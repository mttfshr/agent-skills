---
name: finishing-a-session
description: >
  Structured end-of-session ritual. Load automatically when user says "I'm done 
  for now", "let's stop here", "wrapping up", "good stopping point", "I need to 
  go", or "let's call it". Ensures clean handoff state and useful git history 
  before the session ends.
---

# Finishing a Session

## When to Use

When work is stopping — end of day, context switch, natural stopping point. The goal is to leave the codebase and your future self in the best possible state.

---

## The Session Close

Work through these in order. Each one is a question to answer together.

### 1. What state is the code in?

- **Working and complete** → ready to commit and close
- **Working but mid-feature** → commit what's working, note what's next
- **Broken/mid-change** → don't leave it here; either finish or revert to last working state

Don't leave the codebase broken between sessions. Future-you will lose 20 minutes reconstructing the context.

### 2. Is everything uncommitted work accounted for?

- [ ] Changes you want to keep are committed (or staged with intention)
- [ ] Debug artifacts are removed (see verification-before-completion)
- [ ] No uncommitted work you'll forget about

If there are uncommitted changes, decide now: commit them, stash them, or revert them.

### 3. What's the commit message?

Suggest a message for Matt to review and edit. A good session-closing commit captures what was accomplished, not just what files changed.

If multiple logical units of work happened this session and aren't yet committed separately, this is the moment to break them apart. A single "did a bunch of stuff" commit is harder to use as memory later.

### 4. Is any work midstream?

Before writing the State line, list every workstream started and not finished, including non-module work (evals, skills, refactors, spikes, docs). For each, record what is done, where it stopped, the next step, and any decision it waits on. Put these under a labeled **In progress** line at the top of the State block. "No active module" is not the same as nothing in progress.

Last check: reread State against the newest dated entry. A thread that appears in the entry but not in State is a miss.

### 5. What's next?

Capture the next step explicitly — one sentence is enough. The canonical place for this is **HANDOFF.md** in the project root (or STATUS.md for broader progress). The implement-workflow uses these files as session memory; keeping them current means the next session starts with zero reconstruction overhead.

If the project doesn't use HANDOFF.md yet, a clear next-step line in the commit message is the minimum. But HANDOFF.md is better.

### 6. Any loose threads worth noting?

Things discovered during this session that aren't in the plan yet:
- Unexpected behaviors to investigate
- Shortcuts taken that need revisiting
- Architectural questions that surfaced

These don't need to be resolved now, but they should be written down somewhere before they're forgotten.

### 7. Are the status claims grounded?

Before saying anything is closed, done, passing or unblocked, check it against its source instead of memory:

- Name the source: a ticked task, a log path, a commit, a tracking-doc row. If you didn't open it this session, say "per the docs" or "not verified".
- Reconcile every tracking doc the project keeps (plan, gates/blockers list, task file) so none still lists the thing as open. Grep for it; don't trust recall.
- Label anything inferred (worked out, not observed) as inferred.

For the f_ project the files are `.specify/gates.md`, `.specify/plan.md` and the module's `tasks.md`, and `tests/build/test_gates.py` flags a stale gate row (see its CLAUDE.md, "Claims").

### 8. Are the open lists free of closed items?

The start-of-session files (HANDOFF.md "START HERE", plan "Next" and "Owed") hold lists of OPEN items. The usual slip: when something closes, its bullet gets rewritten in place ("X closed, Matt says it passes") and stays under "Candidates" or "Next", so the next session reads a finished item as work to do.

When an item closes, MOVE it, don't edit it in place:

- Delete its bullet from every open list (HANDOFF "Candidates", plan "Next", plan "Owed to Matt", gates "Waiting") and write it once under the closed list (HANDOFF "State: closed ...", plan "Closed ...").
- Keep only what is still open from a mixed bullet (e.g. "X closed; Y still needs a name" becomes just the Y line under open items).
- Renumber the list and fix any "see Next 2" style cross-references the move breaks.
- Last check, by reading and not by memory: take each item closed this session and grep HANDOFF.md, plan.md and gates.md for it. Anything found under an open heading is a miss.
- Also look for decisions made this session that changed a doc elsewhere (descriptions in README / launch menu / help text, type lines in reference docs): list the places and say which were updated.

---

## Closing Questions

Before ending:

> "Anything else you want to capture before we close out?"

This is a prompt for Matt, not a checklist item — sometimes there's context that doesn't fit the above categories but matters for next time.

---

## What Good Session Hygiene Produces

Over time, consistent session closes mean:
- Git log is a useful narrative of the project, not just a list of saves
- Sessions start fast because context is always explicit
- Nothing important lives only in your head or in the chat history
