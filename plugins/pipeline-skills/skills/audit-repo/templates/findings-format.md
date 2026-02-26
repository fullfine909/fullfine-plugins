# Findings Format Template

Standard output format for all audit pipeline agents. Every agent must structure their findings using this format to enable cross-phase consumption.

---

## Template

```markdown
# {Agent Title} — {Module/Scope}

**Phase**: {phase number}
**Agent**: {agent number and role}
**Date**: {run date}
**Paths Analyzed**: {list of paths}

## Summary

One-paragraph executive summary of findings. State the overall health, most critical finding, and key recommendation.

## Inventory

Brief structural inventory of what was analyzed:
- Files: N
- Classes: N
- Functions/Methods: N
- Key components: [list]

## Findings

### VIOLATIONS — Architecture/Pattern Violations

Issues where code breaks established patterns, layer boundaries, or architectural rules.

- **V-001**: {description} | `{file:line}` | severity: {critical|high|medium|low}
  - Expected: {what should be}
  - Actual: {what is}
  - Impact: {why this matters}

### DRIFT — Cross-Module Inconsistencies

Cases where modules that should follow the same pattern have diverged.

- **D-001**: {what differs}
  - Module A: {pattern used} (`{file}`)
  - Module B: {different pattern} (`{file}`)
  - Recommendation: {which pattern to standardize on}

### STALE — Dead Code, Unused, Outdated

Code that is no longer needed, referenced, or up to date.

- **S-001**: {description} | `{file:line}`
  - Evidence: {how we know it's stale}
  - Action: {remove|update|deprecate}

### RISKS — Potential Failures and Vulnerabilities

Latent risks: race conditions, missing error handling, edge cases that could cause production failures. These are NOT neutral observations — they require attention.

- **R-001**: {description} | `{file:line}` | likelihood: {high|medium|low} | impact: {high|medium|low}
  - Scenario: {what triggers it}
  - Mitigation: {how to fix}

### PASS — Correct and Consistent

Things that work well and follow established patterns. Important for knowing what NOT to change and for replicating good patterns in future modules.

**Minimum**: Include at least 5 PASS findings per major section analyzed.

- **P-001**: {what works well}

### OBSERVATIONS — Neutral Findings

Context, measurements, and notes that aren't issues but inform interpretation.

- **O-001**: {observation}

## Metrics

| Metric | Count |
|--------|-------|
| Files analyzed | N |
| Classes/functions inventoried | N |
| Violations found | N |
| Drift instances | N |
| Stale items | N |
| Risks identified | N |
| Critical severity | N |
| High severity | N |
| Medium severity | N |
| Low severity | N |
```

---

## Severity Definitions

| Level | Meaning | Action | Guideline |
|-------|---------|--------|-----------|
| **critical** | Causes runtime failures, data corruption, or security risk | Must fix immediately | Use ONLY when code will break in production |
| **high** | Significant pattern/layer violation, impacts maintainability | Fix in current sprint | Architecture rules broken, but system still works |
| **medium** | Inconsistency or tech debt, doesn't block anything | Plan for next sprint | Could be better, not urgent |
| **low** | Style/preference, minor improvement | Address opportunistically | Nice to have |

---

## Finding Categories

- **V-NNN**: Violation (V-001, V-002, ...)
- **D-NNN**: Drift (D-001, D-002, ...)
- **S-NNN**: Stale (S-001, S-002, ...)
- **R-NNN**: Risk (R-001, R-002, ...)
- **P-NNN**: Pass (P-001, P-002, ...)
- **O-NNN**: Observation (O-001, O-002, ...)

IDs are local to each agent's output file. Cross-referencing uses `{agent-file}:{ID}` format (e.g., `01-l5-domain:V-003`).

The Phase 3 synthesis agent assigns globally unique IDs for the master issue list: `ARCH-001`, `IMPL-001`, `DOM-001`, `QUAL-001`, `DOC-001`.
