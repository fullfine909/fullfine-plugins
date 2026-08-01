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

**Plugin: `design-skills`**

Skills:
- `/poster-prompt` — Prompts for text-heavy posters and infographics: model routing
  (GPT Image 2 / Ideogram / Nano Banana / Recraft vector), the 5-to-9 card ceiling,
  exact-string quoting, and which copy must be retyped rather than generated.

Renders through the `poster` CLI in `~/Dev/tools/poster` (symlinked into
dj-platform, fullfine-services and pulse as `scripts/poster`). The skill writes the
prompt; the CLI turns it into a file.

## Install

In Claude Code, run `/plugins` and add the marketplace:

```
fullfine/fullfine-plugins
```

Then enable `pipeline-skills`, `design-skills`, or both.

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
