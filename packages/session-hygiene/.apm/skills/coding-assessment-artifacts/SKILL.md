---
name: coding-assessment-artifacts
description: Generate interactive tutorials and comprehension assessments as artifacts. Use when user asks to assess understanding, generate coding assessment, quiz on concepts, or review learning. Addresses research showing AI-assisted coding can reduce comprehension by 17%.
---

# Coding Assessment (Artifact Mode)

Generate interactive tutorials and comprehension assessments for code written collaboratively to ensure deep understanding and identify knowledge gaps.

**This version outputs assessments as artifacts** instead of saving to filesystem, making it compatible with uploaded custom skills.

## Purpose

Addresses the research finding that AI-assisted coding can reduce comprehension by 17% (nearly two letter grades). Helps maintain professional responsibility for all submitted code by:

1. **Immediate comprehension check** - Tutorial + quiz after coding sessions
2. **Weakness tracking** - Identifies concepts needing reinforcement via Claude memory
3. **Proactive reinforcement** - Surfaces relevant learning when touching weak-spot concepts
4. **Fluency development** - Builds contextual mastery progressively

## When to Use

### Explicit Triggers
- "Assess my understanding of what we just built"
- "Generate a coding assessment for this session"
- "Quiz me on [concept/feature]"
- "Review my understanding of [topic]"

### Proactive Triggers (Auto-surface)
When starting work that touches a previously identified weak concept:
```
"Quick refresher: We worked on [concept] on [date].
You were reinforcing [specific pattern]. Key insight: [summary]

Ready to proceed, or want a quick review first?"
```

## Assessment Output

**Format:** Markdown artifact
**Filename suggestion:** `YYYY-MM-DD-topic-name.md`

User can save the artifact to their preferred location (Obsidian, notes app, etc.)

## Memory Schema

Track learning progress using Claude's memory system:

**Weak concepts** (need reinforcement):
```
Coding comprehension - Weak areas:
- async/await cleanup patterns (last assessed: 2025-01-30, confidence: 3/5)
- closure scope in event handlers (last assessed: 2025-01-25, confidence: 2/5)
```

**Strong concepts** (well understood):
```
Coding comprehension - Strong areas:
- React component composition (reinforced: 2025-01-28)
- CSS Grid layouts (reinforced: 2025-01-26)
```

**Recent focus**:
```
Coding comprehension - Recent work:
- Working on async patterns in event handling (Jan 30)
- Emphasized debugging cleanup logic
```

## Workflow: Post-Session Assessment

**Process:**

1. **Analyze** recent conversation + specified files
2. **Identify** key concepts, patterns, architectural decisions
3. **Check memory** for known weak spots
4. **Generate tutorial** explaining the "why/why not" of choices
5. **Create assessment** focused on:
   - Debugging scenarios (primary focus per research - 40%)
   - Code reading comprehension (30%)
   - Conceptual understanding (20%)
   - Alternative approaches considered (10%)
6. **Weight questions** toward weak areas from memory
7. **Present as artifact** with suggested filename
8. **Update memory** after user provides answers

## Assessment Document Structure

### Frontmatter
```yaml
---
date: 2025-01-30
concepts:
  - async/await
  - useEffect cleanup
  - event listeners
  - closure scope
confidence_before: 2/5
suggested_save_location: coding-assessments/2025-01-30-async-cleanup.md
---
```

### Tutorial Section
```markdown
## Tutorial: Why This Pattern Works

### The Problem
[Explain what we were trying to solve]

### Our Solution
[Show the actual code we wrote]

### Key Decisions

#### Why useEffect cleanup?
[Explain the "why" - not just "what"]

#### Why not alternatives?
[Cover approaches we rejected and why]

### Conceptual Foundation
[Explain underlying principles]

### Connection to Previous Learning
[If relevant weak spot from memory]
```

### Assessment Section
```markdown
## Assessment Questions

### Question 1: Debugging (High Priority)
```javascript
// Code with subtle bug
```

What will happen? Why? How would you fix it?

**Your answer:**
[Write your answer here before checking feedback]

---

### Question 2-5: [Similar format]
```

### Feedback Section
```markdown
## How to Use This Assessment

1. Read the tutorial section
2. Answer all 5 questions in writing
3. Return to chat and share your answers
4. I'll provide detailed feedback
5. We'll update your learning profile together

## Scoring Guide

- 5/5 correct: Strong understanding (confidence: 5/5)
- 4/5 correct: Solid grasp (confidence: 4/5)
- 3/5 correct: Developing (confidence: 3/5)
- 2/5 or fewer: Needs reinforcement (confidence: 2/5)
```

## Assessment Question Types

### 1. Debugging Questions (40% - Highest Priority)
```markdown
**Format:** Code with subtle bug + diagnosis request

**Tests:**
- Ability to identify incorrect code
- Understanding of why it fails
- Knowledge of how to fix it

**Why prioritized:** Research showed debugging had largest gap
```

### 2. Code Reading Questions (30%)
```markdown
**Format:** Show code + ask what it does/prevents

**Tests:**
- Comprehension of existing code
- Ability to verify AI-generated code
- Understanding of side effects
```

### 3. Conceptual Questions (20%)
```markdown
**Format:** Explain principles without code

**Tests:**
- Understanding core principles
- Grasp of library design patterns
- Ability to assess AI code appropriateness
```

### 4. Alternative Approaches (10%)
```markdown
**Format:** Why we chose X over Y

**Tests:**
- Understanding trade-offs
- Architectural decision reasoning
- Recognition of context-appropriate patterns
```

## Confidence Tracking System

### Self-Report (User rates after providing answers)
```
1/5 - "I guessed on most questions"
2/5 - "I got the basics but missed nuances"
3/5 - "I understand the pattern but need practice"
4/5 - "I'm comfortable and could debug issues"
5/5 - "I could teach this to someone else"
```

### Performance Inference (From answers)
```
Strong indicators (↑ confidence):
- Correctly identifies bugs
- Explains "why" not just "what"
- Connects to broader principles
- Mentions trade-offs

Weak indicators (↓ confidence):
- Surface-level answers
- Misses subtle bugs
- Can't explain reasoning
- Confuses similar concepts
```

### Combined Assessment
```
Final confidence = (self-report + inferred) / 2

Track over time in memory:
- Jan 25: 2/5 (weak)
- Jan 30: 3/5 (improving)
- Next encounter: Expect 3.5-4/5
```

## Memory Update Protocol

After user provides answers and feedback is given:

### 1. Update Weak Concepts
```
If confidence ≤ 3/5:
  Add/update in "Weak areas" with date + score

Example memory update:
"User struggled with closure scope in event handlers
(2/5 on Jan 30). Needs reinforcement on how closures
capture variable references."
```

### 2. Promote to Strong Concepts
```
If confidence ≥ 4/5 on previously weak concept:
  Move from "Weak" to "Strong" areas
  Keep date of promotion

Example:
"Closure scope: promoted to strong on Feb 15
(was weak at 2/5 on Jan 30, now 4/5)"
```

### 3. Track Recent Focus
```
Always update "Recent work" with:
- Date
- Concept focus
- Key emphasis
- Confidence trajectory
```

## Proactive Reinforcement Logic

### Detection
```
User message contains concept keywords:
  - "event listener" → check for "event handler" weak spots
  - "useEffect" → check for "React hooks" weak spots
  - "async" → check for "async/await" weak spots
```

### Response Template
```
When weak spot detected:

"Quick refresher: [Concept] (last assessed: [date], confidence: [X/5])

Key insight from [date]: [One sentence summary]

[If very recent (< 3 days)]:
  Want to review before we start?

[If older (> 1 week)]:
  This is a good chance to reinforce. Quick 2-min review?

[Always]:
  Your last assessment covered: [brief summary]"
```

### Don't Over-Surface
```
Rules for when NOT to proactively remind:
- Confidence ≥ 4/5 (strong understanding)
- Last assessment < 24 hours ago (too recent)
- Concept only tangentially related
```

## Example: Complete Session Flow

```
[During coding session]
User: "Let's add cleanup to this useEffect"

Claude: [We implement cleanup together]

User: "Okay, that's working. Assess my understanding"

Claude:
"Creating assessment for useEffect cleanup patterns...

I identified these key concepts:
- Cleanup function timing
- Subscription lifecycle
- Memory leak prevention

From memory, you've been working on closure scope
(confidence: 2/5 on Jan 25). I'll connect cleanup to
closure patterns since they're related.

Generating assessment artifact..."

[Presents artifact with tutorial + 5 questions]

"Assessment ready! I've created an artifact with:

Tutorial section explaining:
- Why cleanup runs before re-effects
- Why we can't use async directly in useEffect
- Connection to closure scope from your Jan 25 learning

5 questions covering:
- 2 debugging scenarios (main focus)
- 1 code reading (explain what cleanup prevents)
- 1 conceptual (timing and lifecycle)
- 1 alternatives (why not useLayoutEffect)

Suggested save location:
  coding-assessments/2025-01-30-cleanup-patterns.md

Work through the questions, then share your answers here
and I'll provide detailed feedback."

[User works through assessment]

User: "Okay, here are my answers..."
[Pastes answers]

Claude:
"Let me review your responses...

✅ Q1 (Debugging): Strong! You identified the missing
   dependency AND explained why it causes stale closures.

⚠️ Q2 (Debugging): Partial. You caught the memory leak
   but missed that cleanup also prevents state updates
   on unmounted components.

✅ Q3 (Code Reading): Excellent explanation of timing.

✅ Q4 (Conceptual): Good grasp of lifecycle.

⚠️ Q5 (Alternatives): Close, but useLayoutEffect runs
   synchronously BEFORE paint, not after.

Overall: 4/5 questions strong

Confidence assessment: 3.5/5 (solid understanding,
minor gaps on edge cases)

Updating my memory:
- Moving cleanup patterns to strong areas (was 2/5, now 3.5/5)
- Noting: understands core well, watch for edge cases
- Keeping closure scope in focus (still connected)

Great progress! 🎉"

[Updates memory]
```

## Differences from Filesystem Version

**Removed:**
- Obsidian vault filesystem operations
- Directory creation and file saving
- Past assessment file reading

**Kept:**
- All tutorial and assessment generation logic
- Memory tracking for weak/strong concepts
- Proactive reinforcement when touching weak spots
- Confidence scoring system

**Added:**
- Artifact output format
- Suggested save locations in frontmatter
- Instructions for manual saving

## Research Alignment

This skill directly addresses findings from Anthropic's
"How AI assistance impacts the formation of coding skills" research:

**Problem identified:**
- AI assistance reduced comprehension by 17%
- Debugging showed largest gap
- Cognitive offloading prevented skill development

**This skill's approach:**
- Emphasizes debugging questions (40% of assessment)
- Forces active engagement with "why/why not"
- Tracks learning over time via memory
- Promotes "generation-then-comprehension" pattern

## Success Criteria

This skill is working well when:

✅ You confidently understand all code you commit
✅ Weak spots are identified and reinforced
✅ Assessment feels natural, not burdensome
✅ Professional responsibility is met
✅ You can explain decisions to colleagues

---

**To use:** Just say "Assess my understanding" after any coding session!
