---
name: solve
description: Analyze a free-text request and produce a concrete implementation plan
argument-hint: "<request text>"
disable-model-invocation: true
---

# Solve Pipeline

Goal-directed multi-phase solution planning -- language and framework agnostic.

## Usage

```
/solve add rate limiting to the API endpoints
/solve fix the flaky integration tests in payments module
/solve refactor auth module to use JWT instead of sessions
```

Everything after `/solve` is the request. Always targets the current directory.

## Supporting Files

This skill uses a modular file structure. Read files on demand as each phase begins:

- `phases/discovery.md` — Phase 1 agent prompts and consolidation
- `phases/solution.md` — Phase 2 agent prompts and shared context
- `phases/synthesis.md` — Phase 3 synthesizer prompt
- `templates/` — Output format templates referenced by agent prompts
- `pipeline.md` — Pipeline architecture reference

---

## Execution Order

Follow steps 0 → 1 → 2 → 3 → 4 strictly in sequence. Step 0 MUST complete (directory created, manifest written, banner displayed) before any research or agent work begins.

---

## Step 0: Setup Run (do this FIRST)

Before any research, exploration, or agent work — execute these setup actions immediately:

1. **Create the run directory**:
   ```bash
   TODAY=$(date +%Y-%m-%d)
   SOLVE_ROOT="faudit/runs/solve"
   RUN_DIR="$SOLVE_ROOT/$TODAY"
   # If directory exists, append -v2, -v3, etc.
   ```
   Run the mkdir command now. Ensure `faudit/runs/` is in `.gitignore`.

2. **Write `{RUN_DIR}/run-manifest.json`** with this content:
   ```json
   {
     "pipeline": "solve",
     "version": 3,
     "started_at": "<ISO timestamp>",
     "git_commit": "<git rev-parse --short HEAD>",
     "git_branch": "<git branch --show-current>",
     "request": "<the user's request text>",
     "agents": { "phase1": 3, "phase2": 2, "phase3": 0 },
     "status": "running"
   }
   ```

3. **Display the banner** to the user:
   ```
   SOLVE PIPELINE
   ─────────────────────────────────
   Request:   {REQUEST}
   Run dir:   {RUN_DIR}
   Agents:    ps:code-explorer, ps:pattern-analyzer, ps:dependency-mapper
              ps:solution-architect, ps:risk-analyst, ps:synthesizer
   ─────────────────────────────────
   ```

Only after the banner is displayed and manifest is written, proceed to Step 1.

---

## Step 1: Phase 1 — Discovery

1. Create output directory: `mkdir -p {RUN_DIR}/phase-01`
2. Set `OUTPUT_DIR={RUN_DIR}/phase-01`
3. **Read `phases/discovery.md`** and execute the phase as described there.

---

## Step 2: Phase 2 — Solution Design

1. Set `INPUT_DIR={RUN_DIR}/phase-01`
2. Set `OUTPUT_DIR={RUN_DIR}/phase-02`
3. Create output directory: `mkdir -p {RUN_DIR}/phase-02`
4. **Read `phases/solution.md`** and execute the phase as described there.

---

## Step 3: Phase 3 — Synthesis (Optional)

Only reached if user says "continue" after Phase 2.

1. Set `PHASE1_DIR={RUN_DIR}/phase-01`
2. Set `PHASE2_DIR={RUN_DIR}/phase-02`
3. Set `OUTPUT_DIR={RUN_DIR}/phase-03`
4. Create output directory: `mkdir -p {RUN_DIR}/phase-03`
5. **Read `phases/synthesis.md`** and execute the phase as described there.

---

## Step 4: Final Report

Update `run-manifest.json`: set `"status": "completed"`, add `"completed_at"`.

Determine the final deliverable location:
- If Phase 3 ran: `{RUN_DIR}/phase-03/01-implementation-plan.md`
- If stopped after Phase 2: `{RUN_DIR}/phase-02/01-solution-plan.md`

Present the results:

```
Solve complete!

Request:     {REQUEST}
Final plan:  {path to final deliverable}

All outputs:
  Phase 1 (Discovery):  {RUN_DIR}/phase-01/ (3 files + summary)
  Phase 2 (Solution):   {RUN_DIR}/phase-02/ (2 files)
  Phase 3 (Synthesis):  {RUN_DIR}/phase-03/ (1 file)    [if applicable]
```

Read and display the Executive Summary from the final deliverable.

---

## Quick Reference

| Phase | Agents | Type | Parallel |
|-------|--------|------|----------|
| 1. Discovery | 3 | ps:code-explorer, ps:pattern-analyzer, ps:dependency-mapper | All parallel |
| [checkpoint] | -- | User review | -- |
| 2. Solution | 2 | ps:solution-architect, ps:risk-analyst | All parallel |
| [checkpoint] | -- | User review | -- |
| 3. Synthesis | 1 | ps:synthesizer | Sequential |

**Total**: 5-6 agents, ~20-30 min (excluding review time)
