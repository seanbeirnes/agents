#!/bin/sh
# install.sh: link this repository into Claude Code and OpenCode.
#
# Usage: ./install.sh [--dry-run]
#
# Safe to rerun. Existing files in the way are moved to <name>.backup-<time>,
# never deleted. ~/.claude/settings.json is merged, not replaced.
# Needs: POSIX sh, ln, and jq (for the settings merge).

set -eu

repo=$(cd "$(dirname "$0")" && pwd)
claude_dir="$HOME/.claude"
opencode_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
stamp=$(date +%Y%m%d-%H%M%S)
dry_run=0

case ${1-} in
--dry-run) dry_run=1 ;;
'') ;;
*)
	echo "usage: $0 [--dry-run]" >&2
	exit 64
	;;
esac

say() { printf '%s\n' "$*"; }

run() {
	if [ $dry_run = 1 ]; then
		say "would run: $*"
	else
		"$@"
	fi
}

# link <target in repo> <link path>
link() {
	target=$1
	path=$2
	if [ -L "$path" ] && [ "$(readlink "$path")" = "$target" ]; then
		say "ok       $path"
		return
	fi
	run mkdir -p "$(dirname "$path")"
	if [ -L "$path" ]; then
		run rm "$path" # a symlink pointing elsewhere; the thing it points to is untouched
	elif [ -e "$path" ]; then
		say "backup   $path -> $path.backup-$stamp"
		run mv "$path" "$path.backup-$stamp"
	fi
	run ln -s "$target" "$path"
	[ $dry_run = 1 ] || say "linked   $path -> $target"
}

if ! command -v jq >/dev/null 2>&1; then
	echo "install.sh needs jq (nix: pkgs.jq, apt: jq). The Claude guard hook needs it too." >&2
	exit 1
fi

# The old setup cloned this repository straight into ~/.config/opencode.
if [ -d "$opencode_dir/.git" ] && [ "$(cd "$opencode_dir" && pwd -P)" != "$repo" ]; then
	cat >&2 <<EOF
$opencode_dir is a git clone (the old way this repo was installed).
Move it aside first, then rerun this script:

  mv "$opencode_dir" "$opencode_dir.old"

EOF
	exit 1
fi

say "== Shared instructions"
link "$repo/AGENTS.md" "$opencode_dir/AGENTS.md"
link "$repo/AGENTS.md" "$claude_dir/CLAUDE.md"

say "== Skills (OpenCode also reads ~/.claude/skills)"
for skill in "$repo"/skills/*/; do
	name=$(basename "$skill")
	link "$repo/skills/$name" "$claude_dir/skills/$name"
done

say "== OpenCode"
link "$repo/opencode/opencode.json" "$opencode_dir/opencode.json"
link "$repo/opencode/commands" "$opencode_dir/commands"
link "$repo/opencode/plugins/guard.ts" "$opencode_dir/plugins/guard.ts"

say "== Claude settings (merged into $claude_dir/settings.json)"
settings="$claude_dir/settings.json"
existing='{}'
if [ -e "$settings" ]; then
	if ! existing=$(jq -e . "$settings"); then
		echo "$settings is not valid JSON; fix it and rerun." >&2
		exit 1
	fi
fi

# Repo keys win, except permission lists, which are combined so rules you
# added locally survive. Any old guard hook entry is replaced with this one.
merged=$(printf '%s' "$existing" | jq --slurpfile repo "$repo/claude/settings.json" --arg dir "$repo" '
	($repo[0] | .hooks.PreToolUse[].hooks[].command |= sub("__AGENTS_DIR__"; $dir)) as $new
	| . as $old
	| ($old * ($new | del(.permissions, .hooks)))
	| .permissions = (($old.permissions // {}) * ($new.permissions | with_entries(
		.value = ((($old.permissions // {})[.key] // []) + .value | unique))))
	| .hooks.PreToolUse = (
		[($old.hooks.PreToolUse // [])[]
			| select(any(.hooks[]?; .command | test("claude-guard\\.sh")) | not)]
		+ $new.hooks.PreToolUse)
')

if [ "$merged" = "$existing" ]; then
	say "ok       $settings"
elif [ $dry_run = 1 ]; then
	say "would update $settings:"
	old_file=$(mktemp)
	new_file=$(mktemp)
	printf '%s\n' "$existing" | jq -S . >"$old_file"
	printf '%s\n' "$merged" | jq -S . >"$new_file"
	diff -u "$old_file" "$new_file" || true
	rm -f "$old_file" "$new_file"
else
	mkdir -p "$claude_dir"
	[ -e "$settings" ] && cp "$settings" "$settings.backup-$stamp" && say "backup   $settings -> $settings.backup-$stamp"
	printf '%s\n' "$merged" >"$settings.tmp.$$"
	mv "$settings.tmp.$$" "$settings"
	say "updated  $settings"
fi

say "Done. Restart Claude Code and OpenCode to pick up the changes."
