# Kongponents Skill

A Claude Code skill for Kong's [Kongponents](https://github.com/Kong/kongponents) Vue component library.

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

This downloads Kongponents documentation and creates a searchable component index.

### Step 3: Use

Ask Claude about Kongponents components:

```
Examples:
- "Show me KButton props"
- "Create a KModal for confirmation dialog"
- "Help me use KSelect with filtering"
- "What components are available?"
```

## Features

- **Offline reference** - Component docs stored locally
- **Quick lookup** - Search props, slots, events
- **Code generation** - Get Vue code examples
- **40+ components** - Buttons, inputs, modals, tables, and more
- **Manual sync** - Control when to update documentation

## Updating

To update Kongponents documentation:

```
/kongponents sync
```

The skill will fetch the latest component docs from the Kong/kongponents repository.

## How It Works

**Structure:**
- `SKILL.md` - Main skill logic
- `scripts/sync.sh` - Downloads Kongponents docs
- `scripts/generate.sh` - Creates component index
- `.data/` - Downloaded docs and generated files (git-ignored)

**Sync process:**
1. Clones Kong/kongponents repository (sparse checkout, docs only)
2. Copies component docs to `.data/components/`
3. Generates `.data/component-index.md` with all components
4. Records version and timestamp

## Development

**Test scripts locally:**

```bash
# Test sync
bash scripts/sync.sh

# Test generator
bash scripts/generate.sh

# Verify output
ls -la .data/
cat .data/component-index.md
```

**Clean data:**

```bash
rm -rf .data/
```

## Troubleshooting

**"Kongponents documentation not synced"**
- Run `/kongponents sync` to download docs

**Sync fails with git error**
- Ensure git is installed: `git --version`
- Check internet connection
- Try again: `/kongponents sync`

**Component not found**
- Check available components: Read `.data/component-index.md`
- Verify sync completed successfully

## License

MIT
