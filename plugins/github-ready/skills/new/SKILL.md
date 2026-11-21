---
name: new
description: Start a brand-new project on GitHub with branches, merge rules, secret checks and safety rules for Claude already in place. Run with /github-ready:new.
disable-model-invocation: true
---

# github-ready: new project

Set up a new project so it is safe from day one: git, a private GitHub repo, a branch-and-pull-request flow, secret checks, and rules that stop Claude doing anything risky. End with a test that proves the protections work.

Shared material lives in the plugin folder, two levels up from this file:
- `../../reference/checklist.md`: every check, what it means in plain words, and how to test it
- `../../reference/gitignore-patterns.md`: `.gitignore` building blocks
- `../../templates/`: files you copy into the project

Read `checklist.md` before you start.

## How to talk to the person

The person may know nothing about git. Use plain words, no jargon. When a git word is unavoidable (branch, commit, pull request), explain it in one short sentence the first time. Ask one thing at a time. Before anything that changes GitHub, say what will happen and wait for a yes.

## Step 1: Check the machine

Run `git --version` and `gh auth status`.

- No git: tell them to install it (on a Mac, running `xcode-select --install` in Terminal installs it). Stop.
- No gh, or not logged in: offer to help. On a Mac with Homebrew: `brew install gh`, then `gh auth login` (they choose GitHub.com, HTTPS, log in with a browser), then `gh auth setup-git`. Stop until this works.
- Note the logged-in GitHub username. That account will own the repo unless they choose an organisation in Step 2.

## Step 2: Ask the setup questions

Use one AskUserQuestion call:

1. **Project name**: lowercase with dashes, such as `booking-portal`. Suggest one from the folder name.
2. **Owner**: their own account, or one of their organisations (list them with `gh api user/orgs --jq '.[].login'`). If they want it under a different personal account they can't log in as here, explain that this account has to create the repo and add them as a collaborator, then stop and help with that instead.
3. **Who can see it**: Private (default) or Public.
4. **What it is**: web app, script or automation, a set of files to back up, or something else. This decides the `.gitignore` and README.

## Step 3: Look at the folder

- Work out the tech stack from files such as `package.json`, `requirements.txt` or `pyproject.toml`, `docker-compose.yml`.
- Look for secret files: `.env*` (not `.env.example`), `*.pem`, `*.key`, `*.p12`, `id_rsa`, `serviceAccountKey.json`, and names containing `credential` or `secret`.
- Grep config and code for keys and tokens (patterns are in `checklist.md`).
- If you find any, list them and confirm they will be kept out of git. If unsure whether something is secret, ask.

## Step 4: Write the files

Never overwrite an existing file without asking. If a file exists, show what you'd add and merge with their yes.

1. `.gitignore` from `gitignore-patterns.md`: OS and editor sections always, the stack's section, every secret file found.
2. `.env.example` if there is a `.env`: variable names only, placeholder values. Never copy real values.
3. `README.md`: what it is, how to run it, the environment variables (names only), and how to work on it (branch, pull request, merge). Short and plain.
4. `CLAUDE.md`: if missing, create it with a one-line description of the project. Then append the contents of `templates/CLAUDE-git-rules.md`.
5. `.claude/settings.json` from `templates/claude-settings.json`. If one exists, merge: add the deny rules and hooks, keep everything already there.
6. `.claude/hooks/guard-git.sh` from `templates/guard-git.sh`.
7. `.githooks/pre-commit` and `.githooks/pre-push` from `templates/`. Make all three scripts executable with `chmod +x`.
8. `.github/pull_request_template.md` from `templates/pull_request_template.md`.
9. `.github/workflows/checks.yml` from `templates/checks.yml`. Keep the secrets job. Adapt the tests job to the stack (the template is for Node; for Python use setup-python and pytest; remove it if there is nothing to test yet and say so).
10. `.github/dependabot.yml` from `templates/dependabot.yml`, with the ecosystems this project uses.

## Step 5: First commit

```bash
git init -b main          # only if there is no .git yet
git config core.hooksPath .githooks
git add -A
git status
```

Show `git status` and point out anything unexpected. Then make the first commit. The pre-commit hook blocks commits on `main`; the very first commit is the one allowed exception:

```bash
ALLOW_MAIN_COMMIT=1 git commit -m "Initial commit"
```

The secret check still runs. If it fails, fix it. Never use `--no-verify`.

## Step 6: Create the GitHub repo

Say exactly what will happen ("This creates a private repo called X under Y and uploads the first commit"), then wait for a yes.

```bash
ALLOW_MAIN_PUSH=1 gh repo create OWNER/NAME --private --source=. --push
```

Use `--public` if they chose Public. This first push to `main` is the only one ever allowed.

## Step 7: GitHub settings

Run each and note pass or fail for the report:

```bash
# Only squash merges, and tidy up branches after merging
gh api -X PATCH repos/OWNER/NAME -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false -F delete_branch_on_merge=true
# Warnings about vulnerable packages, and automatic fix pull requests
gh api -X PUT repos/OWNER/NAME/vulnerability-alerts
gh api -X PUT repos/OWNER/NAME/automated-security-fixes
```

Branch protection: try it with the command in `checklist.md`. On a free account it only works on public repos. If GitHub refuses, do not treat it as an error. Explain: "GitHub only enforces this on paid plans for private repos, so your Mac does the enforcing instead: the safety hooks block pushes to main and force-pushes."

## Step 8: Work on a branch from now on

```bash
git switch -c feat/first-feature
```

Explain the daily flow in four lines: make a branch, do the work, open a pull request, squash-merge it on GitHub.

## Step 9: Prove it works

Run every test in the "Verify" section of `checklist.md`. These test the protections without touching GitHub. Clean up anything a test creates.

## Step 10: Report

Show a short report. One line per item, plain words. Mark each item:

- ✅ working, with proof (the test that passed)
- ⚠️ not possible on this plan, with what covers it instead
- ❌ failed, with what to do

End with two next steps:
- For phone and cloud work, install the Claude GitHub App on this repo: github.com/apps/claude, then Configure, and add the repo (skip if it's already on "All repositories").
- The safety hooks switch on by themselves in Claude Code sessions. Anyone working on this repo without Claude should run `git config core.hooksPath .githooks` once after cloning.

## Never

- Commit or push a secret
- Push to `main` after the first push, or force-push, ever
- Use `--no-verify`
- Overwrite a file without asking
- Create anything on GitHub without a yes
- Claim something is protected without a test that proves it
