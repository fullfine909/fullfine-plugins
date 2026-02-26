# Global Preferences

## Coding Principles

- Continuous refactoring over backward compatibility — break things to improve them
- YAGNI: don't implement unrequested features, ask before adding extras
- Clean architecture: prioritize clarity and maintainability over complexity
- Integration-first testing with real dependencies over mocks
- Avoid over-engineering: only make changes that are directly requested or clearly necessary

## Communication

- Concise, actionable recommendations
- Present options with tradeoffs, then recommend one
- No emojis in code or technical writing unless explicitly requested
- No explanatory comments on edits — code should be self-explanatory

## Cross-Project Conventions

- `faudit/runs/` — Pipeline execution output (always gitignored)
- `.claude/` — Project-specific Claude Code config (skills, commands, agents, settings)
- `ftasks/` — Task management data (project-specific YAML files)
- `CLAUDE.md` — Project instructions at repo root
