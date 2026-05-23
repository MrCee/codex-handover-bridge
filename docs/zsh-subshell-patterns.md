# zsh Subshell Patterns

Strict mode is useful for fail-fast scripts and repair commands:

```zsh
set -euo pipefail
```

But setting strict mode directly in an interactive parent shell can affect later commands the user runs. A command that expects an unset variable, a non-zero probe, or a pipeline with partial failure can behave differently after strict mode is enabled.

Use a subshell for pasteable multi-command blocks:

```zsh
(
  set -euo pipefail
  cd "$HOME/repos/codex-sync"
  git status --short
)
```

The parentheses start a child shell. Strict mode applies inside that child shell and disappears when the block exits.

Avoid this in a user's interactive shell:

```zsh
set -euo pipefail
cd "$HOME/repos/codex-sync"
git status --short
```

That changes the user's current shell state.

This pattern is especially useful for Codex-generated repair, setup, and configuration commands because it makes the command block fail fast without leaving the user's shell in a surprising mode.

## Practical Rules

- Use subshells for pasteable multi-command shell blocks.
- Keep `set -euo pipefail` inside the subshell.
- Use exact paths for sensitive operations.
- Stage explicit files instead of broad patterns.
- Leave the user's parent shell state unchanged.

