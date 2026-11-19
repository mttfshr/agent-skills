---
name: gtd-project-planner
description: Create and manage GTD project planning documents with outcome-driven task development. Use when user wants to create a project plan, develop tasks for a project, or update project documentation. Triggers include "create a project for [topic]", "let's plan out [project]", "add tasks to [project]", "update [project] plan".
---

# GTD Project Planner

Create outcome-driven project plans in Obsidian following GTD methodology, with support for interactive task development and automatic integration with daily Autofocus workflow.

## Core Concepts

**Projects Directory:** `_projects/` (flat structure, status via metadata)

**Vault Location:**
- Use memory first (contains username and vault paths for both laptops)
- If not in memory, detect username from `/Users/` directory:
  - `/Users/matt.fisher/` → work laptop, vault: `/Users/matt.fisher/Obsidian`
  - `/Users/matt/` → personal laptop, vault: `/Users/matt/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian`

**Integration:** Tasks in project docs automatically appear in daily note via Tasks plugin query

## Workflow

### 1. Create New Project

When user requests a new project plan:

1. **Clarify Outcome** - Ask: "What does 'done' look like for this project?" (This is critical - the outcome drives everything)

2. **Generate Project Filename**
   - Convert project name to kebab-case
   - Example: "Playa Events System" → `playa-events-system.md`
   - Location: `_projects/{filename}`

3. **Check for Chat Summary**
   - Determine if a summary already exists for this conversation
   - If not, trigger `obsidian-chat-summarizer` skill to create one
   - Get summary filename for reference linking

4. **Create Project File** using template below

5. **Add Review Reminder to Today's Daily Note**
   - Append to Notes section: `- [ ] Review [[filename]] for todos to add`
   - Format: `YYYY-MM-DD, DayOfWeek.md` in `_autofocus/` directory
   - Example: `2026-02-10, Tuesday.md`

6. **Confirm** - Tell user the project has been created and link to summary

### 2. Interactive Task Development

When user wants to develop tasks for a project:

1. **Load Project** - Read the existing project file from `_projects/`

2. **Display Outcome** - Show the outcome to ground the conversation

3. **Conversational Exploration**
   - Ask: "What needs to happen to achieve this outcome?"
   - Discuss approach, break down work
   - Think through dependencies, blockers, unknowns

4. **Write Tasks** - Add tasks to `## Tasks` section as you discuss
   - Use `- [ ]` format (user assigns status during review)
   - Tasks flow into daily note automatically via query
   - Keep tasks actionable and concrete

5. **Update Metadata** - Set `updated` field to current date

### 3. Update Project

When user wants to modify a project:

1. **Read Existing Project**

2. **Update Requested Sections**
   - Outcome refinement
   - Context changes
   - Additional thinking/notes

3. **Update Metadata** - Set `updated` field

## Project Template

```markdown
---
status: active
created: {{YYYY-MM-DD}}
updated: {{YYYY-MM-DD}}
tags: [project]
---

# {{Project Name}}

## Outcome

{{What "done" looks like - clear definition of success}}

## Context

{{Why this matters, background, constraints, dependencies}}

## Tasks

{{Tasks emerge here during planning and review}}
{{Written as - [ ] initially, user assigns status markers during review}}

## Thinking

{{Working through the approach, notes, evolving understanding}}

## References

- [Conversation Summary](link-to-summary.md)
- [Chat]({{chat_url}})
{{Additional links, related docs}}
```

## Field Guidelines

**Frontmatter:**
- `status`: `active` | `someday-maybe` | `archived`
- `created`: Date project was created (YYYY-MM-DD)
- `updated`: Date of last modification (YYYY-MM-DD)
- `tags`: Always include `project`, add others as relevant

**Sections:**
- **Outcome**: One clear paragraph describing what success looks like
- **Context**: Why this matters, what depends on it, constraints
- **Tasks**: Actionable items that emerge during planning/review
- **Thinking**: Scratchpad for working through approach, decisions
- **References**: Links to summaries, chats, related docs

## Task Integration

Tasks written in project docs automatically appear in daily notes via this query:

```tasks
not done 
path includes _autofocus OR path includes Projects
hide recurrence rule
hide task count
hide backlink
hide tags
group by status.name
group by function task.tags
filter by function ' />'.includes(task.status.symbol)
```

**Task Workflow:**
1. Tasks created as `- [ ]` in project doc
2. During daily review, user assigns status:
   - `[<]` Do later
   - `[>]` Do next
   - `[/]` Doing now
   - `[x]` Done
3. Tasks appear in daily note based on status
4. Natural burndown without manual copying

## Implementation Notes

## Implementation Notes

**File Operations:**
- Use Desktop Commander's `write_file` and `read_file`
- **Vault location** - Use memory first, filesystem check as fallback:
  - Memory contains username and vault path for both laptops
  - If not in memory, detect username from `/Users/` directory
  - Work laptop (matt.fisher): `/Users/matt.fisher/Obsidian/_projects/`
  - Personal laptop (matt): `/Users/matt/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/_projects/`
- Always update `updated` field when modifying

**Summary Integration:**
- Check if conversation summary exists
- If not, trigger `obsidian-chat-summarizer` to create one
- Link to summary in References section
- Always include chat URL in References

**Chat URLs:**
- Get current chat URL before creating project
- Format: `https://claude.ai/chat/{chat_id}`
- Include in References section

**Status Markers:**
- New projects default to `status: active`
- User manually updates status as needed
- Status enables Dataview queries grouped by status

**Daily Note Integration:**
- After creating/updating a project, add review reminder to today's daily note
- Format today's filename: `YYYY-MM-DD, DayOfWeek.md` (e.g., `2026-02-10, Tuesday.md`)
- Location: `_autofocus/YYYY-MM-DD, DayOfWeek.md`
- Append to ## Notes section: `- [ ] Review [[project-filename]] for todos to add`
- If Notes section doesn't exist, create it at the end of the file
- This creates the bridge between project creation and daily task commitment

## Example Interactions

**Creating a Project:**
```
User: "Let's create a project for the playa-events migration"
Claude: "What does 'done' look like for the playa-events migration?"
User: "Django app running in Docker, all data migrated from old system, documentation complete"
Claude: [Creates project, creates/links summary, confirms]
```

**Developing Tasks:**
```
User: "Let's plan out tasks for playa-events-migration"
Claude: [Loads project, shows outcome]
"To achieve: 'Django app running in Docker, all data migrated...'
What's the first thing that needs to happen?"
User: "We need to set up the Docker environment"
Claude: [Adds task, continues conversation]
"What about the data migration piece?"
[Continues iteratively building task list]
```

**Updating a Project:**
```
User: "Update the playa-events outcome - we also need API documentation"
Claude: [Reads project, updates Outcome section, sets updated date]
```

## Guidelines

**Keep Outcomes Clear:**
- One paragraph maximum
- Specific, verifiable definition of "done"
- Avoid vague goals like "improve" or "explore"

**Tasks Should Be Actionable:**
- Start with verbs: "Set up", "Write", "Deploy", "Test"
- Concrete enough to know when complete
- Not too granular (review/refine during daily Autofocus)

**Context Should Explain "Why":**
- What problem does this solve?
- What depends on it?
- What constraints exist?

**Thinking Section Is Dynamic:**
- Evolves as you work through the project
- Captures decisions, trade-offs, realizations
- Not a static plan

**References Connect the Dots:**
- Link to conversation summaries
- Link to related projects
- Link to external resources
- Always include chat URL for full context
