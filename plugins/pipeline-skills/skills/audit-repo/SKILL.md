---
name: audit-repo
description: Run general-purpose multi-phase audit pipeline on any repository
argument-hint: "[path ...] [phase-1|phase-2|phase-3|full] [date] [--variant name]"
disable-model-invocation: true
---

# Repo Audit Pipeline

Multi-phase general-purpose architectural audit — language and framework agnostic.

## Usage

```
/audit-repo                              # Audit current directory
/audit-repo ../dj-platform               # Audit another repo
/audit-repo ../dj-platform ../fullfine-services  # Audit multiple repos (one run each)
/audit-repo ../dj-platform phase-1       # Phase 1 only on another repo
/audit-repo phase-2 2026-02-20           # Phase 2 using existing Phase 1
/audit-repo ../dj-platform phase-2 2026-02-20 --variant v2  # Branch with variant
```

---

## Step 0: Parse Arguments & Setup Run

```bash
#!/bin/bash
TODAY=$(date +%Y-%m-%d)
AUDIT_ROOT="faudit/runs/repo"

# Parse arguments: separate paths from mode/flags
# Any argument that is an existing directory OR starts with ../ or ./ or / is a TARGET_PATH
# Known mode keywords: full, phase-1, phase-2, phase-3
# Everything else follows the mode parsing from before

TARGETS=()
MODE="full"
PHASE_SOURCE_DATE="$TODAY"
VARIANT=""

for arg in "$@"; do
    if [ "$arg" = "full" ] || [ "$arg" = "phase-1" ] || [ "$arg" = "phase-2" ] || [ "$arg" = "phase-3" ]; then
        MODE="$arg"
    elif [ "$arg" = "--variant" ]; then
        READING_VARIANT=true
    elif [ "$READING_VARIANT" = "true" ]; then
        VARIANT="$arg"
        READING_VARIANT=""
    elif [[ "$arg" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
        PHASE_SOURCE_DATE="$arg"
    elif [ -d "$arg" ] || [[ "$arg" == ../* ]] || [[ "$arg" == ./* ]] || [[ "$arg" == /* ]]; then
        TARGETS+=("$arg")
    fi
done

# Default to current directory if no targets specified
if [ ${#TARGETS[@]} -eq 0 ]; then
    TARGETS=(".")
fi
```

**For each TARGET in TARGETS**, run the full pipeline independently:

```bash
for TARGET in "${TARGETS[@]}"; do
    # Resolve target name for run directory
    TARGET_NAME=$(basename $(realpath "$TARGET"))

    # Run directory includes target name
    if [ "$TARGET_NAME" = "$(basename $(pwd))" ]; then
        # Auditing current directory — no target prefix
        RUN_BASE="$AUDIT_ROOT/$TODAY"
    else
        # Auditing external repo — include target name
        RUN_BASE="$AUDIT_ROOT/${TARGET_NAME}/$TODAY"
    fi

    if [ -n "$VARIANT" ]; then
        RUN_DIR="${RUN_BASE}-${VARIANT}"
    else
        RUN_DIR="$RUN_BASE"
        # Auto-increment if exists
        if [ -d "$RUN_DIR" ] && [ "$MODE" = "full" -o "$MODE" = "phase-1" ]; then
            N=2
            while [ -d "${RUN_DIR}-v${N}" ]; do N=$((N+1)); done
            RUN_DIR="${RUN_DIR}-v${N}"
        fi
    fi

    # Resolve TARGET to absolute path for agent prompts
    TARGET_PATH=$(realpath "$TARGET")
done
```

**Ensure `faudit/runs/` is gitignored** before creating any output:
- If `.gitignore` exists and doesn't already contain `faudit/runs/`, append it
- If `.gitignore` doesn't exist, create it with `faudit/runs/`

For phase-2 or phase-3, resolve input directories (same logic as before, but under the target-specific run path).

Display:
```
REPO AUDIT PIPELINE
─────────────────────────────────
Target(s): {TARGET_PATH} (for each target)
Mode:      {MODE}
Run dir:   {RUN_DIR}
Phase 1:   {PHASE1_DIR} (if phase-2/phase-3)
Phase 2:   {PHASE2_DIR} (if phase-3)
─────────────────────────────────
```

Write `{RUN_DIR}/run-manifest.json` with pipeline version, git commit (from target repo: `git -C {TARGET_PATH} rev-parse --short HEAD`), branch, mode, timestamp, target path, project name (`basename {TARGET_PATH}`), and `"status": "running"`.

---

## Step 1: Phase 1 — Discovery

**Skip if**: `MODE` is `phase-2` or `phase-3`

Read the phase definition and execute:

1. Create output directory: `mkdir -p {RUN_DIR}/phase-01`
2. Read `phases/01-discovery.md` for agent prompts
3. Read `templates/findings-format.md` for output format
4. **Inject `{TARGET_PATH}` into every agent prompt**: Add to each agent's prompt preamble:
   ```
   ## Target Repository
   Analyze the repository at: {TARGET_PATH}
   All file paths in your analysis should be relative to this root.
   ```
5. Launch **5 Explore agents in parallel** (single message, multiple Task calls)
6. Each agent:
   - Type: `Explore`
   - Writes findings to `{RUN_DIR}/phase-01/{NN-name}.md`
   - Uses the findings format template
   - **Scoped to `{TARGET_PATH}`** — all exploration within that directory
7. Wait for all 5 to complete
8. **Verify outputs**: Check that all 5 expected files exist. Report any missing.
9. **Produce `00-consolidated.md`**: Read all 5 files, deduplicate findings, aggregate metrics, produce summary table (see `01-discovery.md` Execution Notes for format)

**After Phase 1**:

Report to user:
```
Phase 1 complete for {TARGET_NAME}. 5 discovery files + consolidated summary written to: {RUN_DIR}/phase-01/

| File                    | V | D | S | R | P | O | Crit | High |
|-------------------------|---|---|---|---|---|---|------|------|
| 01-structure.md         | N | N | N | N | N | N | N    | N    |
| 02-code-quality.md      | N | N | N | N | N | N | N    | N    |
| 03-dependencies.md      | N | N | N | N | N | N | N    | N    |
| 04-testing.md           | N | N | N | N | N | N | N    | N    |
| 05-documentation.md     | N | N | N | N | N | N | N    | N    |

Review the findings, then say "continue" to proceed to Phase 2,
or "stop" to end the audit here.
```

**STOP and wait for user instruction.** If `MODE=full`, pause here for checkpoint.

---

## Step 2: Phase 2 — Interpretation

**Skip if**: `MODE` is `phase-1`

1. Set `INPUT_DIR`:
   - If `MODE=phase-2` or `MODE=phase-3`: use the phase-1 from source date
   - If `MODE=full`: use `{RUN_DIR}/phase-01`
2. **Staleness check**: If using a Phase 1 from a different date, compare the `git_commit` in that run's `run-manifest.json` against current `HEAD` of the target repo. If different, warn user and ask to confirm.
3. Create output directory: `mkdir -p {RUN_DIR}/phase-02`
4. Read `phases/02-interpretation.md` for agent prompts
5. Build `{SHARED CONTEXT BLOCK}` — replace `{INPUT_DIR}` in the template. Add `{TARGET_PATH}` so agents can verify against source. If any Phase 1 file is missing, omit it from the file list and add a note.
6. Launch **3 general-purpose agents in parallel**
7. Each agent:
   - Type: `general-purpose`
   - Reads consolidated summary + Phase 1 files from `{INPUT_DIR}/`
   - Can read source files at `{TARGET_PATH}` for verification
   - Writes interpretation to `{RUN_DIR}/phase-02/{NN-name}.md`
   - Mode: research/analysis only, no code changes
8. Wait for all 3 to complete
9. **Verify outputs**: Check that all 3 expected files exist.

**After Phase 2**:

Report to user:
```
Phase 2 complete for {TARGET_NAME}. 3 expert analyses written to: {RUN_DIR}/phase-02/

  01-architecture.md     - Architecture + Implementation analysis
  02-domain-quality.md   - Domain + Quality analysis
  03-docs-dx.md          - Documentation + DX analysis

Review the analyses, then say "continue" to proceed to Phase 3 (synthesis + action plan),
or "stop" to end here.
```

**STOP and wait for user instruction.**

---

## Step 3: Phase 3 — Synthesis + Action Plan

**Skip if**: `MODE` is `phase-1` or `phase-2`

1. Set directories:
   - `PHASE1_DIR`: Phase 1 output location
   - `PHASE2_DIR`: Phase 2 output location (same run, or from source date)
2. Create output directory: `mkdir -p {RUN_DIR}/phase-03`
3. Read `phases/03-synthesis.md` for agent prompt
4. Launch **1 general-purpose agent**
   - Reads ALL Phase 1 + Phase 2 outputs
   - Writes synthesis+plan to `{RUN_DIR}/phase-03/01-synthesis-plan.md`
5. Wait for completion

---

## Step 4: Final Report

Update `run-manifest.json`: set `"status": "completed"`, add `"completed_at"`.

Present the results:

```
Audit complete for {TARGET_NAME}!

Final report:  {RUN_DIR}/phase-03/01-synthesis-plan.md

All outputs:
  Phase 1 (Discovery):      {RUN_DIR}/phase-01/ (5 files + summary)
  Phase 2 (Interpretation):  {RUN_DIR}/phase-02/ (3 files)
  Phase 3 (Synthesis):       {RUN_DIR}/phase-03/ (1 file)

To re-run later phases with different focus:
  /audit-repo {TARGET} phase-2 {date}
  /audit-repo {TARGET} phase-3 {date}
```

Read and display the Executive Summary and Sprint 1 tasks from `01-synthesis-plan.md`.

**If multiple targets**: After completing one target, proceed to the next. Each gets its own run directory and independent pipeline execution.

---

## Run Directory Layout

```
faudit/runs/repo/
├── 2026-02-20/              # Current repo (no target prefix)
│   ├── run-manifest.json
│   ├── phase-01/
│   ├── phase-02/
│   └── phase-03/
├── dj-platform/             # External repo runs grouped by target
│   └── 2026-02-20/
│       ├── run-manifest.json
│       ├── phase-01/
│       ├── phase-02/
│       └── phase-03/
└── fullfine-services/
    └── 2026-02-20/
        └── ...
```

---

## Quick Reference

| Phase | Agents | Type | Parallel | Duration |
|-------|--------|------|----------|----------|
| 1. Discovery | 5 | Explore | All 5 parallel | ~15 min |
| [checkpoint 1] | — | — | — | User review |
| 2. Interpretation | 3 | general-purpose | All 3 parallel | ~15 min |
| [checkpoint 2] | — | — | — | User review |
| 3. Synthesis | 1 | general-purpose | Sequential | ~15 min |

**Total**: 9 agents per target, ~45 min per target (excluding review time)

## Pipeline Definition

Full pipeline configuration: `pipeline.md`
Phase 1 details: `phases/01-discovery.md`
Phase 2 details: `phases/02-interpretation.md`
Phase 3 details: `phases/03-synthesis.md`
Output format: `templates/findings-format.md`
