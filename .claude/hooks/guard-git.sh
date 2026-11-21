#!/bin/sh
# github-ready: stops Claude running risky git commands.
# Claude Code sends the command as JSON on stdin. Exit 2 blocks it and the
# message below goes back to Claude so it can take the safe route instead.

cmd=$(cat | tr '\n' ' ')

block() {
  echo "Blocked by the project's git safety rules: $1" >&2
  exit 2
}

# Only look at git commands
printf '%s' "$cmd" | grep -q 'git' || exit 0

printf '%s' "$cmd" | grep -Eq 'push[^"]*(--force|--force-with-lease| -f( |\\|"|$))' &&
  block "force-pushing overwrites work on GitHub. Push normally, or ask the owner."

printf '%s' "$cmd" | grep -Eq 'push[^"]*[ :](refs/heads/)?(main|master)( |\\|"|$)' &&
  block "pushing straight to main. Push your branch and open a pull request instead."

printf '%s' "$cmd" | grep -Eq -- '--no-verify' &&
  block "--no-verify skips the secret check. Fix what the check found instead."

printf '%s' "$cmd" | grep -Eq 'reset --hard|clean -[a-z]*f|filter-branch|filter-repo' &&
  block "this can permanently delete work. Ask the owner first."

printf '%s' "$cmd" | grep -Eq 'add[^"]*(^| )([^ "]*/)?\.env(\.local|\.production)?( |\\|"|$)' &&
  block ".env holds secrets and must never be committed."

exit 0
