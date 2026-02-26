# Solution Format Template

Standard output format for solve pipeline solution design agents.

---

## Template

```markdown
# Solution Plan: {Request}

**Phase**: 2 (Solution Design)
**Date**: {date}

## Executive Summary

3-5 sentences: What approach are we taking? Why this approach over alternatives? What's the estimated total effort? Biggest risk?

## Approach

### Strategy
{High-level description of the implementation approach}

### Alternatives Considered

| Alternative | Pros | Cons | Why Not |
|-------------|------|------|---------|
| {approach} | {pros} | {cons} | {reason for rejection} |

### Key Design Decisions

- **Decision 1**: {what was decided} -- {rationale}
- **Decision 2**: ...

## Task List

Ordered list of implementation tasks. Each task should be atomic (completable in one sitting) and independently verifiable.

### Task 1: {Title}
- **Files**: {files to create/modify/delete}
- **Changes**: {what specifically to change -- enough detail to execute}
- **Depends on**: {other task numbers or "none"}
- **Effort**: {XS (<30min) / S (30min-2h) / M (2-4h) / L (4-8h) / XL (>8h)}
- **Acceptance criteria**: {how to verify this task is done}

### Task 2: {Title}
...

## Dependency Graph

```
Task 1 --> Task 3 --> Task 5
Task 2 --> Task 4 --/
```

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| {risk} | high/med/low | high/med/low | {how to handle} |

## Testing Approach

- **Existing tests to update**: {list with file paths}
- **New tests to write**: {list with descriptions}
- **Manual verification**: {steps to confirm it works}

## Effort Summary

| Effort | Count | Estimated Time |
|--------|-------|---------------|
| XS | N | N * 15min |
| S | N | N * 1h |
| M | N | N * 3h |
| L | N | N * 6h |
| XL | N | N * 10h |
| **Total** | N | ~Xh |
```
