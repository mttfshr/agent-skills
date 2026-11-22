---
name: analyze-consistency-workflow
description: Validate consistency across constitution, spec, plan, and tasks. Use when user wants to check alignment before implementation.
---

# Specification Analysis Workflow

## When to Use
- After generating tasks
- User says: "analyze consistency", "validate specs", "check alignment", "is everything consistent"
- Before starting implementation

## Goal

Identify inconsistencies, duplications, ambiguities, and gaps across:
- Constitution (`.specify/constitution.md`)
- Specification (`.specify/spec.md`)
- Plan (`.specify/plan.md`)
- Tasks (`.specify/tasks.md`)

**STRICTLY READ-ONLY**: No file modifications. Output structured report only.

## The Analysis Process

### Step 1: Load Artifacts

Load minimal necessary context:

**From constitution.md:**
- Core values (MUST/SHOULD principles)
- Hard constraints
- Out of scope items

**From spec.md:**
- Functional requirements
- Non-functional requirements
- User stories
- Success criteria
- Edge cases
- Verify lines (per user story)

**From plan.md:**
- Architecture/stack choices
- Data model
- Technical constraints

**From tasks.md:**
- Task IDs and descriptions
- Phase grouping
- File paths referenced
- [P] parallel markers
- [US#] story labels
- Checkpoint Verify lines

### Step 2: Build Semantic Models

Create internal mappings (not in output):

**Requirements inventory:**
- Each functional + non-functional requirement
- Key: derived slug (e.g., "user-can-upload-file")

**User story inventory:**
- Discrete user actions
- Acceptance criteria

**Task coverage mapping:**
- Map each task → requirements/stories
- Use explicit references first (a story's Verify line, [US#] labels, FR IDs); infer by keywords only for what is left

**Constitution rule set:**
- Extract principle names
- MUST/SHOULD normative statements

### Step 3: Detection Passes

Focus on high-signal findings (limit 50 total):

#### A. Duplication Detection
- Near-duplicate requirements
- Same feature described differently
- Mark lower-quality phrasing for consolidation

#### B. Ambiguity Detection
- Vague adjectives without metrics (fast, scalable, secure, intuitive)
- Unresolved placeholders (TODO, ???, TBD)
- Requirements missing measurable criteria

#### C. Underspecification
- Requirements with verbs but no measurable outcome
- User stories missing acceptance criteria
- Tasks referencing undefined components
- Missing file structure in plan

#### D. Constitution Alignment
- Any requirement/plan conflicting with MUST principles
- Missing mandated sections from constitution
- Out-of-scope features appearing in spec/tasks

#### E. Coverage Gaps
- Requirements with zero associated tasks
- Tasks with no mapped requirement/story
- Non-functional requirements not in tasks (performance, security)

#### F. Inconsistency
- Terminology drift (same concept, different names)
- Data entities in plan but not spec (or vice versa)
- Task ordering contradictions
- Conflicting requirements (e.g., "Next.js" vs "Vue")
- User story priorities not matching task phases

#### G. Verification Coverage
- User story with no Verify line
- Verify is `none yet` (P1 story: HIGH; P2 or later: MEDIUM)
- A story's Verify missing from, or different in, its phase checkpoint in tasks.md
- A `test:` or `command:` Verify with no task creating it, and not already present in the project
- Plan's Verification Strategy contradicts the spec's Verify

### Step 4: Severity Assignment

**CRITICAL:**
- Violates constitution MUST principle
- Missing core artifact
- Requirement with zero coverage blocking baseline functionality
- Conflicting hard constraints

**HIGH:**
- Duplicate or conflicting requirement
- Ambiguous security/performance attribute
- Untestable acceptance criterion
- User story without tasks
- P1 story whose Verify is `none yet`, or whose spec Verify is missing from its checkpoint

**MEDIUM:**
- Terminology drift
- Missing non-functional task coverage
- Underspecified edge case
- Task without requirement mapping
- P2 or later story whose Verify is `none yet`, or a story with no Verify line
- A `test:` or `command:` Verify with no creating task

**LOW:**
- Style/wording improvements
- Minor redundancy not affecting execution
- Nice-to-have documentation gaps

### Step 5: Generate Analysis Report

Output markdown table format:

```markdown
## Specification Analysis Report

**Date**: [Today]
**Artifacts**: constitution.md, spec.md, plan.md, tasks.md

### Findings

| ID | Category | Severity | Location | Summary | Recommendation |
|----|----------|----------|----------|---------|----------------|
| A1 | Duplication | HIGH | spec.md:L120-134 | Two similar requirements for user auth | Merge; keep clearer version |
| C1 | Constitution | CRITICAL | plan.md:L45 | Uses PostgreSQL but constitution says "no backend" | Remove or update constitution |
| G1 | Coverage | HIGH | spec.md FR-005 | "Export data" requirement has no tasks | Add export tasks to US3 |
| T1 | Terminology | MEDIUM | spec/plan | "Session" vs "User session" | Standardize on "session" |

[Continue for all findings, max 50 rows]

### Coverage Summary

| Requirement | Has Tasks? | Task IDs | Notes |
|-------------|------------|----------|-------|
| FR-001: User login | ✅ | T015, T016 | |
| FR-002: Data export | ❌ | None | Missing coverage |
| FR-003: Session mgmt | ✅ | T020-T023 | |
[Continue for all requirements]

### Verification Coverage

| Story | Verify (spec) | In checkpoint? | Creating task | Notes |
|-------|---------------|----------------|---------------|-------|
| US1 | test: tests/session.spec.js | ✅ | T012 | |
| US2 | none yet | ❌ | None | P2: MEDIUM |
[Continue for all stories]

### Constitution Alignment

**✅ Aligned:**
- No backend (all tasks use local storage)
- Vue 3 stack (plan and tasks consistent)

**⚠️ Issues:**
- FR-007 mentions "API endpoint" but constitution says "no backend"

### Unmapped Tasks

Tasks with no clear requirement/story mapping:
- T045: "Add analytics tracking" (not in spec, conflicts with out-of-scope)
- T051: "Setup CI/CD" (infrastructure, maybe should be in plan)

### Metrics

- Total Requirements: 24
- Total Tasks: 47
- Coverage: 87.5% (21 requirements with ≥1 task)
- Ambiguity Count: 3
- Duplication Count: 2
- Critical Issues: 1
- High Issues: 4
- Medium Issues: 6
- Low Issues: 2
```

### Step 6: Provide Next Actions

**If CRITICAL issues exist:**
```
⚠️ CRITICAL issues found. Resolve before implementation:
1. [List critical issues]
2. [Suggested fixes]

Recommended: Fix critical issues, then re-run analysis.
```

**If only HIGH/MEDIUM/LOW:**
```
✅ No critical blockers. You may proceed with implementation.

Recommended improvements:
- [List top 3-5 issues by severity]

Optional: Address these issues now or create tasks to fix during polish phase.
```

### Step 7: Offer Remediation

Ask: "Would you like me to suggest concrete fixes for the top N issues?"

**Do NOT apply fixes automatically** - only suggest them.

Example remediation:
```
**Fix for A1 (Duplication):**

In spec.md, lines 120-134, you have:
- FR-003: "Users must authenticate via email"
- FR-008: "System requires email-based login"

Suggested merge:
- FR-003: "Users MUST authenticate via email and password"
- Delete FR-008
- Update any task references from FR-008 → FR-003
```

## Example Session

```
User: "Analyze consistency"

Claude: [loads all artifacts, performs analysis]

## Specification Analysis Report

**Date**: 2026-02-01
**Artifacts**: constitution.md, spec.md, plan.md, tasks.md

### Findings

| ID | Category | Severity | Location | Summary | Recommendation |
|----|----------|----------|----------|---------|----------------|
| C1 | Constitution | CRITICAL | spec.md FR-012 | Requires backend API but constitution says "no backend" | Remove FR-012 or update constitution |
| G1 | Coverage | HIGH | spec.md FR-007 | "Balance indicator" has no tasks | Add tasks to US5 phase |
| T1 | Terminology | MEDIUM | Throughout | Mixes "task" and "todo" | Standardize on "task" |
| D1 | Duplication | HIGH | spec.md:L89, L145 | Two requirements for session close | Merge into single FR |

### Coverage Summary

Coverage: 91.7% (22 of 24 requirements have tasks)

Missing coverage:
- FR-007: Balance indicator visual design
- FR-019: Session resume on reload

### Constitution Alignment

**⚠️ CRITICAL VIOLATION:**
- FR-012 requires "REST API for sync" but constitution says "no backend, no sync"

**✅ Aligned:**
- Local-first architecture (all tasks use IndexedDB)
- Vue 3 + Dexie.js stack consistent

### Metrics

- Requirements: 24
- Tasks: 47  
- Coverage: 91.7%
- Critical: 1
- High: 2
- Medium: 1
- Low: 0

---

⚠️ **CRITICAL issue found. Resolve before implementation:**

C1: FR-012 conflicts with constitution's "no backend" constraint.

**Resolution options:**
1. Remove FR-012 from spec (recommended)
2. Update constitution to allow backend (requires explicit decision)

Would you like me to suggest fixes for the other issues?
```

User: "Yes, suggest fixes"

Claude: 
```
### Suggested Fixes

**For G1 (Coverage - Balance Indicator):**

Add to tasks.md, Phase 5 (US5):
```
- [ ] T034 [US5] Create BalanceIndicator component in src/components/BalanceIndicator.vue
- [ ] T035 [US5] Wire BalanceIndicator into SessionView
- [ ] T036 [US5] Test balance indicator updates with task changes
```

**For T1 (Terminology - task/todo):**

Search and replace in spec.md:
- "todo" → "task"
- "to-do" → "task"

**For D1 (Duplication):**

In spec.md:
- Keep FR-008 (line 89): "User can close session with optional reflection"
- Delete FR-015 (line 145): duplicate of session close
- Update any references to FR-015 → FR-008

Shall I proceed to create a remediation checklist?
```

## Validation Checklist

After analysis, verify report includes:
- [ ] Findings table with ID, severity, location, summary, recommendation
- [ ] Coverage summary showing requirements → tasks mapping
- [ ] Verification coverage: each story's Verify line and where it appears in tasks.md
- [ ] Constitution alignment section
- [ ] Unmapped tasks list
- [ ] Metrics summary
- [ ] Clear next actions
- [ ] Limited to 50 findings (if more, aggregate in overflow section)

## Output

Generates: Analysis report (markdown, not saved to file)

## Common Issues Found

**Constitution violations:**
- Tech stack mismatch
- Features in out-of-scope appearing in spec
- Missing mandated quality gates

**Coverage gaps:**
- Requirements without tasks
- Non-functional requirements (performance, security) not in tasks
- User stories without complete task set

**Inconsistencies:**
- Terminology drift (session vs user-session vs planning-session)
- Data model mismatch (entities in plan not in spec)
- Priority mismatch (P1 story in Phase 4 tasks)

**Ambiguity:**
- Vague requirements ("fast", "secure", "robust")
- Missing acceptance criteria
- Undefined edge cases

## Best Practices

**Token efficiency:**
- Load artifacts progressively
- Build internal models, not raw text
- Limit findings to top 50 by severity
- Focus on actionable issues

**Accuracy:**
- Don't hallucinate missing sections
- Report absences accurately
- Use examples, not generic patterns

**Prioritization:**
- Constitution violations always CRITICAL
- Coverage gaps usually HIGH
- Terminology drift usually MEDIUM
- Style issues usually LOW

## After Analysis

**If you fix issues during analysis**, commit them:

```bash
git add [files-you-fixed]
git commit -m "Fix [N] issues found by analyze workflow

Issues resolved:
- [Issue 1]: [Fix]
- [Issue 2]: [Fix]

Remaining issues: [N] (see analysis report)
Next: [Re-run analyze|Begin implementation]"
```

**Analysis reports are artifacts** - show them to the user, but don't save as files unless requested.

**The git log is your work record. Don't create separate summary docs.**

## Next Steps

After analysis:
- **If CRITICAL**: Fix issues, re-run analysis
- **If HIGH**: Consider fixing before implementation
- **If MEDIUM/LOW**: Proceed, or add polish tasks

Ready to implement: Use `implement` workflow

---

**Remember:** This is quality assurance, not perfection seeking. 
The goal is to catch real problems before code is written.