# Discovery Format Template

Standard output format for solve pipeline discovery agents. Each agent writes findings relevant to their assigned exploration area and the user's goal.

---

## Template

```markdown
# Discovery: {Area Name}

**Phase**: 1 (Discovery)
**Agent**: {agent number} of {total agents}
**Area**: {area description}
**Request**: {user's request}

## Current State

How does this area of the codebase currently work? Describe the existing implementation, architecture, and behavior.

### Key Files

| File | Purpose | Relevance to Request |
|------|---------|---------------------|
| `path/to/file.ext` | {what it does} | {why it matters for the goal} |

### Key Functions/Classes

| Name | Location | Purpose |
|------|----------|---------|
| `function_name` | `file:line` | {what it does} |

### Patterns & Conventions

How is this area structured? What patterns does it follow? What conventions must new code respect?

- Pattern 1: {description}
- Pattern 2: {description}

## Relevant to the Goal

What specifically in this area relates to the user's request?

### Opportunities

Where and how could changes be made to address the request?

- **OPP-1**: {description} | `{file}` | {why this is a good place to change}

### Constraints

What must a solution respect? Hard requirements that cannot be violated.

- **CON-1**: {constraint} | {why it exists} | {what breaks if violated}

### Dependencies

What does this area depend on, and what depends on it?

- **Upstream**: {things this area uses}
- **Downstream**: {things that use this area}

## Obstacles

What makes solving the request harder in this area?

- **OBS-1**: {obstacle} | severity: {high|medium|low} | {possible workaround}

## Summary

1-2 paragraph summary: What did we learn about this area? What's the most important insight for the solution designer?
```
