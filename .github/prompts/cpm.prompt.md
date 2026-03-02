---
agent: 'agent'
tools: ['#runInTerminal', '#readFile']
description: 'Commit, PR, Merge - one-shot workflow'
---

# /cpm - Commit, PR, Merge

One-shot workflow: commit all changes, create a PR, merge it, close the issue, and rebase on main.

## Instructions

Execute these steps sequentially. Do NOT skip steps or proceed if a step fails.

### Phase 1: Pre-flight

1. Run `git status` to confirm there are changes
2. Run `git diff --stat` to see what changed
3. Extract issue number from current branch name (leading digits before first `-`)
4. Run `git log --oneline -5` for recent commit style

If no changes and no unpushed commits, stop: "Nothing to commit or push."

### Phase 2: Commit

1. Stage changed files with `git add` (prefer specific files; never stage `.env`)
2. Commit: `{issue-number}: {concise description}`
3. Do NOT add any AI attribution

### Phase 3: Push & Create PR

1. Push: `git push -u origin HEAD`
2. Check for PR template at `.github/PULL_REQUEST_TEMPLATE.md`
3. Create PR with `gh pr create`:
   - Title: `{issue-number}: {concise description}`
   - Body: Use template if found, include `Closes #{issue-number}`

### Phase 4: Merge

1. `gh pr merge --squash --delete-branch`
2. Confirm merge succeeded

### Phase 5: Close Issue

1. Verify auto-close: `gh issue view {issue-number} --json state`
2. If still open: `gh issue close {issue-number}`

### Phase 6: Rebase on Main

1. `git checkout main`
2. `git fetch origin`
3. `git reset --hard origin/main`
4. `git status` to confirm clean

### Phase 7: Report

```
## Completed

- **Issue**: #{issue-number} - {title}
- **PR**: {URL} (merged)
- **Commit**: {SHA} - {message}
- **Branch**: Deleted, now on `main`
- **Status**: Clean, up to date
```
