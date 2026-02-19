---
name: component-dev
description: This skill should be used when the user asks to "build a new component", "create a component", "implement a component from Figma", "add a component to cs-ui", "scaffold a component", or wants to create a new React component in the cs-ui library. Guides the full workflow from Figma design inspection through to complete implementation including the component file, CSS, Storybook story, and test file.
version: 1.0.0
---

# New Component Workflow

Guide the user through building a complete, production-ready component for the cs-ui v2 library (`src/components/`). Each component must have a `.tsx` component file, a `.css` file, a `.stories.tsx` Storybook story, a `.test.tsx` test file, and an `index.ts` barrel export.

## Phase 1 — Gather Requirements

Before writing any code, collect the following. If any item is missing, ask the user before proceeding.

**Required inputs:**
- **Figma node ID** — the specific node to inspect (e.g. `15232-184960`). If the user hasn't provided one, ask: *"What is the Figma node ID for this component? You can find it in the URL when you select the frame in Figma (the `node-id` query parameter)."*
- **Component name** — use the name shown in Figma (PascalCase, e.g. `Button`, `DatePicker`). If the Figma frame name is ambiguous, confirm with the user before proceeding.

**Nice-to-have (ask if unclear from Figma):**
- Does this component wrap a native HTML element? (e.g. `<button>`, `<input>`, `<select>`)
- Should it use `forwardRef`? (yes for any component that wraps an interactive/focusable element)
- Are there sub-components (e.g. `ButtonGroup` alongside `Button`)?

## Phase 2 — Inspect the Figma Design

Use the Figma MCP server to fetch design data. Call the appropriate Figma MCP tool with the node ID provided. Extract:

- **Variants** — list all variant properties (e.g. `size: sm | md | lg`, `variant: primary | secondary | destructive`)
- **States** — hover, focus, disabled, error, loading, etc.
- **Design tokens** — colors, spacing, border radius, typography. Map these to the existing CSS custom properties in `src/components/` (e.g. `var(--Text-color-text)`, `var(--Spacing-spacing-sm)`, `var(--Radii-radius-md)`). If a token from Figma has no match in `defaults.css`, note that a new token will need to be added.
- **Sub-components** — nested frames that may become separate component files
- **Figma component URL** — extract the full Figma URL for the `design` parameter in the story metadata

If the Figma MCP is unavailable or returns an error, tell the user and ask them to paste the relevant design details manually.

## Phase 3 — Check shadcn/ui for a Base

Before writing from scratch, use the shadcn MCP tools to check if a matching component exists:
- `mcp_shadcn_view_items_in_registries` — search the registry for the component name
- `mcp_shadcn_get_item_examples_from_registries` — fetch usage examples

If a shadcn equivalent exists, use it as the structural starting point. Keep its accessibility patterns (ARIA attributes, keyboard navigation, Radix primitive usage) and adapt the styling to match the Figma design using the project's CSS custom properties. Replace all Tailwind utility classes with `CSUI-` prefixed class names and CSS variables.

If no shadcn equivalent exists, implement from scratch following the patterns below.

## Phase 4 — Fetch Library Documentation

Use the context7 MCP tools to pull up-to-date docs for the libraries involved in this component before writing any code.

**Always fetch docs for:**
- **React** — resolve with `mcp__plugin_context7_context7__resolve-library-id` (query: `"react"`), then query docs for the APIs in use (e.g. `"forwardRef"`, `"useRef"`, `"useState"`) — focus the topic on whichever hooks/APIs the component will need
- **@testing-library/react** — resolve (query: `"@testing-library/react"`), then query docs for `"render screen userEvent"` to confirm current best-practice query patterns

**Fetch conditionally:**
- If a **shadcn component** was found in Phase 3 — resolve `"shadcn/ui"` and query docs for the specific component (e.g. `"Dialog"`, `"Select"`)
- If the shadcn component is built on a **Radix primitive** — resolve the relevant `"@radix-ui/react-*"` package and query docs for its props and composable parts (e.g. `"Trigger Content Overlay"`)
- If the component will need **complex state** (e.g. date pickers, multi-select, comboboxes) — fetch docs for any relevant utility library already in the project's `package.json`

Use the resolved library ID with `mcp__plugin_context7_context7__query-docs`. If context7 returns an error or cannot resolve a library, note it and continue — docs are informational, not blocking.

Briefly summarise what you found (key prop names, patterns, caveats) so the user can see what informed the implementation.

## Phase 5 — Plan the Component API

Before writing code, outline the TypeScript interface. Confirm with the user if any props are ambiguous:

```ts
export interface ComponentNameProps extends React.HTMLAttributes<HTMLElement> {
  variant?: 'primary' | 'secondary';   // from Figma variants
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  // callback props for all significant interactions
  onSomeAction?: (value: string) => void;
  // escape hatches always present via ...rest spread
}
```

Rules:
- Extend the appropriate native HTML element attributes (`HTMLButtonElement`, `HTMLInputElement`, etc.) for full prop pass-through
- Use `forwardRef` for any component that wraps a focusable/interactive element
- Always set `displayName` on `forwardRef` components
- Provide sensible defaults for optional props

## Phase 6 — Create the Component Files

Create all files in `src/components/ComponentName/`. Use PascalCase for both the directory and file names.

### File: `ComponentName.tsx`

```tsx
import { forwardRef } from 'react';
import { getClasses } from '../../lib/utils';
import './ComponentName.css';

export interface ComponentNameProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
}

export const ComponentName = forwardRef<HTMLDivElement, ComponentNameProps>(
  ({ variant = 'primary', size = 'md', className, children, ...rest }, ref) => {
    const classes = getClasses(
      'CSUI-component-name',
      `CSUI-component-name-variant-${variant}`,
      `CSUI-component-name-size-${size}`,
      className,
    );
    return (
      <div ref={ref} className={classes} {...rest}>
        {children}
      </div>
    );
  },
);
ComponentName.displayName = 'ComponentName';
```

Key rules:
- **Never** import from `lib/components/` — v2 components are fully independent
- Use `getClasses()` from `../../lib/utils` for className joining
- CSS class naming: `CSUI-[component]`, `CSUI-[component]-[prop]-[value]`
- JSDoc every exported interface and component
- Handle all Figma variants and states

### File: `ComponentName.css`

```css
/* ============================================================
   CSUI-component-name
   ============================================================ */

.CSUI-component-name {
  /* base styles using CSS custom properties */
  color: var(--Text-color-text);
  background-color: var(--Backgrounds-color-bg-secondary);
  border-radius: var(--Radii-radius-md);
  padding: var(--Spacing-spacing-sm) var(--Spacing-spacing-md);
  transition: background-color var(--t-time);
}

/* ---- Variants ---- */
.CSUI-component-name-variant-primary { ... }
.CSUI-component-name-variant-secondary { ... }

/* ---- Sizes ---- */
.CSUI-component-name-size-sm { ... }
.CSUI-component-name-size-md { ... }
.CSUI-component-name-size-lg { ... }

/* ---- States ---- */
.CSUI-component-name:hover { ... }
.CSUI-component-name:focus-visible { ... }
.CSUI-component-name:disabled,
.CSUI-component-name[aria-disabled="true"] { ... }
```

Key rules:
- **Only** use CSS custom properties — no Tailwind, no hardcoded colour hex values
- Use `visibility: hidden` + `opacity: 0` rather than `display: none` for animated elements
- Use `var(--t-time)` for transition timing
- If a required token doesn't exist in `defaults.css`, add it there following the Figma naming convention

### File: `ComponentName.stories.tsx`

```tsx
import { useState } from 'react';
import type { Meta, StoryObj } from '@storybook/react-vite';
import { ComponentName, ComponentNameProps } from './ComponentName';

const meta = {
  title: 'Components/ComponentName',
  component: ComponentName,
  parameters: {
    layout: 'padded',
    design: {
      type: 'figma',
      url: 'https://www.figma.com/design/...?node-id=XXXXX',  // from Phase 2
    },
  },
  tags: ['autodocs'],
  argTypes: {
    variant: { control: { type: 'select' }, options: ['primary', 'secondary'] },
    size: { control: { type: 'select' }, options: ['sm', 'md', 'lg'] },
  },
} satisfies Meta<ComponentNameProps>;

export default meta;
type Story = StoryObj<ComponentNameProps>;

// ===========================================
// BASIC STORIES
// ===========================================

export const Default: Story = {
  args: { variant: 'primary', size: 'md', children: 'Label' },
};

// ===========================================
// VARIANT SHOWCASE
// ===========================================

export const AllVariants: Story = {
  render: () => (
    <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
      <ComponentName variant="primary">Primary</ComponentName>
      <ComponentName variant="secondary">Secondary</ComponentName>
    </div>
  ),
};

// ===========================================
// INTERACTIVE DEMO
// ===========================================

export const Interactive: Story = {
  render: () => {
    const [active, setActive] = useState(false);
    return (
      <ComponentName onClick={() => setActive(!active)}>
        {active ? 'Active' : 'Click me'}
      </ComponentName>
    );
  },
};
```

Key rules (from `.cursorrules`):
- Import from `@storybook/react-vite`, not `@storybook/react`
- Every story requiring state must use `render: () => { const [x] = useState(...); return ... }` — never put state in `args`
- Every interactive story must have an obvious trigger — never require users to manually toggle Controls to see the component work
- Include a `design` parameter with the Figma URL
- Organize stories into sections with `// ===` comment dividers
- Include: Default, AllVariants, AllSizes (if applicable), and at least one interactive story per stateful component

### File: `ComponentName.test.tsx`

```tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ComponentName } from './ComponentName';

test('renders with default props', () => {
  render(<ComponentName>Label</ComponentName>);
  expect(screen.getByText('Label')).toBeInTheDocument();
});

test('applies variant class', () => {
  const { container } = render(<ComponentName variant="secondary">Label</ComponentName>);
  expect(container.firstChild).toHaveClass('CSUI-component-name-variant-secondary');
});

test('forwards ref', () => {
  const ref = { current: null };
  render(<ComponentName ref={ref}>Label</ComponentName>);
  expect(ref.current).not.toBeNull();
});

test('calls onClick when clicked', async () => {
  const user = userEvent.setup();
  const onClick = vi.fn();
  render(<ComponentName onClick={onClick}>Click</ComponentName>);
  await user.click(screen.getByText('Click'));
  expect(onClick).toHaveBeenCalledTimes(1);
});
```

Key rules:
- Test rendering, class application per variant/size, forwarded ref, and callback props
- Use `@testing-library/react` + `@testing-library/user-event` (already in devDependencies)
- Use `vi.fn()` from Vitest (globals are enabled)
- Test keyboard interactions for focusable elements (`userEvent.keyboard('{Enter}')`, `'{Escape}'`)

### File: `index.ts`

```ts
export type { ComponentNameProps } from './ComponentName';
export { ComponentName } from './ComponentName';
```

## Phase 7 — Register the Export

Add the component's exports to `src/main.tsx`:

```ts
export * from './components/ComponentName/ComponentName';
```

If the component has additional named exports (sub-components, type aliases), list them explicitly.

## Phase 8 — Verify

After all files are written:

1. Run `pnpm tsc --noEmit` (or `npx tsc --noEmit`) to check for TypeScript errors
2. Run `pnpm test` to ensure tests pass
3. Run `pnpm storybook` (or note to the user to verify in Storybook) to confirm stories render correctly

Report any errors and fix them before declaring the component complete.

## Quick Reference: Checklist

- [ ] Figma node ID obtained and design inspected
- [ ] Component name confirmed (PascalCase, matches Figma)
- [ ] shadcn/ui base checked
- [ ] context7 docs fetched for React, testing-library, and any shadcn/Radix primitives in use
- [ ] Props interface defined and reviewed
- [ ] `src/components/ComponentName/ComponentName.tsx` created
- [ ] `src/components/ComponentName/ComponentName.css` created (CSS variables only)
- [ ] `src/components/ComponentName/ComponentName.stories.tsx` created (with Figma URL)
- [ ] `src/components/ComponentName/ComponentName.test.tsx` created
- [ ] `src/components/ComponentName/index.ts` created
- [ ] Export added to `src/main.tsx`
- [ ] TypeScript type-check passes
- [ ] Tests pass
