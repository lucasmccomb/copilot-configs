---
agent: 'agent'
tools: ['#runInTerminal']
description: 'Create a new GitHub issue with proper labels'
---

# Create GitHub Issue

## Your Task

1. **Gather issue details** (if not provided via ${input:issueTitle})

   Ask the user:
   - Title: Brief description of the issue
   - Type: feature, bug, refactor, or human-agent
   - Description: More details about what needs to be done

2. **Determine labels**

   Based on issue type:
   - `feature` -> `enhancement`
   - `bug` -> `bug`
   - `refactor` -> `chore`
   - `human-agent` -> `human-agent` (assign to @{{GITHUB_USERNAME}})

3. **Create the issue**

   ```bash
   gh issue create --title "<title>" --body "<description>" --label "<labels>"
   ```

   If human-agent:
   ```bash
   gh issue create --title "<title>" --body "<description>" --label "human-agent" --assignee "{{GITHUB_USERNAME}}"
   ```

4. **Report result** - Show issue number and URL

## Issue Title Format

Good titles:
- "Add user authentication flow"
- "Fix calendar grid alignment on mobile"
- "Refactor habit service for better error handling"
