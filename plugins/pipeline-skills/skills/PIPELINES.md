# Agent Pipeline System

Composable multi-phase agent pipelines for deep codebase analysis. Pipelines are markdown-driven — no framework code, Claude Code **is** the runtime.

## How It Works

A pipeline is a set of markdown files that tell Claude what agents to spawn, in what order, with what prompts. When you invoke `/your-command`, Claude reads the entry point `.md` and follows it step-by-step as an orchestrator.

```
User types /command
       │
       ▼
Claude reads entry point .md (the "main()")
       │
       ▼
Step 0: Parse args, create run dir, write manifest
       │
       ▼
Step 1: Read phase-01 definition → launch N agents in parallel via Task tool
       │                            agents write findings to files
       ▼
       ██ CHECKPOINT ██ → Claude stops, shows summary, waits for "continue"
       │
       ▼
Step 2: Read phase-02 definition → launch N agents (read phase-01 output as input)
       │
       ▼
       ██ CHECKPOINT ██
       │
       ▼
Step N: Final phase → synthesis agent reads all prior output
       │
       ▼
Finalize: Update manifest, display results
```

There is no code execution. Claude reads markdown instructions, calls the `Task` tool to spawn agents, manages file I/O, and follows checkpoint instructions literally.

## File Roles

### Entry Point (skill or command `.md`)

The orchestrator script. Claude follows this step-by-step. Handles:
- Argument parsing (mode, date, variant)
- Run directory creation and auto-increment
- Manifest writing (`run-manifest.json`)
- Phase execution: reads phase files, substitutes variables, launches agents
- Consolidation between phases (aggregating agent outputs)
- Checkpoint stops (presenting summaries, waiting for user)
- Final report

**Location**:
- Plugin skill: `plugins/<plugin>/skills/{name}/SKILL.md` (available when plugin is enabled)
- Project command: `.claude/commands/{name}.md` (project-specific)

### Pipeline Definition (`pipeline.md`)

Metadata and configuration. Not directly executed — serves as reference for the entry point and documentation.

Contains:
- Name, version, description
- Target scope (paths to analyze)
- Standards (reference docs for compliance)
- Phase sequence with agent counts and types
- Run management rules (directory naming, branching, staleness)
- Variable contract
- Extension points

### Phase Definitions (`phases/NN-name.md`)

Agent definitions for one phase. Each agent block specifies:

```markdown
## Agent N: {Name}

- **Subagent type**: `Explore` | `general-purpose`    ← Task tool parameter
- **Thoroughness**: `very thorough`                     ← Explore agents only
- **Output file**: `{OUTPUT_DIR}/NN-name.md`           ← where agent writes

### Prompt

\```
{the actual prompt text — sent verbatim to Task tool}
Write your findings to: {OUTPUT_DIR}/NN-name.md
Use the findings format from: {template path}
\```
```

The entry point reads each agent block, substitutes `{OUTPUT_DIR}` and other variables, then calls `Task(subagent_type=..., prompt=...)`.

### Output Template (`templates/*.md`)

Standard format all agents must use. Enables cross-phase consumption — Phase 2 agents can reliably parse Phase 1 output because it follows a known structure.

The default template uses V/D/S/R/P/O categories:
- **V**iolations — architecture/pattern violations
- **D**rift — cross-module inconsistencies
- **S**tale — dead code, unused, outdated
- **R**isks — potential failures, vulnerabilities
- **P**ass — correct and consistent (what NOT to change)
- **O**bservations — neutral context

Located at: `skills/audit-repo/templates/findings-format.md` (relative to plugin root)

## Variable Contract

Phase files use template variables. The entry point substitutes them at runtime.

| Variable | Description | Example |
|---|---|---|
| `{RUN_DIR}` | Root of current run | `faudit/runs/my-pipeline/2026-02-21` |
| `{OUTPUT_DIR}` | Where this phase writes | `{RUN_DIR}/phase-01` |
| `{INPUT_DIR}` | Where this phase reads from | `{RUN_DIR}/phase-01` (for Phase 2) |
| `{PHASE1_DIR}` | Phase 1 output (for Phase 3) | `{RUN_DIR}/phase-01` |
| `{PHASE2_DIR}` | Phase 2 output (for Phase 3) | `{RUN_DIR}/phase-02` |
| `{SHARED CONTEXT BLOCK}` | Preamble injected into Phase 2+ prompts | Defined in phase file |
| `{TARGET_PATH}` | Repository root (for multi-target pipelines) | `/home/user/project` |

## Run Management

### Directory Layout

```
faudit/runs/
└── {pipeline-name}/
    └── {date}[-variant]/
        ├── run-manifest.json
        ├── phase-01/
        │   ├── 00-consolidated.md   ← produced by orchestrator after agents finish
        │   ├── 01-*.md              ← agent 1 output
        │   ├── 02-*.md              ← agent 2 output
        │   └── ...
        ├── phase-02/
        │   └── ...
        └── phase-03/
            └── 01-synthesis-plan.md
```

`faudit/runs/` should always be gitignored.

### Run Manifest (`run-manifest.json`)

Written at start, updated at end:

```json
{
  "pipeline": "my-pipeline",
  "version": 1,
  "started_at": "2026-02-21T10:00:00Z",
  "git_commit": "abc1234",
  "git_branch": "main",
  "mode": "full",
  "variant": null,
  "agents": { "phase1": 5, "phase2": 3, "phase3": 1 },
  "status": "running"
}
```

On completion: set `"status": "completed"`, add `"completed_at"`.

### Auto-Increment

If `2026-02-21/` exists and you start a new full run, it creates `2026-02-21-v2/`.

### Branching

Reuse earlier phases with different parameters:

```
/my-pipeline phase-2 2026-02-21 --variant focus-security
```

This reads Phase 1 from `faudit/runs/my-pipeline/2026-02-21/phase-01/` but writes Phase 2 to a new `2026-02-21-focus-security/phase-02/`.

### Staleness Check

When reusing Phase 1 from a different date, compare the `git_commit` in that run's manifest against current HEAD. If different, warn the user before proceeding.

## Design Decisions

### Agent Types

| Type | Tools | Use for |
|---|---|---|
| `Explore` | Read-only (Glob, Grep, Read, WebSearch) | Discovery phases — fast, cheap, safe |
| `general-purpose` | All tools (Read, Write, Edit, Bash, etc.) | Interpretation/synthesis — can verify by running things |
| Custom agents | Defined in `.claude/agents/` | Domain-specific analysis |

### Parallelism

- **Within a phase**: all agents launch in parallel (single message, multiple Task calls)
- **Between phases**: strictly sequential (Phase 2 needs Phase 1 output)
- **Consolidation**: the orchestrator (main session) aggregates between phases, not a separate agent

### Checkpoints

The entry point explicitly says **"STOP and wait for user instruction"** after each phase. This provides:
- **Review gates**: inspect output before spending tokens on next phase
- **Branch points**: re-run a phase with different parameters
- **Early termination**: stop after Phase 1 if that's sufficient
- **Selective re-runs**: `/command phase-2 {date}` skips Phase 1 entirely

### Input Chaining

Each phase reads prior phase output. This is the key compositional mechanism:
- Phase 1 agents explore codebase → write structured findings
- Phase 2 agents read Phase 1 files → produce expert analysis
- Phase 3 agent reads Phase 1 + Phase 2 → produces synthesis + action plan

The output template ensures consistent structure so downstream agents can parse upstream output.

## Creating a New Pipeline

### Minimum Files

```
# Entry point — single self-contained file (preferred)
.claude/commands/{name}.md                    # project-local
plugins/<plugin>/skills/{name}/SKILL.md       # plugin skill
```

Agent prompts and output templates should be **inlined** in the entry point. Only use separate files for templates shared across multiple pipelines.

### Step 1: Define Scope and Phases

Decide what you're analyzing and how deep:

| Depth | Phases | Agents | Cost | Use when |
|---|---|---|---|---|
| Quick scan | 1 | 2-3 | Low | Targeted check, single concern |
| Standard audit | 2 | 5+3 | Medium | Module analysis with interpretation |
| Deep audit | 3 | 5+3+1 | High | Full analysis with action plan |

### Step 2: Write the Skill File

Copy from an existing `SKILL.md` (e.g., `skills/solve/SKILL.md`) and adapt:
- Change pipeline name, description, usage examples
- Define agent prompts inline for each phase (subagent type, prompt, output format)
- Adjust argument parsing if needed

Tips for writing agent prompts:
- Be specific about target paths
- List exactly what to inventory/analyze
- Specify the output file path with `{OUTPUT_DIR}` variable
- Inline the output format template directly in the prompt
- End with: "Research and analysis only, no code changes."
- For Phase 2+: include `{SHARED CONTEXT BLOCK}` with file list from prior phase

### Step 3: Wire Up

**For project-local**: Place entry point at `.claude/commands/{name}.md` — invoked as `/{name}`.

**For plugin**: Place at `plugins/<plugin>/skills/{name}/SKILL.md` inside a Claude Code plugin. Install via `/plugins`.

## Design Levers

| Lever | Range | Tradeoff |
|---|---|---|
| Agent count per phase | 1-8 | Coverage vs cost |
| Agent type | Explore vs general-purpose | Speed/safety vs capability |
| Phase count | 1-4 | Depth vs time |
| Checkpoint behavior | Stop vs auto-continue | Control vs speed |
| Output format | Reuse V/D/S/R/P/O vs custom | Consistency vs domain fit |
| Scope | Hardcoded paths vs auto-discover | Precision vs portability |
| Multi-target | Single repo vs N repos | Simplicity vs flexibility |

## Existing Pipelines

| Pipeline | Command | Scope | Source | Entry Point |
|---|---|---|---|---|
| `audit` | `/audit` | FUXI L5/L7 music modules | `faudit/pipelines/audit/` | `.claude/commands/audit.md` |
| `repo` | `/audit-repo` | Any repository (agnostic) | `skills/audit-repo/` | `skills/audit-repo/SKILL.md` |
| `solve` | `/solve` | Any repository (goal-directed) | `skills/solve/` | `skills/solve/SKILL.md` |

## Shared Agents

Agent definitions live in `plugins/<plugin>/agents/` inside a Claude Code plugin. They serve dual purpose:

1. **Pipeline building blocks** — referenced by `subagent_type` name in phase files. The agent definition provides the base role (system prompt), and the pipeline provides the specific context ({REQUEST}, output paths, format references).
2. **Standalone agents** — invokable directly via `Task(subagent_type="agent-name", prompt="...")` or `claude --agent agent-name`.

### Available Agents

| Agent | Type | Tools | Pipeline Use |
|---|---|---|---|
| `code-explorer` | Explore | Read, Grep, Glob, Bash | solve P1, audit P1 |
| `pattern-analyzer` | Explore | Read, Grep, Glob, Bash | solve P1, audit P1 |
| `dependency-mapper` | Explore | Read, Grep, Glob, Bash | solve P1, audit P1 |
| `solution-architect` | general-purpose | Read, Grep, Glob, Bash, Write | solve P2 |
| `risk-analyst` | general-purpose | Read, Grep, Glob, Bash | solve P2 |
| `synthesizer` | general-purpose | Read, Grep, Glob, Bash, Write | solve P3, audit P3 |

### Agent Definition Format

```markdown
---
name: agent-name
description: When to use this agent
tools: Read, Grep, Glob, Bash
model: inherit
---

Role description and base instructions (system prompt).
Kept short — detailed instructions come from the pipeline prompt.
```

### How Pipelines Reference Agents

Phase files specify `subagent_type` matching the agent's `name` field:

```markdown
## Agent 1: Code Explorer

- **Subagent type**: `code-explorer`
- **Output file**: `{OUTPUT_DIR}/01-code-structure.md`

### Prompt
{Context-specific prompt with {REQUEST}, {OUTPUT_DIR}, format reference}
```

The orchestrator calls `Task(subagent_type="code-explorer", prompt=<substituted prompt>)`.

## Shared Resources

| Resource | Location | Used by |
|---|---|---|
| Agent definitions | `agents/*.md` (plugin root) | All pipelines, standalone use |
| Findings format (V/D/S/R/P/O) | `skills/audit-repo/templates/findings-format.md` | audit-repo pipeline |
| Run output | `faudit/runs/{pipeline}/{date}/` | All pipelines |
| Sync checker | `scripts/sync-check.sh` | Structural drift detection between canonical and override skills |

## Inline vs External Convention

**Preferred**: Inline all agent prompts and output templates directly in `SKILL.md`. This eliminates runtime file reads and makes each skill self-contained.

**When to use external files**: Only for shared templates reused by multiple pipelines (e.g., `audit-repo/templates/findings-format.md`). If a template is used by only one skill, inline it.

**Project overrides** (e.g., `/fuxi-solve` overriding `/solve`): Copy the full structure, replace agent types and domain-specific content. Use `scripts/sync-check.sh` to verify structural alignment with the canonical skill.
