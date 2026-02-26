# Phase 2: Solution Design

**Type**: Implementation planning based on discovery findings
**Agents**: 2 (solution-architect, risk-analyst) -- parallel
**Input**: `{RUN_DIR}/phase-01/` (consolidated + 3 discovery files)
**Output**: `{RUN_DIR}/phase-02/`

---

## Setup

Create output directory: `mkdir -p {RUN_DIR}/phase-02`

Set:
- `INPUT_DIR={RUN_DIR}/phase-01`
- `OUTPUT_DIR={RUN_DIR}/phase-02`

---

## Shared Context Block

Every Phase 2 agent receives this preamble (replace variables at runtime):

```
## Context

You are designing a solution for a software engineering request.

**Request**: {REQUEST}

Phase 1 (Discovery) has been completed by 3 exploration agents. A consolidated summary and the raw findings are available.

**Start by reading the consolidated summary**, then consult individual discovery files for detail:
- {INPUT_DIR}/00-consolidated.md (SUMMARY -- read this first)
- {INPUT_DIR}/01-code-structure.md (Relevant code and architecture)
- {INPUT_DIR}/02-patterns.md (Patterns and conventions)
- {INPUT_DIR}/03-dependencies.md (Dependencies and constraints)

If any file is missing, note its absence and proceed with available data.

You may also read source code files directly to verify details or investigate things the discovery agents missed.

## Important

- Your plan must respect constraints identified in Phase 1
- Reference specific files and functions by path
- Every proposed change must have a clear rationale
- Do NOT propose changes outside the scope of the original request
```

---

## Agent 1: Solution Architect

- **Subagent type**: `solution-architect`
- **Output file**: `{OUTPUT_DIR}/01-solution-plan.md`

### Prompt

```
{SHARED CONTEXT BLOCK}

## Your Task

Design a concrete implementation plan that solves the user's request.

## Process

1. **Understand the Goal** -- Re-read the request. What exactly needs to change?
2. **Review Findings** -- Read all Phase 1 output. What did we learn?
3. **Design Approach** -- Choose an implementation strategy. Explain WHY this approach over alternatives.
4. **Plan Tasks** -- Break down into ordered, atomic tasks.
5. **Verify Feasibility** -- Read the actual source files to confirm your plan is realistic.

## Output

Write to: {OUTPUT_DIR}/01-solution-plan.md
Use the format from: ~/.claude/skills/solve/templates/solution-format.md

Research and analysis only, no code changes.
```

---

## Agent 2: Risk Analyst

- **Subagent type**: `risk-analyst`
- **Output file**: `{OUTPUT_DIR}/02-risk-analysis.md`

### Prompt

```
{SHARED CONTEXT BLOCK}

## Your Task

Analyze the risks and testing implications of making changes to solve the user's request. A solution architect (Agent 1) is simultaneously producing an implementation plan. Your analysis is independent.

## Analysis Focus

1. **What Could Break** -- Given the areas touched in Phase 1 findings, what existing functionality is at risk? What tests exist? What's untested?
2. **Edge Cases** -- What inputs, states, or conditions might the solution need to handle that aren't obvious?
3. **Migration/Compatibility** -- If the change affects APIs, data formats, or behavior: what are the migration concerns?
4. **Testing Strategy** -- What tests should be written or updated? What's the minimum coverage for confidence?
5. **Rollback Plan** -- If the change goes wrong, how to revert safely?

## Output

Write to: {OUTPUT_DIR}/02-risk-analysis.md

```markdown
# Risk & Testing Analysis

## Request
{REQUEST}

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|

## What Could Break
{Detailed analysis of existing functionality at risk}

## Edge Cases
{Non-obvious conditions the solution must handle}

## Migration Concerns
{If applicable: API changes, data migration, backward compatibility}

## Testing Strategy

### Existing Tests to Update
{List with file paths}

### New Tests Needed
{List with descriptions}

### Verification Steps
{How to confirm the solution works end-to-end}

## Rollback Plan
{Steps to safely revert if needed}
```

Research and analysis only, no code changes.
```

---

## Execution Notes

1. Launch BOTH agents in a **single message** (parallel Task calls)
2. Each agent uses its shared definition from `~/.claude/agents/` as base instructions
3. After both complete, **verify** both output files exist
4. **STOP** for user review before Phase 3
