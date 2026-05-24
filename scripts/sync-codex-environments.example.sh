#!/usr/bin/env zsh
set -euo pipefail

# Generic example only. Copy into your private handover repo before use.
# Keep real hostnames, usernames, private paths, and SSH ports out of public repos.

script_dir="${0:A:h}"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$repo_root" ]]; then
  echo "error: run this script from inside your private handover repo." >&2
  exit 1
fi

fleet_map="${CODEX_ENV_SYNC_CONFIG:-$repo_root/config/codex-environments}"

if [[ ! -f "$fleet_map" ]]; then
  echo "error: missing fleet map: $fleet_map" >&2
  echo "create it from config/codex-environments.example." >&2
  exit 2
fi

remote_script=$(cat <<'REMOTE'
set -euo pipefail
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/opt/homebrew/bin:/usr/local/bin:$PATH"
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

current_hostname="$(hostname -s 2>/dev/null || hostname)"
matches=0

rows=()
while IFS= read -r row; do
  [[ -z "${row//[[:space:]]/}" ]] && continue
  [[ "$row" == \#* ]] && continue
  rows+=("$row")
done < "$fleet_map"

for row in "${rows[@]}"; do
  IFS='|' read -r name target_hostname ssh_target dotfiles_path handover_path codex_home_path <<< "$row"
  [[ "$target_hostname" == "$current_hostname" ]] && (( matches += 1 ))
done

if (( matches != 1 )); then
  echo "error: current hostname '$current_hostname' must match exactly one target." >&2
  exit 2
fi

for row in "${rows[@]}"; do
  IFS='|' read -r name target_hostname ssh_target dotfiles_path handover_path codex_home_path <<< "$row"
  mode="$ssh_target"
  [[ "$target_hostname" == "$current_hostname" ]] && mode="local"
  echo "==> $name ($target_hostname via $mode)"

  if [[ "$mode" == "local" ]]; then
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
