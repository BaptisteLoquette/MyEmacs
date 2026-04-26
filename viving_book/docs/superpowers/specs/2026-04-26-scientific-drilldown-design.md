# Scientific Drill-Down Explainer — Prompt & Pipeline Optimization Design

**Date:** 2026-04-26  
**Foundation:** [illustrated-explainer-spec](https://github.com/vthinkxie/illustrated-explainer-spec), [educational-viz-framework](C:/Users/Bapti/docs/superpowers/specs/2026-04-26-educational-viz-design.md)

---

## 1. Overview

Evolve the spec-compliant drill-down explainer to generate **high-quality scientific explanatory images** (physics, electronics, generative AI, math) using optimized prompts, domain-aware routing, dual-pipeline architecture, and a quality gate — while preserving the original drill-down mechanic (§7 red marker, §6 content-addressed caching, §9 concurrency).

### Key Changes from Original Spec

| Aspect | Original Spec | Optimized |
|---|---|---|
| Style | Watercolor painting, warm paper, serif title | Technical precision per domain, clean vector aesthetic, white background |
| Prompt routing | Single unified prompt | Domain-aware routing via taxonomy + semantic classification |
| Variety | One style | 4-5 archetypes per domain, random selection |
| Child pages | Pure visual drill-down (red marker only) | 2-step: vision-describe red circle → context-injected child prompt |
| Quality | None | Vision-model quality gate with auto-regenerate (max 2x) |
| Pipeline | Only AI image gen | Dual: Pipeline A (pure AI gen) + Pipeline B (programmatic render) |

---

## 2. Architecture

```
User query
    │
    ▼
┌──────────────────────────────────────────────────────────┐
│  Domain Router (prompts.js)                               │
│  Tier 1: Keyword matching against taxonomy YAML           │
│  Tier 2: Semantic classification via Gemini text call     │
│  Output: domain + archetype + pipeline choice (A/B)       │
└──────────────────────┬───────────────────────────────────┘
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
┌──────────────────┐     ┌──────────────────────────┐
│  Pipeline A       │     │  Pipeline B               │
│  Pure AI Gen      │     │  Programmatic Render      │
│  (Gemini)         │     │  (LLM → Code → Render)    │
├──────────────────┤     ├──────────────────────────┤
│ For:              │     │ For:                      │
│ • Scenes          │     │ • Flowcharts (Mermaid)    │
│ • Conceptual      │     │ • Schematics (Schemdraw)  │
│ • Visual metaphor │     │ • Equations (TikZ)        │
│ • Cross-sections  │     │ • Architecture (Graphviz) │
│ • Physics fields  │     │ • Data plots (matplotlib) │
└────────┬─────────┘     └──────────────┬───────────┘
         │                              │
         └──────────────┬───────────────┘
                        ▼
┌──────────────────────────────────────────────────────────┐
│  Quality Gate (quality-gate.js)                           │
│  • Gemini Vision evaluates output against UX rules       │
│  • Checks: text legibility, diagram accuracy,            │
│    style consistency, no artifacts                       │
│  • If score < threshold → auto-regenerate with critique  │
│    (max 2 retries)                                       │
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼
                   Final PNG
```

---

## 3. File Changes

| File | Action | Description |
|---|---|---|
| `prompts.js` | New | Domain router, prompt factory, archetype selector, taxonomy loader |
| `pipeline-b.js` | New | Programmatic rendering: framework selector, code exec, subprocess |
| `quality-gate.js` | New | Vision-model evaluation, regenerate loop |
| `server.js` | Modify | Import new modules, route to Pipeline A or B, call quality gate |
| `providers/gemini.js` | Modify | Add `generateText()` for vision-describe + quality eval |
| `public/index.html` | Modify | Add domain tag UI with manual override, paper search input |

---

## 4. Prompt Architecture (prompts.js)

### 4.1 Style per Domain

All domains share a quality baseline: clean vector aesthetic, white background, high contrast, colorblind-safe palette, no decorative elements, no 3D renders, publication-quality.

Domain-specific conventions per the educational-viz taxonomy (§2):

- **physics**: Feynman diagrams, field lines with arrows, SI units, coordinate axes, labeled vectors
- **math**: LaTeX-style equations, clean proof steps, function plots, geometric constructions
- **electronics**: IEEE schematic symbols, signal flow arrows, component values, timing diagrams
- **ai-ml**: Layer diagrams, attention visualizations, training pipelines, embedding plots
- **data-viz**: Labeled axes, color scales, statistical annotations, multi-panel layouts
- **concept-map**: Connected nodes, hierarchical/network layout, color-coded categories
- **general-science**: Annotated diagrams, process flows, cross-sections

### 4.2 Archetype Variety

Each domain defines 4-5 layout archetypes. On generation, randomly select one (or least-recently-used) to maximize variety. Each archetype has specific spatial/notation instructions.

### 4.3 UX Quality Rules (from educational-viz §4.4)

Injected into every prompt:
1. Labels/arrows must not overlap
2. Axes match physical units, log scale for multi-decade spans
3. Vector fields obey div/curl constraints, physical consistency
4. Max 3 visual channels (color + size + position)
5. Colorblind-safe (viridis/cividis, no rainbow)
6. Key features annotated (maxima, minima, zero-crossings)
7. Clean layout with breathing room

### 4.4 Anti-Patterns (Negative Prompt Elements)

- No overlay overload (>4 traces), no static dump, no equation vomit
- No fake physics, no mislabeled axes, no garbled text
- No 3D renders, no photorealism, no decorative elements

### 4.5 Prompts Structure

**First-page prompt:**
```
{QUALITY_BASELINE}
{DOMAIN_STYLE_CONVENTIONS}
{ARCHETYPE_INSTRUCTIONS}
{UX_QUALITY_RULES}
{NEGATIVE: ANTI_PATTERNS}

Topic: {query}

Generate a single 16:9 scientific explanatory figure about this topic.
Choose the diagram type best suited to explain the concept.
Output a single PNG image, 16:9. Include a clear title.
```

**Child-page prompt (2-step):**
```
Step 1 — Vision Describe:
"The provided image has a red circle drawn on it. Describe in 1-2
sentences exactly what object, component, or concept the red circle
is on. Be specific and technical."

Step 2 — Generate:
"{QUALITY_BASELINE}
{DOMAIN_STYLE_CONVENTIONS}
{UX_QUALITY_RULES}

You are continuing a scientific explanation. The previous figure is provided.
A red circle marks: {context_from_step_1}

Generate the next page: a single 16:9 scientific figure that goes deeper
into the marked area. Match the diagram style and notations of the
provided image exactly. Do NOT include the red circle in the output.
Output a single PNG image, 16:9."
```

---

## 5. Pipeline B — Programmatic Rendering

### 5.1 Routing to Pipeline B

Queries matching structured diagram types route to Pipeline B:

| Query pattern | Framework | Render command |
|---|---|---|
| flowchart, workflow, process | Mermaid | `mmdc -i in.mmd -o out.png` |
| circuit, schematic, transistor | Schemdraw | `python circuit.py` |
| architecture, system diagram | Graphviz (DOT) | `dot -Tpng in.dot -o out.png` |
| neural network layers | TikZ (PlotNeuralNet) | `pdflatex diagram.tex` |
| math equation, proof | TikZ / Matplotlib | `pdflatex` or `python` |
| data plot, chart, histogram | Matplotlib | `python plot.py` |

### 5.2 Code Generation

LLM (Gemini) generates code in the target framework's canonical API. Code is executed in a subprocess with a 30s timeout. Output PNG is validated for existence and size > 0.

### 5.3 Dependencies (Tier 1)

- Mermaid CLI: `@mermaid-js/mermaid-cli` (npm)
- Graphviz: `graphviz` (system) or `node-graphviz` (npm)
- Python: matplotlib, schemdraw (pip)
- LaTeX: Optional for TikZ

---

## 6. Quality Gate (quality-gate.js)

### 6.1 Evaluation Prompt

```
"You are evaluating a scientific figure for quality. Check:
1. Are all text labels crisp and legible? (yes/no)
2. Does the diagram accurately represent the topic? (yes/no)
3. Are there any artifacts (watermarks, red circles, garbled regions)? (yes/no)
4. Does the style match scientific publication standards? (yes/no)

Answer with a JSON object: { pass: true/false, issues: ["..."] }"
```

### 6.2 Regeneration Loop

```
generate → evaluate → pass? → return
                ↓ no (issues listed)
              inject issues as fix instructions
              regenerate (max 2 total retries)
                ↓ still failing
              return best attempt with warning
```

### 6.3 Performance

- Quality gate adds ~1-2s latency per page (lightweight Gemini text call)
- Pipeline B adds ~2-5s latency (code gen + subprocess)
- Total worst case: ~15s (2 retries × 5s gen + 2 × 2s eval)

---

## 7. User Interface Changes

### 7.1 Domain Tag

A small tag/chip next to the topic input shows the auto-detected domain (e.g., "Physics", "AI/ML"). User can click to manually switch domains before generating.

### 7.2 Paper Search Input (Future)

Placeholder for arXiv/Semantic Scholar integration. Separate from topic input — reserved for the next phase (research paper exploration).

---

## 8. Integration with Educational-Viz Framework

The educational-viz-framework (`C:/Users/Bapti/docs/superpowers/specs/2026-04-26-educational-viz-design.md`) provides:

- **Taxonomy YAML files**: Loaded by `prompts.js` for concept-to-pattern-to-framework routing
- **9 pattern primitives**: Used by Pipeline B to select the right rendering approach
- **18 framework portfolio**: Target rendering backends for Pipeline B
- **Code pattern templates**: Starting points for LLM-generated render code
- **Agent prompt templates**: UX rules and gotchas for each framework

The drill-down explainer is the **interaction layer** on top of this viz-framework. The framework provides the generation engine; the explainer provides the topic input, click-to-drill, and navigation UI.

---

## 9. Acceptance Criteria

- [ ] Type "transformer architecture" → auto-routes to Pipeline B, generates clean architecture diagram
- [ ] Type "quantum entanglement" → auto-routes to Pipeline A, generates physics illustration
- [ ] Type "RLC bandpass filter" → generates circuit schematic with correct IEEE symbols
- [ ] Click on a diagram component → drills deeper into that specific component
- [ ] Garbled text in output → quality gate detects and auto-regenerates
- [ ] Domain tag shows correct domain, user can override
- [ ] Cache hits return instantly (no regeneration, no quality gate re-run)
- [ ] Drill 5 pages deep → style and notation stay consistent
- [ ] Reset clears state back to empty topic input

---

*Design complete. Proceed to implementation plan.*
