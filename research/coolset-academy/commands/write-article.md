---
description: Write a Coolset Academy article from a brief
allowed-tools:
  - Read
  - Write
  - Edit
  - WebSearch
  - WebFetch
  - Grep
  - Glob
argument-hint: [topic or brief]
model: opus
---

Write a Coolset Academy article based on the user's brief: $ARGUMENTS

Load the academy-writing skill for Coolset voice, structure and style guidance. Also read these reference files for detailed rules:
- @${CLAUDE_PLUGIN_ROOT}/skills/academy-writing/references/style-guide.md
- @${CLAUDE_PLUGIN_ROOT}/skills/academy-writing/references/content-examples.md
- @${CLAUDE_PLUGIN_ROOT}/skills/academy-writing/references/ai-optimization.md

Follow this workflow step by step:

## Step 1: Understand the brief

Read the brief carefully. Identify the target topic, angle and key points to cover. Note any specific requirements (word count, sections, CTAs, content type). If the brief is unclear or missing critical information, ask the user to clarify before proceeding.

## Step 2: Research

Conduct thorough web research before writing anything.

- Search for current statistics, regulatory updates and timelines related to the topic
- Prioritize authoritative sources: EU Commission, Eurostat, EEA, official regulatory bodies
- Find real-world examples and case studies
- Search for existing Coolset articles to link internally: search "site:coolset.com [topic]"
- Verify all statistics – if a source cannot be cited, do not include the statistic

Present a short research summary to the user showing the key facts, sources and internal links found.

## Step 3: Outline

Create and present an outline for approval:

- H1 title (descriptive, informative, not clever for cleverness' sake)
- Introduction approach (what hook, what context)
- H2 sections – each phrased as a natural user question
- Planned bullet point sections or lists
- Conclusion angle and CTA
- FAQ questions (3–5)

Wait for the user to approve or adjust the outline before writing.

## Step 4: Write

Write the full article following Coolset voice and style rules:

- Professional, smart, conversational tone. Active voice throughout.
- Third person for explanations, second person for instructions.
- Short sentences. Paragraphs of 2–3 sentences max.
- American English. Sentence case. No Oxford comma unless needed for clarity.
- Spell out acronyms on first use. Hyphens (–) not em-dashes (—).
- No bold in-text. No filler phrases. No passive constructions.
- Cite all statistics with sources directly in text.
- Include internal Coolset links where relevant.
- Start each section with a direct, factual answer to the H2 question.
- Repeat key terms instead of pronouns (CSRD, not "it").
- Use bullet points for processes, comparisons and lists.
- End with a FAQ section (3–5 questions, answers under 60 words each).

## Step 5: Quality check

Before delivering, verify every item:

- All statistics cited with sources
- Acronyms spelled out on first use
- Active voice throughout (no passive constructions)
- Paragraphs are 2–3 sentences
- H2s read as natural user questions
- Each section opens with a direct answer
- Internal Coolset links included
- No filler phrases ("in conclusion," "let's explore," "moreover")
- American English spelling
- Sentence case capitalization
- FAQ section present with answers under 60 words
- Clear next steps or CTA at the end
- Real-world examples included
- Tone is professional, smart, conversational – not academic or salesy

Save the final article as a markdown file.
