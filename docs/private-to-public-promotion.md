# Private To Public Promotion

This project separates the live operational handover repo from the public reusable template.

`codex-sync` is an example name for a private live handover repo. It is where real Codex handovers, local workflow notes, and private operational details may exist.

`codex-handover-bridge` is the public reusable template and documentation project. It should contain only generic, safe, reusable material.

Not every private change should be published.

## Personal Automation Versus Template Guidance

Some users may choose to make the promotion check a personal rule in their private Codex instructions. For example, they might require Codex to check every private handover-repo change and decide whether a sanitized public equivalent belongs in a public template repo.

That is a useful personal workflow, but it is not a default requirement for everyone using this template.

If you adopt it, keep the rule in your private or global Codex instructions. Public repos should document the pattern generically, not contain personal paths, private handovers, or project-specific agent rules.

## Operating Rule

When making improvements to `~/repos/codex-sync`, consider whether the change is a reusable public-facing improvement for `~/repos/codex-handover-bridge`.

If it is generic and safe, suggest or apply a sanitized equivalent change to `~/repos/codex-handover-bridge`.

Never copy private handover content, personal paths, names, emails, secrets, client information, legal or medical material, or project-specific logs into the public repo.

## Good Public Candidates

Public-facing candidates include:

- script bug fixes
- template improvements
- README or documentation improvements
- safer `AGENTS.example.md` wording
- troubleshooting lessons
- generic config examples
- generic loader prompt improvements

## Never Publish

Never publish:

- private handovers
- real local project paths
- names, emails, or client details
- secrets, tokens, or API keys
- legal, medical, or client evidence
- raw Codex logs from private work
- project-specific `AGENTS.md` files

## Sanitisation Review

Require a sanitisation review before copying any idea into the public repo.

Prefer reimplementing the idea cleanly in the public repo instead of copying private files verbatim. Reimplementation forces you to remove private context, simplify the wording, and make the result useful to other users.

## Public Promotion Checklist

1. Is this change generic?
2. Does it remove all private paths?
3. Does it remove all personal names/emails?
4. Does it avoid secrets and sensitive material?
5. Does it help other users?
6. Has the diff been reviewed before commit?
7. Is the public commit message clear?
