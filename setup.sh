#!/bin/bash
# =============================================================================
# copilot-configs setup script
# =============================================================================
# Personalizes all config files with your GitHub username, name, and log repo.
# Run once after cloning. Safe to re-run (idempotent).
#
# Usage:
#   ./setup.sh
#   ./setup.sh --github-user myname --full-name "My Name" --log-repo my-agent-logs
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------------------------------------------------------------------------
# Parse arguments (or prompt interactively)
# ---------------------------------------------------------------------------
GITHUB_USERNAME=""
FULL_NAME=""
LOG_REPO_NAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --github-user)  GITHUB_USERNAME="$2"; shift 2 ;;
    --full-name)    FULL_NAME="$2"; shift 2 ;;
    --log-repo)     LOG_REPO_NAME="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: ./setup.sh [--github-user USER] [--full-name NAME] [--log-repo REPO]"
      echo ""
      echo "Options:"
      echo "  --github-user   Your GitHub username (e.g., octocat)"
      echo "  --full-name     Your full name for attribution (e.g., \"Octo Cat\")"
      echo "  --log-repo      Name of your agent logs repo (e.g., my-agent-logs)"
      echo ""
      echo "If options are not provided, the script will prompt interactively."
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Interactive prompts for missing values
if [ -z "$GITHUB_USERNAME" ]; then
  # Try to detect from gh CLI
  DETECTED_USER=$(gh api user --jq '.login' 2>/dev/null || echo "")
  if [ -n "$DETECTED_USER" ]; then
    read -p "GitHub username [$DETECTED_USER]: " GITHUB_USERNAME
    GITHUB_USERNAME="${GITHUB_USERNAME:-$DETECTED_USER}"
  else
    read -p "GitHub username: " GITHUB_USERNAME
  fi
fi

if [ -z "$FULL_NAME" ]; then
  # Try to detect from git config
  DETECTED_NAME=$(git config user.name 2>/dev/null || echo "")
  if [ -n "$DETECTED_NAME" ]; then
    read -p "Full name [$DETECTED_NAME]: " FULL_NAME
    FULL_NAME="${FULL_NAME:-$DETECTED_NAME}"
  else
    read -p "Full name: " FULL_NAME
  fi
fi

if [ -z "$LOG_REPO_NAME" ]; then
  read -p "Agent logs repo name [agent-logs]: " LOG_REPO_NAME
  LOG_REPO_NAME="${LOG_REPO_NAME:-agent-logs}"
fi

# ---------------------------------------------------------------------------
# Validate
# ---------------------------------------------------------------------------
if [ -z "$GITHUB_USERNAME" ]; then
  echo "ERROR: GitHub username is required."
  exit 1
fi

if [ -z "$FULL_NAME" ]; then
  echo "ERROR: Full name is required."
  exit 1
fi

echo ""
echo "Configuration:"
echo "  GitHub username:  $GITHUB_USERNAME"
echo "  Full name:        $FULL_NAME"
echo "  Log repo name:    $LOG_REPO_NAME"
echo ""
read -p "Proceed? [Y/n] " CONFIRM
CONFIRM="${CONFIRM:-Y}"
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# ---------------------------------------------------------------------------
# Replace placeholders in all files
# ---------------------------------------------------------------------------
echo ""
echo "Applying configuration..."

# Find all text files (md, json) and replace placeholders
# Using | as sed delimiter to avoid conflicts with paths
find "$SCRIPT_DIR" -type f \( -name "*.md" -o -name "*.json" \) ! -path "*/.git/*" | while read -r file; do
  if grep -q '{{GITHUB_USERNAME}}\|{{FULL_NAME}}\|{{LOG_REPO_NAME}}' "$file" 2>/dev/null; then
    sed -i.bak \
      -e "s|{{GITHUB_USERNAME}}|$GITHUB_USERNAME|g" \
      -e "s|{{FULL_NAME}}|$FULL_NAME|g" \
      -e "s|{{LOG_REPO_NAME}}|$LOG_REPO_NAME|g" \
      "$file"
    rm -f "${file}.bak"
    echo "  Updated: $(basename "$file")"
  fi
done

# ---------------------------------------------------------------------------
# Optional: Create the log repo
# ---------------------------------------------------------------------------
echo ""
read -p "Create the agent logs repo on GitHub? ($GITHUB_USERNAME/$LOG_REPO_NAME) [y/N] " CREATE_LOG_REPO
CREATE_LOG_REPO="${CREATE_LOG_REPO:-N}"

if [[ "$CREATE_LOG_REPO" =~ ^[Yy]$ ]]; then
  LOG_DIR="$HOME/code/$LOG_REPO_NAME"
  if [ -d "$LOG_DIR" ]; then
    echo "  Directory already exists: $LOG_DIR"
  else
    echo "  Creating GitHub repo..."
    gh repo create "$GITHUB_USERNAME/$LOG_REPO_NAME" --private --clone --description "Agent session logs" 2>/dev/null && \
      mv "$LOG_REPO_NAME" "$LOG_DIR" 2>/dev/null || \
      git clone "git@github.com:$GITHUB_USERNAME/$LOG_REPO_NAME.git" "$LOG_DIR" 2>/dev/null || \
      echo "  Could not create/clone repo. You may need to create it manually."
  fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "====================================="
echo "  Setup complete!"
echo "====================================="
echo ""
echo "Next steps:"
echo "  1. Copy .vscode/settings.json contents into your VS Code User Settings"
echo "     (Ctrl+Shift+P -> 'Open User Settings (JSON)')"
echo ""
echo "  2. For each project repo, copy these files:"
echo "     - .github/copilot-instructions.md"
echo "     - .github/prompts/  (the prompt files you want)"
echo "     - .github/instructions/  (conditional instruction files)"
echo "     - .copilotignore"
echo ""
echo "  3. Install GitHub CLI if not already installed:"
echo "     https://cli.github.com/"
echo "     Then: gh auth login"
echo ""
echo "  4. See README.md for full documentation"
echo ""
