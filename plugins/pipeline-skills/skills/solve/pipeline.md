# Solve Pipeline — Design Reference

## Architecture

The solve pipeline is a 3-phase, multi-agent orchestration that turns a free-text request into a concrete implementation plan.

```
Phase 1: Discovery          Phase 2: Solution Design       Phase 3: Synthesis
┌──────────────────┐        ┌──────────────────────┐       ┌───────────────┐
│ ps:code-explorer │──┐     │ ps:solution-architect │──┐    │ ps:synthesizer│
│ ps:pattern-analyz│──┼──►  │ ps:risk-analyst       │──┼──► │               │
│ ps:dependency-map│──┘     └──────────────────────┘  │    └───────────────┘
└──────────────────┘        reads phase-01 output ────┘    reads phases 1+2
        ▲                           ▲                           │
        │                           │                           ▼
   [user checkpoint]          [user checkpoint]          final plan
```

## File Organization

```
solve/
├── SKILL.md              # Orchestration flow (setup, step sequencing, final report)
├── pipeline.md           # This file — design reference
├── phases/
│   ├── discovery.md      # Phase 1: 3 parallel agents + consolidation
│   ├── solution.md       # Phase 2: 2 parallel agents + shared context
│   └── synthesis.md      # Phase 3: 1 synthesizer agent
└── templates/
    ├── discovery-output.md    # Output format for all discovery agents
    ├── consolidation.md       # Phase 1 summary format
    ├── solution-plan.md       # Solution architect output format
    ├── risk-analysis.md       # Risk analyst output format
    └── implementation-plan.md # Final synthesized plan format
```

## Extension Pattern

Project-specific skills can extend this pipeline by:

1. **Overriding agent types** — use domain-specific agents instead of generic ones
2. **Injecting domain context** — add project-specific context to agent prompts
3. **Extending templates** — add extra fields/sections to the shared output formats
4. **Reusing templates** — reference this skill's templates for consistent output

Example: a FUXI-specific solve skill might use `architecture-reviewer` instead of
`code-explorer`, inject layer architecture context, and add "Layer" fields to tasks.

To reference templates from an extending skill:
```
Read the output format from the global solve template:
~/.claude/plugins/marketplaces/fullfine-plugins/plugins/pipeline-skills/skills/solve/templates/{template}.md
```

## Output Structure

Each run creates a timestamped directory:

```
faudit/runs/solve/
└── 2026-03-10/
    ├── run-manifest.json
    ├── phase-01/
    │   ├── 00-consolidated.md
    │   ├── 01-code-structure.md
    │   ├── 02-patterns.md
    │   └── 03-dependencies.md
    ├── phase-02/
    │   ├── 01-solution-plan.md
    │   └── 02-risk-analysis.md
    └── phase-03/           (optional)
        └── 01-implementation-plan.md
```

## Agent Contract

All agents follow the same contract:
- **Input**: Request text + any prior phase output files
- **Output**: A single markdown file at the specified path
- **Constraint**: Research and analysis only — no code changes
- **Format**: As defined in the relevant template file
