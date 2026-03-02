---
agent: 'agent'
tools: ['#runInTerminal']
description: 'Fetch origin and rebase current branch on main'
---

# Sync with Main

## Your Task

1. **Check for uncommitted changes**
   ```bash
   git status --short
   ```
   - If dirty, ask user: stash, commit, or abort

2. **Fetch latest from origin**
   ```bash
   git fetch origin
   ```

3. **Rebase on main**
   ```bash
   git rebase origin/main
   ```

4. **Handle conflicts if any**
   - List conflicting files
   - Help resolve
   - After resolution: `git rebase --continue`

5. **Report result**
   - Show ahead/behind count after sync
   - If stashed, remind to `git stash pop`
   - Note: force push needed if branch was already pushed: `git push --force-with-lease`
