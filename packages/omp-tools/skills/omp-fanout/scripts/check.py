#!/usr/bin/env python3
"""Fan-out run helper. Standard library only.

Run layout (RUN_DIR):
  snapshot/            read-only copy of the material being examined
  findings/<unit>.json list of finding objects written by workers
  verdicts/<id>.json   one verdict per finding, written by verifiers
  checked/<unit>.json  written by `validate`
  notes.md             optional: things that went wrong, written by the lead
  REPORT.md            written by `report`

Commands:
  check.py validate RUN_DIR   locate every quote in snapshot/, merge duplicates, write checked/
  check.py pending RUN_DIR    print ids that need a verdict: none yet, or the verdict file is unusable
  check.py show RUN_DIR ID    print what a verifier may see (no worker reasoning)
  check.py report RUN_DIR     render REPORT.md from checked/ and verdicts/
"""
import json
import sys
from pathlib import Path

SEV = {"high": 0, "med": 1, "low": 2}
REAL = ("yes", "no", "unsure")


def norm_map(text):
    """Collapse whitespace; remember the source line of every kept character."""
    out, lines, line, prev_space = [], [], 1, True
    for ch in text:
        if ch == "\n":
            line += 1
        if ch.isspace():
            if not prev_space:
                out.append(" ")
                lines.append(line)
            prev_space = True
        else:
            out.append(ch)
            lines.append(line)
            prev_space = False
    return "".join(out), lines


def locate(snapshot, rel, quote):
    """Return ((first_line, last_line), 'ok') or (None, reason)."""
    path = Path(snapshot) / rel
    if not path.is_file():
        return None, "file_missing"
    nq = " ".join(str(quote).split())
    if not nq:
        return None, "empty_quote"
    nt, lines = norm_map(path.read_text(errors="replace"))
    i = nt.find(nq)
    if i < 0:
        return None, "quote_not_found"
    return (lines[i], lines[i + len(nq) - 1]), "ok"


def fix_unique(snapshot, fix):
    if not fix:
        return False
    path = Path(snapshot) / fix.get("file", "")
    if not path.is_file() or not fix.get("old_text"):
        return False
    return path.read_text(errors="replace").count(fix["old_text"]) == 1


def load(path):
    try:
        return json.loads(Path(path).read_text())
    except Exception as exc:  # malformed JSON is a result, not a crash
        return {"_error": str(exc)}


def overlap(a, b):
    return bool(a and b) and a[0] <= b[1] and b[0] <= a[1]


def validate(run):
    run = Path(run)
    snap = run / "snapshot"
    (run / "checked").mkdir(exist_ok=True)
    total = bad_files = rejected = dupes = 0
    loaded = []
    for f in sorted((run / "findings").glob("*.json")):
        data = load(f)
        if isinstance(data, dict) and "_error" in data or not isinstance(data, list):
            bad_files += 1
            print(f"MALFORMED {f.name}: needs a retry from the worker")
            continue
        for fd in data:
            total += 1
            problems = []
            claim = fd.get("claim") or {}
            loc, why = locate(snap, claim.get("file", ""), claim.get("quote", ""))
            fd["claim_lines"] = loc
            if why != "ok":
                problems.append(f"claim:{why}")
            ev_ok = True
            fd["evidence_lines"] = []
            for ev in fd.get("evidence") or []:
                eloc, ewhy = locate(snap, ev.get("file", ""), ev.get("quote", ""))
                fd["evidence_lines"].append(eloc)
                if ewhy != "ok":
                    ev_ok = False
                    problems.append(f"evidence:{ewhy}")
            fd["evidence_ok"] = ev_ok and bool(fd.get("evidence"))
            fd["fix_unique"] = fix_unique(snap, fd.get("proposed_fix"))
            fd["problems"] = problems
            fd["status"] = "auto_rejected" if f"claim:{why}" in problems else "verify"
            rejected += fd["status"] == "auto_rejected"
        loaded.append((f, data))
    # Merge duplicates: two surviving findings whose claim lines overlap in the same file
    # are one root cause reported from two units. Keep the first, list the rest.
    kept = []
    for f, data in loaded:
        for fd in data:
            if fd["status"] != "verify":
                continue
            cf = (fd.get("claim") or {}).get("file", "")
            twin = next((k for k in kept if k[0] == cf and overlap(k[1], fd["claim_lines"])), None)
            if twin:
                fd["status"] = "duplicate"
                fd["duplicate_of"] = twin[2]
                dupes += 1
            else:
                kept.append((cf, fd["claim_lines"], fd.get("id")))
    for f, data in loaded:
        (run / "checked" / f.name).write_text(json.dumps(data, indent=2))
    print(f"findings={total} auto_rejected={rejected} duplicates_merged={dupes} malformed_files={bad_files}")


def all_checked(run):
    for f in sorted((Path(run) / "checked").glob("*.json")):
        data = load(f)
        if isinstance(data, list):
            yield from data


def usable_verdict(run, fid):
    p = Path(run) / "verdicts" / f"{fid}.json"
    if not p.exists():
        return None, "missing"
    v = load(p)
    if "_error" in v:
        return None, "malformed"
    if v.get("finding_real") not in REAL:
        return None, "missing finding_real"
    return v, "ok"


def pending(run):
    for fd in all_checked(run):
        if fd["status"] == "verify" and usable_verdict(run, fd["id"])[0] is None:
            print(fd["id"])


def show(run, fid):
    for fd in all_checked(run):
        if fd["id"] == fid:
            print(json.dumps({
                "id": fd["id"],
                "claim": fd.get("claim"),
                "evidence": fd.get("evidence"),
                "proposed_fix": fd.get("proposed_fix"),
            }, indent=2))
            return
    sys.exit(f"no such finding: {fid}")


def fmt_lines(loc):
    if not loc:
        return "?"
    return f"{loc[0]}" if loc[0] == loc[1] else f"{loc[0]}-{loc[1]}"


def first_sentence(text, limit=220):
    text = " ".join(str(text).split())
    cut = text.find(". ")
    s = text if cut < 0 else text[:cut + 1]
    return s if len(s) <= limit else s[:limit - 1] + "…"


def compact(fd, v):
    c = fd.get("claim") or {}
    pf = fd.get("proposed_fix")
    line = f"- **{fd['id']}** [{fd.get('severity', '?')}] `{c.get('file', '?')}:{fmt_lines(fd.get('claim_lines'))}` {first_sentence(fd.get('why', ''))}"
    if pf:
        line += f"\n  - `{pf['file']}`: \"{' '.join(pf['old_text'].split())[:110]}\" → \"{' '.join(pf['new_text'].split())[:110]}\""
    return line


def item(fd, v, why_unverified=None):
    c = fd.get("claim") or {}
    out = [f"**{fd['id']}** [{fd.get('severity', '?')}] `{c.get('file', '?')}:{fmt_lines(fd.get('claim_lines'))}`",
           f"- {fd.get('why', '')}",
           f"- claim: \"{' '.join(str(c.get('quote', '')).split())}\""]
    if why_unverified:
        out.append(f"- no usable verdict ({why_unverified}): re-run the verifier")
    if v and v.get("reason"):
        out.append(f"- verifier: {v['reason']}")
    if fd.get("needs_decision"):
        out.append(f"- decision needed: {fd['needs_decision']}")
    pf = fd.get("proposed_fix")
    if pf and v and v.get("fix_grounded") == "no":
        out.append("- verifier says the proposed fix is NOT grounded: do not apply it")
    elif pf and fd.get("fix_unique"):
        out.append(f"- proposed fix in `{pf['file']}`: replace \"{' '.join(pf['old_text'].split())[:160]}\" with \"{' '.join(pf['new_text'].split())[:160]}\"")
    elif pf:
        out.append("- proposed fix present but its old_text does not match exactly once (do not apply as is)")
    if fd.get("problems"):
        out.append(f"- check problems: {', '.join(fd['problems'])}")
    return "\n".join(out)


def report(run):
    run = Path(run)
    apply_, decide, rejected, unverified, merged = [], [], [], [], []
    for fd in all_checked(run):
        if fd["status"] == "duplicate":
            merged.append(fd)
            continue
        v, state = usable_verdict(run, fd["id"])
        if fd["status"] == "auto_rejected":
            rejected.append((fd, v, "quote not found at snapshot"))
        elif v is None:
            unverified.append((fd, state))
        elif v.get("finding_real") == "no":
            rejected.append((fd, v, v.get("reason", "")))
        elif (v.get("finding_real") == "yes" and v.get("fix_grounded") == "yes"
              and fd.get("proposed_fix") and fd["fix_unique"] and fd["evidence_ok"]
              and not fd.get("needs_decision")):
            apply_.append((fd, v))
        else:
            decide.append((fd, v))
    key = lambda t: SEV.get(t[0].get("severity"), 3)
    for lst in (apply_, decide, unverified):
        lst.sort(key=key)
    parts = ["# REPORT", "",
             f"Apply-ready: {len(apply_)} | Needs decision: {len(decide)} | "
             f"Rejected: {len(rejected)} | Not verified: {len(unverified)} | "
             f"Merged duplicates: {len(merged)}", ""]
    full = list(parts)
    parts += ["## Apply-ready (verified, fix grounded, old_text unique)", ""]
    parts += [compact(fd, v) for fd, v in apply_] or ["_none_"]
    parts += ["", "## Needs decision", ""]
    parts += [compact(fd, v) + (f"\n  - decision: {first_sentence(fd['needs_decision'], 260)}" if fd.get("needs_decision") else "") + (f"\n  - verifier: {first_sentence(v['reason'])}" if v and v.get("reason") else "") for fd, v in decide] or ["_none_"]
    full += ["## Apply-ready (verified, fix grounded, old_text unique)", ""]
    full += [item(fd, v) + "\n" for fd, v in apply_] or ["_none_", ""]
    full += ["## Needs decision", ""]
    full += [item(fd, v) + "\n" for fd, v in decide] or ["_none_", ""]
    parts += ["## Not verified", ""]
    parts += [item(fd, None, st) + "\n" for fd, st in unverified] or ["_none_", ""]
    parts += ["## Rejected (one line each)", ""]
    for fd, v, why in rejected:
        parts.append(f"- {fd['id']}: {' '.join(str((fd.get('claim') or {}).get('quote', '')).split())[:100]} -- {why}")
    if not rejected:
        parts.append("_none_")
    parts += ["", "## Merged duplicates (same claim lines as another finding)", ""]
    parts += [f"- {fd['id']} merged into {fd.get('duplicate_of')}" for fd in merged] or ["_none_"]
    empty = [f.stem for f in sorted((run / "findings").glob("*.json"))
             if load(f) == []]
    parts += ["", "## Units with no findings", "", ", ".join(empty) if empty else "_none_"]
    notes = run / "notes.md"
    parts += ["", "## What could not be done", "",
              notes.read_text().strip() if notes.exists() and notes.read_text().strip() else "_nothing recorded_", ""]
    (run / "REPORT.md").write_text("\n".join(parts))
    (run / "REPORT_FULL.md").write_text("\n".join(full + parts[parts.index("## Not verified"):]))
    print(f"wrote {run / 'REPORT.md'} (compact) and REPORT_FULL.md")


if __name__ == "__main__":
    a = sys.argv[1:]
    cmds = {"validate": (validate, 1), "pending": (pending, 1), "show": (show, 2), "report": (report, 1)}
    if not a or a[0] not in cmds or len(a) - 1 != cmds[a[0]][1]:
        sys.exit(__doc__)
    cmds[a[0]][0](*a[1:])
