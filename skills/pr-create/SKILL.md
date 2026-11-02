---
name: pr-create
description: Analyze the current branch, draft a pull request with the required Summary/Changes/Testing description, and create it with GitHub CLI when available. Use when the user asks to open, create, or describe a pull request.
---

## What I do

I analyze the current branch, draft an accurate pull-request title and description, and create the pull request with GitHub CLI by default. If GitHub CLI is unavailable, unauthenticated, or unable to create the pull request, I provide the completed title and description without claiming that a pull request was created.
I do not run when the branch is on `main` or `master`.

## Workflow

1. Identify the current Git repository and branch. If the branch is on `main` or `master`, alert the user and stop.
2. Interpret any user-provided arguments as optional context, such as the base branch, title guidance, or whether to create a draft pull request.
3. Identify the upstream or default base branch and its merge base with the current branch. Inspect the complete committed branch diff, changed files, and commit messages. Include uncommitted changes only when the user explicitly requests working-tree analysis.
4. When `gh` is available and authenticated, check whether the current branch already has an associated pull request. If one exists with an empty body, retain its number and continue so it can be updated in step 11. If one exists with a non-empty body, alert the user by stating the URL and a PR content summary, then stop.
5. Review available test results and inspect the diff for added, modified, renamed, or removed test files and test cases. Infer test coverage changes from the code changes without claiming that inferred tests were executed.
6. Draft one concise pull-request title that reflects the primary purpose of the branch.
7. Draft the description using this exact template:

```markdown
# Summary

[1-5 sentences overview]

# Changes

- One point per meaningful change
- ...

# Testing

[tests added or updated, and verification actually run]
```

8. Replace every bracketed placeholder with concrete information. Keep the summary to 1–5 sentences and include one focused bullet for each meaningful change. Leave out changes that were added and then removed again on the branch, since they are not in the diff against the base. Do not add a "Generated with" footer or any other AI attribution.
9. In `# Testing`, report both forms of evidence separately when applicable:
   - Tests added, updated, renamed, or removed, as inferred from the branch diff.
   - Test, lint, build, or manual verification commands actually run and their outcomes.
   Never imply that a test was run merely because its file or case appears in the diff. If test coverage changed but no verification ran, describe the test changes and state `Not run in this session.` If no test coverage changed and no verification ran, write `Not run (not requested).`
10. Show the complete title and Markdown description before attempting creation or update.
11. If an existing pull request with an empty body was found, run `gh pr edit <number>` with the generated title and body to populate it. Otherwise, if `gh` is available and authenticated, ensure the branch is available on its remote, then run `gh pr create` with the generated title and body. Apply any user-requested base branch or draft status when creating a pull request. Do not use an alternative hosting API when `gh` is unavailable.
12. If creation or update succeeds, report the pull-request URL. If `gh` is unavailable, unauthenticated, or the operation fails, clearly report why and fall back to providing the title and description only.
13. On fallback, copy the exact Markdown description to the system clipboard. Try these commands in order, stopping after the first available command succeeds:

```sh
pbcopy
wl-copy
xclip -selection clipboard
```

Pipe the description to the command without modifying its content. Confirm which clipboard command succeeded. If none are installed or copying fails, clearly report that the description was shown but could not be copied.

## When to use me

Use this skill when the user asks to create a pull request for the current branch. Provide the title and description without creation only when GitHub CLI cannot create the pull request or the user explicitly requests description-only output.
