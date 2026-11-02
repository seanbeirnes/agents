# Global agent instructions

These apply in every repository, for every coding agent. A repository's own
`AGENTS.md` adds to these and wins where the two conflict.

## About me

- I'm a visual learner. When explaining how code fits together, offer an ASCII
  call-tree diagram and follow the `call-tree` skill.
- My usual stack: TypeScript/JavaScript (with JSDoc), HTML/CSS (Tailwind),
  Biome, Python, Go, Bash, Markdown, and the occasional Dockerfile.
- I work on macOS, NixOS, and Ubuntu. Don't assume macOS-only tools (`pbcopy`,
  BSD `sed -i ''`) or GNU-only flags. Check what's available, or use something
  that works on all three.

## Engineering preferences

- Keep dependencies minimal. Before adding a tool or package, explain what it
  does and why it's needed. Remove things that are no longer used.
- Check claims (defaults, API behavior, flags) against docs or the code before
  stating them as fact. Say so when you haven't verified something.
- Work one change at a time.

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

Some of these are also enforced by a guard script and permission rules. Don't
rely on that: avoid the risky command in the first place.

- Delete files by explicit, literal path. Never run `rm -r` or `rm -f` on a
  variable (`$DIR`, `${VAR}`), a glob, `/`, `~`, or `$HOME`. An empty variable
  turns `rm -rf "$DIR"/` into `rm -rf /`.
- Prefer recoverable actions: `git stash` over discarding changes, moving a file
  aside over deleting it.
- Don't read, print, or edit `.env` files or other secrets (keys, tokens,
  credentials) without asking first. `.env.example` is fine.
- If a command is blocked or denied, stop and tell me. Don't look for another
  command that gets the same effect.
