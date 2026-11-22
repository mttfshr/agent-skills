# Consolidation plan: agent-skills as the single source of skills

Written 2026-11-22. Status: plan agreed in direction by Matt; D1 and D2 decided, D3-D5 not yet confirmed.

## Goal

Every skill file originates in this repo, is distributed from here, and is installed or referenced
from projects through APM, whether the project is Matt's (f_, others) or someone else's. Matt always
knows where an edit goes: here.

## Decided (Matt, 2026-11-22, chat)

- All skills originate in `agent-skills`; other copies are generated or installed, never edited.
- Distribution is via APM, for Matt's own projects and for other people's.
- Replaces the earlier idea of a one-way sync script from f_/skills (rejected: it kept two sources).

## State today (measured 2026-11-22)

Three copies, no stated direction of flow.

| Copy | Role today | State |
|---|---|---|
| `claude-scaffold/skills-for-upload/{workflow,session-workflow}-skills/` | source for spec + session skills; zips built from it | has the verification-thread edits (uncommitted); agent-skills does not |
| `f_/skills/` | source for Max/f_ skills; `claude-scaffold/skills/` symlinks into it | content matches agent-skills apart from portability edits; has evals/, MANIFEST.md, check.sh, 3 `local.md` sidecars, untracked zips |
| `agent-skills/packages/*` | sanitised copy taken 2026-11-19 | spec-workflow and session-hygiene/verification-before-completion stale; f-library, max-msp, productivity content-current |

Other facts:
- agent-skills has no git remote and no tags; README still says `OWNER`. f_ is `github.com/mttfshr/f_`, no tags.
- `finishing-a-session` in agent-skills already equals the scaffold working tree (including Matt's uncommitted step).
- `project-scaffolder` (agent-skills) intentionally differs from `scaffold-meta` (scaffold); leave alone.
- `constitution-workflow/references/{core,validator,workflow}.md` here are the same files as scaffold `templates/`. `core.md` here is already generic; scaffold's has `/Users/matt`. `validator.md` here lacks the new Mechanical Checks table.
- Skills are named `<x>-workflow` here and `<x>` in scaffold; only the folder/frontmatter names differ.
- f_ `skills/MANIFEST.md` (stamped 2026-11-15) tracks last claude.ai upload; `skills/check.sh` reports staleness.
- `scripts/check-portable.sh` uses a relative `packages` path: run it from the repo root.

## Target layout

- Source: `packages/<pkg>/skills/<skill>/`, the only editable copy. Project-neutral, enforced by `scripts/check-portable.sh`.
- Consumers (f_, Matt's projects): `apm.yml` lists the packages; `apm install` deploys to `.claude/skills/` (generated, never hand-edited).
- Others: `apm install mttfshr/agent-skills/packages/<pkg>#vX.Y.Z`.
- claude.ai uploads: a script builds zips from here; the upload-staleness manifest moves here.
- Evals move here (they test skill descriptions).
- Retired: `f_/skills/`, `claude-scaffold/skills/` symlinks, scaffold `skills-for-upload/` source folders.

## Use cases to solve for (Matt, 2026-11-22)

1. Solo, two laptops, a personal Pro account and a work Team account: skills being honed must be usable on either machine under either account.
2. Claude Desktop on both machines is the UI for both chat and code.
3. Terminal use of `omp` and `pi`: skills must be reachable from them too.
4. Later (not now): package and distribute the f_, Max and workflow skills to colleagues and friends.
5. For his own projects: install skills in one place, update a skill centrally once, and have it apply everywhere on both laptops. No preference where that place is.

Findings that bear on these (docs/web, 2026-11-22; see sources in the chat that produced this file):
- pi reads `~/.pi/agent/skills/` and `~/.agents/skills/` globally, `.agents/skills/` in the project and ancestors, and can be pointed at `~/.claude/skills` through its `skills` setting. omp inherits the Agent Skills standard; a third-party doc says its `agents` provider reads `~/.agents/skills/`, and omp's discovery has native, Claude, Codex and Agents providers (details unverified).
- APM `-g` installs to user scope `~/.apm/` and deploys to user-level harness dirs (`~/.claude/` for target claude, honouring `CLAUDE_CONFIG_DIR`). Its `agent-skills` target writes `.agents/skills/` (cross-client). pi and omp are not named APM targets. Whether `-g` accepts a local path, and the exact user-scope path for `agent-skills`, are undocumented in the pages reached.
- claude.ai uploads are per account, so the upload channel doubles with two accounts (Pro and Team). Whether a Team member can upload personal skills is unverified.
- Claude Code docs: symlinked skill entries at personal or project level are supported and loaded once.
- Claude Desktop's own personal-skills storage may differ from `~/.claude/skills` (user report, Windows paths); unverified for the Code tab on macOS.

Claude Code `synced/` folder (docs, read 2026-11-22): Claude Code downloads the account's claude.ai skills into `~/.claude/skills/synced/` at session start and keeps checking while the session runs; loads previously synced skills in later sessions signed in to the same account; never uploads. Edits under `synced/` are not saved to the account and "a later sync can overwrite or remove it"; deleting the directory by hand makes the next sync download it again while the skill stays enabled. Not documented: whether a hand-copied skill there is recognized or kept, and what happens to the folder when switching between the Pro and Team accounts. Therefore `synced/` is NOT a deploy target. Controls: setting `syncClaudeAiSkills` to false in user settings stops Claude Code downloading and, on next start, moves already-synced skills to `~/.claude/skills/.trash/`; per-skill on/off in claude.ai skills settings controls what syncs; synced skills appear as `/anthropic-skills:<name>` (or `/<name>` when no other command has that name). Using `syncClaudeAiSkills: false` would remove the dual-loading risk in Claude Code, leaving uploads for chat/Cowork only (candidate for D6).

Matt's goal on chat (2026-11-22): make skills available to chat WITHOUT uploading them to claude.ai; if uploading is unavoidable, the flow should just do that rather than a separate local install. Facts: docs say Cowork and cloud sessions load the skills enabled for the claude.ai account and do not read `~/.claude/skills/` on the machine, so native skill behaviour in chat needs an upload. Local files are still needed for pi/omp and for a zero-step edit loop in Claude Code, so upload-only does not replace the local layer. Options to cut upload frequency (D9, undecided): (a) router skill: upload one small stable skill per account whose body is an index of the repo's skills and says to read the real SKILL.md from the connected agent-skills folder when a task matches (the pattern `scaffold-meta` already uses); no per-edit uploads, but works only when the computer is linked and the folder connected, and per-skill description matching is lost; (b) upload only the skills that must trigger natively in chat, router for the rest; (c) look at whether Claude Desktop reads skills from its own app-data folder (user report, unverified; Claude's data folders cannot be inspected from this session, so Matt would check).

Proposed design (D8, not yet confirmed by Matt): source = one clone of this repo per laptop at the same relative path, synced with git pull; local deploy = symlinks from `~/.claude/skills/<skill>` and `~/.agents/skills/<skill>` to the clone, made by `scripts/link-skills.sh` (computed from `$HOME`, nothing machine-specific committed), giving zero-step edits for Claude Code, pi and omp; claude.ai upload for chat/Cowork, done per account with a per-account manifest stamp; APM kept for releases and for other people. This would supersede the local-path decision in D2 for his own machines.

## Workflows (as decided)

- **Edit a skill (own projects):** edit in the agent-skills checkout, then `apm install` in the project (local-path dependency). Never edit `.claude/skills/` in a project; it is generated.
- **Release (for other people):** commit, push, tag. Others pin the tag: `apm install mttfshr/agent-skills/packages/<pkg>#vX.Y.Z`.
- **claude.ai upload (chat and linked sessions):** edit here, `scripts/build-zips.sh` (one zip per skill), upload the changed zips in claude.ai (manual, no automation known), then `check.sh stamp`. `check.sh` before uploading lists which skills are stale. After D1 the manifest hash covers only the skill folder, not project notes.
- Docs say (code.claude.com/docs/en/skills, read 2026-11-22): same-name precedence is enterprise > personal (`~/.claude/skills`) > project (`.claude/skills`); plugin skills are namespaced and both load. Terminal Claude Code syncs claude.ai-account skills into `~/.claude/skills/synced/` only in sessions signed in with a claude.ai account (not API key, Bedrock, bare mode, `--safe-mode`); synced skills do not take a plain `/name` that another command uses and run as `/anthropic-skills:<name>`; edits under `synced/` are not saved back and may be overwritten; Cowork and cloud sessions load account skills and do not read `~/.claude/skills`. A 2026 GitHub issue reported org-uploaded skills missing from the CLI, so behaviour may vary by version. Not yet tested on Matt's setup: see T040 item g and the test recipe there.
- Uploaded skills reach chat-style and desktop-linked sessions (this chat lists `anthropic-skills:*`). Claude Code sessions read the filesystem (`.claude/skills/`, `~/.claude/skills/`), which is where `apm install` writes. Whether local Claude Code sessions ALSO list uploaded skills, and what happens when a skill is both installed and uploaded, is unverified (T040 item g).

## Measured on the personal laptop, 2026-11-22 (Desktop Commander)

- Desktop Commander runs commands on the real Mac (HOME=/Users/matt); the chat shell does not. Use it for anything under `~/.claude`, `~/.agents`, `~/.omp`, `~/.pi`.
- `~/.claude/skills/` held only `synced/` (from Nov 15): account sync is active. `synced/` contains one bucket folder named by two UUIDs holding 43 skills; with two accounts (Pro, Team) expect one bucket each (inference, not yet seen).
- Against the repo: only `brownfield-analysis` and `systematic-debugging` are byte-identical to the uploaded copies; 23 differ (stale uploads and/or the sanitising edits); 18 uploaded skills are not in agent-skills, of which about a dozen are Anthropic's account skills and five are Matt's own (see T033).
- `~/.agents/skills` did not exist. `pi` 1.0.4 and `omp` 18.13.2 are installed. pi settings had no skills config. omp's `config.yml` already lists claude-scaffold skill folders under `skills.customDirectories` (see T029).

## Claude Code `/skills` observation, personal laptop, 2026-11-22 (Matt pasted the lower part of the list)

- The four symlinked skills are listed with source `user`, about 100 tokens each, so Claude Code accepts symlinks in `~/.claude/skills` and treats them as personal skills.
- In the pasted part, `systematic-debugging` and `verification-before-completion` appear only as `user`; their `claude.ai sync` copies (which exist in the synced bucket) are not listed. So a same-name personal skill seems to replace the synced copy in the list, not duplicate it. Not yet seen for `finishing-a-session` (above the pasted part). Description cost per skill is roughly 50 to 350 tokens; linking replaces synced copies, so it should not add to the total.
- Still untested: an edit in the repo showing up in a running session, whether the model uses the personal copy rather than the synced one at invocation, and the same on the work laptop with the Team account.

## Where the work runs

- The chat session's linked-computer shell has `git` and `python3` but no `apm` and no `gh`. Anything that needs `apm`, network pushes or tagging (T040, Phase 3, Phases 5-6 cutovers) belongs in a Claude Code session on Matt's machine.
- File ports and diffs (Phase 1, most of Phase 2) can run in either.
- This directory is the handoff: a Code session opened in the repo should start from `plan.md` and `tasks.md` (see T001).

## Principle: one source, several generated copies, drift must be detectable

Matt's concern (2026-11-22): installing skills locally AND uploading to claude.ai creates multiple copies that can disagree. Accepted framing: the source of truth is single (this repo); every other copy is generated (apm install into `.claude/skills/`, zips uploaded to claude.ai, and the copy Claude Code syncs back into `~/.claude/skills/synced/`). The risks are (1) a stale copy, mainly the manual upload, (2) one session loading two copies of the same skill, (3) a stale personal `~/.claude/skills` copy shadowing an up-to-date project install because personal beats project.
Design goal: copies are identical at the same commit, and any difference is reported by a check, not discovered by surprise. If copies are always identical, dual loading is harmless.

## Open decisions (confirm with Matt before the tasks that depend on them)

- **D1, local.md home. AGREED by Matt 2026-11-22.** Three skills (gen-tilde-codebox, jit-gen-codebox, maxpat-json-authoring) say "if a `local.md` sits next to this file, read it". f_ holds 115/45/32 lines of f_-only notes there. A generated install folder can be overwritten. Proposal: skills read a fixed project path `.claude/local/<skill>.md`; notes live and are committed in the consuming project. Alternative (rejected): keep them in agent-skills, which would publish f_-only material.
- **D2, how projects see an edit. DECIDED by Matt 2026-11-22.** Own projects: local-path dependency on the agent-skills checkout; edit at the source, then `apm install` in the project (2 steps). Release workflow: commit, push, tag; other people pin tags. Fallback if APM does not re-copy a changed local source: symlinks from `.claude/skills/`. Open: `../` vs absolute path (two laptops with different home paths), tested in T040.
- **D3, generated skills in consumer repos.** Proposal: gitignore `.claude/skills/`, commit `apm.lock.yaml`. A fresh clone needs `apm install` first.
- **D4, hosting and audience.** Public or private repo; whether `f-library` is for contributors or only Matt (its skills only work inside an f_ checkout); review `max-msp` for anything not to publish if public.
- **D6, channel per surface (open, depends on the T040g result).** Option A: for his own use the claude.ai upload is the only channel (Claude Code gets it by sync), and apm is for other people and pinned releases; one deploy step, but depends on sync working and on being signed in with a claude.ai account. Option B: apm for Claude Code, upload only the subset needed in chat/Cowork; the overlap is still duplicated. Option C (current default): both channels for everything, kept identical and checked by `check.sh`. If T040g shows messy dual loading, move to A or B.
- **D7, personal-scope links (under consideration, Matt asked 2026-11-22 whether `~/.claude/skills/` could BE the repo).** Not as the repo root: Claude Code needs `~/.claude/skills/<skill>/SKILL.md` one level deep and reserves `~/.claude/skills/synced/`, which clashes with the `packages/<pkg>/skills/<skill>` APM layout; personal scope loads every skill in every project on the machine (f_-only skills included); it does not touch the claude.ai upload channel; two laptops still each need a clone. Variant to evaluate: symlinks from `~/.claude/skills/<skill>` to the agent-skills checkout for the general packages (spec-workflow, session-hygiene, max-msp, productivity), via `scripts/link-personal.sh`; `f-library` stays project-scoped (apm into f_). Zero-step edit loop for general skills, no per-project install. Docs say symlinked skill entries at personal level are supported. Test in T042.
- **D5, what remains of claude-scaffold.** Its `templates/` duplicates `references/`; decide the one home. Docs and QUICKSTART stay unless Matt says otherwise.

## Costs accepted

- A f_ change that needs a skill edit now spans two repos and two commits. Note this in f_ `CLAUDE.md`.
- f_ `module-preflight` work (`.specify/preflight/` T030, T033) now lands here, then f_ updates.
- Consumers must run `apm install` after a skill edit; never edit `.claude/skills/` in a project (generated, overwritten on install).

## Not verified yet

- APM accepts a relative `../` local path dependency.
- APM deploys to `.claude/skills/` for `targets: claude` as expected, and how it treats extra files (evals, MANIFEST, local.md).
- Whether a one-folder install clones the whole repo.
- max-msp diffs against f_/skills read in full (f-library diffs were; max-msp only by line count).
- `f_/skills/` has no uncommitted skill edits (only untracked zips seen so far).
- Pass G and the Verify thread on a real spec (separate dry run, claude-scaffold work).

## Order of work

1. Content currency here (port verification edits; confirm f_/skills adds nothing missing).
2. Move tooling here (evals, zip build, manifest) and settle D1.
3. Publish: remote, README, tag.
4. Scratch test of `apm install` (local path, tag pin, deploy dir, sidecars).
5. Cut over f_.
6. Cut over claude-scaffold.

Deletions in connected folders need Matt's permission each time; move to `_to_delete/` if declined.

## Rejected approaches (and why)

- **One-way sync from f_/skills to agent-skills (sanitise on copy).** Keeps two sources; the 2026-11-19 copy was stale within two days.
- **Install straight from `mttfshr/f_/skills/<name>`.** f_ has no tags (versions would track library releases, pins would be SHA or branch); each skill folder carries evals, MANIFEST and local.md sidecars; unverified whether APM fetches the whole repo for a one-folder install.
- **Edit the installed copy, copy back at session close.** A forgotten copy-back loses the edit and `apm install` may overwrite it silently; it recreates multiple sources. Dropped in favour of edit-at-source.
- **Keep `local.md` inside agent-skills.** Would publish f_-only notes (115/45/32 lines) to a repo others install from.
- **Git branch or tag pin for Matt's own projects.** 4-5 steps per skill edit; too slow for iterating. Kept for other people and releases.
- **Symlinks from `.claude/skills/` as the primary route.** 1 step, but own projects would bypass APM. Kept only as the fallback if a local path is not re-copied (T040b).

## APM facts relied on (docs, checked 2026-11-22)

- Dependency forms include GitHub shorthand with `#tag`/`#branch`/`#sha`, virtual subdirectory (one skill folder from a repo), and local path (`./packages/x` or `/abs/path`, labelled development only). Source: https://microsoft.github.io/apm/consumer/install-packages/ and the manage-dependencies page (that URL fetched as a redirect stub; the table came from a search snippet).
- Installs are staged under `apm_modules/` and recorded in `apm.lock.yaml`. Source: https://microsoft.github.io/apm/producer/source-vs-installed/.
- `--dev` adds a dependency under `devDependencies`.
- No link, watch or override command was found. The docs reach was incomplete, so this is "not found", not "absent".

## Constraints from Matt

- Solo, main-branch only, more or less permanent: no PR or CI gates designed here.
- Unzipped skill files are the source of truth; zips are artifacts built as needed.
- Two laptops with different home paths (work `/Users/matt.fisher`, personal `/Users/matt`, as the gtd skill records), so a committed absolute path breaks on the other machine.
- Matt reviews `git diff` and commits himself; deletions need his permission.

## Related work NOT tracked here

- **claude-scaffold:** the verification-thread edits (10 files, uncommitted) and Matt's separate `finishing-a-session` diff must be committed there before cutover (T061). Offered and still open: a dry run of the Verify thread and analyze pass G on a small feature in a scratch directory (T071).
- **f_ (own HANDOFF.md and `.specify/preflight/`):** Matt reviews nine content-past-frame modules; preflight Phase 1 starts at T010 there; `test_gates.py` not yet run; HANDOFF, gates.md and `.specify/preflight/` edits uncommitted. The constitution-drift question in f_ (amend via amend-constitution) was never answered.
- **Deferred by design:** invariant/property tests (need a bug-vs-bad-test triage step first), a fresh-context reviewer at checkpoints, PR/CI placement of verification.
