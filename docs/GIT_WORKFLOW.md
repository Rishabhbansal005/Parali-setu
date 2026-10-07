# ParaliSetu Git Workflow

This document explains our Git branching, committing, and GitHub synchronization process in plain language.

---

## 1. Golden Rules

1. **Only ParaliSetu is committed and pushed.**  
   The `references/` folder and any reference repository files are strictly excluded via `.gitignore` and must never be tracked or pushed to GitHub.
2. **Main branch stays stable and green.**  
   Code on `main` must always pass all unit tests and be functional.
3. **Feature and task branches for all changes.**  
   Every task or feature gets its own branch (e.g., `chore/hardening`, `docs/teaching`, `feat/app-onboarding`).
4. **No unauthorized history rewrites.**  
   Never force-push (`git push --force`), rewrite history, or delete branches without explicit approval.
5. **No secret leakage.**  
   Real API keys, phone numbers, email credentials, and private tokens must never be committed. Real keys belong in `.env` (ignored), while `.env.example` contains placeholders.
6. **Report after every push.**  
   After every push, report the branch name, commit hash, and list of files pushed.

---

## 2. Commit Message Standards

Use conventional, descriptive prefixes for all commits:
- `feat:` for a new user-facing feature or functional capability
- `fix:` for fixing a bug or regression
- `docs:` for updating documentation or learning logs
- `test:` for adding or updating unit/integration tests
- `chore:` for repository maintenance, dependencies, or configuration changes

---

## 3. Branching Lifecycle

1. **Create and switch to a branch from latest `main`:**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b <branch-name>
   ```

2. **Make focused changes and test:**
   - Write tests first or alongside code.
   - Run test suite locally (`pytest`, `flutter test`, etc.) and ensure all pass.

3. **Stage and commit:**
   - Verify `git status` to ensure no unexpected files or reference repositories are staged.
   - Commit with clear message:
     ```bash
     git add <files>
     git commit -m "feat: descriptive summary of change"
     ```

4. **Push branch to GitHub:**
   ```bash
   git push -u origin <branch-name>
   ```

5. **Merge to `main` only after tests pass and user gives OK:**
   ```bash
   git checkout main
   git merge <branch-name>
   git push origin main
   ```

---

## 4. Current Remote

- **Remote URL:** `https://github.com/Rishabhbansal005/Parali-setu.git`
- **Default branch:** `main`
