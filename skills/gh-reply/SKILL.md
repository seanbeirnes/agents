---
name: gh-reply
description: Draft or post comments and replies to GitHub issues, pull requests, and reviews on the user's behalf, always prefixed with the required AI disclaimer. Use when the user asks to reply to, comment on, respond to, or review a GitHub issue or PR, or when running `gh issue comment`, `gh pr comment`, or `gh pr review`.
---

## What I do

I draft (and, when explicitly asked, post) comments and replies to GitHub issues, pull requests, and reviews on behalf of the maintainers.
Every reply I produce starts with a fixed disclaimer identifying it as AI-drafted.

## Disclaimer rule

Prepend exactly this line as a blockquote, followed by a blank line, to every comment or reply:

```markdown
> **Disclaimer:** This reply was drafted by <model name> (via <agent name>), an AI coding agent, on behalf of the maintainers.

```

- Substitute `<model name>` with the current model's name (for example `Claude Opus 5.5`) and `<agent name>` with the coding agent you are running in (for example `Claude Code` or `OpenCode`).
- The disclaimer is always the first line. Never place anything above it.
- Keep the wording verbatim; do not paraphrase, shorten, or restyle it.
- Apply it to every reply, including short ones and follow-ups in the same thread.

## Workflow

1. Gather context: read the issue/PR body, existing comments, and any relevant code or diffs before drafting.
2. Draft the reply body in GitHub-flavored markdown, matching the tone of the maintainers.
3. Prepend the disclaimer blockquote and a blank line.
4. Show the full draft to the user.
5. Post only when the user explicitly asks to post. Use `gh` (for example `gh issue comment <n> --body-file <file>` or `gh pr review <n> --comment --body-file <file>`), passing the body via a file to preserve formatting.
6. After posting, return the comment URL.

## Example

```markdown
> **Disclaimer:** This reply was drafted by Claude Opus 5.5 (via Claude Code), an AI coding agent, on behalf of the maintainers.

Thanks for the report. I was able to reproduce this on `main` with the steps you listed.
The root cause is in `src/config/load.ts:42`, where the fallback path is resolved before the env override is applied. A fix is up in #128.
```
