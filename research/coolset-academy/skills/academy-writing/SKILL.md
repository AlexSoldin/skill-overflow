---
name: academy-writing
description: >
  This skill should be used when the user asks to "write an article",
  "create a blog post", "draft academy content", "write about CSRD",
  "write about sustainability", "create Coolset content", or needs
  guidance on Coolset's voice, tone, style rules, or article structure
  for any sustainability or compliance topic.
version: 1.2.0
---

# Coolset Academy Writing

Coolset is an Amsterdam-based platform that helps companies measure, analyze and reduce their emissions. Academy content targets EU-based professionals – from C-level executives to sustainability managers and consultants – who need practical guidance on regulations like CSRD, EUDR and the EU Taxonomy.

## Coolset voice

Write with a professional, smart and conversational tone. Speak with authority without condescension. Be confident without being dry, conversational without being casual. Use active voice, short sentences and 2–3 sentence paragraphs. American English spelling. Sentence case only.

The reader should feel they are in the hands of a team that knows its stuff. Balance subject-matter authority with a friendly, confident tone. Think one step ahead – point readers to additional context, relevant resources, or useful next steps.

## Article structure

**Introduction (3 paragraphs max):**
Open with a hook that resonates with the reader's daily experience. Establish why the topic matters now. Preview what the article covers without saying "this article will cover."

**Body (H2 sections):**
Each H2 should read like a natural user question. Start every section with a short, factual answer – no warm-up. Follow with supporting details, examples and context. Use bullet points for processes, comparisons or lists. Keep paragraphs to 2–3 sentences.

**Conclusion:**
Summarize key takeaways. Provide clear next steps. Include a relevant CTA (contact team, watch webinar, download guide).

**FAQ section (required for Academy blogs and reports):**
3–5 common questions. Answer each in under 60 words. Use natural language questions.

## Core content topics

When relevant, reference: Corporate Sustainability Reporting Directive (CSRD), European Sustainability Reporting Standards (ESRS), double materiality, decarbonization, carbon management, VSME, EU Deforestation Regulation (EUDR), EU Taxonomy, the Omnibus Proposal, Scope 1/2/3 emissions, Greenhouse Gas Protocol.

Spell out terms fully on first mention, then use acronyms.

## Research requirements

Always conduct web research before writing. Prioritize authoritative sources: EU Commission, Eurostat, EEA, official regulatory bodies. Verify all statistics and cite sources directly in text. If a statistic cannot be cited, leave it out. Search for existing Coolset articles to link internally (search: "site:coolset.com [topic]").

## Reference files

For detailed guidance, load the following as needed:

- **`references/style-guide.md`** — Complete language rules, do's/don'ts, punctuation, formatting
- **`references/content-examples.md`** — Example introductions, sections, bullet point usage, FAQ format
- **`references/ai-optimization.md`** — Rules for making content LLM-discoverable (H2s as questions, answer-first, FAQ structure)

## Webflow interaction rules

These rules apply to all commands in this plugin: write-article, optimize-article, content-brief, and review-article.

### 1. Never rewrite or publish without explicit user confirmation

Before making any change to Webflow CMS content — whether that is updating a CMS item, editing page content, or publishing — stop and ask the user for explicit confirmation. Describe exactly what will be changed (which item, which fields, what the new content will be) and wait for an affirmative response before proceeding. This applies to every individual write, update, and publish action.

Do not batch multiple changes into a single confirmation. Each distinct content change should be confirmed separately so the user has full visibility.

### 2. Capture before-and-after snapshots for every change

Before making any Webflow CMS change, save the current state of the content being modified to a local file. After the change is applied, save the new state as well. This creates a clear audit trail.

Use the following file naming convention and save to the working directory:

```
webflow-changes/
  YYYY-MM-DD_HH-MM_[slug-or-item-name]/
    before.md     ← current content fetched from Webflow before changes
    after.md      ← new content after changes are applied
    changeset.md  ← summary: what changed, why, and user confirmation reference
```

If a GitHub repository is available, commit these snapshots so the team can review the history of all Webflow interactions. Use descriptive commit messages (e.g., "Update CSRD article intro – confirmed by user").

### 3. Default to local file delivery

When writing new content (articles, briefs, optimized drafts), always save the output as a local file first. Only push content to Webflow CMS if the user explicitly asks for it — and even then, follow rules 1 and 2 above.

### 4. Never publish a Webflow site without explicit confirmation

Publishing makes changes live. Always confirm with the user before calling any site publish action, and state clearly which domains will be affected.
