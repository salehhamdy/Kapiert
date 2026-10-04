-- Kapiert cloud sync
-- Adds idempotent history sync, server-side streak merging and
-- last-write-wins settings. Safe to run on top of the initial schema.

-- ---------------------------------------------------------------------------
-- Default user_id to the caller so clients can't spoof it by accident.
-- (RLS `with check` still enforces it.)
-- ---------------------------------------------------------------------------
alter table public.lookup_history alter column user_id set default auth.uid();
alter table public.streaks        alter column user_id set default auth.uid();
alter table public.favorites      alter column user_id set default auth.uid();
alter table public.user_settings  alter column user_id set default auth.uid();

-- ---------------------------------------------------------------------------
-- Lookup history: client-generated id for idempotent upserts
-- ---------------------------------------------------------------------------
alter table public.lookup_history add column if not exists client_id uuid;
update public.lookup_history set client_id = gen_random_uuid() where client_id is null;
alter table public.lookup_history alter column client_id set default gen_random_uuid();
alter table public.lookup_history alter column client_id set not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'lookup_history_user_client_key'
  ) then
    alter table public.lookup_history
      add constraint lookup_history_user_client_key unique (user_id, client_id);
  end if;
end $$;

-- Pull queries are "my rows with id > cursor".
create index if not exists lookup_history_user_id_id_idx
  on public.lookup_history (user_id, id);

-- ---------------------------------------------------------------------------
-- Streaks: merge a device's streak into the server copy.
--
-- A streak (N days ending on L) covers the contiguous days [L-N+1, L].
-- If the two runs overlap or touch, the merged streak is their union;
-- otherwise the more recent run wins. Empty runs (N <= 0 or L is null)
-- never overwrite a real one.
-- ---------------------------------------------------------------------------
create or replace function public.merge_streak(
  p_current_streak integer,
  p_last_active_date date
)
returns public.streaks
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_uid    uuid := auth.uid();
  v_row    public.streaks;
  s_start  date;
  c_start  date;
  m_last   date;
  m_streak integer;
begin
  if v_uid is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  insert into public.streaks (user_id, current_streak, last_active_date)
  values (v_uid, 0, null)
  on conflict (user_id) do nothing;

  select * into v_row from public.streaks where user_id = v_uid for update;

  -- Incoming run is empty: keep server.
  if p_last_active_date is null or coalesce(p_current_streak, 0) <= 0 then
    return v_row;
  end if;

  -- Server run is empty: take incoming.
  if v_row.last_active_date is null or v_row.current_streak <= 0 then
    m_last := p_last_active_date;
    m_streak := p_current_streak;
  else
    s_start := v_row.last_active_date - (v_row.current_streak - 1);
    c_start := p_last_active_date - (p_current_streak - 1);

    if c_start <= v_row.last_active_date + 1 and s_start <= p_last_active_date + 1 then
      -- Overlapping or adjacent: union of both runs.
      m_last := greatest(v_row.last_active_date, p_last_active_date);
      m_streak := (m_last - least(s_start, c_start)) + 1;
    elsif p_last_active_date > v_row.last_active_date then
      m_last := p_last_active_date;
      m_streak := p_current_streak;
    else
      return v_row;
    end if;
  end if;

  update public.streaks
     set current_streak = m_streak,
         last_active_date = m_last,
         updated_at = now()
   where user_id = v_uid
  returning * into v_row;

  return v_row;
end;
$$;

-- Explicit reset (merge_streak can never lower a streak).
create or replace function public.reset_streak()
returns public.streaks
language sql
security invoker
set search_path = public
as $$
  insert into public.streaks (user_id, current_streak, last_active_date, updated_at)
  values (auth.uid(), 0, null, now())
  on conflict (user_id) do update
    set current_streak = 0, last_active_date = null, updated_at = now()
  returning *;
$$;

revoke all on function public.merge_streak(integer, date) from public, anon;
revoke all on function public.reset_streak() from public, anon;
grant execute on function public.merge_streak(integer, date) to authenticated;
grant execute on function public.reset_streak() to authenticated;
