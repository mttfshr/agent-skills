# Obsidian Chat Summarizer Skill

## Installation

To install this skill in Claude.ai:

1. **Upload the skill folder**:
   - Go to your Claude.ai Project settings
   - Find the "Skills" section
   - Upload the entire `obsidian-chat-summarizer` folder

2. **Enable the skill**:
   - Toggle the skill on in your Project settings

## Usage

Once installed, you can trigger the skill by saying things like:

- "Summarize this to Obsidian"
- "Save this conversation to my vault"
- "Document this chat"
- "Create notes for this conversation"

Claude will:
1. Ask what type of summary you want (project idea, learning path, tutorial, problem space)
2. Generate a brief summary with your frontmatter format
3. Save it to your Obsidian vault root with an auto-generated filename

## Features

- **Intent-driven**: Different templates for different purposes
- **Brief by default**: Summaries link to chat for details instead of duplicating content
- **Your frontmatter**: Uses a standard note format
- **Auto-naming**: Generates filenames from conversation topic
- **Vault integration**: Saves to `$OBSIDIAN_VAULT/_ideas/` (set `OBSIDIAN_VAULT` in your shell profile, or the skill asks once)

## Template Types

1. **Project Idea** - Capture concepts with status and next steps
2. **Learning Path** - Track what you're learning with progress checklist
3. **Tutorial/Checklist** - Step-by-step guides with troubleshooting
4. **Problem Space** - Document challenges with possible approaches
5. **Other/General** - Flexible format for any conversation

All summaries include:
- Your standard frontmatter (`title`, `created`, `modified`, `publish`, `tags`, `description`)
- Additional fields: `source` (chat link), `type` (intent category)
- Hyperlinks back to the chat for detailed information

## Notes

- Summaries are saved to vault root (you can move them later)
- `publish: false` by default (change when ready for your website)
- Designed for quick scanning with details linked, not duplicated
