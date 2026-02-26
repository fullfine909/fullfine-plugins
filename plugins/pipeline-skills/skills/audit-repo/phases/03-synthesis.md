# Phase 3: Synthesis + Action Plan

**Type**: Consolidated analysis and concrete refactoring plan
**Agents**: 1 general-purpose agent
**Input**: `{RUN_DIR}/phase-01/` + `{RUN_DIR}/phase-02/` (all prior outputs)
**Output**: `{RUN_DIR}/phase-03/` (1 comprehensive report)

---

## Setup

Before launching, create the output directory:

```bash
mkdir -p {RUN_DIR}/phase-03
```

Set:
- `PHASE1_DIR={RUN_DIR}/phase-01` (Discovery findings)
- `PHASE2_DIR={RUN_DIR}/phase-02` (Interpretation analyses)
- `OUTPUT_DIR={RUN_DIR}/phase-03`

---

## Agent 1: Synthesis + Action Planner

- **Subagent type**: `general-purpose`
- **Output file**: `{OUTPUT_DIR}/01-synthesis-plan.md`

### Prompt

```
## Context

You are the final agent in a 3-phase audit of a software repository.

Phase 1 (Discovery) produced structural inventories. Phase 2 (Interpretation) produced expert analyses from 3 perspectives. Your job is to synthesize ALL findings into a definitive assessment and produce a concrete, ordered refactoring plan.

## Input Files

**Phase 1 — Discovery** (read the consolidated summary first, then individual files as needed):
- {PHASE1_DIR}/00-consolidated.md (CONSOLIDATED SUMMARY)
- {PHASE1_DIR}/01-structure.md
- {PHASE1_DIR}/02-code-quality.md
- {PHASE1_DIR}/03-dependencies.md
- {PHASE1_DIR}/04-testing.md
- {PHASE1_DIR}/05-documentation.md

**Phase 2 — Interpretation** (read the Top 5 from each first, then full analysis as needed):
- {PHASE2_DIR}/01-architecture.md (Architecture + Implementation analysis)
- {PHASE2_DIR}/02-domain-quality.md (Domain + Quality analysis)
- {PHASE2_DIR}/03-docs-dx.md (Documentation + DX analysis)

If any input file is missing, note its absence and work with available data.

## Part 1: Synthesis

### Cross-Reference Findings
- Where do multiple experts agree? (high-confidence issues)
- Where do experts disagree? (resolve with Phase 1 evidence)
- What did everyone miss? (gaps in coverage)

### Module/Component Comparison
- Identify the major modules/components from Phase 1
- Where are they consistent, where do they diverge?
- Justified differences (domain-driven) vs accidental drift

### Issue Inventory
- Deduplicated master list of all issues across all phases
- Each issue: ID, description, source(s), severity, affected files
- Group by category: Architecture, Implementation, Domain, Quality, Documentation
- Use globally unique IDs: ARCH-001, IMPL-001, DOM-001, QUAL-001, DOC-001

### Risk Assessment
- Top 5 risks with likelihood and impact
- What breaks if we don't fix it?

### What's Working Well
- Patterns to preserve and replicate
- Strengths to build on

## Part 2: Action Plan

Transform the analysis into a concrete, ordered refactoring plan. Answer: "What do we do, in what order, and why that order?"

### Dependency Analysis
- Which fixes depend on other fixes?
- Which are independent and parallelizable?
- Cascading effects?

### Effort Estimation
For each issue from the master list:
- XS (< 30 min): trivial rename, delete dead code
- S (30 min - 2 hours): single-file refactor, add validation
- M (2-4 hours): multi-file refactor, component extraction
- L (4-8 hours): architectural change, new pattern
- XL (> 8 hours): cross-module restructuring

### Sprint Planning

**Sprint 1: Critical & Foundational** (This Week)
Fixes that are blocking or that other fixes depend on.

**Sprint 2: Consistency & Alignment** (Next Week)
Cross-module standardization, DRY consolidation, pattern alignment.

**Sprint 3: Enhancement & Polish** (Following Week)
Quality improvements, documentation, nice-to-haves.

For each task:
- **Task**: {title}
- **Why now**: {dependency/risk reason}
- **Effort**: {XS/S/M/L/XL}
- **Files**: {list of files to modify}
- **Depends on**: {other task IDs or "none"}
- **Acceptance criteria**: {how to verify it's done}

### Dependency Graph
ASCII representation of task dependencies.

### Parallel Work Opportunities
Tasks that can be done simultaneously.

## Output Structure

Write to: {OUTPUT_DIR}/01-synthesis-plan.md

```markdown
# Audit Synthesis & Action Plan

**Date**: {run date}
**Scope**: Full repository audit

---

## Executive Summary
3-5 sentences: overall health, biggest risk, key insight, recommended first action.

## Repository Health

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Architecture | | |
| Code Quality | | |
| Pattern Consistency | | |
| Error Handling | | |
| Test Coverage | | |
| Dependencies | | |
| Documentation | | |
| Developer Experience | | |

Use: Good / Acceptable / Needs Work / Poor

## Master Issue List

| ID | Category | Severity | Description | Source(s) | Files |
|----|----------|----------|-------------|-----------|-------|

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|

## What's Working Well

{Patterns to preserve}

## Action Plan

### Sprint 1: Critical & Foundational
{tasks}

### Sprint 2: Consistency & Alignment
{tasks}

### Sprint 3: Enhancement & Polish
{tasks}

### Dependency Graph
{ASCII graph}

## Verification Checklist
After all sprints:
- [ ] All quality tools pass (linter, formatter, type checker)
- [ ] All tests pass
- [ ] No import errors or circular dependencies
- [ ] Documentation updated to match changes
- [ ] README setup instructions still work
```

Research and analysis only, no code changes.
```

---

## Execution Notes

1. Launch 1 agent (sequential — needs all Phase 1 + Phase 2 outputs)
2. Agent is `general-purpose` type — can read files but should NOT make edits
3. After completion, the audit run is done
4. Present the synthesis+plan as the final deliverable
