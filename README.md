# RoamingOS — Investor Deck

A static investor pitch deck: [`index.html`](index.html), with optional demo media in
[`demo-assets/`](demo-assets/) and brand assets in [`logos/`](logos/).

Most presentation assets are inlined, and the demo media folder is published beside
the HTML. The site needs **no build step and no dependencies**.

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
The workflow copies `index.html`, `demo-assets/`, and `logos/` into the Pages artifact
with no build step.

## Editing

All content lives in `index.html`, organized as `<section>` blocks
(hero, vision/evidence, pain, solution, business model, market, roadmap,
raise, team, closing). Search for `<section` to jump between slides.
