---
description: Create a content brief for a Coolset Academy article from keywords and competitive research
allowed-tools:
  - Read
  - Write
  - Edit
  - WebSearch
  - WebFetch
  - Grep
  - Glob
argument-hint: [primary keyword + any secondary keywords or topic context]
model: opus
---

Create a content brief for a Coolset Academy article based on the user's input: $ARGUMENTS

Load the academy-writing skill for Coolset voice, structure and topic guidance. Also read these reference files:
- @${CLAUDE_PLUGIN_ROOT}/skills/academy-writing/references/style-guide.md
- @${CLAUDE_PLUGIN_ROOT}/skills/academy-writing/references/ai-optimization.md

If a product copy matrix exists in the working folder or plugin references, load it before drafting the "How software helps" section.

Follow this workflow step by step. Present each step to the user for feedback before moving to the next.

## Step 1: Confirm inputs and fill gaps

The user provides the primary keyword and topic context. Before proceeding, confirm or ask for anything not provided:

- **Primary keyword:** As provided by the user. If only a topic was given, ask the user to specify their target keyword.
- **Secondary keywords (5-7):** If not provided, suggest based on related searches – but confirm with the user before using.
- **Target persona:** Ask which audience this targets if not stated:
  - Sustainability/ESG reporting leaders
  - Supply chain/procurement managers
  - Compliance/risk stakeholders
  - Operational leads supporting ESG (finance, IT, product/packaging)
- **Search intent:** Classify as informational / navigational / commercial / transactional and confirm with the user.
- **Brief trigger:** Ask whether this is driven by a regulatory update/news or a content gap – this affects the angle.

Do not proceed to research until the user has confirmed these inputs.

## Step 2: Competitor analysis

Search for the primary keyword and analyze the top 5 ranking results. For each, fetch the full page and document:

- Title and URL
- Word count (approximate)
- Strengths: What they do well – depth, structure, examples, authority
- Weaknesses: What they miss, get wrong, cover superficially, or fail to make practical

Then summarize the competitive opportunity:

- What value can Coolset's article add that these don't provide?
- Where can we go deeper, be more hands-on, or speak more directly to our personas?
- What angle or framing would differentiate us?

## Step 3: People Also Ask research

Search the primary keyword and collect PAA (People Also Ask) questions. Also search 2-3 secondary keywords for additional PAA results.

Present all PAA questions found, grouped by theme. Recommend which ones to:

- Answer as H2 sections (substantial enough for a full section)
- Answer in the FAQ (can be handled in under 60 words)
- Skip (off-topic or too generic)

## Step 4: Internal content audit

Search for existing Coolset Academy articles related to this topic. Keep searches tight — use only the primary keyword to stay focused and avoid loading irrelevant results:

- Search "site:coolset.com/academy [primary keyword]"
- Search "site:coolset.com [primary keyword]" (catches product pages and non-academy content)

Only add a secondary keyword search if the primary keyword returns fewer than 3 results AND that secondary keyword represents a meaningfully different concept. For example, if the brief is about "PPWR" and that search yields little, it may be worth also searching "packaging regulation" — but skip the extra search if primary results are sufficient.

If working in a local folder, also scan for existing article files.

Document:

- Existing articles to link to from the new piece (title + URL)
- Existing articles that should link back to the new piece once published
- Content overlap check: Flag if an existing article already targets this keyword. If overlap is found, STOP and ask the user whether to: (a) update the existing article instead, (b) differentiate the new one and specify how, or (c) proceed anyway. Do not continue until the user decides.

## Step 5: CTA resource matching

Search for downloadable resources and webinars that relate to the article topic:

- Search "site:coolset.com/downloads [primary keyword]" and "site:coolset.com/downloads [broader topic]"
- Search "site:coolset.com/webinars [primary keyword]" and "site:coolset.com/webinars [broader topic]"
- Also try fetching coolset.com/downloads and coolset.com/webinars directly to browse available resources if search results are thin.

For each relevant resource found, document:

- Title and URL
- Type: Download (guide, checklist, template, whitepaper) or Webinar (live, on-demand)
- Topic match: Why this resource fits the article topic – be specific

Recommend placement:

- **Mid-article CTA:** The resource that best matches the section where the reader is deepest in the problem (e.g., a checklist after a "what to collect" section, a guide after an explainer section). The goal is a natural next step – the reader should feel like the CTA answers "I want to go deeper on this."
- **Bottom CTA:** The resource with the broadest relevance to the overall article topic, or a product page if no download/webinar fits.

If no relevant resources are found on either page, note this in the brief as a content gap so the team can consider creating one.

## Step 6: Build the brief

Compile the brief using this structure:

```
# Content Brief: [H1 Title]

**Date:** [today's date]
**Brief type:** Regulatory update / Content gap
**Primary keyword:** [keyword]
**Secondary keywords:** [5-7 terms]
**Search intent:** [type]
**Target persona:** [persona from Step 1]

## Description
[Short paragraph on what the article covers and for whom.]

## Unique POV
[What makes this article different from competitor content. What lens are we using? Why is Coolset's take more practical, more tailored, or more in-depth?]

## Outline + FAQs

H2: Introduction – [core question or why it matters]
- Brief context and link to pillar page
- Internal links:
  - [relevant academy article]
  - [relevant academy article]

H2: [Key requirement or explainer section – phrased as user question]
- What the regulation demands in this area
- Internal/External links

H2: [Step-by-step / Practical walkthrough – phrased as user question]
- H3: [Sub-step 1]
- H3: [Sub-step 2]
- H3: [Sub-step 3]
- Internal links:
  - [product page]
  - [related academy article]
  - [downloadable resource]

H2: [What to collect / ask / verify – phrased as user question]
- Checklist or bullet format
- External links: (authoritative sources – EU Commission, EEA, etc.)

H2: How [Coolset / software] helps with [topic]
- Tie into Coolset product capabilities using approved messaging from product copy matrix
- Bottom CTA: [matched resource from Step 5 – download, webinar, or product page]

H2: FAQ
- [PAA question 1]
- [PAA question 2]
- [PAA question 3]
- [PAA question 4]
- [PAA question 5 – if relevant]

## Length
- Target: 1,600-1,800 words
- FAQ included if PAA matches found

## Competition
| # | Title | URL | Word count | Strengths | Weaknesses |
|---|-------|-----|-----------|-----------|------------|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |

## SEO
- Primary keyword: [keyword]
- Secondary keywords: [5-7 terms]
- Keyword placement:
  - Primary: title, intro, body, conclusion
  - Secondary: subheads + paragraph leads

## Internal link targets
- [List of coolset.com/academy URLs to link to]
- [List of existing articles that should eventually link back to this one]

## Content CTAs
- Mid-article CTA:
  - Resource: [title of matched download or webinar]
  - URL: [coolset.com/downloads/... or coolset.com/webinars/...]
  - Placement: After [which H2 section] – [why it fits here]
- Bottom CTA:
  - Resource: [title of matched download, webinar, or product page]
  - URL: [URL]
  - Text: [one-line value prop tied to the article topic]
- Gap flag: [note if no suitable resource exists – suggest what type of resource would fit]

## Key sources
- [Authoritative sources found during research with URLs]

## Notes
- [Any specific requirements, angles to avoid, or context from the user]
```

Save the brief as a markdown file using the format: `brief-[slug].md` (e.g., `brief-ppwr-compliance-guide.md`).

Briefs are planning documents — deliver locally only. If the user later asks to push resulting content to Webflow CMS, follow the Webflow interaction rules in the academy-writing skill.
