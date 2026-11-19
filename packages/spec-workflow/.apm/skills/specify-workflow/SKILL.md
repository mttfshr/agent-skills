---
name: specify-workflow
description: Create feature specifications with prioritized user stories. Use when user wants to write a spec or define a feature.
---

# Specification Creation Workflow

## When to Use
- Defining a new feature or project
- User says: "write spec", "create specification", "define feature", "what should the spec say"
- After constitution exists

## What a Spec Contains

A specification defines WHAT to build and WHY, not HOW.

**Key sections:**
1. User Stories (prioritized P1, P2, P3...)
2. Acceptance Scenarios (Given/When/Then)
3. Functional Requirements
4. Non-Functional Requirements
5. Success Criteria
6. Edge Cases

## The Specification Process

### Step 1: Understand Scope

Ask the user:
- What feature/capability are we defining?
- Who is it for?
- What problem does it solve?
- What's explicitly OUT of scope?

### Step 2: Identify User Stories

Break the feature into independent user journeys.

**Each story should be:**
- Independently testable (can verify it works alone)
- Independently deliverable (adds value on its own)
- Priority-ordered (P1 = MVP, P2 = next most important, etc.)

**Format:**
```markdown
### User Story 1 - [Brief Title] (Priority: P1)

[Describe what the user can do]

**Why this priority**: [Explain the value]

**Independent Test**: [How to verify this works without other stories]

**Acceptance Scenarios**:
1. **Given** [state], **When** [action], **Then** [outcome]
2. **Given** [state], **When** [action], **Then** [outcome]
```

### Step 3: Extract Requirements

From user stories, derive functional requirements.

**Format:**
```
- **FR-001**: System MUST [specific capability]
- **FR-002**: Users MUST be able to [interaction]
- **FR-003**: System MUST [data requirement]
```

**Testable, not vague:**
- ✅ "System MUST validate email format before accepting registration"
- ❌ "System should have good validation"

### Step 4: Define Success Criteria

How will you know this feature succeeded?

**Format:**
```
1. [Measurable metric with target]
2. [User satisfaction measure]
3. [Performance target]
4. [Business outcome]
```

**Technology-agnostic, measurable:**
- ✅ "Users complete checkout in under 2 minutes"
- ❌ "React components render efficiently"

### Step 5: Document Edge Cases

What unusual or error scenarios exist?

```
- What happens when [boundary condition]?
- How does system handle [error scenario]?
- What if user [unexpected action]?
```

### Step 6: Write the Spec

Create `.specify/spec.md` with this structure:

```markdown
# Feature Specification: [Name]

**Created**: [Date]
**Status**: Draft

---

## User Stories

[All stories with priorities, independent tests, acceptance scenarios]

---

## Requirements

### Functional Requirements

[All FR-XXX items]

### Non-Functional Requirements

[Performance, security, usability requirements]

---

## Success Criteria

[Measurable outcomes]

---

## Edge Cases

[Boundary conditions and error scenarios]
```

## Example: Session Management Feature

```markdown
# Feature Specification: Session Management

**Created**: 2026-02-01
**Status**: Draft

---

## User Stories

### User Story 1 - Start and Resume Sessions (Priority: P1)

A user can start a planning session and have it resume if they close and reopen the app.

**Why this priority**: Sessions are the core container for all other features. 
Without this, nothing else works.

**Independent Test**: Start a session, see active session view. Close app, reopen, 
confirm session is still active. Close session, confirm return to start screen.

**Acceptance Scenarios**:

1. **Given** no active session exists, **When** user opens app, **Then** start screen is shown
2. **Given** user taps "Start Session", **When** session creates, **Then** active session view appears
3. **Given** active session exists and app closes, **When** app reopens, **Then** session resumes
4. **Given** user closes session, **When** closure completes, **Then** start screen appears

---

### User Story 2 - Optional Reflection (Priority: P2)

A user can write a brief reflection when closing a session, or skip it entirely.

**Why this priority**: Adds mindfulness value without blocking core workflow.

**Independent Test**: Close session, see reflection prompt. Write reflection, 
confirm saved. Close session, skip reflection, confirm not required.

**Acceptance Scenarios**:

1. **Given** user initiates close, **When** reflection prompt appears, **Then** user can write text or skip
2. **Given** user writes reflection, **When** confirms, **Then** reflection saved with session
3. **Given** user skips reflection, **When** confirms, **Then** session closes without reflection

---

## Requirements

### Functional Requirements

- **FR-001**: System MUST allow exactly one active session at a time
- **FR-002**: System MUST persist active session across page reloads
- **FR-003**: System MUST close session with status "closed" and timestamp
- **FR-004**: Users MUST be able to skip reflection when closing
- **FR-005**: System MUST save reflection text only when user provides it

### Non-Functional Requirements

- **NF-001**: Session state MUST persist in local IndexedDB
- **NF-002**: Session resume MUST happen within 100ms of app launch
- **NF-003**: Session close MUST complete within 200ms

---

## Success Criteria

1. User can complete start → close → start cycle in under 30 seconds
2. Session survives app close/reopen without data loss
3. Reflection is truly optional - users never feel forced to write one
4. 95% of sessions close successfully on first attempt

---

## Edge Cases

- App crashes mid-session → Session remains active, resumes on restart
- User force-closes without closing session → Session stays active
- User starts session then immediately closes → Empty session is allowed
- Multiple rapid session starts → Only one succeeds, others no-op
```

## Validation Checklist

Before finalizing spec:
- [ ] Each user story has priority (P1, P2, P3...)
- [ ] Each user story has independent test
- [ ] Each user story has 2+ acceptance scenarios
- [ ] Functional requirements are testable
- [ ] Success criteria are measurable
- [ ] No HOW (implementation details) in spec
- [ ] No vague adjectives without metrics

## Output

Creates: `.specify/spec.md`

**Note:** A single `spec.md` at the flat `.specify/` level is the right default for
solo developers on a bounded project. Only introduce a `specs/` subdirectory if you
accumulate parallel, independent feature specs (e.g., a de-risking spec and a
moderation-ui spec running simultaneously).

## Commit Your Work

After creating the specification, suggest a commit message for Matt to review and edit before committing. A good spec commit captures the number of user stories, their priorities, and what's next.

**The git log is your work record. Don't create separate summary docs.**

## Next Steps

After specification:
- Run clarify workflow to resolve ambiguities
- Or proceed directly to plan creation
- Or write design research specs for complex areas

---

**Remember:** Spec defines WHAT and WHY. Plan defines HOW.
Keep implementation details out of specs.