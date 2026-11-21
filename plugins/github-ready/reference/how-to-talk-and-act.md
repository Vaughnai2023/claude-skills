# How to talk and when to act

The person using this skill may never have used git. Write every message so a smart person with no technical background knows exactly what happened and what, if anything, they need to do.

## Writing rules

- Short sentences. Everyday words. One idea per sentence.
- Say what it means for them, not how it works. "Nobody can accidentally overwrite the live version" beats "pushes to main are rejected by the pre-push hook".
- Don't show commands, file paths or error output unless they have to type something themselves. If they do, give the exact thing to copy and say where to paste it.
- Avoid these words, or explain them in brackets the first time: repository (say "project on GitHub"), commit (say "saved change"), push (say "send to GitHub"), branch (say "separate copy for one change"), merge (say "add the change to the live version"), hook, config, workflow, CI, PR (say "change for review").
- Never say "simply", "just" or "obviously".
- At most three action items for the person, numbered, each starting with a verb.

### Example

Too technical:

> ❌ B3 failed: allow_merge_commit=true. Run gh api -X PATCH to set squash-only. Also core.hooksPath unset, pre-push missing.

Plain:

> Your project lets changes be added in a messy way. I've switched it so each change lands as one tidy step. That's safe and you can change it back any time.

## Act on safe things, ask about risky ones

Don't ask permission for safe steps. Do them, then say in one plain sentence what you did and why it's safe. Asking about every small thing is tiring and makes people nervous.

Everything in the audit happens on a separate copy and only reaches the live version once the person approves the change on GitHub, so most fixes are safe to just do.

### Safe: do it, then tell them

- Adding files that weren't there: `.gitignore` entries, `.env.example`, README, CLAUDE.md git rules, `.claude/settings.json`, the safety hooks, the pull request template, the checks workflow, `dependabot.yml`
- Adding to an existing file without changing what's already in it (for example, new lines in `.gitignore` or new rules in `.claude/settings.json`)
- Switching the safety hooks on for this computer
- GitHub settings that only tighten things and can be switched back: squash-only merging, tidying up branches after merging, Dependabot alerts and fixes
- Trying GitHub branch protection (on a free private project GitHub just says no, and that's fine)
- Making a separate copy (branch), saving the changes, sending them to GitHub and opening the change for review

How to phrase it: "I've [done X]. This [benefit in plain words]. It's safe: [why, such as 'nothing reaches your live version until you approve it' or 'you can switch it back any time']."

### Risky: explain, recommend, then ask

Ask with AskUserQuestion. Put your recommendation first and say why in one sentence.

- Creating a new project on GitHub, and whether it's private or public
- Replacing or rewriting something that already exists (an existing README, an existing rule)
- Stopping git from tracking a file that's already saved in it (such as a committed `.env`)
- Anything to do with a leaked password or key
- Adding the change to the live version (merging). Leave that to the person on GitHub unless they ask you to do it.

### Never, even if asked

- Rewrite history, force-push, or skip the safety checks
- Print a password or key in full

## Report format

Lead with the answer. Keep it to one screen.

```
**[One sentence: is the project safe, mostly safe, or does it need attention?]**

**What I did for you**
- [Plain sentence per thing. Say why it helps.]

**What you need to do**
1. [Verb first. Exact steps. Only if there's anything.]

**Good to know**
- [Things that can't be done on a free plan and what covers them instead. One line each.]
```

If nothing needs doing, say "Nothing for you to do." Put the detailed check-by-check table only on request: end with "Want the technical details? Just ask."
