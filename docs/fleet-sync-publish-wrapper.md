# Fleet Sync Publish Wrapper

For private handover repos that also coordinate a small machine baseline, use a
wrapper that separates generated files from human-edited files.

The safe sequence is:

1. Refuse to start if files outside an approved generated allowlist are dirty.
2. Run local fleet status and safe fast-forward pulls.
3. Commit only generated status and handover files.
4. Push the private handover repo.
5. Run pull-only fan-out after the private repo is clean.
6. Mark offline SSH targets pending instead of treating them as a local publish failure.

Good generated-file candidates:

```text
fleet/status/LATEST.md
fleet/status/history/*.md
codex-runs/LAST-CODEX-RUN.md
codex-runs/by-project/<project-name>/LAST.md
project-handovers/<project-name>/LAST-HANDOVER.md
project-handovers/<project-name>/recent/*.md
```

Do not allow the wrapper to commit arbitrary source files, dotfiles, config
changes, logs, secrets, or project repo changes.

Recommended private index files:

```text
fleet/index/LATEST.md
fleet/index/HOSTS.md
fleet/index/REPOS.md
fleet/index/RULES.md
fleet/index/DIAGNOSTICS.md
```

Keep the default baseline small. A practical baseline is the private handover
repo plus a dotfiles repo. Project repos should not become default fleet sync
targets unless explicitly added.

See [../scripts/fleet-sync-and-publish.example.sh](../scripts/fleet-sync-and-publish.example.sh)
for a generic wrapper template.
