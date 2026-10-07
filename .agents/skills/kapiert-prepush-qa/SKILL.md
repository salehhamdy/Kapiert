---
name: kapiert-prepush-qa
description: >-
  Enforces the mandatory quality assurance workflow before pushing to GitHub.
  Use whenever a new feature, bugfix, or refactor is completed to run unit and widget tests,
  execute flutter analyze, check RenderFlex layout overflow regressions, stage, commit, and push.
---

# Kapiert Pre-Push QA & Verification Runbook

This skill outlines the strict verification and push pipeline mandated by `AGENTS.md`. Never push code to `origin main` without completing every verification step in this runbook.

## Pipeline Steps

### 1. Run Feature-Specific Tests
Before running the full suite, verify that newly added or modified test files pass cleanly:
```powershell
flutter test test/features/<feature>/<feature>_test.dart
```

### 2. Run the Full Flutter Test Suite
Run the entire Flutter test suite across all feature and domain modules to ensure zero regressions:
```powershell
cd flutter_app
flutter test
```
- **Target**: 100% passing tests (zero failures).
- If any test fails, diagnose whether it is an uninitialized dependency (e.g. `StorageService` accessed without provider override) or a regression before continuing.

### 3. Run Flutter Static Analysis
Verify that the codebase has zero warnings, errors, or deprecated usage:
```powershell
cd flutter_app
flutter analyze
```
- **Target**: `No issues found!`.
- Fix any unused imports, type mismatches, or style lints immediately.

### 4. Run Backend Tests (If Backend Was Touched)
If any backend code (`backend/`), schemas, or API contracts were modified:
```powershell
cd backend
python -m pytest tests/ -v
```
- **Target**: 100% passing (12/12 tests or more).

### 5. Layout & RenderFlex Overflow Inspection
Check widget test outputs for:
- `A RenderFlex overflowed by X pixels`
- Verify that charts, lists, and modal sheets are wrapped in appropriate scrollables (`SingleChildScrollView`) or bounded constraints (`SizedBox`, `Expanded`).

### 6. Stage, Commit & Push Immediately
Only after steps 1–5 have completed with 0 errors:
```powershell
git status
git add .
git commit -m "<type>: <concise description of feature/fix>"
git push origin main
```
- Verify that `git status` reports: `nothing to commit, working tree clean` and `Your branch is up to date with 'origin/main'`.
