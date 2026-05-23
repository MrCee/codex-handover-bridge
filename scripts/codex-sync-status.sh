#!/usr/bin/env zsh
set -euo pipefail

script_dir="${0:A:h}"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$repo_root" ]]; then
  print -u2 "error: scripts/codex-sync-status.sh must be run from inside a Git repository."
  exit 1
fi

cd "$repo_root"

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

