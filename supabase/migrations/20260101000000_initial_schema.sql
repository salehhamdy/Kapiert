-- Kapiert initial Supabase schema
-- Run via Supabase CLI: supabase db push
-- Or paste into Supabase Dashboard → SQL Editor

-- ---------------------------------------------------------------------------
-- Profiles (extends auth.users)
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', split_part(new.email, '@', 1)));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Lookup history (mirrors Flutter SQLite history table)
-- ---------------------------------------------------------------------------
create table if not exists public.lookup_history (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  timestamp timestamptz not null default now(),
  word text not null,
  article text not null check (article in ('der', 'die', 'das')),
  correct boolean not null default true,
  mode text not null default 'lookup' check (mode in ('lookup', 'quiz')),
  created_at timestamptz not null default now()
);

create index if not exists lookup_history_user_id_idx on public.lookup_history (user_id);
create index if not exists lookup_history_timestamp_idx on public.lookup_history (timestamp desc);

alter table public.lookup_history enable row level security;

create policy "Users can view own history"
  on public.lookup_history for select
  using (auth.uid() = user_id);

create policy "Users can insert own history"
  on public.lookup_history for insert
  with check (auth.uid() = user_id);

create policy "Users can delete own history"
  on public.lookup_history for delete
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Streaks (mirrors SharedPreferences streak storage)
-- ---------------------------------------------------------------------------
create table if not exists public.streaks (
  user_id uuid primary key references auth.users (id) on delete cascade,
  current_streak integer not null default 0,
  last_active_date date,
  updated_at timestamptz not null default now()
);

alter table public.streaks enable row level security;

create policy "Users can view own streak"
  on public.streaks for select
  using (auth.uid() = user_id);

create policy "Users can upsert own streak"
  on public.streaks for insert
  with check (auth.uid() = user_id);

create policy "Users can update own streak"
  on public.streaks for update
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Favorites (future feature)
-- ---------------------------------------------------------------------------
create table if not exists public.favorites (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  word text not null,
  article text not null check (article in ('der', 'die', 'das')),
  gender text check (gender in ('m', 'f', 'n')),
  plural text,
  translation text,
  created_at timestamptz not null default now(),
  unique (user_id, word)
);

alter table public.favorites enable row level security;

create policy "Users can manage own favorites"
  on public.favorites for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- User settings (mirrors SharedPreferences settings)
-- ---------------------------------------------------------------------------
create table if not exists public.user_settings (
  user_id uuid primary key references auth.users (id) on delete cascade,
  show_hints boolean not null default true,
  dark_mode boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.user_settings enable row level security;

create policy "Users can view own settings"
  on public.user_settings for select
  using (auth.uid() = user_id);

create policy "Users can upsert own settings"
  on public.user_settings for insert
  with check (auth.uid() = user_id);

create policy "Users can update own settings"
  on public.user_settings for update
  using (auth.uid() = user_id);
