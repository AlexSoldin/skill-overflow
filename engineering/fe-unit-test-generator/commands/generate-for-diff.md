---
description: Generate unit tests for all TypeScript/React source files changed in the current git diff. Skips test files, stories, configs, and files that already have tests. Accepts an optional git ref to diff against (default: HEAD).
argument-hint: "[git-ref]  # e.g. main, HEAD~1, or leave empty for staged+unstaged changes"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
---

# Generate Unit Tests for Git Diff

Generate tests for every eligible source file that has changed in the current diff.

## Step 1: Determine the diff scope

If an argument was provided, use it as the base ref:
```bash
git diff --name-only <arg>
```

If no argument was provided, collect both staged and unstaged changed files:
```bash
git diff --name-only HEAD
```

Collect the full list of changed file paths.

## Step 2: Filter eligible files

From the list, keep only files that match **all** of the following:

- Extension is `.ts` or `.tsx`
- Does **not** match any exclusion pattern:
  - `*.test.ts` / `*.test.tsx`
  - `*.d.ts`
  - `*.config.ts` / `*.config.js` / `*.config.mts` / `*.config.cjs`
  - `*.stories.tsx` / `*.stories.ts`
  - `main.tsx` / `main.ts`
  - `App.tsx` / `App.ts`
  - `index.ts` / `index.tsx`
  - Any path containing `/test/`
  - `vite.config.*` / `vitest.config.*` / `tailwind.config.*`

For each file that passes the filter, use Glob to check for a colocated test file (e.g. `Foo.tsx` → `Foo.test.tsx`). **Skip files that already have a test file**, unless the test file was also changed in the diff (meaning it may need new cases).

If no eligible files remain after filtering, tell the user and stop.

## Step 3: Report the plan

Before generating anything, tell the user:
- How many files were found in the diff
- How many are eligible for test generation (list them)
- How many were skipped and why (already have tests, excluded type, etc.)

## Step 4: Generate tests for each eligible file

For each eligible file, apply the full **`generating-unit-tests` skill** workflow:

1. Read project config (`vite.config.ts`, `tsconfig.json`)
2. Analyze the source file (type, exports, dependencies, async ops)
3. Check for an existing test file — merge if present, create if absent
4. Determine mock strategy (`msw` vs `vi.mock`)
5. Resolve import aliases from `tsconfig.json`
6. Write the test file

After writing each test file, run:
```bash
npx vitest run <test-file-path>
```

If tests fail, read the error, fix the issue, and re-run until all tests pass.

## Step 5: Summary report

After processing all files, report:
- Total files generated or updated
- Test counts per file
- Any files that could not be completed and why
