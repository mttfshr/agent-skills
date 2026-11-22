# Lessons from earlier runs

Append to this file after every scored run. Keep entries short and specific.

## 2026-10-18: documentation staleness pilot (f_ repo, 10 units + 2 inventory modules)

Result: recall 5 of 6 seeded problems; roughly 43 findings confirmed; drafts mostly applied cleanly. Several defects came from how the task was handed off, not from the models.

What went wrong, and the fix now built into the template:

- **Models were asked to write line numbers, quotes, diffs and token counts.** Line numbers drifted, some quotes were paraphrased, the orchestrator rebuilt malformed diffs, omp could not report tokens. Fix: workers give file and verbatim quote only; `check.py` locates quotes and computes lines; fixes are `old_text`/`new_text`, checked for a single match.
- **The orchestrator was a model doing mechanical work.** It pasted one finding's draft line into another finding. Fix: the report is rendered by `check.py report`.
- **One verdict covered both "finding is real" and "fix is right".** An arbiter confirmed a finding whose draft overstated what had been verified. Fix: two fields, `finding_real` and `fix_grounded`.
- **Workers audited the whole body of idea notes and design captures.** About a dozen findings shared one root cause (a pre-build design note). Fix: "report once per root cause" and "dated snapshots: header and status only".
- **The verifier confirmed about 90% of what it saw.** It accepted wrong line numbers as "drift". Fix: quote location is checked by code before verification; the verifier default is "no".
- **Answer key sat beside the briefs.** Fix: the key lives only in the reply to the user.
- **The first prompt had placeholders.** Fix: every path and name filled in; the skill checks for `<<` before delivering.
- **The report was 625 lines in rank order.** Fix: apply-ready, needs decision, rejected, could-not-do, in that order.
- **Working tree differed from the commit.** Some cited lines did not match the pinned copy. Fix: snapshot with `git archive` and read only from it.

Observed model behavior worth remembering:

- Flash-tier workers produce plausible evidence quotes that are paraphrases; verify by code.
- They attach claim quotes to the wrong finding when several findings sit near each other; the finding text and the quote must be checked together by the verifier.
- Refuted drafts left on disk can be applied by accident; the harness keeps drafts inside findings and does not write separate diff files.

Not yet learned: how many units a single prompt can fan out before coordination fails; how omp reports usage; whether routing verification to a different model than the examiner changes the confirm rate.

## 2026-10-18: staleness-2 (same job re-run with the skill)

Result: 12 apply-ready, 7 needs-decision, 3 rejected, 1 unverified. Key recall 4 of 6 (README "Eight" -> ten, decorrelate row, f_weave header, f_caustic "to be written" found; README "development instructions" pointer missed again; caustic_scatter fold-in not found, and the spec already says "addendum", so that key item was weak). Every quote was real, every line number correct, no stray edits to HANDOFF, plan.md or .maxpat. Report was 145 lines, not 625.

What the skill fixed: no paraphrased claim quotes survived, no wrong line numbers, no retyped report, finding and fix judged separately (caught an overclaiming README fix).

Defects still open:
- Same root cause reported from two units (README row came from README.md and from the decorrelate folder). Two different fixes for one row, one apply-ready and one ungrounded. Fix: tell examiners that a file outside their unit that is already someone else's unit is evidence only, or add a dedup step keyed on claim file + quote in check.py.
- A verifier wrote JSON with a trailing comma; check.py shows it as "Not verified" but nobody retried. Fix: Task 3 must re-run any verdict that `check.py report` lists under Not verified, once.
- Verifier gave fix_grounded=yes while its own reason said the date was off by a day (tf_axisflow "Built 2026-10-17" vs built 2026-10-16). Fix: the verifier brief should say that any discrepancy it notices in new_text means fix_grounded=no.
- Pointer checks ("as described in the development instructions") are missed by examiners that compare status claims. Needs a dedicated "every cross-reference in this file resolves" task class.
- Evidence quotes were paraphrased in 4 findings (flagged by code, correctly demoted); the flash tier still does this.

## 2026-10-18: staleness-3 (30 units + reference pass on each, snapshot at fe46d7f)

Result: 265 findings -> 109 apply-ready, 73 needs-decision, 40 rejected, 43 merged duplicates, 0 unverified. 215 verdicts, all valid after the retry step. Dedup and malformed-verdict retry worked. Spot check of applied fixes (f_masonry mortar/width defaults, f_stipple proc_mode, README decorrelate row) matched definition.py and source comments.

Defects:
- README "development instructions" pointer missed a third time. The reference pass saw a "## Development" heading and treated the pointer as resolved. Fix: the reference brief must say a pointer to a section resolves only if the section's content contains what the pointer promises (here: where to symlink package/).
- An examiner edited a file inside the snapshot. The lead noticed, restored from git and diffed. Fix: `chmod -R a-w snapshot` in Setup, and tell workers their only writable file is their own output file.
- Verifiers were read-only and could not write verdict files; the lead persisted replies verbatim. Fix: design for it. Verifiers return the verdict as one line of JSON; the lead writes it unchanged.
- Apply-ready contains edits to tasks.md and spec test criteria that rewrite what a dated plan asserted (flipping unticked tasks to done, changing an expected aspect from 4 to 2). These are accuracy edits, not staleness edits. Fix: add "do not edit task lists or acceptance criteria; flag them" to the examiner rules, or route them to Needs decision.
- Report ran to 1233 lines at 265 findings. Fix: one line per apply-ready item (id, file:line, old -> new) and verifier reasons trimmed to one sentence; full text kept in checked/.
- Examiner names reused across batches and one reference checker force-wrapped before writing; the lead recovered both. Cap batch size (about 15 workers at once) and tell the lead to confirm every expected output file exists before Validate.

## 2026-10-18: param-audit-1 (40 module reference docs vs definition.py, behavior prose only; names/ranges/defaults done by script)

Result: 77 findings -> 54 apply-ready, 16 needs-decision, 7 rejected, 4 merged duplicates, 0 unverified. 7 of 40 units returned []. Report 193 lines. Seeded controls (three prose errors planted only in snapshot copies of the docs): 2 of 3 found (viscosity polarity reversed; masonry `skip` "hidden" vs visible). Missed: a route-token list with `decay` removed (a structural claim, not a behavior claim).

What worked:
- Splitting the job: a 130-line script compared tables exactly (22 differences across 40 modules, no model involved); omp only judged prose against the shader code. Planting controls in the snapshot copy (never the repo) gave a clean recall test with no repo changes.
- Read-only snapshot, one-line JSON verdicts saved by the lead, `pending` re-run, and dedup all held. Notes show the harness caught two worker errors (a `proposed_fix` returned as a list; a verdict with the wrong id) and recovered.
- Behavior rewrites that went in (f_grain, f_weave, f_vf_advect bypass) read as correct on spot check.

Defects:
- Route/structure lists in diagrams (`unmatched -> route a b c`) are not caught by a prose-behavior examiner. Either give the script a route-list check (compare to definition param names) or add a "diagram lines" instruction.
- 7 empty units is plausible for recently overhauled modules (f_vf_flow, f_tf_axisflow) but was not checked. With a control set, require at least one planted error in a unit before trusting an empty result in that unit.
- Several high-severity items landed in Needs-decision (doc vs code facts that look fixable). Likely cause: fix too large for a single old_text. Consider letting the examiner split a large fix into several findings, or add a `rewrite` field the human reviews.

Folded into the template and SKILL.md (2026-10-18): short-exact-span rule for fixes, diagram/route lines count as claims, empty-unit rule when controls exist, structural control class. Not folded: the script-side route-list check (belongs in the task's own script, e.g. param_diff.py).

## 2026-10-19: gate-prep-1 (first record-style "extract" job: 33 modules x two record kinds, snapshot db4c2c2)

Result: 66 records, 66 verified real, 0 malformed after repairs. Report 184 lines. Controls (answer key kept out of the run): 7 of 7 tier-1 controls hit (masonry skip, caustic / fluid / axisflow have mirrors, advect add_mirror, chladni and vortex add_mirror). Blend: grain split_done, warp needs_split, vortex not_applicable all hit. One apparent miss (f_chladni expected split_done) was an error in the key: plan.md says chladni is in the gain/mix rollout, but its definition.py has `gain` and `amp` and no `mix_pct`.

What worked: `extract.py` (records, code-checked quotes and paths, script-rendered tables); one record per module per kind; the two-field verdict; an advisor memo that cites the report's lines instead of retyping counts.

Defects:
- Blend brief did not say that `bypass` is not a blend control. Workers listed it as `blend_weight_only` in droste, mobius, ngon, luma, vortex, repulse, which pushed droste to `partial` and several processors to `unsure`. Fix: say so in the brief, and add a status `none` for "processor with a dry input and no gain, mix_pct or blend-like parameter at all". The advisor then built an option ("is a lone bypass compliant?") on the bad data.
- The tier-1 verifier agreed with all 33 records (zero disagreements) although the blend verifier caught 3 real errors. Controls passed, so the records look right, but an all-yes batch still wants a spot-check of a few non-control records.
- The lead repaired quotes in 5 records itself (one record had no evidence at all and the lead added two quotes). That breaks "the lead never writes content". Fix: send the record back to the worker once; if it still fails, mark the record unverified.
- Advisor memo regrouped by cost loosely (moderate modules sat in the "cheap" list) and its blanket-rule check missed that `invariants_only` modules must be listed as exceptions. Fix: have `extract.py report` print the group lists itself and let the advisor reason over them.
- Minor: warp's record gave default 0.0 (the codebox Param) where the hand-tuned saved default is 0.1 (definition.py comment). Brief should say to report both the definition default and the codebox default when they differ.

## 2026-10-19: mirror-build-1 (first code-writing fan-out: 6 modules, authors write a NumPy mirror + test, snapshot e031f75)

Result: 5 of 6 candidates validated (prism's flash author failed twice and was skipped), all five landed after review; control (a planted Gaussian falloff in one codebox, doc says exponential) hit: the author reported it as a codebox-versus-doc disagreement unprompted. Automatic mutation scores 16 to 26 of 30 (survivors exposed real test gaps, e.g. mobius never tests a generic rotation angle). The omp session hung at verification; Claude verified by hand.

Shape used (adapted from the fixed report-only shape, because the output is code): Author (writes into its own work/<unit>/) -> Validate (`check.py` runs the test in a read-only snapshot's import path, locates every quote, runs up to 30 automatic ast mutations of the mirror) -> Verify (independence of the reference and fidelity of the mirror, two fields) -> Report. Nothing is applied to the repo; the architect reviews and lands.

What worked:
- Mechanical gates did the judging code can do: tests pass, declared mutations caught, quotes located, snapshot and repo hashes unchanged. Automatic mutation is a cheap, worker-independent measure of test strength (and deterministic).
- Requiring ground truth to come from the reference doc or a stated identity, with a verbatim doc quote per check, made the planted disagreement visible.
- One `test_DISAGREES_*` convention for "the codebox contradicts the doc" kept the other tests green and made the finding explicit.

Defects:
- A plant in the codebox corrupts the mirror too: the author's mirror follows the planted line, so the candidate cannot be landed as-is and has to be un-planted by hand. Plant controls in the DOC copy instead (the codebox stays right, the mirror lands unchanged, the disagreement is still found).
- Authors overclaim independence in docstrings ("no expected value is a retyped codebox line") while one check re-derives the codebox in float64. The verifier must read docstring claims as claims; `source: math` on a whole-frame re-derivation is an overclaim.
- Files were edited after validation (by an unidentified actor, probably the hung session) and the edited pair no longer matched its report. Fix built in: `validate` records file hashes and `report` rejects a candidate whose files changed since. A snapshot of the validated text (the `show` output) allowed an exact restore; keep `show` outputs.
- The omp lead hung at the verify step, which hands each verifier 20 to 29 KB of code. Either shrink the material (mirror + test only, codebox excerpt) or let the architect verify.
- One flash author (prism: a 17-version codebox folder, moderate cost) failed twice with a wrong mirror signature. Treat moderate-cost units as a harder task class, or give them a second pass with the failing test output.
- Parameter-default survivors dominate the automatic mutation survivors (defaults the tests always override); report them separately from logic survivors next time.

Not yet learned: whether omp-routed verification works at all (it never ran); whether an author given a failing test output can repair itself.

## 2026-10-20: mirror-build-2 (wave 1: six single-codebox modules, planted doc control, feedback channel)

Result: 5 of 6 candidates validated and landed after review (hue, repulse, stereo, channel_grader, luma), weave incomplete. Planted control (two sentences of a doc copy swapped) hit: the author filed it, the verifier confirmed it. Three real findings surfaced (a doc that contradicted its own codebox in repulse, a GPU atan2(0,0) NaN in stereo, a tie-hue quirk in luma). Feedback channel: 146 entries from 12 agents, none silent, none blocking; 43 "worked well", 27 improvements.

What worked: the feedback channel itself (the three closing questions each drew 10 to 11 substantive answers, no filler; "permission to record small frictions" was named as helpful); the `try` mutation loop (six authors praised it); pre-located quotes in the verifier's input; the "default answer is no" rule; the planted doc control; locked folders (no late overwrite this time).

What failed: (1) the lead's `wait` tool has no timed wakeup, so wall-clock deadlines in the run sheet were unenforceable and a unit (weave) was lost after 59 minutes with the author mid-debug. Use author self-budgets enforced by a tool they already call (`check.py try` prints elapsed time) and let the lead poll with `sleep N; check.py status` instead of blocking. (2) An author wrote a probe script into the repo root because the shell's cwd was the repo root: give workers a scratch folder and say where cwd is. (3) Validation problems on a candidate (unlocated quotes, a phantom test name) were recorded but the unit stayed "candidate" and was locked, so nothing could be fixed and the report hid it: make them MALFORMED. (4) The allowed-imports list omitted colorsys while the brief told authors to use it. (5) The independence rule was defined only by negative example; 8 agents had to invent the operative rule. Define it positively (a plausible transcription slip would change the outcome; the expected value comes from a doc statement, a stated identity or textbook closed form, a reference library, or the shared input), and treat convention-dependent values as codebox-dependent. (6) The verifier rubric had overlapping questions (claims grounding inside reference_independent), undefined phrases ("every check that matters", overclaim threshold) and no place for nits: split claims_grounded out, add caveats, define the terms. (7) Reading lists sized for the hardest module cost every author 5 to 10 minutes on simple modules: trim by module type. (8) Authors asked for per-module "known facts and traps"; every author re-derived them from the codebox. (9) Planting a control in a doc (not a codebox) kept the mirror correct; the converted test (doc-as-it-really-is) replaced the disagreement test at landing.

Not yet learned: whether a self-budgeted author finishes more units; whether per-module facts shorten authoring time; how the revised verifier rubric reads to a verifier.

## 2026-10-20: mirror-build-3 (wave 2: seven modules, planted doc control, per-module facts, feedback channel v2)

Result: 7 of 7 candidates validated (none incomplete, no stragglers, authors finished 1 to 11 minutes after their first try); the verifiers rejected two (sirds: the mirror wrapped a coordinate the codebox clamps; lens: docstrings credited the doc with codebox-only constants), both repairable at landing. Three declared disagreements were confirmed, plus two numerically verified findings in chladni (a dead zone at note 127; view_mode reaching only mode 1). 137 feedback entries from 15 agents. The planted control (a swapped sentence about the direction of one dial in a doc copy) was MISSED by author and verifier alike.

Why the control was missed: the author grounded every check as "math" in the recurrence the codebox itself implements (p_n = p_{n-1} * decay + ...), which the independence rule allowed, and never tested the direction the doc states for the dial. A closed form derived from the code cannot show that the doc's direction is right. Fix: for every dial whose doc sentence states a direction, require a sign or monotonicity check built from those words alone, and make a verifier name any dial without one.

New systematic defect: omp's file reader truncates lines at about 768 characters, and our briefs were mostly very long single-line paragraphs. An author and a verifier each saw a rule cut mid-sentence. Hard-wrap everything generated (about 100 columns) and keep long commands in fenced blocks, which wrapping never touches.

What worked: the per-module facts field (one author called it blocking-valuable; chladni's "verify, do not assume" trap list led to two real findings); framing suspected mismatches as leads to verify; the three `against` kinds; rule 3's two examples; the two-file verifier output; the automatic mutation list (it found real blind spots); the status-driven lead sheet (the straggler machinery never fired; the lead said the keep-a-timestamp step and the poll cadence did not matter).

What failed or cost time: (1) reading lists sized for the hardest module (10 agents): trim by what the module exercises; (2) warp and chain modules need tolerance guidance (twelve resampling stages push no-op checks to 2e-5 to 3e-5; a check that recovers coordinates by ramp readback is in the recovered unit; a read clamped at uv = 1 returns the edge texel centre, so mask on the start position; the neutral setting of a warp is not the identity); (3) my hint for one module was wrong (I said "scalar recursion over one row"; the right reference walks stored stage textures with its own bilinear sampler): hints are claims and need the same care as docs; (4) the verifier rubric put its definitions after the mechanical results and truncated; define "value-bearing", cap caveats at a visible limit, show survivors with their source line; (5) three of seven authors failed validation only on a paraphrased quote: give authors a `lint` command; (6) a verdict with one over-long caveat was silently unusable: print the exact reason from `pending`; (7) praise entries with an out-of-set severity were dropped: accept them; (8) authors rebuilt `uv run` incantations for probes: give a `probe` command; one author saw automatic survivors that its own emulation showed were caught: add a `mutant` command to reproduce one site.

Not yet learned: whether hard-wrapped briefs remove the truncation reports; whether the dial-direction rule catches a planted dial-direction control; how weave and prism behave under the self-budget and the status-driven lead.

## 2026-10-20 to 21: ks-lbm-1 to 4 (f_ks and f_vf_lbm: wave 1 mirrors, wave 2 measurement sweeps)

Result: wave 1 (two stage-decomposed float32 mirrors, `ks-lbm-1`) ran clean and landed, with a planted-control score of 1 of 2. Wave 2 first attempt (`ks-lbm-2`, four measurement units) FAILED: too many jobs, too long, one worker at 1h28 against a 45 minute budget, only one unit validated. Retry `ks-lbm-3` (measured costs, three units) worked: two units validated, one marked incomplete by a harness bug. The user's assessment after seeing it: another wave (`ks-lbm-4`) was not the best use of time; the remaining risks (GPU cost of the per-pixel DFT, steps per frame) belong on the bench, and the mirrors needed a careful human read more than another sweep. The gut check in SKILL.md Step 0 comes from this.

What went wrong:
- **Sized by task list, not cost.** One worker per task, per-frame costs guessed 3 to 5 times too low (LBM 300 by 50 is 17 ms/frame, not "a few"; KS N=256 is 26 ms/frame). Shedding alone was 6.6 core-hours over 88 cells with 16 timeouts. Fix: time one real unit first; per-step cost tables in the briefs; budgets in compute (cell-seconds); `try` prints the estimate; run two heavy workers at a time.
- **Validation was one blocking, unresumable call** killed at the lead's shell cap, all progress lost. Fix: `validate --bg`, per-cell results written as they finish, `status` shows progress.
- **A worker edited its script while the checker ran**, so resampled cells "failed to repeat" (the script had changed, not the mirror). Fix: the checker runs a frozen copy; an edit after `report.json` makes the unit malformed. The rule must read as an invariant (report matches script), not "never edit": a fixer pass must edit both.
- **Workers re-ran the lead's setup.** Fix: `SETUP_DONE` plus an explicit "setup is done, your only commands are try and lint" line.
- **The lint cost estimate extrapolated from three cells (first, middle, last) and overstated one grid about 5 times**, so a worker who had sized correctly failed lint and burned its wall budget. Fix: gate only above 3 times budget, warn below, and tell the worker to trust its own frames-times-ms sum.
- **My facts pre-empted a planted control (wave 1).** The LBM brief named the streaming-direction wording as the trap and told the author to build on one form; the author never compared the other spec sentences, so the planted "+e_i inverts the flow" sentence was missed. A KS fact said the spec and the experiment agree on a sign; they did not. Hints are claims: word them "verify whether they agree".
- **Worker prose can disagree with its own claims.** The shedding report said "dominant-bin share 0.86 mean" against a verified 0.7487, and said nothing sheds at U0 <= 0.04 "in 7000 frames" when every such cell ran 2001. A verifier that reads the claims against the table caught both; the architect should recompute from the checker's table, not trust prose.
- **Briefs lacked the local-run recipe**: every worker lost minutes finding the uv interpreter and the PYTHONPATH. Put the literal line in the brief.
- **The mirror cannot answer what it does not model.** The KS mirror's long runs use np.fft in float64 (tied to the texel-level DFT only at N = 32) and the LBM mirror is float32-only, so float32 versus float64 questions came back "not measured".

What worked: stage-decomposed mirrors with a `reference_sources` unit option (no shipped codebox needed); automatic mutation testing; the checker running every cell itself and recomputing every quoted number (it caught a wrong claim in the dry run and the verifier-visible mismatches later); a relay for a malformed unit (one fresh agent, problem lines pasted verbatim); per-frame cost tables, which two workers called the best part of the brief; naming exact checkpoint frames so a question costs nothing extra.

Not yet learned: whether an omp wave ever beat doing the same work directly on these modules in total time; the user's own judgment was that the remaining value was on the bench.

## 2026-10-23: webgpgpu-ideas-1 (first ideation fan-out: 21 units, inventory -> match -> verify, webgpgpu at 5997061)

Result: 154 techniques (0 rejected), 154 matches (covered 9, extends 36, new 76, not_fit 33), 93 proposals verified (5 per unit cap dropped 19), 84 kept (61 idea drafts, 23 suggestions), 9 needs-a-look, 0 unverified, 0 checker problems. Pilot unit took 5 minutes. Spot check of five drafts against the shader files: every number matched (wave c = 12.5, dt = 0.1, ten steps per frame; quasizoom 5 waves by 7 scales; Life 8-neighbor rule).

Controls (key kept out of the run): retinotopic map found twice and tied to f_wc (hit); Ex 20 color matrix covered by the hue processor (hit); Ex 16 hue rotation came back `extends f_channel_grader`, not covered (defensible); the Wilson-Cowan per-frame noise was found as a technique but filed as a generic noise utility under f_ks, never as the load-bearing drive of f_wc (partial miss: matches are per technique, so how techniques combine is not seen).

What worked: two-stage split (facts first, then overlap and sketch), code-checked quotes and names (zero rejected), the paused-module rule, per-proposal verifiers with three separate fields, the pilot gate, script-rendered idea files, feedback channel (199 entries; 27 challenges, mostly small).

Defects:
- No cross-unit dedup. The same technique was proposed once per unit: 8 Box-Muller noise utilities, 5 adaptation drafts, 4 wave-field drafts, 4 cellular-automaton drafts, 3 temporal band-pass drafts. The report should cluster by tag and closest module and print the cluster table itself.
- Verifier caveats are lost. Six kept drafts carry an imprecision the verifier noticed (a dial that rests on commented-out code, a wrong tap count in the risk line, a wrong glyph-id range) but only in FEEDBACK.md, because the verdict has one-sentence reason. Add a `caveats` field to the verdict and render it into the draft.
- `state_encoding` mislabeled 8-bit framebuffers as float in three records. Brief: name the framebuffer type argument and quote the line that sets it.
- Three feasibility = no verdicts were wrong quotes, not wrong verdicts (the cited constraint did not support the claim). Let the verifier supply the right quote and downgrade to unsure.
- `other_use` and research pointers came back empty, so the web-shim thread was unrepresented. "Only for a clear fit" was too strict, or the units had none; ask for one per run, not per unit.
- Reading lists: vendored math.js (57k lines) was listed as a primary file; "read in full" is impractical for it. SKILL.md (1022 lines) needs a table of contents in the context pack. The README read was redundant with the inventory.
- PAUSED.txt came from the folder listing, and one worker reported a doc that calls a listed module shippable again (I could not find that line when I looked, so unconfirmed). Check the paused list against plan.md before a run.
- Tag list lacked temporal band-pass, homeostat and analytic-gradient shading; three inventory workers used other:* slugs for them.

Not yet learned: how many of the 84 kept ideas the user adopts; whether a theme-level dedup step before Match would cut the match workload.

Addendum (same run, found while writing the idea files): a kept draft carried a wrong closed form in its tier-1 line (the Ising critical temperature written as 1/ln(2+sqrt 2), which is 0.81; the correct value is 2/ln(1+sqrt 2) = 2.269) and the verifier passed it, because verifiers check quotes and f_ overlap, not formulas. Sketches that state a formula need a formula-check instruction for the verifier or a flag for the architect to recompute.
