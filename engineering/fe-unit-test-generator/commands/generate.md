---
description: Generate colocated unit tests for a TypeScript or React source file. Analyzes the file type (component, hook, or utility), reads project config for import aliases and test setup, then creates or merges a .test.tsx/.test.ts file using Vitest and @testing-library/react. Runs the generated tests to validate them.
argument-hint: "<path/to/source-file.tsx>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
---

# Generate Unit Tests

The user has provided a file path to generate unit tests for.

## Steps

1. **Get the file path**: The argument contains the source file path. If no argument was provided, ask: "Which file would you like me to generate tests for?"

2. **Follow the `generating-unit-tests` skill**: Use the full skill workflow — read project config, analyze the source file, check for an existing test file, determine mock strategy, resolve import aliases, and generate a comprehensive test file.

3. **Run the tests**: After writing the file, run:
   ```bash
   npx vitest run <test-file-path>
   ```
   If tests fail, read the error, fix the issue, and re-run until all tests pass.

4. **Report results**: Tell the user:
   - The path of the test file created or updated
   - How many test cases were written
   - Final test run results (pass/fail counts)
