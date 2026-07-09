# RoamingOS — Investor Deck

A single self-contained investor pitch deck: [`index.html`](index.html).

Everything is inlined — styles, scripts, fonts, and images (base64) — so the
file needs **no build step and no dependencies**. Open it in a browser and it runs.

## View locally

Just open the file:

```
open index.html
```

Or serve it (needed if you want the correct routing / to mimic Pages):

```
node .claude/serve.mjs   # serves on http://localhost:4599
```

## Deploy

Pushing to `main` publishes `index.html` to GitHub Pages via
[`.github/workflows/deploy-pages.yml`](.github/workflows/deploy-pages.yml).
The workflow just copies `index.html` into the Pages artifact — no build.

## Editing

All content lives in `index.html`, organized as `<section>` blocks
(hero, vision/evidence, pain, solution, business model, market, roadmap,
raise, team, closing). Search for `<section` to jump between slides.
