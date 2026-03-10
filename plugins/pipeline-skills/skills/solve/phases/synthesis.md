# Phase 3: Synthesis (Optional)

Only reached if user says "continue" after Phase 2.

## Preparation

Before spawning the agent, read this template file and substitute its full content into the agent prompt below. Subagents cannot access skill directory paths — the content must be inlined directly into the prompt.

| Placeholder | Template File |
|-------------|---------------|
| `{TEMPLATE:implementation-plan}` | `templates/implementation-plan.md` (in this skill directory) |

---

Launch **1 synthesizer agent**. Wait for completion. Update `agents.phase3` to 1 in `run-manifest.json`.

---

## Agent 1: Synthesizer

- **Subagent type**: `pipeline-skills:synthesizer`
- **Output file**: `{OUTPUT_DIR}/01-implementation-plan.md`

**Prompt**:

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

Use this output format:

{TEMPLATE:implementation-plan}

---

Research and analysis only, no code changes.
```
