---
agent: 'agent'
tools: ['#runInTerminal', '#readFile', '#editFiles', '#codebase']
description: 'Comprehensive codebase audit across 8 categories'
---

# Codebase Audit

Comprehensive codebase audit with fix capabilities. Finds issues across 8 categories, fixes what it can, and reports what needs human review.

## Instructions

### Phase 1: Pre-Flight

1. Check git status - working directory must be clean for fix mode
2. Create checkpoint branch: `git branch audit-checkpoint-$(date +%Y%m%d-%H%M%S)`
3. If user wants read-only, skip fixes

### Phase 2: Discovery

1. Check for monorepo structure (`apps/`, `packages/`, `workspaces`)
2. Identify tech stack (TypeScript, React, Node.js, package manager)
3. Read CLAUDE.md or copilot-instructions.md for project rules
4. Check ESLint/linter configs

### Phase 3: Audit (8 Categories)

Audit each category sequentially:

1. **Security** - hardcoded secrets, console.logs with sensitive data, injection risks
2. **Dependencies** - `npm audit`, outdated packages, unused deps
3. **Code Quality** - ESLint violations, unused imports, long methods, large files
4. **Architecture** - circular deps, god objects, improper layering
5. **TypeScript/React** - excessive `any`, missing return types, Fast Refresh violations
6. **Testing** - missing test files, tests without assertions
7. **Documentation** - missing JSDoc, stale comments
8. **Performance** - N+1 queries, missing React.memo, large bundle imports

### Phase 4: Fix (if not read-only)

For each auto-fixable finding:
1. Apply fix
2. Run `npm run lint && npm run type-check && npm run test:run`
3. If passes: `git add . && git commit -m "audit: {category} - {title}"`
4. If fails: `git checkout -- .` and move to human review queue

### Phase 5: Summary

Report findings by category, severity, and fixability. Show recovery instructions if fixes were made.

### Phase 6: Issue Creation (optional)

Ask user if they want GitHub issues created for findings needing human review.
