# Phase 2: Solution Design

## Preparation

Before spawning agents, read these template files and substitute their full content into the agent prompts below. Subagents cannot access skill directory paths — the content must be inlined directly into each prompt.

| Placeholder | Template File |
|-------------|---------------|
| `{TEMPLATE:solution-plan}` | `templates/solution-plan.md` (in this skill directory) |
| `{TEMPLATE:risk-analysis}` | `templates/risk-analysis.md` (in this skill directory) |

Also, replace every `{SHARED CONTEXT BLOCK}` in the agent prompts below with the full preamble defined in the "Shared Context Block" section.

---

Launch **2 agents in parallel**. Wait for both to complete. Verify both output files exist.

---

## Shared Context Block

Every Phase 2 agent receives this preamble. Replace `{SHARED CONTEXT BLOCK}` in each agent prompt with this content:

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

- **Subagent type**: `pipeline-skills:solution-architect`
- **Output file**: `{OUTPUT_DIR}/01-solution-plan.md`

**Prompt**:

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

Use this output format:

{TEMPLATE:solution-plan}

---

Research and analysis only, no code changes.
```

---

## Agent 2: Risk Analyst

- **Subagent type**: `pipeline-skills:risk-analyst`
- **Output file**: `{OUTPUT_DIR}/02-risk-analysis.md`

**Prompt**:

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

Use this output format:

{TEMPLATE:risk-analysis}

---

Research and analysis only, no code changes.
```

---

## After Phase 2

Read the executive summary and task list from `01-solution-plan.md`. Report to user:

```
Phase 2 complete. Solution plan and risk analysis written to: {RUN_DIR}/phase-02/

{Display the Executive Summary section from 01-solution-plan.md}

{Display the Task List section from 01-solution-plan.md}

This is a usable plan. Say "continue" for Phase 3 (deeper synthesis and validation),
or "done" to finish here.
```

**STOP and wait for user instruction.**
