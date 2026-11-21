---
name: audit
description: Check an existing project's git and GitHub setup (branches, merge rules, leaked secrets, safety rules for Claude), report in plain words, and fix what the person approves. Run with /github-ready:audit.
disable-model-invocation: true
---

# github-ready: audit an existing project

Check a project that is already in git, show a plain pass/fail report, then fix only what the person approves, on a branch, through a pull request.

Shared material lives in the plugin folder, two levels up from this file:
- `../../reference/checklist.md`: every check, what it means in plain words, and how to test it
- `../../reference/gitignore-patterns.md`: `.gitignore` building blocks
- `../../templates/`: the files used for fixes

Read `checklist.md` before you start.

## How to talk to the person

The person may know nothing about git. Use plain words, no jargon. Explain any git word you must use in one short sentence. Lead with what matters most: a leaked secret comes before a missing template.

## Step 1: Check the machine and the repo

```bash
git --version
gh auth status
git rev-parse --show-toplevel
git remote get-url origin
git status --short
git branch --show-current
```

- Not a git repo: say so and suggest `/github-ready:new` instead. Stop.
- No GitHub remote: run the local checks only and note that the GitHub checks were skipped.
- Uncommitted changes: tell them. Don't touch their files until those are committed or they say go ahead.
- Work out OWNER/NAME from the remote. Check visibility and plan: `gh api repos/OWNER/NAME --jq '{private, visibility, permissions}'`.

## Step 2: Run every check (read-only)

Run the checks in `checklist.md`, sections A to E. Change nothing in this step.

The full-history secret scan matters most. Use gitleaks if it's installed (`gitleaks git --redact -v`, or `gitleaks detect --redact -v` on older versions). Otherwise use the git log grep in `checklist.md`. Never print a found secret in full: show the file, the commit, and the first four characters.

## Step 3: Report

Show a table: check, result, what it means. Then a short "fix first" list.

- ✅ fine
- ⚠️ not possible on a free plan for private repos, with what covers it instead
- ❌ missing or wrong

If a secret is in the git history, put it at the very top:

> A key for X was committed on [date] in [file]. Deleting it now doesn't remove it from history. Anyone who has ever had access to this repo could have it. **Change the key at X first**: make a new one, update it wherever the project uses it, delete the old one. That's the real fix. Scrubbing git history is optional, risky, and needs everyone to re-download the repo, so don't do it without a separate decision.

Never rewrite history or force-push as part of this skill.

## Step 4: Ask what to fix

One AskUserQuestion call, multi-select, listing each ❌ and ⚠️ item that can be fixed, in plain words. Recommend all of them.

## Step 5: Fix on a branch

```bash
git switch main && git pull
git switch -c chore/github-ready
```

Apply the approved fixes. Use the same files and steps as `/github-ready:new`, Step 4 and Step 7 (`../new/SKILL.md`). For existing files, always merge rather than overwrite: add what's missing and keep the rest. For `.claude/settings.json`, add the deny rules and hooks next to whatever is already there.

Switch the hooks on for this clone:

```bash
git config core.hooksPath .githooks
```

If secret files are tracked (like a committed `.env`), add them to `.gitignore` and stop tracking them with `git rm --cached <file>`. That keeps the file on disk. Tell them the key inside still needs changing if it was ever pushed.

Commit, push the branch, and open a pull request:

```bash
git add -A
git commit -m "Set up git safety rules and checks"
git push -u origin chore/github-ready
gh pr create --fill
```

If `gh pr create` fails (it does in cloud sessions from the phone or web), use the REST API instead: `gh api repos/OWNER/NAME/pulls -f title='...' -f head='BRANCH' -f base=main -f body='...'`.

GitHub settings changes (squash merges, Dependabot, branch protection) apply to the repo directly. Say which ones you're about to change and wait for a yes before running them.

## Step 6: Prove it works

Run the "Verify" tests in `checklist.md`. Clean up anything a test creates.

## Step 7: Final report

Same format as Step 3, now showing what changed, each with its proof. Give the pull request link and say: "Have a look, then merge it on GitHub with Squash and merge."

## Never

- Print a full secret
- Rewrite history, force-push, or push to `main`
- Use `--no-verify`
- Overwrite a file without asking
- Change GitHub settings without a yes
- Claim something is protected without a test that proves it
