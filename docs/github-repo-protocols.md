# GitHub Repo Protocols

> **Note**: Translated from Claude Code's `~/.claude/github-repo-protocols.md` for use with Copilot on Windows.

This file defines the full GitHub repository lifecycle: setup, planning, implementation, and conventions.

---

## 1. Repository Setup

### A. Create GitHub Repo

```bash
gh repo create {{GITHUB_USERNAME}}/{repo-name} --private
```

### B. Repo Settings

```bash
gh repo edit {{GITHUB_USERNAME}}/{repo-name} \
  --enable-squash-merge \
  --enable-rebase-merge \
  --disable-merge-commit \
  --enable-auto-merge \
  --delete-branch-on-merge \
  --no-enable-wiki
```

### C. Standard Labels

Delete defaults, then create:

```bash
# Status labels
gh label create "in-progress" --color "0e8a16" --description "Currently being worked on"
gh label create "in-review" --color "1d76db" --description "PR open, awaiting review"
gh label create "on-hold" --color "d93f0b" --description "Paused"
gh label create "blocked" --color "b60205" --description "Cannot proceed"

# Priority labels
gh label create "p0-critical" --color "b60205" --description "Drop everything"
gh label create "p1-high" --color "d93f0b" --description "Do next"
gh label create "p2-medium" --color "fbca04" --description "Normal priority"
gh label create "p3-low" --color "0e8a16" --description "Nice to have"

# Type labels
gh label create "bug" --color "d73a4a" --description "Something isn't working"
gh label create "enhancement" --color "a2eeef" --description "New feature or improvement"
gh label create "documentation" --color "0075ca" --description "Documentation changes"
gh label create "chore" --color "e4e669" --description "Maintenance, dependencies, config"

# Meta labels
gh label create "epic" --color "3e4b9e" --description "Tracking issue for a group of sub-issues"
gh label create "human-agent" --color "f9d0c4" --description "Requires manual human action"
```

### D. Initial Files

**README.md**, **CLAUDE.md** (or `.github/copilot-instructions.md`), **.gitignore**, **.github/PULL_REQUEST_TEMPLATE.md**

PR template:
```markdown
## Summary

<!-- What does this PR do? -->

## Changes

<!-- Key changes made -->

## Test Plan

<!-- How was this tested? -->

## Issue

Closes #
```

---

## 2. Planning & Issue Creation

**Every piece of work must have a GitHub issue before starting.**

### Workflow

```
1. Assess Scope -> 2. Plan (if needed) -> 3. Create Issue(s) -> 4. Implement
```

### Single Issue vs Epic

| Criteria | Single Issue | Epic + Sub-Issues |
|----------|--------------|-------------------|
| PRs needed | 1 | 2+ |
| Distinct components | Tightly coupled | Independent |
| Risk of large PR | Low | High (>500 lines) |
| Human-agent tasks | None | Any manual config |

### Human-Agent Issues

Create a `human-agent` issue whenever the plan requires:
- Setting environment variables or secrets
- Configuring external services
- Creating accounts or API keys
- Manual testing requiring human judgment

---

## 3. Implementation Workflow

### Step-by-step

1. **Find and understand** the issue
2. **Claim it**: `gh issue edit <number> --add-label "in-progress"`
3. **Create branch**: `git checkout -b {issue-number}-{description} origin/main`
4. **Implement** + write tests + run verification
5. **Commit**: `{issue_number}: {description}` (no AI attribution)
6. **Push + PR**: `git push -u origin HEAD` then `gh pr create`
7. **Merge**: `gh pr merge --squash --delete-branch`
8. **Post-merge**: Return to main, run npm install if needed
9. **Close issue**: `gh issue close <number>`

---

## 4. Conventions

### One Issue = One Branch = One PR

- Branch: `{issue-number}-{brief-description}`
- PR title: `{issue_number}: {brief description}`
- PR body: `Closes #{issue_number}`

### Issue Selection Rules

- **Skip** `human-agent` issues
- **Skip** `in-progress` issues unless directed
- **Skip** `in-review` issues unless directed
- Multi-agent: skip issues with a different agent's label

### Discovering New Work

While working, if you discover:
- **Human-agent work needed**: Create new issue with `human-agent` label
- **Related follow-up**: Create new issue
- **Blocking dependency**: Note in PR and link blocking issue

---

## 5. Reference

### Human Agent

{{FULL_NAME}} (@{{GITHUB_USERNAME}}) is the sole human agent. All `human-agent` issues are assigned to them.
