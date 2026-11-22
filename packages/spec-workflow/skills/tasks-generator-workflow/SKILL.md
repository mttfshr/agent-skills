---
name: tasks-generator-workflow
description: Generate flat, dependency-ordered task list from specs and plan. Use when user wants to break down work into implementable tasks.
---

# Task Generation Workflow

## When to Use
- After specs and plan are complete
- User says: "generate tasks", "break this down", "create task list", "what's the build order"

## Prerequisites

Required files in `.specify/`:
- ✅ `constitution.md` - Core values, constraints
- ✅ `spec.md` - User stories with P1, P2, P3 priorities
- ✅ `plan.md` - Tech stack, project structure

Optional (improves quality):
- Design research specs in `specs/*.md`
- Data model definitions
- API contracts

## The Task Generation Process

### Step 1: Gather Context

Read from `.specify/`:
- `constitution.md` - Understand constraints and values
- `spec.md` - Extract user stories and priorities
- `plan.md` - Get tech stack and directory structure
- Any design research specs for detailed requirements

### Step 2: Define Source Layout FIRST

Before any tasks, define the complete target directory structure.
This prevents ambiguity about where files go.

Example for Vue app:
```
src/
├── main.js                      # Entry point
├── App.vue                      # Root component
├── db/
│   ├── index.js                 # Dexie schema
│   └── seed.js                  # Initial data
├── constants/
│   └── categories.js            # Fixed values
├── composables/
│   ├── useDatabase.js           # DB singleton
│   ├── useSession.js            # Session state
│   └── useTasks.js              # Task CRUD
└── components/
    ├── StartScreen.vue
    ├── SessionView.vue
    └── TaskList.vue
```

**Why this matters:** Every task will reference exact file paths.
No ambiguity about "where does this go?"

### Step 3: Organize Tasks by Phase

Tasks are organized by user story to enable independent implementation:

#### Phase 0: Setup
- Project initialization
- Tool configuration  
- Directory structure creation
- Dependency installation

**Checkpoint:** Dev environment works, empty app runs

#### Phase 1: Foundational (CRITICAL - BLOCKS ALL STORIES)
- Shared infrastructure
- Database schema
- Authentication framework (if needed)
- Base models used by multiple stories
- Core utilities

**Checkpoint:** Foundation ready, user stories can begin

#### Phase 2+: User Stories (One phase per story, in priority order)
- Phase 2: User Story 1 (P1) - The MVP
- Phase 3: User Story 2 (P2)
- Phase 4: User Story 3 (P3)
- etc.

Each story phase:
- Has a clear goal
- Has an independent test criterion
- Has a Verify line (command, test, manual, or none yet), copied from the spec
- Contains all tasks for that story
- Ends with a checkpoint

**Final Phase: Polish**
- Documentation
- Performance optimization
- Cross-cutting concerns

### Step 4: Task Format (CRITICAL)

Every task MUST follow this exact format:

```
- [ ] T### [P?] [US#?] Description with exact file path
```

**Components:**

1. `- [ ]` - Markdown checkbox (REQUIRED)2. `T###` - Sequential ID starting at T001 (REQUIRED)
3. `[P]` - Parallelizable marker (OPTIONAL - only if can run in parallel)
4. `[US#]` - User story label (REQUIRED for story phases, omit for Setup/Foundational/Polish)
5. Description with exact file path (REQUIRED)

**When to use [P] (Parallelizable):**
- Different files
- No dependencies on incomplete tasks
- Can be worked on simultaneously

**Examples:**

✅ CORRECT:
- `- [ ] T001 Create project structure per plan.md`
- `- [ ] T005 [P] Install and configure Tailwind CSS`
- `- [ ] T012 [P] [US1] Create User model in src/models/user.py`
- `- [ ] T015 [US1] Implement UserService in src/services/user.py (depends on T012)`

❌ WRONG:
- `Create User model` (missing checkbox, ID, story label, path)
- `T001 [US1] Create model` (missing checkbox, file path)
- `- [ ] Create model in user.py` (missing ID, story label)

### Step 5: Map Features to User Stories

For each user story in the spec:

1. **Identify what's needed:**
   - Models/entities
   - Services/business logic
   - UI components/endpoints
   - Integrations
   - Validation

2. **Create tasks in order:**
   - Tests first (if TDD requested)
   - Models before services
   - Services before endpoints/UI
   - Core before integration

3. **Add checkpoint:**
   - How to verify this story works independently
   - What should be testable at this point
   - The story's **Verify** line from the spec, copied or refined (`command:`, `test:`, or `manual: <what to look at>`)
   - If the Verify is a `test:` or `command:` that does not exist yet, add a task that creates it before that story's implementation tasks (this replaces "tests first if TDD requested" for that story only)

### Step 6: Document Dependencies

Create a dependencies section showing:

**Phase dependencies:**
- Setup → Foundational (BLOCKS all stories) → User Stories → Polish

**User story independence:**
- US1 (P1): No dependencies on other stories
- US2 (P2): May integrate with US1 but independently testable
- US3 (P3): May integrate with US1/US2 but independently testable

**Within each story:**
- Tests → Models → Services → Endpoints
- Core implementation → Integration
- Story complete before next priority

### Step 7: Identify Parallel Opportunities

Mark tasks that can run in parallel within each phase:

```markdown
### Parallel Example: User Story 1

Launch all models together:
- T012 [P] [US1] Create Category model in src/models/category.py
- T013 [P] [US1] Create Task model in src/models/task.py

Then services (depends on models):
- T015 [US1] Implement TaskService in src/services/task_service.py
```

### Step 8: Write Implementation Strategy

Document recommended approaches:

**MVP First (Recommended):**
1. Complete Setup + Foundational
2. Complete User Story 1 only
3. STOP and validate independently
4. Deploy/demo if ready
5. Add more stories incrementally

**Incremental Delivery:**
- Each story adds value without breaking previous ones
- Can stop at any story and have working software
- Each story is independently testable

## Template Structure

```markdown
# Tasks: [Feature Name]

**Spec**: .specify/spec.md
**Build order**: Sequential. Complete each phase before next.
**Branching**: All work on main. Commits per task or logical group.

---

## Expected Source Layout

[Full directory structure defined upfront]

---

## Phase 0: Setup

**Purpose**: Project initialization

- [ ] T001 Task description
- [ ] T002 [P] Parallel task
...

**Checkpoint**: [What should work at this point]
**Verify**: [command, test, or manual: what to look at]

---

## Phase 1: Foundational (BLOCKING)

**Purpose**: Core infrastructure required by all stories

⚠️ CRITICAL: No user story work can begin until complete

- [ ] T00X Task description
...

**Checkpoint**: Foundation ready - story implementation can begin

---

## Phase 2: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [What this story delivers]

**Independent Test**: [How to verify this works alone]
**Verify**: [copied from the spec: command | test | manual | none yet]

### Implementation for User Story 1

- [ ] T0XX [P] [US1] Create [Entity] in src/models/entity.py
- [ ] T0XX [US1] Implement [Service] in src/services/service.py
...

**Checkpoint**: User Story 1 fully functional and testable (runs the Verify above)

---

## Phase 3: User Story 2 - [Title] (Priority: P2)

[Same structure]

---

## Phase N: Polish & Cross-Cutting

**Purpose**: Improvements affecting multiple stories

- [ ] TXXX Documentation updates
- [ ] TXXX Performance optimization
...

---

## Dependencies & Execution Order

[Detailed dependency graph]

### Phase Dependencies
- Setup → Foundational → User Stories → Polish

### User Story Dependencies  
- US1: Can start after Foundational
- US2: Can start after Foundational (may integrate with US1)
...

### Within Each Story
- Models → Services → Endpoints
- Core → Integration

### Parallel Opportunities
[List all [P] tasks by phase]

---

## Implementation Strategy

### MVP First
[Steps to build just US1]

### Incremental Delivery
[How to add stories one at a time]

### Parallel Team Strategy
[How multiple developers could work in parallel]

---

## Notes

- [P] = different files, no dependencies
- [US#] = maps task to user story
- Stop at any checkpoint to validate independently
- Commit after each task or logical group
```

## Validation Checklist

After generation, verify:
- [ ] Every task has checkbox + sequential ID
- [ ] User story tasks have [US#] label
- [ ] All tasks include exact file paths
- [ ] Source layout defined before any tasks
- [ ] Each phase has clear checkpoint
- [ ] Every user story's Verify line from the spec appears in its phase checkpoint
- [ ] Every checkpoint has a Verify (a command or test, or `manual:` saying what to look at)
- [ ] A `test:` or `command:` Verify that does not exist yet has a task creating it before the story's implementation tasks
- [ ] Dependencies documented
- [ ] Parallel opportunities marked [P]
- [ ] Implementation strategy included
- [ ] No vague tasks ("implement feature")
- [ ] No same-file conflicts in parallel tasks

## Output

Creates: `.specify/tasks.md`

Total task count typically:
- Small feature: 15-25 tasks
- Medium feature: 30-50 tasks
- Large feature: 50-80 tasks

If exceeding 80 tasks, consider breaking into multiple features.

## Common Mistakes to Avoid

❌ **Vague descriptions**: "Implement user management"
✅ **Specific**: "Create User model with email, password_hash, created_at in src/models/user.py"

❌ **Missing file paths**: "Add validation"
✅ **With path**: "Add email validation in src/services/user_service.py"

❌ **Wrong ordering**: Service before model
✅ **Correct**: Model first, then service

❌ **Missing [US#]**: "Create component"
✅ **With label**: "[US1] Create TaskList component in src/components/TaskList.vue"

## Commit Your Work

After generating tasks, suggest a commit message for Matt to review and edit before committing. A good tasks commit captures total task count, phase structure, and what's next.

**The git log is your work record. Don't create separate summary docs.**

## Next Steps

After generating tasks:
1. Review with `analyze` workflow
2. Validate consistency across spec/plan/tasks
3. Begin implementation with `implement` workflow

---

**Remember:** Tasks should be clear enough that an LLM can implement them without additional context. If a task needs clarification, it's too vague.