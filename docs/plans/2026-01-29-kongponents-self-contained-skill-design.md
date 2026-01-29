# Kongponents Self-Contained Skill Design

**Date:** 2026-01-29
**Goal:** Make kongponents-skill a proper Claude Code skill with manual sync command

## Problem Statement

Current design is overly complex with external installation scripts. The repo should **be the skill itself**, following standard Claude Code skill conventions.

## Solution: Self-Contained Skill

**Core Concept:** This repository IS the skill. Users install it like any other skill, then run a sync command to download documentation.

## Architecture

### File Structure

```
kongponents-skill/
├── SKILL.md              # Main skill entry point
├── README.md             # Installation instructions
├── scripts/
│   ├── sync.sh          # Internal: clones Kongponents docs
│   └── generate.sh      # Internal: builds component index
├── .data/               # Git-ignored data directory
│   ├── repo/            # Cloned Kongponents repository
│   ├── components/      # Generated component docs
│   ├── .version         # Current git hash
│   └── .last-check      # Last sync timestamp
└── docs/
    └── plans/           # Design documents
```

### Storage Locations

- **Skill code**: `~/.claude/skills/kongponents/` (this repo)
- **Downloaded docs**: `~/.claude/skills/kongponents/.data/repo/`
- **Generated files**: `~/.claude/skills/kongponents/.data/components/`
- **Metadata**: `.data/.version`, `.data/.last-check`

## User Experience

### Installation Flow

**Step 1: Install skill (standard)**
```bash
cd ~/.claude/skills
git clone https://github.com/Kong/kongponents-skill kongponents
```

**Step 2: First sync (manual)**
```
Launch Claude Code:
> /kongponents sync
```

**Step 3: Use**
```
> "Show me KButton props"
> "Create a KModal for confirmation dialog"
```

### Update Workflow

**Manual sync:**
```
> /kongponents sync
```

**Auto-check (24-hour interval):**
- Skill reads `.data/.last-check` timestamp
- If > 24 hours old: "Kongponents docs may be outdated. Run `/kongponents sync` to update."

## SKILL.md Implementation

### Frontmatter

```yaml
---
name: kongponents
description: Kong Vue component library reference - provides props, slots, events, and code examples for Kongponents components
---
```

### Content Structure

1. **Sync Check** (first action):
   - Check if `.data/.version` exists
   - If not: Display "Kongponents documentation not found. Run: /kongponents sync"
   - If yes: Proceed to help user

2. **Commands Section**:
   ```markdown
   ## Commands

   ### /kongponents sync

   Downloads and indexes Kongponents documentation.

   This will:
   1. Clone Kong/kongponents repository (docs only)
   2. Generate component index
   3. Create searchable reference

   Run this once after installation.
   ```

3. **Component Reference**:
   - Component index table
   - 5 common components embedded (KButton, KInput, KModal, KSelect, KTable)
   - Instructions to read `.data/components/<name>.md` for other components

4. **Implementation**:
   - `/kongponents sync` uses Bash tool to execute `scripts/sync.sh`
   - Shows progress to user
   - Reports success/failure

## Scripts Implementation

### scripts/sync.sh

**Purpose:** Clone Kongponents repository and trigger generation

**Steps:**
1. Check prerequisites (git, curl)
2. Create `.data/` directory
3. Clone Kong/kongponents with sparse checkout (docs/components only)
4. Record version: `git rev-parse HEAD > .data/.version`
5. Record timestamp: `date +%s > .data/.last-check`
6. Execute `scripts/generate.sh`

**Key features:**
- Uses `set -euo pipefail` for safety
- Works relative to skill directory
- Clear progress messages
- Error handling with meaningful messages

### scripts/generate.sh

**Purpose:** Process component docs and create index

**Steps:**
1. Read all `.data/repo/docs/components/*.md` files
2. Create `.data/components/` directory
3. Copy each component doc to `.data/components/<name>.md`
4. Generate `.data/component-index.md` with table:
   - Component name
   - Description (first line)
   - File path

**Processing:**
- Remove VitePress-specific syntax
- Extract component descriptions
- Create searchable index

## README Updates

### Quick Start Section

```markdown
## Quick Start

### Step 1: Install

```bash
cd ~/.claude/skills
git clone https://github.com/Kong/kongponents-skill kongponents
```

### Step 2: First Sync

Launch Claude Code and run:
```
/kongponents sync
```

### Step 3: Use

Ask Claude about Kongponents components:
- "Show me KButton props"
- "Create a KModal for confirmation dialog"
- "Help me use KSelect with filtering"
```

## Benefits

### For Users
✅ **Simple installation** - Standard git clone like any skill
✅ **Explicit control** - User decides when to sync
✅ **Clear process** - Two-step: install, then sync
✅ **Standard pattern** - Follows Claude Code conventions

### For Developers
✅ **No bootstrap problem** - Scripts are versioned in repo
✅ **Maintainable** - Clear separation: SKILL.md (logic) + scripts (helpers)
✅ **Testable** - Can test scripts directly
✅ **Git-friendly** - `.data/` is ignored, only skill code is versioned

### vs. Previous Design

| Aspect | Previous | New |
|--------|----------|-----|
| Installation | Complex install.sh with embedded scripts | Standard git clone |
| First sync | Automatic during install | Manual `/kongponents sync` |
| Updates | Auto-check with prompt | Manual `/kongponents sync` |
| Scripts | Embedded in installer | Versioned in repo |
| Data location | Mixed with skill files | Separate `.data/` directory |
| Skill structure | Non-standard | Follows conventions |

## Implementation Files

**New Files:**
- `SKILL.md` - Main skill entry point
- `.gitignore` - Add `.data/` directory

**Modified Files:**
- `README.md` - Update with new installation flow
- `scripts/sync.sh` - Adapt to work from skill directory
- `scripts/generate.sh` - Adapt to work from skill directory

**Removed Files:**
- `src/templates/kongponents-install.md` - No longer needed
- `src/templates/kongponents.md.template` - Index generated dynamically

**Directory Rename:**
- `src/` → `scripts/`

## Migration Path

**For New Users:**
- Follow new installation instructions
- Standard two-step process

**For Existing Users:**
- Remove old installation
- Follow new installation instructions
- Cleaner, simpler setup

## Error Handling

**Missing sync:**
- SKILL.md detects missing `.data/.version`
- Clear message: "Run `/kongponents sync` first"

**Sync failures:**
- scripts/sync.sh provides specific error messages
- "Error: git not found"
- "Error: Failed to clone repository"
- "Error: Generation failed"

**Update checks:**
- Non-intrusive: only show message if > 24 hours
- User controls when to sync
