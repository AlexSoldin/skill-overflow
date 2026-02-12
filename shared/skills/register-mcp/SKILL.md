---
name: register-mcp
description: Add an MCP server to any department plugin, with a built-in catalog of common servers.
---

# Register MCP Server

Add an MCP server configuration to any department plugin's `.mcp.json` file.

## Instructions

### 1. Choose department

Ask the user which department plugin to add the server to: shared, engineering, marketing, research, sales, or customer-success.

### 2. Choose server

Present the built-in catalog of common servers and ask the user to pick one, or specify a custom server.

**Built-in catalog:**

| Server | Type | Config |
|--------|------|--------|
| linear | http | `{"type": "http", "url": "https://mcp.linear.app/mcp"}` |
| sentry | http | `{"type": "http", "url": "https://mcp.sentry.dev/mcp"}` |
| n8n | stdio | `{"command": "npx", "args": ["-y", "n8n-mcp"], "env": {"N8N_BASE_URL": "${N8N_BASE_URL}", "N8N_API_KEY": "${N8N_API_KEY}"}}` |
| context7 | stdio | `{"command": "npx", "args": ["-y", "@upstash/context7-mcp"]}` |

**Custom server path:** If the user wants a server not in the catalog, ask for:
- Server name (kebab-case identifier)
- Server type: `stdio` (command-based) or `http`/`sse` (URL-based)
- For stdio: command, args, and any environment variables
- For http/sse: type and URL

### 3. Read or create .mcp.json

Read the existing `<department>/.mcp.json` file if it exists. If it doesn't exist, start with an empty JSON object `{}`.

### 4. Add server entry

Add the server configuration to the JSON object. Use the server name as the key.

If a server with that name already exists, warn the user and ask for confirmation before overwriting.

### 5. Write file

Write the updated JSON to `<department>/.mcp.json` with proper formatting (2-space indent, trailing newline).

### 6. Validate

Run the validation script:

```bash
python3 scripts/validate_plugin.py
```

### 7. Offer to commit

Ask the user if they'd like to commit using `/shared:commit-push-pr`.

## Safety Rules

- Never overwrite an existing server entry without asking the user first
- Use `${ENV_VAR}` syntax for secrets and API keys — never hardcode actual values
- Always validate after writing the file
- Remind users to set required environment variables if the server config uses `${...}` placeholders
