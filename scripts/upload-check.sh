#!/bin/sh
# upload-check.sh: which skills are out of date on each claude.ai account.
#
# claude.ai uploads are copies. manifests/uploads-<account>.md records each skill's
# hash as of the last upload to that account (Pro and Team can differ).
#
#   scripts/upload-check.sh [check] [--account A]     report ok / STALE / NEW / REMOVED / INVALID
#   scripts/upload-check.sh names --account A          print the STALE and NEW names, space-separated
#   scripts/upload-check.sh stamp --account A [skill...]
#                                                      record the current state; run AFTER uploading.
#                                                      No names = every skill; names = only those.
#
# check with no --account reports every account that has a manifest (or says to stamp one).
# Typical flow: names --account pro | build-zips.sh | upload | stamp --account pro
# Exit: 0 clean, 1 drift or invalid skill, 2 usage error.

set -eu

REPO=$(cd "$(dirname "$0")/.." && pwd)
. "$REPO/scripts/lib-skills.sh"
MDIR="$REPO/manifests"

CMD=check; ACCOUNT=""; NAMES=""
case "${1:-}" in check|names|stamp) CMD="$1"; shift ;; esac
while [ $# -gt 0 ]; do
  case "$1" in
    --account) ACCOUNT="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) NAMES="$NAMES $1"; shift ;;
  esac
done

case "$ACCOUNT" in
  ""|*[!a-z0-9-]*|-*) [ -z "$ACCOUNT" ] || { echo "invalid --account '$ACCOUNT' (use lowercase letters, digits, hyphens)" >&2; exit 2; } ;;
esac

ALL=$(skills_list)
dups=$(printf '%s\n' "$ALL" | awk '{print $2}' | sort | uniq -d)
[ -z "$dups" ] || { echo "duplicate skill names across packages: $dups" >&2; exit 2; }

dir_of() { printf '%s\n' "$ALL" | awk -v n="$1" '$2==n{print $1"/"$2}'; }
mfile() { echo "$MDIR/uploads-$1.md"; }
# "<skill> <hash> <date>" rows of a manifest
rows() { [ -f "$1" ] && sed -n 's/^| `\([^`]*\)` | \([0-9a-f]*\) | [0-9]* | \([0-9-]*\) |$/\1 \2 \3/p' "$1" || true; }

check_account() {
  acct="$1"; mf=$(mfile "$acct"); drift=0
  echo "== account: $acct"
  [ -f "$mf" ] || echo "   (no manifest: every skill counts as NEW until you stamp after uploading)"
  printf '%s\n' "$ALL" | while read -r d s; do
    p=$(skill_problem "$d/$s"); [ -z "$p" ] || printf 'INVALID  %-34s %s\n' "$s" "$p"
  done
  tmp=$(mktemp); rows "$mf" > "$tmp"
  nok=0; nbad=0
  for s in $(printf '%s\n' "$ALL" | awk '{print $2}' | sort); do
    h=$(skill_hash "$(dir_of "$s")")
    old=$(awk -v n="$s" '$1==n{print $2}' "$tmp")
    when=$(awk -v n="$s" '$1==n{print $3}' "$tmp")
    if [ -z "$old" ]; then printf 'NEW      %s\n' "$s"; nbad=$((nbad+1))
    elif [ "$old" != "$h" ]; then printf 'STALE    %-34s uploaded %s\n' "$s" "$when"; nbad=$((nbad+1))
    else nok=$((nok+1)); fi
  done
  for s in $(awk '{print $1}' "$tmp"); do
    [ -n "$(dir_of "$s")" ] || { printf 'REMOVED  %-34s still on %s; delete it there\n' "$s" "$acct"; nbad=$((nbad+1)); }
  done
  rm -f "$tmp"
  echo "   ok $nok, need attention $nbad"
  [ "$nbad" -eq 0 ]
}

accounts_found() { ls "$MDIR"/uploads-*.md 2>/dev/null | sed 's|.*/uploads-||;s|\.md$||'; }

case "$CMD" in
  check)
    rc=0
    if [ -n "$ACCOUNT" ]; then accts="$ACCOUNT"; else accts=$(accounts_found); fi
    if [ -z "$accts" ]; then
      echo "no manifests yet. After uploading, run: scripts/upload-check.sh stamp --account pro (and team)"
      printf '%s\n' "$ALL" | awk '{print "NEW      "$2}'; exit 1
    fi
    for a in $accts; do check_account "$a" || rc=1; done
    exit $rc ;;
  names)
    [ -n "$ACCOUNT" ] || { echo "names needs --account" >&2; exit 2; }
    mf=$(mfile "$ACCOUNT"); tmp=$(mktemp); rows "$mf" > "$tmp"; out=""
    for s in $(printf '%s\n' "$ALL" | awk '{print $2}' | sort); do
      old=$(awk -v n="$s" '$1==n{print $2}' "$tmp")
      [ "$old" = "$(skill_hash "$(dir_of "$s")")" ] || out="$out $s"
    done
    rm -f "$tmp"; echo $out ;;
  stamp)
    [ -n "$ACCOUNT" ] || { echo "stamp needs --account" >&2; exit 2; }
    for n in $NAMES; do [ -n "$(dir_of "$n")" ] || { echo "no such skill: $n" >&2; exit 2; }; done
    mkdir -p "$MDIR"; mf=$(mfile "$ACCOUNT"); old=$(mktemp); new=$(mktemp)
    rows "$mf" > "$old"; today=$(date +%Y-%m-%d)
    for s in $(printf '%s\n' "$ALL" | awk '{print $2}' | sort); do
      if [ -z "$NAMES" ] || case " $NAMES " in *" $s "*) true;; *) false;; esac; then
        printf '%s %s %s\n' "$s" "$(skill_hash "$(dir_of "$s")")" "$today" >> "$new"
      else
        grep "^$s " "$old" >> "$new" || true   # keep previous row; none if never uploaded
      fi
    done
    {
      echo "# Upload manifest: $ACCOUNT"
      echo
      echo "State of each skill as of its last upload to the $ACCOUNT claude.ai account."
      echo "Written by \`scripts/upload-check.sh stamp --account $ACCOUNT\`, run AFTER uploading. Do not edit by hand."
      echo
      echo "| skill | sha256(12) | lines | uploaded |"
      echo "|---|---|---|---|"
      while read -r s h w; do
        printf '| `%s` | %s | %s | %s |\n' "$s" "$h" "$(skill_lines "$(dir_of "$s")")" "$w"
      done < "$new"
    } > "$mf"
    if [ -z "$NAMES" ]; then k=$(wc -l < "$new" | tr -d ' '); else k=$(echo $NAMES | wc -w | tr -d ' '); fi
    echo "stamped $k skill(s); manifest now lists $(wc -l < "$new" | tr -d ' ') -> $mf"
    rm -f "$old" "$new" ;;
esac
