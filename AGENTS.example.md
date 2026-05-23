# Example Global Codex Rules

Copy the parts you want into your local `~/.codex/AGENTS.md`. Keep real private paths in your local file, not in public template repos.

## Shell Safety

- Use subshells for pasteable multi-command blocks:
  - `( set -euo pipefail; ... )`
- Never set `set -euo pipefail` directly in the user's interactive parent shell.
- Do not set strict mode in the parent interactive shell.
- Do not leave the user's shell state changed.

## Handover Rule

At the end of every meaningful Codex task, write or update the latest handover files in your private handover repo:

- `codex-runs/LAST-CODEX-RUN.md`
- `project-handovers/<project-name>/LAST-HANDOVER.md`

Every handover should include:

- date/time
- source project
- local path
- GitHub repo, if known
- current branch
- current commit
- task requested
- files inspected
- files changed
- commands run
- validation performed
- validation result
- risks / unknowns
- next safest action for ChatGPT Web UI

## Sensitive Data

Do not store secrets, passwords, API keys, tokens, private keys, raw client evidence, raw legal evidence, raw medical evidence, or private chat logs in the handover repo.

Use summaries and filenames instead of sensitive raw material.

Do not publish private handovers to public template repos.

## Git Rules For The Private Handover Repo

- Always run `git status --short` before staging.
- Stage only known handover files.
- Never use `git add -A` for handover publishing.
- Commit if there are staged changes.
- Push the private handover repo after committing.
- Do not create timestamped archives unless explicitly requested.

Example commit message:

```text
docs(sync): update latest handover
```

## Git Rules For Source Project Repos

- Do not push source project repos unless the user explicitly asks.
- Commit source project repos only after validation, or when the user explicitly asks for a checkpoint.
- Never discard, reset, rebase, clean, or force-push without explicit permission.
- Always inspect `git status --short` before editing.

## If Using `danger-full-access`

- Use exact repo paths.
- Use explicit staging only.
- Prefer known handover filenames over broad patterns.
- Validate before committing.
- Do not use vague prompts with unknown repositories.
