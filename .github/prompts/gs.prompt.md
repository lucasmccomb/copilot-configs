---
agent: 'agent'
tools: ['#runInTerminal']
description: 'Show git status and project info (branch, PRs, issues)'
---

# Git Status & Project Info

## Your Task

Run these commands and summarize the results:

1. **Branch and sync status**
   ```bash
   git branch --show-current
   git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>nul || echo "no upstream"
   git rev-list --count @{u}..HEAD 2>nul || echo "unknown"
   git rev-list --count HEAD..@{u} 2>nul || echo "unknown"
   ```

2. **Working directory**
   ```bash
   git status --short
   ```

3. **Recent commits**
   ```bash
   git log --oneline -5
   ```

4. **Open PRs**
   ```bash
   gh pr list --limit 10
   ```

## Summary Format

- Current branch and whether the working directory is clean or dirty
- Whether the branch is ahead/behind remote
- Any open PRs with numbers and titles
- Brief description of uncommitted changes (if any)
- Recommended next action (push, pull, rebase, etc.)
