---
name: plan-workflow
description: Create technical implementation plan from specification. Use when user wants to plan implementation or define architecture.
---

# Implementation Planning Workflow

## When to Use
- After spec is complete and clarified
- User says: "create plan", "plan implementation", "what's the architecture", "how should we build this"

## What a Plan Contains

The plan defines HOW to build what the spec describes.

**Key sections:**
1. Technical Context (stack, tools, constraints)
2. Project Structure (directories, files)
3. Architecture Decisions
4. Data Model (if applicable)
5. Implementation Phases

## The Planning Process

### Step 1: Load Constitution and Spec

Read:
- `.specify/constitution.md` - Tech constraints, values
- `.specify/spec.md` - What to build

### Step 2: Define Technical Context

Based on project type and constitution, specify:

**Language/Framework:**
- Primary language and version
- Framework (if applicable)
- Why this choice fits the project

**Dependencies:**
- Core libraries needed
- Rationale for each dependency
- Alignment with constitution values

**Storage:**
- Where data lives
- Why this approach

**Testing:**
- Test framework
- Testing strategy

**Platform:**
- Target environment
- Browser/OS/device requirements

**Example:**
```markdown
## Technical Context

**Language**: JavaScript ES2022
**Framework**: Vue 3 (Composition API)
**Storage**: IndexedDB via Dexie.js  
**Testing**: Vitest for unit tests
**Platform**: Modern browsers (Chrome, Firefox, Safari)
**Build Tool**: Vite

**Stack Rationale**:
- Vue 3: Constitution requires reactive UI, Vue provides this with minimal overhead
- Dexie.js: Simplifies IndexedDB, aligns with "local-first" constraint
- Vite: Fast development, production-ready builds

**Constraints from Constitution**:
- No backend allowed → All logic client-side
- Local-first → IndexedDB only, no API calls
- iOS packaging → Must work as Capacitor web view
```

### Step 3: Define Project Structure

Map user stories to directory structure.

**Show complete tree:**
```
src/
├── main.js                      # Entry point
├── App.vue                      # Root component
├── db/
│   ├── index.js                 # Dexie schema (US1: data layer)
│   └── seed.js                  # Initial data (US1: categories)
├── composables/
│   ├── useDatabase.js           # DB singleton
│   ├── useSession.js            # US2: session state
│   └── useTasks.js              # US3: task management
└── components/
    ├── StartScreen.vue          # US2: session start
    ├── SessionView.vue          # US2: active session
    ├── TaskList.vue             # US3: task display
    └── BalanceIndicator.vue     # US5: balance visual
```

**Explain key decisions:**
- Why this structure fits the domain
- How it maps to user stories
- Where each feature's code lives

### Step 4: Data Model (if applicable)

Define entities, relationships, and constraints.

**For each entity:**
```markdown
### [Entity Name]

**Purpose**: [What it represents]

**Fields**:
- `id` (primary key): Auto-generated UUID
- `field1`: Type, constraint
- `field2`: Type, constraint

**Relationships**:
- Belongs to / Has many / References

**Indexes**:
- Which fields need indexes for queries

**Lifecycle**:
- When created
- When updated
- When deleted
```

**Example:**
```markdown
### Session

**Purpose**: Container for a planning session

**Fields**:
- `id`: Auto-generated UUID (primary key)
- `status`: String, one of ['active', 'closed']
- `startedAt`: ISO timestamp
- `closedAt`: ISO timestamp or null

**Relationships**:
- Has many Tasks (via sessionId foreign key)
- Has zero or one Reflection (via sessionId foreign key)

**Indexes**:
- `status` (for finding active session)

**Lifecycle**:
- Created when user starts session
- Updated when user closes session
- Never deleted (kept as history)
```

### Step 5: Architecture Decisions

Document key technical decisions:

**Format:**
```markdown
### [Decision Name]

**Context**: [Why this decision is needed]

**Decision**: [What we decided]

**Rationale**: [Why this choice]

**Alternatives Considered**:
- [Option 1]: Why rejected
- [Option 2]: Why rejected

**Consequences**:
- Positive: [Benefits]
- Negative: [Tradeoffs]
```

### Step 6: Dependency Block Analysis (Natural Pause Points)

**If the plan is complex (5+ user stories), map dependency blocks as natural checkpoints for verification.**

This provides pause points where you can verify intent and direction before proceeding.

**For each major feature group, document:**

```markdown
## Dependency Blocks

### Block 1: [Name] (e.g., Data Foundation)

**Dependencies**: None (or what must exist first)
**Builds**: [What components/features this creates]
**Why this block**: [Brief rationale for the dependency]
**Verification checkpoint**: [How to verify this block works before proceeding]

**Example:**
```markdown
### Block 1: Data Foundation
**Dependencies**: None
**Builds**: Database schema, categories table, seed data
**Why this block**: Nothing else can work without data layer
**Verification checkpoint**: Can create, read, update, delete categories
```

### Block 2: [Name] (e.g., Session Container)
**Dependencies**: Block 1 (needs database)
**Builds**: Session state machine, session UI shells
**Why this block**: Tasks need sessions to belong to
**Verification checkpoint**: Can start and close sessions, session persists across reloads
```

**This helps:**
- Identify natural pause points for user verification
- Prevent building on shaky foundations
- Make parallel work opportunities obvious
- Catch architectural issues early

**Present blocks to user before detailed phase breakdown:**
- "Here are the 4 major dependency blocks. Does this sequence make sense?"
- User can redirect before you invest time in detailed phases

### Step 7: Implementation Phases

Map user stories to implementation sequence, informed by dependency blocks.

**Format:**
```markdown
## Implementation Phases

### Phase 0: Setup
- Initialize project
- Configure tooling
- Create directory structure

### Phase 1: Foundational (Block 1)
- Database schema
- Seed data
- Core utilities
- **Checkpoint**: Block 1 verification
- *BLOCKS all user story work*

### Phase 2: User Story 1 (P1) (Block 2)
- [Brief description]
- Files: [List key files]
- **Checkpoint**: Block 2 verification

### Phase 3: User Story 2 (P2) (Block 3)
- [Brief description]
- Files: [List key files]
- **Checkpoint**: Block 3 verification

[Continue for all user stories]

### Phase N: Polish
- Documentation
- Performance optimization
- Final testing
```

### Step 7: Write the Plan

Create `.specify/plan.md` with complete structure.

## Template Structure

```markdown
# Implementation Plan: [Feature]

**Date**: [Today]
**Spec**: .specify/spec.md

---

## Summary

[One paragraph: what we're building and technical approach]

---

## Technical Context

[Stack, dependencies, platform, constraints]

---

## Constitution Check

✅ Constraint 1: [How plan satisfies it]
✅ Constraint 2: [How plan satisfies it]
⚠️ Potential issue: [Any concerns and mitigations]

---

## Project Structure

[Complete directory tree with annotations]

**Structure Decision**: [Why this organization]

---

## Data Model

[Entity definitions if applicable]

---

## Architecture Decisions

### Decision 1: [Name]
[Context, decision, rationale, alternatives, consequences]

### Decision 2: [Name]
[Same format]

---

## Dependency Blocks (Optional - for complex plans)

### Block 1: [Name]
**Dependencies**: [What must exist first]
**Builds**: [What this creates]
**Why this block**: [Rationale]
**Verification checkpoint**: [How to verify]

### Block 2: [Name]
[Same format]

---

## Implementation Phases

[Phase breakdown mapping to user stories]

---

## Complexity Notes

[Any concerns about complexity, with justifications]
```

## Validation Checklist

Before finalizing plan:
- [ ] Tech stack matches constitution constraints
- [ ] All user stories have implementation approach
- [ ] Directory structure is complete
- [ ] Data model covers all entities from spec
- [ ] Key decisions are documented
- [ ] Phases map clearly to user stories
- [ ] No spec details duplicated (link to spec instead)

## Output

Creates: `.specify/plan.md`

## Common Plan Elements by Project Type

### Web App
- Frontend framework choice
- State management approach
- API communication (if applicable)
- Routing strategy
- Build/deployment process

### CLI Tool
- Argument parsing library
- Configuration approach
- Output formatting
- Error handling strategy

### Library
- API surface design
- Dependency philosophy
- Versioning strategy
- Documentation approach

## Commit Your Work

After creating the plan, suggest a commit message for Matt to review and edit before committing. A good plan commit captures the tech stack, key architectural decisions, and what's next.

**The git log is your work record. Don't create separate summary docs.**

## Next Steps

After planning:
- Generate tasks from spec + plan
- Or refine plan if issues discovered
- Use analyze workflow to validate consistency

---

**Remember:** Plan is HOW to build WHAT the spec describes.
Keep WHAT (user value) in spec, HOW (implementation) in plan.