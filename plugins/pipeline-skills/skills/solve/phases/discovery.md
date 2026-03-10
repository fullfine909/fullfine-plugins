# Phase 1: Discovery

## Preparation

Before spawning agents, read these template files and substitute their full content into the agent prompts below. Subagents cannot access skill directory paths — the content must be inlined directly into each prompt.

| Placeholder | Template File |
|-------------|---------------|
| `{TEMPLATE:discovery-output}` | `templates/discovery-output.md` (in this skill directory) |
| `{TEMPLATE:consolidation}` | `templates/consolidation.md` (in this skill directory) |

---

Launch **3 agents in parallel** (single message, multiple Agent calls). Wait for all 3 to complete.

After all finish: verify all 3 output files exist, then produce `{OUTPUT_DIR}/00-consolidated.md`.

---

## Agent 1: Code Explorer

- **Subagent type**: `pipeline-skills:code-explorer`
- **Output file**: `{OUTPUT_DIR}/01-code-structure.md`

**Prompt**:

```
The user wants to: {REQUEST}

Explore this codebase to find all code relevant to the above request.

## What to Investigate

- Code directly related to the request: files, functions, classes
- Architecture around the affected area: how modules connect
- Entry points and code paths that touch the relevant functionality
- Configuration and initialization related to the area

## Scope

Start from the project root. Read README.md and top-level structure first, then drill into areas relevant to the request. Ignore code that has no bearing on the goal.

## Output

Write your findings to: {OUTPUT_DIR}/01-code-structure.md

Use this output format:

{TEMPLATE:discovery-output}

Set these template values:
- AGENT_AREA: "Code Structure"
- N: 1
- area_description: "Code structure and architecture"

---

Research and analysis only, no code changes.
```

---

## Agent 2: Pattern Analyzer

- **Subagent type**: `pipeline-skills:pattern-analyzer`
- **Output file**: `{OUTPUT_DIR}/02-patterns.md`

**Prompt**:

```
The user wants to: {REQUEST}

Analyze the patterns and conventions in this codebase that are relevant to the above request.

## What to Investigate

- How does the codebase handle similar functionality to what's being requested?
- What patterns and abstractions exist that the solution should follow?
- Naming conventions, code style, and structural patterns in the affected areas
- Existing utilities, helpers, or base classes that could be reused
- Anti-patterns or inconsistencies in the relevant areas

## Scope

Focus on patterns in the areas of the codebase that would be touched by the request. Compare across modules to identify the established way of doing things.

## Output

Write your findings to: {OUTPUT_DIR}/02-patterns.md

Use this output format:

{TEMPLATE:discovery-output}

Set these template values:
- AGENT_AREA: "Patterns & Conventions"
- N: 2
- area_description: "Patterns, conventions, and reusable abstractions"

---

Research and analysis only, no code changes.
```

---

## Agent 3: Dependency Mapper

- **Subagent type**: `pipeline-skills:dependency-mapper`
- **Output file**: `{OUTPUT_DIR}/03-dependencies.md`

**Prompt**:

```
The user wants to: {REQUEST}

Map the dependencies and constraints that are relevant to the above request.

## What to Investigate

- What does the affected code depend on? (imports, packages, services)
- What depends on the affected code? (downstream consumers, tests, APIs)
- External integrations that would be impacted (databases, APIs, config)
- Tests that verify the current behavior (what must keep passing)
- Type contracts, API schemas, or interfaces that constrain changes
- Environment or configuration dependencies

## Scope

Start from the code areas relevant to the request and trace dependencies outward. Focus on hard constraints (things that break if violated) over soft ones.

## Output

Write your findings to: {OUTPUT_DIR}/03-dependencies.md

Use this output format:

{TEMPLATE:discovery-output}

Set these template values:
- AGENT_AREA: "Dependencies & Constraints"
- N: 3
- area_description: "Dependencies, constraints, and integration points"

---

Research and analysis only, no code changes.
```

---

## Consolidation

After all 3 agents finish, read all 3 discovery files and produce `{OUTPUT_DIR}/00-consolidated.md`.

Use this format:

{TEMPLATE:consolidation}

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
