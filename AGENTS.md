# Agent Instructions & Operating Directives (AGENTS.md)

This file contains mandatory directives for all AI coding agents working on **ParaliSetu**.

## 1. Single Source of Truth
Before planning or writing any code, ALWAYS read:
1. `docs/ROADMAP.md` (Living status, Golden Path, agronomic ground truth)
2. `docs/AGENT_RULES.md` (Repository rules, commit policies, secrets policy)
3. `SPEC.md` (Detailed system architecture and database contracts)

## 2. Anti-Hallucination Guardrails
- **Inspect, Don't Guess:** Never guess table columns or endpoints from memory. Run queries or inspect `backend/app/models/` and `backend/alembic/versions/`.
- **Honesty in Capabilities:** Clearly classify everything as either **BUILT** or **PLANNED**. Do not describe planned or mocked features as completed.
- **Agronomic Authenticity:** Respect the distinction between *total residue* (~3.6 t/acre) and *baler recoverable residue* (~2.0 t/acre). Never change yield formulas without verifying against `backend/app/core/stubble_config.py`.
- **Zero Secrets Policy:** Never print, copy, or commit `.env`, JWT secret keys, Supabase pooler passwords, or private tokens.

## 3. Branching & Testing
- Work in one distinct git branch per task (`<type>/<feature-name>`).
- Run `pytest` for backend changes and `flutter analyze` + `flutter test` for mobile app changes. All tests must be 100% green before submitting work.
