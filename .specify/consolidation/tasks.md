# Consolidation tasks

Format: `Verify:` says how the task is checked. Nothing here is committed or pushed until Matt says so.

## Phase 0: decisions (Matt)

- [x] D1 local.md home: project path `.claude/local/<skill>.md` (Matt agreed, 2026-11-22 chat)
- [x] D2 consumption: Matt decided 2026-11-22: own projects use a local-path dependency on the agent-skills checkout (edit at source, then `apm install` in the project: 2 steps). Tag/push/pin is part of releasing the repo, for other people. Fallback if T040 shows no re-copy: symlinks from `.claude/skills/`.
- [ ] D3 generated `.claude/skills/` gitignored, `apm.lock.yaml` committed (proposed)
- [ ] D4 public or private; audience for f-library; max-msp publish review
- [ ] D9 chat without per-edit uploads: router skill (upload once per account) vs upload the skills that must trigger natively vs both; also check whether Claude Desktop reads a local skills folder (Matt checks app-data)
- [ ] D8 own-machine deploy = symlinks into `~/.claude/skills` and `~/.agents/skills` from one clone per laptop (supersedes local-path D2 for own machines); upload per account; apm for releases and others (proposed 2026-11-22, see plan 'Use cases')
- [ ] D7 personal-scope symlinks for general packages (variant of using `~/.claude/skills/`): decide after T042
- [ ] D6 channel per surface (A upload-only for own use / B split by surface / C both, identical and checked): decide after T040g
  - Matt 2026-11-22: claude.ai (chat/Cowork) upload set = productivity (2) + spec-workflow (11) only, on each account. Max, session-hygiene, f-library and omp-tools skills reach Claude Code/omp via symlinks and are not uploaded; their old uploads on claude.ai are stale and can be deleted (also removes their `anthropic-skills:` duplicates in Claude Code). No CLI/API exists for claude.ai account skills (support docs; open feature request); replacing = delete + upload by hand, or browser automation (fragile).
- [ ] D5 home for constitution templates vs references; what stays in claude-scaffold

Still waiting on Matt: D3, D4, D5; whether to add the CLAUDE.md pointer now (T001); zips are per skill unless he says per package (assumed).

## Phase 1: content currency (no decisions needed)   (runs in chat or Code)

- [ ] T001 Add `CLAUDE.md` at the repo root: skills are edited only here, installed copies in projects are generated and never edited; point to `.specify/consolidation/plan.md` and `tasks.md`.
      Verify: file exists, mentions both paths, passes `check-portable.sh`.

- [x] T010 Port verification-thread edits into `packages/spec-workflow/skills/{specify,clarify,plan,tasks,analyze,implement,constitution,amend-constitution}-*`.
      Result: done 2026-11-22: patches from claude-scaffold applied; remaining diffs vs scaffold are only the constitution/amend-constitution `references/` path lines (the scaffold copies hold absolute `/Users/matt.fisher/...` paths)
      Source: `git diff` in claude-scaffold. Keep this repo's folder names and the `references/` wording in constitution and amend-constitution.
      Verify: `diff` of each SKILL.md against scaffold shows only name/frontmatter and references-path lines.
- [x] T011 Add the Mechanical Checks table to `constitution-workflow/references/validator.md`.
      Result: done 2026-11-22: diff against scaffold templates/validator.md is empty
      Verify: `diff` against scaffold `templates/validator.md` is empty.
- [x] T012 Port `verification-before-completion` edit to `packages/session-hygiene`.
      Result: done 2026-11-22: diff against scaffold copy is empty
      Verify: `diff` against scaffold copy is empty.
- [x] T013 Read the max-msp diffs against `f_/skills` in full; confirm they are only portability edits.
      Result: done 2026-11-22: only folded frontmatter, path/'Matt' portability edits; local.md and .DS_Store exist only in f_; fixed one lowercase 'The maintainer's' in parameters-and-ui.md
      Verify: list each differing line with its reason.
- [x] T014 Confirm `f_/skills` has no uncommitted or post-2026-11-19 content edits not present here (`git status`, `git log --since=2026-11-19 -- skills`).
      Result: done 2026-11-22: f_/skills content equals agent-skills apart from the sanitising edits; only untracked zips in git status; see output in chat
      Verify: output shown; anything found is ported or listed.
- [x] T015 Bump versions (spec-workflow 2.1.0, session-hygiene 1.1.0, root bundle) and fix README pins.
      Result: done 2026-11-22: spec-workflow 2.1.0, session-hygiene 1.1.0, root 2.1.0; README pins updated (tags not created yet)
      Verify: `apm.yml` versions and README agree.
- [x] T016 Run `sh scripts/check-portable.sh` from repo root; fix hits.
      Result: done 2026-11-22: check-portable.sh prints ok and exits 1 on a planted /Users/x line (run from repo root)
      Verify: prints `ok`. Check it fails once on a planted `/Users/x` line.

## Phase 2: move tooling here (needs D1; chat or Code)

- [ ] T020 Edit the three local.md-reading skills to the D1 path. Verify: grep shows no "next to this file" wording.
- [ ] T021 Move `f_/skills/evals/` to `agent-skills/evals/` (copy first, delete only with permission). Verify: file count and hashes match.
- [x] T027 Write `scripts/link-skills.sh` (symlinks each skill into `${CLAUDE_CONFIG_DIR:-~/.claude}/skills` and `~/.agents/skills`; dry-run, unlink, prune, never touches real files, refuses duplicate names).
      Result: done 2026-11-22; 11 sandbox tests pass (dry run, 52 links for 26 skills, idempotent, live edit visible, conflicts left alone, foreign link left alone, prune, unlink only ours, package/target subsets, duplicate refusal, CLAUDE_CONFIG_DIR). NOT yet run against Matt's real home: the chat shell cannot write there (see T028).
- [~] T028 (partly done 2026-11-22 via Desktop Commander on the personal laptop, /Users/matt): dry run for everything = 52 links, 0 conflicts; real run `--packages session-hygiene --targets claude` created 4 links in ~/.claude/skills (coding-assessment-artifacts, finishing-a-session, systematic-debugging, verification-before-completion), all resolve. Remaining: observe `/skills` in a new Claude Code session (linked and synced copies of the same skill, T040g/T043); link the rest and the agents target; check pi and omp; repeat on the work laptop after `git pull`. Undo: `scripts/link-skills.sh --unlink`. Original task text follows. Matt runs it on a laptop: `cd ~/Github/agent-skills && scripts/link-skills.sh --dry-run`, then for real (start with `--packages session-hygiene --targets claude`). Then check the skill list in Claude Code (`/skills`), pi and omp; undo with `--unlink`. Repeat on the second laptop after `git pull`.
  - Update 2026-11-22: all 28 skills linked into ~/.claude/skills on the personal laptop (claude target). `agents` target and pi not done; work laptop not done.
      Verify: each tool lists the linked skills once; an edit in the repo shows without any install; any conflicts reported are real pre-existing copies, which Matt decides about.
- [x] T022 Write `scripts/build-zips.sh`: one zip per skill from `packages/*/skills/*`. Verify: unzip one and diff against source.
  - Result 2026-11-22: `scripts/build-zips.sh` writes `dist/<skill>.zip` (gitignored; `<skill>/` at zip root, no __MACOSX/.DS_Store), all or named skills, `--out DIR`. Built all 28. Verified: unzip+diff identical for 3 skills (incl. one with references/ and one with scripts/); subset and unknown-name (exit 2); refuses description >1024 chars or containing < or > (exit 1, no zip written). Parses single-line, quoted and block-scalar (`>`, `>-`) descriptions: 12 skills use block scalars. NOTE: f_/skills/check.sh reads only the first line of `description:` and would misread `>-` as an XML tag; fix when porting (T023).
- [x] T023 Port `skills/check.sh` and `MANIFEST.md` here (staleness against last upload; `stamp` after uploading). After D1 the hash covers only the skill folder. Verify: `check.sh` reports clean after `stamp`, STALE after editing a SKILL.md.
  - Result 2026-11-22: `scripts/upload-check.sh` (check / names / stamp, per account) + shared `scripts/lib-skills.sh` (also used by build-zips.sh; block-scalar descriptions parsed). Manifests will live in `manifests/uploads-<account>.md` (pro, team); none stamped yet, so every skill reports NEW until Matt uploads and stamps. Verified in a scratch copy: clean after stamp; STALE after editing SKILL.md or a references/ file; subset stamp; NEW/REMOVED/INVALID; usage errors exit 2. Flow: `upload-check.sh names --account pro` -> `build-zips.sh <names>` -> upload -> `upload-check.sh stamp --account pro <names>`. Not ported: f_ evals dir (T021).
  - 2026-11-22: Pro stamped for all 28 skills (Matt uploaded all 28 by hand, not only the 13-skill chat set; the 15 Max/session/f_/omp uploads are therefore current but add `anthropic-skills:` duplicates in Claude Code) (browser automation not used: built-in browser not signed in; Claude in Chrome off for this chat). Team account not yet uploaded/stamped.
- [ ] T025 Extend `check.sh` to report drift of each deployed copy against source: the uploaded set (manifest), and installed copies in listed project directories (`check.sh --installed <project>`), including any same-named skill under `~/.claude/skills/`.
      Verify: edit a source skill; the check names the upload as stale and the project install as behind; after install/stamp both read clean.
- [ ] T024 Extend `check-portable.sh` to flag skill references to project-only paths other than the D1 notes path. Verify: planted hit fails.

- [~] T029 Update omp (personal laptop DONE 2026-11-22; work laptop open): `~/.omp/agent/config.yml` has `skills.customDirectories` pointing at claude-scaffold (`skills`, `skills-for-upload`, `.../workflow-skills`, `.../session-workflow-skills`). Replace with the five agent-skills `packages/*/skills` directories (omp scans them one level deep, which matches the layout), or rely on `~/.agents/skills` only; never both, or omp sees two copies. Needs Matt's go before editing his config. Do on both laptops.
  - Result (personal): customDirectories now the five agent-skills `packages/*/skills` dirs. `omp skill list` shows 26 skills, each once, no duplicates (so omp follows symlinks in ~/.claude/skills without double-listing, or dedupes by name). New to omp: module-preflight, bench-test-authoring; scaffold-meta no longer listed (no home in repo, T033). Undo: `cp ~/.omp/agent/config.yml.bak-2026-11-22 ~/.omp/agent/config.yml`.
  - Claude Code `/skills`: plain synced copies of the 3 linked session-hygiene skills are replaced by the `user` links; `anthropic-skills:`-namespaced copies still listed (separate namespace).
- [ ] T034 Work laptop checklist (/Users/matt.fisher; do in this order):
  1. `cd ~/Github && git clone https://github.com/mttfshr/agent-skills.git` (or `git pull` if present); `git log -1` should show the commit tagged v1.0.0 or later.
  2. `cd agent-skills && sh scripts/check-portable.sh` -> ok; `sh scripts/link-skills.sh --dry-run --targets claude` -> expect 28 links, 0 conflicts. If it reports CONFLICT for real folders in `~/.claude/skills` (old installs), move them aside first; do not delete.
  3. `sh scripts/link-skills.sh --targets claude`.
  4. Back up `~/.omp/agent/config.yml`, then replace its `skills.customDirectories` entries (claude-scaffold paths) with the six `~/Github/agent-skills/packages/{spec-workflow,session-hygiene,productivity,max-msp,f-library,omp-tools}/skills` dirs using the work laptop's absolute home path (`/Users/matt.fisher/...`). `omp skill list` should show 28 skills, each once.
  5. New Claude Code session on the work Team account: `/skills` should show the 28 as `user`; plain claude.ai-synced duplicates disappear, `anthropic-skills:`-prefixed copies remain (accepted, see T043).
  6. Old claude-scaffold skill folders on that laptop stay untouched until T060/T061.
- [x] T033 Find a home for uploaded skills that exist in no repo here: `spec-kit-sync`, `spec-kit-wrapper`, `omp-fanout`, `scaffold-meta` (scaffold `meta-skill/`), and `coding-assessment` (agent-skills calls it `coding-assessment-artifacts`). Decide for each: add to a package, keep local-only, or retire from the upload. Anthropic's own account skills (pdf, docx, xlsx, pptx, docs, skill-creator, chrome-browser, built-in-browser, computer-use, deep-research, import-memory, morning) are not ours.
  - Decided 2026-11-22: omp-fanout -> new package `omp-tools` (from newer f_omp_runs/skill-draft copy; draft left in place, now a copy). scaffold-meta -> `spec-workflow`, made portable (root via $CLAUDE_SCAFFOLD_ROOT or ~/Github/claude-scaffold; may be redundant now that project-scaffolder/brownfield-analysis load directly). spec-kit-sync and spec-kit-wrapper -> RETIRE (no repo copy; delete the claude.ai uploads on both accounts when rebuilding uploads). coding-assessment upload = old name of coding-assessment-artifacts -> retire old upload name. Linked on personal laptop; omp config updated. Uncommitted.
      Verify: every skill in the synced bucket is either in agent-skills, listed as Anthropic's, or explicitly retired.

## Phase 3: publish (needs D4; Code, needs push credentials)

- [ ] T030 Replace `OWNER` with `mttfshr` in README and root `apm.yml` examples.
- [ ] T031 Add remote, push, tag packages (decide tag scheme: per-package vs repo-wide). Matt performs or approves the push.
      Verify: `git ls-remote --tags` lists the tags.
- [ ] T032 Document the workflows in README: edit here, `apm install` in the project (own projects, local path); release = commit, push, tag, others pin the tag; claude.ai upload = build-zips, upload, stamp.
      Verify: README states both paths and matches what T040 found.

## Phase 4: scratch test of APM (needs T030/T031 for the tag pin case; Code, needs `apm`)

- [x] T040 In a scratch directory, install one package by local path and one by tag pin.
      Verify, and record each: (a) does `../agent-skills/...` work, or only an absolute path (Matt's two laptops have different home paths, so an absolute path in a committed apm.yml breaks on the other machine); (b) after editing the source, does `apm install` re-copy it; (c) where files land and whether `.claude/skills/` is created; (d) whether sidecars/evals are copied; (e) whether apm.lock.yaml records a local path sensibly; (f) whether Claude Code sees a changed skill mid-session or only in a new one. (g) test recipe: make a throwaway skill `zz-precedence-test` whose body says which copy it is; put copies at project `.claude/skills/` (PROJECT), `~/.claude/skills/` (PERSONAL) and upload one to claude.ai (UPLOADED); in a Claude Code session signed in with claude.ai run `/skills`, then `/zz-precedence-test`, then `/anthropic-skills:zz-precedence-test`, then a prompt that matches its description without naming it; record which marker answers each; remove the uploaded test skill afterwards. Also: in a local Claude Code session (CLI and the desktop app's code sessions), which skills are listed: only `.claude/skills/` and `~/.claude/skills/`, or also the claude.ai uploaded ones; and what happens when the same skill is both installed and uploaded (duplicate, shadowing, or one wins).
  - Result 2026-11-22 (apm 0.36.0, scratch dirs in /tmp, real repo untouched):
    - Needs a harness: with no `.claude/` etc. `apm install` errors "No harness detected"; fix by `targets: [claude]` in the project's apm.yml (or `--target claude`).
    - Tag pin works: `mttfshr/agent-skills/packages/session-hygiene#v1.0.0` resolves from GitHub (public repo), copies 4 skills to `.claude/skills/`, adds `apm_modules/` to .gitignore, writes apm.lock.yaml with resolved_commit dcba3b1, resolved_ref v1.0.0 and per-file sha256.
    - (a) Relative local path works: `../agent-skills-copy/packages/spec-workflow` (so a committed apm.yml can use `../agent-skills/...` if both repos sit side by side on each laptop; absolute path not needed). Lock records `source: local`, `local_path: <as written>`, `repo_url: _local/spec-workflow`, no commit pin.
    - (b) Editing the source then `apm install` DOES re-copy (marker appended to plan-workflow/SKILL.md appeared in the project copy; install took 0.2s). Files are copies, not symlinks, so edit-then-reinstall is required per project: this is the 2-step flow.
    - (c)/(d) Lands in `<project>/.claude/skills/<skill>/`; `references/` sidecars are copied (constitution-workflow got workflow.md, validator.md, core.md). Not tested: evals/, local.md sidecars.
    - Not tested: (f) mid-session visibility, (g) precedence recipe, installing a skill that exists in both personal and project scope.
    - Implication for D2/D8: for own projects, local-path install gives per-project copies that need `apm install` after each edit; the symlinks in ~/.claude/skills (D8) need no install and are already live on the personal laptop. Do not use both for the same skill in one project (duplicates in /skills).
- [~] T043 Test `syncClaudeAiSkills: false` in user settings on one laptop: confirm Claude Code lists only the linked local skills, synced ones move to `.trash`, chat/Cowork still see uploads. Also note what `synced/` holds when switching between the Pro and Team accounts.
  - Result 2026-11-22 (personal laptop): `syncClaudeAiSkills: false` set in ~/.claude/settings.json (backup settings.json.bak-2026-11-22). `/skills` in a new session lists the 28 repo skills once each as `user` + plugin skills; no claude.ai sync entries and no `anthropic-skills:` duplicates; Anthropic's own account skills (docs/docx/pdf/pptx/xlsx/browser/computer-use/skill-creator/morning) no longer appear in Claude Code (still in chat/Cowork). Before the flag, linked skills produced 25 `anthropic-skills:` duplicates (~4.3k tokens) and one `name-only` truncation.
  - REVERTED 2026-11-22 (Matt: needs Anthropic skills in Claude Code, e.g. browser, computer-use, docx/pdf/pptx/xlsx). Flag is all-or-nothing. Open: check whether Anthropic's document skills install as a Claude Code plugin (unverified) before using the flag again; meanwhile accept ~4.3k tokens of `anthropic-skills:` duplicates.
- [ ] T042 Test D7: symlink one skill from `~/.claude/skills/<name>` to the agent-skills checkout; confirm `/skills` lists it once, an edit at source shows without any install, and behaviour when a project also has an installed copy of the same skill.
- [ ] T041 Record results in plan.md "Not verified yet" and update D2/D3 if the facts differ.

## Phase 5: cut over f_ (needs D1-D3, T040; Code)

- [ ] T050 Add `f_/apm.yml` depending on spec-workflow, session-hygiene, max-msp, f-library per D2; `apm install`.
- [ ] T051 Move the three `local.md` files to the D1 path in f_.
- [ ] T052 Update f_ `CLAUDE.md` (Skills in the Flow, two-repo edit rule), `tests/check.sh` and any reference to `skills/check.sh`, `.gitignore` per D3.
- [ ] T053 Retarget `.specify/preflight/tasks.md` T030/T033 to edit module-preflight here, then `apm install` in f_; update `HANDOFF.md`.
- [ ] T054 Remove `f_/skills/` (needs delete permission; otherwise `_to_delete/`).
      Verify: `tests/check.sh quick` passes; a fresh clone plus `apm install` produces the same `.claude/skills/` tree.

## Phase 6: cut over claude-scaffold (needs D5; Code)

- [ ] T060 Remove `skills/` symlinks and `skills-for-upload/*` source folders; keep what D5 says. Update README and QUICKSTART to point here.
- [ ] T061 Commit the verification-thread edits in claude-scaffold first (Matt reviews `git diff`), so nothing is lost before removal.
      Order: T061 must precede T060.

## Phase 7: close

- [ ] T070 Rebuild zips from here and upload; run `check.sh stamp`. Matt's step.
- [ ] T071 Dry run of the Verify thread on a small feature (offered earlier; separate from consolidation).

## Deferred (not scheduled)

- [ ] T080 Invariant/property tests for skills' checks (needs a bug-vs-bad-test triage step first).
- [ ] T081 Fresh-context reviewer at checkpoints for the spec workflow.
- [ ] T082 If Matt chooses per-package zips, revisit T022.
