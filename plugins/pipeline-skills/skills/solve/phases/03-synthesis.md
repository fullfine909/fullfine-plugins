# Phase 3: Synthesis (Optional)

**Type**: Final implementation plan consolidation and validation
**Agents**: 1 (synthesizer)
**Input**: `{RUN_DIR}/phase-01/` + `{RUN_DIR}/phase-02/` (all prior outputs)
**Output**: `{RUN_DIR}/phase-03/` (1 comprehensive report)

---

## Setup

Create output directory: `mkdir -p {RUN_DIR}/phase-03`

Set:
- `PHASE1_DIR={RUN_DIR}/phase-01`
- `PHASE2_DIR={RUN_DIR}/phase-02`
- `OUTPUT_DIR={RUN_DIR}/phase-03`

---

## Agent 1: Synthesizer

- **Subagent type**: `synthesizer`
- **Output file**: `{OUTPUT_DIR}/01-implementation-plan.md`

### Prompt

```
## Context

You are the final agent in a multi-phase solution planning pipeline.

**Request**: {REQUEST}

Phase 1 (Discovery) explored the codebase with 3 agents. Phase 2 (Solution Design) produced an implementation plan and a risk analysis. Your job: synthesize everything into a definitive, ready-to-execute implementation plan.

## Input Files

**Phase 1 -- Discovery**:
- {PHASE1_DIR}/00-consolidated.md (summary)
- {PHASE1_DIR}/01-code-structure.md (relevant code and architecture)
- {PHASE1_DIR}/02-patterns.md (patterns and conventions)
- {PHASE1_DIR}/03-dependencies.md (dependencies and constraints)

**Phase 2 -- Solution Design**:
- {PHASE2_DIR}/01-solution-plan.md (implementation approach)
- {PHASE2_DIR}/02-risk-analysis.md (risk and testing analysis)

If any input file is missing, note its absence and work with available data.

## What to Produce

1. **Validate the Plan** -- Does the Phase 2 plan actually work? Cross-check against Phase 1 constraints. Read source files to verify.
2. **Integrate Risk Mitigation** -- Weave the risk analysis mitigations into the task list.
3. **Refine Task Ordering** -- Optimize the sequence: dependencies first, parallel opportunities identified.
4. **Add Implementation Detail** -- For each task, add enough detail that an engineer (or Claude Code) could execute it without re-reading the entire codebase.

## Output

Write to: {OUTPUT_DIR}/01-implementation-plan.md

```markdown
# Implementation Plan: {REQUEST}

**Date**: {date}
**Pipeline**: solve
**Phases completed**: 3

## Executive Summary
{3-5 sentences: what we're doing, why this approach, biggest risk, estimated effort}

## Approach
{High-level strategy, 1-2 paragraphs}

## Task List

### Phase A: Foundation
{Tasks that must come first -- dependencies, setup, infrastructure}

For each task:
- **Task**: {title}
- **Files**: {files to create/modify/delete}
- **Changes**: {specific description of what to change}
- **Depends on**: {other task titles or "none"}
- **Effort**: {XS/S/M/L/XL}
- **Acceptance criteria**: {how to verify it's done}
- **Risk**: {what could go wrong, from risk analysis}

### Phase B: Core Changes
{The main implementation work}

### Phase C: Verification & Cleanup
{Tests, documentation, cleanup}

## Dependency Graph
{ASCII representation of task dependencies}

## Parallel Opportunities
{Tasks that can be done simultaneously}

## Risks & Mitigations
{Integrated from Phase 2 risk analysis, mapped to specific tasks}

## Testing Plan
{What to test, how to test, minimum coverage for confidence}

## Verification Checklist
- [ ] All existing tests still pass
- [ ] New tests cover the changes
- [ ] No regressions in adjacent functionality
- [ ] {Request-specific verification items}
```

Research and analysis only, no code changes.
```

---

## Execution Notes

1. Launch 1 agent (sequential -- needs all Phase 1 + Phase 2 outputs)
2. Agent uses shared `synthesizer` definition (registered by plugin)
3. After completion, the pipeline run is done
4. Update `agents.phase3` to 1 in run-manifest.json
