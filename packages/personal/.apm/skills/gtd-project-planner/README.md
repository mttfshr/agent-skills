# GTD Project Planner

A Claude skill for creating and managing GTD-style project planning documents in Obsidian, with outcome-driven task development and automatic integration with Autofocus daily workflow.

## Features

- **Outcome-Driven Planning**: Every project starts with a clear definition of "done"
- **Interactive Task Development**: Conversationally explore and develop task lists
- **Automatic Integration**: Tasks in project docs flow into daily notes via Tasks plugin query
- **Summary Linking**: Automatically creates and links conversation summaries
- **Flat File Structure**: Simple `Projects/` directory with status via metadata
- **GTD Methodology**: Follows Getting Things Done principles for project management

## Usage

### Create a New Project
```
"Create a project for [topic]"
"Let's plan out the playa-events migration"
```

### Develop Tasks for a Project
```
"Let's add tasks to the playa-events project"
"Help me think through what needs to happen for [project]"
```

### Update a Project
```
"Update the outcome for [project]"
"Add more context to [project]"
```

## Integration with Obsidian

### Directory Structure
```
Projects/
├── playa-events-migration.md
├── website-redesign.md
└── video-synthesis-system.md
```

### Task Query Integration

Projects integrate with the daily Autofocus workflow via this Tasks plugin query in daily notes:

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

Tasks written in project docs automatically appear in daily burndown without manual copying.

### Task Status Workflow

1. Tasks created as `- [ ]` in project docs during planning
2. During daily review, assign status markers:
   - `[<]` Do later
   - `[>]` Do next  
   - `[/]` Doing now
   - `[x]` Done
3. Tasks flow into daily note based on status
4. Natural burndown as work progresses

## Project Template Structure

```markdown
---
status: active
created: 2026-02-09
updated: 2026-02-09
tags: [project]
---

# Project Name

## Outcome
What "done" looks like

## Context
Why this matters, constraints, dependencies

## Tasks
- [ ] Tasks emerge during planning/review

## Thinking
Working through the approach

## References
- [Summary](link.md)
- [Chat](url)
```

## Status Management

Projects use metadata for status tracking:
- `active`: Currently working on
- `someday-maybe`: Future consideration
- `archived`: Completed or cancelled

View projects grouped by status using Dataview:

```dataview
TABLE status, updated
FROM "Projects"
WHERE status != "archived"
SORT status ASC, updated DESC
```

## Design Philosophy

**Outcome First**: Every project starts with defining what success looks like. This drives all task development.

**Minimal Friction**: Tasks stay in project docs, no manual copying. Review happens naturally during daily Autofocus scan.

**Conversation-Driven**: Task development happens through dialogue, not filling in templates. The skill helps you think through what needs to happen.

**GTD Aligned**: Follows Getting Things Done methodology - projects have clear outcomes, tasks are concrete actions, review happens regularly.

## Dependencies

- **Desktop Commander**: For file system operations
- **obsidian-chat-summarizer**: For creating/linking conversation summaries
- **Obsidian Tasks Plugin**: For task queries and status markers
- **Obsidian Dataview** (optional): For project dashboards

## Author

Created for Matt Fisher's GTD + Autofocus workflow in Obsidian.
