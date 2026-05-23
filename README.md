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
project-handovers/<project-name>/LAST-HANDOVER.md
```

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

4. Publish a latest handover after meaningful Codex work:

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

More loader variants are in [docs/chatgpt-web-ui-loader.md](docs/chatgpt-web-ui-loader.md).

## Example Codex Prompt

```text
At the end of meaningful tasks, update my private handover repo:

- codex-runs/LAST-CODEX-RUN.md
- project-handovers/<project-name>/LAST-HANDOVER.md

Stage only those expected files, commit them, and push the handover repo.
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

## Safety Notes

The real handover repo should normally be private because it may contain local paths, branch names, filenames, implementation notes, and risk summaries.

This public repository should not be your live handover repo. Treat it as a template and explanation package.

Do not put secrets, API keys, tokens, private keys, passwords, raw client data, legal records, medical records, or private chat logs into handovers.

The bridge works because Codex writes Markdown and GitHub stores it. ChatGPT Web UI reads it through your connected GitHub repo when asked.

## Promoting Improvements From A Private Handover Repo

Think of the private handover repo as the working lab and this public repo as the cleaned template.

Improvements discovered while using a private repo such as `~/repos/codex-sync` may be ported here only when they are generic, safe, reusable, and not private. Good candidates include script bug fixes, template improvements, clearer loader prompts, safer example wording, and troubleshooting lessons.

Do not copy private handovers, real local paths, names, emails, client details, secrets, raw Codex logs, or project-specific `AGENTS.md` files into this public repo.

Before publishing, run a sanitisation review and prefer reimplementing the idea cleanly instead of copying private files verbatim. See [docs/private-to-public-promotion.md](docs/private-to-public-promotion.md) and [scripts/promote-public-candidate.sh](scripts/promote-public-candidate.sh).

Some people may turn this into a personal Codex rule for their private workflow, but it is optional. This template documents the pattern; it does not require every user to maintain a public upstream repo.

## Not Official Tooling

This project is not official OpenAI tooling. It is a practical workflow pattern using local files, Git, GitHub, and the ChatGPT GitHub connector.

It does not bypass context limits, sync hidden model memory, or replicate a full conversation. It creates a reliable, Git-backed, human-readable continuation point.
