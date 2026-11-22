---
name: omp-fanout
description: Design a parallel subagent job for oh-my-pi (omp) and hand back a paste-ready prompt. Use when the user asks to set up a subagent project or fan-out in omp / oh-my-pi, or wants bulk read-heavy work (audits, inventories, research sweeps, comparisons across many files or sources) delegated to cheaper models. Starts with a gut check on whether omp is worth reaching for at all. Output is report-only. Also use when the user brings back an omp report to be scored, or asks whether another omp wave is worth it.
---

# omp-fanout

You are the architect and omp is the executor. Your deliverable is a prompt the user pastes into omp, plus files you save for them when you can write to their machine. You do not run omp, and you do not do the bulk work yourself.

omp is a harness like Claude Code: it reads files, runs shell commands, spawns subagents and writes files. It routes subagents to models by task type and difficulty on its own. So describe each kind of task and how hard it is, in plain words. Never name models or tiers unless the user does.

Read `references/lessons.md` before designing anything. It records what went wrong in earlier runs.

## Step 0: gut check (before any design work)

omp is not free. Setup, tooling, supervision and review all cost the user's time, and on the f_ modules the setup and tooling cost more than the runs did. Before intake, decide in a few minutes whether to reach for omp at all, and say the verdict in three lines: the verdict, the expected cost against doing it directly, and the decision the answer would change.

Ask, in this order. Any "no" in 1 to 3 means do not use omp.

1. **Does the answer change a decision?** If you would take the same action with a conservative default, or the value is cheaper to find by tuning live (the user's bench or a scratch patch), skip it. Tightening a bound that will be set conservatively anyway is the typical waste.
2. **Can omp do it at all?** It cannot drive the user's apps, a GPU, real-time behavior or anything needing human judgment mid-task. Those unknowns are the usual top risks of a build, so name them and put them on the user's bench instead.
3. **Is the question cheaper than it looks to get wrong?** A wrong answer in a report is cheap; a wrong number that gets built on is not. If the output would be trusted without review, the review cost belongs in the estimate.
4. **Is the tooling already built?** A reusable harness for this task shape (a `check.py`, a template) makes a wave cheap. A new harness or a new unit shape costs hours, and with six units or fewer you should do the work directly.
5. **What does it really cost, measured not guessed?** Estimate the architect's time to build and brief (tooling, briefs, controls), the workers' compute (time one real unit for five minutes and multiply; guessed per-step costs were 3 to 5 times too low in the f_ks and f_vf_lbm waves), the review (reading the report, spot checks, a relay for about one unit in three), and compare with the direct path. Reach for omp only when the direct cost clearly exceeds all of that, roughly by 3 times.

Verdicts: **go**, **go light** (the small-job path below), **do it directly**, or **defer** (say what would change the answer). Ask the user only when it is borderline, and put the numbers in the question.

Repeat the gate before every follow-up wave. After one run the easy answers are in; the default for a follow-up is no unless a named decision is blocked. Sunk tooling is not a reason to run again.

## Step 1: fit check

Good fit: many independent units; each unit's answer can be checked against files or sources; a wrong answer is cheap because the output is a report; no specialist apps (Max, Ableton, a GUI) and no human judgment mid-task.

Poor fit: one deep reasoning task, anything needing the user's apps, anything that is really a decision. Say so plainly and offer to do it directly instead.

Small jobs (about six units or fewer, or a simple lookup): use the light path. One prompt, one subagent per unit, no separate verify step. Keep the hard rules and the output schema.

## Step 2: intake

Gather: the task, the unit list (or a rule that enumerates it), where the material lives, what is off limits, and what a good result looks like. Infer what you can and ask at most three questions, only for what you cannot infer. State your assumptions in your answer.

Ask once if the material could be private or sensitive. It goes to a hosted provider. Public repos and the user's own non-sensitive notes are fine; work for other organizations is the user's call.

Output is always report-only: omp proposes changes as text and never applies them. What happens to the report is a separate decision.

## Step 3: design the run

The shape is fixed. Do not invent a new one per task.

1. **Setup (lead, mechanical):** run folder, snapshot of the material made read-only with `chmod -R a-w` (a worker once edited the snapshot), `check.py`, the unit list. Say in every worker brief that setup is already done and name the only commands the worker may run.
2. **Examine (one subagent per unit; difficulty usually medium; at most 15 running at once):** each writes `findings/<unit>.json`. Optional 2b, when the material points at other things (docs, READMEs, specs): a second, easy pass per unit that checks every pointer ("see X", paths, section names) resolves. Examiners judging claims tend to skip pointers.
3. **Validate (lead runs `check.py validate`):** code verifies every quote and computes every line number. A finding whose claim quote is not in the snapshot is rejected automatically, and findings that point at the same lines of the same file are merged. Malformed JSON gets one retry.
4. **Verify (one fresh subagent per surviving finding; medium):** it sees only what `check.py show` prints, must reproduce the finding from the files alone, and judges the finding and the proposed fix separately. Default answer is "no". Verifiers may be read-only, so they reply with the verdict as one line of JSON and the lead saves it unchanged; `check.py pending` lists any verdict that is missing or unusable, and the lead re-runs those once.
5. **Report (lead runs `check.py report`):** the script renders a compact `REPORT.md` (one or two lines per apply-ready item) and the complete `REPORT_FULL.md`; the lead writes only a short reply.

The lead never writes line numbers, counts, diffs or token figures, and never retypes a finding into the report.

Sizing the run (from the failed f_ks and f_vf_lbm wave): size from measured cost, not from the task list. Put per-step cost tables in the briefs, state budgets as compute (frames times cost per frame, summed over cells) as well as minutes, and let `check.py try` print the estimate. Run at most two compute-heavy workers at a time on one machine. Any step that can run longer than the lead's shell allows (validating a measurement grid, say) runs detached, writes each result as it finishes and resumes after an interruption. The checker runs a frozen copy of any script a worker wrote, so a worker's late edit cannot change what was measured.

Controls: for a task type you have not run before, include one or two units where you know the answer and one or two that should be clean, unlabeled, in the unit list. If the same task has a structural class of claim (route lists, diagrams, file trees), plant one control of that class too, since examiners tuned to prose skip it. Keep the answer key in your reply to the user, never in a file omp can read. Do not let your own hints pre-empt a planted sentence: a brief that names the suspected trap makes the worker stop reading the other sentences.

## Step 4: write the prompt

Use `references/prompt-template.md`. Fill every `<<MARKER>>`, then search your finished prompt for `<<` and fix any that remain. No placeholders may reach the user.

Delivery:
- With file access: save the prompt as `RUN.md` in the run folder, copy `scripts/check.py` next to it, and give the user one line to paste: `Read <path>/RUN.md and follow it exactly.`
- Without file access: give the whole prompt in one code block, with `check.py` embedded as the appendix the template describes.

The default run folder is a sibling of the source tree, never inside it. For an f_ repo checked out at `<parent>/f_`, that is `<parent>/f_omp_runs/<run-name>/`.

Your reply to the user: the gut-check verdict, the paste line, a three-line summary of what the run does, the assumptions you made, and the answer key if you included controls.

## Prompting rules for flash-tier workers

- Ask for judgments, not bookkeeping. Code produces line numbers, counts, diffs and checksums.
- One unit per worker, one job per step.
- Put the hard rules first and repeat them last.
- Include one worked example of a finding and one of a non-finding. The non-finding stops padding.
- Say outright that an empty result is valid.
- Give an exit for doubt (`needs_decision`, `unsure`) so the worker does not guess.
- Tell workers to report a repeated problem once and list the other places as evidence.
- Verifiers get the finding and nothing else. Never show them the examiner's reasoning.
- Spell out every path and name. No placeholders, no "as above". Give the literal interpreter line and import path a worker needs to run things locally.
- Hints and "known facts" are claims, not facts: label them as claims to verify, and word a suspected mismatch as "verify whether they agree", never as a statement that they do.
- For idea notes, design captures and logs (dated snapshots), say that only the header and stated status count, not the body.
- For audits of documents, tell examiners not to propose edits to task lists, acceptance criteria or test expectations; those go to `needs_decision`.
- Fixes must be one short exact span. A fix too big for that is split into several findings, or goes to `needs_decision`; large fixes are the main reason high-severity items land in Needs-decision.
- Diagram lines, route lists and file trees are claims; say so in the brief. When a script can compare them to the source, let it.
- A pointer to a section resolves only if the section's content gives what the pointer promises, not merely if a heading of that name exists.

## Reading results

When the user brings back a report:

1. Read the top counts and the Apply-ready and Needs-decision sections. Check the Rejected list for anything wrongly dropped.
2. If there was a control set, score it: recall on the seeded items, and whether the clean units stayed clean.
3. Spot-check a sample of Apply-ready items against the files, and every proposed fix you would let the user apply. A verifier can be wrong even when it says yes (one confirmed a fix that would have changed a correct count to a wrong one), so check numbers and dates in `new_text` yourself. For measurement runs, recompute from the checker's table; a worker's prose number can disagree with its own claim.
4. Report back in this order: what to apply, what needs a decision, what to ignore, what the run could not do. Then say whether the prompt or the harness caused each defect.
5. Triage Needs-decision in buckets: (A) correct, grounded fixes held back only because an evidence quote did not match, which are mostly safe in a batch after a glance; (B) one policy question that settles many items (for example, banner superseded specs instead of rewriting them); (C) real calls about the user's code or intent; (D) fixes the verifier called ungrounded, which are skipped or redone by hand.
6. An empty unit is not proof the unit is clean. If controls were planted, trust an empty result only where nothing was planted; otherwise spot-check one or two empty units yourself.
7. After the user applies fixes, run the repo's own checks before committing.
8. Before suggesting another wave, run the Step 0 gut check again and say plainly if the next step belongs on the user's bench or in tuning, not in omp.
9. Append what the run taught you to `references/lessons.md` (or tell the user what to add if you cannot write there).
