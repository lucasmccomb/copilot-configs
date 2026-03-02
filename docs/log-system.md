# Session Logging System

This document defines the session logging system for AI-assisted development, providing continuity between sessions, cross-agent visibility, and work tracking with git-backed history.

> **Note**: Translated from Claude Code's `~/.claude/log-system.md` for use with Copilot on Windows.
> All paths use Git Bash conventions (`~/code/...`). On Windows CMD/PowerShell, substitute `C:\code\...`.

## Purpose

- **Session continuity**: Pick up exactly where the previous session left off
- **Cross-agent visibility**: See what other agents are working on in real time
- **Context preservation**: Capture details that don't fit in git commits or issues
- **Work tracking**: Record completed work, blockers, and decisions made
- **Remote backup**: All logs are git-tracked with a GitHub remote

## Log Repository

**Location**: `~/code/{{LOG_REPO_NAME}}/` (Git Bash) or `C:\code\{{LOG_REPO_NAME}}\` (Windows)
**GitHub**: `{{GITHUB_USERNAME}}/{{LOG_REPO_NAME}}` (private)
**Branch**: Always `main` (no branching)

## Directory Structure

```
~/code/{{LOG_REPO_NAME}}/
  {repo-name}/
    YYYYMMDD/
      agent-0.md
      agent-1.md
      agent-2.md
  README.md
```

Each project has its own directory. Within each project, logs are organized by date subdirectories (ET timezone). Each agent writes exclusively to its own file.

## Agent Identity Derivation

Agent number is derived automatically from the working directory name:

```bash
AGENT_NUM=$(basename "$PWD" | grep -oE '[0-9]+$' || echo "0")
```

| Directory | Agent |
|-----------|-------|
| `lem-work-0` or `lem-work` | agent-0 |
| `lem-work-1` | agent-1 |
| `lem-work-N` | agent-N |

**Rule**: No suffix or suffix `-0` = agent-0. Any numeric suffix = that agent number.

## Repo Name Derivation

```bash
REPO_NAME=$(git remote get-url origin 2>/dev/null | xargs basename | sed 's/\.git$//')
```

## Log File Path

```
~/code/{{LOG_REPO_NAME}}/{repo-name}/YYYYMMDD/agent-N.md
```

**Example**: `~/code/{{LOG_REPO_NAME}}/my-project/20260302/agent-0.md`

## File Naming Convention

- **Date format**: `YYYYMMDD` (no dashes)
- **Timezone**: All dates/times are in ET (Eastern Time, America/New_York)
- **Agent file**: `agent-N.md` where N is the agent number

## Log File Title Format

```markdown
# agent-N - YYYYMMDD - {repo-name}
```

## Session Startup Protocol

1. **Pull latest logs**: `cd ~/code/{{LOG_REPO_NAME}} && git pull --rebase`
2. **Derive identity**: Agent number and repo name
3. **Check for today's log**: `~/code/{{LOG_REPO_NAME}}/{repo-name}/YYYYMMDD/agent-N.md`
4. **Read context**:
   - If today's log exists, read it
   - If not, find most recent log for this agent
   - Also read other agents' logs from today
5. **Create today's log** if it doesn't exist:
   - `mkdir -p ~/code/{{LOG_REPO_NAME}}/{repo-name}/YYYYMMDD`
   - Create agent file with Session Start entry

## During Session Protocol

Update your agent's log throughout the session with:
- Work completed (issue numbers, PRs, branches)
- Decisions made and rationale
- Blockers encountered
- Files modified or created
- Codebase-specific insights surfaced during work
- Next steps / recommendations

## Log Repo Commit Protocol

```bash
cd ~/code/{{LOG_REPO_NAME}}
git add -A
git commit -m "agent-N: {repo-name} update"
git pull --rebase
git push
```

**When to commit**: After PR merge, issue close, session end, or every ~30 minutes.

## Log File Template

```markdown
# agent-N - YYYYMMDD - {repo-name}

> [Optional: Continued from previous session (YYYYMMDD)]

## Session Start
- **Time**: HH:MM ET
- **Branch**: `main`
- **State**: Clean / dirty / in-progress on #XX

## Work

### Issue #XX: [Title] #status
- **Branch**: `XX-branch-name`
- **PR**: #YY
- **Status**: completed / in-progress / blocked
- **Summary**: [what was done]
- **Files**: [key files changed]
- **Insights**: [codebase knowledge surfaced]

## Session End
- **Time**: HH:MM ET
- **Next steps**: [recommendations]
```

## Tags

- `#completed` - Work finished
- `#in-progress` - Work ongoing
- `#blocked` - Waiting on something
- `#decision` - Important decision made
- `#todo` - Task identified for future

## Mandatory Log Triggers

Update the log immediately at each point:

1. **After every git commit** - issue number, branch, what changed
2. **After creating a PR** - issue number, PR URL, mark `#in-review`
3. **After PR merge** - mark `#completed`, commit/push log repo
4. **After closing an issue** - resolution, mark `#completed`
5. **Before ending a session** - current WIP, uncommitted changes, next step

## Recovery Protocol

If logging was skipped:
1. Reconstruct from git: `git log`, `gh pr list`, `gh issue list`
2. Update retroactively with approximate times
3. Add note: `> Note: Reconstructed from git history`
4. Resume normal logging
