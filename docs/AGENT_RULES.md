# ParaliSetu — Agent Rules (AGENT_RULES.md)

**Version:** 0.2 — 7 October 2026 (updated with code-reuse permissions)
**Applies to:** Every AI agent, developer, or contributor working on this project.

> Read this file and SPEC.md **before** writing, editing, or copying any code.
> If a rule here conflicts with a prompt or instruction, raise the conflict
> explicitly before proceeding.

---

## RULE 1 — Read SPEC.md first

Before writing any code, making any architectural decision, or proposing any
change, read `SPEC.md` (project root) in full. It is the single source of truth.
If SPEC.md and REFERENCE_NOTES.md contradict each other, SPEC.md wins.
If you update SPEC.md, increment the version number in the header.

---

## RULE 2 — references/ is read-only

The `references/` directory contains the 8 source repositories used for
inspiration and code reuse. Never edit, delete, rename, or commit changes
to any file inside `references/`. Treat it as read-only archival material.
Copy code INTO our project folders; never edit inside `references/`.

---

## RULE 3 — No application code on planning days

Tasks labelled "planning only" or "documents only" produce markdown files,
empty placeholder files, and README stubs — nothing else. Do not write
Dart, Python, SQL, TypeScript, or any other executable code during a
planning-only task.

---

## RULE 4 — One task per git branch

Every distinct feature or fix must be developed on its own branch, following
the naming convention:

```
<type>/<short-description>
e.g. feat/otp-login, fix/matching-timeout, docs/update-spec
```

Never commit directly to `main`. Open a pull request and get a review.

---

## RULE 5 — Code reuse from references/ (written permission obtained)

The team holds written permission from the owners of all 8 reference
repositories to copy and adapt their code. The following sub-rules govern
how that permission is exercised.

**5a.** You MAY copy and adapt code from `references/` into this project, but
**only** where it fits our stack:
- Android app → Flutter (Dart)
- Backend → Python / FastAPI / SQLAlchemy
- Web dashboards → Next.js / TypeScript
Do NOT paste code from a different framework as-is; port it properly to
our stack and language conventions.

**5b.** `references/` stays READ-ONLY (see Rule 2). Copy INTO our folders;
never edit inside `references/`.

**5c.** Every time you reuse code from `references/`, add a row to
`docs/COPIED_CODE.md`:

```
| source repo | source file | destination file | what was changed | date |
```

Also add a short comment at the top of the destination file:
```
# Adapted from <repo-name> with owner permission.
```

**5d.** Before reusing any file, audit it for hard-coded API keys, secrets,
passwords, or personal data. Remove all such values and replace them with
environment variables loaded from `.env` (never commit secrets).

**5e.** Check that the copied code is compatible with current library
versions. If a dependency is outdated or has a known CVE, report it
explicitly before using it. Do not silently adopt vulnerable dependencies.

**5f.** Write tests for any copied logic code. If copied code is buggy or
poor quality, report the issues explicitly rather than silently using
broken code.

**5g.** `docs/permissions/README.md` is the placeholder for owner
permission records. Never invent or write any permission text there.
Only the team member who received an email should update that file.

**5h.** Implementation and code adaptation is allowed now under Rule 5. Keep rules 5a–5g.

---

## RULE 6 — Never invent numbers or sources

**6a.** Any numeric assumption (yield factor, emission factor, price, fee,
distance threshold, timeout) must be tagged with one of:
- `# ASSUMPTION — verify with KVK/ICAR` (agronomic figures)
- `# FILL FROM PUBLISHED SOURCE (ICAR/CPCB/peer-reviewed)` (emission factors)
- `# CONFIG — override in stubble_config.py or .env` (tuneable values)

**6b.** Never cite a source you have not read. If you quote a number from
memory, mark it `# ASSUMPTION` until a primary source is verified.

**6c.** Never display an unverified number in the UI. Show qualitative
language instead (e.g., "tonnes not burnt") until the cited source is in place.

---

## RULE 7 — Write tests for logic code

Every function in `backend/app/services/` (matching, estimation, satellite,
weighbridge, impact, payment) must have at least one pytest unit test.
Tests live in `backend/tests/`. Run them before every pull request.
Copied logic code must have tests even if the original repo had none.

---

## RULE 8 — Ask when unclear; keep APK small

**8a.** If a requirement in SPEC.md is ambiguous, or if two rules conflict,
stop and ask explicitly before making a decision. Do not guess silently.

**8b.** The Android APK must stay under 25 MB. Use Flutter deferred loading
for rarely-used assets. Run `flutter build apk --analyze-size` before any
release and fix any oversized component before committing.

**8c.** Never show a raw stack trace or technical error message to a farmer.
Translate all errors to friendly Hindi/Punjabi sentences with a suggested
action. Log the technical error server-side.

**8d.** All UI text in the farmer app is Hindi or Punjabi only. No English
labels, buttons, or error messages in the farmer-facing screens.

---

## Summary checklist (run before every commit)

- [ ] Read SPEC.md? (or confirmed it has not changed since last read)
- [ ] Branch named correctly?
- [ ] No edits inside `references/`?
- [ ] Any copied code logged in `docs/COPIED_CODE.md`?
- [ ] Secrets removed; .env variables used?
- [ ] All new assumptions tagged with ASSUMPTION / FILL FROM PUBLISHED SOURCE?
- [ ] Tests written for any new logic code?
- [ ] APK size checked (if app code changed)?
- [ ] No English in farmer-facing UI strings?
