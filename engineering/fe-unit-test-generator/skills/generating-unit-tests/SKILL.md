---
name: generating-unit-tests
description: |
  This skill should be used when generating unit tests for React/TypeScript source files
  in projects that use Vitest and @testing-library/react. It applies when a user asks to
  "generate unit tests", "write tests for", "add test coverage", "create tests for", or
  "test this file". It covers React components, custom hooks, and utility/service functions,
  and handles mock strategy selection (vi.mock and msw), TypeScript compliance, import alias
  resolution from tsconfig.json, and running and validating the generated tests.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Unit Test Generator

Generate comprehensive, colocated unit tests for React/TypeScript source files. Tests use Vitest with `@testing-library/react` and follow the project's established patterns.

## Step 1: Read Project Configuration

Read the following files from the project root before generating anything:

1. `vite.config.ts` / `vite.config.js` / `vitest.config.ts` — confirm `environment: "jsdom"` and note `setupFiles` location (typically `./src/test/setup.ts`)
2. `tsconfig.json` — extract `compilerOptions.paths` to know available import aliases at runtime

Do not assume alias names. Read them from the file.

## Step 2: Analyze the Source File

Read the source file and identify:

1. **File type** — detected from exports and naming:
   - **React component**: exports a PascalCase function returning JSX
   - **Custom hook**: function name starts with `use`
   - **Utility/service**: all other exported functions, classes, or constants

2. **All exported symbols** — every function, class, and type exported from the file

3. **External dependencies** — non-relative imports (candidates for mocking)

4. **Async operations** — `async/await`, `useEffect`, data fetching calls

5. **Side effects** — callbacks, event handlers, context mutations

## Step 3: Check for Existing Test File

Colocate test files alongside source files:

- `src/modules/foo/Bar.tsx` → check for `src/modules/foo/Bar.test.tsx`
- `src/helpers/formatDate.ts` → check for `src/helpers/formatDate.test.ts`

If a test file already exists, **merge** new test cases into it rather than overwriting.

## Step 4: Determine Mock Strategy

**Use `msw` when** the source file:
- Contains `fetch()` calls
- Imports `axios` or a dedicated HTTP client
- Calls an API client that makes network requests

**Use `vi.mock()` when** the source file:
- Imports modules that need to be isolated (stores, routers, contexts, utilities)
- Uses browser APIs (`localStorage`, `matchMedia`, `ResizeObserver`)
- Uses timers or `Date`

Both strategies can be combined in the same test file. See `references/mocking-patterns.md` for implementation examples.

## Step 5: Resolve Import Paths

When writing import statements in the generated test file:

1. Read the `paths` extracted from `tsconfig.json` in Step 1
2. Check if the source file's location maps to one of those aliases
3. Prefer the alias: `import { Foo } from 'modules/foo/Foo'`
4. Fall back to a relative path if no alias covers the file's location

## Step 6: Generate Tests

### React Component Pattern

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MyComponent } from './MyComponent';

describe('MyComponent', () => {
  it('renders with default props', () => {
    render(<MyComponent label="Hello" />);
    expect(screen.getByText('Hello')).toBeInTheDocument();
  });

  it('calls onChange when user interacts', async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<MyComponent onChange={onChange} />);
    await user.click(screen.getByRole('button'));
    expect(onChange).toHaveBeenCalledOnce();
  });

  it('renders nothing when hidden prop is true', () => {
    const { container } = render(<MyComponent hidden />);
    expect(container).toBeEmptyDOMElement();
  });
});
```

**Rules:**
- Always use `userEvent.setup()` — never `fireEvent` for user interactions
- Query priority: `getByRole` → `getByText` → `getByLabelText` → `getByTestId` (last resort)
- Use `waitFor` for async state updates
- Test behavior, not implementation (avoid class name assertions unless they change behavior)
- Cover: default render, every meaningful prop, all user interactions, async states, error states

### Custom Hook Pattern

```tsx
import { renderHook, act } from '@testing-library/react';
import { useMyHook } from './useMyHook';

describe('useMyHook', () => {
  it('returns correct initial state', () => {
    const { result } = renderHook(() => useMyHook());
    expect(result.current.value).toBeNull();
    expect(result.current.isLoading).toBe(false);
  });

  it('updates state when action is called', () => {
    const { result } = renderHook(() => useMyHook());
    act(() => {
      result.current.setValue('new value');
    });
    expect(result.current.value).toBe('new value');
  });

  it('handles async operations', async () => {
    const { result } = renderHook(() => useMyHook());
    await act(async () => {
      await result.current.fetchData();
    });
    expect(result.current.data).not.toBeNull();
  });

  it('cleans up on unmount', () => {
    const { unmount } = renderHook(() => useMyHook());
    expect(() => unmount()).not.toThrow();
  });
});
```

**Rules:**
- Wrap synchronous state updates in `act()`
- Wrap async actions in `await act(async () => { ... })`
- Test `unmount()` if the hook registers listeners or timers
- Test re-renders with `rerender` if inputs change

### Utility Function Pattern

```ts
import { formatDate } from './dateUtils';

describe('formatDate', () => {
  it('formats a valid date correctly', () => {
    expect(formatDate(new Date('2024-01-15'))).toBe('15 Jan 2024');
  });

  it('returns empty string for null', () => {
    expect(formatDate(null)).toBe('');
  });

  it('handles edge case: leap year date', () => {
    expect(formatDate(new Date('2024-02-29'))).toBe('29 Feb 2024');
  });

  it('throws on invalid input', () => {
    expect(() => formatDate('not-a-date')).toThrow('Invalid date');
  });
});
```

**Cover:** happy path, `null`/`undefined`/empty inputs, boundary values, and error conditions.

### TypeScript Compliance

Test files are excluded from `tsconfig.json` compilation (`"exclude": ["src/**/*.test.ts", "src/**/*.test.tsx"]`) but are still type-checked by Vitest at test time. Ensure:

- All imports are correctly typed
- Use `as unknown as Type` for complex mocks rather than `as any`
- Vitest globals (`describe`, `it`, `expect`, `vi`) are available without import (configured globally in the vitest config)

## Step 7: Run and Validate

After writing the test file:

```bash
npx vitest run <test-file-path>
```

If tests fail:
1. Read the error output carefully
2. Fix import paths, incorrect assertions, or missing mocks
3. Re-run until all tests pass
4. Report final results to the user: file path, test count, pass/fail
