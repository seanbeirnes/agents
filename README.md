# Agents

Personal configuration shared by coding agents: [Claude Code](https://code.claude.com/) and [OpenCode](https://opencode.ai/). One set of instructions, skills, and safety rules, linked into each tool. Works on macOS, NixOS, and Ubuntu.

## Setup

Requirements: `git`, `jq`, and a POSIX shell.

```sh
git clone git@github.com:seanbeirnes/agents.git ~/.config/agents
cd ~/.config/agents
./install.sh --dry-run   # preview every change
./install.sh
```

Restart Claude Code and OpenCode afterwards.

The installer is safe to rerun:

- Files and folders are **symlinked**, so edits in the repository apply right away. Anything already in the way is moved to `<name>.backup-<time>`, never deleted.
- `~/.claude/settings.json` is **merged**, not replaced. Your own settings (theme, voice, and so on) are kept, and permission rules you added locally are kept alongside the repository's.
- If `~/.config/opencode` is still a clone of this repository (the old setup), the installer stops and tells you to move it aside first.
- It creates `~/agents/`, where agents keep session notes and plans (see Session State in `AGENTS.md`). Both tools are allowed to read and write there without prompting.

The repository can live anywhere; the links point to wherever you cloned it. If you move it, rerun `./install.sh`.

### What gets linked

| Repository | Claude Code | OpenCode |
| --- | --- | --- |
| `AGENTS.md` | `~/.claude/CLAUDE.md` | `~/.config/opencode/AGENTS.md` |
| `skills/<name>/` | `~/.claude/skills/<name>/` | read from `~/.claude/skills/` |
| `claude/settings.json` | merged into `~/.claude/settings.json` | |
| `opencode/opencode.json` | | `~/.config/opencode/opencode.json` |
| `opencode/commands/` | | `~/.config/opencode/commands/` |
| `opencode/plugins/guard.ts` | | `~/.config/opencode/plugins/guard.ts` |

OpenCode discovers skills in `~/.claude/skills/` natively, so skills are linked once.

## Instructions

[`AGENTS.md`](AGENTS.md) holds the global instructions: preferences, the Git workflow, and safety rules. Both tools load it in every session. A repository's own `AGENTS.md` adds to it.

## Skills

| Skill | Purpose |
| --- | --- |
| `/commit` | Split changes into focused commits, each with a descriptive conventional-commit title. |
| `/pr-create` | Analyze the current branch, draft a pull request, and create it with GitHub CLI. |
| `/gh-reply` | Draft or post a GitHub issue or PR reply, prefixed with an AI disclaimer. |
| `/call-tree` | Draw an ASCII call-tree diagram of a file, feature, or pull request. |

Claude Code exposes each skill as a slash command directly. OpenCode uses the thin wrappers in `opencode/commands/`, so the names match in both tools.

## Safety

Three layers, from soft to hard:

1. **Instructions.** The Safety section of `AGENTS.md` tells agents to avoid risky commands in the first place.
2. **Permission rules.** `claude/settings.json` and `opencode/opencode.json` express the same policy for each tool:
   - **Deny**, never allowed: force pushes, deleting repositories or releases, expiring the reflog, wiping disks.
   - **Ask**, needs approval: pushing, amending, rebasing, merging, resetting, cleaning, deleting branches, creating or commenting on pull requests and issues, `gh api`, `sudo`, system rebuilds, and editing or reading `.env` files.
   - **Allow**, no prompt: Git and GitHub CLI reads, `git add`, `git commit`, switching and creating branches.
3. **Guard script.** [`hooks/guard.sh`](hooks/guard.sh) checks the actual command before it runs, which catches what patterns can't:
   - **Blocks** `rm` on a variable or command substitution, `rm -r`/`-f` on `/`, a top-level directory, a home directory or anything directly in it, `.`, `..`, or `*`, `find -delete` from those places, and force pushes in any form (including `git -C dir push -f`).
   - **Asks** before a command or file read touches a `.env` file (`.env.example` is fine).

The guard runs as a `PreToolUse` hook in Claude Code (`hooks/claude-guard.sh`) and as a plugin in OpenCode (`opencode/plugins/guard.ts`). OpenCode plugins can't ask for approval, so OpenCode blocks the `.env` cases and tells the agent to ask you instead. The Claude hook needs `jq` and **fails closed**: without `jq`, every guarded tool call is blocked.

The guard parses commands roughly (it ignores quotes and splits on `;`, `&&`, `|`, and so on), so it can be over-cautious. For example, text in a heredoc that looks like `rm -rf "$DIR"` is blocked too.

Run the tests with:

```sh
sh hooks/guard.test.sh
```

## Secret scanning

The Gitleaks GitHub Actions workflow scans the complete repository history on pull requests and every branch pushed to the GitHub repository.

To also scan before each local push, configure the path to your Gitleaks executable and enable the versioned hook:

```sh
git config --local gitleaks.path /absolute/path/to/gitleaks
ln -sf ../../.githooks/pre-push .git/hooks/pre-push
```

The executable path is stored only in the clone's `.git/config`; it is not committed. The hook blocks the push when Gitleaks detects a secret, although Git hooks can be explicitly bypassed with `git push --no-verify`.

## Repository layout

```text
.
├── AGENTS.md           # Shared global instructions
├── skills/             # Shared skills (SKILL.md plus supporting files)
├── hooks/              # Guard script, its Claude hook adapter, and tests
├── claude/
│   └── settings.json   # Claude Code permissions, hook, and settings
├── opencode/
│   ├── commands/       # Slash-command wrappers for the skills
│   ├── plugins/        # Guard plugin
│   └── opencode.json   # OpenCode permissions
├── install.sh          # Links everything into place
├── .githooks/          # Versioned local Git hooks
├── .github/            # CI: Gitleaks, ShellCheck, guard tests
└── LICENSE
```

## License

Available under the [MIT License](LICENSE).
