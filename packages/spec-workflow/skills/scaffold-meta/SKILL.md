---
name: scaffold-meta
description: Filesystem-based tools for the user's specification-driven development system. Use when the user says "use scaffold to..." for project setup or brownfield analysis. Workflow skills (constitution, specify, plan, tasks, amend-constitution, etc.) are already uploaded and auto-discover.
---

# Scaffold Meta-Skill

Provides access to **filesystem-based skills** that require Desktop Commander.

**Note:** Workflow skills (constitution, specify, clarify, plan, tasks, analyze, implement) are uploaded as custom skills and **auto-discover automatically** - you don't need this meta-skill to use them.

## System Location

**Locate the claude-scaffold repo before reading any skill files:**
- Use `$CLAUDE_SCAFFOLD_ROOT` if it is set
- Otherwise use `~/Github/claude-scaffold/` if it exists
- If neither exists, ask the user for the path

All skill file paths below are relative to that root.

## When to Use This Meta-Skill

### Trigger Pattern: "Use scaffold to..."

When the user says:
- **"Use scaffold to set up new project"** → project-scaffolder
- **"Use scaffold to analyze existing project"** → brownfield-analysis

### Or Specific Triggers:

- **"Set up new project"** → project-scaffolder
- **"Analyze existing project at [path]"** → brownfield-analysis

## Filesystem-Based Skills

These skills **cannot be uploaded** as custom skills because they require file operations.

### 1. Project Scaffolder

**Triggers:**
- "Use scaffold to set up new project"
- "Set up new project called [name]"
- "Initialize new project"

**What it does:**
- Reads templates from `templates/`
- Fills in placeholders interactively
- Creates `.claude/skills/` in project
- Creates project structure (STATUS.md, HANDOFF.md, etc.)

**Process:**
1. Locate the scaffold root (see System Location above)
2. Read: `skills/project-scaffolder/SKILL.md`
3. Read: `templates/core.md`, `templates/workflow.md`, `templates/validator.md`
4. Follow scaffolder instructions
5. Use Desktop Commander for all file operations

### 2. Brownfield Analysis

**Triggers:**
- "Use scaffold to analyze existing project"
- "Analyze existing project at [path]"
- "Document this codebase"
- "Reverse-engineer constitution from code"

**What it does:**
- Scans project directory structure
- Reads code files for patterns
- Mines git history for decisions
- Generates constitution from code
- Creates ADRs documenting decisions
- Two modes: documentation only (~30 min) or full migration planning (~1-2 hours)

**Process:**
1. Locate the scaffold root (see System Location above)
2. Read: `skills/brownfield-analysis/SKILL.md`
3. Follow analysis workflow
4. Use Desktop Commander to scan directories and read files
5. Generate constitution and ADRs

## Templates (Referenced by Project Scaffolder)

Located in `templates/` under the detected root:

- **core.md** - Project identity template (what project IS/ISN'T)
- **workflow.md** - Git-first workflow template
- **validator.md** - ADR compliance checker template

These are automatically read by project-scaffolder when initializing projects.

## Workflow Skills (Already Uploaded)

**You don't need this meta-skill to use these** - they auto-discover:

- constitution - Create project identity and `.claude/skills/` files
- amend-constitution - Amend constitution when implementation reveals new constraints
- specify - Write feature specs
- clarify - Resolve ambiguities
- plan - Create implementation plan
- tasks - Generate task list
- analyze - Validate consistency
- implement - Guide implementation

Just use their natural triggers:
- "create constitution"
- "amend constitution" / "add this as a constraint"
- "write spec"
- "create plan"
- etc.

## How to Invoke

### Simple Pattern (Recommended)

```
"Use scaffold to [action] [target]"
```

**Examples:**
- "Use scaffold to set up new project called my-app"
- "Use scaffold to analyze existing project at ~/Github/playa-events"

### Direct Pattern

```
"[Specific trigger phrase]"
```

**Examples:**
- "Set up new project"
- "Analyze existing project at ~/Github/my-app"

## What Happens When You Invoke

1. **Claude recognizes** the trigger pattern
2. **Claude locates** the claude-scaffold root
3. **Claude reads** the appropriate skill file using Desktop Commander
4. **Claude follows** the skill's workflow instructions
5. **Claude uses** Desktop Commander for all file operations
6. **Claude generates** outputs (constitutions, ADRs, project structures)

## Token Efficiency

- Load only the specific skill needed
- Don't load workflow skills (they're already uploaded)
- Read templates only when scaffolding

## Philosophy

**Separation of concerns:**
- **Uploaded skills** = Planning and validation workflows (auto-discover)
- **Filesystem skills** = Project setup and analysis (manual invoke via this meta-skill)

**Git-first:**
- All skills promote git commits over documentation
- Filesystem skills create initial structure, then git takes over

**Solo-optimized:**
- No branching complexity
- Sequential build on main
- Flat task lists

## Quick Reference

| Task | Command | Skill Used |
|------|---------|------------|
| Start new project | "Use scaffold to set up new project" | project-scaffolder |
| Document existing code | "Use scaffold to analyze existing project at [path]" | brownfield-analysis |
| Amend constitution | "amend constitution" / "add this as a constraint" | amend-constitution (uploaded) |
| Plan feature | "create constitution" (auto-discovers) | constitution (uploaded) |
| Write spec | "write spec" (auto-discovers) | specify (uploaded) |
| Generate tasks | "generate tasks" (auto-discovers) | tasks (uploaded) |

## Success Criteria

This meta-skill is working when:

✅ You can say "use scaffold to..." and the right skill loads
✅ The scaffold root is found on any machine
✅ Project scaffolder creates proper directory structure
✅ Brownfield analysis generates constitutions from code
✅ You don't need to remember file paths
✅ Workflow skills auto-discover without this meta-skill

---

**Remember:** This meta-skill is for **filesystem operations only**. Planning workflows are already uploaded and auto-discover.
