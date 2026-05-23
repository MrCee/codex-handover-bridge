# Troubleshooting

## `Operation not permitted` Writing `.git/index.lock`

This usually means the sandbox allows file edits but blocks Git metadata writes.

Options:

- add the handover repo to explicit writable roots
- allow sandbox escalation prompts
- use a temporary clone fallback
- use `danger-full-access` only if you knowingly accept the risk

## Workspace Write Limitations

`workspace-write` is safer than broad filesystem access, but Codex may only be able to write inside the active workspace and configured writable roots.

If your handover repo is outside those roots, direct publish commands may fail.

## Temp-Clone Fallback

Use a temporary clone when direct writes to the local handover checkout are blocked:

```sh
tmpdir="$(mktemp -d)"
git clone <private-handover-repo-url> "$tmpdir"
```

Copy only the latest handover files, commit, push, and remove the temp directory.

After publishing from a temp clone, your normal local checkout may be stale. Run:

```sh
git pull --ff-only
```

inside the normal handover repo before editing it again.

## GitHub Repo Not Visible To ChatGPT Yet

Check that the GitHub connector is enabled and has access to the private handover repo.

If you recently created the repo, disconnecting and reconnecting the connector, or refreshing its repository permissions, may be necessary.

## Private Repo Connector Permissions

Private repos require explicit connector permission. If ChatGPT cannot read the handover file, confirm:

- the repo exists on GitHub
- the file was pushed
- the connected GitHub account can access the repo
- the connector is allowed to access private repositories

## Accidental `AGENTS.md` Commit

If your `AGENTS.md` contains private paths or personal workflow details, avoid committing it to public repos.

For local-only instructions, use:

```text
AGENTS.local.md
```

Then add it to `.gitignore`:

```gitignore
AGENTS.local.md
```

If private content was pushed publicly, deleting the file in a later commit may not be enough because history can still expose it.

History rewrite or repo recreation may be appropriate when secrets or sensitive private content were published.

## Direct Publishing Under `danger-full-access`

Direct publishing can work smoothly when Codex has full filesystem access and approval prompts are disabled.

That setup is convenient but risky because Codex can write outside the active repo. Use it only on trusted machines and with good backups.

