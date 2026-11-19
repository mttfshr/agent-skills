# agent-skills

Claude skills packaged for [APM](https://microsoft.github.io/apm/), split by audience.

| Package | Contents | Audience |
|---|---|---|
| `packages/spec-workflow` | constitution, specify, clarify, plan, tasks, analyze, implement, amend-constitution, project-scaffolder, brownfield-analysis | Anyone planning or documenting a project |
| `packages/session-hygiene` | finishing-a-session, systematic-debugging, verification-before-completion, coding-assessment-artifacts | Anyone using Claude |
| `packages/personal` | obsidian-chat-summarizer, gtd-project-planner (vault via `OBSIDIAN_VAULT`) | Obsidian + GTD users |

Max/MSP skills live in the f_ repo and are packaged there.

## Install

```yaml
# apm.yml of your project
dependencies:
  apm:
    - OWNER/agent-skills/packages/spec-workflow#v2.0.0
    - OWNER/agent-skills/packages/session-hygiene#v1.0.0
```

Then run `apm install`. Edit skills only under `packages/*/.apm/skills/`.
