---
name: commit
description: Commit changes as focused commits, each with clear boundaries and a descriptive conventional-commit title. Use when the user asks to commit, or when a logical change on a feature branch is finished.
---

# Commit

Turn the current changes into commits where each one does exactly one thing,
and its title says what that thing is. Committing doesn't need the user's
approval.

## Rules

- **One logical change per commit.** If the changes do several things (a fix,
  a refactor, a new feature), split them into separate commits. Keep
  whitespace-only or formatting changes in their own commit.
- **Title only.** No commit body, no trailers (`Co-Authored-By` or anything else).
- **Never commit on `main` or `master`.** Create a feature branch first.
- **Never commit secrets** (`.env` files, keys, tokens, credentials). If one is
  among the changes, leave it out and tell the user.
- **Don't amend, rebase, or push** as part of committing.

## Steps

1. Look at everything that changed: `git status`, `git diff`, and
   `git diff --cached`. Read recent titles with `git log --oneline -10` to match
   the repository's style.
2. Group the changes into logical commits. If the user has already staged
   something, treat that as their intended commit. If a change looks like the
   user's unrelated work in progress, leave it uncommitted and mention it.
3. For each group, stage exactly its files by path (`git add path/to/file`).
   Don't use `git add -A`, `git add .`, or `git commit -a`, which sweep in
   everything.
4. Write the title and commit with `git commit -m "<title>"`.
5. Report each commit's hash and title, and anything left uncommitted.

## Title format

```text
<type>: <what changed>
```

- **Type:** `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `style`, `build`,
  `ci`, or `chore`. Pick the one that fits the main purpose.
- **Description:** imperative mood ("add", not "added"), lowercase first word,
  no trailing period, under about 72 characters.
- Be specific enough that someone reading `git log --oneline` knows what the
  commit changes without opening it.

```text
fix: correct form input validation
feat: add users route
refactor: extract retry logic from api client
chore: bump next.js to 15.2
style: format lua files with stylua
```
