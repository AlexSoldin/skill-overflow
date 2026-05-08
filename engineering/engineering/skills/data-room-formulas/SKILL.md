---
name: data-room-formulas
description: >-
  This skill should be used when the user asks to "write a data room formula",
  "author a survey formula", "create a formula block", "validate a formula
  expression", "fix a formula error", or wants help producing a valid
  `expression` / `fields` payload for a data-room survey Formula block.
  Covers the SymPy-backed evaluator in data-room-api and the CodeMirror
  authoring UI in data-room-react-app, including the gotchas where the two
  diverge.
version: 1.0.0
---

# Authoring Data Room Formulas

Data room surveys support **Formula blocks** whose `expression` is evaluated server-side by `data-room-api` using SymPy. The `data-room-react-app` frontend is purely an authoring UI — there is no client-side evaluator and very little client-side validation, so most invalid formulas only fail after submit. This skill captures the rules an author (or AI agent) must follow to produce a formula that will evaluate successfully on first submit.

## Architecture at a glance

- **Backend evaluator** — `data-room-api/data_room/services/formula_service.py` (`FormulaService`).
  - Parses with `sympy.sympify(expression, evaluate=False)` then computes with `.evalf()`.
  - Substitutes `{field_id}` placeholders via Python `str.format(**field_id_data_points)` *before* parsing.
  - Validates substituted numeric literals with regex (rejects malformed numbers).
- **Frontend authoring** — `data-room-react-app/src/modules/Expressions/components/`.
  - `ExpressionInput.tsx` (v1, MUI `TextField`) and `ExpressionInputV2.tsx` (v2, CodeMirror) — both produce the same `{ expression: string, fields: string[] }` payload.
  - `fields` is derived from `expression` by regex matching `/{([^}]+)}/g` and trimming.
  - Autocomplete only suggests existing blocks of type `Number` or `Formula`. `RadioButton` blocks with numeric option values are also valid references but must be typed manually (see below).

A formula payload looks like:

```json
{
  "expression": "{number__emissions_scope_1} + {number__emissions_scope_2}",
  "fields": ["number__emissions_scope_1", "number__emissions_scope_2"]
}
```

### Field id convention

Every placeholder you write must resolve to an existing field id whose data point value is numeric. In practice that means one of these prefixes:

- `number__…` — a Number block (raw user input). **Preferred.**
- `formula__…` — another Formula block (computed value).
- `radio_button__…` — a Radio Button block, **only if** every option for that block has a numeric `value`. Allowed because option values are controlled by Coolset staff, but the frontend autocomplete will not surface these — you must type the placeholder manually. If any option has a non-numeric value, evaluation fails at runtime with `non-numeric value: <value>`.

Field ids are stable, lowercase, snake_case identifiers (typically `<prefix>__<descriptor>` with a double underscore between prefix and body, e.g. `number__emissions_scope_1`). They're stored as `CharField(max_length=125, unique=True)` per survey. Don't invent ids — reference ones that already exist in the same survey.

## Formula syntax rules (SymPy + Coolset constraints)

### Field references

- Reference other blocks as `{exact_field_id}`. The id must match a `Number` or `Formula` block in the same survey.
- **No whitespace inside braces.** The frontend trims when extracting `fields`, but the expression text is passed verbatim to `str.format`, which looks up the literal key (including any spaces) and raises `KeyError`. Write `{foo}`, never `{ foo }`.
- The set of placeholders in `expression` **must equal** the entries in `fields` (`FormulaService._substitute_placeholders` enforces `set(fields) == set(field_id_data_points.keys())`). No extras, no missing.

### Operators

- Arithmetic: `+`, `-`, `*`, `/`, `**` (exponent), `( )` for grouping.
- **Never use `^` for exponent.** SymPy parses `^` as XOR — silently wrong result, no error. Always use `**`.
- Negation in formula text: prefer `0 - {x}` or `-1 * {x}` over a leading literal `-1`, because the backend regex validator scans positive numeric literals only and may flag malformed combinations.

### Functions

- Use SymPy built-ins only: `sqrt`, `log`, `exp`, `Min`, `Max`, `Abs`, trig (`sin`, `cos`, ...), `Pow`, etc.
- **Do not** use Python or JS conventions like `math.sqrt(x)`, `Math.pow(x, y)` — `sympify` will treat unknown identifiers as symbolic, `.evalf()` returns a non-numeric expression, and the call fails.
- See https://docs.sympy.org/latest/modules/functions/elementary.html for the full list.

### Numeric literals

The backend (`_validate_expression_after_substitution`) rejects:

- **Trailing decimal:** `5.` is invalid. Use `5` or `5.0`.
- **Leading-zero multi-digit integer:** `012` is invalid. Use `12`.

These checks run *after* placeholder substitution, so the same rules apply to values that arrive at runtime.

### Cross-references

- A formula can reference another formula's output (autocomplete includes `Formula`-type blocks).
- Be aware of evaluation order — circular references will fail at evaluation time, not at authoring time.

## Why authoring is "loose" but evaluation is "strict"

The frontend has no SymPy in the browser, so it cannot preview a result. v1 only checks parenthesis/brace parity (`hasUnbalancedBrackets` in `ExpressionInput.tsx`); v2 has no syntax check at all. Every other rule above lands as a backend error after submit. When advising a user, assume any expression they type is **only** validated by parity-of-brackets on the client.

## Authoring checklist

When producing or reviewing a formula:

- [ ] Every `{...}` placeholder uses an exact field id with no internal whitespace.
- [ ] The `fields` array matches the set of placeholders exactly (no extras, no missing).
- [ ] No `^` operator anywhere — exponentiation uses `**`.
- [ ] Function names are SymPy built-ins (`sqrt`, `log`, `exp`, `Min`, `Max`, `Abs`, ...), not `math.*` or `Math.*`.
- [ ] All numeric literals are well-formed (no trailing `.`, no leading zeros).
- [ ] Parentheses and braces are balanced.
- [ ] Referenced blocks exist in the same survey and resolve to a numeric value at runtime — `Number`, `Formula`, or a `RadioButton` whose options are all numeric. Prefer `Number`; only reach for `RadioButton` when the survey already models the input that way.
- [ ] No accidental circular references between formulas.

## Worked examples

### Valid

A simple sum:

```json
{
  "expression": "{number__revenue} + {number__other_income}",
  "fields": ["number__revenue", "number__other_income"]
}
```

Weighted average using parentheses and division:

```json
{
  "expression": "({number__score_a} * 2 + {number__score_b} * 3) / 5",
  "fields": ["number__score_a", "number__score_b"]
}
```

Reusing the same field twice — `fields` is a deduplicated set:

```json
{
  "expression": "{number__value} * {number__value}",
  "fields": ["number__value"]
}
```

Referencing another formula's output:

```json
{
  "expression": "{formula__total_emissions} / {number__revenue}",
  "fields": ["formula__total_emissions", "number__revenue"]
}
```

Using SymPy built-in functions (square root, exponent, absolute value):

```json
{
  "expression": "sqrt({number__a}**2 + {number__b}**2) + Abs({number__delta})",
  "fields": ["number__a", "number__b", "number__delta"]
}
```

### Invalid (and why)

| Expression | `fields` | Backend error | Cause |
|------------|----------|---------------|-------|
| `{ number__a } + {number__b}` | `["number__a", "number__b"]` | `Expected field_ids: {...} not found` | Whitespace inside braces — `str.format` looks up the literal key ` number__a ` and fails. |
| `{number__a} + {number__b}` | `["number__a"]` | `Expected field_ids: {...} not found` | `fields` set doesn't match placeholders — `number__b` missing from `fields`. |
| `{number__a} ^ 2` | `["number__a"]` | Wrong result, no error | `^` is XOR in SymPy. Use `**`. |
| `{number__a} + 5.` | `["number__a"]` | `Formula <id> contains invalid float format: 5.` | Trailing-decimal literal. Use `5` or `5.0`. |
| `{number__a} + 012` | `["number__a"]` | `Formula <id> contains invalid integer format: 012` | Leading-zero integer. Use `12`. |
| `math.sqrt({number__a})` | `["number__a"]` | `Error evaluating formula <id>: ...` | `math.sqrt` is unknown to SymPy. Use bare `sqrt(...)`. |
| `{number__a} / 0` | `["number__a"]` | `Error evaluating formula <id>: ...` | Division by zero at `evalf()` time. |
| `{short_text__name} + {number__a}` | `["short_text__name", "number__a"]` | `Failed to evaluate formula ... non-numeric value: ...` | Referenced block resolves to a non-numeric value. Only blocks whose data point is numeric (`Number`, `Formula`, numeric-only `RadioButton`) can be referenced. |
| `{radio_button__tier} + {number__a}` where `radio_button__tier` has a `"high"` option | `["radio_button__tier", "number__a"]` | `Failed to evaluate formula ... non-numeric value: high` | Radio button is referenceable only if **every** option value is numeric. A single non-numeric option breaks evaluation when that option is selected. |

## Diagnosing a failing formula

If the backend rejects a formula, the error usually maps to one of:

| Symptom | Likely cause |
|--------|--------------|
| `Expected field_ids: {...} not found` | `fields` doesn't match the placeholders in `expression` (often whitespace inside `{ ... }`, or a stale field id). |
| `Formula <id> contains invalid float format: 5.` | Trailing-dot literal — fix to `5` or `5.0`. |
| `Formula <id> contains invalid integer format: 012` | Leading-zero integer — drop the leading zeros. |
| `Error evaluating formula <id>: ...` | SymPy-level failure — usually `^` used as exponent, an unknown function name, division by zero, or a non-numeric result from a missing function. |
| `Failed to evaluate formula ... non-numeric value: <value>` | A referenced field's data point isn't numeric. Most often: a `RadioButton` reference where the selected option's value is a string. Either remove the reference or update the radio block so all options have numeric values. |

## Reference docs to share with an AI agent

When prompting another agent to author formulas, link these alongside this skill:

- SymPy `sympify` parser: https://docs.sympy.org/latest/modules/core.html#sympy.core.sympify.sympify
- SymPy basic operations: https://docs.sympy.org/latest/tutorials/intro-tutorial/basic_operations.html
- SymPy `evalf` numeric evaluation: https://docs.sympy.org/latest/modules/evalf.html
- SymPy elementary functions: https://docs.sympy.org/latest/modules/functions/elementary.html

## Source pointers

- Backend evaluator: `data-room-api/data_room/services/formula_service.py`
- Backend subscriber that drives evaluation: `data-room-api/data_room/subscribers/formula_subscriber.py`
- Frontend authoring (v1): `data-room-react-app/src/modules/Expressions/components/ExpressionInput.tsx`
- Frontend authoring (v2): `data-room-react-app/src/modules/Expressions/components/ExpressionInputV2.tsx`
- Frontend type definitions: `data-room-react-app/src/modules/Expressions/expressions.ts`
