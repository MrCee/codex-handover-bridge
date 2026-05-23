#!/usr/bin/env zsh
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/publish-latest-handover.sh <handover-repo-path> <project-name> <source-project-path> [options]

Required:
  handover-repo-path     Local path to the private handover repo.
  project-name           Safe project identifier for project-handovers/<project-name>/.
  source-project-path    Local path to the source project.

Options:
  --task <text>          Task requested.
  --inspected <text>     Files inspected summary.
  --changed <text>       Files changed summary.
  --commands <text>      Commands run summary.
  --validation <text>    Validation performed.
  --validation-result <text>
                         Validation result.
  --risks <text>         Risks or unknowns.
  --next <text>          Next safest action.
  -h, --help             Show this help.

This script stages only:
  codex-runs/LAST-CODEX-RUN.md
  project-handovers/<project-name>/LAST-HANDOVER.md

It commits if those files changed and pushes only if a remote exists.
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 3 ]]; then
  usage
  exit 0
fi

handover_repo="$1"
project_name="$2"
source_project_path="$3"
shift 3

task="Not provided."
inspected="Not provided."
changed="Not provided."
commands="Not provided."
validation="Not provided."
validation_result="Not provided."
risks="Not provided."
next_action="Review this handover and continue from the safest listed next step."

while (( $# > 0 )); do
  case "$1" in
    --task)
      task="${2:?missing value for --task}"
      shift 2
      ;;
    --inspected)
      inspected="${2:?missing value for --inspected}"
      shift 2
      ;;
    --changed)
      changed="${2:?missing value for --changed}"
      shift 2
      ;;
    --commands)
      commands="${2:?missing value for --commands}"
      shift 2
      ;;
    --validation)
      validation="${2:?missing value for --validation}"
      shift 2
      ;;
    --validation-result)
      validation_result="${2:?missing value for --validation-result}"
      shift 2
      ;;
    --risks)
      risks="${2:?missing value for --risks}"
      shift 2
      ;;
    --next)
      next_action="${2:?missing value for --next}"
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

if [[ "$project_name" == *"/"* || "$project_name" == "." || "$project_name" == ".." || -z "$project_name" ]]; then
  print -u2 "error: project-name must be a single safe path segment."
  exit 2
fi

if [[ ! -d "$handover_repo/.git" ]]; then
  print -u2 "error: handover repo is not a Git repository: $handover_repo"
  exit 1
fi

if [[ ! -d "$source_project_path" ]]; then
  print -u2 "error: source project path does not exist: $source_project_path"
  exit 1
fi

mkdir -p "$handover_repo/codex-runs" "$handover_repo/project-handovers/$project_name"

now="$(date '+%Y-%m-%d %H:%M:%S %Z')"
source_repo="$(git -C "$source_project_path" remote get-url origin 2>/dev/null || print "unknown")"
branch="$(git -C "$source_project_path" branch --show-current 2>/dev/null || print "unknown")"
commit="$(git -C "$source_project_path" rev-parse HEAD 2>/dev/null || print "unknown")"

latest_path="$handover_repo/codex-runs/LAST-CODEX-RUN.md"
project_path="$handover_repo/project-handovers/$project_name/LAST-HANDOVER.md"

write_handover() {
  local path="$1"
  local title="$2"

  cat > "$path" <<EOF
# $title

- date/time: $now
- source project: $project_name
- local path: $source_project_path
- GitHub repo: $source_repo
- current branch: $branch
- current commit: $commit
- task requested: $task

## Files Inspected

- $inspected

## Files Changed

- $changed

## Commands Run

- $commands

## Validation Performed

- $validation

## Validation Result

- $validation_result

## Risks / Unknowns

- $risks

## Next Safest Action For ChatGPT Web UI

- $next_action
EOF
}

write_handover "$latest_path" "Latest Codex Run"
write_handover "$project_path" "Project Handover"

git -C "$handover_repo" status --short
git -C "$handover_repo" add codex-runs/LAST-CODEX-RUN.md "project-handovers/$project_name/LAST-HANDOVER.md"

if git -C "$handover_repo" diff --cached --quiet; then
  print "No handover changes to commit."
  exit 0
fi

git -C "$handover_repo" commit -m "docs(sync): update latest handover"

if git -C "$handover_repo" remote get-url origin >/dev/null 2>&1; then
  git -C "$handover_repo" push origin "$(git -C "$handover_repo" branch --show-current)"
else
  print "No origin remote configured; committed locally only."
fi
