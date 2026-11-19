---
name: verification-before-completion
description: >
  Checklist to run before declaring work done. Load automatically when user says
  "it's working", "that fixed it", "I think that's done", "should be good now",
  or before wrapping up a task or session. Prevents premature completion and 
  ensures fixes actually solved the right problem.
---

# Verification Before Completion

## When to Use

Before saying "done." Before moving to the next task. Before ending a session on a positive note.

The rule: a fix isn't complete until you've verified the actual behavior, not just that the error message changed.

---

## The Checklist

### 1. Does it do the right thing?

Test the specific scenario that was broken. Not a related scenario — the exact one.

- [ ] The original problem is gone
- [ ] The behavior matches what was expected, not just "no error"
- [ ] You tested it in the context where it failed, not just in isolation

### 2. Did you break anything adjacent?

Changes have neighbors. Quickly check:

- [ ] Functionality that touches the same code still works
- [ ] No new errors or warnings appeared
- [ ] If you changed a shared utility/component, other callers still behave correctly

### 3. Is the fix complete or a patch?

- [ ] You fixed the root cause (not just suppressed the symptom)
- [ ] There's no obvious path to the same failure recurring
- [ ] If it's a patch (intentional), you noted why in the code or commit

### 4. Is the code in a committable state?

- [ ] No debug output left in (console.log, var_dump, die(), etc.)
- [ ] No commented-out code added during debugging
- [ ] No hardcoded test values or temporary overrides

---

## If Any Box Is Unchecked

Don't move on. That unchecked box is the next thing to address.

It's common to fix the presenting symptom and feel done — then discover the root cause is still there, or that something else broke. The checklist is specifically for catching that moment before it becomes the next session's mystery.

---

## After Verification

Prompt Matt to commit before moving to the next task. Suggest a commit message he can review and edit.

A verification commit should describe what works now, not just what changed. "Users can now reset password via email" is more useful than "Fix password reset bug."
