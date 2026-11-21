# github-ready checklist

The checks both skills use. Each one has the plain-words reason, how to check it, and the fix.

## Why some of this lives on the computer, not GitHub

On a free GitHub account, branch protection, rulesets and GitHub's own secret scanning only work on **public** repos. For private repos on a free plan, the same protection comes from:

- `.githooks/pre-commit`: blocks commits straight onto `main` and blocks secrets
- `.githooks/pre-push`: blocks pushes to `main` and force-pushes
- `.claude/hooks/guard-git.sh` and the deny rules in `.claude/settings.json`: stop Claude from trying any of that
- `.github/workflows/checks.yml`: scans every pull request for secrets on GitHub's side

Hooks only run where they're switched on. Claude Code switches them on by itself through the SessionStart hook. People working without Claude run `git config core.hooksPath .githooks` once per clone. This protects against Claude and honest mistakes. It does not stop a collaborator who deliberately turns the hooks off; only a paid plan or a public repo gives that.

## A. Secrets

| Check | Plain words | How |
|---|---|---|
| A1 Secret files ignored | `.env` and key files must never go to GitHub | `.gitignore` covers `.env`, `.env.*` (but not `.env.example`), `*.pem`, `*.key`, `*.p12`, `id_rsa*` |
| A2 No secret files tracked | Checks nothing slipped in already | `git ls-files \| grep -E '(^\|/)(\.env(\..+)?\|.*\.pem\|.*\.p12\|.*\.key\|id_rsa.*\|serviceAccountKey\.json)$' \| grep -vE '\.env\.(example\|sample\|template)$'` must print nothing |
| A3 No secrets in history | A deleted key is still in old commits | gitleaks (see the audit skill), or the grep below |
| A4 `.env.example` exists | Shows which settings are needed without the values | Present when the project uses `.env` |
| A5 Secret check before each commit | Catches keys before they're saved | `.githooks/pre-commit` present, executable, and `git config core.hooksPath` prints `.githooks` |

History grep (use when gitleaks isn't installed):

```bash
git log -p --all | grep -nE 'AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|sk-ant-[A-Za-z0-9_-]{20,}|sk-(proj-)?[A-Za-z0-9_-]{32,}|gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{40,}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|sk_live_[0-9a-zA-Z]{24,}' | cut -c1-120
```

Also check for any `.env` file that was ever committed: `git log --all --name-only --format= | grep -E '(^|/)\.env' | grep -vE '\.env\.(example|sample|template)$' | sort -u`

## B. Branches and merges

| Check | Plain words | How |
|---|---|---|
| B1 Main branch is `main` | One clear "live" branch | `gh api repos/OWNER/NAME --jq .default_branch` |
| B2 Work happens on branches | Changes go through a pull request, never straight to main | `.githooks/pre-commit` and `pre-push` present and executable |
| B3 Squash merge only | Each pull request becomes one tidy commit on main | `gh api repos/OWNER/NAME --jq '{allow_squash_merge,allow_merge_commit,allow_rebase_merge}'` should be true, false, false |
| B4 Branches tidied after merge | Old branches don't pile up | `gh api repos/OWNER/NAME --jq .delete_branch_on_merge` is true |
| B5 GitHub branch protection | GitHub itself refuses pushes to main | Public repos or paid plans only. Command below |

Branch protection (try it; on a free private repo GitHub answers 403 "Upgrade to GitHub Pro", which is expected):

```bash
gh api -X PUT repos/OWNER/NAME/branches/main/protection --input - <<'EOF'
{"required_status_checks":null,"enforce_admins":false,"required_pull_request_reviews":{"required_approving_review_count":0},"restrictions":null,"allow_force_pushes":false,"allow_deletions":false}
EOF
```

Branch names: `feat/short-name` for new things, `fix/short-name` for fixes, `chore/short-name` for tidying. Claude's cloud sessions use `claude/...`, which is fine.

## C. Claude safety rules

| Check | Plain words | How |
|---|---|---|
| C1 Deny rules | Claude can't force-push, wipe changes, skip checks, or read `.env` | `.claude/settings.json` has the `permissions.deny` list from `templates/claude-settings.json` |
| C2 Guard hook | Blocks risky git commands even if the rules are worded around | `.claude/hooks/guard-git.sh` present, executable, and wired as a PreToolUse hook on Bash |
| C3 Hooks switch on by themselves | The git hooks work in every Claude session, including cloud ones | SessionStart hook runs `git config core.hooksPath .githooks` |
| C4 Git rules in CLAUDE.md | Claude knows the branch, PR and secrets rules | `CLAUDE.md` contains the section from `templates/CLAUDE-git-rules.md` |
| C5 Claude GitHub App | Needed for phone and cloud sessions on private repos | Ask the person to check github.com/apps/claude → Configure. This can't be checked from the command line |

## D. GitHub extras

| Check | Plain words | How |
|---|---|---|
| D1 Pull request template | Every PR explains what changed and how it was tested | `.github/pull_request_template.md` |
| D2 Checks on every PR | GitHub scans for secrets and runs tests on each PR | `.github/workflows/checks.yml` |
| D3 Dependabot alerts | Warnings about packages with known security holes | `gh api repos/OWNER/NAME/vulnerability-alerts` returns 204 (404 means off) |
| D4 Dependabot updates | Automatic PRs that fix those packages | `.github/dependabot.yml` present |

Free private repos get 2,000 GitHub Actions minutes a month, which is plenty for these checks.

## E. Housekeeping

| Check | Plain words | How |
|---|---|---|
| E1 README | Says what it is and how to run it | `README.md` present and not empty |
| E2 `.gitignore` fits the stack | No `node_modules`, build output or OS junk in git | Compare with `gitignore-patterns.md` |
| E3 No huge files | Big files slow everything down | `git ls-files -z \| xargs -0 du -k 2>/dev/null \| sort -rn \| head -5`; warn above 10 MB |

## Verify

Run these after setting up. Each must give the result shown. Run them from the project root.

**V1. Claude's guard blocks a force-push** (expect exit code 2):

```bash
echo '{"tool_input":{"command":"git push --force origin feat/x"}}' | sh .claude/hooks/guard-git.sh; echo "exit $?"
```

**V2. Claude's guard blocks pushing to main** (expect exit code 2):

```bash
echo '{"tool_input":{"command":"git push origin main"}}' | sh .claude/hooks/guard-git.sh; echo "exit $?"
```

**V3. Claude's guard allows a normal branch push** (expect exit code 0):

```bash
echo '{"tool_input":{"command":"git push -u origin feat/main-menu"}}' | sh .claude/hooks/guard-git.sh; echo "exit $?"
```

**V4. The pre-push hook blocks main** (expect exit code 1):

```bash
z=0000000000000000000000000000000000000000; h=$(git rev-parse HEAD)
echo "refs/heads/x $h refs/heads/main $z" | sh .githooks/pre-push origin url; echo "exit $?"
```

**V5. The pre-commit hook blocks a secret** (expect exit code 1, then clean up):

```bash
git switch -c verify/secret-test
printf 'key = "AKIA%s"\n' "QWERTYUIOPASDFGH" > verify-secret.txt
git add verify-secret.txt
sh .githooks/pre-commit; echo "exit $?"
git rm -q --cached verify-secret.txt; rm verify-secret.txt
git switch - && git branch -D verify/secret-test
```

**V6. The pre-commit hook blocks commits on main** (expect exit code 1):

```bash
git switch main && sh .githooks/pre-commit; echo "exit $?"; git switch -
```

**V7. Settings file is valid JSON** (expect no error): `python3 -m json.tool .claude/settings.json > /dev/null && echo ok`

**V8. Hooks are switched on**: `git config core.hooksPath` prints `.githooks`.

**V9. GitHub settings** (when there's a remote): re-run the B3, B4 and D3 commands and confirm the values.
