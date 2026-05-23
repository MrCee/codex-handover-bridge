#!/usr/bin/env zsh
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/init-handover-repo.sh <handover-repo-path> [--git-init]

Creates a local private handover repo structure:
  codex-runs/LAST-CODEX-RUN.md
  project-handovers/.gitkeep
  templates/.gitkeep
  .gitignore

This script does not create a GitHub repo and does not push.
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 1 ]]; then
  usage
  exit 0
fi

handover_repo="$1"
git_init=false

shift
while (( $# > 0 )); do
  case "$1" in
    --git-init)
      git_init=true
      ;;
    *)
      print -u2 "error: unknown argument: $1"
      usage
      exit 2
      ;;
  esac
  shift
done

mkdir -p "$handover_repo/codex-runs" "$handover_repo/project-handovers" "$handover_repo/templates"

if [[ ! -f "$handover_repo/codex-runs/LAST-CODEX-RUN.md" ]]; then
  cat > "$handover_repo/codex-runs/LAST-CODEX-RUN.md" <<'EOF'
# Latest Codex Run

- date/time:
- source project:
- local path:
- GitHub repo:
- current branch:
- current commit:
- task requested:

## Files Inspected

- 

## Files Changed

- 

## Commands Run

- 

## Validation Performed

- 

## Validation Result

-

## Risks / Unknowns

- 

## Next Safest Action For ChatGPT Web UI

-
EOF
fi

touch "$handover_repo/project-handovers/.gitkeep"
touch "$handover_repo/templates/.gitkeep"

if [[ ! -f "$handover_repo/.gitignore" ]]; then
  cat > "$handover_repo/.gitignore" <<'EOF'
.DS_Store
.env
.env.*
secrets/
private/
*.tmp
*.log
AGENTS.local.md
local/
codex-runs/private/
project-handovers/private/
EOF
fi

if $git_init && [[ ! -d "$handover_repo/.git" ]]; then
  git -C "$handover_repo" init
fi

cat <<EOF
Created handover repo structure at:
  $handover_repo

Next steps:
  cd "$handover_repo"
  git init
  git add .gitignore codex-runs/LAST-CODEX-RUN.md project-handovers/.gitkeep templates/.gitkeep
  git commit -m "chore(init): create handover repo"
  gh repo create <owner>/<private-handover-repo> --private --source . --remote origin --push
EOF

