#!/usr/bin/env zsh
set -euo pipefail

# Generic example only. Copy into your private handover repo before use.
# Keep real hostnames, usernames, private paths, and SSH ports out of public repos.

usage() {
  cat <<'USAGE'
Usage:
  scripts/fleet-sync-and-publish.example.sh

Example safe publish sequence for a private handover repo:
  1. refuse to start if non-generated files are dirty,
  2. run a local fleet status/pull command,
  3. commit only approved generated handover/status files,
  4. push the private handover repo,
  5. optionally run a pull-only fan-out script that marks offline targets pending.

Adapt the generated allowlist and script names to your private repo.
USAGE
}

if (( $# > 0 )); then
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
fi

script_dir="${0:A:h}"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$repo_root" ]]; then
  echo "error: run this script from inside your private handover repo." >&2
  exit 1
fi

cd "$repo_root"

generated_path_allowed() {
  local candidate_path="$1"
  case "$candidate_path" in
    fleet/status/LATEST.md|\
    codex-runs/LAST-CODEX-RUN.md|\
    codex-runs/by-project/*/LAST.md|\
    project-handovers/*/LAST-HANDOVER.md)
      return 0
      ;;
    fleet/status/history/*.md|project-handovers/*/recent/*.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

status_path_from_line() {
  local line="$1"
  local candidate_path="${line[4,-1]}"
  if [[ "$candidate_path" == *" -> "* ]]; then
    candidate_path="${candidate_path##* -> }"
  fi
  print -- "$candidate_path"
}

assert_only_generated_dirty() {
  local context="$1"
  local bad_paths=()
  local line candidate_path

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    candidate_path="$(status_path_from_line "$line")"
    if ! generated_path_allowed "$candidate_path"; then
      bad_paths+=("$line")
    fi
  done < <(git status --porcelain --untracked-files=all)

  if (( ${#bad_paths[@]} > 0 )); then
    echo "error: refusing to continue during $context because non-generated files are dirty:" >&2
    for line in "${bad_paths[@]}"; do
      echo "  $line" >&2
    done
    exit 10
  fi
}

stage_generated_files() {
  [[ -e fleet/status/LATEST.md ]] && git add fleet/status/LATEST.md
  [[ -d fleet/status/history ]] && git add fleet/status/history/*.md(N)
  [[ -e codex-runs/LAST-CODEX-RUN.md ]] && git add codex-runs/LAST-CODEX-RUN.md
  [[ -d codex-runs/by-project ]] && git add codex-runs/by-project/*/LAST.md(N)
  [[ -d project-handovers ]] && git add project-handovers/*/LAST-HANDOVER.md(N)
  [[ -d project-handovers ]] && git add project-handovers/*/recent/*.md(N)
}

status_script="${FLEET_STATUS_SCRIPT:-scripts/fleet-sync-status.sh}"
fanout_script="${FLEET_FANOUT_SCRIPT:-scripts/sync-codex-environments.sh}"

echo "==> Checking private handover repo worktree"
assert_only_generated_dirty "pre-flight"

if [[ ! -x "$status_script" ]]; then
  echo "error: missing executable fleet status script: $status_script" >&2
  exit 11
fi

echo "==> Running local fleet status and safe pull"
"$status_script" --all --pull

echo "==> Publishing approved generated files only"
assert_only_generated_dirty "post-status"
stage_generated_files

if ! git diff --cached --quiet; then
  git commit -m "docs(fleet): publish latest fleet status"
  git push origin main
else
  echo "No generated fleet status changes to publish."
fi

if [[ -n "$(git status --porcelain --untracked-files=all)" ]]; then
  echo "error: private handover repo is still dirty after generated-file publish:" >&2
  git status --short >&2
  exit 12
fi

if [[ -x "$fanout_script" ]]; then
  echo "==> Running optional fan-out"
  "$fanout_script" --continue-offline
else
  echo "No executable fan-out script found; publish finished locally."
fi
