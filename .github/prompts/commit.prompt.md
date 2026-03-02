---
agent: 'agent'
tools: ['#runInTerminal', '#readFile']
description: 'Stage all changes and commit with conventional format'
---

# Git Commit

## Your Task

1. **Check current state**
   - Run `git status --short` and `git diff --cached --stat` and `git diff --stat`
   - If there are no changes, inform the user and stop

2. **Run verification (if package.json exists)**
   ```bash
   npm run lint 2>nul || echo lint-skipped
   npm run build 2>nul || echo build-skipped
   ```
   - If lint or build fails, STOP and report the errors
   - Do NOT commit broken code

3. **Stage and commit**
   ```bash
   git add -A
   git commit -m "${input:commitMessage}"
   ```

4. **Report result**
   - Show the commit hash and message
   - Remind user to push when ready

## Commit Message Format

Expected: `{issue_number}: {brief description}`
- Example: `4: Add user authentication`
- Example: `12: Fix calendar alignment bug`

**CRITICAL**: Do NOT add any Co-Authored-By trailers or AI attribution.
