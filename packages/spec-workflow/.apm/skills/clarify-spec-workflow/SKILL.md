---
name: clarify-spec-workflow
description: Systematically identify and resolve ambiguities in specifications. Use when user wants to improve spec quality before planning.
---

# Specification Clarification Workflow

## When to Use
- After writing initial spec
- User says: "clarify the spec", "check for ambiguities", "what's unclear", "improve this spec"
- Before creating implementation plan

## Goal

Detect and reduce ambiguity or missing decision points in a specification.
Make it concrete enough that implementation can proceed with confidence.

## The Clarification Process

### Step 1: Load Specification

Read `.specify/spec.md` (or `.specify/specs/[name].md` if the project uses multiple specs)

### Step 2: Scan for Ambiguity

Perform structured coverage analysis across these categories:

#### Functional Scope & Behavior
- Are core user goals clear and measurable?
- Is out-of-scope explicitly stated?
- Are user roles/personas distinct?

#### Domain & Data Model
- Are entities, attributes, relationships defined?
- Are identity and uniqueness rules clear?
- Are state transitions documented?
- Are data volumes/scale assumptions stated?

#### Interaction & UX Flow
- Are critical user journeys complete?
- Are error/empty/loading states specified?
- Are accessibility requirements stated?

#### Non-Functional Quality
- Are performance targets measurable? (latency, throughput)
- Are scalability limits defined?
- Are reliability expectations clear?
- Are security/privacy requirements stated?
- Are compliance constraints identified?

#### Integration & Dependencies
- Are external services and failure modes documented?
- Are data formats specified?
- Are protocol/versioning assumptions clear?

#### Edge Cases & Errors
- Are negative scenarios covered?
- Is failure handling defined?
- Are conflict resolution approaches specified?

#### Constraints & Tradeoffs
- Are technical constraints stated?
- Are rejected alternatives documented?

#### Terminology & Consistency
- Are terms used consistently?
- Are synonyms avoided?

#### Completion Signals
- Are acceptance criteria testable?
- Is "done" measurable?

#### Placeholders
- Are there TODO markers?
- Are there vague adjectives ("robust", "fast", "secure")?

### Step 3: Prioritize Questions

Generate up to 5 clarification questions.

**Include a question ONLY if:**
- Answer materially impacts architecture, data modeling, task decomposition, or testing
- No reasonable default exists
- Multiple interpretations have different implications

**Prioritize by impact:**
1. Scope (significantly changes what gets built)
2. Security/Privacy (legal or financial implications)
3. User Experience (core interaction patterns)
4. Technical Details (can often use defaults)

**LIMIT: Maximum 5 questions total**

### Step 4: Ask Questions Sequentially

Present **ONE question at a time**.
**For multiple-choice questions:**

1. **Analyze options and recommend best choice based on:**
   - Best practices for the project type
   - Common patterns
   - Risk reduction (security, performance, maintainability)
   - Alignment with constitution values

2. **Present recommendation prominently:**
   ```
   **Recommended:** Option B - <brief reasoning why this is best>
   ```

3. **Show all options in table:**
   ```markdown
   | Option | Description |
   |--------|-------------|
   | A | First option |
   | B | Second option (recommended) |
   | C | Third option |
   | Custom | Provide your own answer (≤5 words) |
   ```

4. **Accept multiple response types:**
   - "yes" or "recommended" → Use your recommendation
   - Letter (A, B, C) → Use that option
   - Custom text → Use if ≤5 words

**For short-answer questions (no discrete options):**

1. **Provide suggested answer:**
   ```
   **Suggested:** <your proposed answer> - <brief reasoning>
   ```

2. **Format constraint:**
   ```
   Format: Short answer (≤5 words). 
   Reply "yes"/"suggested" to accept, or provide your own.
   ```

### Step 5: Integrate Answers Incrementally

After EACH accepted answer:

1. **Update clarifications section:**
   - Create `## Clarifications` section if doesn't exist
   - Add `### Session YYYY-MM-DD` subheading for today
   - Append: `- Q: <question> → A: <answer>`

2. **Update relevant sections:**
   - Functional ambiguity → Add/update Functional Requirements
   - User interaction → Update User Stories or acceptance scenarios
   - Data shape → Update Data Model (add fields, types, relationships)
   - Non-functional → Add measurable criteria to Quality Attributes
   - Edge case → Add to Edge Cases section
   - Terminology → Normalize across spec

3. **Remove contradictions:**
   - If answer invalidates earlier ambiguous statement, replace it
   - Leave no obsolete contradictory text

4. **Save immediately:**
   - Write updated spec after each answer
   - Atomic updates minimize risk of context loss

### Step 6: Stop Conditions

Stop asking questions when:
- All critical ambiguities resolved (remaining are low-impact)
- User signals completion ("done", "good", "no more")
- Reached 5 questions (the limit)

### Step 7: Validation

After each update:
- [ ] Clarifications section has one bullet per answer
- [ ] Total questions ≤ 5
- [ ] Updated sections resolve vague placeholders
- [ ] No contradictory statements remain
- [ ] Markdown structure valid
- [ ] Terminology consistent

### Step 8: Report Completion

Output:
- Number of questions asked and answered
- Path to updated spec (`.specify/specs/[name].md`)
- Sections touched (list names)
- Coverage summary:
  - **Resolved**: Was partial/missing, now addressed
  - **Deferred**: Exceeds question quota or better for planning phase
  - **Clear**: Already sufficient
  - **Outstanding**: Still partial/missing but low impact

**Recommendation:**
- If Outstanding items exist: Run clarify again or note for planning
- Otherwise: Proceed to plan creation

## Example Session

```
User: "Clarify the spec"

Claude: [scans spec.md, finds ambiguities]

"I found 3 areas needing clarification:

**Question 1: Authentication Method**

Context: Spec mentions 'user authentication' but doesn't specify approach.

**Recommended:** Option B - Session-based is simpler for web apps, 
no token management complexity, works well for this use case.

| Option | Description |
|--------|-------------|
| A | OAuth2 (third-party like Google/GitHub) |
| B | Session-based (email/password) |
| C | JWT tokens (stateless) |
| Custom | Provide different approach (≤5 words) |

Your choice:"

User: "yes"

Claude: [saves: "Q: Authentication method? → A: Session-based"]
[updates Functional Requirements with session-based auth details]

"Updated spec with session-based authentication.

**Question 2: Data Retention**

Spec doesn't specify how long to keep user data.

**Suggested:** 2 years - Balances legal requirements with storage costs

Format: Short answer (≤5 words). 
Reply "yes"/"suggested" to accept, or provide your own.

Your choice:"

User: "indefinitely"

Claude: [saves: "Q: Data retention? → A: Indefinitely"]
[updates Non-Functional Requirements]

"Updated spec with indefinite retention.

**Question 3: Performance Target**

'Fast response time' is vague. What's the target?

**Recommended:** Option B - Under 1 second is standard web UX expectation

| Option | Description |
|--------|-------------|
| A | Under 200ms (very fast, may need caching) |
| B | Under 1 second (standard web UX) |
| C | Under 3 seconds (acceptable for complex ops) |
| Custom | Specify different target (≤5 words) |

Your choice:"

User: "B"

Claude: [saves: "Q: Performance target? → A: Under 1 second"]
[updates Success Criteria with measurable metric]

"✅ Clarification complete!

Questions answered: 3
Spec updated: .specify/specs/mvp-spec.md

Sections touched:
- Functional Requirements (authentication)
- Non-Functional Requirements (retention, performance)
- Success Criteria (performance metric)

Coverage Summary:
- Resolved: Authentication, retention, performance
- Clear: All other categories
- Outstanding: None

✅ Spec is ready for planning. Next: 'create plan' or 'generate tasks'"
```

## Best Practices

**Making informed guesses:**
- Use industry standards when reasonable
- Document assumptions in spec
- Only ask when no good default exists

**Question quality:**
- Specific, not general
- Answerable in one choice or short phrase
- Directly impacts implementation

**Limiting questions:**
- Focus on high-impact areas
- Combine related questions
- Trust reasonable defaults

**Integration:**
- Update spec immediately after each answer
- Keep related content together
- Remove ambiguity, don't add complexity

## Common Clarification Areas

**If spec lacks these, consider asking:**

**Scope:**
- Supported vs unsupported use cases
- User types and permissions
- Platform/device support

**Security:**
- Authentication requirements
- Data encryption needs
- Access control approach

**Performance:**
- Response time targets
- Concurrent user expectations
- Data volume assumptions

**Errors:**
- Validation approach
- Error message strategy
- Failure recovery

**Integration:**
- External API dependencies
- Data import/export formats
- Version compatibility

## Output

Updates: `.specify/spec.md` (or `.specify/specs/[name].md`) with:
- Clarifications section documenting Q&A
- Resolved ambiguities in relevant sections
- Concrete, testable requirements

## Commit Your Work

After resolving ambiguities, suggest a commit message for Matt to review and edit before committing. A good clarification commit lists each question and its answer — these decisions are worth preserving explicitly in the git log.

**The git log is your work record. Don't create separate summary docs.**

## Next Steps

After clarification:
- Create technical plan
- Generate task list
- Or run analysis to validate consistency

---

**Remember:** The goal is specificity, not perfection. 
Get the spec concrete enough that tasks can be generated confidently.