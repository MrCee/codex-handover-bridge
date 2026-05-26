# Codex Handover Bridge

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Shell: zsh](https://img.shields.io/badge/shell-zsh-4EAA25.svg)](scripts/)
[![Status: template](https://img.shields.io/badge/status-template-blue.svg)](#)
[![Safety: Markdown only](https://img.shields.io/badge/safety-Markdown%20only-brightgreen.svg)](docs/security-model.md)

A small, Git-backed workflow for carrying local Codex CLI context back into ChatGPT Web UI without pretending to sync hidden chat state.

`codex-handover-bridge` is the public template and documentation project. Your real operational handover repository is usually a separate private repo, often named something like `codex-sync`.

## Why This Exists

Codex CLI works locally. ChatGPT Web UI does not automatically know what Codex just did in your terminal, what files changed, what validation ran, or what risks remain.

This bridge gives both tools a simple continuation point:

1. Codex writes a concise Markdown handover.
2. GitHub stores the latest handover in a private repo.
3. ChatGPT Web UI reads it through the GitHub connector when you ask.

The workflow is deliberately small, explicit, readable, and recoverable.

## What Problem It Solves

Without a handover, you often have to paste summaries manually between Codex CLI and ChatGPT Web UI. That is easy to forget and easy to get wrong.

With this workflow, Codex updates stable files such as:

```text
codex-runs/LAST-CODEX-RUN.md
codex-runs/by-project/<project-name>/LAST.md
project-handovers/<project-name>/LAST-HANDOVER.md
```

Optionally, a private handover repo can also keep a small rolling recovery buffer:

```text
project-handovers/<project-name>/recent/YYYY.MM.DD-HHMMSS.md
```

Keep this buffer small, such as the newest 10 handovers per project. `LAST-CODEX-RUN.md` remains the fast default loader for `;codexload`; `codex-runs/by-project/<project-name>/LAST.md` keeps each project's latest run addressable when another repo runs later. The recent folder is only for recovery if several Codex runs happen before you return to ChatGPT Web UI.

## Loader Selection

ChatGPT Web UI should resolve `;codexload` in this order:

1. If the user names a project, load `codex-runs/by-project/<project-name>/LAST.md`.
2. If the current repository path or project name is known, load the matching `codex-runs/by-project/<project-name>/LAST.md`.
3. Only when no project is named or inferable, load `codex-runs/LAST-CODEX-RUN.md` as the global latest fallback.

For status checks, use `scripts/codex-sync-status.sh <project-name>` and keep the `Global latest`, `Requested project latest`, and `Requested project handover mirror` sections separate.

Then ChatGPT Web UI can load those files on demand with a short convention such as:

```text
;codexload
```

This does not sync full chat history. It does not transfer private model state. It only syncs human-readable Markdown handovers that you choose to write and publish.

## Quick Start

1. Create a private handover repo:

```sh
scripts/init-handover-repo.sh ~/repos/codex-sync
```

2. Add handover rules to your local Codex instructions using [AGENTS.example.md](AGENTS.example.md).

3. Add a ChatGPT Web UI custom instruction using [custom-instructions.example.md](custom-instructions.example.md).

4. Run Codex normally in a repo that has the handover rules installed.

Once the `AGENTS.md` rules are installed and working, the normal workflow is automatic on the Codex side. Codex loads local `AGENTS.md` rules when it runs in a repo/session, completes the requested local work, then follows the standing handover rule at the end of each meaningful task.

You should not need to paste a handover prompt after every Codex task. Manual prompts and helper scripts are mainly for setup, testing, recovery, or repos that do not yet have the rules installed.

For a one-off test, you can publish a latest handover manually:

```sh
scripts/publish-latest-handover.sh ~/repos/codex-sync my-project ~/repos/my-project \
  --task "Implemented the requested change" \
  --validation "Ran tests successfully" \
  --next "Review the linked handover and continue from the listed next action"
```

5. In ChatGPT Web UI, type:

```text
;codexload
```

## How The Automation Flows

1. Codex CLI reads the local `AGENTS.md` rules for the current repo/session.
2. Codex completes the requested local work.
3. Codex writes or updates Markdown handover files in the private handover repo.
4. Codex commits and pushes only the expected handover files, if configured and permitted.
5. ChatGPT Web UI reads the latest handover through the GitHub connector when you type `;codexload`.

## What Is Automatic / What Is Not

Automatic after setup:

- Codex-side handover writing, if the `AGENTS.md` rules are installed.
- Git-backed handover file updates, if the private handover repo is configured and Codex is permitted to commit and push them.

Not automatic:

- ChatGPT secretly knowing terminal state.
- Full chat history sync.
- Hidden model memory sync.
- Unsafe pushing of source repos.
- Public promotion of private handovers.

## The Loader Instruction

You can add a Custom Instruction like this:

```text
When I type `;codexload`, read `codex-runs/LAST-CODEX-RUN.md` from my connected private GitHub handover repo, then follow any referenced project handover and summarise source project, last task, files changed, validation, risks, and next safest action.
```

## Set Up The `;codexload` Loader In ChatGPT Web UI

`;codexload` is not magic built into ChatGPT. It only works because you add it to ChatGPT Custom Instructions as a personal shortcut.

1. Open ChatGPT.
2. Go to Settings.
3. Open Personalization.
4. Open Custom Instructions.
5. Paste the contents of `custom-instructions.example.md`.
6. Replace `<owner>/<private-handover-repo>` with your private handover repo, for example `yourname/codex-sync`.
7. Save.
8. In any chat, type `;codexload`.

The command is just a convention you define for yourself. It is not an official ChatGPT command.

More loader variants are in [docs/chatgpt-web-ui-loader.md](docs/chatgpt-web-ui-loader.md). The loader is the ChatGPT Web UI side of the workflow; it does not replace the Codex-side `AGENTS.md` rule that writes the handover.

## Manual Fallback Prompt

This is not the normal daily workflow once `AGENTS.md` is configured. Use it for setup checks, one-off testing, recovery, or a repo/session where the standing handover rules are not installed.

```text
At the end of meaningful tasks, update my private handover repo:

- codex-runs/LAST-CODEX-RUN.md
- codex-runs/by-project/<project-name>/LAST.md
- project-handovers/<project-name>/LAST-HANDOVER.md

Stage only those expected files, commit them, and push the handover repo.
Do not stage unrelated project files or use `git add -A` unless explicitly requested.
Do not store secrets, tokens, private evidence, or raw logs.
Do not push the source project unless I explicitly ask.
```

## Repository Layout

```text
AGENTS.example.md                         Example local Codex instruction file
custom-instructions.example.md            Example ChatGPT Web UI loader instruction
config/                                   Safe and frictionless Codex config examples
docs/                                     Workflow, security, loader, and troubleshooting docs
scripts/                                  Small helper scripts for handover repos
templates/                                Markdown handover templates
```

Config and shell safety references:

- [docs/config-evolution.md](docs/config-evolution.md)
- [docs/dangerous-config-explained.md](docs/dangerous-config-explained.md)
- [docs/zsh-subshell-patterns.md](docs/zsh-subshell-patterns.md)
- [config/codex-config-safe.example.toml](config/codex-config-safe.example.toml)
- [config/codex-config-workspace-write.example.toml](config/codex-config-workspace-write.example.toml)
- [config/codex-config-frictionless-danger.example.toml](config/codex-config-frictionless-danger.example.toml)

For multi-machine setups, see [config/codex-environments.example](config/codex-environments.example), [scripts/sync-codex-environments.example.sh](scripts/sync-codex-environments.example.sh), and [docs/fleet-sync-publish-wrapper.md](docs/fleet-sync-publish-wrapper.md). Together they demonstrate a hostname-selected, allowlisted, pull-only SSH sync pattern and a generated-file publish wrapper for keeping private handover repos and Codex rules current across trusted machines without copying runtime secrets.

The fleet map format is:

```text
name|hostname|ssh_target|dotfiles_path|handover_repo_path|codex_home_path
```

The script compares `hostname -s` with the `hostname` field. The matching row runs locally; every other row is reached over SSH. This lets any configured machine initiate sync without recursively SSHing back into itself.

## Safety Notes

The real handover repo should normally be private because it may contain local paths, branch names, filenames, implementation notes, and risk summaries.

This public repository should not be your live handover repo. Treat it as a template and explanation package.

Do not put secrets, API keys, tokens, private keys, passwords, raw client data, legal records, medical records, or private chat logs into handovers.

Handovers are not terminal transcripts. Record useful reproducible context, validation results, and risks, but keep command lists short, safe, and sanitised. Full commands should only be listed when they are harmless and useful to rerun. Sensitive commands should be summarised instead, for example `Ran a redacted authenticated API request`.

Omit raw logs, heredocs, auth headers, signed URLs, `.env` contents, private evidence, legal or medical material, client material, secrets, and any other raw private data. Use placeholders such as `<redacted>` where a detail matters but the value must not be stored.

The bridge works because Codex writes Markdown and GitHub stores it. ChatGPT Web UI reads it through your connected GitHub repo when asked.

## Promoting Improvements From A Private Handover Repo

Think of the private handover repo as the working lab and this public repo as the cleaned template.

Improvements discovered while using a private repo such as `~/repos/codex-sync` may be ported here only when they are generic, safe, reusable, and not private. Good candidates include script bug fixes, template improvements, clearer loader prompts, safer example wording, and troubleshooting lessons.

Do not copy private handovers, real local paths, names, emails, client details, secrets, raw Codex logs, or project-specific `AGENTS.md` files into this public repo.

Before publishing, run a sanitisation review and prefer reimplementing the idea cleanly instead of copying private files verbatim. See [docs/private-to-public-promotion.md](docs/private-to-public-promotion.md) and [scripts/promote-public-candidate.sh](scripts/promote-public-candidate.sh).

Some people may turn this into a personal Codex rule for their private workflow, but it is optional. This template documents the pattern; it does not require every user to maintain a public upstream repo.

Significant private workflow improvements should trigger a sanitized public review. Public promotion is optional and only for safe, generic improvements such as reusable handover wording, AGENTS rule examples, loader instructions, sanitisation checklists, placeholder helper scripts, and troubleshooting notes without private facts.

Never copy private handovers directly into this public repo. Recreate the useful idea with generic project names, placeholder paths, and example-only data.

For a reusable contract template, see [docs/CODEX-SYNC-HANDOVER-CONTRACT.md](docs/CODEX-SYNC-HANDOVER-CONTRACT.md) and [templates/CODEX-HANDOVER-TEMPLATE.md](templates/CODEX-HANDOVER-TEMPLATE.md).

## Not Official Tooling

This project is not official OpenAI tooling. It is a practical workflow pattern using local files, Git, GitHub, and the ChatGPT GitHub connector.

It does not bypass context limits, sync hidden model memory, or replicate a full conversation. It creates a reliable, Git-backed, human-readable continuation point.
