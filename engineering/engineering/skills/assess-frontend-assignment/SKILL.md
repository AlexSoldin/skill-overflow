---
name: assess-frontend-assignment
description: >-
  This skill should be used when the user asks to "assess a frontend assignment",
  "review a candidate's submission", "grade a frontend take-home", "evaluate a
  frontend assignment", or wants to score and review a candidate's Coolset frontend
  position assessment submission.
---

# Frontend Assignment Assessment

Systematically evaluate a candidate's Coolset frontend position submission and produce a structured scorecard.

## Usage

```
/assess-frontend-assignment <path-to-submission>
```

If no path is provided, ask the user: *"What is the path to the candidate's submission directory?"*

---

## Phase 1 — Locate and Understand the Submission

### 1a. Find the project root

Navigate to the given path and confirm it contains a valid frontend project:
- Must have a `package.json`
- Should have a `src/` directory with React/TypeScript source files
- May have `vite.config.ts`, `tsconfig.json`, `vitest.config.ts`, or similar config files

If the path contains multiple sub-directories (e.g., a top-level folder with `coolset-assignment/` inside), find the correct project root automatically using Glob.

### 1b. Read the candidate's README

Check for a `README.md`. If present, read it for:
- Self-reported TODOs or known gaps
- Architecture decisions the candidate called out
- Any notes about what they ran out of time on

Note these explicitly — they show self-awareness and should factor into the overall assessment.

---

## Phase 2 — Static Code Analysis

Read the source files to assess the following dimensions. Do **not** run the project yet — static analysis first.

### 2a. Component Architecture

Check whether the submission implements the required component hierarchy:

**Atoms (each earns +1 point):**
- `Button` with at least two modes/variants
- `Header` (or typography component) with multiple levels
- `Select` (or dropdown) component

**Molecules (each earns +1 point):**
- `DataTable` as the main molecule
- Sub-components: `DataTableCaption`, `DataTableHead`, `DataTableHeadCell`, `DataTableRow`, `DataTableRowCell`, `DataTableFooter` (award partial credit if some are present)

For each component found, note its file path and a brief description of how it's implemented.

### 2b. Functional Requirements

Inspect the source to determine whether each requirement is met:

| Requirement | What to look for |
|---|---|
| **Sorting** | Sort handler, sorted state, clickable column headers, sort icons |
| **Filtering by section** | Filter state, filter UI control (dropdown or input), filtered data logic |
| **Pagination** | Page state, page size selector, slice/chunk logic on data |
| **Sticky header** | `position: sticky`, `top: 0`, or equivalent CSS on `<thead>` or header row |

Rate each as: ✅ Implemented | ⚠️ Partial | ❌ Missing

### 2c. TypeScript Quality

- Are props typed with explicit interfaces or types? (no `any`, no implicit types)
- Are event handlers typed correctly (e.g., `React.ChangeEvent<HTMLSelectElement>`)?
- Are generics used where appropriate (e.g., `DataTable<T>` with typed row data)?
- Is there consistent use of `interface` vs `type`?

Rate overall TypeScript usage: **Strong** / **Adequate** / **Weak**

### 2d. React Best Practices

- Are components logically split (single responsibility)?
- Is state managed at the right level (lifted where needed, not over-centralised)?
- Are side effects isolated in `useEffect` with proper dependencies?
- Are callbacks memoised with `useCallback` where appropriate?
- Is `key` prop used correctly in lists?
- Is `forwardRef` used for interactive/focusable components?

### 2e. Accessibility (a11y)

- Does `<table>` have a `<caption>` or `aria-label`?
- Do sortable column headers use `aria-sort` attributes?
- Do interactive elements (buttons, selects) have accessible labels?
- Is keyboard navigation possible for sorting and pagination controls?
- Are there any obvious ARIA misuses (e.g., non-interactive elements with click handlers and no role)?

Rate overall a11y: **Strong** / **Adequate** / **Weak** / **Missing**

### 2f. Responsive Design

- Is there CSS media query usage or responsive layout techniques (flexbox, grid, relative units)?
- Does the table handle overflow on small screens (horizontal scroll, responsive collapse)?
- Are font sizes and spacing using relative units (`rem`, `em`, `%`)?

Rate: **Strong** / **Adequate** / **Weak** / **Missing**

### 2g. Code Style and Cleanliness

- Consistent naming conventions (PascalCase for components, camelCase for functions/variables)
- No unused imports or dead code
- Logical file/folder organisation
- Reasonable file lengths (no god components)
- Descriptive variable and function names

---

## Phase 3 — Storybook

Check if Storybook is set up:
- Does `.storybook/` exist?
- Are there `*.stories.tsx` or `*.stories.ts` files?
- Do stories cover the main `DataTable` component with meaningful variants?
- Are controls/args defined to make stories interactive?

Rate: ✅ Present and meaningful | ⚠️ Present but minimal | ❌ Absent

---

## Phase 4 — Tests

### 4a. Check for test files

Look for `*.test.tsx`, `*.test.ts`, `*.spec.tsx`, or `*.spec.ts` files.

Note what is tested:
- Are components rendered and basic output asserted?
- Are interactions tested (sorting click, filter change, pagination click)?
- Are edge cases tested (empty data, single page, all items in one section)?

### 4b. Run the tests

```bash
cd <submission-path> && npm test -- --run 2>&1
```

Or if Vitest config uses a different command, adapt accordingly.

Report:
- Total tests: X passing, Y failing
- Paste any failure output verbatim (truncated to first 20 lines per failure)

### 4c. Run TypeScript type check

```bash
cd <submission-path> && npx tsc --noEmit 2>&1
```

Report the number of type errors (0 is great; list up to 5 representative errors if any).

---

## Phase 5 — Scorecard

After completing all analysis phases, produce a structured scorecard:

---

### Assessment: `<Candidate Name or Path>`

**Date:** `<today's date>`

#### Functional Requirements

| Requirement | Status | Notes |
|---|---|---|
| Sorting | ✅/⚠️/❌ | |
| Filtering by section | ✅/⚠️/❌ | |
| Pagination + page size | ✅/⚠️/❌ | |
| Sticky header | ✅/⚠️/❌ | |

#### Component Architecture

| Component | Present | Notes |
|---|---|---|
| Button (2 modes) | ✅/❌ | |
| Header / Typography | ✅/❌ | |
| Select | ✅/❌ | |
| DataTable | ✅/❌ | |
| DataTable sub-components | ✅/⚠️/❌ | List which ones |

#### Quality Dimensions

| Dimension | Rating | Summary |
|---|---|---|
| TypeScript | Strong/Adequate/Weak | |
| React best practices | Strong/Adequate/Weak | |
| Accessibility | Strong/Adequate/Weak/Missing | |
| Responsive design | Strong/Adequate/Weak/Missing | |
| Code style | Strong/Adequate/Weak | |
| Storybook | Present/Minimal/Absent | |
| Tests | X passing / Y failing | |
| TypeScript errors | 0 / N errors | |

#### Candidate Self-Reported Gaps

> [Paste anything from the README here, verbatim]

#### Strengths

- Bullet list of 3–5 specific, concrete strengths observed in the code

#### Areas for Improvement

- Bullet list of 3–5 specific gaps or weaknesses

#### Overall Recommendation

**Proceed** / **Borderline** / **Pass**

One paragraph (3–5 sentences) summarising the overall quality, the candidate's apparent skill level, and your recommendation.

---

## Scoring guidance

Use this rubric when forming the Overall Recommendation:

| Signal | Weight |
|---|---|
| All 4 functional requirements implemented correctly | High |
| Strong TypeScript usage (no `any`, properly typed props) | High |
| Accessible markup (ARIA, keyboard nav) | Medium |
| Tests present and passing | Medium |
| Storybook with meaningful stories | Medium |
| Component architecture matches spec | Medium |
| Responsive layout | Low |
| Code cleanliness and organisation | Low |

**Proceed** — Functional requirements met, TypeScript solid, tests present, no major red flags.
**Borderline** — 1–2 functional requirements missing or major quality issues, but strong signal in other areas. Worth a technical interview to probe gaps.
**Pass** — Multiple functional requirements missing, poor TypeScript, no tests, or code quality concerns that indicate the candidate is not ready for this role.

---

## Safety rules

- **Never modify the candidate's code** — read-only analysis only
- **Do not assume** — if a file is ambiguous, read it before drawing conclusions
- **Be specific** — every rating must reference actual file paths and line numbers where possible
- **Be fair** — note what the candidate said they ran out of time on and factor that into the recommendation, but the scorecard must still reflect what was actually delivered
