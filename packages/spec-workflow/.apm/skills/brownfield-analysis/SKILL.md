---
name: brownfield-analysis
description: Reverse-engineer Constitution and ADRs from existing codebases to create documentation parity with greenfield projects. Use when the user asks to analyze existing projects, create documentation for codebases, reverse-engineer architecture, or generate Constitution from code. Supports two modes - Mode A for documentation only (~30 min), Mode B for migration planning with delta analysis (~1-2 hours).
---

# Brownfield Analysis

Reverse-engineer Constitution and ADRs from existing codebases to create documentation parity with greenfield projects.

## Goal

Generate the same long-term artifacts (Constitution + ADRs) whether project started with planning or already exists:

```
GREENFIELD: Planning → Constitution → Code
BROWNFIELD: Code → Analysis → Constitution (inferred)

RESULT: Same documentation assets regardless of path
```

## When to Use

Trigger when user says:
- "Analyze this existing project"
- "Create documentation for this codebase"
- "Reverse-engineer the architecture"
- "What does this project care about?"
- "Generate Constitution from code"

## Interactive Analysis Workflow

### Phase 1: Discovery

**Goal:** Understand what we're looking at

1. **Scan project structure**
   - Use Desktop Commander to list directory
   - Identify project type (package.json, requirements.txt, Gemfile, etc)
   - Note configuration files (docker, CI/CD, env templates)
   - Check for existing docs (README, ARCHITECTURE, old ADRs)

2. **Ask user context**
   ```
   "I'm analyzing [project-name]. Before I dive into code:
   
   - Is there any existing documentation I should know about?
   - Are there any known constraints or values to be aware of?
   - Should I focus on specific aspects or analyze everything?"
   ```

3. **Set scope**
   - Full analysis (Constitution + ADRs)
   - Architecture only (ADRs)
   - Values only (Constitution)

### Phase 2: Code Analysis

**Goal:** Infer technical decisions from code patterns

**Analyze:**

1. **Project Type & Architecture**
   ```
   Technologies used:
   - Language/framework (React, Flask, Rails, etc)
   - Architecture pattern (SPA, API, CLI, monolith, microservices)
   - Deployment model (static, serverless, traditional)
   ```

2. **Dependencies**
   ```
   External dependencies:
   - What's included? (frameworks, libraries)
   - What's deliberately minimal? (few deps = constraint)
   - What's absent that's common? (no analytics, no tracking)
   ```

3. **Data & State**
   ```
   Data patterns:
   - Storage approach (DB, localStorage, no persistence)
   - State management (Redux, Context, none)
   - Data flow (unidirectional, bidirectional)
   ```

4. **Configuration & Constraints**
   ```
   Operational constraints:
   - Environment variables (what's configurable)
   - Resource limits (connection pools, timeouts)
   - Security patterns (CSP, validation, sanitization)
   ```

5. **Code Organization**
   ```
   Structural patterns:
   - File organization (by feature, by type, flat)
   - Module boundaries (loose coupling, tight coupling)
   - Abstraction level (simple, complex, over-engineered)
   ```

6. **Testing Approach**
   ```
   Quality priorities:
   - What's tested heavily? (critical paths)
   - What has no tests? (acceptable risk)
   - Test types (unit, integration, e2e)
   ```

**Present findings conversationally:**

```
"Based on code analysis:

This appears to be a [type] with these characteristics:
- [Characteristic 1] (evidence: [what I found])
- [Characteristic 2] (evidence: [what I found])

I notice these constraints:
- [Constraint 1] (evidence: [pattern])
- [Constraint 2] (evidence: [pattern])

Does this match your understanding?"
```

### Phase 3: Git History Mining

**Goal:** Find explicit decision rationale

**Search for:**

1. **Decision commits**
   ```bash
   git log --grep="ADR\|decision\|because\|why" --oneline
   ```
   
2. **Major refactors**
   ```bash
   git log --all --stat --summary | grep "delete\|rename"
   ```

3. **Removal patterns**
   - What was tried and abandoned?
   - Commit messages like "Remove X, it didn't work"
   - Features that were pulled out

4. **Timeline analysis**
   - When were big architectural changes made?
   - What was the original approach vs current?
   - Evolution of priorities

**Extract quotes:**
- Commit messages with explicit rationale
- Comments in code explaining "why not X"
- TODO/FIXME indicating constraints

**Present findings:**

```
"Git history shows some interesting decisions:

[Date]: 'Removed authentication - privacy-first approach'
  → Suggests: Privacy is a core value

[Date]: 'Switch from Redux to Context - simpler is better'
  → Suggests: Simplicity valued over features

Do these reflect intentional values?"
```

### Phase 4: Synthesis (Interactive)

**Goal:** Draft Constitution with user confirmation

**Process:**

1. **Present inferred "What it IS"**
   ```
   "Based on analysis, this project appears to BE:
   
   ✅ [Characteristic 1] - Evidence: [code pattern]
   ✅ [Characteristic 2] - Evidence: [git history]
   ✅ [Characteristic 3] - Evidence: [dependencies]
   
   Accurate? Any corrections?"
   ```

2. **Present inferred "What it ISN'T"**
   ```
   "The project appears to deliberately AVOID:
   
   ❌ [Anti-pattern 1] - Evidence: [absence of X]
   ❌ [Anti-pattern 2] - Evidence: [removed in commit]
   
   Accurate? Any corrections?"
   ```

3. **Present inferred "Hard Constraints"**
   ```
   "I see these constraints:
   
   - [Constraint 1] - Evidence: [validation pattern]
   - [Constraint 2] - Evidence: [config limit]
   
   Are these intentional or accidental?"
   ```

4. **Discuss "Core Values" (hardest to infer)**
   ```
   "I see patterns suggesting these values:
   
   - Simplicity over features (minimal deps, simple patterns)
   - Privacy-first (no analytics, local storage only)
   
   Do these resonate? What values would you add?"
   ```

5. **Iterate until accurate**
   - User corrects inferences
   - Add missing values
   - Remove incorrect assumptions
   - Confirm final understanding

### Phase 5: ADR Extraction

**Goal:** Document key architectural decisions

**Generate ADRs for:**

1. **Technology Choices**
   ```markdown
   ## ADR-001: [Framework/Language] Choice
   
   **Status**: Accepted (inferred from codebase)
   **Date**: [First commit with this tech]
   
   ### Context
   [What problem needed solving]
   
   ### Decision
   Use [technology X]
   
   ### Rationale (inferred)
   [Evidence from code/commits]
   CONFIDENCE: [High/Medium/Low]
   
   ### Consequences
   [Observable impacts in code]
   ```

2. **Architectural Patterns**
   - Data storage approach
   - State management
   - Authentication/authorization
   - Deployment model
   - Testing strategy

3. **Constraint Decisions**
   - "No external dependencies"
   - "Local-only data"
   - "Single-page application"

**Mark confidence levels:**
- HIGH: Explicit in commits or code comments
- MEDIUM: Strong pattern evidence
- LOW: Inferred, needs confirmation

**Present for review:**

```
"I've drafted [N] ADRs based on code analysis:

ADR-001: React + TypeScript (HIGH confidence)
ADR-002: localStorage only (HIGH - explicit in code)
ADR-003: No authentication (MEDIUM - no auth code found)
ADR-004: Minimal dependencies (MEDIUM - pattern observed)

Review these? I'll flag any that need your input on WHY."
```

### Phase 6: Create Artifacts

**Goal:** Generate same files as greenfield projects

**Create:**

1. **`.specify/constitution.md`**
   ```markdown
   <!-- GENERATED FROM BROWNFIELD ANALYSIS -->
   <!-- Date: [analysis date] -->
   <!-- Confidence: Review and confirm all sections -->
   
   # [Project] Constitution
   
   ## Purpose
   [Inferred from README or user input]
   
   ## Core Values
   [Confirmed with user during synthesis]
   
   ## Hard Constraints  
   [Inferred from code patterns]
   
   ## Out of Scope
   [Inferred from absences and removals]
   
   ---
   *Note: This Constitution was reverse-engineered from code.
   Please review and update with any missing context.*
   ```

2. **`docs/decisions.md`**
   ```markdown
   # Architectural Decision Records
   
   *Note: These ADRs were extracted from existing code.
   Confidence levels indicate how certain we are about the rationale.*
   
   ## ADR-001: [Decision]
   **Confidence**: [High/Medium/Low]
   [Standard ADR format with evidence noted]
   
   ---
   ```

3. **`.claude/skills/` (extracted)**
   - Run normal extraction process
   - Creates core.md, validator.md from Constitution
   - Now project has same structure as greenfield

**Confirm with user:**

```
"Analysis complete! Created:

.specify/
├── constitution.md (DRAFT - please review)
└── analysis-notes.md (my findings)

docs/
└── decisions.md ([N] ADRs extracted)

.claude/skills/
├── core.md (from Constitution)
├── validator.md (from constraints)
└── workflow.md (standard)

Next steps:
1. Review Constitution - confirm it's accurate
2. Review ADRs - add missing context on "why"
3. Update going forward using normal sync workflow

This project now has same documentation as greenfield projects!"
```

## Analysis Techniques by Project Type

### Web Application
**Look for:**
- Framework choice (React, Vue, Angular, vanilla)
- Rendering approach (SSR, CSR, hybrid)
- State management strategy
- API patterns (REST, GraphQL, none)
- Authentication approach

**Infer from:**
- Package.json dependencies
- File structure (components, pages, routes)
- Build configuration
- Network calls in code

### CLI Tool
**Look for:**
- Argument parsing (click, argparse, commander)
- Command structure (single command, subcommands)
- Configuration approach (flags, config files, env vars)
- Output format (text, JSON, tables)

**Infer from:**
- Entry point structure
- Help text and error messages
- Configuration file format
- Test fixtures

### Library/Package
**Look for:**
- API surface (what's exported)
- Dependency policy (peer deps, none, minimal)
- Platform targets (browser, node, both)
- Versioning approach

**Infer from:**
- Index file exports
- Package.json configuration
- Build targets
- Documentation

### API Service
**Look for:**
- HTTP framework (Express, FastAPI, Rails)
- Database/storage layer
- Authentication/authorization
- API design (REST, GraphQL, RPC)
- Rate limiting, caching

**Infer from:**
- Route definitions
- Middleware stack
- Database models/migrations
- Configuration files

## Confidence Markers

Use these in generated documents:

```markdown
✅ HIGH CONFIDENCE - Explicit in code/commits
⚠️ MEDIUM CONFIDENCE - Strong pattern evidence  
❓ LOW CONFIDENCE - Inferred, please confirm
🔍 NEEDS INPUT - Cannot determine from code
```

## Example Output

**analysis-notes.md** (working document):

```markdown
# Brownfield Analysis: [Project]

**Analysis Date**: 2026-01-29
**Analyzed by**: Claude
**Code revision**: [git hash]

## Summary
This is a [type] that appears to prioritize [values].

## High Confidence Findings
✅ Uses React + TypeScript (package.json, all files)
✅ localStorage only (no DB imports, all data goes to localStorage)
✅ No external API calls (no fetch/axios, offline-first pattern)

## Medium Confidence Findings
⚠️ Privacy-focused (no analytics code, no tracking)
⚠️ Simplicity valued (minimal deps, simple patterns)

## Low Confidence Findings  
❓ Intended for single-user (no multi-user code, but unclear if constraint)

## Needs Clarification
🔍 Why no authentication? Security unnecessary or privacy choice?
🔍 Why avoid backend? Constraint or preference?

## Recommended ADRs
1. React + TypeScript choice
2. localStorage-only data storage
3. No backend/offline-first
4. No authentication
5. Minimal dependencies

## Next Steps
1. User confirms findings
2. Generate Constitution
3. Write ADRs with confirmed context
```

## Integration with Greenfield Workflow

Once brownfield analysis creates Constitution + ADRs:

1. **Project now has same artifacts** - .specify/, docs/decisions.md
2. **Can use normal sync workflow** - Edit Constitution, sync to skills
3. **Can add new features with Spec Kit** - Spec new features normally
4. **Skills enforce discovered values** - Validator catches drift

**The gap is closed** - Legacy project now documented like greenfield project.

## Best Practices

1. **Always mark inferences** - Don't pretend we're certain when we're not
2. **Iterate with user** - This is collaborative, not automated
3. **Preserve evidence** - Link to commits, code patterns that support findings
4. **Generate drafts** - Documents need review, not blind acceptance
5. **Focus on "why"** - Code shows "what", we need to understand "why"

## Limitations

**Cannot infer:**
- Business context (why project exists)
- User needs (what problems it solves)  
- Future plans (what's coming next)
- Implicit team knowledge (tribal wisdom)

**Needs human input for:**
- Core values confirmation
- Decision rationale (when not in commits)
- Priority clarification
- Scope boundaries

This is **human-augmented analysis**, not fully automated documentation generation.

---

## Two Analysis Modes

The brownfield analysis skill supports two distinct use cases:

### Mode A: Documentation Only (Default)

**Use Case:** Backfill documentation for existing projects

**Goal:** Create documentation parity with greenfield projects

**Generates:**
```
.specify/
├── constitution.md          # Inferred from code
└── analysis-notes.md        # Working notes

docs/
└── decisions.md             # Extracted ADRs

.claude/skills/              # Normal extraction
├── core.md
├── validator.md
└── workflow.md
```

**When to Use:**
- Onboarding documentation for stable projects
- Creating reference docs for portfolio
- Establishing baseline for future changes
- Team handoffs

**Scope:** Focus on accurate representation of current state

---

### Mode B: Migration Planning (Extended Analysis)

**Use Case:** Planning rewrite/major refactor

**Goal:** Support rewrite vs refactor decision with evidence

**Generates everything from Mode A, PLUS:**
```
.specify/
├── constitution-current.md   # What code shows now
├── constitution-desired.md   # Template for target state
└── DELTA.md                  # Gap analysis framework

analysis/
├── tech-debt-assessment.md   # Spaghetti patterns found
├── migration-considerations.md  # Challenges, risks
└── refactor-vs-rewrite.md    # Decision support
```

**When to Use:**
- Planning major modernization
- Justifying rewrite to management
- Scoping migration effort
- Comparing current vs desired architecture

**Scope:** Deep analysis of problems, constraints, migration path

---

## Choosing Analysis Mode

At analysis start, ask:

```
"What's the goal of this analysis?

A) Documentation only
   Create Constitution + ADRs for reference
   (~30 min analysis)

B) Migration planning  
   Deep analysis for rewrite/refactor decision
   (~1-2 hour analysis, includes delta framework)

Which mode?"
```

**User chooses A:**
- Focus on accurate current state
- Generate standard artifacts
- Quick, focused analysis

**User chooses B:**
- Include tech debt assessment
- Generate migration artifacts
- Provide delta framework for desired state
- Support decision-making

---

## Mode B: Extended Analysis Details

### Tech Debt Assessment

**Analyze for:**

1. **Spaghetti Patterns**
   - Tight coupling (where components should be separate)
   - Circular dependencies
   - God objects/modules
   - Mixed concerns (business logic in views, etc)

2. **Outdated Dependencies**
   - Framework versions (Django 2.x vs current)
   - Security vulnerabilities
   - Abandoned packages
   - Breaking changes required for updates

3. **Code Smells**
   - Repeated patterns (DRY violations)
   - Long functions/classes
   - Complex conditionals
   - Magic numbers/strings

4. **Architecture Issues**
   - No clear boundaries
   - Difficult to test
   - Hard to extend
   - Performance bottlenecks

**Output: `analysis/tech-debt-assessment.md`**

```markdown
# Tech Debt Assessment: [Project]

## Critical Issues (Blockers for Evolution)

### Monolithic Architecture
**Problem:** All concerns in single Django app
**Impact:** Cannot add API layer without major refactor
**Evidence:** [file structure, imports analysis]
**Fix Effort:** HIGH - Requires architectural redesign

### Outdated Framework
**Problem:** Django 2.2 (EOL, security issues)
**Impact:** Cannot use modern Django features
**Evidence:** requirements.txt, Django version
**Fix Effort:** MEDIUM - Migration path exists but dependencies need updates

## Medium Priority Issues

[Similar format for each issue]

## Minor Issues / Future Improvements

[Lower priority items]
```

### Migration Considerations

**Analyze:**

1. **Data Migration Complexity**
   - Database schema complexity
   - Data volume
   - Migration path availability
   - Backward compatibility needs

2. **Integration Points**
   - External systems that depend on this
   - APIs exposed to others
   - Breaking changes impact

3. **Team Knowledge**
   - Who knows the current system?
   - Learning curve for new approach
   - Documentation gaps

4. **Risk Factors**
   - Critical paths that cannot break
   - Compliance/security requirements
   - Timeline constraints

**Output: `analysis/migration-considerations.md`**

### Refactor vs Rewrite Decision Support

**Framework for decision:**

```markdown
# Refactor vs Rewrite: [Project]

## Current State Assessment

**Code Quality:** [1-10 scale with evidence]
**Architecture Debt:** [Low/Medium/High with examples]
**Tech Stack Age:** [Years behind current, migration path difficulty]
**Team Knowledge:** [How well understood, documentation quality]

## Refactor Path

**Pros:**
- Preserve working functionality
- Lower risk (incremental changes)
- Team knows existing code

**Cons:**
- [Specific constraints from tech debt]
- [Time to modernize while maintaining]
- [Spaghetti makes changes difficult]

**Estimated Effort:** [Timeline based on issues found]

## Rewrite Path

**Pros:**
- Clean architecture from start
- Modern framework/patterns
- Use existing code as specification

**Cons:**
- Higher initial risk
- Must replicate all functionality
- Requires comprehensive testing

**Estimated Effort:** [Timeline for fresh implementation]

## Recommendation

Based on analysis:
- Delta between current and desired: [LARGE/MEDIUM/SMALL]
- Tech debt severity: [HIGH/MEDIUM/LOW]
- Refactor feasibility: [DIFFICULT/MODERATE/EASY]

**Recommendation:** [REWRITE/REFACTOR/HYBRID]

**Rationale:** [Evidence-based reasoning]
```

### Delta Analysis Framework

**Compare constitutions to show gap:**

```markdown
# Delta Analysis: Current vs Desired State

## Architecture

**Current:**
❌ [What code shows]
- Evidence: [specific patterns]

**Desired:**
✅ [What you want]
- Benefit: [why this is better]

**Gap:** [Size of change - LARGE/MEDIUM/SMALL]
**Approach:** [How to bridge - rewrite/refactor/migrate]

## Tech Stack

[Same format]

## Data Model

[Same format]

## Integration Points

[Same format]

## Summary Table

| Aspect | Current | Desired | Gap Size | Approach |
|--------|---------|---------|----------|----------|
| Architecture | Monolith | Modular | LARGE | Rewrite |
| Framework | Django 2.2 | Django 5.x | MEDIUM | Migrate |
| API | None | REST/GraphQL | LARGE | Build new |
| Auth | Spaghetti | Clean boundaries | HIGH | Redesign |

## Overall Assessment

**Total Gap:** [LARGE/MEDIUM/SMALL]
**Complexity:** [HIGH/MEDIUM/LOW]
**Recommendation:** [Strategic direction]
**Justification:** [Evidence from analysis]
```

---

## Example: Mode B for Playa Events

**User says:** "Analyze Playa Events for migration planning"

**Analysis process:**

1. **Scan Django app structure**
   - Out-of-date requirements.txt (Django 2.x)
   - Monolithic app structure
   - No API layer
   - Mixed concerns in views

2. **Analyze spaghetti patterns**
   - Authorization logic scattered
   - Template-bound data logic
   - Tight coupling throughout

3. **Mine git history**
   - Find abandoned modernization attempts
   - See where complexity grew
   - Identify pain points from commits

4. **Generate Mode B artifacts**
   - constitution-current.md (monolithic Django app, tightly coupled)
   - Tech debt assessment (framework EOL, spaghetti auth, no API)
   - Migration considerations (data complexity, external integrations)
   - Refactor vs rewrite framework (recommendation: rewrite)

5. **Provide desired state template**
   - constitution-desired.md (you fill in modern vision)
   - Then generate DELTA.md comparing them

**Deliverable to manager:**
- Here's what we have (constitution-current)
- Here's what we want (constitution-desired)
- Here's the gap (DELTA.md)
- Here's why rewrite makes sense (refactor-vs-rewrite.md)
- Here's the tech debt evidence (tech-debt-assessment.md)

---

## Mode Selection at Runtime

**Trigger phrase determines mode:**

**Mode A (Documentation):**
- "Analyze this project"
- "Document this codebase"
- "Create Constitution for this app"
- "Generate ADRs from code"

**Mode B (Migration Planning):**
- "Analyze for migration"
- "Planning a rewrite of this"
- "Should we refactor or rewrite this?"
- "Modernization analysis for this project"

**If ambiguous, ask explicitly:**

```
"I can do:
A) Documentation analysis (Constitution + ADRs)
B) Migration planning (includes delta analysis, tech debt assessment)

Which do you need?"
```

---

## Summary

**Mode A:** Quick documentation backfill
- Standard artifacts only
- Focus on current state
- ~30 minutes

**Mode B:** Deep migration analysis
- All Mode A artifacts PLUS
- Tech debt assessment
- Migration considerations
- Delta framework
- Decision support
- ~1-2 hours

**Both modes produce documentation parity** - difference is depth and additional migration artifacts.
