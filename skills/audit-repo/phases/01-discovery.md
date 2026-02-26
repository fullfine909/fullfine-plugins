# Phase 1: Discovery

**Type**: Read-only structural inventory and codebase profiling
**Agents**: 5 Explore agents (all parallel)
**Output**: `{RUN_DIR}/phase-01/` (5 markdown files + consolidated summary)

---

## Setup

Before launching agents, create the output directory:

```bash
mkdir -p {RUN_DIR}/phase-01
```

Set: `OUTPUT_DIR={RUN_DIR}/phase-01`

---

## Agent 1: Project Structure & Architecture

- **Subagent type**: `Explore`
- **Thoroughness**: `very thorough`
- **Output file**: `{OUTPUT_DIR}/01-structure.md`

### Prompt

```
You are an exploration agent performing Phase 1 of a repository audit. Your job is to produce a thorough STRUCTURAL INVENTORY of this repository's architecture and project organization.

## Scope

Analyze the ENTIRE repository. Start from the root and work inward.

## What to Inventory

**1. Project Identity**:
- Language(s) used (primary and secondary)
- Framework(s) and their versions
- Package manager(s) and dependency files
- Project type: monorepo, single app, library, microservice, CLI tool, etc.

**2. Directory Structure**:
- Top-level directory layout with purpose of each directory
- Nesting depth and organization pattern
- Source code location(s) vs config/scripts/docs

**3. Architectural Pattern**:
- Identify the architecture: MVC, hexagonal, layered, modular, flat, etc.
- Are there explicit layers or boundaries? How are they enforced?
- Module/package organization: by feature, by type, by layer?

**4. Entry Points & Routing**:
- Main entry point(s): where does execution start?
- API routes/endpoints (if applicable)
- CLI commands (if applicable)
- Background workers/jobs (if applicable)

**5. Key Modules/Components**:
- List the major modules/packages/directories
- For each: purpose, approximate size (files/lines), key classes/functions
- Dependencies between modules (who imports whom)

**6. Configuration & Environment**:
- Config files: what exists, what format, how loaded
- Environment variables: how managed (.env, config objects, etc.)
- Secrets management approach

**Anything Unexpected**:
- Files or directories that don't fit the apparent pattern
- Unusual naming conventions or organizational choices
- Circular dependencies or tangled imports you notice

## Output Format

Use the findings format from: ~/.claude/skills/audit-repo/templates/findings-format.md

Title: "Project Structure & Architecture — Repository Overview"

Include at least 5 PASS findings for patterns that are well-organized.

Research and analysis only, no code changes.
```

---

## Agent 2: Code Quality & Patterns

- **Subagent type**: `Explore`
- **Thoroughness**: `very thorough`
- **Output file**: `{OUTPUT_DIR}/02-code-quality.md`

### Prompt

```
You are an exploration agent performing Phase 1 of a repository audit. Your job is to produce a thorough STRUCTURAL INVENTORY of this repository's code quality and implementation patterns.

## Scope

Sample source code broadly across the repository. Prioritize core business logic over configuration or generated files.

## What to Inventory

**1. Naming Conventions**:
- Class, function, variable naming patterns
- File naming conventions
- Consistency across different parts of the codebase
- Acronym handling, abbreviation patterns

**2. Code Style & Formatting**:
- Formatting tool configuration (if any: prettier, black, gofmt, etc.)
- Import organization pattern
- Consistency of style across modules
- Line length, indentation, quote style

**3. Error Handling Patterns**:
- How are errors created, raised, and caught?
- Consistent error types/classes or ad-hoc?
- Error propagation: do errors bubble up with context?
- Missing error handling in critical paths

**4. Type Safety**:
- Type annotations/hints: present? comprehensive? accurate?
- Runtime validation (Zod, Pydantic, joi, etc.)
- Null/undefined handling patterns
- Generic types usage

**5. Code Organization Patterns**:
- How is similar functionality grouped?
- DRY adherence: duplicated logic across modules?
- Abstraction level: over-engineered or under-abstracted?
- Function/method complexity: any overly long or complex functions?

**6. Logging & Observability**:
- Logging framework and usage patterns
- Structured vs unstructured logging
- Log levels used appropriately?
- Metrics, tracing, or monitoring integration

**Anything Unexpected**:
- Dead code, unreachable branches, unused imports
- Inconsistent patterns between modules that should match
- Code that contradicts the apparent architecture

## Output Format

Use the findings format from: ~/.claude/skills/audit-repo/templates/findings-format.md

Title: "Code Quality & Patterns — Implementation Review"

Include at least 5 PASS findings for good patterns worth preserving.

Research and analysis only, no code changes.
```

---

## Agent 3: Dependencies & Build System

- **Subagent type**: `Explore`
- **Thoroughness**: `very thorough`
- **Output file**: `{OUTPUT_DIR}/03-dependencies.md`

### Prompt

```
You are an exploration agent performing Phase 1 of a repository audit. Your job is to produce a thorough STRUCTURAL INVENTORY of this repository's dependencies, build system, and infrastructure configuration.

## Scope

Analyze all dependency files, build configs, CI/CD pipelines, and deployment configuration.

## What to Inventory

**1. Dependency Management**:
- Package manager(s): npm, pip, cargo, go mod, etc.
- Lock file presence and freshness
- Dependency count: direct vs transitive
- Version pinning strategy: exact, range, floating
- Dependency groups: dev, prod, optional, peer

**2. Dependency Health**:
- Any obviously outdated major versions?
- Deprecated packages still in use?
- Duplicate packages serving the same purpose?
- Heavy dependencies that could be replaced with lighter alternatives?

**3. Build System**:
- Build tool(s): Make, just, npm scripts, gradle, etc.
- Build steps and their purpose
- Development vs production build differences
- Build artifacts: what gets produced, where it goes

**4. CI/CD Pipeline**:
- CI platform: GitHub Actions, GitLab CI, Jenkins, etc.
- Pipeline stages and what they check
- Quality gates: what blocks a merge?
- Deployment process: manual, automatic, staged?

**5. Containerization & Deployment**:
- Docker: Dockerfile quality, multi-stage builds, image size
- Docker Compose or orchestration configs
- Cloud platform configs (AWS, GCP, Vercel, Render, etc.)
- Infrastructure as Code (Terraform, Pulumi, etc.)

**6. Environment & Configuration**:
- Environment variable management
- Secret handling (vault, env files, CI secrets)
- Multi-environment support (dev, staging, prod)
- Configuration loading pattern

**Anything Unexpected**:
- Security concerns in dependency chain
- Orphaned config files for tools no longer used
- Inconsistencies between CI config and local dev setup

## Output Format

Use the findings format from: ~/.claude/skills/audit-repo/templates/findings-format.md

Title: "Dependencies & Build System — Infrastructure Review"

Include at least 5 PASS findings for well-configured infrastructure.

Research and analysis only, no code changes.
```

---

## Agent 4: Testing & Quality Gates

- **Subagent type**: `Explore`
- **Thoroughness**: `very thorough`
- **Output file**: `{OUTPUT_DIR}/04-testing.md`

### Prompt

```
You are an exploration agent performing Phase 1 of a repository audit. Your job is to produce a thorough STRUCTURAL INVENTORY of this repository's testing infrastructure, test quality, and quality gates.

## Scope

Analyze test directories, test configuration, CI quality checks, and linting/formatting setup.

## What to Inventory

**1. Test Framework & Configuration**:
- Test framework(s) used (pytest, jest, vitest, go test, etc.)
- Configuration files and settings
- Test runner scripts or commands
- Parallel test execution support

**2. Test Organization**:
- Test directory structure: alongside source or separate?
- Naming conventions for test files and functions
- Test categorization: unit, integration, e2e, API
- Fixture/helper/mock organization

**3. Test Coverage Assessment**:
- Coverage tool configuration (if any)
- Coverage targets/thresholds (if configured)
- Approximate test-to-source ratio
- Areas with good coverage vs obvious gaps
- Critical paths: are the most important code paths tested?

**4. Test Quality Patterns**:
- Test isolation: do tests depend on each other or shared state?
- Assertion quality: specific assertions or vague checks?
- Test data management: fixtures, factories, builders?
- Mocking strategy: what gets mocked, what doesn't?

**5. Quality Gate Tools**:
- Linter configuration and rules
- Formatter configuration
- Type checker (if applicable)
- Static analysis tools
- Pre-commit hooks

**6. CI Quality Checks**:
- What checks run on every PR/commit?
- What checks are enforced (blocking) vs advisory?
- Test execution in CI: full suite or subset?
- Quality reporting: coverage reports, lint results

**Anything Unexpected**:
- Tests that are skipped or disabled
- Flaky test indicators
- Quality tools configured but not enforced
- Tests that test implementation details rather than behavior

## Output Format

Use the findings format from: ~/.claude/skills/audit-repo/templates/findings-format.md

Title: "Testing & Quality Gates — Quality Infrastructure Review"

Include at least 5 PASS findings for effective testing practices.

Research and analysis only, no code changes.
```

---

## Agent 5: Documentation & Onboarding

- **Subagent type**: `Explore`
- **Thoroughness**: `very thorough`
- **Output file**: `{OUTPUT_DIR}/05-documentation.md`

### Prompt

```
You are an exploration agent performing Phase 1 of a repository audit. Your job is to produce a thorough STRUCTURAL INVENTORY of this repository's documentation quality and developer experience.

## Scope

Analyze all documentation: README, docs directories, code comments, API docs, and developer guides. Evaluate from the perspective of a new developer joining the project.

## What to Inventory

**1. README Quality**:
- Does it exist? Is it comprehensive or minimal?
- Project description: clear purpose statement?
- Setup instructions: can someone get running from scratch?
- Architecture overview: high-level understanding?
- Contributing guidelines: how to contribute?

**2. Documentation Structure**:
- Docs directory: organized? up to date?
- API documentation: OpenAPI/Swagger, JSDoc, docstrings?
- Architecture Decision Records (ADRs)?
- Changelog or release notes?
- Diagrams: architecture, data flow, sequence?

**3. Code-Level Documentation**:
- Docstrings/comments: present on public interfaces?
- Type annotations as documentation
- Inline comments: helpful or noise?
- Module/package-level documentation

**4. Documentation-Code Sync**:
- Do documented patterns match actual implementation?
- Are documented APIs/endpoints current?
- Outdated references to removed features?
- Examples that still work?

**5. Developer Experience**:
- How many steps from clone to running?
- Are common tasks documented (build, test, deploy, debug)?
- Error messages: helpful or cryptic?
- Development tooling: editor configs, debug configs?

**6. Onboarding Assessment**:
- Could a new developer understand the project structure in < 1 hour?
- Is the "happy path" for common development tasks clear?
- Are non-obvious decisions explained (why, not just what)?
- Tribal knowledge: things you need to know that aren't written down?

**Anything Unexpected**:
- Documentation that contradicts code
- Stale TODO/FIXME/HACK comments
- Generated documentation that's checked in but not maintained
- Missing license or legal files

## Output Format

Use the findings format from: ~/.claude/skills/audit-repo/templates/findings-format.md

Title: "Documentation & Onboarding — Developer Experience Review"

Include at least 5 PASS findings for good documentation practices.

Research and analysis only, no code changes.
```

---

## Execution Notes

1. Launch ALL 5 agents in a **single message** (parallel Task calls)
2. Each agent is `Explore` type with thoroughness `very thorough`
3. Each writes to `{OUTPUT_DIR}/{NN-name}.md`
4. After all 5 complete, **verify** all expected files exist
5. **Produce `00-consolidated.md`**: Read all 5 files, then:
   - Deduplicate findings that appear in multiple agents
   - Aggregate metrics (total files, violations, drift, stale, risks)
   - Produce summary table:

```markdown
# Phase 1 Consolidated Summary

## Metrics

| File | V | D | S | R | P | O | Crit | High |
|------|---|---|---|---|---|---|------|------|
| 01-structure.md    | N | N | N | N | N | N | N | N |
| 02-code-quality.md | N | N | N | N | N | N | N | N |
| 03-dependencies.md | N | N | N | N | N | N | N | N |
| 04-testing.md      | N | N | N | N | N | N | N | N |
| 05-documentation.md| N | N | N | N | N | N | N | N |
| **TOTAL**          | N | N | N | N | N | N | N | N |

## Key Findings (deduplicated)

### Critical + High Severity
{list}

### Cross-Cutting Themes
{themes that appear in 2+ agents}

## Repository Profile

- **Language(s)**: {from Agent 1}
- **Framework(s)**: {from Agent 1}
- **Architecture**: {from Agent 1}
- **Test framework**: {from Agent 4}
- **Build system**: {from Agent 3}
- **CI/CD**: {from Agent 3}
```
