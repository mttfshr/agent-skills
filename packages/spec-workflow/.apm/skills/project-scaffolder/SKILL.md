---
name: project-scaffolder
description: Automates creation of Claude skills and project structure for new projects. Use when user says 'set up new project', 'scaffold a project', 'create project structure', 'initialize skills', or 'start a new project with skills'.
---

# Project Scaffolder

Automates creation of Claude skills and project structure for new projects.

## What This Skill Does

1. Asks clarifying questions about the project
2. Reads templates from `../constitution-workflow/references/`
3. Fills in placeholders interactively
4. Creates Claude skills in appropriate locations
5. Initializes project documentation structure

## Interactive Scaffolding Process

### Step 1: Gather Project Information

Ask the user these questions (be conversational, not a form):

**Required:**
- Project name (e.g., "weather-dashboard", "mattfisher-io")
- Project location (absolute path, e.g., ~/Github/my-project)
- Primary purpose (one sentence: what does it do?)
- Project type (web app, CLI tool, library, data project, creative, etc.)

**Optional (can infer or set defaults):**
- 3-5 key characteristics (what it IS)
- 3-5 anti-patterns (what it ISN'T)

### Step 2: Read Templates

Use Desktop Commander to read:
```
../constitution-workflow/references/core.md
../constitution-workflow/references/workflow.md
../constitution-workflow/references/validator.md
```

### Step 3: Fill Templates

Replace placeholders based on user's answers:

**In core.md:**
- `[PROJECT_NAME]` → project name
- `[ONE-LINE PROJECT DESCRIPTION]` → primary purpose
- `[PRIMARY_PURPOSE]` → primary purpose (same)
- `[KEY_CHARACTERISTIC 1-4]` → from user or inferred
- `[ANTI-PATTERN 1-5]` → from user or inferred
- `[PATH]/[PROJECT_NAME]` → actual project path

**In validator.md:**
- `[PROJECT_NAME]` → project name
- `[KEY_PRINCIPLE 1-4]` → inferred from characteristics
- `[MOST COMMONLY VIOLATED]` → infer based on project type
- `[PRIMARY PURPOSE]` → primary purpose

**In workflow.md:**
- `[PROJECT_NAME]` → project name
- Leave most of workflow.md unchanged (it's universal)

### Step 4: Create Skill Files

Use Desktop Commander to create:

**Global skills (always available):**
```
~/.claude/skills/<project-name>/
├── core.md
├── workflow.md
└── validator.md
```

**Project skills (project-specific):**
```
<project-path>/.claude/skills/
├── core.md
├── workflow.md
└── validator.md
```

### Step 5: Initialize Project Documentation

Create basic project structure:

```
<project-path>/
├── STATUS.md
├── HANDOFF.md
├── docs/
│   └── decisions.md
└── .claude/
    └── skills/
```

**STATUS.md initial content:**
```markdown
# <Project Name>

**Created**: <date>
**Purpose**: <primary purpose>

## Current Status

**Phase**: Project initialization
**Session**: 1

## What's Built

- Project structure initialized
- Claude skills configured
- Documentation framework created

## Next Steps

1. Define initial architectural decisions (ADRs)
2. Set up development environment
3. Begin implementation

## Architecture Overview

See `docs/decisions.md` for architectural decisions.
```

**HANDOFF.md initial content:**
```markdown
Working on: Project initialization
Status: Skills configured, ready to start development
Next: Define first ADR or begin implementation
```

**docs/decisions.md initial content:**
```markdown
# Architectural Decision Records

## ADR-001: <First Decision>

**Status**: Draft
**Date**: <date>

### Context
[Why this decision is needed]

### Decision
[What we decided]

### Consequences
[What this means for the project]

---

*Add new ADRs below as architectural decisions are made*
```

### Step 6: Confirmation

After creating all files, show the user:
1. What was created and where
2. Next steps to customize
3. How to test the skills

## Smart Defaults by Project Type

### Web App
**IS:**
- User interface, interactive application
- Frontend or full-stack architecture
- Responsive design, accessibility

**IS NOT:**
- Backend-only service, API only
- Desktop application, mobile native app
- Static site, documentation site

**Common violations:**
- Tight coupling between UI and logic
- No error boundaries
- Missing loading states
- Poor accessibility

### CLI Tool
**IS:**
- Command-line utility, automation script
- Developer tool, system utility
- Text-based interface

**IS NOT:**
- GUI application, web service
- Background daemon, system service
- Interactive TUI (if it's simple CLI)

**Common violations:**
- Poor error messages
- No --help documentation
- Assuming environment
- Silent failures

### Library/Package
**IS:**
- Reusable code, well-documented API
- Minimal dependencies, focused scope
- Versioned, backwards compatible

**IS NOT:**
- Application, end-user tool
- Framework, opinionated structure
- Complete solution

**Common violations:**
- Application logic in library
- Breaking changes without major version
- Undocumented public API
- Global state or side effects

### Data/Analysis Project
**IS:**
- Reproducible analysis, documented process
- Version-controlled data and code
- Jupyter notebooks or scripts

**IS NOT:**
- Production pipeline, real-time system
- Interactive dashboard, web app
- Database or data warehouse

**Common violations:**
- Hardcoded paths
- Missing data provenance
- Undocumented assumptions
- Non-reproducible results

### Creative/Art Project
**IS:**
- Creative exploration, experimentation
- Visual/audio output, generative systems
- Process-oriented, iterative

**IS NOT:**
- Production tool, client deliverable
- Framework for others
- Fully polished product

**Common violations:**
- Over-engineering creative code
- Premature optimization
- Hiding the process
- Too much abstraction

## Example Interaction

```
User: "Let's set up a new project"

Claude: "I'll help you scaffold a new project with Claude skills! 

What's the project called? (e.g., weather-dashboard, my-blog)"

User: "food-tracker"

Claude: "Great! Where should this project live? (full path)"

User: "~/Github/food-tracker"

Claude: "Perfect. What does food-tracker do in one sentence?"

User: "Track what I eat daily with calorie estimates"

Claude: "Got it - a food tracking app. Is this a:
1. Web app
2. Mobile app  
3. CLI tool
4. Something else?"

User: "Web app"

Claude: [reads templates, fills in smart defaults]

"I'll set this up as:

**What food-tracker IS:**
- Daily food tracking with calorie estimates
- Web-based application
- Personal health tool
- Simple data entry and tracking

**What food-tracker IS NOT:**
- Social platform or food sharing
- Recipe database or meal planning
- Nutritionist advice or medical tool
- Complex analytics dashboard

**Common violations I'll watch for:**
- Feature creep (meal planning, social features)
- Overcomplicated UI
- Medical advice or health claims
- Database of all foods (vs simple tracking)

Does this sound right? Any adjustments?"

User: "Yes, perfect"

Claude: [creates all files]

"✅ Project scaffolded! Created:

**Skills:**
- ~/.claude/skills/food-tracker/ (global)
- ~/Github/food-tracker/.claude/skills/ (project)

**Documentation:**
- ~/Github/food-tracker/STATUS.md
- ~/Github/food-tracker/HANDOFF.md
- ~/Github/food-tracker/docs/decisions.md

**Next steps:**
1. cd ~/Github/food-tracker
2. claude (skills will load automatically)
3. Start defining your first ADR or begin implementation

Want me to help you define your first architectural decision?"
```

## Error Handling

If templates don't exist:
- Check ../constitution-workflow/references/ exists
- Provide helpful error message
- Suggest reinstalling the package: `apm install`

If project directory doesn't exist:
- Ask if should create it
- Create with mkdir -p if confirmed

If skills already exist:
- Warn about overwriting
- Ask for confirmation
- Offer to back up existing skills

## Token Efficiency

This skill should be efficient:
- Only load when user wants to scaffold
- Don't load full templates into context (read as needed)
- Use Desktop Commander to read/write files
- Keep interaction conversational, not verbose

## Success Criteria

User should be able to:
1. Say "set up new project" → Get fully configured project
2. Answer 3-4 questions → Get smart defaults
3. Start working immediately with skills active
4. Have proper documentation structure ready

No bash scripts, no manual file editing, no copying templates.
Just conversation → working project.

---

## UPDATED: Two Planning Approaches

The scaffolder now supports BOTH quick start and Spec Kit planning:

### Approach A: Quick Start (5 minutes)
- Interactive questions
- Fill templates directly
- Start coding immediately
- Best for: Simple projects, solo work, exploration

### Approach B: Spec Kit Planning (solo-adapted, 1-2 hours)
- Create Constitution via `specify init` + `specify constitution`
- Write a single unified spec with user stories ordered as a build sequence
- Write a flat ordered task list (`tasks.md`) defining the full src/ structure before coding
- Extract to skills when ready
- Build sequentially on main — each story is a testable checkpoint, not a branch
- Best for: Complex projects, deep planning, solo development

See `spec-kit-wrapper` skill for full details on the adapted workflow.

### Choosing Approach

When user says "set up new project", ask:

```
"How would you like to plan this project?

A) Quick start - I'll ask a few questions, we start coding in 5 minutes
B) Spec Kit planning - Structured specification phase first (1-2 hours)

Which approach? (Your preference is architecture discussion before coding)"
```

### If User Chooses Spec Kit

1. Run `specify init` + `specify constitution` (interactive Constitution creation)
2. Write unified spec: all user stories ordered by dependency, each with an Independent Test
3. Write tasks.md: flat ordered task list across phases, defining full directory structure upfront
4. Extract to `.claude/skills/` (core.md, validator.md, workflow.md, decisions.md)
5. Build sequentially on main, committing at each phase checkpoint

### Handoff Between Phases

**Planning Phase** (Spec Kit in .specify/)
↓
**Extraction** ("Extract spec into skills")
↓
**Implementation Phase** (Sequential build on main, skills enforcing spec)
↓
**Maintenance** (Git commits at checkpoints + validator updates)

This satisfies the preference to "discuss architecture and strategy before writing code" while keeping the solo build process linear and low-overhead.
