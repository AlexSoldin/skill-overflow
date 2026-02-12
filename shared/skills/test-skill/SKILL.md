---
name: test-skill
description: We are trying this
---

# Test Skill

We are trying this

## Instructions

### 1. Choose department

Ask the user which department plugin to add the server to: shared, engineering, marketing, research, sales, or customer-success.

## Safety Rules

- Never overwrite an existing server entry without asking the user first
- Use `${ENV_VAR}` syntax for secrets and API keys — never hardcode actual values
- Always validate after writing the file
- Remind users to set required environment variables if the server config uses `${...}` placeholders
