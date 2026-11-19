---
name: [PROJECT_NAME]-workflow
description: Git-based session workflow for [PROJECT_NAME] development. Use when starting a new session, when user says "checkpoint" or "document this", or when managing session continuity. Enforces git commits as primary documentation with minimal file updates.
---

# [PROJECT_NAME] Development Workflow

Git commits are primary documentation (16x more efficient than doc edits).

## Session Initialization

When starting a new session:

1. **Read git history**
   ```bash
   git log -1
   ```
   Tells you: last session number, what was done, what's next

2. **Read HANDOFF.md** (if exists)
   - 3-5 lines maximum
   - Format: "Working on: X, Status: Y, Next: Z"
   - Only exists if session was interrupted

3. **Confirm understanding with user**
   ```
   Based on git log, last session was [N]: [summary]
   HANDOFF.md says: [current task]
   
   Ready to work on [specific next step]. Should I proceed?
   ```

4. **Begin work** - load other skills only if needed

## During Work

### Primary Documentation: Git Commits

After each meaningful change:

```bash
git add -A
git commit -m "Session N: What you did

Changes:
- Specific change 1
- Specific change 2

Status: Current state
Next: What to do next"
```

**For work-in-progress:**
```bash
git commit -m "WIP: Feature X - completed Y, still need Z"
```

### Commit Message Quality

✅ Good commit messages:
- Start with Session number (or date, or clear identifier)
- Clear summary of what changed
- List specific changes
- State current status
- Indicate what's next

❌ Bad commit messages:
- "Update files"
- "WIP"
- "Fixed stuff"

## Checkpoint Commands

User may trigger documentation updates:

**"Checkpoint"** → Update HANDOFF.md immediately:
```
Working on: [current feature]
Status: [what's done]
Next: [what's needed]
```
Keep to 3-5 lines max.

**"Document this"** → Add to appropriate file (ask which)

**"ADR this decision"** → Create new ADR in docs/decisions.md

**"Update priorities"** → Revise HANDOFF.md based on completed work

## Documentation Protocol

### Primary: Git Commits
- Use for session history (always)
- 16x more efficient than doc edits
- Immutable record of what happened

### Minimal: File Updates
Only update files when:

**Update HANDOFF.md when:**
- User says "checkpoint"
- Starting new major feature
- Session gets interrupted
- Never: at end of normal session

**Update STATUS.md when:**
- Major milestone reached
- Never: every session, small changes

**Update decisions.md when:**
- Making new architectural decision
- User says "ADR this decision"
- Never: for implementation details

**Update [OTHER_DOCS] when:**
- [SPECIFIC TRIGGER]
- Never: [ANTI-PATTERN]

### Use Artifacts For:
- Session summaries
- Testing guides
- Implementation plans
- Let user decide if/where to save

### Never Create:
- ❌ SESSION_N_*.md files
- ❌ 10+ doc edits per session
- ❌ Duplicate info (git + files)
- ❌ >20% session time on docs

## Project Structure

```
[PROJECT_NAME]/
├── STATUS.md          # Single source of truth (update at milestones)
├── HANDOFF.md         # Session continuity (3-5 lines)
├── docs/
│   ├── decisions.md   # ADRs (update for new decisions)
│   └── ...
└── [MAIN_DIR]/        # Current work
```

## Session End

Normal end (no interruption):
1. Make final commit with clear "Next:" section
2. Do NOT update HANDOFF.md
3. Do NOT update STATUS.md (unless milestone)

Interrupted session:
1. Commit WIP
2. Update HANDOFF.md (3-5 lines)
3. User will read on return

## Verifiable Assertions Only

Always reference actual documentation:

✅ "According to git log, Session 12 implemented..."
✅ "HANDOFF.md indicates current focus is..."
✅ "docs/decisions.md establishes ADR-011..."

❌ "We're 70% complete" (no evidence)
❌ "I completed X" (without commit reference)
❌ "We decided Y" (without ADR reference)

## Token Efficiency Note

This workflow saves tokens:
- Git log is read once per session
- HANDOFF.md is 3-5 lines (not 50+)
- No duplicate documentation
- Enables more development per conversation
