# Example Global Codex Rules

Copy the parts you want into your local `~/.codex/AGENTS.md`. Keep real private paths in your local file, not in public template repos.

## Shell Safety

- Use subshells for pasteable multi-command blocks:
  - `( set -euo pipefail; ... )`
- Never set `set -euo pipefail` directly in the user's interactive parent shell.
- Do not set strict mode in the parent interactive shell.
- Do not leave the user's shell state changed.

## Launch Mode For Trusted Repos

- For your own trusted personal or admin repos, you may choose to use Codex in low-friction YOLO/bypass mode by default.
- This is only appropriate when you knowingly accept the risk because the work is Git-backed, recoverable, and repeatedly validated.
- Preferred launch command from the normal shell:
  - `codex --dangerously-bypass-approvals-and-sandbox`
- Do not launch a nested interactive Codex session from inside an already-running Codex session.
- If a session was started without the intended bypass mode and prompts become noisy, stop cleanly, return to the normal shell prompt, and restart with the intended command.
- For your trusted repos, avoid asking for routine file edits, git add, git commit, git push, validation commands, or handover updates if your local rules already permit them.
- Still keep changes scoped to the requested repo/files.
- Still avoid `git add -A` unless explicitly requested.
- Still do not force-push unless explicitly requested.
- For downloaded, unfamiliar, third-party, client, or risky repos, do not assume YOLO/bypass mode is appropriate.

## Handover Rule

At the end of every meaningful Codex task, write or update the latest handover files in your private handover repo:

- `codex-runs/LAST-CODEX-RUN.md`
- `project-handovers/<project-name>/LAST-HANDOVER.md`

Optionally, also write a timestamped project recovery copy:

- `project-handovers/<project-name>/recent/YYYY.MM.DD-HHMMSS.md`

If using project recent handovers, keep only the newest 10 `.md` files in each project `recent/` directory. `LAST-CODEX-RUN.md` remains the fast loader for `;codexload`; recent handovers are only a recovery buffer if several Codex runs happen before returning to ChatGPT Web UI.

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
- commands / validation summary
- validation performed
- validation result
- risks / unknowns
- next safest action for ChatGPT Web UI

## Handover Batching

Do not update, commit, and push the private handover repo after every tiny action. Batch routine handover updates at meaningful completed tasks or checkpoints, such as the end of a task group or roughly every 30 minutes of meaningful work.

Push a handover immediately when the run changes authentication, security, deployment, runtime behavior, or review targets; when quota, time, or context is running low; when the working state would be difficult to recover; or when the user explicitly asks for ChatGPT Web UI reload state.

Skip handover pushes for read-only inspection, planning, diagnostics, diff previews, and intermediate edits that will continue in the same session.

During time-limited sessions, keep handovers concise. Avoid reading large session logs, raw transcripts, or other bulky runtime records unless they are needed for recovery.

## Handover Command Logging Safety

Handovers are not terminal transcripts. Prefer short, sanitised command summaries that preserve reproducible context without copying sensitive terminal content.

- Full commands should only be listed when they are safe, generic, and useful to rerun.
- Never include secrets, tokens, API keys, passwords, private keys, cookies, auth headers, signed URLs, `.env` contents, raw private data, raw logs, or full heredocs.
- Use placeholders such as `<redacted>` when a value is important to understand but unsafe to store.
- If a command is sensitive, summarise it instead, for example: `Ran a redacted authenticated API request`.
- Add a `Redactions / Omissions` section to handovers when useful, especially if validation or recovery context depends on omitted sensitive details.

## Sensitive Data

Do not store secrets, passwords, API keys, tokens, private keys, raw client evidence, raw legal evidence, raw medical evidence, or private chat logs in the handover repo.

Use summaries and filenames instead of sensitive raw material.

Do not publish private handovers to public template repos.

## Optional Private-To-Public Promotion Review

Treat your private handover repo as the working lab and any public template repo as the cleaned reusable version.

When a private handover-repo update contains a significant reusable improvement, assess whether a sanitized public version belongs in your public template repo.

Good public candidates include:

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

If promoting, recreate the idea generically. Never copy private handovers directly into public files.

## Git Rules For The Private Handover Repo

- Always run `git status --short` before staging.
- Stage only known handover files and intended recent handover additions/deletions.
- Never use `git add -A` for handover publishing.
- Commit if there are staged changes.
- Push the private handover repo after committing.
- Do not create global timestamped archives unless explicitly requested.

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
