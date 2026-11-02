#!/bin/sh
# Tests for guard.sh. Run: sh hooks/guard.test.sh
# Each case: expected exit status (0 allow, 2 block, 3 ask), mode, input.

guard="$(dirname "$0")/guard.sh"
pass=0
fail=0

t() {
	expected=$1
	mode=$2
	input=$3
	printf '%s' "$input" | sh "$guard" "$mode" 2>/dev/null
	actual=$?
	if [ "$actual" = "$expected" ]; then
		pass=$((pass + 1))
	else
		fail=$((fail + 1))
		printf 'FAIL: expected %s, got %s: guard.sh %s <<< %s\n' "$expected" "$actual" "$mode" "$input"
	fi
}

# --- rm: allowed ---
t 0 bash 'rm build/output.txt'
t 0 bash 'rm -rf node_modules'
t 0 bash 'rm -rf ./dist'
t 0 bash 'rm -f *.log'
t 0 bash 'rm -rf src/generated/*'
t 0 bash 'rm -rf ~/projects/app/tmp'
t 0 bash 'rm -rf /tmp/build-cache'
t 0 bash 'rm -r /Users/sean/code/old-project'
t 0 bash 'echo rm -rf is dangerous'

# --- rm: blocked ---
t 2 bash 'rm -rf /'
t 2 bash 'rm -rf /*'
t 2 bash 'rm -fr ~'
t 2 bash 'rm -rf ~/'
t 2 bash 'rm -rf ~/*'
t 2 bash 'rm -rf ~/.config'
t 2 bash 'rm -r -f /usr'
t 2 bash 'rm -R /etc/'
t 2 bash 'rm --recursive --force /home/sean'
t 2 bash 'rm -rf /Users/sean'
t 2 bash 'rm -rf .'
t 2 bash 'rm -rf ..'
t 2 bash 'rm -rf ../..'
t 2 bash 'rm -rf *'
t 2 bash 'rm -rf "$DIR"'
t 2 bash 'rm -rf "$DIR"/'
t 2 bash 'rm -rf ${BUILD_DIR}/out'
t 2 bash 'rm $TMPFILE'
t 2 bash 'rm -rf $(pwd)'
t 2 bash 'rm -rf `pwd`'
t 2 bash 'rm --no-preserve-root -rf /'
t 2 bash '/bin/rm -rf /'
t 2 bash '\rm -rf ~'
t 2 bash 'sudo rm -rf /var'
t 2 bash 'sudo -u root rm -rf /'
t 2 bash 'cd /tmp && rm -rf ~'
t 2 bash 'true; rm -rf /'
t 2 bash 'make clean || rm -rf "$OUT"'
t 2 bash '{ rm -rf ~; }'
t 2 bash 'ls | xargs rm -rf'
t 0 bash 'ls *.tmp | xargs rm -f'

# --- find ---
t 0 bash 'find . -name "*.pyc" -delete'
t 0 bash 'find src -type f -name "*.log"'
t 2 bash 'find / -name "*.log" -delete'
t 2 bash 'find ~ -type f -delete'
t 2 bash 'find "$DIR" -delete'
t 2 bash 'find / -name core -exec rm {} \;'

# --- git push ---
t 0 bash 'git push'
t 0 bash 'git push -u origin feat/thing'
t 0 bash 'git push origin main --follow-tags'
t 0 bash 'git status'
t 2 bash 'git push --force'
t 2 bash 'git push -f origin main'
t 2 bash 'git push origin main -f'
t 2 bash 'git push -uf origin main'
t 2 bash 'git push --force-with-lease'
t 2 bash 'git push origin +main'
t 2 bash 'git push --mirror'
t 2 bash 'git -C ../repo push --force'
t 2 bash 'git -c push.default=current push -f'
t 2 bash 'git add . && git commit -m wip && git push -f'

# --- .env through the shell ---
t 0 bash 'cat .env.example'
t 0 bash 'cp .env.example .env.sample'
t 3 bash 'cat .env'
t 3 bash 'grep KEY config/.env.local'
t 3 bash 'source .env'
t 3 bash 'node app.js < .env'
t 3 bash 'cp .env.example .env'

# --- file paths (Read/Edit/Write tools) ---
t 0 path 'src/index.ts'
t 0 path '/Users/sean/app/.env.example'
t 0 path 'environment.ts'
t 3 path '.env'
t 3 path '/Users/sean/app/.env'
t 3 path 'apps/web/.env.production'

printf '%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" = 0 ]
