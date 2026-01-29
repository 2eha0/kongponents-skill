---
name: kongponents-install
description: One-time installation for Kongponents component reference skill
---

## Installation

Execute the following steps to install the Kongponents skill:

**Prerequisites:** Ensure `git` and `curl` are installed on your system.

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

**Security note:** Review scripts before executing them. You can inspect the source at the URLs below.

```bash
curl --fail -o ~/.claude/skills/kongponents/sync.sh \
  https://raw.githubusercontent.com/Kong/kongponents-skill/main/src/sync.sh

curl --fail -o ~/.claude/skills/kongponents/generate.sh \
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
