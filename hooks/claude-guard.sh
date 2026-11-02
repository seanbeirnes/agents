#!/bin/sh
# Claude Code PreToolUse hook: passes the tool call to guard.sh.
# Reads the hook JSON on stdin. Blocks with exit 2, or asks with a JSON reply.
# Fails closed: without jq, every guarded tool call is blocked.

here=$(cd "$(dirname "$0")" && pwd)

if ! command -v jq >/dev/null 2>&1; then
	echo "Blocked by guard: jq is required by the agents guard hook. Install jq (nix: pkgs.jq, apt: jq)." >&2
	exit 2
fi

payload=$(cat)
tool=$(printf '%s' "$payload" | jq -r '.tool_name // empty')

case $tool in
Bash)
	mode=bash
	value=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')
	;;
Read | Edit | Write)
	mode=path
	value=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')
	;;
*) exit 0 ;;
esac

reason=$(printf '%s' "$value" | sh "$here/guard.sh" "$mode" 2>&1 >/dev/null)
status=$?

case $status in
0) exit 0 ;;
3)
	jq -n --arg reason "$reason" '{
		hookSpecificOutput: {
			hookEventName: "PreToolUse",
			permissionDecision: "ask",
			permissionDecisionReason: $reason
		}
	}'
	exit 0
	;;
*)
	printf '%s\n' "${reason:-Blocked by guard.}" >&2
	exit 2
	;;
esac
