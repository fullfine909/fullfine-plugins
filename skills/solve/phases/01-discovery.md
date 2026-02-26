# Phase 1: Discovery

**Type**: Goal-directed codebase exploration
**Agents**: 3 (code-explorer, pattern-analyzer, dependency-mapper) -- all parallel
**Output**: `{RUN_DIR}/phase-01/` (3 discovery files + consolidated summary)

---

## Setup

Create the output directory:

```bash
mkdir -p {RUN_DIR}/phase-01
```

Set: `OUTPUT_DIR={RUN_DIR}/phase-01`

---

## Agent 1: Code Explorer

- **Subagent type**: `code-explorer`
- **Output file**: `{OUTPUT_DIR}/01-code-structure.md`

### Prompt

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
Use the format from: ~/.claude/skills/solve/templates/discovery-format.md

Research and analysis only, no code changes.
```

---

## Agent 2: Pattern Analyzer

- **Subagent type**: `pattern-analyzer`
- **Output file**: `{OUTPUT_DIR}/02-patterns.md`

### Prompt

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
Use the format from: ~/.claude/skills/solve/templates/discovery-format.md

Research and analysis only, no code changes.
```

---

## Agent 3: Dependency Mapper

- **Subagent type**: `dependency-mapper`
- **Output file**: `{OUTPUT_DIR}/03-dependencies.md`

### Prompt

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
Use the format from: ~/.claude/skills/solve/templates/discovery-format.md

Research and analysis only, no code changes.
```

---

## Execution Notes

1. Launch ALL 3 agents in a **single message** (parallel Task calls)
2. Each agent uses its shared definition from `~/.claude/agents/` as base instructions
3. Each writes to `{OUTPUT_DIR}/{NN-name}.md`
4. After all 3 complete, **verify** all expected files exist
5. **Produce `00-consolidated.md`** (format below)

---

## Consolidation Format

After all agents finish, read all 3 discovery files and produce `{OUTPUT_DIR}/00-consolidated.md`:

```markdown
# Phase 1: Discovery Summary

## Request
{REQUEST}

## Agent Findings

| # | Agent | File | Key Findings |
|---|-------|------|-------------|
| 1 | code-explorer | 01-code-structure.md | {1-2 sentence summary} |
| 2 | pattern-analyzer | 02-patterns.md | {1-2 sentence summary} |
| 3 | dependency-mapper | 03-dependencies.md | {1-2 sentence summary} |

## Cross-Agent Connections
{Things that multiple agents found or that create dependencies between areas}

## Constraints Identified
{Hard constraints any solution must respect: existing tests, API contracts,
type signatures, conventions, etc.}

## Preliminary Assessment
{1 paragraph: Is this request straightforward or complex? What's the main
challenge? What approach looks most promising based on discovery?}
```
