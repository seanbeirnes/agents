# OpenCode Configuration

Personal [OpenCode](https://opencode.ai/) configuration with reusable skills, slash commands, and conservative permissions for Git and GitHub operations.

## Setup

Back up any existing OpenCode configuration, then clone this repository into OpenCode's default configuration directory:

```sh
mv ~/.config/opencode ~/.config/opencode.backup
git clone <repository-url> ~/.config/opencode
```

Restart OpenCode after cloning so it discovers the commands and skills.

## Secret Scanning

The Gitleaks GitHub Actions workflow scans the complete repository history on pull requests and every branch pushed to the GitHub repository.

To also scan before each local push, configure the path to your Gitleaks executable and enable the versioned hook:

```sh
git config --local gitleaks.path /absolute/path/to/gitleaks
ln -sf ../../.githooks/pre-push .git/hooks/pre-push
```

The executable path is stored only in the clone's `.git/config`; it is not committed. The hook blocks the push when Gitleaks detects a secret, although Git hooks can be explicitly bypassed with `git push --no-verify`.

## Commands

| Command | Purpose |
| --- | --- |
| `/commit` | Draft a conventional commit title from staged changes and commit after approval. |
| `/pr-create` | Analyze the current branch, draft a pull request, and create it with GitHub CLI. |
| `/prototype` | Build a throwaway logic or UI prototype to answer a design question. |
| `/grill-me` | Stress-test a plan, decision, or idea through structured questions. |
| `/teach` | Create a workspace-based learning path for a skill or concept. |

Commands are thin entry points in `opencode/commands/`. Their detailed workflows live in the corresponding `skills/` directories.

## Safety Defaults

`opencode/opencode.json` limits destructive or remote operations:

- Denies pushes, hard resets, forced branch deletion, repository deletion, pull-request merges, and secret management.
- Requires confirmation for rebases, amended commits, pull-request edits, issue closure, and release creation.
- Leaves routine local inspection and editing available to the agent.

Review these permissions before adapting the configuration to your own workflow.

## Repository Layout

```text
.
├── .githooks/      # Versioned local Git hooks
├── .github/        # GitHub Actions workflows
├── opencode/
│   ├── commands/       # Slash-command entry points
│   └── opencode.json   # OpenCode permissions and configuration
├── skills/         # Reusable agent workflows and supporting files
├── LICENSE         # Repository-wide MIT license
└── README.md
```

## License

Original content in this repository is available under the [MIT License](LICENSE). Adapted skills remain subject to the license and attribution included in their respective directories.

## Credits

The `prototype`, `grill-me`, and `teach` skills are adapted from [Matt Pocock's skills repository](https://github.com/mattpocock/skills). See each skill's metadata and license for details.
