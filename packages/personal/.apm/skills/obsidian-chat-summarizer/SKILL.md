---
name: obsidian-chat-summarizer
description: Create brief, intent-driven markdown summaries of conversations and save them to Obsidian vault. Use when the user asks to summarize a chat to Obsidian, save conversation notes, document discussions, or create chat summaries. Triggers include "summarize this to Obsidian", "save this to my vault", "document this chat", "create notes for this conversation".
---

# Obsidian Chat Summarizer

Create concise, intent-specific summaries of conversations with hyperlinks to chat for details, following the user's Obsidian frontmatter conventions.

## Workflow

1. **Clarify Intent** - When user requests a summary, ask:
   ```
   What's the purpose of this summary?
   - Capturing a project idea
   - Clarifying a learning path  
   - Creating a tutorial/checklist
   - Understanding a problem space
   - Other (please specify)
   ```

2. **Generate Summary** - Create brief, intent-specific markdown following the appropriate template below

3. **Create Filename** - Auto-generate from topic: `{topic_slug}.md` (e.g., `muse_eeg_streaming_setup.md`)

4. **Detect Vault Location** - Use memory first, filesystem check as fallback:
   - Check memory for username and vault location
   - If not in memory, use Desktop Commander to detect:
     - Check if `/Users/matt.fisher/` exists → work laptop, vault: `/Users/matt.fisher/Obsidian/_ideas/`
     - Otherwise check if `/Users/matt/` exists → personal laptop, vault: `/Users/matt/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/_ideas/`
   - If neither exists, ask user for vault location

5. **Write to Vault** - Use Desktop Commander to write file to detected `_ideas/` folder

6. **Add Review Reminder to Today's Daily Note**
   - Append to Notes section: `- [ ] Review [[filename]] for project potential`
   - Format: `YYYY-MM-DD, DayOfWeek.md` in `_autofocus/` directory
   - Example: `2026-02-10, Tuesday.md`

7. **Confirm** - Inform user the file has been saved to `_ideas/` in their vault

## Frontmatter Template

All summaries MUST use this frontmatter structure:

```yaml
---
title: [Display title]
created: YYYY-MM-DD
modified: YYYY-MM-DD
publish: false
tags: [relevant, topic, tags]
description: [One-line summary of the conversation]
source: [Link to chat]
type: [project-idea|learning-path|tutorial|problem-space|other]
---
```

**Field Guidelines:**
- `title`: Clear, descriptive title
- `created`: Current date (YYYY-MM-DD)
- `modified`: Same as created initially
- `publish`: Always `false` by default (user can change later)
- `tags`: 2-5 relevant tags based on content
- `description`: Single sentence summary
- `source`: Full URL to the chat conversation
- `type`: Intent category from workflow step 1

## Intent-Based Templates

### Project Idea

```markdown
---
title: [Project Name]
created: YYYY-MM-DD
modified: YYYY-MM-DD
publish: false
tags: [relevant, tags]
description: [One-line project description]
source: [Chat URL]
type: project-idea
---

# [Project Name]

**Concept:** One-line description of the core idea

**Key Components:**
- Component 1
- Component 2
- Component 3

**Status:** [Active | Planned | On Hold]

**Next Steps:**
- [ ] First action item
- [ ] Second action item
- [ ] Third action item

**Resources:**
- [Full conversation](source)
- [External resource if applicable]

**Notes:**
Any additional brief context or considerations
```

### Learning Path

```markdown
---
title: Learning [Topic]
created: YYYY-MM-DD
modified: YYYY-MM-DD
publish: false
tags: [learning, topic, tags]
description: [What you're learning and why]
source: [Chat URL]
type: learning-path
---

# Learning: [Topic]

**Goal:** What you want to learn or achieve

**Background:** Brief context of current understanding

**Learning Path:**
1. Start with [concept/resource] → [link to details]
2. Then learn [next concept] → [link]
3. Finally [final concept] → [link]

**Key Resources:**
- [Documentation](url)
- [Tutorial](url)
- [Full conversation](source)

**Progress:**
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3
```

### Tutorial/Checklist

```markdown
---
title: How to [Task]
created: YYYY-MM-DD
modified: YYYY-MM-DD
publish: false
tags: [tutorial, how-to, tags]
description: [Brief description of what this tutorial covers]
source: [Chat URL]
type: tutorial
---

# How to: [Task]

**Purpose:** One-line description of what this accomplishes

**Prerequisites:**
- Requirement 1
- Requirement 2

**Steps:**
1. First step - brief description
2. Second step - brief description  
3. Third step - brief description

**Verification:**
How to confirm it's working correctly

**Troubleshooting:**
- **Issue:** Solution → [details](source#section)
- **Issue:** Solution → [details](source#section)

**Full Details:** [Complete conversation with all technical specifics](source)
```

### Problem Space

```markdown
---
title: [Problem Name]
created: YYYY-MM-DD
modified: YYYY-MM-DD
publish: false
tags: [problem, relevant, tags]
description: [One-line problem summary]
source: [Chat URL]
type: problem-space
---

# Problem: [Brief Description]

**Context:** One-sentence framing of the situation

**The Challenge:**
Brief description of the core problem

**Constraints:**
- Constraint 1
- Constraint 2
- Constraint 3

**Possible Approaches:**
- **Option A:** Brief description → [details](source#approach-a)
- **Option B:** Brief description → [details](source#approach-b)
- **Option C:** Brief description → [details](source#approach-c)

**Decision:** [If made] We chose [option] because [brief reason]

**Resources:**
- [Full conversation](source)
- [External reference if applicable]
```

### Other/General

```markdown
---
title: [Title]
created: YYYY-MM-DD
modified: YYYY-MM-DD
publish: false
tags: [relevant, tags]
description: [Brief description]
source: [Chat URL]
type: [user-specified-type]
---

# [Title]

**Purpose:** Why this conversation happened

**Key Points:**
- Point 1
- Point 2
- Point 3

**Outcomes:**
- Outcome 1
- Outcome 2

**Next Steps:**
- [ ] Action 1
- [ ] Action 2

**Full Details:** [Complete conversation](source)
```

## Guidelines

**Keep it Brief:**
- Summaries should be scannable (< 200 words typically)
- Use bullet points and lists over paragraphs
- Hyperlink to chat for details, don't duplicate content
- Only include essential information in summary

**Good Examples:**
- ✅ "Set up EEG streaming → [full setup guide](chat)"
- ✅ "Three approaches possible → [detailed comparison](chat#approaches)"

**Avoid:**
- ❌ Copying large code blocks or detailed instructions into summary
- ❌ Repeating information that's in the chat
- ❌ Long paragraphs of explanation

**Filename Generation:**
- Convert topic to lowercase
- Replace spaces with underscores
- Remove special characters except underscores and hyphens
- Keep under 50 characters when possible
- Example: "Muse EEG Streaming Setup" → `muse_eeg_streaming_setup.md`

**Tags:**
- Include 2-5 relevant tags
- Use existing tag conventions from vault when possible
- Common tags: project, learning, tutorial, technical, creative, planning

## Implementation Notes

- Always use Desktop Commander's `write_file` tool to save to vault
- **Vault location** - Use memory first, filesystem check as fallback:
  - Memory contains username and vault path for both laptops
  - If not in memory, detect username from `/Users/` directory
  - Work laptop (matt.fisher): `/Users/matt.fisher/Obsidian/_ideas/`
  - Personal laptop (matt): `/Users/matt/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/_ideas/`
- Files are saved directly to `_ideas/` folder
- User will manually move/organize files later if needed for publishing
- Always get chat URL for `source` field before creating summary
- **Daily Note Integration:**
  - After creating a summary, add review reminder to today's daily note
  - Format today's filename: `YYYY-MM-DD, DayOfWeek.md` (e.g., `2026-02-10, Tuesday.md`)
  - Location: `_autofocus/YYYY-MM-DD, DayOfWeek.md`
  - Append to ## Notes section: `- [ ] Review [[filename]] for project potential`
  - If Notes section doesn't exist, create it at the end of the file
  - This creates the bridge between idea capture and daily review
