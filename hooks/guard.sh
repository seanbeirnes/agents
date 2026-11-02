#!/bin/sh
# guard.sh: decide whether an agent's shell command or file access is safe.
#
# Usage:
#   guard.sh bash < command   the shell command the agent wants to run
#   guard.sh path < path      a file the agent wants to read or edit
#
# Exit status: 0 = allow, 2 = block, 3 = ask the user. The reason goes to stderr.
#
# This is a safety net, not a sandbox: it parses commands roughly (quotes are
# ignored, separators split commands) and errs on the side of blocking.
# POSIX sh only, so it runs the same on macOS, NixOS, and Ubuntu.

set -f # never expand globs while splitting words

block() {
	printf 'Blocked by guard: %s\n' "$1" >&2
	exit 2
}

ask() {
	printf 'Needs approval: %s\n' "$1" >&2
	exit 3
}

# A .env file with real values (not an example or template).
is_secret_env() {
	base=${1##*/}
	case $base in
	.env.example | .env.sample | .env.template) return 1 ;;
	.env | .env.*) return 0 ;;
	esac
	return 1
}

# A path that would be a disaster to delete recursively: /, a top-level
# directory, a home directory or anything directly inside it, ., .., or a
# bare * glob over one of those.
is_dangerous_target() {
	t=$1
	case $t in
	\*) return 0 ;;
	*/\*) t=${t%/\*} ;;
	esac
	[ -z "$t" ] && return 0
	while [ "$t" != / ] && [ "${t%/}" != "$t" ]; do t=${t%/}; done
	case $t in
	/ | '~' | . | ..) return 0 ;;
	*[!./]*) ;;
	*) return 0 ;; # only dots and slashes, like ../..
	esac
	case $t in
	'~'/*/*) return 1 ;;
	'~'/*) return 0 ;;
	/Users/*/* | /home/*/*) return 1 ;;
	/Users/* | /home/*) return 0 ;;
	/*/*) return 1 ;;
	/*) return 0 ;;
	esac
	return 1
}

# Arguments: the words after `rm`. $via_xargs is set when rm runs under xargs.
check_rm() {
	recursive=0
	force=0
	for w in "$@"; do
		case $w in
		--) ;;
		--recursive) recursive=1 ;;
		--force) force=1 ;;
		--no-preserve-root) block "rm --no-preserve-root is never allowed." ;;
		--*) ;;
		-*)
			case $w in *[rR]*) recursive=1 ;; esac
			case $w in *f*) force=1 ;; esac
			;;
		esac
	done
	if [ "$via_xargs" = 1 ] && [ $recursive = 1 ]; then
		block "rm -r through xargs deletes paths that can't be checked. List the paths explicitly."
	fi
	for w in "$@"; do
		case $w in
		-*) continue ;;
		*'$'*) block "rm on a variable or command substitution ($w). Delete by literal path." ;;
		esac
		if [ $recursive = 1 ] || [ $force = 1 ]; then
			if is_dangerous_target "$w"; then
				block "rm -r/-f on '$w' is too broad. Delete a specific path instead."
			fi
		fi
	done
}

# Arguments: the words after `find`.
check_find() {
	deletes=0
	prev=
	for w in "$@"; do
		case $w in -delete) deletes=1 ;; esac
		[ "$prev" = -exec ] || [ "$prev" = -execdir ] || [ "$prev" = -ok ] && case ${w##*/} in rm) deletes=1 ;; esac
		prev=$w
	done
	[ $deletes = 1 ] || return 0
	for w in "$@"; do
		case $w in -* | '(' | '!') break ;; esac
		case $w in
		. | ./) continue ;; # deleting matches under the current directory is normal
		*'$'*) block "find with -delete on a variable path ($w). Use a literal path." ;;
		esac
		if is_dangerous_target "$w"; then
			block "find -delete starting at '$w' is too broad. Start from a specific directory."
		fi
	done
}

# Arguments: the words after `git`.
check_git() {
	# Skip global options to find the subcommand: git -C dir -c k=v push ...
	while [ $# -gt 0 ]; do
		case $1 in
		-C | -c | --git-dir | --work-tree | --namespace) shift 2 || return 0 ;;
		-*) shift ;;
		*) break ;;
		esac
	done
	[ "${1-}" = push ] || return 0
	shift
	for w in "$@"; do
		case $w in
		--force* | --mirror) block "force pushing is never allowed ($w)." ;;
		--*) ;;
		-*f*) block "force pushing is never allowed ($w)." ;;
		+*) block "force pushing is never allowed (refspec $w)." ;;
		esac
	done
}

# Check one simple command, already split into words.
check_command() {
	via_xargs=0
	# Skip wrappers and their options: sudo -u x, env A=b, nohup, time, ...
	while [ $# -gt 0 ]; do
		case $1 in
		sudo | doas | command | builtin | exec | nohup | time | nice | env | "{" | "}") shift ;;
		xargs)
			via_xargs=1
			shift
			;;
		-u | -g | -n) shift 2 || return 0 ;;
		-*) shift ;;
		*=*) shift ;;
		*) break ;;
		esac
	done
	[ $# -gt 0 ] || return 0
	cmd=${1#\\}
	cmd=${cmd##*/}
	shift
	case $cmd in
	rm) check_rm "$@" ;;
	find) check_find "$@" ;;
	git) check_git "$@" ;;
	esac
}

check_bash() {
	# Split into simple commands. $( and backticks also leave a "$_" word behind,
	# so `rm -rf $(pwd)` is still seen as rm on a substitution.
	segments=$(printf '%s\n' "$1" | awk '{
		gsub(/[\047"]/, "")
		gsub(/\$\(/, " $_\n")
		gsub(/`/, " $_\n")
		gsub(/&&|\|\||[;|&()]/, "\n")
		print
	}')
	needs_env_approval=
	old_ifs=$IFS
	nl='
'
	IFS=$nl
	for segment in $segments; do
		IFS=$old_ifs
		# shellcheck disable=SC2086 # word splitting is the point here
		set -- $segment
		for w in "$@"; do
			w=${w#[<>]}
			if is_secret_env "$w"; then needs_env_approval=$w; fi
		done
		check_command "$@"
		IFS=$nl
	done
	IFS=$old_ifs
	if [ -n "$needs_env_approval" ]; then
		ask "this command touches the secrets file $needs_env_approval."
	fi
}

check_path() {
	if is_secret_env "$1"; then
		ask "$1 may contain secrets."
	fi
}

mode=${1-}
input=$(cat)
case $mode in
bash) check_bash "$input" ;;
path) check_path "$input" ;;
*)
	printf 'usage: guard.sh bash|path < input\n' >&2
	exit 64
	;;
esac
exit 0
