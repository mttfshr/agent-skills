---
name: implement-workflow
description: Guide for sequential implementation of tasks. Use when user wants to start building or needs guidance on implementation approach.
---

# Implementation Workflow

## When to Use
- Ready to start building
- User says: "start implementation", "begin building", "let's implement", "start phase 1"
- After tasks are generated and analyzed

## Sequential Build Philosophy

Build one complete phase at a time, testing at each checkpoint.

**Not parallel development** - This is optimized for solo work:
- Complete Phase 0 (Setup) → Verify checkpoint
- Complete Phase 1 (Foundational) → Verify checkpoint
- Complete Phase 2 (User Story 1) → Verify checkpoint
- Complete Phase 3 (User Story 2) → Verify checkpoint
- Continue until feature complete

**All work on `main` branch** - No feature branches:
- Commit after each task or logical group
- Each commit should leave code in working state
- Phase checkpoints are natural stopping points

## The Implementation Process

### Step 1: Load Context

Read:
- `.specify/tasks.md` - Ordered task list
- `.specify/plan.md` - Technical approach
- `.claude/skills/validator.md` - Architecture constraints
- `.specify/constitution.md` - Values and hard constraints

### Step 2: Verify Prerequisites

Before starting Phase 0:
- [ ] Project directory exists
- [ ] Git initialized
- [ ] Constitution, spec, plan, tasks all complete
- [ ] Development environment ready

### Step 3: Work Through Phases Sequentially

#### For Each Phase:

1. **Read phase description**
   - Understand the goal
   - Note the checkpoint criteria
   - Identify which user story (if applicable)

2. **Work through tasks in order**
   - Tasks are already dependency-ordered
   - Tasks marked [P] can be done in any order within that set
   - Complete each task before moving to next (unless [P])

3. **For each task:**
   ```
   a. Read task description and file path
   b. Implement the task
   c. Test that it works
   d. Check .claude/skills/validator.md: does this task touch any constraint?
      If yes, verify compliance before committing
      Run the cheap Mechanical Checks from validator.md (if it has that section)
   e. Suggest commit message: "[T###] Description"
   f. Move to next task
   ```

4. **At phase checkpoint:**
   - Run the phase's **Verify** (its checkpoint line in tasks.md): `command:` or `test:` run it and read the result; `manual:` say exactly what Matt should look at, then stop and wait for him; `none yet` stop and say so
   - Run all validator.md **Mechanical Checks** (cheap ones also run after every task)
   - Record each result with its method (command output, test log, or "Matt looked"); never report a check as passed without one
   - Run validator.md against the completed phase — scan for any constraints the phase touched
   - Use the **verification-before-completion** checklist before declaring the phase done
   - Verify all acceptance criteria pass
   - If checkpoint fails, fix before proceeding — use systematic-debugging if the cause isn't clear
   - Suggest a checkpoint commit for Matt to review
   - Move to next phase

### Step 4: Task Execution Pattern

**For implementation tasks:**
```bash
# Example: T012 [P] [US1] Create User model in src/models/user.py

1. Create file: src/models/user.py
2. Implement User model per spec requirements
3. Test: Can instantiate, fields exist, validation works
4. Commit: "[T012] Create User model"
```

**For parallel tasks ([P]):**
```bash
# Example: T005 [P] and T006 [P] can be done in any order

T005: Configure Tailwind
T006: Install Dexie

# Do either first, both will work
```

**For integration tasks (no [P]):**
```bash
# Example: T015 [US1] Implement UserService (depends on T012 User model)

# MUST do T012 first (User model)
# THEN do T015 (UserService that uses User model)
```

### Step 5: Validator Integration

Before committing significant changes:

```
"Validate against ADRs" or "Check architecture constraints"
```

Claude will check your changes against:
- Constitution values
- Hard constraints
- Common violations
- ADR compliance

### Step 6: Status Updates

Update STATUS.md regularly:

```markdown
# Project Status

**Last Updated**: 2026-02-01
**Current Phase**: Phase 2 (User Story 1)
**Session**: 3

## Progress

- [x] Phase 0: Setup (Checkpoint passed)
- [x] Phase 1: Foundational (Checkpoint passed)
- [x] Phase 2: US1 - Tasks T012-T015 complete
- [ ] Phase 2: US1 - Tasks T016-T017 remaining
- [ ] Phase 3: US2 (Not started)

## What Works

- Database initialized with schema
- Categories seeded correctly
- User model implemented and tested
- UserService partially complete

## Next Steps

1. Complete T016 (validation)
2. Complete T017 (logging)
3. Run Phase 2 checkpoint
4. Begin Phase 3 if checkpoint passes
```

Update HANDOFF.md when context-switching:

```markdown
# Handoff

**Status**: Mid-implementation, Phase 2
**Working on**: User Story 1 - User management
**Last commit**: "[T015] Implement UserService"

## What's Working
- Setup and foundational phases complete
- User model fully implemented
- UserService partially done

## What's Next
- Complete T016: Add validation to UserService
- Complete T017: Add logging
- Run Phase 2 checkpoint

## Blockers
None

## Notes
UserService needs validation for email format before it's complete.
```

### Step 7: Checkpoint Verification

When phase checkpoint is reached:

1. **Run all checkpoint tests:**
   - The checkpoint's Verify line first; manual testing only where it says `manual:`
   - Automated tests if they exist
   - Visual verification for UI components

2. **If checkpoint passes:**
   ```bash
   git add .
   git commit -m "Checkpoint: Phase N complete"
   ```

3. **If checkpoint fails:**
   - Fix the issue
   - Re-test
   - Don't proceed until it passes
   - Checkpoints prevent compound failures

### Step 8: MVP Decision Point

After completing User Story 1 (usually Phase 2):

**Stop and evaluate:**
- Is US1 independently valuable?
- Does it satisfy the core need?
- Should we deploy/demo before adding more?

**Options:**
1. **Stop here** - US1 is MVP, ship it
2. **Continue** - Add US2 for more value
3. **Refine** - Improve US1 before expanding

This is where solo workflow shines - you control the pace.

## Working Patterns

### Deep Work Session

```
1. Load tasks.md
2. Pick a phase
3. Work through all tasks in that phase
4. Hit checkpoint
5. Commit and update status
6. Take break or continue to next phase
```

### Interrupted Session

```
1. Check HANDOFF.md for last state
2. Pick up where you left off
3. Complete current task
4. Update HANDOFF.md before stopping
5. Next session starts from HANDOFF.md
```

### Discovery During Implementation

**If you discover something that invalidates the plan:**

1. Stop implementation
2. Update affected artifact (spec, plan, or tasks)
3. Re-run analyze workflow
4. Regenerate tasks if structure changed
5. Resume implementation with updated tasks

**If you discover something that should change the constitution:**

1. Stop implementation
2. Use the **amend-constitution** workflow to evaluate and apply the change
3. Re-run analyze workflow to check downstream impact
4. Resume implementation

**Don't push through with wrong plan** - fix the foundation first.

## Common Situations

### "Something broke during implementation"

Stop and use the **systematic-debugging** skill before trying fixes. Don't guess-and-check — gather evidence first, trace the root cause, then propose a single targeted fix.

### "This task is unclear"

Ask Claude: "Clarify task T###"

Claude will check:
- Spec requirements for that story
- Plan architecture for that component
- Related tasks for context

Then provide clarification or suggest task improvement.

### "Architecture feels wrong"

Run: "Validate against ADRs"

Claude will check if your approach violates:
- Constitution constraints
- Architectural decisions
- Common anti-patterns

### "Should I refactor now or later?"

**Rule of thumb:**
- Refactor now if: Breaking a hard constraint, will compound, blocking progress
- Refactor later if: Style improvement, nice-to-have, time pressure
- Add to Polish phase tasks if deferring

### "Task is bigger than expected"

Two options:
1. **Break it down**: Commit partial progress with descriptive messages
2. **Update tasks**: Split into multiple tasks, re-number

Choose #1 for minor underestimation, #2 for major scope discovery.

## Git Commit Strategy

After each task or logical group, suggest a commit message for Matt to review and edit. A good task commit names the task ID and what it accomplishes — not just what files changed.

**Task commits:** `[T###] Description of what this implements`
**Checkpoint commits:** `Checkpoint: Phase N complete — [what works now]`
**Discovery commits:** `Update: [what changed and why it was needed]`

## Success Criteria

You're doing it right if:
- ✅ Each phase checkpoint passes before moving on
- ✅ Git history shows steady progress (commits every session)
- ✅ STATUS.md accurately reflects current state
- ✅ No constitution violations accumulating
- ✅ Each user story is independently testable

You need to adjust if:
- ❌ Multiple checkpoints failing in a row
- ❌ Long periods without commits (task too big)
- ❌ Accumulating technical debt
- ❌ Plan-reality mismatch growing
- ❌ Lost track of what's working

**The git log is your implementation history. Don't create separate progress docs.**

## Output

Produces:
- Working code in `src/` (or equivalent)
- Git history documenting progress
- Updated HANDOFF.md only if interrupted
- Each phase checkpoint verified

## Next Steps

After implementation complete:
- Review against success criteria from spec
- Document lessons learned
- Update constitution if patterns emerged
- Consider assessment: "Assess my understanding"

---

**Remember:** Sequential build on main means each commit should leave things working.
Checkpoints are your safety net - don't skip them.