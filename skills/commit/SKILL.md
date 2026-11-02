---
name: commit
description: Draft a succinct conventional commit title for staged Git changes and commit them. Use when the user asks to commit, or when a logical change on a feature branch is finished.
---

## What I do

I inspect the Git index, draft a conventional-commit-style title, and commit staged changes.
Committing does not need the user's approval. I never commit on `main` or `master`, and I never amend, rebase, or push as part of committing.

## Staging

- When the user asks me to commit, I commit what they have staged and do not stage anything myself.
- When I commit my own finished work, I stage only the files I changed, by explicit path (`git add path/to/file`). I never use `git add -A`, `git add .`, or `git commit -a`, so the user's unrelated changes stay out of the commit.

## Workflow

1. Identify the current Git repository and branch. If the branch is `main` or `master`, alert the user and stop.
2. Confirm whether there are staged changes using `git diff --cached --quiet`. If none are staged, clearly report that no commit can be created until changes are staged.
3. Inspect the staged file summary with `git diff --cached --stat` and review the complete staged diff with `git diff --cached`. Use staged file status and recent commit messages when helpful.
4. If the staged changes contain sensitive or unsafe data, such as secrets or an `.env` file, alert the user and stop.
5. Infer the primary purpose of the staged changes and choose the most accurate prefix from: `fix`, `feat`, `chore`, `docs`, `refactor`, `test`, `perf`, `build`, `ci`, or `style`.
6. Draft exactly one title in this format:

```text
<prefix>: <short descriptive title>
```

7. Keep the title succinct and specific to the staged changes. Use an imperative verb, lowercase the description's first word, omit a trailing period, and do not add a body, Markdown, alternatives, or explanatory text to the title itself.
8. Run `git commit -m "<title>"` with the drafted title. Do not add trailers such as `Co-Authored-By`.
9. Report the title, whether the commit succeeded, and the resulting commit hash.

## Examples

```text
fix: correct form input validation
chore: bump next.js dependencies
feat: add users route
```

## When to use me

Use this skill when the user asks to commit, or when I have finished one logical change on a feature branch. Keep whitespace-only or formatting changes in their own commit.
