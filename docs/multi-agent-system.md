# Multi-Agent System

> **Note**: Translated from Claude Code's `~/.claude/multi-agent-system.md` for use with Copilot on Windows.
> This system works identically with any AI coding assistant. The coordination is git-based, not tool-specific.

## Overview

Multiple AI agents work on the same repository in parallel using independent clones.
Each agent runs in its own clone with full git isolation - independent branches, independent PRs.

## Directory Structure

```
C:\code\{repo}-repos\
  {repo}-0\       # Clone 0 (agent-0)
  {repo}-1\       # Clone 1 (agent-1)
  {repo}-2\       # Clone 2 (agent-2)
  {repo}-3\       # Clone 3 (agent-3)
```

Each clone is a full, independent git repository.

### Setup Commands (Git Bash)

```bash
REPO="my-repo"
GITHUB_USER="{{GITHUB_USERNAME}}"
AGENT_COUNT=4

mkdir -p ~/code/${REPO}-repos
for i in $(seq 0 $((AGENT_COUNT - 1))); do
  git clone git@github.com:${GITHUB_USER}/${REPO}.git ~/code/${REPO}-repos/${REPO}-${i}
  git -C ~/code/${REPO}-repos/${REPO}-${i} checkout -b agent-${i} origin/main
done
```

### Agent Labels (create once per repo)

```bash
for i in 0 1 2 3; do
  gh label create "agent-${i}" --description "Being worked on by agent-${i}"
done
```

## Agent Identity

Derived from the working directory name suffix:
- `my-repo-0` or `my-repo` -> agent-0
- `my-repo-1` -> agent-1, etc.

## Claiming Issues

Before writing any code:

1. **Check GitHub labels** - skip if any `agent-*` or `in-progress` label exists:
   ```bash
   gh issue view {number} --json labels --jq "[.labels[].name]"
   ```

2. **Check sibling clone branches** - skip if any clone has a branch starting with `{issue-number}-`:
   ```bash
   for dir in ~/code/{repo}-repos/{repo}-*; do
     echo "$(basename $dir): $(git -C $dir branch --show-current 2>/dev/null)"
   done
   ```

3. **Label the issue immediately** (before creating a branch):
   ```bash
   gh issue edit {number} --add-label "in-progress" --add-label "agent-{N}"
   ```

4. **Verify labels applied**:
   ```bash
   gh issue view {number} --json labels --jq "[.labels[].name]"
   ```

Do NOT create a branch or start coding until labels are confirmed.

## When Finishing an Issue

```bash
gh issue edit {number} --remove-label "agent-{N}"
gh issue close {number} --comment "Completed: {summary}"
gh issue edit {number} --remove-label "in-progress"
```

## Git Workflow

- **Branch from origin/main**: `git checkout -b {issue}-{desc} origin/main`
- **After PR merge**: `git fetch origin && git checkout agent-{N} && git reset --hard origin/main`
- **Each clone fetches independently**
- **npm install is per-clone**
- **Env files are per-clone** (.env must be copied individually)

## Session Logs

All agents write to `~/code/{{LOG_REPO_NAME}}/{repo-name}/YYYYMMDD/agent-N.md`.
See `docs/log-system.md` for full protocol.

## Conflict Resolution

If two agents claim the same issue:
1. Human supervisor resolves
2. One agent releases (removes label)
3. Work continues with clear ownership
