# Prompt template

Everything between the two `=====` lines is the prompt. Replace every `<<MARKER>>`. A marker may need a sentence, a list, or deleting the line it sits on. Before delivering, search the finished prompt for `<<`: none may remain.

Marker guide:

| Marker | Fill with |
|---|---|
| `<<TITLE>>` | Short name of the job |
| `<<RUN_DIR>>` | Absolute path of the run folder, outside the source tree |
| `<<SOURCE_DIR>>` | Absolute path of the material |
| `<<OFF_LIMITS>>` | Paths or areas workers must not read or touch, or "nothing" |
| `<<SNAPSHOT_COMMANDS>>` | For a git repo: `cd <<SOURCE_DIR>> && git rev-parse HEAD > <<RUN_DIR>>/SHA && git archive HEAD \| tar -x -C <<RUN_DIR>>/snapshot` (and `git status --short` so the lead can mention uncommitted changes). For non-git material: `cp -R` into `snapshot/`. |
| `<<UNITS>>` | A literal list of unit paths relative to the snapshot, or a shell command that enumerates them. Control units go in this list unlabeled. |
| `<<TASK_DEFINITION>>` | 2 to 4 sentences: what the examiner is looking for, with the classes of finding if there are any |
| `<<NOT_A_FINDING>>` | Task-specific list of things that do not count. For audits of documents, always include: edits to task lists, acceptance criteria and test expectations (flag them with `needs_decision` instead), and anything inside dated history. |
| `<<EXAMPLE_FINDING>>` / `<<EXAMPLE_NON_FINDING>>` | One real-looking example of each, in the task's own terms |
| `<<TRUTH_HIERARCHY>>` | For disagreements between sources: which wins. Delete the line if not relevant. |
| `<<REFS_EXAMPLE_FINDING>>` / `<<REFS_NON_FINDING>>` | Only for the optional Task 1b (reference check): one example of a pointer that does not resolve, one of a pointer that does. Delete all of Task 1b, its brief, and this pair if the job has nothing to cross-reference. |
| `<<DIFFICULTY_*>>` | One plain phrase: "easy, mechanical", "medium, needs reading and comparing", "hard, needs real reasoning" |

=====

# <<TITLE>>

You are the lead for a read-only fan-out job. Delegate the work below to subagents. For each kind of task I say how hard it is; use that to decide who does it. I do not care which model does what.

## Hard rules (repeated at the end)

1. Read-only. Write only inside `<<RUN_DIR>>`. Never modify, move or delete anything else.
2. Off limits: <<OFF_LIMITS>>
3. Never write line numbers, counts, diffs or token figures yourself. `check.py` computes them.
4. Quotes are copied verbatim from the file, 25 words or fewer, never paraphrased.
5. An empty result is valid. When unsure, say so (`needs_decision` or `unsure`). Never guess.
6. A subagent gets only its own brief and its own unit. It never sees this prompt, another finding, or another unit's results.
7. Report only. Fixes are proposed as text and never applied.

## Setup (you do this yourself, in order, with shell commands)

1. `mkdir -p <<RUN_DIR>>/findings <<RUN_DIR>>/verdicts <<RUN_DIR>>/snapshot`
2. Snapshot the material (all workers read only from `<<RUN_DIR>>/snapshot`): `<<SNAPSHOT_COMMANDS>>`
3. Make the snapshot read-only: `chmod -R a-w <<RUN_DIR>>/snapshot`. Workers must never write anywhere except their own single output file; if a worker reports that it changed anything in the snapshot, restore it from the source, note it in `notes.md`, and re-run that unit.
4. `<<RUN_DIR>>/check.py` was provided with this prompt. Run `python3 <<RUN_DIR>>/check.py` with no arguments and confirm it prints usage. If the file is missing, stop and tell me.
5. Units, paths relative to the snapshot: <<UNITS>>

## Task 1: Examine each unit (<<DIFFICULTY_EXAMINE>>; one subagent per unit; run in parallel)

Give each subagent the Examiner brief below with its unit filled in. It writes `<<RUN_DIR>>/findings/<unit>.json`, where `<unit>` is the unit path with `/` replaced by `_`. If a file is not valid JSON, send the subagent the schema again and retry once. If it fails twice, add a line to `<<RUN_DIR>>/notes.md` and move on. Run at most 15 subagents at a time, in batches. Use a fresh subagent per unit; do not reuse names across batches. Before Task 2, list `<<RUN_DIR>>/findings` and confirm one file exists for every unit (and every `.refs.json` if Task 1b runs). Re-run any missing unit once. If a unit returned `[]` and the job has planted controls, an empty result counts only for units that hold no planted error; a planted unit that returns `[]` is a miss, so re-run it once with the Examiner brief unchanged and record the miss in `notes.md`.

## Task 1b: Reference check (easy, mechanical; one subagent per unit; run in parallel with Task 1)

Give each subagent the Reference brief below with its unit path and slug filled in. It writes `<<RUN_DIR>>/findings/<slug>.refs.json`. Same retry rule as Task 1.

## Task 2: Validate (you, mechanical)

Run `python3 <<RUN_DIR>>/check.py validate <<RUN_DIR>>`. It locates every quote in the snapshot, rejects findings whose claim quote is not found, and merges findings that point at the same lines of the same file (one root cause reported from two units). Re-run any worker that it reports as MALFORMED, once.

## Task 3: Verify each surviving finding (<<DIFFICULTY_VERIFY>>; one fresh subagent per finding; run in parallel)

List the ids with `python3 <<RUN_DIR>>/check.py pending <<RUN_DIR>>`. For each id, run `python3 <<RUN_DIR>>/check.py show <<RUN_DIR>> <id>` and give the subagent only that output plus the Verifier brief. It replies with the verdict as ONE line of JSON and nothing else; you write that line unchanged to `<<RUN_DIR>>/verdicts/<id>.json`. If you can route verification to a different delegate than the one that examined the unit, do.

When the verifiers finish, run `pending` again. Any id it still lists has no verdict or an unusable one (for example invalid JSON). Re-run that verifier once, telling it to write strictly valid JSON with no trailing commas. If the id is still listed, add a line to `<<RUN_DIR>>/notes.md`.

## Task 4: Report (you, mechanical)

Run `python3 <<RUN_DIR>>/check.py report <<RUN_DIR>>`. Then reply with the final reply format below. Do not summarize, reorder or reword findings.

## Examiner brief (give each subagent this, with its unit filled in)

You are examining ONE unit: `<unit>`. The material is in `<<RUN_DIR>>/snapshot` and is read-only.

<<TASK_DEFINITION>>

<<TRUTH_HIERARCHY>>

What does NOT count as a finding:
- wording, style, typos
- the same problem repeated: report it ONCE and list the other places as extra evidence
- <<NOT_A_FINDING>>

Write a JSON array to `<<RUN_DIR>>/findings/<unit>.json` with one object per finding. `[]` is valid and common.

Exactly these keys:

```json
{
  "id": "<unit>-1",
  "unit": "<unit>",
  "severity": "high | med | low",
  "claim":    { "file": "path relative to the snapshot", "quote": "verbatim, 25 words or fewer" },
  "evidence": [ { "file": "path relative to the snapshot", "quote": "verbatim" } ],
  "why": "one sentence",
  "proposed_fix": { "file": "...", "old_text": "exact text that appears once", "new_text": "..." },
  "needs_decision": null
}
```

`proposed_fix` is `null` when no mechanical fix exists. When fixing needs a human choice, set `needs_decision` to a sentence saying what must be chosen, and leave `proposed_fix` null. Severity: high = a reader would act on wrong information; med = misleading but easy to notice; low = cosmetic.

Example of a finding:

<<EXAMPLE_FINDING>>

Example of something that is NOT a finding:

<<EXAMPLE_NON_FINDING>>

Fixes must be small and exact: `old_text` is one short span (a sentence or a table cell) that appears exactly once. If the right fix is bigger, split it into several findings (one span each) or set `needs_decision`; never paste a paragraph as `old_text`. Structure counts as a claim too: diagram lines, route lists, pipeline arrows and file trees are claims, so check them against the source like any sentence.

Reminders: quotes verbatim; no line numbers; no diffs; one finding per root cause; nothing wrong means `[]`.

## Reference brief (give each subagent this, with its unit filled in)

You are checking the pointers in ONE unit: `<unit>`. The material is in `<<RUN_DIR>>/snapshot` and is read-only.

A pointer is any place where the unit sends the reader somewhere else: a file path, a script or command, a section or heading, a module name, or a phrase such as "see X", "as described in X", "the Y instructions". List every pointer in the unit, then check each one against the snapshot: the file or script exists; the module exists; and for a pointer to a section, heading or named instructions, open it and check that its content really gives what the pointer promises. A heading with the right name is not enough: if the sentence says the reader will find setup steps there, the steps must be there. Report only the pointers that do not resolve. A pointer that resolves, a link to an outside website, and a path that exists in an off-limits area (you may list file names there) are not findings.

Write a JSON array to `<<RUN_DIR>>/findings/<slug>.refs.json` using exactly the same keys as the Examiner brief, with ids `<slug>-refs-<n>`. The claim quote is the sentence or phrase that holds the pointer. Evidence is what you found when you looked (for example the headings that actually exist), quoted verbatim. `[]` is valid.

Example of a finding:

<<REFS_EXAMPLE_FINDING>>

Example of something that is NOT a finding:

<<REFS_NON_FINDING>>

## Verifier brief (give each subagent this plus the `check.py show` output)

You are checking ONE finding, given to you below. Everything you need is in `<<RUN_DIR>>/snapshot`. You were not told how the finding was reached, so do not try to guess.

1. Open the claim file and each evidence file. Is each quote really there?
2. Does the evidence actually contradict the claim, not merely differ in wording?
3. Does a newer or higher-ranked source already resolve it? <<TRUTH_HIERARCHY>>
4. If there is a `proposed_fix`: would applying it make the file correct and change nothing else? Does it claim more than the evidence supports? If anything in `new_text` is not supported by the evidence, even a date that is off by a day, `fix_grounded` is `no` and `reason` says what is wrong.

Reply with ONE line of JSON, nothing else (the lead saves it). Use strictly valid JSON, no trailing commas:

```json
{ "id": "<id>", "finding_real": "yes | no | unsure", "fix_grounded": "yes | no | n/a",
  "own_quote": { "file": "...", "quote": "what you found yourself, verbatim" },
  "reason": "one sentence" }
```

Judge the finding and the fix separately: a real problem can have a wrong fix. If you cannot reproduce the finding from the files alone, `finding_real` is `no`.

## Final reply format

Reply with: the counts from the top of REPORT.md; the path to `<<RUN_DIR>>/REPORT.md`; the commit SHA from `<<RUN_DIR>>/SHA` and whether `git status` showed uncommitted changes (if this is a git job); anything in `notes.md`. Do not paste the report into chat.

## Hard rules again

Read-only, writes only inside `<<RUN_DIR>>`. Off limits: <<OFF_LIMITS>>. No line numbers, counts, diffs or token figures from you. Quotes verbatim. Empty and "unsure" are valid answers. Subagents see only their own brief and unit. Report only: nothing is applied.

=====

## Appendix: no file access

If you cannot write `check.py` into the run folder, add this step to Setup after step 3 and paste the full contents of `scripts/check.py` into the prompt as a heredoc:

```
Create <<RUN_DIR>>/check.py with exactly this content:
cat > <<RUN_DIR>>/check.py <<'PYEOF'
...contents of scripts/check.py...
PYEOF
```
