# Dangerous Config Explained

Some users want Codex to update a secondary handover repo without repeated approval prompts. That can be convenient, but it changes the risk profile.

## Why Someone Might Choose It

This workflow can require Codex to write outside the active source repo, especially when the handover repo is a separate checkout.

Some sandbox configurations also block direct writes to Git metadata such as `.git/index.lock`. In those cases, Codex may be able to edit files but fail when staging or committing.

The frictionless configuration avoids repeated prompts and allows direct Git writes to secondary repos such as a handover repo.

## The Risk

`danger-full-access` means Codex can write outside the active repo. If a prompt is wrong, a tool has a bug, or the model follows bad instructions, it can modify files you did not intend to expose.

Only use it on trusted machines, trusted repos, and with good backups.

The safest public default should not be `danger-full-access`.

> Warning: `danger-full-access` can write outside the active repo.

> Warning: `approval_policy = "never"` means Codex will not stop and ask before running commands.

> Warning: this can damage files if prompts are wrong, ambiguous, or applied to the wrong repository.

Use only on trusted machines, with Git backups, and with repo-specific safeguards.

Never combine this mode with vague prompts or unknown repositories.

Prefer exact repo paths, known filenames, explicit staging, and clear validation steps.

## Tier 1: Safer Default

Use workspace write access and explicitly allow the private handover repo as a writable root.

```toml
approval_policy = { granular = { sandbox_approval = true, rules = false, mcp_elicitations = false, request_permissions = false, skill_approval = false } }
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
writable_roots = [
  "~/repos/codex-sync"
]
network_access = true
```

This is the recommended public starting point.

Depending on Codex behavior and your config parser, `~` may need to be expanded to an absolute path. Verify that the writable root is actually honored before relying on direct handover publishing.

## Tier 2: Frictionless But Dangerous

```toml
approval_policy = "never"
sandbox_mode = "danger-full-access"
```

This was used to avoid repeated Codex approval prompts and to allow direct Git writes to a secondary handover repo.

It is documented for people who knowingly accept the risk. It is not the safest default.

## Tier 3: Temp-Clone Fallback

If direct Git metadata writes are blocked, use a temporary clone of the handover repo:

1. Clone the private handover repo into a temporary directory.
2. Copy in the latest Markdown handovers.
3. Stage only the expected handover files.
4. Commit and push from the temporary clone.
5. Remove the temporary clone.

This avoids broad filesystem access but adds operational complexity. Your main local handover checkout may become stale until you pull.

## Trade-Off Summary

Safe sandbox plus no prompts may require a temp-clone fallback.

Safe sandbox plus direct Git writes may require approval prompts.

No prompts plus direct Git writes requires accepting `danger-full-access` risk.
