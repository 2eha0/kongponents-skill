#!/bin/bash
# Kongponents Skill Generator
# Extracts component docs and builds component index

set -euo pipefail

# Capitalize first letter (portable)
capitalize() {
    echo "$1" | awk '{print toupper(substr($0,1,1)) substr($0,2)}'
}

# Get skill directory (where this script lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$SKILL_DIR/.data"
REPO_DIR="$DATA_DIR/repo"
DOCS_DIR="$REPO_DIR/docs/components"
COMPONENTS_DIR="$DATA_DIR/components"
INDEX_FILE="$DATA_DIR/component-index.md"

if [ ! -d "$DOCS_DIR" ]; then
    echo "Error: Docs directory not found: $DOCS_DIR" >&2
    echo "Run 'scripts/sync.sh' first to clone the repository." >&2
    exit 1
fi

echo "==> Generating component index..."

# Create components directory
mkdir -p "$COMPONENTS_DIR"

# Start building component index file
cat > "$INDEX_FILE" << 'HEADER'
# Kongponents Component Index

| Component | Description | File |
|-----------|-------------|------|
HEADER

# Process all component files
for file in "$DOCS_DIR"/*.md; do
    [ -f "$file" ] || continue
    name=$(basename "$file" .md)

    # Extract first line description (after # heading)
    desc=$(grep -m1 "^[A-Z]" "$file" 2>/dev/null | head -c 80 || echo "Vue component")

    # Copy to components directory
    cp "$file" "$COMPONENTS_DIR/${name}.md"

    # Add to index
    echo "| K$(capitalize "$name") | ${desc} | .data/components/${name}.md |" >> "$INDEX_FILE"
done

# Count results
total=$(ls -1 "$DOCS_DIR"/*.md 2>/dev/null | wc -l)

echo "==> Generated index with $total components"
echo "==> Index: $INDEX_FILE"
echo "==> Components: $COMPONENTS_DIR/"
