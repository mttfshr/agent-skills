# lib-skills.sh: shared helpers, sourced (not run) by build-zips.sh and upload-check.sh.
# Expects REPO to be set to the repo root.

# "<package skills dir> <skill>" for every skill in every package with an apm.yml
skills_list() {
  for pkg in "$REPO"/packages/*/; do
    [ -f "$pkg/apm.yml" ] || continue
    for s in "$pkg"skills/*/; do
      [ -f "$s/SKILL.md" ] || continue
      printf '%s %s\n' "${pkg}skills" "$(basename "$s")"
    done
  done
}

# description from a SKILL.md frontmatter: one line (optionally quoted) or a
# YAML block scalar (> >- | |-), joined with single spaces
skill_desc() {
  awk '
    NR==1 && $0!="---" {exit}
    NR>1 && $0=="---" {exit}
    /^description:/ {
      v=$0; sub(/^description:[ ]*/,"",v)
      if (v ~ /^[>|][-+]?[ ]*$/) { blk=1; next }
      gsub(/^["\x27]|["\x27]$/,"",v); print v; exit
    }
    blk && /^[ \t]+/ { l=$0; sub(/^[ \t]+/,"",l); out = (out=="" ? l : out " " l); next }
    blk { print out; exit }
    END { if (blk && out!="") print out }
  ' "$1" | head -n 1
}

# claude.ai upload rules; prints the problem (nothing if fine)
skill_problem() {
  d=$(skill_desc "$1/SKILL.md")
  n=$(printf '%s' "$d" | wc -m | tr -d ' ')
  [ "$n" -gt 1024 ] && { echo "description is $n chars (max 1024)"; return; }
  case "$d" in *"<"*|*">"*) echo "description contains < or > (read as an XML tag)";; esac
  return 0
}

# first 12 hex of sha256 over SKILL.md then every other file in the folder (sorted)
skill_hash() {
  { cat "$1/SKILL.md"; find "$1" -type f ! -name SKILL.md ! -name .DS_Store | LC_ALL=C sort | xargs cat 2>/dev/null; } \
    | shasum -a 256 | awk '{print substr($1,1,12)}'
}

skill_lines() { awk 'END{print NR}' "$1/SKILL.md"; }
