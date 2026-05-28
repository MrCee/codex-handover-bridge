# Agent Workflow Spec

This document is the public-safe canonical workflow spec for a Codex CLI to ChatGPT Web UI handover bridge.

It is intended to be byte-identical between a private operational handover repo and a public sanitized template repo. Keep private operational details in private-only docs. Keep this spec generic.

## Purpose

The handover bridge creates a Git-backed continuation point between local Codex CLI work and ChatGPT Web UI.

Codex CLI can inspect and edit local files, run validation, summarize what changed, and write Markdown handovers. ChatGPT Web UI can read those handovers through a connected GitHub repo when the user asks. The workflow does not sync hidden model state, full chat history, local shell state, or private runtime files.

## Roles

- Codex CLI does local filesystem, repository, implementation, and validation work.
- ChatGPT Web UI reads handovers through GitHub when the user asks, and may publish a handover when the user provides enough information.
- GitHub stores Markdown handover files in a private handover repo.
- A public template repo may store sanitized reusable workflow docs, examples, templates, and scripts.

## Handover Files

The private handover repo should use stable latest files:

```text
codex-runs/LAST-CODEX-RUN.md
codex-runs/by-project/<project-name>/LAST.md
project-handovers/<project-name>/LAST-HANDOVER.md
```

It may also keep a small rolling project recovery buffer:

```text
project-handovers/<project-name>/recent/YYYY.MM.DD-HHMMSS.md
```

Keep only a small number of recent recovery files, such as the newest 10 Markdown files per project.

## Loader Resolution

When loading handover state, prefer the most specific file:

1. If the user names a project, load `codex-runs/by-project/<project-name>/LAST.md`.
2. If the current project can be inferred, load the matching `codex-runs/by-project/<project-name>/LAST.md`.
3. If no project is named or inferable, load `codex-runs/LAST-CODEX-RUN.md` as the global latest fallback.

Status output should keep global latest, requested project latest, and project handover mirror records clearly labelled.

## Efficient Usage Rules

Routine work should minimize local agent usage while preserving reliable recovery.

- Avoid broad audits during routine work.
- Avoid reading large session logs unless needed for recovery.
- Do not update, commit, and push handovers after every tiny action.
- Keep an in-session compact checkpoint summary during routine work.
- Batch handover updates by completed task group or roughly every 30 minutes of meaningful work, whichever comes first.
- Push or publish immediately when auth, security, runtime, deploy, or review target state changes.
- Push or publish immediately when the user explicitly asks for a handover, reload state, or checkpoint.
- Push or publish immediately when stopping due to low quota, time, or context limits.
- Push or publish immediately when difficult recovery state must be preserved.

If changes are being batched and not yet pushed, the agent's final response should include a compact local checkpoint summary: changed files, validation already run, risks or unknowns, and the next safest action.

## ChatGPT Web UI Publishing

ChatGPT Web UI may publish a handover when the user pastes a Codex summary or asks for a checkpoint.

Web UI publishing is useful when it saves local Codex usage and the pasted summary contains enough state to preserve the work.

ChatGPT Web UI must:

- avoid inventing local command output, validation results, branch state, commit IDs, or terminal output;
- mark unknowns clearly when information was not provided;
- keep checkpoint files concise and sanitized;
- avoid publishing secrets, credentials, tokens, passwords, private keys, raw logs, sensitive evidence, or private runtime data.

Suggested Web UI checkpoint files:

```text
webui-checkpoints/LATEST.md
webui-checkpoints/recent/YYYY.MM.DD-HHMMSS.md
```

Keep only a small number of recent Web UI checkpoint files, such as the newest 10 Markdown files.

## Public Promotion

The private handover repo is the working lab. The public template repo receives only sanitized reusable improvements.

Generic agent logic can be shared between private and public repos when it contains no private facts. A canonical shared spec may be kept identical in both repos to reduce drift.

Private facts must not be promoted. Recreate public-safe improvements generically instead of copying private operational content.

## Source Project Safety

Source project repos are separate from the private handover repo.

- Do not commit or push source project repos unless the user explicitly asks.
- Inspect `git status --short --branch` before edits, commits, or pushes.
- Avoid broad staging commands such as `git add -A` unless explicitly requested.
- Stage only intended files.
- Do not discard, reset, clean, rebase, or force-push user work without explicit permission.

## Sanitisation Checklist

Before copying a workflow improvement into a public template repo, remove or replace:

- private paths;
- hostnames;
- machine names;
- client names;
- emails and domains;
- credentials;
- secrets, tokens, and passwords;
- private keys;
- raw handovers and raw logs;
- medical, legal, client, or sensitive evidence;
- project-specific instructions;
- private network details;
- private implementation details that are not needed to explain the generic workflow.

## README Relationship

README files should point to this shared canonical spec for the agent workflow.

The shared spec should stay identical between private and public repos. Private README files may contain private operational notes. Public README files should remain generic and template-focused.
