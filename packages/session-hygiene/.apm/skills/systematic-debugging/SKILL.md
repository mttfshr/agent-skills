---
name: systematic-debugging
description: >
  4-phase root cause debugging process. Load automatically when user says anything
  is broken, not working, failing, throwing errors, or when a fix didn't help.
  Also trigger on: "still broken", "I don't know why", "I've tried X", "why is this happening".
  Prevents guess-and-check thrashing by enforcing evidence-first debugging.
---

# Systematic Debugging

## When to Use

Triggers: "it's not working", "this fix isn't helping", "I don't know why", "still broken after X", "I've been stuck on this"

**The rule:** If you haven't completed Phase 1, you cannot propose a fix. This is not optional.

Systematic debugging is faster than guess-and-check. It feels slower at the start. It isn't.

---

## The 4 Phases

### Phase 1: Evidence Gathering

**Do this before anything else. No exceptions.**

Ask these questions to build a complete picture:

1. **What exactly is the symptom?** Error message verbatim, or specific wrong behavior?
2. **Where does it break?** What's the last thing that works correctly?
3. **When did it start?** Was it ever working? What changed?
4. **What have you already tried?** List every fix attempted and its result.
5. **What does the environment look like?** Relevant config, dependencies, version info?

**Do not proceed to Phase 2 until you can answer all of these.**

If you're the one who has context on the codebase, provide this proactively — don't make me extract it question by question.

---

### Phase 2: Root Cause Tracing

Work backward from the symptom to the origin.

**The technique:** Starting from the visible failure, trace each step backward:
- What produced this output?
- What called that?
- What data/state fed into that call?
- Where did that data originate?

Keep going until you find where the system first diverged from expected behavior. That's the root cause — not the place where the error surfaces.

**Common traps:**
- Fixing where the error appears instead of where it originates
- Assuming the first suspicious thing is the cause
- Stopping when you find *a* problem instead of *the* problem

**Deliverable:** A clear statement of root cause with evidence. "The bug is in X because Y, which causes Z."

If you can't make that statement, you haven't found the root cause. Keep tracing.

---

### Phase 3: Fix and Verify

Only after completing Phase 2.

1. Propose a single fix targeting the root cause
2. Predict what should change after the fix
3. Apply the fix
4. Verify the prediction was correct, not just that the error message changed

**One fix at a time.** Multiple simultaneous changes mean you can't know what worked.

**STOP conditions — return to Phase 1 if:**
- The fix made no difference
- The fix changed the error but didn't resolve it
- A new unrelated symptom appeared
- You're not sure if it helped

**If 3 or more fixes have failed:** Don't try another fix. Go to Phase 4.5.

---

### Phase 4: Defense in Depth

After the fix works: add a layer so this class of bug is caught earlier next time.

This might be:
- A validation check at a component boundary
- A clearer error message at the point of failure
- A note in the code about the non-obvious constraint
- A test that would have caught this

Not every bug needs this. Use judgment. If you just spent 2 hours on it, it probably does.

---

## Phase 4.5: Architecture Question

**Trigger:** 3+ fixes have failed, or Phase 2 keeps finding new layers of the same problem.

Stop trying to fix. Ask instead:

> Is the problem that the code is wrong, or that the architecture is wrong?

Signs it's architectural:
- Every fix creates a new problem
- The root cause keeps moving
- The "right" fix would require changing too many things
- The system is doing something it was never designed to do

If it's architectural, fixes are symptoms management. The conversation shifts to: what would we need to change fundamentally?

**This is a decision to make together, not something to solve unilaterally.**

---

## Chat-Specific Notes

In chat, I can't run your code or read your logs directly. Phase 1 therefore depends on you providing good evidence. The more precisely you can describe the symptom and share relevant output, the faster we move through Phase 2.

If you're sharing error output, paste it verbatim rather than paraphrasing — the exact wording often matters.

For async/timing bugs specifically: describe the sequence of events, not just the end state. "It fails when X happens after Y" is much more useful than "it sometimes fails."

---

## Anti-Patterns (Violations of This Process)

- **Proposing a fix before completing Phase 1** — we don't have enough information yet
- **Trying two things at once** — we can't know which one helped
- **Declaring success because the error message changed** — verify the actual behavior
- **Adding logging/debugging code and then forgetting to remove it** — debugging artifacts become tech debt
- **Rationalizing a shortcut because the bug seems simple** — simple bugs have root causes too, and the process is fast for simple bugs

---

## After Resolution

When the bug is fixed, prompt Matt to commit before moving on. Suggest a commit message he can use or edit — don't commit on his behalf.

A good debugging commit message captures:
- What was wrong (not just what changed)
- The root cause in one sentence
- Optionally: why this wasn't caught earlier

This is the debugging session's artifact. It's worth taking 60 seconds to write it well.
