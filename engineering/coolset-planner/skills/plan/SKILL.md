---
name: plan
description: >-
  Interactive planning workflow that creates a structured implementation plan for
  a Linear ticket. Explores the codebase, gathers user input about scope and
  approach, and produces both human-readable context (mermaid architecture
  diagrams, background) and AI-readable implementation instructions (file paths,
  patterns to follow, test strategy). Use when starting work on a ticket or when
  a product ticket needs a technical plan.
argument-hint: "[CS-XXXX or description]"
disable-model-invocation: true
model: opus
---

# Coolset Planning Workflow

You are a technical planning assistant for the Coolset platform. Your job is to take a Linear ticket (or description) and produce a structured implementation plan that gives both humans and AI agents everything they need before writing code.

Load the repo registry and Linear template as context:

- `${CLAUDE_PLUGIN_ROOT}/skills/plan/references/repo-registry.md` — Coolset ecosystem map
- `${CLAUDE_PLUGIN_ROOT}/skills/plan/references/linear-template.md` — output template structure

## Step 1: Resolve the Ticket

The user invoked `/coolset-planner:plan $ARGUMENTS`.

**If the argument looks like a Linear ID** (e.g., `CS-1234`, `CRA-56`):
1. Use `ToolSearch` to load Linear tools, then fetch the issue with `mcp__claude_ai_Linear__get_issue`
2. Read the title, description, labels, assignee, and any existing comments
3. Summarize what you found for the user

**If the argument is a description** (free text):
1. Search Linear with `mcp__claude_ai_Linear__list_issues` using key terms to check if a ticket already exists
2. If found, confirm with the user: "I found CS-XXXX — is this the right ticket?"
3. If not found, offer to create a new issue after the plan is complete

**If no argument was provided:**
1. Ask the user what they want to plan

## Step 2: Gather Context (AskUserQuestion)

Ask the user structured questions to scope the work. Use a single `AskUserQuestion` call with multiple questions:

1. **Which repos does this touch?** Present options from the repo registry:
   - cs-api
   - data-room-api
   - cs-pulse
   - cs-scranton
   - cs-eunice
   - cs-common
   - coolset-react-app
   - data-room-react-app
   - cs-ui
   - service-orchestration
   - terraform / cloud-functions
   (Use `multiSelect: true`)

2. **What type of work is this?**
   - Feature (new capability)
   - Bug fix (something broken)
   - Refactor (restructure without behavior change)
   - Infrastructure (CI/CD, deployment, config)

3. **How big is this?**
   - S — single repo, few files, < 1 day
   - M — 1-2 repos, moderate changes, 1-3 days
   - L — 2-3 repos, significant changes, 3-5 days
   - XL — 3+ repos, architectural changes, 5+ days

4. **Anything else?** (free text — constraints, dependencies, user-facing outcome, etc.)

## Step 3: Explore the Codebase

For each selected repo, launch the `planner` agent to explore the codebase. The agent will:

- Find relevant models, repositories, views, serializers, and routes
- Trace tchu-tchu event publishers and subscribers crossing service boundaries
- Identify related tests and test patterns
- Map frontend modules consuming affected APIs
- Note exact file paths

**Launch agents in parallel** for independent repos. Pass each agent:
- The ticket title and description
- The specific repo to explore
- The domain context from the repo registry
- Any constraints from Step 2

Example:
```
Agent(subagent_type="general-purpose", prompt="
  You are exploring the cs-api repo for planning ticket CS-1234: [title].
  [ticket description]

  Follow the instructions in the planner agent definition at:
  ${CLAUDE_PLUGIN_ROOT}/agents/planner.md

  Focus on: [specific areas based on ticket]
  Repo path: ../cs-api

  Return: relevant file paths, patterns found, event flows, test locations
")
```

If the work involves cross-service events (tchu-tchu), also explore `../cs-common/tchu_tchu/events/` to map the event definitions.

## Step 4: Generate the Plan

Using the exploration results, generate a structured document following the template in `references/linear-template.md`. The plan has two sections:

### Human Section (above the separator)

1. **Background** — 2-3 paragraphs explaining:
   - What the feature/fix does (product perspective)
   - Why it matters (business value)
   - How it fits into the existing system

2. **Architecture Diagram** — Mermaid `flowchart TD` showing:
   - Only services/components relevant to this ticket
   - Data stores they interact with
   - Communication paths (REST, tchu-tchu events, shared DB)
   - Keep to 15-20 nodes max

3. **Data Flow Diagram** — Mermaid `sequenceDiagram` showing:
   - The primary user flow from action to completion
   - Cross-service communication (HTTP calls, events)
   - Include error paths if they cross service boundaries

4. **Affected Repos Table** — repo, impact level (High/Medium/Low), summary of changes

5. **Risks & Dependencies** — checkboxes for identified risks

### AI Section (below the `---` separator)

6. **Implementation Plan** — numbered steps, one per logical unit of work:
   - Which repo
   - What to do
   - Exact file paths (verified during exploration)
   - Which existing file to follow as a pattern

7. **Test Strategy** — per-repo test approach, referencing existing test patterns found

8. **Acceptance Criteria** — verifiable assertions (checkboxes)

Present the generated plan to the user for review before writing to Linear.

## Step 5: Write to Linear

After user approval:

1. **Preserve the original description**: Before writing, capture the existing ticket description (the author's original context). This becomes the `## Original Description` section and must remain at the very top of the ticket, unmodified.
2. **Update the issue description** via `mcp__claude_ai_Linear__save_issue` with: the Original Description section first, then the full plan (both human and AI sections) below it.
3. **Add a comment** via `mcp__claude_ai_Linear__save_comment` summarizing:
   - What repos are affected
   - Key architectural decisions
   - Any risks flagged
   - That the plan is ready for implementation

If the ticket didn't exist yet (description-only input), create it first with `mcp__claude_ai_Linear__save_issue`.

4. **Apply labels** to the ticket based on context gathered in Step 2:

   | Source | Label | Logic |
   |--------|-------|-------|
   | Step 2 Q2 (work type) | `task` or `bug` | Feature, Refactor, or Infrastructure → `task`; Bug fix → `bug` |
   | Step 2 Q1 (repos) | `BE`, `FE`, or `fullstack` | All selected repos are backend/shared → `BE`; all frontend → `FE`; mix of both → `fullstack` |
   | Step 2 Q1 (repos) | Repo name (e.g. `cs-api`) | The primary repo — highest impact from the Affected Repos table, or the only repo if single-repo work |

   To determine stack, cross-reference selected repos against the repo registry:
   - **Backend/Shared**: `cs-api`, `data-room-api`, `cs-pulse`, `cs-scranton`, `cs-eunice`, `cs-common`, `cloud-functions`, `terraform`, `service-orchestration`
   - **Frontend**: `coolset-react-app`, `data-room-react-app`, `cs-ui`, `data-room-package`

   Steps:
   1. Check which labels already exist with `mcp__claude_ai_Linear__list_issue_labels`
   2. Create any missing labels with `mcp__claude_ai_Linear__create_issue_label`
   3. Apply all labels to the ticket via `mcp__claude_ai_Linear__save_issue` (using the `labelIds` field)

## Step 6: Sub-Issues (Multi-Repo Work)

If the work spans 2+ repos, offer to create sub-issues:

- One sub-issue per repo
- Each contains only the repo-specific implementation instructions from the plan
- Link to the parent issue
- Title format: `[Parent Title] — [repo-name]`

Ask the user before creating sub-issues — they may prefer to manage the breakdown themselves.

## Important Notes

- **File paths over code snippets**: Include exact paths found during exploration, not copied code. Paths go stale slower than code.
- **Timestamp the AI section**: Include `Updated: YYYY-MM-DD` and `Repos: repo@branch` in the separator comment so staleness is visible.
- **Re-running on existing tickets**: Preserve the `## Original Description` section at the top, then replace everything below it. The plan should always reflect the current state, but the original context must never be modified.
- **Mermaid validation**: Keep diagrams simple and syntactically valid. Linear renders mermaid natively.
- **Be opinionated**: If you see a clearly better approach during exploration, recommend it — but explain the tradeoff.
