---
name: refresh-plugin
description: Update the skill-overflow plugin to the latest version.
---

# Refresh Plugin

Update the skill-overflow plugin to the latest version from the marketplace.

## Usage

```
/refresh-plugin
```

## Instructions

When invoked, follow these steps:

### 1. Check current version

Show the user the currently installed plugin version:

```bash
claude /plugin list 2>/dev/null || echo "Unable to list plugins"
```

### 2. Update the plugin

Run the plugin update command:

```bash
claude /plugin update skill-overflow@skill-overflow
```

### 3. Report results

After the update completes, provide:
- Whether the plugin was updated or was already at the latest version
- The new version number if updated
- Any errors encountered during the update
