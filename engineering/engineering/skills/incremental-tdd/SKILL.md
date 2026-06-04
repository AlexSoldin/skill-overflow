---
name: incremental-tdd
description: Use when implementing a BE Linear ticket (cs-api, cs-scranton, cs-pulse, data-room-api, cs-common) whose acceptance criteria you want to drive one slice at a time with strict TDD discipline (red → green → commit per AC). Python/pytest/Django only — not for FE work. Pairs with /coolset-planner:plan as the source of ACs.
args: issue_id [--ac N]
---

# incremental-tdd

Drive one acceptance-criterion-sized TDD slice end-to-end: read the Linear ticket, pick the next unaddressed AC, write a failing pytest, confirm it fails for the right reason, implement minimally, confirm it passes, commit. Then stop. Invoke again for the next slice.

## Core principle

**One AC → one failing test → one minimal implementation → one commit.** Each invocation handles a single slice. The skill produces small, traceable commits and explicit verification at each step. No batching. No "I'll write tests after."

## When to use

- The ticket has an `## Acceptance Criteria` section (written by `/coolset-planner:plan` as "verifiable assertions" — checkboxes).
- You want per-AC traceability: each AC maps to a test, a commit, and a checked box on the ticket.
- You want test-first discipline enforced, not just suggested.
- You're working in cs-api, cs-scranton, cs-pulse, data-room-api, or cs-common.

**Do not use** for:
- Tickets without acceptance criteria (run `/coolset-planner:plan` first, or pass an AC list manually).
- FE work (this skill targets BE only).
- Single-line changes where TDD is overkill.
- Refactoring with no behavioral change.

## Usage

```
/engineering:incremental-tdd CS-1234              # pick the next unaddressed AC
/engineering:incremental-tdd CS-1234 --ac 2       # target AC 2 explicitly (1-indexed)
```

If no argument is provided, infer the issue ID from the current branch name (`CS-1234/...`).

## Workflow

### Step 1 — Read the ticket

Fetch the issue via the Linear MCP tool:

```
mcp__claude_ai_Linear__get_issue(id: "<issue_id>")
```

Find the `## Acceptance Criteria` section. Parse the checkbox list, marking which are checked. Read the **Affected Repos** table to identify which repo(s) the work touches.

**If the AC section is missing**, prompt:

> "This ticket hasn't been planned. Run `/coolset-planner:plan CS-1234` first, or paste an AC list now (one per line)."

Accept a manual AC list as a fallback.

### Step 2 — Pick the slice

Walk the AC list top to bottom. Pick the first AC that is both:
1. Unchecked in the Linear ticket, AND
2. Lacking a test exercising its behavior (check the current diff and existing test files).

`--ac N` overrides selection and targets the 1-indexed AC explicitly.

State the slice to the user and confirm before writing tests:

> "Working on AC2: vendor can disable notifications. Proceed?"

If multiple ACs would touch the same file in incompatible ways, surface it and ask which to do first.

### Step 3 — RED: Write the failing test

Follow the test patterns documented in the repo's CLAUDE.md:

- **File location:** Mirror source structure. `services/notification_service.py` → `tests/services/test_notification_service.py`. Views → `tests/views/test_*.py`. Repositories → `tests/repositories/test_*.py`.
- **Naming:** `test_<method>__<scenario>` with double-underscore separator. Example: `test_disable_for_vendor__updates_notification_settings`.
- **Function-based only.** No class-based tests.
- **Fixtures:** Use `baker.make()` from `model_bakery`. Place reusable fixtures in `tests/fixtures/<model>.py`, re-exported via `tests/fixtures/__init__.py`. Inline `baker.make()` only for single-use cases.
- **conftest scope:** Auth, client, event-patching, and autouse infrastructure only. Model fixtures do NOT belong in conftest.
- **DB access:** Pass `db` as a fixture argument: `def test_x(db, auth_client, ...):`. Avoid the `@pytest.mark.django_db` decorator.
- **Auth fixture pick:**
  - `auth_client` — most view tests (uses `force_authenticate`)
  - `basic_auth_client` — only when the test exercises the real Basic Auth login flow
  - `api_key_auth_client` — API key auth tests
- **Mocking:** Mock external clients and services only (third-party APIs, Stripe, Firebase admin). Test internal services, repos, and models through fixtures.
- **Avoid `_private_fields`** in tests. Test through the public API.
- **Performance-sensitive code:** Use `django_assert_num_queries` to lock expected query counts.
- **URLs (cs-api only):** Inline URLs in each test. Avoid module-level `BASE_URL` constants.
- **Helpers (cs-pulse only):** Avoid `_make_*` setup helpers in test files. Use a fixture in `tests/fixtures/<model>.py` instead.
- **Structure:** Arrange-Act-Assert. One assertion per concept.

### Step 4 — Verify failure (red, for the right reason)

Run the new test in isolation:

```bash
pytest <test-file>::<test-name> -x
```

The failure must be **behavioral**, not a setup mistake:

| Failure | Real red? |
|---|---|
| `AssertionError` (expected behavior absent) | ✅ |
| `AttributeError` (missing method or attribute) | ✅ |
| Wrong HTTP status, wrong response shape | ✅ |
| `ImportError`, missing fixture, syntax error | ❌ — fix the test first |

**If the test passes immediately,** halt and surface:

> "The AC may already be implemented, or the test is too weak. Review before continuing."

Do not proceed silently.

### Step 5 — GREEN: Implement minimally

Follow Coolset layering:

- **Queries** → repository methods in `<app>/repositories/`
- **Business logic** → service methods in `<app>/services/`
- **HTTP layer** → views in `<app>/views/` (thin: validate, call service, return serialized response)

Rules:

- Make the smallest change that turns the failing test green.
- No new abstractions. No scope expansion. Leave adjacent code alone.
- If you notice an unrelated issue, note it in the user-facing report — do not fix it in this slice.
- Re-run the targeted test until it passes.

### Step 6 — Verify the full suite

Run the full test suite to catch regressions:

```bash
make tests          # cs-api, cs-scranton, cs-pulse, data-room-api
make test           # cs-common (singular)
```

Halt on any regression. Do not paper over with skips, xfails, or edits to unrelated tests.

### Step 7 — Commit (one slice = one commit)

Stage only files touched in this slice:

```bash
git add tests/services/test_notification_service.py \
        notifications/services/notification_service.py \
        notifications/views/notification_settings_view.py
git commit -m "feat(notifications): vendor can disable notifications (CS-1234 AC2)

- test: tests/services/test_notification_service.py::test_disable_for_vendor__updates_settings
- impl: notifications/services/notification_service.py::disable_for_vendor
- impl: notifications/views/notification_settings_view.py"
```

Do **not** push or open a PR. Pushing belongs to `/engineering:commit-push-pr` at the end of the ticket flow.

### Step 8 — Tick the AC and report

Tick the AC checkbox on the Linear ticket:

```
mcp__claude_ai_Linear__save_issue(id: "<issue_id>", description: "<updated description with the AC checkbox now [x]>")
```

Then report to the user:

- AC addressed (e.g. "AC2 ✅")
- Test names added
- Files touched
- Remaining unchecked ACs and the next-step invocation
- If all ACs are done: suggest `/engineering:commit-push-pr`

## Repo-aware behavior

Detect the repo from the current working directory + git remote, then adapt:

| Repo | Event system | Test command | Notes |
|---|---|---|---|
| cs-api | tchu-tchu | `make tests` | Inline URLs in tests |
| cs-scranton | celery-salt (`SaltEvent`, `@subscribe(Event)`) | `make tests` | Queue: `scranton_queue` |
| cs-pulse | celery-salt | `make tests` | No `_make_*` helpers in tests |
| data-room-api | celery-salt | `make tests` | Queue: `data_room_queue` |
| cs-common | n/a | `make test` (singular) | Pure logic only; DB-heavy tests belong in consuming services |

For event-related slices, consult the affected-repos table in the Linear ticket plus the local repo context before generating test code.

## Edge cases

| Situation | Action |
|---|---|
| No ACs in ticket | Prompt to run `/coolset-planner:plan`, or accept a manual AC list. |
| AC has no test-shaped behavior ("performance should be good") | Ask the user how to translate it into a verifiable assertion, or skip with explicit acknowledgment. |
| Test passes immediately | Halt. AC may be done already, or test is too weak. |
| Test fails for the wrong reason (`ImportError`, missing fixture, syntax) | Fix the test first; this is not a real red. |
| AC requires a migration | Allowed. Flag it prominently in the user report and the commit message. |
| AC requires cs-common changes | Invoke `cross-repo-validator` before commit. If validation surfaces breaking changes to consumers, halt and surface them. |
| AC spans multiple repos | Refuse and ask the user to split into two slices, one per repo. |
| Wider test suite regresses after the slice | Halt. Do not skip tests, edit unrelated tests, or commit. |

## Common rationalizations to refuse

| Excuse | Reality |
|---|---|
| "This AC is trivial, I'll skip the test" | The test takes a minute and documents intent. Trivial code breaks too. |
| "I'll batch multiple ACs into one slice" | Batching loses traceability and makes the diff harder to review. One AC, one commit. |
| "The test passed immediately, that's fine, move on" | Halt. The test is either weak or the AC was already done. Both deserve attention. |
| "I'll write the test after the implementation works" | Tests written after implementation test what the code does, not what it should do. Write the failing test first. |
| "The full suite regression is unrelated, I'll skip those tests" | A green suite is the contract. Investigate the regression; do not skip. |
| "Refactoring this nearby code is part of the slice" | It is not. Scope discipline — note it for a separate slice, then leave it alone. |
| "Mocking the internal service is faster than setting up fixtures" | Use fixtures. Mocking internal services hides real failure modes. |

## Red flags — STOP

- Writing implementation code before a failing test exists
- Test passes on first run (no fail-then-pass cycle)
- Multiple ACs touched in one commit
- Tests skipped or xfailed to make the suite green
- Files modified outside the slice's natural surface area
- Commit pushed before the rest of the ticket flow has run

**Any of these means: stop, undo, restart the slice properly.**

## Composition with other skills

- `coolset-planner:plan` — soft prerequisite. Produces the AC list this skill consumes.
- `engineering:ticket` — runs independently for now. Invoke `incremental-tdd` manually after `ticket` reaches its implementation step. Integration into `ticket` step 3 is deferred to a follow-up PR after this skill has been validated in real use.
- `engineering:commit-push-pr` — runs after the last AC ships. This skill never pushes.
- `engineering:cross-repo-validator` (existing agent) — invoked automatically before commit when the slice touches cs-common.
