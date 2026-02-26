# claude-skills

Shared skills, agents, and pipelines for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## What's Included

**Skills** (invoke with `/skill-name` in Claude Code):
- `/solve` — Multi-phase solution planning: discovery (3 agents) → solution design (2 agents) → synthesis (1 agent)
- `/audit-repo` — Codebase audit pipeline: discovery → interpretation → synthesis

**Agents** (used as `subagent_type` by skills):
- `code-explorer` — Codebase structure and architecture exploration
- `pattern-analyzer` — Code patterns and conventions analysis
- `dependency-mapper` — Dependencies and constraints mapping
- `solution-architect` — Implementation planning with concrete task lists
- `risk-analyst` — Risk assessment and testing strategy
- `synthesizer` — Multi-agent findings consolidation

## Install

```bash
git clone git@gitlab.com:fullfine_utils/claude-skills.git
cd claude-skills
./install.sh
```

This creates symlinks into `~/.claude/` (agents as individual file links, skills as directory links). Existing real files are never overwritten.

To install to a custom location:

```bash
./install.sh /path/to/target
```

## Sync (maintainer only)

Copy files from the SSOT (dotfiles) into this repo:

```bash
./sync.sh                    # default: ~/.dots/claude
./sync.sh /path/to/source    # custom source
```

Then commit and push.
