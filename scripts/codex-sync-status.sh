#!/usr/bin/env zsh
set -euo pipefail

script_dir="${0:A:h}"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$repo_root" ]]; then
  print -u2 "error: scripts/codex-sync-status.sh must be run from inside a Git repository."
  exit 1
fi

cd "$repo_root"

project_name="${1:-}"

print "Repo:"
pwd

print
print "Git status:"
git status --short

print
print "Latest commit:"
git log -1 --oneline 2>/dev/null || print "No commits yet."

print
print "Last Codex run:"
if [[ -f codex-runs/LAST-CODEX-RUN.md ]]; then
  cat codex-runs/LAST-CODEX-RUN.md
else
  print "codex-runs/LAST-CODEX-RUN.md not found."
fi

if [[ -n "$project_name" ]]; then
  if [[ "$project_name" == *"/"* || "$project_name" == "." || "$project_name" == ".." ]]; then
    print -u2 "error: project argument must be a single safe path segment."
    exit 2
  fi

  project_path="project-handovers/$project_name/LAST-HANDOVER.md"
  by_project_path="codex-runs/by-project/$project_name/LAST.md"
  recent_dir="project-handovers/$project_name/recent"

  print
  print "Project latest Codex run: $by_project_path"
  if [[ -f "$by_project_path" ]]; then
    cat "$by_project_path"
  else
    print "$by_project_path not found."
  fi

  print
  print "Project handover: $project_path"
  if [[ -f "$project_path" ]]; then
    cat "$project_path"
  else
    print "$project_path not found."
  fi

  print
  print "Recent handovers: $recent_dir"
  if [[ -d "$recent_dir" ]]; then
    recent_files=()
    while IFS= read -r recent_file; do
      [[ -n "$recent_file" ]] && recent_files+=("$recent_file")
    done < <(find "$recent_dir" -type f -name '*.md' -print | sort -r)
    if (( ${#recent_files[@]} > 0 )); then
      printf '%s\n' "${recent_files[@]}"
    else
      print "No recent handovers found."
    fi
  else
    print "$recent_dir not found."
  fi
fi
