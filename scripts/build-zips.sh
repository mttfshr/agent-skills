#!/bin/sh
# build-zips.sh: build claude.ai upload zips from packages/*/skills/*.
#
# One zip per skill -> dist/<skill>.zip, with the <skill>/ folder at the zip root
# (the layout claude.ai accepts). dist/ is generated and gitignored; never edit it.
#
# Usage:
#   scripts/build-zips.sh                 build every skill
#   scripts/build-zips.sh plan-workflow   build only the named skills
#   scripts/build-zips.sh --out DIR       write somewhere other than dist/
#   scripts/build-zips.sh -h
#
# Refuses to zip a skill that claude.ai would reject: description over 1024
# characters, or containing < or >. Exit 1 if any skill is refused, 2 on a
# usage error or a duplicate skill name across packages.

set -eu

REPO=$(cd "$(dirname "$0")/.." && pwd)
. "$REPO/scripts/lib-skills.sh"
OUT="$REPO/dist"
NAMES=""

while [ $# -gt 0 ]; do
  case "$1" in
    --out) OUT="$2"; shift 2 ;;
    -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) NAMES="$NAMES $1"; shift ;;
  esac
done

command -v zip >/dev/null 2>&1 || { echo "zip not found" >&2; exit 2; }

ALL=$(skills_list)

# duplicate skill names across packages
dups=$(printf '%s\n' "$ALL" | awk '{print $2}' | sort | uniq -d)
if [ -n "$dups" ]; then
  echo "duplicate skill names across packages: $dups" >&2
  exit 2
fi

# every requested name must exist
for n in $NAMES; do
  printf '%s\n' "$ALL" | awk -v n="$n" '$2==n{f=1} END{exit !f}' || { echo "no such skill: $n" >&2; exit 2; }
done

mkdir -p "$OUT"

printf '%s\n' "$ALL" | while read -r dir skill; do
  if [ -n "$NAMES" ]; then
    case " $NAMES " in *" $skill "*) ;; *) continue ;; esac
  fi
  md="$dir/$skill/SKILL.md"
  bad=$(skill_problem "$dir/$skill")
  if [ -n "$bad" ]; then
    printf 'REFUSED  %-34s %s\n' "$skill" "$bad"
    echo x >> "$OUT/.refused.$$"
    continue
  fi
  rm -f "$OUT/$skill.zip"
  ( cd "$dir" && zip -rqX "$OUT/$skill.zip" "$skill" -x '*.DS_Store' -x '*/__MACOSX/*' )
  printf 'built    %-34s %s\n' "$skill" "$(du -k "$OUT/$skill.zip" | awk '{print $1}')K"
  echo x >> "$OUT/.built.$$"
done

built=$( [ -f "$OUT/.built.$$" ] && wc -l < "$OUT/.built.$$" | tr -d ' ' || echo 0 )
refused=$( [ -f "$OUT/.refused.$$" ] && wc -l < "$OUT/.refused.$$" | tr -d ' ' || echo 0 )
rm -f "$OUT/.built.$$" "$OUT/.refused.$$"

echo "built $built, refused $refused -> $OUT"
[ "$refused" -eq 0 ]
