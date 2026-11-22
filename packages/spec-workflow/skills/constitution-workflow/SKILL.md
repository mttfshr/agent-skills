---
name: constitution-workflow
description: Guide to creating project constitutions - core values, constraints, and identity. Use when user wants to define project foundations.
---

# Constitution Creation Workflow

## When to Use
- Starting a new project
- User says: "create constitution", "define project values", "what should the constitution say"
- Before writing detailed specs

## What a Constitution Defines

A constitution is the **unchangeable foundation** of your project:
- **Purpose** - What the project does in one sentence
- **Core Values** - 3-5 principles that guide all decisions
- **Hard Constraints** - Technology/architecture choices that are committed
- **Out of Scope** - What this project will NOT do
- **Success Criteria** - How you'll know if it succeeds

## The Interactive Process

### 1. Ask Core Questions

**Be conversational, not a form. Ask one question at a time:**

**Project Identity:**
- What does this project do? (one sentence)
- Who is it for?
- What problem does it solve?

**Core Values (3-5 principles):**
- What matters most in this project?
- What trade-offs are you willing to make?
- What should never be compromised?

Examples of values:
- "Simplicity over features"
- "Performance over convenience"
- "Privacy over convenience"
- "Local-first, no dependencies"
- "Accessibility is not optional"

**Hard Constraints:**
- What technology choices are committed? (language, framework, database)
- What architectural decisions are locked?
- What deployment constraints exist?

**Out of Scope:**
- What will this NOT do?
- What features are explicitly rejected?
- What use cases are not supported?

### 2. Common Patterns by Project Type

**Web Apps:**
- Backend dependencies (serverless, traditional server, local-first)
- Authentication approach
- Data persistence strategy
- Frontend framework commitment

**CLI Tools:**
- Language and standard library only vs dependencies
- Configuration approach (flags, config files, interactive)
- Output format commitments (JSON, plain text, formatted)

**Libraries:**
- API stability promises
- Dependency philosophy (zero-dep, minimal, batteries-included)
- Breaking change policy

**Creative/Art Projects:**
- Technical constraints (real-time, offline, web-based)
- Interaction philosophy (generative, reactive, controllable)
- Output format (visual, audio, data)

### 3. Structure the Constitution

Use this template structure:

```markdown
# [Project Name] Constitution

**Created**: [Date]
**Project**: [project-name]

---

## Purpose

[One paragraph describing what this project does and why it exists]

---

## Core Values

[3-5 numbered principles that guide all decisions]

1. **[Principle name].** [Why this matters and what it means in practice]
2. **[Principle name].** [Why this matters and what it means in practice]
...

---

## Hard Constraints

[Committed technology and architecture decisions]

- **[Constraint].** [What this means]
- **[Constraint].** [What this means]
...

---

## Out of Scope

[Explicit rejections - what this project will NOT do]

- [Rejected feature/use case with brief reasoning]
- [Rejected feature/use case with brief reasoning]
...

---

## Success Criteria

[3-5 measurable outcomes that define success]

1. [Specific, testable criterion]
2. [Specific, testable criterion]
...
```

### 4. Write Constitution

Create `.specify/constitution.md` with the filled template.

### 5. Generate Project Identity Skills

Read the templates from this skill's `references/` folder:
- `references/core.md`
- `references/validator.md`
- `references/workflow.md`

Fill in each template from the constitution:

**core.md** — project identity, IS/ISN'T lists, locked ADRs, common violations, project path
**validator.md** — quick validation checklist, ADR violations to catch, scope creep patterns, and a **Mechanical Checks** table: for each hard constraint ask whether a command can check it (a test, a linter rule, a grep, a build step) and list those with their cost (cheap = every task, full = checkpoints); leave the rest as judgment items. Ask Matt rather than guessing commands.
**workflow.md** — replace `[PROJECT_NAME]` placeholders; this template rarely needs other changes

Create all three as `.claude/skills/core.md`, `.claude/skills/validator.md`, `.claude/skills/workflow.md` in the project directory.

## Example: Local-First Web App

```markdown
# studio-deck Constitution

**Created**: 2026-01-31
**Project**: studio-deck

---

## Purpose

A local-first web app for holistic studio session planning via a 6-category, 
card-based methodology. Helps artists create balanced sessions by making 
category coverage visible without enforcement.

---

## Core Values

1. **Suggest, never enforce.** Balance is visible, not mandated. Trust the user.

2. **The analog workflow is truth.** Every interaction should map to something 
   you could do with physical cards. If it only makes sense digitally, question it.

3. **User owns the prompts.** Prompts are in the user's words. App is a vessel,
   not a content provider.

4. **Mindfulness over productivity.** Not a task manager. Goal is attentive
   practice, not optimized output.

5. **Sessions are flexible.** No fixed duration, no auto-close, no streaks.

---

## Hard Constraints

- **No backend, no server.** All data in IndexedDB. No accounts, no sync.
- **Vue 3 + Dexie.js + Tailwind.** Committed stack for Phase 1-3.
- **Capacitor for iOS.** Web app IS the app. Single codebase.
- **Standalone distribution.** Not an Obsidian plugin.
- **Six categories fixed.** Users customize prompts, not categories.

---

## Out of Scope

- Productivity tracking, analytics, pattern detection
- Social features, sharing, collaboration
- Backend, accounts, data sync
- Obsidian plugin (revisit after standalone iOS ships)
- Enforcing balanced task lists
- Gamification, streaks, rewards
- Notifications or reminders

---

## Success Criteria

1. User can complete full session loop in under 2 minutes
2. Balance indicator shows missing categories without blocking actions
3. Incomplete tasks carry forward to next session automatically
4. Card browsing feels like physical cards, not scrolling
5. Can build and package as iOS app via Capacitor with no changes
6. User understands core loop within one session without onboarding
```

## Validation

Check that the constitution:
- [ ] Has a clear, one-sentence purpose
- [ ] Lists 3-5 core values with explanations
- [ ] Defines hard constraints (tech choices)
- [ ] Explicitly rejects out-of-scope features
- [ ] Includes measurable success criteria
- [ ] Contains no implementation details (those go in plan)
- [ ] Contains no specific features (those go in specs)

## Output

Creates:
- `.specify/constitution.md` - Full constitution (source of truth)
- `.claude/skills/core.md` - Project identity for enforcement (from template)
- `.claude/skills/validator.md` - ADR compliance checker (from template)
- `.claude/skills/workflow.md` - Session workflow (from template)

## Commit Your Work

After creating the constitution, suggest a commit message for Matt to review and edit before committing. A good constitution commit captures the core values, hard constraints, and out-of-scope decisions — the things that will govern all future work.

**The git log is your work record. Don't create separate summary docs.**

## Next Steps

After constitution:
- Write design research specs (optional but recommended)
- Write MVP spec with user stories
- Or create technical plan directly

---

**Remember:** Constitution is the foundation. It should rarely change. 
If you find yourself needing to change it, question whether you're adding 
the right feature.
