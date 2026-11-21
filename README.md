# Vaughn's Claude skills

Skills for Claude Code that you install once and keep up to date from this repo.

| Skill | What it does | Type this in Claude |
|---|---|---|
| github-ready: new | Starts a new project on GitHub with safety rules already in place | `/github-ready:new` |
| github-ready: audit | Checks an existing project and fixes what's missing | `/github-ready:audit` |

---

## Install (one time)

Open the Claude desktop app, click the **Code** tab, start a new session (pick any folder), and paste this message:

```
Please install Vaughn's Claude skills on this computer for me. I'm not technical, so do everything you can yourself, explain each step in plain words, and only ask me when you need me to click something.

1. Make sure git is installed. If it isn't, install it.
2. Make sure the claude command works in the terminal. If it doesn't, install the Claude Code command-line tool using the official instructions at code.claude.com.
3. Run: claude plugin marketplace add Vaughnai2023/claude-skills
4. Run: claude plugin install github-ready@vaughn-skills
5. Tell me it's done, and that from now on, when Vaughn says he's updated something, I just say "Update Vaughn's skills" in a Code session.
```

Claude does the rest. No GitHub account needed. When it's done, start a new session and type `/github-ready:` to see the skills.

---

## Getting Vaughn's updates

Ask Claude: **"Update Vaughn's skills."** It runs:

```bash
claude plugin marketplace update vaughn-skills
claude plugin update github-ready@vaughn-skills
```

Then start a new session.

To get updates automatically instead: in Claude Code in the terminal, type `/plugin`, go to **Marketplaces**, choose **vaughn-skills**, then **Enable auto-update**.

---

## How github-ready keeps a project safe

Every project it sets up works the same way:

1. **`main` is the live version.** Nobody, including Claude, saves changes straight onto it.
2. **Work happens on a branch**, which is a separate copy for one change, such as `feat/booking-reminders`.
3. **A pull request** shows the change on GitHub. Checks run automatically: a secret scan, plus tests if there are any.
4. **Squash and merge** turns the pull request into one tidy change on `main`, and GitHub deletes the branch.

Safety rules on every project:

- Passwords and API keys can't be committed. They live in `.env`, which never goes to GitHub.
- Claude can't force-push, delete work, skip the checks, or read `.env`.
- Pushing straight to `main` is blocked.

**About free GitHub accounts:** GitHub only enforces branch rules itself on public repos or paid plans. On free private repos, the computer does the enforcing instead, through hooks that switch on automatically in Claude Code. The skill tells you which applies to each project.

---

## For Vaughn: adding and updating skills

```
.claude-plugin/marketplace.json   the catalogue: one entry per plugin
plugins/<name>/                   one folder per plugin
  .claude-plugin/plugin.json
  skills/<skill>/SKILL.md
```

**Update a skill:** edit it on a branch, run `claude plugin validate .`, open a pull request, merge. People get the change next time they update. Leave out the `version` field so updates follow the latest commit.

**Add a skill:** make a new folder under `plugins/` (copy `github-ready` as a starting point), add an entry to `marketplace.json`, validate, pull request, merge.

**Move an existing skill** from `~/.claude/skills/<name>`: create `plugins/<name>/.claude-plugin/plugin.json`, copy the skill folder into `plugins/<name>/skills/<name>/`, and add the catalogue entry. Once installed this way, it's typed as `/<name>:<name>`, so consider shorter skill names inside the plugin.

**Share it with someone:** send them the install section above. The repo is public, so they don't need a GitHub account or an invite.

**Keep it public-safe:** this repo is public. Nothing personal, nothing about clients, no keys. Private skills go in their own private repo. See `CLAUDE.md` for the full list.
