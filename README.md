# Copilot Configs

GitHub Copilot configuration files translated from Claude Code's global config (`~/.claude/`).
Provides a comprehensive AI-assisted development workflow for VS Code with custom instructions, slash commands, session logging, and multi-agent coordination.

## Quick Setup

### 1. Clone and Run Setup

```bash
git clone https://github.com/lucasmccomb/copilot-configs.git
cd copilot-configs
./setup.sh
```

The setup script will:
- Prompt for your **GitHub username**, **full name**, and **log repo name**
- Auto-detect values from `gh` CLI and `git config` if available
- Replace all `{{PLACEHOLDER}}` values across config files
- Optionally create a private agent logs repo on GitHub

You can also pass values directly:
```bash
./setup.sh --github-user octocat --full-name "Octo Cat" --log-repo my-agent-logs
```

### 2. Install User-Level VS Code Settings

1. Open VS Code: `Ctrl+Shift+P` -> "Preferences: Open User Settings (JSON)"
2. Merge the contents of `.vscode/settings.json` into your user settings
3. Save and reload: `Ctrl+Shift+P` -> "Developer: Reload Window"

See [Settings Reference](#settings-reference) below for what each setting does.

### 3. Copy Per-Project Files

For each repo you work on, copy the relevant files:

```
your-repo/
  .github/
    copilot-instructions.md    <-- Global rules (copy or customize per-project)
    prompts/                   <-- Slash command prompt files
      commit.prompt.md
      gs.prompt.md
      pr.prompt.md
      new-issue.prompt.md
      startup.prompt.md
      sync.prompt.md
      walkthrough.prompt.md
      cpm.prompt.md
      audit.prompt.md
    instructions/              <-- Conditional per-filetype instructions
      react-typescript.instructions.md
      sql-migrations.instructions.md
    PULL_REQUEST_TEMPLATE.md
  .copilotignore
```

### 4. Install GitHub CLI

The prompt files use `gh` extensively:
```bash
# Install: https://cli.github.com/
gh auth login
```

## How to Use

### Slash Commands (Prompt Files)

In Copilot Chat (Agent mode - `Ctrl+Shift+I`), type `/` and your custom prompts appear:

| Command | Purpose |
|---------|---------|
| `/commit` | Stage and commit with `{issue}: {description}` format |
| `/gs` | Git status, branch info, open PRs, issues overview |
| `/pr` | Push branch, create PR, update issue labels |
| `/new-issue` | Create GitHub issue with proper labels |
| `/startup` | Session startup with log check and work overview |
| `/sync` | Fetch origin and rebase on main |
| `/walkthrough` | Step-by-step guided task completion |
| `/cpm` | One-shot: commit + PR + merge + rebase on main |
| `/audit` | Comprehensive 8-category codebase audit |

### Instruction Files

Files in `.github/instructions/` apply automatically based on `applyTo` globs:
- **react-typescript.instructions.md** - Applies to `.ts` and `.tsx` files
- **sql-migrations.instructions.md** - Applies to SQL files in `migrations/` directories

Verify they're loaded by checking the **References** list in a Copilot response.

### Session Logging

The logging system provides continuity between sessions. See `docs/log-system.md` for the full protocol. Key points:
- Logs live in a git-backed repo (created during setup)
- Each agent writes to its own file: `{log-repo}/{project}/YYYYMMDD/agent-N.md`
- Update logs after every commit, PR, merge, and issue close

## File Map: Claude Code -> Copilot

| Claude Code | Copilot Equivalent | Location |
|------------|-------------------|----------|
| `~/.claude/CLAUDE.md` | User settings + copilot-instructions.md | `.vscode/settings.json` + `.github/copilot-instructions.md` |
| `~/.claude/commands/*.md` | Prompt files | `.github/prompts/*.prompt.md` |
| `~/.claude/log-system.md` | Reference doc | `docs/log-system.md` |
| `~/.claude/multi-agent-system.md` | Reference doc | `docs/multi-agent-system.md` |
| `~/.claude/github-repo-protocols.md` | Reference doc | `docs/github-repo-protocols.md` |
| `.claudeignore` | `.copilotignore` | `.copilotignore` |
| `~/.claude/hooks/*.py` | Husky git hooks | See "Git Workflow Enforcement" below |

## What Wasn't Migrated

| Claude Code Feature | Why |
|-------------------|-----|
| `hooks/*.py` (enforce-git-workflow) | Use Husky git hooks instead (see below) |
| `commands/dotsync.md` | Claude-specific dotfiles sync |
| `commands/cws-submit.md` | Chrome Web Store submission |
| `commands/promote-rule.md` | Claude-specific instruction management |
| MCP servers | Can be added later via `.vscode/mcp.json` |
| `~/.claude/settings.json` | Claude Code-specific permission system |

## Git Workflow Enforcement

The Claude Code hooks enforced: no commits on main, issue-number commit messages, no direct pushes to main.

To replicate with **Husky**:

```bash
npm install --save-dev husky
npx husky init
```

**Pre-commit** (`.husky/pre-commit`):
```bash
#!/bin/sh
BRANCH=$(git branch --show-current)
if [ "$BRANCH" = "main" ]; then
  echo "ERROR: Cannot commit on main. Create a feature branch first."
  exit 1
fi
```

**Commit-msg** (`.husky/commit-msg`):
```bash
#!/bin/sh
MSG=$(cat "$1")
if ! echo "$MSG" | grep -qE "^[0-9]+:"; then
  echo "ERROR: Commit message must start with issue number."
  echo "  Format: {issue_number}: {description}"
  echo "  Example: 4: Add user authentication"
  exit 1
fi
```

## Model Recommendations

| Task | Best Model |
|------|-----------|
| Default / general coding | Auto or GPT-4.1 |
| Quick questions, small edits | Claude Haiku 4.5 or GPT-5 mini |
| Multi-file refactoring | Raptor mini |
| Working from screenshots/mockups | GPT-4o |
| Agent mode (complex features) | GPT-4.1 (or request Opus/Sonnet access) |

## Key Differences from Claude Code

1. **No inline context at load time**: Claude commands pre-load git state with `!` backtick syntax. Copilot prompts instruct the agent to run commands as steps.
2. **No automatic enforcement hooks**: Claude Code hooks block bad actions in real-time. Copilot uses instructions (soft) or Husky hooks (hard).
3. **Model switching is per-chat**: `Ctrl+Alt+.` to switch. Claude Code uses `--model` flag.
4. **Agent mode must be selected**: `Ctrl+Shift+I` for Agent mode. Default chat is ask-only.
5. **Context is explicit**: Use `#file`, `#codebase`, `#changes` to feed context. Claude Code automatically reads referenced files.

## Customization

### Adding Project-Specific Instructions

Create a `.github/copilot-instructions.md` in your project repo. This overrides or supplements the global instructions for that workspace.

### Adding New Prompt Files

Create `.prompt.md` files in `.github/prompts/`. Frontmatter options:
- `agent`: Set to `'agent'` for autonomous mode
- `tools`: Array of tool references (`#runInTerminal`, `#editFiles`, `#readFile`, `#codebase`)
- `description`: Shown in the `/` autocomplete menu
- `model`: Override model for this prompt

### Per-Language Instructions

Create `.instructions.md` files in `.github/instructions/` with `applyTo` globs:
```yaml
---
name: 'Python Standards'
applyTo: '**/*.py'
---
Use type hints. Prefer dataclasses over dicts.
```

## Settings Reference

The `.vscode/settings.json` file contains user-level VS Code settings. Here's what each one does.

### Copilot Settings

| Setting | Value | What It Does |
|---------|-------|-------------|
| `chat.useClaudeMdFile` | `true` | Copilot reads `CLAUDE.md` files in your repos as additional context. If you have repos with existing `CLAUDE.md` files from Claude Code, Copilot will respect those instructions alongside `.github/copilot-instructions.md`. |
| `chat.agent.enabled` | `true` | Enables Agent Mode - the closest equivalent to Claude Code's default behavior. Copilot can run terminal commands, edit files, and read files autonomously. Without this, chat is ask-only. Open with `Ctrl+Shift+I`. |
| `github.copilot.enable` | `{ "*": true, ... }` | Controls which file types get inline autocomplete suggestions (the gray ghost text as you type). Explicitly enables `plaintext`, `markdown`, and `yaml` which some setups disable by default. Set any to `false` to disable suggestions for that type. |
| `github.copilot.nextEditSuggestions.enabled` | `true` | After you make an edit, Copilot predicts where you'll edit next and pre-suggests the change. For example, rename a function parameter and it suggests updating all usages. Accept with `Tab`. |
| `github.copilot.chat.terminalChatLocation` | `"terminal"` | When you use Copilot in the terminal, chat appears inline in the terminal panel rather than opening the sidebar. Handy for quick terminal questions without leaving context. |

### Editor Settings

| Setting | Value | What It Does |
|---------|-------|-------------|
| `editor.formatOnSave` | `true` | Automatically formats the file every time you save (`Ctrl+S`). Uses whichever formatter is configured (Prettier when uncommented). |
| `editor.defaultFormatter` | `"esbenp.prettier-vscode"` | Sets Prettier as the formatter for all file types. Handles consistent quotes, semicolons, indentation, and line width. **Requires** the Prettier extension (`Ctrl+Shift+X` -> search "Prettier"). Commented out by default until installed. |
| `editor.codeActionsOnSave` | `{ fixAll, organizeImports }` | `source.fixAll.eslint` auto-fixes ESLint errors on save (unused imports, spacing rules). `source.organizeImports` sorts and groups imports on save. `"explicit"` means it runs on manual save only, not on auto-save or window close. Requires ESLint extension. |

### TypeScript Settings

| Setting | Value | What It Does |
|---------|-------|-------------|
| `typescript.preferences.importModuleSpecifier` | `"non-relative"` | When VS Code auto-imports, it uses path aliases (`@/services/auth`) instead of relative paths (`../../../services/auth`). Only works if your project has path aliases configured in `tsconfig.json`. |
| `typescript.suggest.autoImports` | `true` | VS Code automatically suggests imports when you type a symbol name. Start typing `useState` and it offers to add `import { useState } from 'react'`. |

### Git Settings

| Setting | Value | What It Does |
|---------|-------|-------------|
| `git.autofetch` | `true` | VS Code periodically runs `git fetch` in the background. The branch indicator in the bottom-left shows if you're ahead/behind origin without manually fetching. |
| `git.confirmSync` | `false` | Skips the "are you sure?" dialog when syncing (push/pull) via the VS Code UI. Reduces friction for routine git operations. |
| `git.enableSmartCommit` | `true` | If you click the commit button with no staged files, VS Code automatically stages ALL changed files and commits. Without this, you'd get an error saying "nothing staged". |
| `git.postCommitCommand` | `"none"` | After committing, VS Code does nothing (no auto-push, no auto-sync). Intentional - you control when to push, matching the issue-first workflow. |

### File Exclusion Settings

| Setting | What It Excludes | Why |
|---------|-----------------|-----|
| `files.exclude` | `node_modules`, `dist`, `build`, `.next`, `coverage` | Hides these from the file explorer sidebar and `Ctrl+P` quick open. These are generated directories you never browse manually. |
| `search.exclude` | Same as above + `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` | Excludes from `Ctrl+Shift+F` global search results. Lock files are huge and pollute search. Also reduces noise when Copilot searches your codebase via `#codebase`. |

### What's NOT in Settings

These rules live in per-project files instead of user settings:

| What | Where | How Copilot Finds It |
|------|-------|---------------------|
| Global project rules (no AI attribution, git workflow, code standards) | `.github/copilot-instructions.md` | Auto-loaded per workspace |
| Per-filetype rules (React/TS conventions, SQL migration rules) | `.github/instructions/*.instructions.md` | Auto-scanned, applied by `applyTo` glob match |
| Slash commands (`/commit`, `/pr`, `/gs`, etc.) | `.github/prompts/*.prompt.md` | Auto-discovered, appear in `/` menu in Agent mode |

### Prerequisites

These extensions should be installed for full functionality:

| Extension | ID | Required For |
|-----------|----|-------------|
| GitHub Copilot | `GitHub.copilot` | All Copilot features |
| GitHub Copilot Chat | `GitHub.copilot-chat` | Chat and Agent mode |
| Prettier | `esbenp.prettier-vscode` | `editor.defaultFormatter` setting |
| ESLint | `dbaeumer.vscode-eslint` | `source.fixAll.eslint` on save |

Install via `Ctrl+Shift+X` (Extensions panel) or command line:
```bash
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
```

## License

MIT
