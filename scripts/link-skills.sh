#!/bin/sh
# Link this repo's skills into the places agents read them from, so one edit here
# is live everywhere on this machine. Safe to re-run. Never touches real files.
#
#   claude  -> ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/<skill>   (Claude Code)
#   agents  -> $HOME/.agents/skills/<skill>                         (pi, omp, other Agent Skills tools)
#
# Usage: scripts/link-skills.sh [--dry-run] [--unlink] [--packages "a b"] [--targets "claude agents"]
#   --dry-run    show what would happen, change nothing
#   --unlink     remove only the links this repo made (links pointing into this repo)
#   --packages   package folders under packages/ to link (default: all)
#   --targets    claude and/or agents (default: both)
# Exit 1 if any destination was left alone because something else is there.

set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd -P)"
DRY=0; UNLINK=0; PACKAGES=""; TARGETS="claude agents"

usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --unlink) UNLINK=1 ;;
    --packages) shift; PACKAGES="$1" ;;
    --targets) shift; TARGETS="$1" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [ -z "$PACKAGES" ]; then
  for d in "$REPO"/packages/*/; do
    [ -f "$d/apm.yml" ] && PACKAGES="$PACKAGES $(basename "$d")"
  done
fi

target_dir() {
  case "$1" in
    claude) echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" ;;
    agents) echo "$HOME/.agents/skills" ;;
    *) echo "unknown target: $1" >&2; exit 2 ;;
  esac
}

LIST="$(mktemp)"; trap 'rm -f "$LIST"' EXIT
for pkg in $PACKAGES; do
  [ -d "$REPO/packages/$pkg/skills" ] || { echo "no such package: $pkg" >&2; exit 2; }
  for d in "$REPO/packages/$pkg/skills"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    printf '%s|%s\n' "$(basename "$d")" "${d%/}" >> "$LIST"
  done
done

DUPS="$(cut -d'|' -f1 "$LIST" | sort | uniq -d)"
if [ -n "$DUPS" ]; then
  echo "duplicate skill folder names across packages (names must be unique):" >&2
  echo "$DUPS" >&2; exit 2
fi
if cut -d'|' -f1 "$LIST" | grep -qix 'synced'; then
  echo "a skill is named 'synced', a reserved name in Claude Code; rename it" >&2; exit 2
fi

LINKED=0; OK=0; CONFLICT=0; REMOVED=0; PRUNED=0
say() { printf '%-9s %-7s %s\n' "$1" "$2" "$3"; }

for t in $TARGETS; do
  TD="$(target_dir "$t")"

  if [ "$UNLINK" -eq 1 ]; then
    for e in "$TD"/*; do
      [ -L "$e" ] || continue
      case "$(readlink "$e")" in
        "$REPO"/packages/*) say "unlink" "$t" "$(basename "$e")"
                            [ "$DRY" -eq 1 ] || rm "$e"; REMOVED=$((REMOVED+1)) ;;
      esac
    done
    continue
  fi

  while IFS='|' read -r name src; do
    dest="$TD/$name"
    if [ -L "$dest" ]; then
      cur="$(readlink "$dest")"
      if [ "$cur" = "$src" ]; then OK=$((OK+1))
      else say "CONFLICT" "$t" "$name (a link to $cur is already there)"; CONFLICT=$((CONFLICT+1)); fi
    elif [ -e "$dest" ]; then
      say "CONFLICT" "$t" "$name (a real file or folder is already there)"; CONFLICT=$((CONFLICT+1))
    else
      say "link" "$t" "$name"
      if [ "$DRY" -eq 0 ]; then mkdir -p "$TD"; ln -s "$src" "$dest"; fi
      LINKED=$((LINKED+1))
    fi
  done < "$LIST"

  # remove our own links whose skill no longer exists (renamed or deleted here)
  for e in "$TD"/*; do
    [ -L "$e" ] || continue
    case "$(readlink "$e")" in
      "$REPO"/packages/*) [ -e "$e" ] || { say "prune" "$t" "$(basename "$e") (skill no longer in repo)"
                                           [ "$DRY" -eq 1 ] || rm "$e"; PRUNED=$((PRUNED+1)); } ;;
    esac
  done
done

if [ "$UNLINK" -eq 1 ]; then
  echo "unlinked $REMOVED"
else
  echo "linked $LINKED, already correct $OK, pruned $PRUNED, conflicts $CONFLICT"
fi
[ "$DRY" -eq 1 ] && echo "(dry run: nothing changed)"
[ "$CONFLICT" -eq 0 ]
