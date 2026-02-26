# fullfine-plugins

Personal Claude Code plugin marketplace.

## What's Included

**Plugin: `pipeline-skills`**

Skills (invoke with `/skill-name` in Claude Code):
- `/solve` — Multi-phase solution planning: discovery (3 agents) → solution design (2 agents) → synthesis (1 agent)
- `/audit-repo` — Codebase audit pipeline: discovery (5 agents) → interpretation (3 agents) → synthesis (1 agent)

Agents (used as `subagent_type` by skills):
- `code-explorer` — Codebase structure and architecture exploration
- `pattern-analyzer` — Code patterns and conventions analysis
- `dependency-mapper` — Dependencies and constraints mapping
- `solution-architect` — Implementation planning with concrete task lists
- `risk-analyst` — Risk assessment and testing strategy
- `synthesizer` — Multi-agent findings consolidation

## Install

In Claude Code, run `/plugins` and add the marketplace:

```
fullfine/fullfine-plugins
```

Then enable `pipeline-skills`.

## Update

Run `/plugins` and refresh the marketplace. Or:

```bash
git -C ~/.claude/plugins/marketplaces/fullfine-plugins pull
```

## Uninstall

Disable `pipeline-skills` in `/plugins`, or remove the marketplace entirely:

```bash
rm -rf ~/.claude/plugins/marketplaces/fullfine-plugins
```
