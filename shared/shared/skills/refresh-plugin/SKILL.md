---
name: refresh-plugin
description: Update skill-overflow plugins to the latest version.
---

# Refresh Plugin

Update one or all skill-overflow plugins from the marketplace.

## Usage

```
/refresh-plugin
```

## Instructions

When invoked, follow these steps:

### 1. List installed plugins

Show the user currently installed skill-overflow plugins:

```bash
claude /plugin list 2>/dev/null || echo "Unable to list plugins"
```

### 2. Ask the user what to update

The skill-overflow marketplace contains these plugins:
- `skill-overflow@shared`
- `skill-overflow@engineering`
- `skill-overflow@coolset-academy`

Ask the user whether they want to update **all installed plugins** or a **specific plugin**.

### 3. Update the plugin(s)

**To update a specific plugin:**

```bash
claude /plugin update skill-overflow@<plugin-name>
```

**To update all installed plugins:**

Run the update command for each installed skill-overflow plugin:

```bash
claude /plugin update skill-overflow@shared
claude /plugin update skill-overflow@engineering
claude /plugin update skill-overflow@coolset-academy
```

Skip any that aren't installed.

### 4. Report results

After the update completes, provide:
- Which plugins were updated or were already at the latest version
- Any errors encountered during the update
