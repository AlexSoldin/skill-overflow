---
description: Optimize an existing article for AI search discoverability
allowed-tools:
  - Read
  - Write
  - Edit
  - WebSearch
  - WebFetch
argument-hint: [file path or paste article]
---

Optimize an existing article for AI search discoverability using Coolset's LLM optimization rules.

Load the AI optimization reference:
@${CLAUDE_PLUGIN_ROOT}/skills/academy-writing/references/ai-optimization.md

Also load the style guide to ensure edits stay on-voice:
@${CLAUDE_PLUGIN_ROOT}/skills/academy-writing/references/style-guide.md

If the user provided a file path, read it. Otherwise, work with the pasted content.

Apply these optimizations in order:

## 1. Rewrite H2s as user questions

Transform all H2 headings into natural language questions that the target persona (sustainability managers, compliance officers, CFOs) would ask. Keep them descriptive and informative.

Show the user a before/after comparison of each H2 before making changes.

## 2. Add answer-first openings

Check the first 1–2 sentences of each section. If a section does not open with a short, factual answer to its H2 question, rewrite the opening. Remove any warm-up language, broad introductions or fluff.

## 3. Replace pronouns with key terms

Scan for pronouns ("it," "they," "this," "the regulation") that refer to key regulatory terms, frameworks or organizations. Replace with the specific name. Keep it natural – do not over-repeat within the same sentence.

## 4. Add structured formats

Identify sections that explain processes, comparisons or decision logic. Convert these to bullet points, numbered lists or step-by-step formats where they are currently written as dense paragraphs.

## 5. Flag opportunities for proprietary content

Identify 2–3 places where Coolset-specific insights, frameworks or product capabilities could be added. Suggest specific additions – do not insert generic placeholder text.

## 6. Add or improve FAQ section

If no FAQ section exists, create one with 3–5 questions based on the article's content. If a FAQ exists, check that answers are under 60 words and questions use natural phrasing. Improve as needed.

## 7. Anchor abstract concepts

Find any theoretical or abstract passages. Suggest or write specific, practical examples to replace them.

## Delivery

Present a summary of all changes made, organized by category. Save the optimized article as a new file (append "-optimized" to the filename). Do not overwrite the original.
