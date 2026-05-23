#!/usr/bin/env zsh
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/promote-public-candidate.sh [--title <title>] [--note <text>]

Prints a safe private-to-public promotion checklist.

This script does not copy files from the private handover repo.
If --title is provided, it creates a Markdown note under public-candidates/
for tracking a sanitized public improvement idea.
USAGE
}

title=""
note=""

while (( $# > 0 )); do
  case "$1" in
    --title)
      title="${2:?missing value for --title}"
      shift 2
      ;;
    --note)
      note="${2:?missing value for --note}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      print -u2 "error: unknown argument: $1"
      usage
      exit 2
      ;;
  esac
done

cat <<'EOF'
Private to public promotion check

Private operational repo:
  ~/repos/codex-sync

Public template repo:
  ~/repos/codex-handover-bridge

Do not copy private repo contents automatically.
Prefer reimplementing the generic idea cleanly in the public repo.

Public promotion checklist:
1. Is this change generic?
2. Does it remove all private paths?
3. Does it remove all personal names/emails?
4. Does it avoid secrets and sensitive material?
5. Does it help other users?
6. Has the diff been reviewed before commit?
7. Is the public commit message clear?
EOF

if [[ -n "$title" ]]; then
  repo_root="$(git -C "${0:A:h}" rev-parse --show-toplevel 2>/dev/null || pwd)"
  mkdir -p "$repo_root/public-candidates"
  slug="$(print -r -- "$title" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '-' | sed 's/^-//; s/-$//')"
  if [[ -z "$slug" ]]; then
    slug="candidate"
  fi
  path="$repo_root/public-candidates/$(date '+%Y%m%d-%H%M%S')-$slug.md"

  cat > "$path" <<EOF
# Public Candidate: $title

- created: $(date '+%Y-%m-%d %H:%M:%S %Z')
- private source repo: ~/repos/codex-sync
- public target repo: ~/repos/codex-handover-bridge

## Note

${note:-Describe the generic public improvement here. Do not paste private content.}

## Sanitisation Checklist

- [ ] Is this change generic?
- [ ] Does it remove all private paths?
- [ ] Does it remove all personal names/emails?
- [ ] Does it avoid secrets and sensitive material?
- [ ] Does it help other users?
- [ ] Has the diff been reviewed before commit?
- [ ] Is the public commit message clear?

## Implementation Guidance

Reimplement the idea cleanly in the public repo. Do not copy private handovers, raw logs, project-specific instructions, or sensitive source material.
EOF

  print
  print "Created public candidate note:"
  print "  $path"
fi

