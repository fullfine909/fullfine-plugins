---
name: poster-prompt
description: Write prompts for AI image models that produce text-heavy posters and infographics — software feature sheets, programme/schedule posters, one-page explainers, event posters. Routes to the right model for the job (Ideogram / GPT Image / Nano Banana), enforces the card-count and exact-string rules, and separates the copy that can be generated from the copy that must be retyped. Use when asked to make a poster, infographic, feature sheet, schedule graphic, or any image whose words have to be legible and correct.
---

# Poster and infographic prompting

For images where the *words* carry the meaning: feature sheets, programme schedules,
one-page explainers, event posters. A different discipline from illustration prompting —
here typography accuracy is the deliverable and the picture is the wrapper.

Grounded in a source sweep dated **2026-08-01** (`~/Documents/Last30Days/best-ai-image-generation-model-for-posters-and-infographics-with-text-raw-v3.md`).
Model rankings move fast. If more than a quarter has passed, re-run
`/last30days best AI image model text rendering` before trusting the routing table.

---

## The one rule that matters

**Generate the look, retype the words.**

Any string a reader will act on — a date, a time, a price, a person's name, a product
name, a URL, a call to action — is rebuilt as an editable text layer in Figma / Canva /
Illustrator after generation. No model is at 100%, and one wrong glyph in
`Sesión 3 · 14:30` makes the poster unusable.

- Image model owns: composition, colour, iconography, style, hierarchy, background, mood.
- Text layer owns: anything that has to be *true*.

Skip the retype step only when the poster is a concept or mood piece nobody will read
literally. Say which mode you are in before writing the prompt.

Corollary: AI infographic generators are optimised for aesthetics, not truth. Any number,
percentage or chart a model draws is decoration until you have verified it against the
real source.

---

## Model routing

| Job | Model | Why |
|---|---|---|
| Many short strings; non-Latin scripts; UI labels | **GPT Image 2** | ~99% text-rendering accuracy incl. CJK, Devanagari, Arabic; #1 on a blind arena of 11,390 human votes |
| Poster and branding layout; typographic craft | **Ideogram 4.0** | Won a blind professional-designer typography study 47.9% vs Nano Banana 2's 30.0%; 0.97 X-Omni English OCR. Note that study was against Nano Banana, **not** GPT Image 2 — the two text leaders have no clean head-to-head |
| One tool for everything; fast iteration | **Nano Banana 2 (Gemini)** | Most consistent all-rounder in hands-on tests; weaker on non-English grammar and spelling per Google's own docs |
| Output must stay editable; data must be exact | **Canva / Venngage / Piktochart** | Template tools, not image models — they emit a real layout, not pixels |
| Editable text straight from the model | **Recraft v4.1 vector** | Emits SVG, so the type is a real layer you can correct — the retype rule solved at the source |
| Do not use for text | Midjourney v8.1, FLUX.2 Pro, Stable Diffusion, Firefly | Aesthetics-first; multi-line copy degrades to gibberish |

**Default ladder**: draft in Nano Banana 2 (cheap iteration) → finish the text-critical
version in Ideogram 4.0 → switch to GPT Image 2 if the poster is string-dense or
multilingual.

**The Ideogram-vs-GPT-Image ranking is contested, not settled.** One 16-model test puts
Ideogram 4.0 first on text accuracy at ~90%; another measures GPT Image 2 at ~99%.
Different benchmarks, no shared blind panel. Do not buy an Ideogram key on the strength
of the table alone — render the same prompt on both and judge with your own eyes. On the
one poster tested here, GPT Image 2 rendered all twelve strings verbatim.

---

## Rendering it

The prompt is this skill's deliverable. Turning it into a file is the `imagegen` CLI
(`~/Dev/tools/imagegen`, symlinked into dj-platform, fullfine-services and pulse as
`scripts/imagegen`). It is a **generic** renderer — it knows models, aspect ratios and
cost, and nothing about posters. All the poster judgement stays in this file.

One OpenRouter key reaches every model in the table above except Ideogram, which has
no OpenRouter endpoint and stays paste-it-yourself.

```bash
just imagegen gen -f prompt.txt -a 3:4             # from a repo with the just lane
python scripts/imagegen/cli.py gen "..." -a 3:4    # inline, from anywhere
python scripts/imagegen/cli.py models              # what the key reaches right now
python scripts/imagegen/cli.py check               # key and alias health, costs nothing
```

Aliases: `text` (GPT Image 2, the default), `pro` (Nano Banana Pro), `flash` (Gemini's
cheaper tier), `vector` (Recraft SVG). Pass a prompt **file** to the `just` lane —
arguments are whitespace-split there, so an inline quoted prompt loses everything after
the first word.

Every render writes a `<name>.prompt.txt` sidecar with the model, parameters and real
cost. Observed spend is $0.007 to $0.04 per image. There is no spend cap: `-n 10` bills
ten. Re-rendering over an existing file aborts unless you pass `--force`.

When handing over a prompt, say which alias to render it with and which strings still
have to be retyped.

---

## Prompt recipe

Eight blocks, in this order. Missing blocks is what produces generic output.

1. **Format and orientation** — `vertical A2 poster`, `16:9 slide`, `square 1:1 social card`
2. **Grid, named explicitly** — `3-column grid`, `2-column grid`, `irregular masonry`. Never leave composition to the model.
3. **Card count, 5 to 9** — a hard ceiling. Every model degrades past nine modules. More content than that is two posters.
4. **Weight** — name the single module that should be largest. Without it everything renders the same size and the poster has no entry point.
5. **Exact strings, quoted** — quote the copy verbatim. Never describe it. `label "DJ Sets"` not `a card about DJ sets`.
6. **Hierarchy** — state where the headline sits and where body copy sits.
7. **Style and palette** — flat / editorial / technical-diagram / brutalist, plus named colours or hex values.
8. **Negative constraint** — `no lorem ipsum, no invented labels, exactly N cards`.

---

## Template: software feature poster

```
Vertical A2 poster. 3-column grid, 6 feature cards. Flat editorial style.

Headline at the top, largest type on the poster: "DigIN"
Subhead directly beneath, one line: "Electronic music discovery"

Six cards, each an icon above a bold label above one line of body text.
The first card spans two columns and is the largest module.
Render these exact strings and no others:

1. label "DJ Sets" — body "Full tracklists, matched track by track"
2. label "Artists" — body "Personas, labels and channels in one graph"
3. label "Library" — body "Everything you saved, in one place"
4. label "Discovery" — body "Surfaces what the algorithms bury"
5. label "Support" — body "Attention that reaches the creator"
6. label "Open data" — body "The scene, made legible"

Palette: near-black background #101010, off-white text, one accent colour.
Typography: geometric sans, tight tracking on the headline.
No lorem ipsum. No invented labels. Exactly six cards.
```

## Template: programme of activities

```
Vertical A3 event poster. Single-column stacked schedule, 7 rows. Editorial, high contrast.

Headline block at the top, three lines:
"Stone Techno"
"Essen · 10-12 July 2026"
"Programme"

Seven schedule rows below. Each row: time on the left in monospace, activity name in
bold beside it, venue in small caps underneath. Row 4 is the largest module.
Render these exact strings and no others:

"10:00  Opening  ·  Sala A"
"11:30  Workshop: Digging  ·  Sala B"
"13:00  Lunch  ·  Patio"
"15:00  Keynote  ·  Main Stage"
"17:00  Panel: Scene Economics  ·  Sala A"
"19:00  Live Set  ·  Main Stage"
"22:00  Closing  ·  Patio"

Palette: two colours only, black and one accent. Generous margins.
No lorem ipsum. No extra rows. Exactly seven rows.
```

---

## Workflow when someone asks for a poster

1. **Collect before prompting.** Exact copy (verbatim), the module count, the palette or brand tokens, the format. Do not invent copy and do not let the model invent it.
2. **Cut to nine.** If the content is more than nine modules, say so and propose the split. Do not silently compress.
3. **Declare the mode.** Concept piece (generate everything) or production piece (generate the look, retype the words). This changes the model choice and the delivery.
4. **Write the prompt** using the eight blocks. Deliver it paste-ready, one fenced block, no commentary inside it.
5. **Name the retype list.** Enumerate which strings the user must rebuild as text layers. This is the deliverable, not an afterthought.

---

## Verification checklist

Run against every generated poster before it goes anywhere:

- [ ] Count the cards or rows. Models add and drop modules silently.
- [ ] Read every glyph. Models double and drop letters mid-word in otherwise clean text.
- [ ] Check digits character by character. Numbers fail more often than letters.
- [ ] Verify diacritics survived (`ó`, `ñ`, `ü`, `ç`) and non-Latin scripts are not decorative nonsense.
- [ ] Verify every number against its real source. Do not trust a chart the model drew.
- [ ] If one string is wrong, do not re-roll hoping for luck. Move that string to a text layer.

---

## Failure modes

| Symptom | Cause | Fix |
|---|---|---|
| Text is gibberish | Wrong model | Move to Ideogram 4.0 or GPT Image 2 |
| Cards multiply or vanish | Count not stated, or above 9 | State the count explicitly; split into two posters |
| Copy is paraphrased | Copy described instead of quoted | Quote every string verbatim in the prompt |
| Right words, shapeless layout | No grid named | Name the grid and the weight module |
| Everything the same size | No weight module | Name the single largest module |
| Looks right, data is wrong | Trusted generated text | Apply the retype rule; verify against source |
| Accents mangled in Spanish/German | Model weak on non-English | GPT Image 2, or retype the affected strings |
