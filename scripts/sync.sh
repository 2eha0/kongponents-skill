#!/bin/bash
# Kongponents Skill Sync Script
# Clones Kongponents docs and generates component index

set -euo pipefail

# Get skill directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$SKILL_DIR/.data"
REPO_DIR="$DATA_DIR/repo"
REPO_URL="https://github.com/Kong/kongponents.git"

echo "==> Checking prerequisites..."

if ! command -v git &> /dev/null; then
    echo "Error: git not found. Please install git first."
    exit 1
fi

echo "==> Syncing Kongponents documentation..."

# Create data directory
mkdir -p "$DATA_DIR"

# Clone or update repository
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "==> First sync: Cloning Kongponents repository..."
    git clone --depth 1 --filter=blob:none --sparse \
        "$REPO_URL" "$REPO_DIR"

    cd "$REPO_DIR" || exit 1
    git sparse-checkout set docs/components
    cd "$SKILL_DIR" || exit 1
else
    echo "==> Updating existing repository..."
    cd "$REPO_DIR" || exit 1
    git fetch origin main
    git reset --hard origin/main
    cd "$SKILL_DIR" || exit 1
fi

# Record version and timestamp
cd "$REPO_DIR" || exit 1
git rev-parse HEAD > "$DATA_DIR/.version"
date +%s > "$DATA_DIR/.last-check"
cd "$SKILL_DIR" || exit 1

echo "==> Running generator..."
"$SCRIPT_DIR/generate.sh"

echo ""
echo "✓ Sync complete!"
echo "Version: $(cat "$DATA_DIR/.version")"
echo "Components available in .data/components/"
