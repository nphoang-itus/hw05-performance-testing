# CLAUDE.md — HW05 Performance Testing (HW05-AI)

Student: Nguyễn Phúc Hoàng · ID `23120264` · Class CQ2023/3 · Tool: Claude Code. Reply in **Vietnamese**, keep technical terms in English.
Spec: `docs/HW05-assignment.pdf`. Checklist: `CHECKLIST.md`. SUT: `../eshop-sut-fithcmus` (backend :3000 only; do not modify SUT code).
Tool: JMeter (default). Workflow (option A): `POST /api/login` → `GET /api/products?search=` → `GET /api/products/:id` → `POST /api/cart` → `POST /api/checkout`.
Endpoint analysis: `docs/endpoint-proposal.md`. Repo: https://github.com/nphoang-itus/hw05-performance-testing (public).

## AI audit — MANDATORY on every prompt
After finishing each user prompt, before the final reply:
1. Run `python3 scripts/ailog.py` → rebuilds `docs/ai/prompt-log.md` (verbatim prompt + output, time, files).
2. Append **one row** to the audit table in `docs/ai-audit-report.md` §3 for that turn: prompt (short quote + `prompt-log.md #n`), output summary, verdict (VALID / INVALID / INCOMPLETE / PENDING), reasoning (cite assignment section / slide / ISTQB), student fix. Never invent a verdict about the student's review: if unknown, write what *Claude* verified and mark `Student review: pending`.
3. Refresh §4 statistics (counts + percentages).
4. Commit the audit files with the related work (do not push unless asked).

**Exception:** prompts starting with `[chore]` are skipped by the script; note them in `docs/ai/chore-turns.md` and add no audit row.

## Rules
- AI-first, step by step (analyse workflow → parameters → plan → review); never one generic prompt.
- Test plans are named `23120264_{Load|Stress|Spike}_{YYYYMMDD}.jmx` in `testplans/`. CSV data in `data/`. Three different listener/report types across the three plans.
- Never fabricate execution results, `.jtl` data, screenshots, hostnames or bugs: they come from real runs (assignment §11). The demo video voice, the AI Critique and the self-assessed grade are the **student's**.
- Backend reseeds the DB on every start → restart via `scripts/start-sut.sh` to reset lockout (2 wrong logins lock an account for 180 s) between Stress/Spike runs, and document it.
- Raw `.jtl` go in `results/<scenario>/`, HTML report folders next to them. Screenshots in `evidence/`.
- Commit one step at a time (each test plan, AI analysis, CI proposal). `bash scripts/gen-commit-log.sh` before submission.
