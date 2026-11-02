# Global agent instructions

These apply in every repository, for every coding agent. A repository's own
`AGENTS.md` adds to these and wins where the two conflict.

## About Sean

- I'm a visual learner:
    - Use bullet points and diagrams in your explanations.
    - When explaining how code fits together, offer an ASCII call-tree diagram and follow the `call-tree` skill.
- I work on macOS, NixOS, and Ubuntu. Prefer cross-platform solutions.

## Engineering preferences

- Keep dependencies minimal. Before adding a tool or package, explain what it
  does and why it's needed. Remove things that are no longer used.
- Check claims (defaults, API behavior, flags) against docs or the code before
  stating them as fact. Say so when you haven't verified something.
- Call out the software patterns you intend to use. This removes misunderstandings early, before the code is written.

## Code Quality

Code quality and design decisions should be rooted in the ideas of these books.
Where they disagree, prefer Ousterhout.
- *A Philosophy of Software Design* by John Ousterhout
- *Clean Code* by Robert Martin
- *The Pragmatic Programmer* by Andy Hunt and Dave Thomas

The over-arching points are:
- Write DRY code: don't repeat knowledge, but don't merge code just because it
  looks similar.
- Choose clear, descriptive method and variable names.
- Prefer deep modules over shallow interfaces.
- Use comments sparingly and only when you need to say *why* the code is there.
  Comments are not for telling *what* the code does, nor are they for documenting ticket/issue numbers, etc.

## Session State

For any task with more than a couple of steps, or one that might continue in a
later session, keep notes, plans, and related data in
`~/agents/<project or issue ID>/`.

If I didn't give a project or task name, or an issue or ticket, infer a name
from my request.

Each project directory looks like this:

- `plan.md`: the project's big-picture plan
- `agent-<name>/`: one directory per agent, named after the agent's task
  (inferred from the request, e.g. `agent-guard-script`)
  - `notes.md`
  - `plan.md`
  - `next-steps.md`

### notes.md

The agent's own running log: what it did, what I decided, where I pushed back,
and where its plan was corrected. Include the cost of runs when known.

### plan.md

At the project root, this describes the overall purpose and big-picture plan of
the project. It's often divided into phases.

In an agent directory, it's the plan for one big task, which may be a phase of
the project plan. The agent drafts it and we refine it together until I approve
it ("that's great, go do it"). From then on, the agent works without checking
back on individual steps or commits, until the end state the plan describes is
implemented.

### next-steps.md

When the agent finishes or stops, it lists the open questions and anything that
needs my input or approval here, so it can resume later without prior context.

## Git

- Work on a feature branch off `main`, never directly on `main`. I merge pull
  requests myself.
- You may commit without asking. Use the `commit` skill: one logical change per
  commit, with a conventional-commit title.
- Keep whitespace-only or formatting changes in their own commits and pull
  requests, separate from functional changes.
- Ask before pushing, and before anything that rewrites history or discards work
  (`commit --amend`, `rebase`, `reset --hard`, `clean`, deleting branches).
- Never force push.
- Don't add AI attribution (`Co-Authored-By` trailers, "Generated with" footers)
  to commits or pull requests.

## Pull requests and GitHub

- Create pull requests with the `pr-create` skill, which holds the required
  description template.
- Every comment or reply posted to GitHub starts with the AI disclaimer from the
  `gh-reply` skill.

## Safety

Avoid risky commands by following these principles:

- Delete files by explicit, literal path. Never run `rm -r` or `rm -f` on a
  variable (`$DIR`, `${VAR}`), a glob, `/`, `~`, or `$HOME`. An empty variable
  turns `rm -rf "$DIR"/` into `rm -rf /`.
- Prefer recoverable actions: `git stash` over discarding changes, moving a file
  aside over deleting it.
- Don't read, print, or edit `.env` files or other secrets (keys, tokens,
  credentials) without asking first. `.env.example` is fine.
- If a command is blocked or denied, stop and tell me. Don't look for another
  command that gets the same effect.
