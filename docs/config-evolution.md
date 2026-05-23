# Config Evolution

This workflow can start conservatively and become more automated only where the user knowingly accepts the risk.

## 1. Normal Codex Prompting

The safest starting point is normal Codex prompting. Codex asks before higher-risk actions, and the user approves or rejects them.

This is slower, but it keeps decision points visible.

## 2. Global AGENTS Rules

Next, add global `~/.codex/AGENTS.md` rules for repeatable workflow expectations:

- writing latest handovers
- using subshells
- avoiding `git add -A`
- staging only expected files
- publishing to a private handover repo

These rules improve consistency without expanding filesystem access by themselves.

## 3. No Prompts With Workspace Write

A tempting next step is:

```toml
approval_policy = "never"
sandbox_mode = "workspace-write"
```

This can reduce repeated approval prompts, but it also means Codex cannot ask for useful sandbox escalation when it hits a boundary.

## 4. Sandbox Metadata Failures

With prompts suppressed, direct writes to a secondary repo's Git metadata may fail.

Common symptoms include:

```text
Operation not permitted
```

or inability to create:

```text
.git/index.lock
```

Codex may be able to edit Markdown files but fail when staging or committing them.

## 5. Temporary-Clone Publishing

A safe fallback is temporary-clone publishing:

1. Clone the private handover repo into a temporary directory.
2. Copy only sanitized latest handover Markdown into the temp clone.
3. Stage only expected files.
4. Commit and push.
5. Remove the temporary clone.

This avoids broad filesystem access, but it adds complexity and can leave the normal local checkout stale until it pulls.

## 6. Frictionless Direct Publishing

Some users eventually choose:

```toml
approval_policy = "never"
sandbox_mode = "danger-full-access"
```

This allows frictionless direct publishing to secondary repos because Codex can write Git metadata outside the active source repo without asking.

## 7. Not The Safe Public Default

This is not the safe public default.

`danger-full-access` with `approval_policy = "never"` is an expert/frictionless mode for trusted machines and trusted repos. It should be paired with exact repo paths, explicit file staging, strong `.gitignore` rules, Git backups, and clear validation.

For public guidance, prefer workspace-write with explicit writable roots:

```toml
approval_policy = { granular = { sandbox_approval = true, rules = false, mcp_elicitations = false, request_permissions = false, skill_approval = false } }
sandbox_mode = "workspace-write"

[sandbox_workspace_write]
writable_roots = [
  "~/repos/codex-sync"
]
network_access = true
```

Depending on Codex behavior and your config parser, `~` may need to be expanded to an absolute path. Verify that the writable root is actually honored before relying on direct handover publishing.

