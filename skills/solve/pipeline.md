# Solve Pipeline: Goal-Directed Solution Planning

**Target**: Any software repository -- language and framework agnostic
**Input**: Free-text user request
**Phases**: 2 default (Discovery -> Solution), optional 3rd (Synthesis)
**Total agents**: 6 (3 + 2 + 1)
**Estimated duration**: ~10 min per phase (~20-30 min total)

---

## Pipeline Configuration

```yaml
name: solve
version: 2
description: Analyze a free-text request and produce a concrete implementation plan
target_scope: current directory (always)
input: free-text request from user
agents: shared definitions from ~/.claude/agents/
```

---

## Agents

All agents are defined in `~/.claude/agents/` (shared across pipelines):

| Agent | Subagent Type | Phase | Role |
|-------|--------------|-------|------|
| Code Explorer | `code-explorer` | 1 | Finds code relevant to the request |
| Pattern Analyzer | `pattern-analyzer` | 1 | Analyzes patterns and conventions |
| Dependency Mapper | `dependency-mapper` | 1 | Maps constraints and dependencies |
| Solution Architect | `solution-architect` | 2 | Designs implementation plan |
| Risk Analyst | `risk-analyst` | 2 | Analyzes risks and testing |
| Synthesizer | `synthesizer` | 3 | Consolidates into final plan |

Agent definitions provide the base role (system prompt). Pipeline prompts provide the specific context ({REQUEST}, output paths, format references).

---

## Phase Sequence

### Phase 1: Discovery
- **File**: `phases/01-discovery.md`
- **Agents**: 3 (code-explorer, pattern-analyzer, dependency-mapper) -- parallel
- **Type**: Goal-directed codebase exploration
- **Output**: `{RUN_DIR}/phase-01/` (3 files + `00-consolidated.md`)
- **Duration**: ~10 min

### [CHECKPOINT 1]

After Phase 1 completes:
1. All 3 agent outputs + consolidated summary in `{RUN_DIR}/phase-01/`
2. **STOP** -- present findings summary table to user
3. User reviews findings
4. User decides: proceed to Phase 2 or stop

### Phase 2: Solution Design
- **File**: `phases/02-solution.md`
- **Agents**: 2 (solution-architect, risk-analyst) -- parallel
- **Type**: Implementation planning
- **Input**: `{RUN_DIR}/phase-01/`
- **Output**: `{RUN_DIR}/phase-02/`
- **Duration**: ~10 min

### [CHECKPOINT 2]

After Phase 2 completes:
1. Solution plan + risk analysis in `{RUN_DIR}/phase-02/`
2. **STOP** -- present executive summary and task list
3. User reviews plan
4. User decides: proceed to Phase 3 (synthesis) or stop here

### Phase 3: Synthesis (Optional)
- **File**: `phases/03-synthesis.md`
- **Agents**: 1 (synthesizer)
- **Type**: Final plan consolidation and validation
- **Input**: `{RUN_DIR}/phase-01/` + `{RUN_DIR}/phase-02/`
- **Output**: `{RUN_DIR}/phase-03/`
- **Duration**: ~10 min

---

## Run Manifest

```json
{
  "pipeline": "solve",
  "version": 2,
  "started_at": "2026-02-21T10:00:00Z",
  "git_commit": "<current HEAD>",
  "git_branch": "<current branch>",
  "request": "add rate limiting to the API",
  "agents": { "phase1": 3, "phase2": 2, "phase3": 0 },
  "status": "running"
}
```

On completion: set `"status": "completed"`, add `"completed_at"`.
If Phase 3 is triggered, update `"agents.phase3": 1`.

---

## Variable Contract

| Variable | Description | Example |
|----------|-------------|---------|
| `{RUN_DIR}` | Root of current run | `faudit/runs/solve/2026-02-21` |
| `{OUTPUT_DIR}` | Where this phase writes | `{RUN_DIR}/phase-01` |
| `{INPUT_DIR}` | Where this phase reads from | `{RUN_DIR}/phase-01` (for Phase 2) |
| `{PHASE1_DIR}` | Phase 1 output (for Phase 3) | `{RUN_DIR}/phase-01` |
| `{PHASE2_DIR}` | Phase 2 output (for Phase 3) | `{RUN_DIR}/phase-02` |
| `{SHARED CONTEXT BLOCK}` | Preamble injected into Phase 2+ prompts | Defined in phase file |
| `{REQUEST}` | User's free-text request | `add rate limiting to the API` |

---

## Extension Points

### Phase Skipping (v3)
Add `/solve --continue 2026-02-21` to reuse Phase 1 and jump to Phase 2.

### Implementation Phase (v3+)
Add Phase 4: agents execute the plan using `general-purpose` agents that can write code.

### Multi-Target (v3+)
Support `/solve --target ../other-repo <request>`.
