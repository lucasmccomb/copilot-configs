---
agent: 'agent'
tools: ['#runInTerminal', '#readFile', '#editFiles']
description: 'Session startup - check logs, git status, PRs, issues'
---

# Session Startup

Analyze the current state of the repository and provide a comprehensive overview.

## Your Task

### 1. Git Repository Check

Run `git rev-parse --is-inside-work-tree` to confirm this is a git repo. If not, inform the user and stop.

### 2. Session Log Setup

- Derive agent number from directory name suffix (e.g., `my-repo-1` -> agent-1, no suffix -> agent-0)
- Derive repo name from `git remote get-url origin`
- Pull latest logs: `cd ~/code/{{LOG_REPO_NAME}} && git pull --rebase`
- Check if today's log exists: `~/code/{{LOG_REPO_NAME}}/{repo-name}/YYYYMMDD/agent-N.md`
- If exists, read it for context
- If not, find the most recent log for this agent
- Read other agents' logs from today for cross-agent awareness
- Create today's log if it doesn't exist:
  - `mkdir -p ~/code/{{LOG_REPO_NAME}}/{repo-name}/YYYYMMDD`
  - Create `agent-N.md` with title: `# agent-N - YYYYMMDD - {repo-name}`

### 3. Git Status

```bash
git status
git branch --show-current
git rev-list --left-right --count origin/main...HEAD
```

### 4. Open PRs and Issues

```bash
gh pr list --limit 10
gh issue list --limit 20 --state open
gh issue list --label "in-progress" --state open
gh issue list --label "in-review" --state open
```

### 5. Dependency Check

If `package.json` exists and local is behind origin/main, run `npm install`.

### 6. Summary

Provide:
1. **Git Status** - branch, clean/dirty, ahead/behind
2. **Work Overview** - open PRs, in-progress issues, available issues
3. **Session Continuity** - what was done in previous session (from logs)
4. **Recommendation** - where to pick up work

Prioritize: unfinished work from logs > in-progress issues > open PRs > new issues
