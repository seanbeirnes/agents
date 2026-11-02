---
name: pr-create
description: Analyze the current branch, draft a pull request with the required Summary/Changes/Testing description, and create it with GitHub CLI when available. Use when the user asks to open, create, or describe a pull request.
---

# Create a pull request

Draft an accurate title and description for the current branch, then create
the pull request with `gh`. Treat `$ARGUMENTS` as optional context, such as the
base branch, title guidance, or a request for a draft pull request.

## Rules

- **Never run on `main` or `master`.** Tell the user and stop.
- **Describe the branch, not the session.** Base the description on the
  committed diff against the base branch. Include uncommitted changes only if
  the user asks. Leave out anything that was added and then removed again on
  the branch, since it isn't in the diff.
- **Only claim verification that actually ran.** Never imply a test ran because
  its file appears in the diff.
- **No AI attribution.** No "Generated with" footer or similar.
- **Use `gh` only.** If it's unavailable, don't fall back to another API.

## Steps

1. Find the base branch (the upstream, or the repository's default) and the
   merge base. Read the full branch diff, the changed files, and the commit
   titles.
2. Check whether the branch already has a pull request (`gh pr view`).
   - If it has one with an empty body, keep its number; you'll fill it in at
     step 6.
   - If it has one with a non-empty body, give the user its URL and a short
     summary of it, then stop.
3. Look at what changed in tests (added, updated, renamed, or removed) and at
   any verification that actually ran in this session.
4. Write a short title for the branch's main purpose, and the description using
   the template below.
5. Show the user the full title and description.
6. Publish it:
   - Existing pull request with an empty body: `gh pr edit <number>` with the
     title and body.
   - Otherwise: make sure the branch is on the remote, then `gh pr create` with
     the title and body, plus any base branch or draft flag the user asked for.
7. Report the pull request's URL.

If `gh` is missing, not authenticated, or fails, say why. Then copy the
description to the clipboard with the first of these that works: `pbcopy`,
`wl-copy`, `xclip -selection clipboard`. Say which one worked, or that none
did.

## Description template

```markdown
# Summary

[1-5 sentences overview]

# Changes

- One point per meaningful change
- ...

# Testing

[tests added or updated, and verification actually run]
```

- Replace every placeholder with concrete information. One focused bullet per
  meaningful change.
- In **Testing**, report two things separately when they apply:
  - test changes, as seen in the diff
  - commands actually run (tests, lint, build, manual checks) and their results
- If tests changed but nothing was run, describe the changes and write
  `Not run in this session.` If nothing changed and nothing was run, write
  `Not run (not requested).`
