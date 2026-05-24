# ChatGPT Web UI Loader

`;codexload` is a personal command convention. It is not built into ChatGPT.

You define it in Custom Instructions so ChatGPT Web UI knows what to read from your connected GitHub handover repo.

## Short Loader

```text
When I type `;codexload`, read `codex-runs/LAST-CODEX-RUN.md` from my connected private GitHub handover repo and summarise the current continuation point.
```

## Verbose Loader

```text
When I type `;codexload`, treat it as a command to continue from my latest Codex handover.

If a project is named or inferable from the current repo, read its project-specific latest file first:

<owner>/<private-handover-repo>
codex-runs/by-project/<project-name>/LAST.md

Otherwise read the global fallback:

<owner>/<private-handover-repo>
codex-runs/LAST-CODEX-RUN.md

Then follow any referenced project handover path and summarise:
1. source project,
2. last Codex task,
3. files changed,
4. validation,
5. risks,
6. next safest action.

Do not assume local filesystem access. Use connected GitHub access where available.
```

## Project-Specific Loader

```text
When I type `;codexload my-project`, read:

<owner>/<private-handover-repo>
project-handovers/my-project/LAST-HANDOVER.md
codex-runs/by-project/my-project/LAST.md

Summarise the last task, files changed, validation result, risks, and the next safest action.
```

## Troubleshooting-Focused Loader

```text
When I type `;codexload troubleshoot`, read `codex-runs/LAST-CODEX-RUN.md` from my connected private GitHub handover repo. Focus on failed commands, validation gaps, risks, and the next safest recovery step.
```

## Useful Response Shape

Ask ChatGPT to keep the loaded summary short:

```text
After loading, respond with:
- source project
- last task
- files changed
- validation result
- risks
- next safest action
```
