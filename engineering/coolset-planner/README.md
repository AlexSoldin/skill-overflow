# Coolset Planner

Planning workflow for Coolset: fetch Linear tickets, explore the codebase across repos, and generate structured implementation plans with architecture diagrams and AI instructions.

## Setup

### Serena cross-repo project

The planner uses [Serena](https://github.com/oraios/serena) for semantic code analysis across all Coolset repos. For this to work, Serena needs a project config at the **parent directory** above all repos.

Create the file `~/projects/coolset/.serena/project.yml` (adjust the path to wherever your repos live):

```yaml
# Coolset umbrella project — gives Serena cross-repo access
languages:
  - python
  - typescript

ignored_paths:
  - "**/node_modules/**"
  - "**/.venv/**"
  - "**/venv/**"
  - "**/__pycache__/**"
  - "**/.git/**"
  - "**/dist/**"
  - "**/build/**"
  - "**/.next/**"
  - "**/migrations/**"
  - "**/*.egg-info/**"
  - "**/sandbox/**"
  - "**/sql/**"
```

Your directory structure should look like:

```
~/projects/coolset/
├── .serena/
│   └── project.yml    ← this file
├── cs-api/
├── cs-pulse/
├── cs-scranton/
├── cs-common/
├── coolset-react-app/
└── ...
```

### Disable Serena's browser popup (optional)

Serena opens a web dashboard on every launch by default. To disable:

In `~/.serena/serena_config.yml`, set:

```yaml
web_dashboard_open_on_launch: false
```

The dashboard remains available at `http://localhost:24282/dashboard/` if needed.

## Usage

```
/coolset-planner:plan CS-1234
```

Or with a description:

```
/coolset-planner:plan Add bulk import for supplier emissions
```
