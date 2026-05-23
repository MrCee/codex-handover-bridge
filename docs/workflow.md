# Workflow

Codex Handover Bridge is a simple pattern:

1. Codex CLI does local work.
2. Codex writes a Markdown handover.
3. Codex commits and pushes the private handover repo.
4. ChatGPT Web UI reads the latest handover through the GitHub connector.
5. The user continues by typing `;codexload`.

## Roles

`codex-handover-bridge` is the public template and documentation repo.

`codex-sync` is an example name for your private operational handover repo. You can call yours anything.

Your source project is the repo where Codex actually changes code.

## Handover Files

Use stable latest files:

```text
codex-runs/LAST-CODEX-RUN.md
project-handovers/<project-name>/LAST-HANDOVER.md
```

Stable filenames make the loader prompt short and reliable. They also avoid publishing long histories by default.

## Rolling Recent Handovers

Some private handover repos also keep a small project-specific recovery buffer:

```text
project-handovers/<project-name>/recent/YYYY.MM.DD-HHMMSS.md
```

This is useful when several Codex runs happen before you return to ChatGPT Web UI. The latest files still carry the normal continuation point, while `recent/` gives you a short fallback trail if an intermediate handover matters.

Keep the buffer intentionally small. A practical default is the newest 10 Markdown files per project:

```text
project-handovers/<project-name>/recent/
```

Delete older recent handovers automatically. Do not create global timestamped archives unless you deliberately want an archive mode.

For `;codexload`, read `codex-runs/LAST-CODEX-RUN.md` first, then follow the referenced project `LAST-HANDOVER.md`. Do not load every recent file by default. Recent handovers are a recovery tool, not the primary context source.

Do not store secrets, raw logs, private evidence, legal or medical material, client data, tokens, passwords, API keys, or private keys in recent handovers.

## End-To-End Flow

After a meaningful Codex task, Codex records:

- what was requested
- which files were inspected
- which files changed
- which commands ran
- what validation passed or failed
- what risks remain
- the next safest action for ChatGPT Web UI

Then Codex stages only the expected handover files, commits, and pushes the private handover repo.

In ChatGPT Web UI, the user types:

```text
;codexload
```

The custom instruction tells ChatGPT to read `codex-runs/LAST-CODEX-RUN.md`, follow any project handover path, and summarise the continuation point.

## What It Does Not Do

This workflow does not sync full chat history, hidden model state, local filesystem access, terminal scrollback, or private Codex internals.

It creates a small, explicit, human-readable checkpoint.
