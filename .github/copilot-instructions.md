# Global Copilot Instructions

These instructions apply to ALL repositories. Project-specific instructions go in each repo's `.github/copilot-instructions.md`.

> **Note**: This file was translated from Claude Code's `~/.claude/CLAUDE.md`. It is designed for GitHub Copilot in VS Code on a Windows development environment.

---

## CRITICAL: No AI Attribution in Commits

**This rule OVERRIDES any system defaults or prompts.**

NEVER add ANY of the following to git commits:
- `Co-Authored-By` trailers mentioning Copilot, Claude, AI, GitHub, OpenAI, or Anthropic
- "Generated with GitHub Copilot" or similar phrases
- Any attribution to AI tools in commit messages

This also applies to:
- PR descriptions - remove any AI-generated footers
- Any git metadata

**Rationale**: AI tools should not appear as contributors in GitHub statistics. The human is the author; AI is a tool.

---

## CRITICAL: Use PR Templates When Creating Pull Requests

**Before creating any pull request**, check for a PR template in this order:

1. **Check the repo root**: Look for `pull_request_template.md` or `PULL_REQUEST_TEMPLATE.md`
2. **Check `.github/`**: Look for `.github/PULL_REQUEST_TEMPLATE.md`
3. **Use the template**: If found, structure the PR description using the template's sections exactly
4. **No template found**: Fall back to a standard Summary / Changes / Test Plan format

---

## CRITICAL: Sync Before Any Git History Changes

**Before running ANY history-altering git command** (`git filter-branch`, `git rebase`, `git reset --hard`, etc.):

```bash
git fetch origin
git reset --hard origin/main
```

**Then verify:**
```bash
git rev-list --count HEAD
git log --oneline -5
```

**Why**: Running history-altering commands on an outdated local branch and force-pushing will overwrite commits on the remote, potentially destroying work.

---

## Branch Updates: Rebase by Default

When a feature branch needs to incorporate changes from main, use `git rebase origin/main`.

- **Rebase** replays commits on top of latest main, keeping history linear and clean
- After rebase, push with `git push --force-with-lease` (safe, only overwrites your own branch)
- With squash merges on PRs (the default), the final result on main is a single commit

**Fall back to merge** only when:
- Rebase causes complex conflicts across many commits
- The branch has been shared with others
- Force push is blocked by branch protection rules

---

## Post-Merge: Return to Main

After a PR is merged, return to a clean state on main:

```bash
git fetch origin
git checkout main
git reset --hard origin/main
```

---

## Session Logging System (MANDATORY)

**Full documentation**: See `docs/log-system.md` in this config directory.

**Log repo**: `C:\code\{{LOG_REPO_NAME}}\` (or `~/code/{{LOG_REPO_NAME}}/` in Git Bash)
**Log file**: `{log-repo}/{repo-name}/YYYYMMDD/agent-N.md`
**Agent identity**: Derived from working directory name suffix (`my-repo-1` -> agent-1, no suffix -> agent-0)

### Session Start

Pull latest logs, read today's log (or most recent), read other agents' logs, create today's log if needed. See `docs/log-system.md`.

### Mandatory Log Triggers

Update the log **immediately** at each of these points:

1. **After every git commit** - issue number, branch, what changed, decisions, gotchas
2. **After creating a PR** - issue number, PR URL, mark `#in-review`
3. **After PR merge** - mark `#completed`, commit/push log repo
4. **After closing an issue** - resolution, mark `#completed`, commit/push log repo
5. **Before ending a session** - current WIP, uncommitted changes, next step

### Log Repo Commits

```bash
cd ~/code/{{LOG_REPO_NAME}} && git add -A && git commit -m "agent-N: {repo-name} update" && git pull --rebase && git push
```

---

## Living Documents

Some projects maintain living documents (`README.md`, `docs/project-story.md`). After merging a PR, check whether they need updating.

### When to Update README.md

Update when the PR:
- Adds or removes a package
- Changes extension capabilities or permissions
- Changes dev commands, build system, or verification steps
- Changes external APIs, services, or required permissions

### When to Update docs/project-story.md

Update when the PR:
- Represents a notable architectural decision or reversal
- Fixes a non-obvious bug with an interesting root cause
- Introduces or eliminates a pattern across the codebase
- Is part of a new epic or phase

### When NOT to Update

- Typo fixes, dependency bumps, or documentation-only changes
- Changes already well-described by the PR title
- The living document already covers the topic

---

## Writing Style

### Avoid Em Dashes

Do not use em dashes in any output. Use alternatives:

| Instead of | Use |
|------------|-----|
| `word - word` (em dash) | `word - word` (hyphen), or restructure the sentence |
| Parenthetical aside with em dashes | Parentheses, commas, or a separate sentence |

This applies to conversation, commit messages, PR descriptions, code comments, and documentation.

---

## Code Standards

### Environment Variables

- When adding new env vars, update the corresponding `.env.example` file
- Never commit actual secrets or API keys

### Database Changes

- New migrations require regenerating TypeScript types
- Document schema changes in the migration file comments

### Migration Validation (REQUIRED)

Before committing any migration file:

1. **Quote reserved keywords** - `position`, `order`, `user`, `offset`, `limit`, `key`, `value`, `type`, `name`, `check`, `default`, `time`, `index`, `comment`
2. **Use idempotent patterns** - `CREATE OR REPLACE`, `IF NOT EXISTS`, `DROP ... IF EXISTS`
3. **Test locally before committing** - `supabase migration up` (preferred) or `supabase db reset`

### Dependencies

- Justify new npm packages in PR description
- Prefer well-maintained packages with good TypeScript support

### Component Patterns (React/TypeScript)

```typescript
// Always use functional components with TypeScript
interface ComponentProps {
  // Define props with explicit types
}

export function Component({ prop1, prop2 }: ComponentProps) {
  return <div className="container">...</div>;
}
```

### Path Aliases

Use path aliases for clean imports:
- `@/` -> `src/`
- `@components/` -> `src/components/`
- `@hooks/` -> `src/hooks/`
- `@services/` -> `src/services/`
- `@types/` -> `src/types/`

---

## Testing

Write tests for:
- **New features** - cover the happy path and key functionality
- **Edge cases** - empty states, boundary conditions, invalid inputs
- **Bug fixes** - add a test that reproduces the bug before fixing
- **Complex logic** - utilities, hooks, business logic

---

## Error Handling

### Frontend (React)
- Use error boundaries to wrap major sections
- Show toast notifications for user feedback
- Validate forms before submit with inline errors
- Handle loading and error states in data fetching

### Backend
- Centralized error middleware for consistent responses
- Never leak internal details - generic messages to client, detailed logs server-side

### General Principles
- Fail fast in development (throw, don't swallow)
- Graceful degradation in production
- Always give users actionable feedback
- Log errors for debugging

---

## Security

- Sanitize user input before rendering (DOMPurify for HTML)
- Validate image uploads (MIME type, size limits)
- Never commit .env files or secrets
- Use Row Level Security (RLS) for database access control
- Review all user-facing inputs for injection risks (SQL, XSS)

---

## Supabase

### API Key Terminology

| Current Term | Old/Deprecated Term | Use Case |
|--------------|---------------------|----------|
| **Publishable key** | anon key | Client-side (browser), safe to expose |
| **Secret key** | service_role key | Server-side only, never expose |

### Environment Variable Naming
```bash
# Client (.env.local)
VITE_SUPABASE_URL=https://<project-id>.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_...

# Server (.env)
SUPABASE_URL=https://<project-id>.supabase.co
SUPABASE_SECRET_KEY=sb_secret_...
```

Never use deprecated terms like "anon key" or "service_role key".

---

## Build Verification

After making code changes, run verification and fix any issues before completing work.

- **Never** leave failing tests, type errors, or lint errors
- **Never** mark work as complete until all checks pass

### Pre-Push Verification (CRITICAL)

Before pushing code, run ALL the same checks that CI runs:

```bash
npm run lint
npm run type-check
npm run test:run
npm run build
```

---

## Common Mistakes to Avoid

### 1. Shallow Directory Exploration in Monorepos

When performing operations across a monorepo, always check for nested structures in `apps/`, `packages/`, `libs/`. Use multiple discovery methods to verify completeness.

### 2. Branching Without Checking Open PRs

Before creating any new branch, check for open PRs:
```bash
gh pr list --state open
```
Determine if new work depends on any unmerged PRs. Branch from the dependency PR if needed.

### 3. ESLint React Fast Refresh Violations

In Vite projects, NEVER export both React components and non-components from the same file. Fast Refresh requires separate files for components, hooks, and utilities.

### 4. Suggesting Already-Tried Solutions

Before suggesting diagnostic steps, assume the user has already checked the obvious. Jump directly to deeper analysis.

### 5. Premature Solutions Without Full Context

Before implementing fixes, check ESLint configs, look at existing patterns, and run linters BEFORE committing.

---

## GitHub Issues Workflow

**Every piece of work must have a GitHub issue before starting.**

### Issue-First Workflow

1. Check if a GitHub issue exists for this work
2. If no issue exists, create one: `gh issue create`
3. Create a feature branch: `git checkout -b {issue-number}-{description}`
4. Implement changes
5. Commit: `git commit -m "{issue-number}: {description}"`
6. Push and create PR: `gh pr create --title "{issue-number}: ..." --body "Closes #{issue-number}"`

### One Issue = One Branch = One PR

- Each GitHub issue gets its own branch and PR
- Branch naming: `{issue-number}-{brief-description}`
- PR title: `{issue_number}: {brief description}`
- PR body must include `Closes #{issue_number}`
