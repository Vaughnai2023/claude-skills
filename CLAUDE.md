# claude-skills

Vaughn's Claude Code plugin marketplace. Other people install from it, so skills must work for people who don't know git or code.

## This repo is public

Anyone on the internet can read everything here, including old versions. Every skill added must be safe to share. Before adding or changing anything, check it contains none of these:

- Client, company or people's names (other than Vaughn as the author)
- Email addresses, phone numbers, physical addresses
- Passwords, API keys, tokens, or links that only work with a login
- Internal business details: prices, rates, contracts, project names, client data or examples taken from real client work
- Anything Vaughn would mind a stranger reading

If a skill needs any of that to work, it doesn't belong here. It goes in its own private repo. When in doubt, ask Vaughn before committing.

## Rules for this repo

- Each plugin lives in `plugins/<name>/` and has an entry in `.claude-plugin/marketplace.json`. Entry name and `plugin.json` name must match.
- Never set a `version` field. Users update by tracking the latest commit.
- Run `claude plugin validate .` after every change and fix anything it reports.
- Skills that change things (files, GitHub, settings) get `disable-model-invocation: true` so they only run when typed.
- Write skills and README text in plain words. Explain any technical step a non-technical person has to do.
- Test shell scripts before committing (see the Verify section in `plugins/github-ready/reference/checklist.md` for the pattern).

## Git rules

- Never work on `main`. Start every change on a branch: `feat/short-name`, `fix/short-name` or `chore/short-name`.
- Small commits with plain messages that say what changed and why.
- When the work is done and checked, push the branch and open a pull request with `gh pr create --fill`. In cloud sessions, where that fails, use `gh api repos/OWNER/NAME/pulls -f title=... -f head=BRANCH -f base=main -f body=...`. Merging happens on GitHub with Squash and merge.
- Never commit secrets. Keys and passwords live in `.env`, which git ignores. If you add a new setting, add its name (not its value) to `.env.example`.
- Never force-push, rewrite history, or use `--no-verify`. If a safety hook blocks something, fix the cause and tell me what it was.
- After a pull request is merged: `git switch main && git pull`, then start the next branch.
- Explain git steps to me in plain words. I may not know the terms.
