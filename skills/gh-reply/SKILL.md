---
name: gh-reply
description: Draft or post comments and replies to GitHub issues, pull requests, and reviews on the user's behalf, always prefixed with the required AI disclaimer. Use when the user asks to reply to, comment on, respond to, or review a GitHub issue or PR, or when running `gh issue comment`, `gh pr comment`, or `gh pr review`.
---

# Reply on GitHub

Draft comments and replies on issues, pull requests, and reviews on behalf of
the maintainers. Post them only when the user asks.

## The disclaimer

Every comment or reply starts with this line as a blockquote, followed by a
blank line:

```markdown
> **Disclaimer:** This reply was drafted by <model name> (via <agent name>), an AI coding agent, on behalf of the maintainers.

```

- Fill in `<model name>` with your model's name (for example `Claude Opus 5.5`)
  and `<agent name>` with the coding agent you're running in (for example
  `Claude Code` or `OpenCode`).
- It's always the first line, with nothing above it.
- Use the wording exactly as written; don't paraphrase, shorten, or restyle it.
- Include it on every reply, including short ones and follow-ups in the same
  thread.

## Steps

1. Read the issue or pull request body, the existing comments, and any relevant
   code or diffs.
2. Draft the reply in GitHub-flavored Markdown, matching the maintainers' tone.
3. Put the disclaimer first, then a blank line, then the reply.
4. Show the full draft to the user.
5. If the user asks you to post it, use `gh` and pass the body through a file to
   keep its formatting, for example `gh issue comment <n> --body-file <file>` or
   `gh pr review <n> --comment --body-file <file>`.
6. After posting, give the comment's URL.

## Example

```markdown
> **Disclaimer:** This reply was drafted by Claude Opus 5.5 (via Claude Code), an AI coding agent, on behalf of the maintainers.

Thanks for the report. I was able to reproduce this on `main` with the steps you listed.
The root cause is in `src/config/load.ts:42`, where the fallback path is resolved before the env override is applied. A fix is up in #128.
```
