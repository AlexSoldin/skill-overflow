---
description: Review a draft against Coolset Academy guidelines
allowed-tools:
  - Read
  - WebSearch
  - WebFetch
argument-hint: [file path or paste article]
---

Review an article draft against Coolset Academy content guidelines and provide specific, actionable feedback.

Load the style guide and content examples for reference:
@${CLAUDE_PLUGIN_ROOT}/skills/academy-writing/references/style-guide.md
@${CLAUDE_PLUGIN_ROOT}/skills/academy-writing/references/content-examples.md

If the user provided a file path, read it. Otherwise, work with the pasted content.

Evaluate the draft across these categories and provide a score (Pass / Needs work / Fail) for each:

## 1. Voice and tone

Check for:
- Professional, smart and conversational tone (not academic or promotional)
- Active voice throughout – flag every passive construction found
- Confidence without being dry or condescending
- No filler phrases ("in conclusion," "let's explore," "moreover," "thus")
- No over-the-top language ("groundbreaking," "revolutionary") without evidence
- No first person unless quoting Coolset directly
- No sarcasm

## 2. Structure and readability

Check for:
- H1 is descriptive and informative
- H2s read as natural user questions
- Introduction hooks with context before diving into regulation
- Paragraphs are 2–3 sentences max
- Sentences are short and readable
- Line breaks support scannability
- Conclusion has clear next steps or CTA

## 3. Formatting and style

Check for:
- American English spelling
- Sentence case capitalization (no excessive caps)
- Acronyms spelled out on first mention
- Hyphens (–) not em-dashes (—)
- No Oxford comma (unless needed for clarity)
- No bold text within paragraphs
- Bullet points used appropriately for lists and processes

## 4. Content quality

Check for:
- Statistics cited with sources in-text
- Real-world examples grounding abstract concepts
- No editorializing or speculation without regulatory/source backing
- No repeated definitions or summaries
- Authoritative sources (EU Commission, Eurostat, EEA)
- Regulatory timelines mentioned where relevant

## 5. SEO and AI readability

Check for:
- Each section opens with a direct, factual answer
- Key terms used instead of pronouns
- FAQ section present (for Academy blogs/reports) with answers under 60 words
- Internal Coolset links included
- Structured formats (bullets, lists, steps) for processes and comparisons

## 6. Coolset alignment

Check for:
- Coolset is not oversold (inform and guide, not pitch)
- Content helps readers understand what's changing, why it matters and what to do next
- Relevant Coolset topics referenced where appropriate (CSRD, EUDR, EU Taxonomy, etc.)

## Delivery

Present the review as a scorecard with the six categories. For each category scored "Needs work" or "Fail," provide specific examples from the text and concrete suggestions for fixing them. End with a prioritized list of the top 3–5 changes that would most improve the article.

This command produces feedback only — it does not make any changes to content. If the user asks to apply review suggestions to Webflow CMS, follow the Webflow interaction rules in the academy-writing skill: capture the before state, confirm the exact changes with the user, apply only after explicit approval, and save the after state locally (or commit to GitHub if available).
