---
name: audit
description: Check an existing project's git and GitHub setup (branches, merge rules, leaked secrets, safety rules for Claude), report in plain words, and fix what the person approves. Run with /github-ready:audit.
disable-model-invocation: true
---

# github-ready: audit an existing project

Check a project that is already in git, show a plain pass/fail report, then fix only what the person approves, on a branch, through a pull request.

Shared material lives in the plugin folder, two levels up from this file:
- `../../reference/how-to-talk-and-act.md`: how to write for a non-technical person, which steps to just do and which to ask about
- `../../reference/checklist.md`: every check, what it means in plain words, and how to test it
- `../../reference/gitignore-patterns.md`: `.gitignore` building blocks
- `../../templates/`: the files used for fixes

Read both reference files before you start.

## How to talk and when to act

Read `../../reference/how-to-talk-and-act.md` first and follow it for every message. In short: write for someone who has never used git, do the safe steps without asking (then say what you did and why it's safe), and only ask about the risky ones, with your recommendation first.

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

## Step 3: Sort what you found

Don't show the person a report yet. Sort each failed check into:

- **Safe to fix**: everything on the "Safe" list in `how-to-talk-and-act.md`. You'll fix these in Step 5 without asking.
- **Needs a decision**: everything on the "Risky" list.

If a secret is in the git history, this outranks everything else. Tell the person straight away, in plain words:

> I found a password or key for [service] saved in your project's history on [date], in [file]. Deleting it now doesn't remove it from the history, so anyone who's had access to this project could have it. **The fix is to change the key at [service]:** make a new one, put it where the project uses it, and delete the old one. I can walk you through that.

Never offer to rewrite history as part of this skill.

## Step 4: Ask only about the risky items

If there are items that need a decision, ask about them in one AskUserQuestion call. For each one, say what it is in plain words, what you recommend, and why. If there's nothing risky, skip this step and don't mention it.

## Step 5: Fix on a branch

```bash
git switch main && git pull
git switch -c chore/github-ready
```

Fix everything on the safe list, plus the risky items the person said yes to. Use the same files and steps as `/github-ready:new`, Step 4 and Step 7 (`../new/SKILL.md`). For existing files, always merge rather than overwrite: add what's missing and keep the rest. For `.claude/settings.json`, add the deny rules and hooks next to whatever is already there.

Switch the hooks on for this clone:

```bash
git config core.hooksPath .githooks
```

If secret files are tracked (like a committed `.env`) and the person said yes in Step 4, add them to `.gitignore` and stop tracking them with `git rm --cached <file>`. That keeps the file on disk. Tell them the key inside still needs changing if it was ever pushed.

Commit, push the branch, and open a pull request:

```bash
git add -A
git commit -m "Set up git safety rules and checks"
git push -u origin chore/github-ready
gh pr create --fill
```

If `gh pr create` fails (it does in cloud sessions from the phone or web), use the REST API instead: `gh api repos/OWNER/NAME/pulls -f title='...' -f head='BRANCH' -f base=main -f body='...'`.

Then apply the GitHub settings that are on the safe list (squash-only merging, tidying branches after merging, Dependabot). They only tighten things and can be switched back, so don't ask first.

## Step 6: Prove it works

Run the "Verify" tests in `checklist.md`. Clean up anything a test creates.

## Step 7: Report

Use the report format in `how-to-talk-and-act.md`: one-sentence verdict, what you did for them, what they need to do (at most three steps), good to know. Base every "done" on a passing test from Step 6.

The last action for the person is usually approving the change on GitHub. Give the link and say: "Open this link, check it looks right, then click the green **Squash and merge** button and **Confirm**."

## Never

- Print a full secret
- Rewrite history, force-push, or push to `main`
- Use `--no-verify`
- Overwrite a file without asking
- Change a GitHub setting that isn't on the safe list without a yes
- Claim something is protected without a test that proves it
