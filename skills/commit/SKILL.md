---
name: commit
description: Analyze staged Git changes, draft a succinct conventional commit title, and commit the changes.
compatibility: opencode
---

## What I do

I inspect the Git index, draft a conventional-commit-style title, and commit staged changes.
I do not stage hunks, files, or untracked changes.
I do this only when the user **explicitly** asks me to commit.

## Workflow

1. Identify the current Git repository and confirm whether it has staged changes using `git diff --cached --quiet`.
2. If no changes are staged, clearly report that no commit can be created until changes are staged. Do not inspect unstaged or untracked changes.
3. Inspect the staged file summary with `git diff --cached --stat` and review the complete staged diff with `git diff --cached`. Use staged file status and recent commit messages when helpful.
4. If the staged changes contain sensitive or unsafe data, such as secrets or an `.env` file, alert the user and stop.
5. Infer the primary purpose of the staged changes and choose the most accurate prefix from: `fix`, `feat`, `chore`, `docs`, `refactor`, `test`, `perf`, `build`, `ci`, or `style`.
6. Draft exactly one title in this format:

```text
<prefix>: <short descriptive title>
```

7. Keep the title succinct and specific to the staged changes. Use an imperative verb, lowercase the description's first word, omit a trailing period, and do not add a body, Markdown, alternatives, or explanatory text to the title itself.
8. Display the title to the user and await approval.
9. If approved, run `git commit -m "[generated title]"` using the exact approved title.
10. Report whether the commit succeeded and show the resulting commit hash.

## Examples

```text
fix: correct form input validation
chore: bump next.js dependencies
feat: add users route
```

## When to use me

Use this skill only when the user explicitly asks to commit the currently staged changes.
