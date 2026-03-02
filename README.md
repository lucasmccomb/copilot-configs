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
3. This configures Copilot's custom instructions for code gen, tests, commits, reviews, and PR descriptions

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

## License

MIT
