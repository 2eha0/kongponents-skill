# Kongponents Skill Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a self-updating Claude Code skill for Kong's Kongponents Vue component library.

**Architecture:** Sparse git checkout of upstream docs, generator script to build skill files, auto-update check on skill invocation.

**Tech Stack:** Bash scripts, Markdown, Git

---

## Task 1: Create Project Structure

**Files:**
- Create: `src/sync.sh`
- Create: `src/generate.sh`
- Create: `src/templates/kongponents.md.template`
- Create: `src/templates/kongponents-install.md`

**Step 1: Create directory structure**

```bash
mkdir -p src/templates
```

**Step 2: Verify structure**

Run: `ls -la src/`
Expected: `templates` directory exists

**Step 3: Commit**

```bash
git add src/
git commit -m "chore: create project structure"
```

---

## Task 2: Create Installation Skill

**Files:**
- Create: `src/templates/kongponents-install.md`

**Step 1: Write installation skill**

```markdown
---
name: kongponents-install
description: One-time installation for Kongponents component reference skill
---

## Installation

Execute the following steps to install the Kongponents skill:

### Step 1: Create skill directory

```bash
mkdir -p ~/.claude/skills/kongponents/components
```

### Step 2: Clone repository (sparse checkout)

```bash
git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/Kong/kongponents.git \
  ~/.claude/skills/kongponents/repo

cd ~/.claude/skills/kongponents/repo
git sparse-checkout set docs/components
```

### Step 3: Download scripts

```bash
curl -o ~/.claude/skills/kongponents/sync.sh \
  https://raw.githubusercontent.com/Kong/kongponents-skill/main/src/sync.sh

curl -o ~/.claude/skills/kongponents/generate.sh \
  https://raw.githubusercontent.com/Kong/kongponents-skill/main/src/generate.sh

chmod +x ~/.claude/skills/kongponents/*.sh
```

### Step 4: Run initial generation

```bash
~/.claude/skills/kongponents/generate.sh
```

### Step 5: Verify installation

```bash
ls ~/.claude/skills/kongponents/
```

Expected files: `kongponents.md`, `sync.sh`, `generate.sh`, `.version`, `.last-check`, `components/`, `repo/`

**Installation complete.** You can now use the `kongponents` skill for Vue component reference.
```

**Step 2: Verify file content**

Run: `cat src/templates/kongponents-install.md`
Expected: Contains installation instructions

**Step 3: Commit**

```bash
git add src/templates/kongponents-install.md
git commit -m "feat: add installation skill template"
```

---

## Task 3: Create Sync Script

**Files:**
- Create: `src/sync.sh`

**Step 1: Write sync script**

```bash
#!/bin/bash
# Kongponents Skill Sync Script
# Pulls latest docs from upstream and regenerates skill files

set -e

SKILL_DIR="${SKILL_DIR:-$HOME/.claude/skills/kongponents}"
REPO_DIR="$SKILL_DIR/repo"
REPO_URL="https://github.com/Kong/kongponents.git"

echo "==> Syncing Kongponents documentation..."

# Check if repo exists
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "Error: Repository not found. Run kongponents-install first."
    exit 1
fi

# Pull latest changes
cd "$REPO_DIR"
git fetch origin main
git reset --hard origin/main

# Record version
git rev-parse HEAD > "$SKILL_DIR/.version"
date +%s > "$SKILL_DIR/.last-check"

echo "==> Running generator..."
"$SKILL_DIR/generate.sh"

echo "==> Sync complete!"
echo "Version: $(cat $SKILL_DIR/.version)"
```

**Step 2: Make executable and verify**

Run: `chmod +x src/sync.sh && head -20 src/sync.sh`
Expected: Shows shebang and initial commands

**Step 3: Commit**

```bash
git add src/sync.sh
git commit -m "feat: add sync script"
```

---

## Task 4: Create Generator Script

**Files:**
- Create: `src/generate.sh`

**Step 1: Write generator script**

```bash
#!/bin/bash
# Kongponents Skill Generator
# Extracts component docs and builds skill files

set -e

SKILL_DIR="${SKILL_DIR:-$HOME/.claude/skills/kongponents}"
REPO_DIR="$SKILL_DIR/repo"
DOCS_DIR="$REPO_DIR/docs/components"
COMPONENTS_DIR="$SKILL_DIR/components"
OUTPUT="$SKILL_DIR/kongponents.md"

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
        echo "| K${name^} | ${desc} | (embedded below) |" >> "$OUTPUT"
    else
        echo "| K${name^} | ${desc} | components/${name}.md |" >> "$OUTPUT"
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
        echo "### K${comp^}" >> "$OUTPUT"
        echo "" >> "$OUTPUT"
        # Include full content, removing VitePress-specific syntax
        sed -e 's/^# .*//' \
            -e 's/:::/---/g' \
            -e 's/<script setup>.*<\/script>//g' \
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
```

**Step 2: Make executable and verify**

Run: `chmod +x src/generate.sh && wc -l src/generate.sh`
Expected: ~90 lines

**Step 3: Commit**

```bash
git add src/generate.sh
git commit -m "feat: add generator script"
```

---

## Task 5: Create Main Skill Template

**Files:**
- Create: `src/templates/kongponents.md.template`

**Step 1: Write template header**

This is a reference template showing the expected output format. The actual file is generated by `generate.sh`.

```markdown
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
| KButton | Button component with multiple appearances | (embedded below) |
| KInput | Text input with validation states | (embedded below) |
| KModal | Pop-up modal with overlay | (embedded below) |
| KSelect | Dropdown select with filtering | (embedded below) |
| KTable | Data table (deprecated, use KTableData) | (embedded below) |
| KAlert | Alert messages | components/alert.md |
| ... | ... | ... |

## Usage

For components marked "(embedded below)", use the documentation in this file.
For other components, read the file from `~/.claude/skills/kongponents/components/`.

---

## Common Components

[Generated content from button.md, input.md, modal.md, select.md, table.md]
```

**Step 2: Commit**

```bash
git add src/templates/kongponents.md.template
git commit -m "docs: add main skill template reference"
```

---

## Task 6: Add README

**Files:**
- Create: `README.md`

**Step 1: Write README**

```markdown
# Kongponents Skill

A Claude Code skill for Kong's [Kongponents](https://github.com/Kong/kongponents) Vue component library.

## Features

- Offline component reference (props, slots, events, examples)
- Auto-update detection with user confirmation
- 5 common components embedded, 40+ loaded on-demand

## Installation

Use the `kongponents-install` skill or run manually:

```bash
# Create directory
mkdir -p ~/.claude/skills/kongponents/components

# Clone docs only (sparse checkout)
git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/Kong/kongponents.git \
  ~/.claude/skills/kongponents/repo
cd ~/.claude/skills/kongponents/repo
git sparse-checkout set docs/components

# Copy scripts
cp src/sync.sh src/generate.sh ~/.claude/skills/kongponents/
chmod +x ~/.claude/skills/kongponents/*.sh

# Generate skill files
~/.claude/skills/kongponents/generate.sh
```

## Usage

After installation, the `kongponents` skill is available in Claude Code.

Example prompts:
- "Create a KButton with danger appearance"
- "Show me KModal props for a confirmation dialog"
- "Help me build a form with KInput and KSelect"

## Updating

The skill checks for updates every 24 hours. When updates are available, you'll be prompted to sync.

Manual sync:
```bash
~/.claude/skills/kongponents/sync.sh
```

## Development

```bash
# Test generator locally
SKILL_DIR=./test-output ./src/generate.sh
```

## License

MIT
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README"
```

---

## Task 7: Test Generator Locally

**Files:**
- Modify: None (testing only)

**Step 1: Create test environment**

```bash
mkdir -p test-output/repo/docs/components
```

**Step 2: Clone sample docs for testing**

```bash
cd test-output/repo
git init
git remote add origin https://github.com/Kong/kongponents.git
git fetch --depth 1 origin main
git checkout origin/main -- docs/components/button.md docs/components/input.md docs/components/modal.md docs/components/select.md docs/components/table.md docs/components/alert.md
```

**Step 3: Run generator**

Run: `SKILL_DIR=./test-output ./src/generate.sh`
Expected: "Generated skill with 6 components (1 on-demand)"

**Step 4: Verify output**

Run: `head -50 test-output/kongponents.md`
Expected: Shows header, update check instructions, and component index

**Step 5: Cleanup test directory**

```bash
rm -rf test-output
echo "test-output/" >> .gitignore
git add .gitignore
git commit -m "chore: add test-output to gitignore"
```

---

## Task 8: Final Integration Test

**Files:**
- None (full installation test)

**Step 1: Run full installation**

```bash
# Backup existing skill if present
[ -d ~/.claude/skills/kongponents ] && mv ~/.claude/skills/kongponents ~/.claude/skills/kongponents.bak

# Create fresh installation
mkdir -p ~/.claude/skills/kongponents/components

git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/Kong/kongponents.git \
  ~/.claude/skills/kongponents/repo

cd ~/.claude/skills/kongponents/repo
git sparse-checkout set docs/components
cd -

cp src/sync.sh src/generate.sh ~/.claude/skills/kongponents/
chmod +x ~/.claude/skills/kongponents/*.sh

~/.claude/skills/kongponents/generate.sh
```

**Step 2: Verify installation**

Run: `ls -la ~/.claude/skills/kongponents/`
Expected: `kongponents.md`, `sync.sh`, `generate.sh`, `.version`, `.last-check`, `components/`, `repo/`

**Step 3: Verify component count**

Run: `ls ~/.claude/skills/kongponents/components/ | wc -l`
Expected: ~40 files (all non-common components)

**Step 4: Verify main skill content**

Run: `grep -c "^### K" ~/.claude/skills/kongponents/kongponents.md`
Expected: 5 (common components embedded)

**Step 5: Test sync script**

Run: `~/.claude/skills/kongponents/sync.sh`
Expected: "Sync complete!" message

**Step 6: Restore backup if needed**

```bash
# Only if you had a backup
[ -d ~/.claude/skills/kongponents.bak ] && rm -rf ~/.claude/skills/kongponents && mv ~/.claude/skills/kongponents.bak ~/.claude/skills/kongponents
```

---

## Summary

After completing all tasks, you will have:

1. `src/templates/kongponents-install.md` - Installation skill for users
2. `src/sync.sh` - Script to pull updates and regenerate
3. `src/generate.sh` - Script to build skill from repo docs
4. `src/templates/kongponents.md.template` - Reference for expected output
5. `README.md` - Project documentation

Users install once with `kongponents-install`, then use `kongponents` skill with auto-update prompts.
