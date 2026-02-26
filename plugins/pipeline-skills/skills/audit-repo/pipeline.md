# Repo Audit Pipeline: General-Purpose Repository Analysis

**Target**: Any software repository — language and framework agnostic
**Phases**: 3 (Discovery → Interpretation → Synthesis)
**Total agents**: 9 (5 + 3 + 1)
**Estimated duration**: ~15 min per phase (~45 min total)

---

## Pipeline Configuration

```yaml
name: repo
version: 1
description: General-purpose deep architectural audit for any software repository
target_scope: auto-discovered  # Agents discover project structure at runtime
standards:
  - README.md (or equivalent)
  - Any architecture docs found during discovery
  - Language/framework community conventions
```

---

## Phase Sequence

### Phase 1: Discovery
- **File**: `phases/01-discovery.md`
- **Agents**: 5 Explore (parallel)
- **Type**: Read-only structural inventory and codebase profiling
- **Output**: `{RUN_DIR}/phase-01/` (5 files + `00-consolidated.md`)
- **Duration**: ~15 min

### [CHECKPOINT 1]

After Phase 1 completes:
1. All 5 agent outputs + consolidated summary are in `{RUN_DIR}/phase-01/`
2. **STOP** — present finding counts summary to user
3. User reviews findings (can browse individual files)
4. User decides: proceed to Phase 2, re-run Phase 1, or stop

### Phase 2: Interpretation
- **File**: `phases/02-interpretation.md`
- **Agents**: 3 general-purpose (parallel)
- **Type**: Expert perspective analysis
- **Input**: `{RUN_DIR}/phase-01/` (consolidated + raw findings)
- **Output**: `{RUN_DIR}/phase-02/` (3 files)
- **Duration**: ~15 min

### [CHECKPOINT 2]

After Phase 2 completes:
1. All 3 expert analyses are in `{RUN_DIR}/phase-02/`
2. **STOP** — present expert summaries to user
3. User reviews analyses
4. User decides: proceed to Phase 3, re-run Phase 2, or stop

### Phase 3: Synthesis + Action Plan
- **File**: `phases/03-synthesis.md`
- **Agents**: 1 general-purpose (sequential)
- **Type**: Consolidated assessment + refactoring plan
- **Input**: `{RUN_DIR}/phase-01/` + `{RUN_DIR}/phase-02/`
- **Output**: `{RUN_DIR}/phase-03/` (1 file)
- **Duration**: ~15 min

### [END]

- Final report: `{RUN_DIR}/phase-03/01-synthesis-plan.md`

---

## Run Management

### Creating a Run

```
RUN_DIR=faudit/runs/repo/$(date +%Y-%m-%d)
```

If the date directory already exists, append a variant:
```
RUN_DIR=faudit/runs/repo/$(date +%Y-%m-%d)-v2
```

### Run Manifest

At the start of each run, write `{RUN_DIR}/run-manifest.json`:
```json
{
  "pipeline": "repo",
  "version": 1,
  "started_at": "2026-02-20T16:08:00Z",
  "git_commit": "<current HEAD>",
  "git_branch": "<current branch>",
  "mode": "full|phase-1|phase-2|phase-3",
  "phase1_source": null,
  "variant": null,
  "agents": { "phase1": 5, "phase2": 3, "phase3": 1 },
  "status": "running"
}
```

Update `status` to `"completed"` and add `completed_at` when done.

### Branching (Reusing Earlier Phases)

To run Phase 2 or 3 with different parameters using existing earlier output:

```
# Original run
RUN_DIR=faudit/runs/repo/2026-02-20

# Branch: new Phase 2+3 with same Phase 1
BRANCH_DIR=faudit/runs/repo/2026-02-20-focus-quality
mkdir -p $BRANCH_DIR/phase-02
# Phase 2 reads from: faudit/runs/repo/2026-02-20/phase-01/
# Phase 2 writes to: $BRANCH_DIR/phase-02/
```

### Staleness Check

When referencing a Phase 1 from a different date, compare the `git_commit` in the source run's manifest against `HEAD`. If they differ, warn: "Phase 1 was run against commit X, current HEAD is Y. Proceed?"

### Comparing Runs

```bash
diff faudit/runs/repo/2026-02-20/phase-03/01-synthesis-plan.md \
     faudit/runs/repo/2026-02-21/phase-03/01-synthesis-plan.md
```

---

## Variable Contract

Phase files use these variables (replaced at runtime by `/audit-repo` command):

| Variable | Description | Example |
|----------|-------------|---------|
| `{RUN_DIR}` | Root of current run | `faudit/runs/repo/2026-02-20` |
| `{OUTPUT_DIR}` | Where this phase writes | `{RUN_DIR}/phase-01` |
| `{INPUT_DIR}` | Where this phase reads from | `{RUN_DIR}/phase-01` (for Phase 2) |
| `{PHASE1_DIR}` | Phase 1 output location | `{RUN_DIR}/phase-01` (for Phase 3) |
| `{PHASE2_DIR}` | Phase 2 output location | `{RUN_DIR}/phase-02` (for Phase 3) |
| `{SHARED CONTEXT BLOCK}` | Preamble injected into Phase 2/3 prompts | See phase files |

---

## Extension Points

### Adding Phase 4 (Implementation)

If needed, add `phases/04-implementation.md`:
- Reads: `{RUN_DIR}/phase-03/01-synthesis-plan.md`
- Agents: `code-implementer` type
- Action: Executes top-priority fixes from Sprint 1

### Adapting for Specific Tech Stacks

To create a specialized variant (e.g., Python monorepo, Go microservice):
1. Fork this pipeline to `pipelines/repo-python/` or similar
2. Add language-specific analysis directives to Phase 1 agent prompts
3. Add framework-specific standards to Phase 2 shared context
4. Phase 3 needs no changes (it reads generically from Phase 1+2)
