# Codex Sync Handover Contract

This is a reusable contract for a private handover repository that bridges local Codex runs into ChatGPT Web UI.

The private handover repo is the working lab. A public template repo is the cleaned reusable version. Public promotion is optional and only for safe, generic improvements.

## Required Files

Every meaningful Codex run should update these files in the private handover repo:

```text
codex-runs/LAST-CODEX-RUN.md
codex-runs/by-project/<source-project>/LAST.md
project-handovers/<source-project>/LAST-HANDOVER.md
project-handovers/<source-project>/recent/<timestamp>.md
```

Keep only a small rolling buffer in each project `recent/` directory, such as the newest 10 Markdown files. `LAST-CODEX-RUN.md` remains the fast default loader file for ChatGPT Web UI; the by-project latest file preserves the current handover for each project.

## Required Handover Fields

Each handover should record:

1. source project
2. last Codex task
3. files changed
4. validation performed
5. risks / unknowns
6. next safest action

Include branch, commit, and validation details where useful. Use summaries instead of raw sensitive material.

## Commit And Push

After successful handover updates:

1. Run `git status --short`.
2. Stage only the expected latest handover files, intended recent handover additions/deletions, and intentional workflow docs/scripts.
3. Avoid broad staging commands such as `git add -A`.
4. Commit if staged changes exist.
5. Push the private handover repo.

If commit or push fails, leave exact recovery commands and the current `git status --short` output in the handover and final response.

## Public Promotion Review

When a private handover-repo update contains a significant reusable improvement, assess whether a sanitized public version belongs in a public template repo.

Public-safe candidates include:

- reusable handover contract wording
- AGENTS rule templates
- safer README wording
- generic loader instructions
- sanitisation checklists
- helper scripts with placeholders
- troubleshooting notes without private facts

Do not promote:

- private handover files
- raw Codex logs
- machine-specific paths
- network storage paths
- client names
- emails/domains
- secrets/tokens/passwords
- private key material
- medical/legal/client details
- private project implementation details

Never copy private handovers directly into the public repo. Recreate the useful idea with placeholder project names, placeholder paths, and example-only data.

## Multi-Machine Sync

If you run Codex on multiple trusted machines, keep the private handover repo and global Codex rules synchronized from a single source of truth.

Use an allowlisted, pull-only workflow:

1. Commit and push the source repo first.
2. Run a sync script against explicit hostname-selected SSH targets.
3. On each target, run `git pull --ff-only`.
4. Verify the global `AGENTS.md` contract is present.
5. Stop on dirty working trees, missing repos, divergent history, or SSH failures.

Never copy Codex auth files, sessions, logs, shell snapshots, `.env` files, keys, tokens, or private runtime state between machines.

See [../scripts/sync-codex-environments.example.sh](../scripts/sync-codex-environments.example.sh) for a generic example.

The companion fleet map uses this format:

```text
name|hostname|ssh_target|dotfiles_path|handover_repo_path|codex_home_path
```

The current machine is selected by comparing `hostname -s` with the `hostname` field. The matching row runs locally; all other rows are reached over SSH. Keep real machine names and paths in your private repo only.
