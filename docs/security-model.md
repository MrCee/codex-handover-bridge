# Security Model

The safest default is a private handover repo and explicit Markdown summaries.

## Keep The Live Handover Repo Private

Handover files can include:

- local paths
- branch names
- filenames
- task summaries
- validation output summaries
- risk notes
- next actions

Those are often not secrets, but they can still reveal private project context. Keep the operational handover repo private unless you are intentionally publishing sanitized examples.

## Do Not Store Secrets

Do not store:

- API keys
- tokens
- passwords
- private keys
- raw client evidence
- raw legal evidence
- raw medical evidence
- private chat logs
- unredacted `.env` content

Use summaries instead of raw sensitive material.

## Public Template Repo Versus Live Repo

This public repo is a template and explanation package. It should not be your live handover repo.

Your live repo should contain only the handover files you intentionally publish for ChatGPT Web UI to read.

## Local AGENTS Files

`AGENTS.md` can contain private paths and personal workflow rules. For public repos, prefer example files such as `AGENTS.example.md`.

If you keep local-only agent rules beside a repo, use a filename such as:

```text
AGENTS.local.md
```

and ignore it in `.gitignore`.

## Why Targeted Staging Matters

Use targeted staging:

```sh
git add codex-runs/LAST-CODEX-RUN.md project-handovers/<project-name>/LAST-HANDOVER.md
```

Avoid broad staging such as:

```sh
git add -A
```

Targeted staging reduces the chance of publishing secrets, local notes, raw logs, or unrelated files.
Keep this rule project-neutral by using placeholders such as `<project-name>` in reusable instructions instead of hard-coding one source project's handover path.

## Useful `.gitignore` Entries

```gitignore
.env
.env.*
secrets/
private/
*.log
AGENTS.local.md
local/
codex-runs/private/
project-handovers/private/
```
