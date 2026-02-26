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
/solve extract shared validation logic into a utils package
```

Everything after `/solve` is the request. Always targets the current directory.

---

## Step 0: Parse Arguments & Setup Run

```bash
#!/bin/bash
TODAY=$(date +%Y-%m-%d)
SOLVE_ROOT="faudit/runs/solve"

# Everything after the command name is the request
REQUEST="$*"

# Validate
if [ -z "$REQUEST" ]; then
    echo "Usage: /solve <your request>"
    echo "Example: /solve add rate limiting to the API"
    exit 1
fi

# Run directory with auto-increment
RUN_DIR="$SOLVE_ROOT/$TODAY"
if [ -d "$RUN_DIR" ]; then
    N=2
    while [ -d "${RUN_DIR}-v${N}" ]; do N=$((N+1)); done
    RUN_DIR="${RUN_DIR}-v${N}"
fi

mkdir -p "$RUN_DIR"
```

**Ensure `faudit/runs/` is gitignored** before creating any output:
- If `.gitignore` exists and doesn't already contain `faudit/runs/`, append it
- If `.gitignore` doesn't exist, create it with `faudit/runs/`

Display:

```
SOLVE PIPELINE
─────────────────────────────────
Request:   {REQUEST}
Run dir:   {RUN_DIR}
─────────────────────────────────
```

Write `{RUN_DIR}/run-manifest.json`:

```json
{
  "pipeline": "solve",
  "version": 2,
  "started_at": "<ISO timestamp>",
  "git_commit": "<git rev-parse --short HEAD>",
  "git_branch": "<git branch --show-current>",
  "request": "{REQUEST}",
  "agents": { "phase1": 3, "phase2": 2, "phase3": 0 },
  "status": "running"
}
```

---

## Step 1: Phase 1 -- Discovery

1. Create output directory: `mkdir -p {RUN_DIR}/phase-01`
2. Set `OUTPUT_DIR={RUN_DIR}/phase-01`
3. Read `~/.claude/skills/solve/phases/01-discovery.md` for agent definitions
4. Read `~/.claude/skills/solve/templates/discovery-format.md` for output format
5. Substitute `{REQUEST}` and `{OUTPUT_DIR}` into each agent's prompt
6. Launch **3 agents in parallel** (single message, multiple Task calls):
   - Agent 1: `code-explorer` -- writes to `{OUTPUT_DIR}/01-code-structure.md`
   - Agent 2: `pattern-analyzer` -- writes to `{OUTPUT_DIR}/02-patterns.md`
   - Agent 3: `dependency-mapper` -- writes to `{OUTPUT_DIR}/03-dependencies.md`
7. Wait for all 3 to complete
8. **Verify outputs**: Check that all 3 expected files exist. Report any missing.
9. **Produce `00-consolidated.md`**: Read all 3 files, then write a consolidated summary (format defined in `phases/01-discovery.md`).

### After Phase 1

Report to user:

```
Phase 1 complete. 3 discovery agents finished.

| # | Agent              | File                  | Key Findings              |
|---|--------------------|-----------------------|---------------------------|
| 1 | code-explorer      | 01-code-structure.md  | {1-2 sentence summary}    |
| 2 | pattern-analyzer   | 02-patterns.md        | {1-2 sentence summary}    |
| 3 | dependency-mapper  | 03-dependencies.md    | {1-2 sentence summary}    |

Files written to: {RUN_DIR}/phase-01/

Review the findings, then say "continue" to proceed to Phase 2 (solution design),
or "stop" to end here.
```

**STOP and wait for user instruction.**

---

## Step 2: Phase 2 -- Solution Design

1. Set `INPUT_DIR={RUN_DIR}/phase-01`
2. Set `OUTPUT_DIR={RUN_DIR}/phase-02`
3. Create output directory: `mkdir -p {RUN_DIR}/phase-02`
4. Read `~/.claude/skills/solve/phases/02-solution.md` for agent definitions
5. Build `{SHARED CONTEXT BLOCK}` from `phases/02-solution.md`:
   - Insert `{REQUEST}`
   - Insert Phase 1 file list (from `00-consolidated.md`)
   - Insert `{INPUT_DIR}` paths
6. Substitute variables into each agent's prompt
7. Launch **2 agents in parallel** (single message, multiple Task calls):
   - Agent 1: `solution-architect` -- writes to `{OUTPUT_DIR}/01-solution-plan.md`
   - Agent 2: `risk-analyst` -- writes to `{OUTPUT_DIR}/02-risk-analysis.md`
8. Wait for both to complete
9. **Verify outputs**: Check that both files exist.

### After Phase 2

Read the executive summary and task list from `01-solution-plan.md`. Report to user:

```
Phase 2 complete. Solution plan and risk analysis written to: {RUN_DIR}/phase-02/

{Display the Executive Summary section from 01-solution-plan.md}

{Display the Task List section from 01-solution-plan.md}

This is a usable plan. Say "continue" for Phase 3 (deeper synthesis and validation),
or "done" to finish here.
```

**STOP and wait for user instruction.**

---

## Step 3: Phase 3 -- Synthesis (Optional)

Only reached if user says "continue" after Phase 2.

1. Set `PHASE1_DIR={RUN_DIR}/phase-01`
2. Set `PHASE2_DIR={RUN_DIR}/phase-02`
3. Set `OUTPUT_DIR={RUN_DIR}/phase-03`
4. Create output directory: `mkdir -p {RUN_DIR}/phase-03`
5. Read `~/.claude/skills/solve/phases/03-synthesis.md` for agent definition
6. Substitute all variables: `{REQUEST}`, `{PHASE1_DIR}`, `{PHASE2_DIR}`, `{OUTPUT_DIR}`
7. Launch **1 `synthesizer` agent**
   - Reads ALL Phase 1 + Phase 2 outputs
   - Writes to `{OUTPUT_DIR}/01-implementation-plan.md`
8. Wait for completion
9. Update `agents.phase3` to 1 in `run-manifest.json`

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

| Phase | Agents | Type | Parallel | Duration |
|-------|--------|------|----------|----------|
| 1. Discovery | 3 | code-explorer, pattern-analyzer, dependency-mapper | All parallel | ~10 min |
| [checkpoint 1] | -- | -- | -- | User review |
| 2. Solution | 2 | solution-architect, risk-analyst | All parallel | ~10 min |
| [checkpoint 2] | -- | -- | -- | User review |
| 3. Synthesis (opt) | 1 | synthesizer | Sequential | ~10 min |

**Total**: 5-6 agents, ~20-30 min (excluding review time)

## References

Full pipeline configuration: `~/.claude/skills/solve/pipeline.md`
Phase 1 details: `~/.claude/skills/solve/phases/01-discovery.md`
Phase 2 details: `~/.claude/skills/solve/phases/02-solution.md`
Phase 3 details: `~/.claude/skills/solve/phases/03-synthesis.md`
Shared agent definitions: `~/.claude/agents/`
Discovery output format: `~/.claude/skills/solve/templates/discovery-format.md`
Solution output format: `~/.claude/skills/solve/templates/solution-format.md`
