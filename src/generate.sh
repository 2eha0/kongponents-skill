#!/bin/bash
# Kongponents Skill Generator
# Extracts component docs and builds skill files

set -e

# Capitalize first letter (portable)
capitalize() {
    echo "$1" | awk '{print toupper(substr($0,1,1)) substr($0,2)}'
}

SKILL_DIR="${SKILL_DIR:-$HOME/.claude/skills/kongponents}"
REPO_DIR="$SKILL_DIR/repo"
DOCS_DIR="$REPO_DIR/docs/components"
COMPONENTS_DIR="$SKILL_DIR/components"
OUTPUT="$SKILL_DIR/kongponents.md"

if [ ! -d "$DOCS_DIR" ]; then
    echo "Error: Docs directory not found: $DOCS_DIR" >&2
    echo "Run sync.sh first to clone the repository." >&2
    exit 1
fi

# Common components to embed in main skill
COMMON_COMPONENTS="button input modal select table"

echo "==> Generating Kongponents skill..."

# Create components directory
mkdir -p "$COMPONENTS_DIR"

# Start building main skill file
cat > "$OUTPUT" << 'HEADER'
---
name: kongponents
description: Kong Vue component library reference - generates correct Kongponents code with props, slots, and events
---

## Update Check

Before using this skill, check for updates:

1. Read `~/.claude/skills/kongponents/.last-check` timestamp
2. If more than 86400 seconds (24 hours) old:
   - Run: `git -C ~/.claude/skills/kongponents/repo fetch origin main`
   - Run: `git -C ~/.claude/skills/kongponents/repo rev-parse origin/main`
   - Compare with contents of `~/.claude/skills/kongponents/.version`
   - If different, ask user: "Kongponents has updates available. Sync now? (Y/n)"
   - If yes: Run `~/.claude/skills/kongponents/sync.sh`
   - Update `.last-check`: `date +%s > ~/.claude/skills/kongponents/.last-check`

---

## Component Index

| Component | Description | File |
|-----------|-------------|------|
HEADER

# Build index from all component files
for file in "$DOCS_DIR"/*.md; do
    [ -f "$file" ] || continue
    name=$(basename "$file" .md)
    # Extract first line description (after # heading)
    desc=$(grep -m1 "^[A-Z]" "$file" 2>/dev/null | head -c 80 || echo "Vue component")

    # Check if common component
    if echo "$COMMON_COMPONENTS" | grep -qw "$name"; then
        echo "| K$(capitalize "$name") | ${desc} | (embedded below) |" >> "$OUTPUT"
    else
        echo "| K$(capitalize "$name") | ${desc} | components/${name}.md |" >> "$OUTPUT"
        # Copy to components directory
        cp "$file" "$COMPONENTS_DIR/${name}.md"
    fi
done

# Add usage instructions
cat >> "$OUTPUT" << 'USAGE'

## Usage

For components marked "(embedded below)", use the documentation in this file.
For other components, read the file from `~/.claude/skills/kongponents/components/`.

---

## Common Components

USAGE

# Embed common component docs
for comp in $COMMON_COMPONENTS; do
    file="$DOCS_DIR/${comp}.md"
    if [ -f "$file" ]; then
        echo "" >> "$OUTPUT"
        echo "### K$(capitalize "$comp")" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
        # Include full content, removing VitePress-specific syntax
        sed -e 's/^# .*//' \
            -e 's/:::/---/g' \
            -e '/<script setup>/,/<\/script>/d' \
            "$file" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
        echo "---" >> "$OUTPUT"
    fi
done

# Count results
total=$(ls -1 "$DOCS_DIR"/*.md 2>/dev/null | wc -l)
ondemand=$(ls -1 "$COMPONENTS_DIR"/*.md 2>/dev/null | wc -l)

echo "==> Generated skill with $total components ($ondemand on-demand)"
echo "==> Output: $OUTPUT"
