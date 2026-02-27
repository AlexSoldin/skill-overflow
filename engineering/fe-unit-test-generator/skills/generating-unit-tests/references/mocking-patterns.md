# Mocking Patterns

Reference patterns for mocking dependencies in Vitest tests. Use these when implementing Step 4 of the generating-unit-tests skill.

## vi.mock — Module Isolation

Use when the source file imports modules that need to be isolated (stores, contexts, routers, utilities, or any non-network dependency).

```ts
// At top of file, before other imports
vi.mock('modules/api/client', () => ({
  apiClient: {
    get: vi.fn().mockResolvedValue({ data: [] }),
    post: vi.fn().mockResolvedValue({ data: { id: 1 } }),
    put: vi.fn().mockResolvedValue({ data: { id: 1 } }),
    delete: vi.fn().mockResolvedValue(undefined),
  },
}));

afterEach(() => vi.clearAllMocks());
```

### Partial module mock (keep some real implementations)

```ts
vi.mock('modules/formatting/dateUtils', async (importOriginal) => {
  const real = await importOriginal<typeof import('modules/formatting/dateUtils')>();
  return {
    ...real,
    formatDate: vi.fn().mockReturnValue('01 Jan 2024'),
  };
});
```

### React context mock

```ts
vi.mock('contexts/AuthContext', () => ({
  useAuth: vi.fn().mockReturnValue({
    user: { id: '1', name: 'Alice' },
    isAuthenticated: true,
    logout: vi.fn(),
  }),
}));
```

### Router mock (react-router-dom)

```ts
vi.mock('react-router-dom', async (importOriginal) => {
  const real = await importOriginal<typeof import('react-router-dom')>();
  return {
    ...real,
    useNavigate: vi.fn().mockReturnValue(vi.fn()),
    useParams: vi.fn().mockReturnValue({ id: '123' }),
  };
});
```

---

## msw — HTTP Network Interception

Use when the source file contains `fetch()`, imports `axios`, or calls an HTTP client that makes network requests. MSW intercepts at the network level, giving higher confidence than mocking the HTTP client directly.

### Basic setup

```ts
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';

const server = setupServer(
  http.get('/api/users', () =>
    HttpResponse.json([{ id: 1, name: 'Alice' }])
  ),
  http.post('/api/users', () =>
    HttpResponse.json({ id: 2, name: 'Bob' }, { status: 201 })
  ),
  http.delete('/api/users/:id', () =>
    new HttpResponse(null, { status: 204 })
  ),
);

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Override handler for a specific test

```ts
it('handles server error', async () => {
  server.use(
    http.get('/api/users', () =>
      HttpResponse.json({ message: 'Internal server error' }, { status: 500 })
    )
  );
  // test error state...
});
```

### Simulating network delay

```ts
import { delay } from 'msw';

http.get('/api/users', async () => {
  await delay(100);
  return HttpResponse.json([{ id: 1, name: 'Alice' }]);
});
```

---

## Browser API Mocks

Use for components that depend on browser APIs not available in jsdom.

### localStorage / sessionStorage

```ts
beforeEach(() => {
  Object.defineProperty(window, 'localStorage', {
    value: {
      getItem: vi.fn(),
      setItem: vi.fn(),
      removeItem: vi.fn(),
      clear: vi.fn(),
    },
    writable: true,
  });
});
```

### matchMedia

```ts
beforeEach(() => {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: vi.fn().mockImplementation((query: string) => ({
      matches: false,
      media: query,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  });
});
```

### ResizeObserver

```ts
beforeEach(() => {
  global.ResizeObserver = vi.fn().mockImplementation(() => ({
    observe: vi.fn(),
    unobserve: vi.fn(),
    disconnect: vi.fn(),
  }));
});
```

### IntersectionObserver

```ts
beforeEach(() => {
  global.IntersectionObserver = vi.fn().mockImplementation(() => ({
    observe: vi.fn(),
    unobserve: vi.fn(),
    disconnect: vi.fn(),
  }));
});
```

---

## Timer Mocks

Use for components or hooks with `setTimeout`, `setInterval`, `Date`, or `requestAnimationFrame`.

```ts
beforeEach(() => {
  vi.useFakeTimers();
});

afterEach(() => {
  vi.useRealTimers();
});

it('debounces input', async () => {
  const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime });
  render(<SearchInput />);
  await user.type(screen.getByRole('searchbox'), 'hello');
  vi.advanceTimersByTime(300); // advance past debounce delay
  expect(screen.getByText('Results for: hello')).toBeInTheDocument();
});
```

---

## Decision Guide

| Scenario | Strategy |
|----------|----------|
| Component calls `fetch()` or `axios` | msw |
| Component uses an API module (e.g. `apiClient.get(...)`) | vi.mock the module |
| Hook uses `useNavigate` or `useParams` | vi.mock react-router-dom |
| Component reads/writes `localStorage` | Browser API mock |
| Component reads from a React context | vi.mock the context hook |
| Function uses `Date.now()` or timers | vi.useFakeTimers() |
| Mix of HTTP calls and module imports | msw + vi.mock |
