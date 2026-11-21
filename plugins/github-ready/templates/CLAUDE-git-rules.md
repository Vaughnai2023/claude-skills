
## Git rules

- Never work on `main`. Start every change on a branch: `feat/short-name`, `fix/short-name` or `chore/short-name`.
- Small commits with plain messages that say what changed and why.
- When the work is done and checked, push the branch and open a pull request with `gh pr create --fill`. Merging happens on GitHub with Squash and merge.
- Never commit secrets. Keys and passwords live in `.env`, which git ignores. If you add a new setting, add its name (not its value) to `.env.example`.
- Never force-push, rewrite history, or use `--no-verify`. If a safety hook blocks something, fix the cause and tell me what it was.
- After a pull request is merged: `git switch main && git pull`, then start the next branch.
- Explain git steps to me in plain words. I may not know the terms.
