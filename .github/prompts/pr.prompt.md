---
agent: 'agent'
tools: ['#runInTerminal', '#readFile', '#editFiles']
description: 'Push branch and create PR that closes an issue'
---

# Create Pull Request

## Your Task

1. **Pre-flight checks**
   - Run `git status --short` - working directory must be clean
   - If uncommitted changes exist, ask user to commit first

2. **Run verification (if package.json exists)**
   ```bash
   npm run lint 2>nul || echo lint-skipped
   npm run build 2>nul || echo build-skipped
   ```
   - If checks fail, STOP and report errors

3. **Rebase on latest main**
   ```bash
   git fetch origin
   git rebase origin/main
   ```

4. **Push to origin**
   ```bash
   git push -u origin HEAD
   ```

5. **Check for PR template**
   - Look for `pull_request_template.md` or `PULL_REQUEST_TEMPLATE.md` in repo root
   - Look for `.github/PULL_REQUEST_TEMPLATE.md`
   - If found, use the template structure
   - If not found, use: `Closes #<issue_number>`

6. **Create PR**
   - Extract issue number from branch name (digits before first `-`)
   ```bash
   gh pr create --title "${input:prTitle}" --body "<body>"
   ```

7. **Update issue labels**
   ```bash
   gh issue edit <issue_number> --remove-label "in-progress" --add-label "in-review"
   ```

8. **Report** - Show PR URL and confirm labels updated

## PR Title Format

`{issue_number}: {brief description}` (e.g., `4: Add user authentication`)

**CRITICAL**: Do NOT add AI attribution to PR descriptions.
