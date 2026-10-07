# Repository Workflow Rules

## 1. Testing & Quality Assurance Before Push
- **Comprehensive Unit & Widget Testing**: Every new feature must be accompanied by unit tests (domain models, repositories, state notifiers) and widget tests (UI components, user interactions, edge cases).
- **Full Suite Execution**: Before any commit or push, you MUST run:
  1. The feature's specific tests.
  2. The entire test suite (`flutter test` across all files to ensure zero regressions across the whole app).
  3. Static analysis (`flutter analyze`) to verify zero warnings or linter errors.
  4. If backend code or schemas were touched, run backend tests (`pytest tests/ -v`).
- **No Overflows or Regressions**: Verify the UI layout has no RenderFlex overflows and all contracts remain intact before considering the feature done.

## 2. Git Commit & Push Policy
- **Immediate Push After Verification**: Only after completing and strictly verifying the feature with all passing tests and zero static analysis issues, immediately stage (`git add`), commit with a concise conventional commit message, and push directly to GitHub (`origin main`).
- **No Unpushed Work**: Do not leave completed features uncommitted or unpushed in the local working tree.
