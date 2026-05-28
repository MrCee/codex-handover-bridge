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

## Loader Resolution

ChatGPT Web UI and helper commands should prefer the most specific handover:

1. named project: `codex-runs/by-project/<source-project>/LAST.md`
2. inferred current repo/project: matching `codex-runs/by-project/<source-project>/LAST.md`
3. no project context: `codex-runs/LAST-CODEX-RUN.md`

Status output should label global latest, requested project latest, and project handover mirror separately.

## Required Handover Fields

Each handover should record:

1. source project
2. last Codex task
3. files changed
4. validation performed
5. risks / unknowns
6. next safest action

Include branch, commit, and validation details where useful. Use summaries instead of raw sensitive material.

Each latest handover should include local path, GitHub repo, current branch, current commit, and host.

## Commit And Push

After successful handover updates:

1. Run `git status --short`.
2. Stage only the expected latest handover files, intended recent handover additions/deletions, and intentional workflow docs/scripts.
3. Avoid broad staging commands such as `git add -A`.
4. Commit if staged changes exist.
5. Push the private handover repo.

If commit or push fails, leave exact recovery commands and the current `git status --short` output in the handover and final response.

## Efficient Handover Batching

Keep an in-session concise running summary during routine work so state can be turned into a handover without reading large logs or transcripts.

Do not update, commit, and push a private handover repo after every tiny action. Routine handover pushes should happen at meaningful completed tasks or checkpoints, such as the end of a task group or roughly every 30 minutes of meaningful work, whichever comes first.

Push immediately when a run changes authentication, security, deployment, runtime behavior, or review targets; when source project files changed and work is stopping; when quota, time, or context is running low; when the working state would be difficult to recover; or when the user explicitly asks for ChatGPT Web UI reload state or a handover.

Skip pushes for read-only inspection, planning, diagnostics, diff previews, and intermediate edits that will continue in the same session.

If changes are being batched and not pushed yet, the final response should include a compact local checkpoint summary with changed files, validation already run, risks, and the next safest action.

During time-limited sessions, keep handovers concise. Avoid reading large session logs, raw transcripts, or other bulky runtime records unless needed for recovery.

## ChatGPT Web UI Checkpoint Publishing

ChatGPT Web UI may publish checkpoint handovers directly to a private handover repo when the user pastes a Codex summary or asks for a Web UI checkpoint. Codex should not spend local usage pushing the handover repo when ChatGPT Web UI can safely publish the checkpoint from a pasted summary.

Suggested private files for Web UI checkpoints:

```text
webui-checkpoints/LATEST.md
webui-checkpoints/recent/YYYY.MM.DD-HHMMSS.md
```

Keep only the newest 10 Markdown files in `webui-checkpoints/recent/`.

Web UI checkpoint files must be private, concise, and sanitized. ChatGPT Web UI must not invent local command output, validation results, branch state, commit IDs, or terminal output it has not been given. It must not publish secrets, passwords, tokens, private keys, raw logs, credentials, or other sensitive material.

## Public Promotion Review

Always assess whether a private workflow improvement has a public-safe reusable equivalent. When a private handover-repo update contains a significant reusable improvement, assess whether a sanitized public version belongs in a public template repo.

Public-safe candidates include:

- reusable handover contract wording
- AGENTS rule templates
- safer README wording
- generic loader instructions
- sanitisation checklists
- efficient handover batching wording
- generic checkpoint cadence rules
- public-safe Web UI publishing patterns
- generic AGENTS examples
- helper scripts with placeholders
- troubleshooting notes without private facts

Do not promote:

- private handover files
- raw Codex logs
- private project paths
- machine-specific paths
- machine names
- hostnames
- network storage paths
- client names
- emails/domains
- credentials
- secrets/tokens/passwords
- private key material
- medical/legal/client details
- project-specific AGENTS.md content
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
