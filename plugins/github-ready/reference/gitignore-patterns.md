# .gitignore building blocks

Always include OS, editor, secrets and logs. Add the stack sections that apply. Keep the section comments.

```gitignore
# === OS files ===
.DS_Store
Thumbs.db
desktop.ini

# === Editors ===
.vscode/*
!.vscode/extensions.json
.idea/
*.swp

# === Secrets (never commit) ===
.env
.env.*
!.env.example
!.env.sample
*.pem
*.key
*.p12
id_rsa*
id_ed25519*
serviceAccountKey.json

# === Claude Code (personal settings stay local) ===
.claude/settings.local.json
.claude/worktrees/

# === Logs and temp ===
*.log
npm-debug.log*
tmp/
.cache/
```

## Node / JavaScript / TypeScript

```gitignore
node_modules/
dist/
build/
.next/
out/
coverage/
.turbo/
.vercel/
*.tsbuildinfo
```

## Python

```gitignore
__pycache__/
*.py[cod]
.venv/
venv/
.pytest_cache/
.mypy_cache/
.ruff_cache/
*.egg-info/
```

## Supabase

```gitignore
supabase/.branches/
supabase/.temp/
```

## Docker / n8n

```gitignore
# Local data volumes
data/
volumes/
.n8n/
```

## Files and backups projects

```gitignore
~$*
*.tmp
```
