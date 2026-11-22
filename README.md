# agent-skills

Claude skills packaged for [APM](https://microsoft.github.io/apm/), split by audience.

| Package | Contents | Audience |
|---|---|---|
| `packages/spec-workflow` | constitution, specify, clarify, plan, tasks, analyze, implement, amend-constitution, project-scaffolder, brownfield-analysis | Anyone planning or documenting a project |
| `packages/session-hygiene` | finishing-a-session, systematic-debugging, verification-before-completion, coding-assessment-artifacts | Anyone using Claude |
| `packages/productivity` | obsidian-chat-summarizer, gtd-project-planner (vault via `OBSIDIAN_VAULT`) | Obsidian + GTD users |
| `packages/max-msp` | gen-tilde-codebox, jit-gen-codebox, maxpat-json-authoring, max-patch-notation, max-advanced-object-methodology, pfft-spectral-processing | Max/MSP developers |
| `packages/f-library` | vsynth-bpatcher, f-helpfile, bench-test-authoring, module-preflight | Contributors to the f_ library |

## Install

```yaml
# apm.yml of your project
dependencies:
  apm:
    - mttfshr/agent-skills/packages/spec-workflow#v1.0.0
    - mttfshr/agent-skills/packages/session-hygiene#v1.0.0
    - mttfshr/agent-skills/packages/max-msp#v1.0.0
```

Then run `apm install`. Every package has the same shape: `packages/<name>/apm.yml` plus `packages/<name>/skills/<skill>/SKILL.md`. The root `apm.yml` just bundles them all.

The Max skills read an optional `local.md` next to `SKILL.md` for project-specific notes. `local.md` files are not packaged; they stay in the project that owns them.
