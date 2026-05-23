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

