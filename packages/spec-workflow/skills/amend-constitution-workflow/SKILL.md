---
name: amend-constitution-workflow
description: Amend the project constitution when implementation reveals a missing or incorrect constraint, often triggered by an ADR decision. Use when user says "this should be a constraint", "the constitution is wrong about X", "this ADR implies a rule", or "add this to the constitution".
---

# Constitution Amendment Workflow

## When to Use

- Implementation reveals a constraint that wasn't anticipated
- An ADR decision implies a rule that should be in the constitution
- An existing constraint turns out to be wrong or incomplete
- User says: "this should be a constraint", "add this to the constitution", "the constitution needs to say X"

**NOT for:** adding features, changing scope, or working around a constraint you don't want to follow. If the urge to amend is coming from "I want to do X but the constitution says no," that's scope creep — not an amendment.

## The Two Amendment Types

### Type 1: New constraint (most common)
Something emerged during implementation — usually from an ADR decision — that should be a standing rule.

*Example: You decide via ADR that all API calls must go through a service layer. That architectural decision implies a constraint: "No direct API calls from components." That belongs in the constitution.*

### Type 2: Incorrect constraint
An existing constraint is wrong — too broad, too narrow, or based on an assumption that turned out to be false.

*Example: Constitution says "No external dependencies" but you've now committed to using Dexie.js as a foundational choice. The constraint needs to be corrected, not worked around.*

## Amendment Process

### Step 1: Name the change clearly

State the proposed amendment in one sentence:
- "Add constraint: [X]"
- "Correct constraint: [old] → [new]"

If you can't state it in one sentence, it's not ready to be a constraint yet.

### Step 2: Identify the trigger

Where did this come from?
- **ADR decision** → name the ADR. The amendment is the downstream implication of that decision.
- **Implementation discovery** → describe what you found. Is this a real pattern or a one-time situation?
- **Conflict with existing constraint** → name the constraint and what's wrong with it.

### Step 3: Evaluate

For **new constraints**, ask:
- Does this apply globally (every session, every feature) or just to this situation?
- Is there already an ADR that covers this? (If so, the ADR may be sufficient — not every ADR needs a constitution entry)
- Would this constraint have changed earlier decisions if it had existed? (If yes, it's real — add it)

For **correcting constraints**, ask:
- Is the existing constraint genuinely wrong, or are you trying to work around it?
- What was the original reasoning? Does that reasoning still hold?
- Are there existing tasks or code that relied on the old constraint?

**If any of these raise doubts, discuss before amending.** Constitution changes should feel deliberate.

### Step 4: Apply the amendment

**For new constraints** — add to the appropriate section in `.specify/constitution.md`:
- A hard technology/architecture commitment → Hard Constraints
- Something the project will never do → Out of Scope
- A principle that guides decisions → Core Values (rare — values rarely emerge mid-project)

**For correcting constraints** — edit the existing entry in-place. Don't delete, rephrase.

### Step 5: Update `.claude/skills/`

Constitution is the source of truth, but `core.md` and `validator.md` are what get read during implementation. Update them to reflect the change:

**core.md:**
- New constraint → add to IS/ISN'T list and Common Violations
- Corrected constraint → update the relevant entry

**validator.md:**
- New constraint → add to Quick Validation Checklist and the relevant ADR violations section
- Corrected constraint → update the checklist and violation examples
- If a command can check the constraint, add or update its row in Mechanical Checks

Use the templates at `../constitution-workflow/references/` as reference for format if needed.

### Step 6: Check downstream impact

Run the **analyze-consistency-workflow** to check whether the amendment creates conflicts with the existing spec, plan, or tasks.

Common impacts:
- New constraint may invalidate tasks that were planned assuming it didn't exist
- Corrected constraint may free up or block approaches used in existing tasks

If analyze finds conflicts, resolve them before resuming implementation.

### Step 7: Commit

Suggest a commit message for Matt to review. A constitution amendment commit should explain what changed and why — future sessions will read this to understand how the project's constraints evolved.

```
Amend constitution: [constraint summary]

Trigger: [ADR-XXX / implementation discovery]
Change: [what was added or corrected]
Impact: [what this affects downstream, or "no downstream conflicts"]
```

## After Amendment

Return to wherever you were in the workflow:
- If triggered during implementation → resume at the task where you stopped
- If triggered during planning → re-run analyze before proceeding to tasks

## What This Skill Does NOT Handle

**Major scope changes** — if the amendment would change the purpose, core values, or success criteria significantly, that's a project pivot, not an amendment. Pause and discuss with stakeholders before proceeding.

**Spec/plan updates** — if the amendment cascades into spec or plan changes, handle those through their respective workflows (specify, plan) after running analyze.

## Output

Produces:
- Updated `.specify/constitution.md`
- Updated `.claude/skills/core.md`
- Updated `.claude/skills/validator.md`
- Analyze report confirming no downstream conflicts (or list of conflicts to resolve)
