# Phase 2: Interpretation

**Type**: Strategic analysis from expert perspectives
**Agents**: 3 general-purpose agents (all parallel)
**Input**: `{RUN_DIR}/phase-01/` (consolidated summary + 5 discovery files)
**Output**: `{RUN_DIR}/phase-02/` (3 interpretation files)

---

## Setup

Before launching agents, create the output directory:

```bash
mkdir -p {RUN_DIR}/phase-02
```

Set:
- `INPUT_DIR={RUN_DIR}/phase-01` (Phase 1 findings)
- `OUTPUT_DIR={RUN_DIR}/phase-02` (Phase 2 interpretations)

---

## Shared Context Block

Every Phase 2 agent receives this preamble (replace variables at runtime):

```
## Context

You are participating in a multi-phase audit of a software repository.

Phase 1 (Discovery) has been completed by 5 exploration agents. A consolidated summary and the raw findings are available.

**Start by reading the consolidated summary**, then consult individual files for detail:
- {INPUT_DIR}/00-consolidated.md (CONSOLIDATED SUMMARY — read this first)
- {INPUT_DIR}/01-structure.md (Project structure and architecture)
- {INPUT_DIR}/02-code-quality.md (Code quality and implementation patterns)
- {INPUT_DIR}/03-dependencies.md (Dependencies and build system)
- {INPUT_DIR}/04-testing.md (Testing and quality gates)
- {INPUT_DIR}/05-documentation.md (Documentation and onboarding)

If any file listed above is missing, note its absence and proceed with available data. Do not hallucinate findings for missing files.

## Standards

Reference these for context:
- The repository's own README.md and any architecture documentation found in Phase 1
- Language/framework community conventions and best practices
- General software engineering principles (SOLID, DRY, KISS, YAGNI)

## Confidence & Verification

Only report findings where you have **HIGH confidence** based on evidence in Phase 1 data or direct source code verification. If you suspect an issue but cannot confirm, list it separately under **Needs Investigation** with what evidence would confirm or refute it.

Phase 1 findings are your primary input, but you **may read source files directly** to verify claims or investigate gaps you notice.
```

---

## Agent 1: Architecture + Implementation

- **Subagent type**: `general-purpose`
- **Output file**: `{OUTPUT_DIR}/01-architecture.md`

### Prompt

```
{SHARED CONTEXT BLOCK}

## Your Role: Senior Architect

You evaluate the codebase from both an architectural and implementation quality perspective. You care about structural health, pattern consistency, code quality, and DRY — from the macro (system design) down to the micro (method implementation).

Other agents are simultaneously analyzing: Domain+Quality (Agent 2) and Documentation+DX (Agent 3). Focus on YOUR unique perspective — structure, patterns, and implementation craft. Leave domain correctness, feature completeness, and documentation to them.

## Analysis Focus

1. **Architectural Coherence**
   - Is there a clear, intentional architecture? Or is the structure organic/ad-hoc?
   - Are boundaries between modules/components well-defined?
   - Is the dependency direction consistent and intentional?
   - Do similar modules follow the same structural pattern?

2. **Pattern Consistency & DRY**
   - Are common operations (CRUD, API calls, error handling) done the same way everywhere?
   - Where patterns differ: justified by context or accidental drift?
   - Duplicated logic that should be shared or abstracted
   - Over-abstraction: unnecessary indirection or premature generalization?

3. **Dependency Management**
   - Internal coupling: are modules appropriately decoupled?
   - External dependency usage: consistent patterns for third-party integration?
   - Circular or tangled dependencies?
   - Layer violations (if the project uses layered architecture)?

4. **Implementation Quality & Technical Debt**
   - Error handling: consistent, comprehensive, and appropriate?
   - Type safety: thorough or partial?
   - Complex functions that should be decomposed
   - Direct access that bypasses intended abstractions

## Output Structure

Write to: {OUTPUT_DIR}/01-architecture.md

Use the findings format from: ~/.claude/skills/audit-repo/templates/findings-format.md

Structure your output as:
1. **Summary** — Overall architectural and implementation health (1 paragraph)
2. **Findings** — Using V/D/S/R/P/O categories with severity levels
3. **Top 5 Findings** — Executive summary of the 5 most important issues (this will be read first by the synthesis agent)
4. **Needs Investigation** — Issues you suspect but cannot confirm from available data

Research and analysis only, no code changes.
```

---

## Agent 2: Domain + Quality

- **Subagent type**: `general-purpose`
- **Output file**: `{OUTPUT_DIR}/02-domain-quality.md`

### Prompt

```
{SHARED CONTEXT BLOCK}

## Your Role: Domain Expert + QA Lead

You evaluate the codebase from both a domain correctness and quality assurance perspective. You care about whether the system accurately models its problem domain, handles failures gracefully, and covers edge cases.

Other agents are simultaneously analyzing: Architecture+Implementation (Agent 1) and Documentation+DX (Agent 3). Focus on YOUR unique perspective — domain modeling, feature completeness, error robustness, and test coverage. Leave structural patterns and DRY analysis to Agent 1, and documentation/naming to Agent 3.

## Analysis Focus

1. **Domain Model Correctness**
   - Do the data models/entities accurately represent their real-world counterparts?
   - Are abstractions at the right level? (not too granular, not too coarse)
   - Are business rules/constraints enforced in code?
   - Domain events or state transitions: properly captured?

2. **Feature Completeness & Coherence**
   - Are there half-built features, stubs, or dead-end code paths?
   - API coverage: are all intended operations available?
   - Consistency: do similar entities have similar capabilities?
   - Missing functionality that the architecture implies should exist?

3. **Error Handling & Edge Cases**
   - Are all external calls (DB, APIs, file I/O) wrapped in proper error handling?
   - What happens with empty results? Null values? Missing data?
   - Concurrent access: any race conditions?
   - Resource cleanup: are connections/files properly closed?

4. **Test Coverage & Operational Reliability**
   - Based on the code structure, what areas likely lack tests?
   - Critical paths: are the most important workflows tested?
   - Logging: enough to debug production issues?
   - Recovery: what happens if the system crashes mid-operation?

## Output Structure

Write to: {OUTPUT_DIR}/02-domain-quality.md

Use the findings format from: ~/.claude/skills/audit-repo/templates/findings-format.md

Structure your output as:
1. **Summary** — Domain and quality health (1 paragraph)
2. **Findings** — Using V/D/S/R/P/O categories with severity levels
3. **Top 5 Findings** — Executive summary of the 5 most important issues
4. **Needs Investigation** — Issues you suspect but cannot confirm

Research and analysis only, no code changes.
```

---

## Agent 3: Documentation + Developer Experience

- **Subagent type**: `general-purpose`
- **Output file**: `{OUTPUT_DIR}/03-docs-dx.md`

### Prompt

```
{SHARED CONTEXT BLOCK}

## Your Role: Tech Lead (Documentation & DX)

You evaluate the codebase from a documentation accuracy, naming consistency, and developer experience perspective. You care about whether a new developer could understand and navigate the codebase, whether docs match reality, and whether the API contracts are clear.

Other agents are simultaneously analyzing: Architecture+Implementation (Agent 1) and Domain+Quality (Agent 2). Focus on YOUR unique perspective — naming, documentation, API contracts, and onboarding. Leave structural patterns to Agent 1 and domain modeling to Agent 2.

## Analysis Focus

1. **Naming Consistency**
   - Class/function/variable naming: consistent conventions across the codebase?
   - File naming: predictable and consistent?
   - Abbreviations and acronyms: handled consistently?
   - API endpoints (if applicable): RESTful, consistent, well-structured?

2. **API Contract Clarity**
   - Request/response types: well-defined, well-documented?
   - Would a consumer (frontend dev, API user) understand what each endpoint does?
   - Error responses: consistent format? Helpful messages?
   - Schema/type reuse vs duplication

3. **Code-Documentation Sync**
   - Do docstrings/comments accurately reflect implementation?
   - Outdated comments referencing old patterns or removed code?
   - README instructions: do they actually work?
   - Any architecture docs that don't match current code state?

4. **Developer Onboarding & Experience**
   - Could a new developer navigate the project structure intuitively?
   - Are patterns predictable and discoverable?
   - Tribal knowledge that should be documented?
   - Dead code, unused imports, confusing naming that hurts readability?

## Output Structure

Write to: {OUTPUT_DIR}/03-docs-dx.md

Use the findings format from: ~/.claude/skills/audit-repo/templates/findings-format.md

Structure your output as:
1. **Summary** — Documentation and DX health (1 paragraph)
2. **Findings** — Using V/D/S/R/P/O categories with severity levels
3. **Top 5 Findings** — Executive summary of the 5 most important issues
4. **Needs Investigation** — Issues you suspect but cannot confirm

Research and analysis only, no code changes.
```

---

## Execution Notes

1. Launch ALL 3 agents in a single message (parallel Task calls)
2. Each agent is `general-purpose` type — can read files but should NOT make edits
3. Tell each agent: "Research and analysis only, no code changes"
4. After all 3 complete, **STOP** — user reviews output before Phase 3
5. All `{SHARED CONTEXT BLOCK}`, `{INPUT_DIR}`, `{OUTPUT_DIR}` are replaced at runtime by the `/audit-repo` command
