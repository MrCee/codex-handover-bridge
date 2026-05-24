#!/usr/bin/env zsh
set -euo pipefail

# Generic example only. Copy into your private handover repo before use.
# Keep real hostnames, usernames, private paths, and SSH ports out of public repos.

targets=(
  "current-machine|local|/path/to/dotfiles|/path/to/private-handover-repo|/path/to/codex-home"
  "second-machine|ssh-alias|/path/to/dotfiles|/path/to/private-handover-repo|/path/to/codex-home"
  "nas-or-server|ssh-alias:2222|/path/to/dotfiles|/path/to/private-handover-repo|/path/to/codex-home"
)

remote_script=$(cat <<'REMOTE'
set -euo pipefail
dotfiles_path="$1"
handover_path="$2"
codex_home_path="$3"

sync_repo() {
  local repo_path="$1"
  local repo_label="$2"

  cd "$repo_path"
  repo_status="$(git status --short)"
  if [[ -n "$repo_status" ]]; then
    echo "error: $repo_label has uncommitted changes at $repo_path" >&2
    echo "$repo_status" >&2
    exit 11
  fi

  git fetch origin
  branch="$(git branch --show-current)"
  git pull --ff-only origin "$branch"
}

sync_repo "$dotfiles_path" "dotfiles"
sync_repo "$handover_path" "private handover repo"

grep -n "Codex Sync + Public Promotion Contract" "$codex_home_path/AGENTS.md"
REMOTE
)

for row in "${targets[@]}"; do
  IFS='|' read -r name ssh_target dotfiles_path handover_path codex_home_path <<< "$row"
  echo "==> $name"

  if [[ "$ssh_target" == "local" ]]; then
    zsh -c "$remote_script" -- "$dotfiles_path" "$handover_path" "$codex_home_path"
  else
    ssh_host="$ssh_target"
    ssh_port_args=()
    if [[ "$ssh_target" == *:* ]]; then
      ssh_host="${ssh_target%%:*}"
      ssh_port="${ssh_target##*:}"
      ssh_port_args=(-p "$ssh_port")
    fi
    ssh "${ssh_port_args[@]}" "$ssh_host" zsh -s -- "$dotfiles_path" "$handover_path" "$codex_home_path" <<< "$remote_script"
  fi
done
