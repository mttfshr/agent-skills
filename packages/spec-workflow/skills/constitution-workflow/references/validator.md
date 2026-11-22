---
name: [PROJECT_NAME]-validator
description: Validates code and suggestions against [PROJECT_NAME]'s locked architectural decisions and design patterns. Use when user asks to "check ADRs", "validate architecture", "review against principles", or before implementing significant features.
---

# [PROJECT_NAME] Architecture Validator

Enforce locked ADRs and design patterns before implementation.

## Quick Validation Checklist

Before ANY recommendation or implementation:

- [ ] [KEY PRINCIPLE 1]
- [ ] [KEY PRINCIPLE 2]
- [ ] [KEY PRINCIPLE 3]
- [ ] [KEY PRINCIPLE 4]
- [ ] [NO TECHNOLOGY COMMITMENTS if exploratory]
- [ ] [ALIGNS WITH PRIMARY PURPOSE]
- [ ] [RESPECTS SCOPE BOUNDARIES]

## Mechanical Checks

Checks a command can run. Judgment items stay in the checklist above.

| Check | Command | Passes when | Cost |
|-------|---------|-------------|------|
| [CHECK 1] | `[COMMAND]` | [EXPECTED RESULT] | cheap |
| [CHECK 2] | `[COMMAND]` | [EXPECTED RESULT] | full |

**cheap** = run after every task. **full** = run at phase checkpoints (slow, needs a running service, or costs time or money).
Delete this section if the project has no command-checkable rules, and say so.

Before trusting a new check, see it fail once (a deliberately broken input, or the code it was written to catch).

## Critical ADR Violations to Catch

### ADR-[X]: [MOST COMMONLY VIOLATED] ⚠️
❌ **[VIOLATION TYPE 1]** - specific examples
❌ **[VIOLATION TYPE 2]** - specific examples
❌ **[VIOLATION TYPE 3]** - specific examples

**If suggesting any of these → STOP and remind user of ADR-[X]**

### ADR-[Y]: [SECOND CRITICAL ADR]
❌ [Anti-pattern 1]
❌ [Anti-pattern 2]
✅ [Correct pattern 1]
✅ [Correct pattern 2]

### ADR-[Z]: [THIRD CRITICAL ADR]
❌ [Anti-pattern 1]
❌ [Anti-pattern 2]
✅ [Correct pattern 1]
✅ [Correct pattern 2]

## Design Pattern Violations

[IF APPLICABLE - delete if no formal patterns]

### Pattern [N]: [PATTERN NAME]
❌ [Violation example]
❌ [Violation example]
✅ [Correct implementation]
✅ [Correct implementation]

## Common Scope Creep

Watch for these expansions beyond [PRIMARY PURPOSE]:

❌ "[SCOPE CREEP EXAMPLE 1]"
❌ "[SCOPE CREEP EXAMPLE 2]"
❌ "[SCOPE CREEP EXAMPLE 3]"

**If any of these appear → redirect to [PRIMARY PURPOSE] focus**

## Validation Report Format

When validating code or suggestions, use this format:

```
# Architecture Validation

## ADR Compliance
✅ ADR-001: [Decision name] maintained
✅ ADR-002: [Decision name] respected
❌ ADR-00X: VIOLATION - [specific issue]

## [Pattern/Principle] Compliance
✅ [Pattern 1]: Correct
✅ [Pattern 2]: Respected
⚠️ [Pattern 3]: Check [specific aspect]

## Mechanical Checks
✅ [Check 1]: passed (`[command]`)
❌ [Check 2]: failed - [output summary]

## Recommendations
1. [Specific fix for violation]
2. [Verification step]
3. [Alternative approach]
```

## Quick ADR Reference

For full details, read `docs/decisions.md`. Quick reference:

- **ADR-001**: [Brief description]
- **ADR-002**: [Brief description]
- **ADR-003**: [Brief description]
- **ADR-00X**: [Brief description] ⭐ CRITICAL

## Technology Stance Validation

[ADAPT BASED ON YOUR TECHNOLOGY PHILOSOPHY]

When discussing technology choices:

❌ "This will be the production [tool]"
❌ "We're committing to [technology]"
❌ "Final architecture uses [platform]"

✅ "Exploring [technology] for [purpose]"
✅ "Testing [tool] as an option"
✅ "Will decide after [milestone]"

**Always caveat tech choices as exploratory** [OR commit early if that's your philosophy]

## [Pattern/Principle] Checklist

For major features, verify all [N] [patterns/principles]:

**[CATEGORY 1]:**
- [ ] 1. [Item]
- [ ] 2. [Item]

**[CATEGORY 2]:**
- [ ] 3. [Item]
- [ ] 4. [Item]

## When to Deep-Dive

This skill provides quick validation. For detailed info:

**Read docs/decisions.md** - Full ADR text
**Read [other-doc].md** - [What it contains]

Only load these if validation finds issues or user asks for details.
