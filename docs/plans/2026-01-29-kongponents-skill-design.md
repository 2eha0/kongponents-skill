# Kongponents Skill Design

## Overview

A Claude Code skill that provides offline reference for Kong's Vue component library (Kongponents). The skill auto-syncs with the upstream repository and prompts users when updates are available.

## Goals

1. **Component Reference** - Provide accurate props, slots, events, and examples for all 45 Kongponents components
2. **Offline First** - Full knowledge base stored locally, no runtime dependency on internet
3. **Auto-Update** - Detect upstream changes and prompt user to sync

## Architecture

```
~/.claude/skills/kongponents/
├── kongponents.md              # Main skill entry
│                               # - Update check logic
│                               # - Component index (45 components)
│                               # - Common components API (Button, Input, Modal, Select, Table)
│
├── .version                    # Current synced commit hash
├── .last-check                 # Timestamp of last update check
│
├── sync.sh                     # Sync script (git pull + regenerate)
│
├── repo/                       # Kongponents repo (sparse checkout)
│   └── docs/components/*.md    # Only docs directory
│
└── components/                 # Generated component references (on-demand)
    ├── alert.md
    ├── badge.md
    └── ... (40 non-common components)
```

## Update Check Flow

```
User invokes skill
       │
       ▼
Check .last-check timestamp
       │
       ├─ < 24 hours → Skip check, use current version
       │
       └─ >= 24 hours
              │
              ▼
       git ls-remote origin main
              │
              ▼
       Compare with .version
              │
              ├─ Same → Update .last-check, continue
              │
              └─ Different → Prompt user:
                    "Kongponents has updates available. Sync now? (Y/n)"
                           │
                           ├─ Yes → Run sync.sh
                           └─ No  → Continue with current version
```

## Components

### Common Components (embedded in main skill)
- KButton
- KInput
- KModal
- KSelect
- KTable

### On-Demand Components (loaded when needed)
- KAlert, KBadge, KBreadcrumbs, KCard, KCatalog
- KCheckbox, KClipboardProvider, KCodeBlock, KCollapse, KComponent
- KCopy, KDateTimePicker, KDropdown, KDropdownMenu, KEmptyState
- KExternalLink, KFileUpload, KInputSwitch, KLabel, KModalFullscreen
- KMultiselect, KPagination, KPop, KPrompt, KRadio
- KSegmentedControl, KSkeleton, KSlideout, KSlider, KStepper
- KTableData, KTableView, KTabs, KTextArea, KToaster
- KToggle, KTooltip, KTreeList, KTruncate

## Files to Create

1. `kongponents-install.md` - One-time installation skill
2. `kongponents.md` - Main skill (template, filled by generate script)
3. `sync.sh` - Sync script (sparse checkout, pull, regenerate)
4. `generate.sh` - Generator script (extracts docs, builds skill files)

## Installation Flow

1. User runs `kongponents-install` skill
2. Skill executes setup:
   - Create `~/.claude/skills/kongponents/` directory
   - Clone repo with sparse checkout (docs only)
   - Run generator to build skill files
   - Record version and timestamp
3. User can now use `kongponents` skill

## Technical Details

### Sparse Checkout
```bash
git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/Kong/kongponents.git repo
cd repo
git sparse-checkout set docs/components
```

### Version Tracking
- `.version` - Contains commit hash: `a1b2c3d4...`
- `.last-check` - Unix timestamp: `1706500000`

### Component Doc Format
Source docs are in VitePress markdown with:
- Props tables
- Slots descriptions
- Events documentation
- Code examples

Generator extracts and reformats for skill consumption.
