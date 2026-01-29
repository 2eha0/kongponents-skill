#!/bin/bash
# Kongponents Skill Sync Script
# Pulls latest docs from upstream and regenerates skill files

set -e

SKILL_DIR="${SKILL_DIR:-$HOME/.claude/skills/kongponents}"
REPO_DIR="$SKILL_DIR/repo"

echo "==> Syncing Kongponents documentation..."

# Check if repo exists
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "Error: Repository not found. Run kongponents-install first."
    exit 1
fi

# Pull latest changes
cd "$REPO_DIR" || exit 1
git fetch origin main
git reset --hard origin/main

# Record version
git rev-parse HEAD > "$SKILL_DIR/.version"
date +%s > "$SKILL_DIR/.last-check"

echo "==> Running generator..."
"$SKILL_DIR/generate.sh"

echo "==> Sync complete!"
echo "Version: $(cat "$SKILL_DIR/.version")"
