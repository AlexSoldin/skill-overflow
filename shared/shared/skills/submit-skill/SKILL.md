---
name: submit-skill
description: Walk through creating and submitting a new skill as a pull request — no git knowledge required.
---

# Submit a New Skill

Guide anyone through contributing a new skill to the skill-overflow marketplace, handling all git operations automatically. The contributor only needs to answer a few questions.

## Usage

```
/submit-skill
```

## Instructions

When invoked, follow these phases in order. Be conversational and encouraging throughout — the user may have zero git experience.

### Phase 0 — Pre-flight checks

Run these checks silently. Only speak up if something fails.

1. **GitHub CLI authentication:**

```bash
gh auth status
```

If this fails, stop and explain:
> You need the GitHub CLI installed and authenticated. Run `gh auth login` and follow the prompts, then try again.

2. **Git remote and latest main:**

```bash
git remote -v
git fetch origin main
```

If there is no `origin` remote or fetch fails, stop and explain:
> This repository doesn't have a remote configured, or you don't have access. Ask the repo owner to add you as a GitHub collaborator, then clone the repo fresh and try again.

3. **Store context for later:**

```bash
git rev-parse --show-toplevel
git branch --show-current
```

Remember the repo root path and the current branch name — you will return to this branch at the end.

If any check fails, explain the problem in plain English and stop. Do not continue to Phase 1.

### Phase 1 — Gather skill details

Ask these questions **one at a time** using AskUserQuestion. Do not batch them.

#### 1. Department

Ask which department this skill belongs to. Present these options:

- **shared** — Available to everyone
- **engineering** — Engineering team
- **research** — Research team

Not all departments have plugins yet. If the user's department isn't listed, suggest "shared" as a starting point or offer to create a new plugin under their department.

Accept a number or name. Default to "shared" if the user is unsure.

#### 2. Plugin

After the department is selected, determine which plugin the skill belongs to.

- If the department has only one plugin (e.g., shared → shared, engineering → engineering), auto-select it and tell the user.
- If the department has multiple plugins (e.g., research → coolset-academy), list the available plugins and ask the user to pick one, or offer to create a new plugin.

Current plugins by department:
- **shared**: `shared`
- **engineering**: `engineering`
- **research**: `coolset-academy`

#### 3. Skill name

Ask for a skill name. Requirements:
- Must be kebab-case: lowercase letters, numbers, and hyphens only (`[a-z0-9]+(-[a-z0-9]+)*`)
- If the user enters spaces or uppercase, auto-convert (e.g. "My Cool Skill" → "my-cool-skill") and confirm the conversion
- Check that the skill directory does not already exist locally:

```bash
ls <department>/<plugin>/skills/<skill-name>/SKILL.md 2>/dev/null
```

- Check that no remote branch already exists:

```bash
git ls-remote --heads origin new-skill/<skill-name>
```

If the skill already exists locally, tell the user and ask for a different name. If a remote branch exists, warn the user and offer to pick a different name or continue (which will create a fresh branch, overwriting the remote one).

#### 4. Description

Ask for a one-line description of what the skill does. Requirements:
- Must not be empty
- Suggest keeping it under 150 characters
- This becomes the `description` field in the SKILL.md frontmatter

#### 5. Skill instructions

Ask the user to describe what the skill should do. They can be as detailed or brief as they like. Tell them:
> Describe what this skill should do. You can write freely — I'll format it into clean markdown for you.

After receiving the input:
1. Reformat it into well-structured markdown with headings, numbered steps, and code blocks as appropriate
2. Show the formatted instructions to the user
3. Ask for confirmation: "Does this look good? I can revise it if you'd like changes."
4. If the user wants changes, iterate until they approve

### Phase 2 — Confirm before submitting

Show a summary box before making any changes:

```
Skill summary
─────────────────────────────
Department:    <department>
Plugin:        <plugin>
Skill name:    <skill-name>
Location:      <department>/<plugin>/skills/<skill-name>/SKILL.md
Branch:        new-skill/<skill-name>
Description:   <description>
─────────────────────────────
```

Ask: "Ready to create this skill and open a PR? (yes / cancel)"

**Nothing has been written or committed yet.** Make this clear to the user.

If the user cancels, say "No problem — nothing was changed." and stop.

### Phase 3 — Git operations

Perform all steps automatically. Narrate each step briefly so the user knows what's happening.

#### 1. Create a fresh branch from latest main

```bash
git checkout -b new-skill/<skill-name> origin/main
```

If this fails because the branch already exists locally, delete it first and retry:

```bash
git branch -D new-skill/<skill-name>
git checkout -b new-skill/<skill-name> origin/main
```

#### 2. Create the SKILL.md file

```bash
mkdir -p <department>/<plugin>/skills/<skill-name>
```

Write the SKILL.md file with this structure:

```markdown
---
name: <skill-name>
description: <description>
---

# <Title derived from skill name>

<The formatted instructions from Phase 1>
```

The `name` field must exactly match the directory name. The title heading should be the skill name converted to title case (e.g. "my-cool-skill" → "My Cool Skill").

#### 3. Stage the new file

```bash
git add <department>/<plugin>/skills/<skill-name>/SKILL.md
```

Only stage this one file. Never use `git add -A` or `git add .`.

#### 4. Commit

```bash
git commit -m "$(cat <<'EOF'
feat(<plugin>): add <skill-name> skill

<description>
EOF
)"
```

#### 5. Push

```bash
git push -u origin new-skill/<skill-name>
```

If push fails with a permission error, stop and explain:
> You don't have push access to this repository. Ask the repo owner to add you as a collaborator on GitHub, then try `/submit-skill` again.

#### 6. Create the pull request

```bash
gh pr create --title "feat(<plugin>): add <skill-name> skill" --body "$(cat <<'EOF'
## New skill: `<skill-name>`

**Department:** <department>
**Plugin:** <plugin>
**Description:** <description>

## Skill instructions

<formatted instructions preview — first 20 lines or a concise summary>

## Checklist

- [x] SKILL.md created with valid frontmatter
- [x] Skill name is kebab-case and matches directory name
- [x] Description is present and concise
- [x] Branch created from latest main

---

Submitted via `/submit-skill`
EOF
)"
```

#### 7. Return to the original branch

```bash
git checkout <original-branch>
```

Use the branch name saved in Phase 0.

### Phase 4 — Report completion

After everything succeeds, print:

```
Skill submitted!
─────────────────────────────
PR:      <pr-url>
Branch:  new-skill/<skill-name>
File:    <department>/<plugin>/skills/<skill-name>/SKILL.md
─────────────────────────────

What happens next:
1. A maintainer will review your PR
2. Once approved and merged, the skill goes live
3. Everyone can get it by running /refresh-plugin
```

## Error handling

At any point if a command fails:

- **Do not silently recover.** Stop and explain the error in plain English.
- **Never use `--force`** on any git command.
- **Never push to main** directly.
- **Never skip hooks** (`--no-verify`).
- **Only create new files** — never modify or delete existing files.
- If the user lacks push access, tell them to request collaborator access from the repo owner.
- If a skill name is taken, ask for a different name — do not overwrite.
- If any git operation fails unexpectedly, show the error output and suggest the user ask for help.
