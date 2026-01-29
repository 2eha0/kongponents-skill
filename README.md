# Kongponents Skill

A Claude Code skill for Kong's [Kongponents](https://github.com/Kong/kongponents) Vue component library.

## Features

- Offline component reference (props, slots, events, examples)
- Auto-update detection with user confirmation
- 5 common components embedded, 40+ loaded on-demand

## Installation

### Using the Installation Skill

In Claude Code, invoke the `kongponents-install` skill:

```
/kongponents-install
```

Then follow the step-by-step installation instructions provided by the skill.

### Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

```bash
# Create directory
mkdir -p ~/.claude/skills/kongponents/components

# Clone docs only (sparse checkout)
git clone --depth 1 --filter=blob:none --sparse \
  https://github.com/Kong/kongponents.git \
  ~/.claude/skills/kongponents/repo
cd ~/.claude/skills/kongponents/repo
git sparse-checkout set docs/components

# Copy scripts from this repository
cp src/sync.sh src/generate.sh ~/.claude/skills/kongponents/
chmod +x ~/.claude/skills/kongponents/*.sh

# Generate skill files
~/.claude/skills/kongponents/generate.sh
```

</details>

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
