# 🛠️ Kapiert Project Skills, Hooks & Subagents Reference

This document indexes all operational skills, automation hooks, and specialized subagents configured for **Kapiert** under the `.agents/` customization root.

---

## 📚 1. Workspace Skills (`.agents/skills/`)

| Skill | Path | Description | When to Use |
|---|---|---|---|
| **`kapiert-prepush-qa`** | [`.agents/skills/kapiert-prepush-qa/SKILL.md`](file:///c:/Users/ASUS/Downloads/German_Articles/.agents/skills/kapiert-prepush-qa/SKILL.md) | Enforces mandatory test verification (`flutter test`, `flutter analyze`, `pytest`), overflow checks, conventional commits, and direct push to `origin main`. | After finishing any feature, bug fix, or refactor before marking the task complete. |
| **`kapiert-flutter-riverpod`** | [`.agents/skills/kapiert-flutter-riverpod/SKILL.md`](file:///c:/Users/ASUS/Downloads/German_Articles/.agents/skills/kapiert-flutter-riverpod/SKILL.md) | Architectural guidelines for Flutter Riverpod 2.x, clean architecture layers, reactive listeners, and critical ProviderScope testing overrides. | When building or modifying UI screens, widgets, StateNotifiers, or writing widget tests. |
| **`kapiert-sqlite-storage`** | [`.agents/skills/kapiert-sqlite-storage/SKILL.md`](file:///c:/Users/ASUS/Downloads/German_Articles/.agents/skills/kapiert-sqlite-storage/SKILL.md) | Local-first SQLite engineering, schema versioning (v1–v5), Desktop FFI setup, streak logic, and SQL date aggregations for heatmaps. | When updating local database tables, writing custom SQL queries, or adding persistence models. |
| **`kapiert-fastapi-backend`** | [`.agents/skills/kapiert-fastapi-backend/SKILL.md`](file:///c:/Users/ASUS/Downloads/German_Articles/.agents/skills/kapiert-fastapi-backend/SKILL.md) | FastAPI Python 3.13 backend service, in-memory dictionary (90k nouns), normalization (umlauts, ß, compounds), anti-clumping batching, and Docker/pytest. | When modifying backend endpoints, dictionary datasets, quiz balancing, or running backend tests. |
| **`kapiert-supabase-sync`** | [`.agents/skills/kapiert-supabase-sync/SKILL.md`](file:///c:/Users/ASUS/Downloads/German_Articles/.agents/skills/kapiert-supabase-sync/SKILL.md) | Two-way cloud synchronization, auth state handling (Guest vs. Signed-in), offline queues, RLS policies, and `merge_streak` RPC. | When implementing user account features, cloud backups, or modifying Supabase PostgreSQL tables. |

---

## 🤖 2. Specialized Subagents (`.agents/agents/`)

| Subagent | Path | Role & Capabilities |
|---|---|---|
| **`qa-auditor`** | [`.agents/agents/qa-auditor/AGENT.md`](file:///c:/Users/ASUS/Downloads/German_Articles/.agents/agents/qa-auditor/AGENT.md) | Runs full test suites (`flutter test`, `flutter analyze`, `pytest`), inspects terminal logs for `RenderFlex` overflows, verifies 0 linter issues, and certifies readiness for git push. |
| **`german-linguist`** | [`.agents/agents/german-linguist/AGENT.md`](file:///c:/Users/ASUS/Downloads/German_Articles/.agents/agents/german-linguist/AGENT.md) | Linguistic domain expert for German grammatical gender rules (*der/die/das* suffix heuristics), compound noun resolution (*Grundwort* rule), plural declensions, and English translation enrichment. |

---

## 🪝 3. Lifecycle Hooks (`.agents/hooks.json`)

Located at [`.agents/hooks.json`](file:///c:/Users/ASUS/Downloads/German_Articles/.agents/hooks.json):

```json
{
  "kapiert-pre-push-guard": {
    "enabled": true,
    "PreToolUse": [
      {
        "matcher": "run_command",
        "hooks": [
          {
            "type": "command",
            "command": "python scripts/hook_runner.py",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

- **`hook_runner.py`** ([`.agents/scripts/hook_runner.py`](file:///c:/Users/ASUS/Downloads/German_Articles/.agents/scripts/hook_runner.py)): Intercepts shell commands, audits `git push` actions, and confirms compliance with testing rules before execution.

---

## 🔄 4. Pre-Push Verification Quick Reference

```powershell
# 1. Run Flutter Tests (all 82 tests)
cd flutter_app
flutter test

# 2. Run Static Analysis (zero issues)
flutter analyze

# 3. Run Backend Pytest (all 12 tests)
cd ../backend
python -m pytest tests/ -v

# 4. Stage, Commit & Push
cd ..
git add .
git commit -m "<type>: <description>"
git push origin main
```
