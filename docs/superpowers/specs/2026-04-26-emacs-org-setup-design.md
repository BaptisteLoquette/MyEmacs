# Ultimate Emacs Org Setup — Design Spec

> For hybrid research: generative AI, analog electronics, scientific computing, and long-term PKM.

**Date:** 2026-04-26  
**Platform:** Windows native + WSL2  
**Base distribution:** Doom Emacs  

---

## 1. Architecture

### 1.1 Base Distribution

Doom Emacs with hybrid evil/Emacs keybindings. Config is a literate Org file.

```
~/.doom.d/
├── init.el          # Module declarations (declarative, one file)
├── config.org       # Literate config — settings, keybinds, package tweaks
├── packages.el      # Additional packages beyond Doom modules
└── custom.el        # Auto-generated, never edited manually
```

### 1.2 Doom Modules (declared in `init.el`)

| Layer | Modules |
|---|---|
| Completion | `vertico +icons`, `company` |
| UI | `doom`, `doom-dashboard`, `doom-modeline`, `treemacs`, `vc-gutter`, `workspaces` |
| Editor | `evil`, `file-templates`, `fold`, `multiple-cursors` |
| Terminal | `vterm` |
| Tools | `(eval +overlay)`, `lookup`, `(lsp +peek)`, `magit`, `pdf` |
| Languages | `(org +roam2 +noter +present +jupyter)`, `(python +lsp +pyright +conda)`, `(julia +lsp +snail)`, `latex`, `sh`, `data`, `emacs-lisp` |
| Literate computing | `org-babel` (built into org) with `ob-python`, `ob-julia`, `ob-R`, `ob-shell`, `ob-latex`, `ob-gnuplot` plus extras: `ob-spice`, `ob-sqlite` |

### 1.3 Extra Emacs Packages (in `packages.el`)

- **PKM:** `org-roam-ui`, `org-roam-bibtex`, `org-ql`, `org-ref`, `elfeed`, `org-noter`, `pdf-tools`
- **AI:** `gptel`, `org-ai`, `opencode.el` (for opencode agent integration)
- **Diagrams:** `graphviz-dot-mode`, `ob-mermaid`
- **Animation:** `org-inline-anim`

### 1.4 Cross-Platform Notes

Config uses `IS-WINDOWS` / `IS-LINUX` guards. Electronics tools (Xschem, Magic, Netgen) run in WSL2. Emacs on Windows talks to WSL2 via `wsl.exe ngspice ...`. On WSL2, everything runs natively.

---

## 2. UI/UX & Visual Design

### 2.1 Layout

VS Code-like: narrow icon activity bar → expandable treemacs sidebar → main buffer area. Status line via `doom-modeline`. Minibuffer + vertico for completion.

### 2.2 Look

- **Theme:** `doom-one` (dark), fallback Modus themes
- **Fonts:** JetBrains Mono (coding), Iosevka (UI), `all-the-icons` everywhere
- **Hidden:** scroll bar, tool bar, menu bar
- **Enabled:** relative line numbers (evil normal mode only), `global-hl-line-mode`, pixel-precise smooth scrolling, which-key on `SPC` and `,`

---

## 3. Hybrid Keybinding Strategy

Evil-mode active in `prog-mode`, `text-mode`, and `org-mode` buffers. Emacs-default bindings everywhere else (dired, magit, org-agenda, treemacs, vterm, help buffers). `evil-collection` handles integration. Which-key provides discoverability for both. Escape hatch: `C-z` toggles evil in current buffer.

---

## 4. PKM Architecture (Org-roam + Notes)

### 4.1 Directory Layout

```
~/org/
├── daily/               # Daily journals, scratch
├── literature/          # One Org-roam node per paper
├── notes/               # Permanent concept notes
├── projects/            # Design documents with references
├── references.bib       # BibTeX database (managed by org-ref)
└── inbox.org            # Capture target for fleeting ideas
```

### 4.2 Connected Pieces

- **Org-roam:** SQLite backlinks database. Every heading with `:ID:` property is a node. Tags on headings drive queries.
- **Org-roam-ui:** Browser-based interactive graph, following current node.
- **Org-roam-bibtex:** Links BibTeX entries to literature notes.
- **Org-ql:** Complex queries across all notes: "show DONE tasks tagged `:analog:`" or "find open questions across project notes."
- **Org-ref:** Citation insertion while writing. `C-c ]` to insert, builds bibliography on export.
- **Elfeed:** Paper discovery from arXiv, journals, blogs.
- **Org-noter:** Split Emacs: left = PDF, right = Org notes, anchored by page.

### 4.3 Daily Flow

1. Fleeting thought → `SPC x` (org-capture) → `inbox.org` or today's daily note
2. Paper read via elfeed → org-noter annotation → literature note in `literature/`
3. Synthesize → permanent note in `notes/`, linked to papers and concepts
4. Design work → project note in `projects/`, pulling references via org-ref

---

## 5. Scientific Computing & Literate Programming

### 5.1 Languages and Backends

| Language | LSP/Backend | REPL | Org-babel |
|---|---|---|---|
| Python | pyright + conda envs | `run-python` or Jupyter kernel | `ob-python` |
| Julia | LanguageServer.jl | `julia-repl` or Jupyter kernel | `ob-julia` |
| R | ESS | ESS inferior R process | `ob-R` |
| Shell | built-in | vterm | `ob-shell` |

Polars is the primary DataFrame library (not pandas). Conda env per project.

### 5.2 Literate Computing Example

```org
* Amplifier noise analysis
#+begin_src python :results file :file noise_plot.png :prologue header.py
  import polars as pl
  df = pl.read_csv("measurements.csv")
  filtered = df.filter(pl.col("gain_db") > 40)
  fig, ax = plt.subplots(figsize=(10, 5))
  ax.plot(filtered["freq"], filtered["gain_db"], color=COLORS['NMOS'])
  ax.set_title("Gain vs Frequency", color=COLORS['text'])
  fig.savefig("noise_plot.png", dpi=150, bbox_inches='tight', facecolor=COLORS['bg'])
  plt.close(fig)
  "noise_plot.png"
#+end_src

#+RESULTS:
[[file:noise_plot.png]]
```

### 5.3 Shared Style Header (`header.py`)

Auto-injected into ob-python blocks via `:prologue`:

```python
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import polars as pl

plt.rcParams.update({
    'figure.facecolor': '#0d1117', 'axes.facecolor': '#161b22',
    'axes.edgecolor': '#30363d', 'axes.labelcolor': '#e6edf3',
    'text.color': '#e6edf3', 'xtick.color': '#8b949e',
    'ytick.color': '#8b949e', 'grid.color': '#21262d',
    'font.family': 'monospace', 'figure.dpi': 150,
})

COLORS = {
    'bg': '#0d1117', 'surface': '#161b22', 'text': '#e6edf3',
    'muted': '#8b949e', 'VSS': '#58a6ff', 'NMOS': '#3fb950',
    'PMOS': '#f78166', 'wire': '#c9d1d9', 'edge': '#ff7b72',
    'node': '#d2a8ff', 'highlight': '#ffa657',
    'success': '#3fb950', 'fail': '#ff7b72',
}
```

### 5.4 REPL vs Jupyter

REPLs in vterm for quick exploration. Jupyter kernels via `ob-jupyter` for long-running data pipelines where state persistence across blocks matters.

---

## 6. Visualization & Animation Stack

### 6.1 Manual Frameworks (Org-babel driven)

| Output Type | Framework | Source Block | Output |
|---|---|---|---|
| Static plots | Matplotlib + Altair | `#+begin_src python` | inline PNG |
| Interactive 2D/3D | Plotly | `#+begin_src python` | HTML → browser |
| Math/science animation | Manim CE / ManimGL | `#+begin_src python` | MP4/GIF |
| Motion graphics | HyperFrames / Remotion | `#+begin_src python` / `js` | MP4 |
| Circuit schematics | Schemdraw | `#+begin_src python` | inline SVG |
| Diagrams (flowcharts, graphs) | Mermaid / Graphviz | `#+begin_src mermaid` / `dot` | inline PNG |
| 3D scientific | PyVista | `#+begin_src python` | PNG/HTML |
| Big data rasterization | Datashader | `#+begin_src python` | inline PNG |
| Scientific illustrations | TikZ / drawsvg | `#+begin_src latex` / `python` | PDF/SVG |
| "By Hand" computation traces | Matplotlib tables | `#+begin_src python` | inline PNG |

### 6.2 Agent Skills (AI-driven generation from Emacs)

**Installed skills:**

| Skill | Installs | Domain |
|---|---|---|
| `davila7/scientific-visualization` | 802 | General scientific viz |
| `davila7/matplotlib` | 596 | Static plots |
| `davila7/plotly` | 476 | Interactive plots |
| `davila7/manim` | 280 | Math animations |
| `bbeierle12/d3js-visualization` | 105 | D3.js interactive |
| `cloudai-x/threejs-animation` | 4.7K | 3D WebGL |
| `antvis/chart-visualization` | 1.8K | Charts (AntV/G2) |

**Recommended additional skills:**

```bash
npx skills add heygen-com/hyperframes@hyperframes -g -y        # 14K — Agent-first video
npx skills add adithya-s-k/manim_skill@manimce-best-practices -g -y  # 1.7K — Better Manim
npx skills add softaworks/agent-toolkit@mermaid-diagrams -g -y  # 3.9K — Diagrams
npx skills add markdown-viewer/skills@graphviz -g -y            # 1.4K — Graph diagrams
npx skills add streamlit/agent-skills@developing-with-streamlit -g -y  # 943 — Dashboards
npx skills add remotion-dev/skills@remotion-best-practices -g -y      # 268K — React video
npx skills add vibe-motion/skills@svg-assembly-animator -g -y   # 216 — SVG animations
```

### 6.3 Generation Matrix

```
Topic in Org note
      │
      ├── Quick static plot ──────▶ ob-python + Matplotlib → inline PNG
      ├── Interactive 2D/3D ──────▶ Plotly agent skill → HTML → browser
      ├── Math/science animation ─▶ Manim agent skill → MP4 → inline
      ├── Motion graphics video ──▶ Remotion/HyperFrames skill → MP4
      ├── Flowchart/diagram ──────▶ Mermaid/Graphviz skill → inline PNG
      ├── 3D scene exploration ───▶ Three.js skill → HTML → browser
      ├── "By Hand" computation ──▶ scientific-viz skill → color-coded grid
      ├── Data dashboard ─────────▶ Streamlit skill → web app
      └── Circuit schematic ──────▶ ob-python + Schemdraw → SVG
```

### 6.4 Best Tool Per Image Type

| Image type | Best tool |
|---|---|
| Math formulas + architecture diagrams | **TikZ** (LaTeX via ob-latex) |
| Data plots, heatmaps, bar charts | **Matplotlib** (dark theme pattern) |
| Custom illustrations | **drawsvg** (Python → SVG) |
| Graphs, trees, DAGs | **Graphviz** (auto-layout, agent-writable DOT) |
| Circuit schematics | **Schemdraw** |
| 3D scientific figures | **PyVista** / **Asymptote** |
| High-quality animations | **Manim CE** |
| Agent-generated video | **HyperFrames** |

### 6.5 Educational Visualization Sub-System

A dedicated framework for programmatic generation of educational scientific visualizations and animations by AI agents. Lives at `docs/superpowers/viz-framework/`.

```
docs/superpowers/viz-framework/
├── taxonomy/
│   ├── physics.yaml          # 6 sub-disciplines, ~40 concepts
│   ├── electronics.yaml      # 15 sub-disciplines, ~90 concepts
│   └── genai.yaml            # 9 sub-disciplines, ~50 concepts
├── patterns/
│   └── nine-patterns.yaml    # P1-P9 definitions, UX rules, anti-patterns
├── templates/
│   ├── agent-prompts/        # 9 per-framework prompt templates for AI agents
│   │   ├── matplotlib.md
│   │   ├── plotly.md
│   │   ├── manim.md
│   │   ├── schemdraw.md
│   │   ├── pyvista.md
│   │   ├── altair.md
│   │   ├── tikz.md
│   │   ├── graphviz.md
│   │   └── by-hand.md
│   └── code-patterns/        # 9 reusable Python render functions
│       ├── scalarfield.py
│       ├── vectorfield.py
│       ├── signalflow.py
│       ├── geom3d.py
│       ├── graphnet.py
│       ├── processanim.py
│       ├── probdist.py
│       ├── phasetraj.py
│       └── decisionprocess.py
├── install/
│   ├── install-tier1.sh      # Core frameworks + skills
│   ├── install-tier2.sh      # On-demand frameworks + skills
│   ├── install-tier3.sh      # Node.js viz pipeline
│   └── verify-install.py     # Import check for all frameworks
└── org/
    ├── README.org            # Org-babel pipeline reference + decision matrix
    ├── examples/
    │   ├── circuit.org       # Schemdraw differential pair
    │   ├── animation.org     # Manim CE wave propagation
    │   ├── diffusion.org     # Matplotlib FuncAnimation DDPM grid
    │   └── by-hand.org       # "By Hand" attention score trace
    └── config.el             # Emacs package config snippet
```

**Nine visualization patterns (P1-P9):**

| Pattern | Name | Visual Essence |
|---|---|---|
| P1 | ScalarField | Heatmap, contour, isosurface, colormap |
| P2 | VectorField | Arrows, streamlines, field lines |
| P3 | SignalFlow | Waveform, spectrogram, eye diagram, Bode plot |
| P4 | Geom3D | 3D mesh, surface, volume rendering |
| P5 | GraphNet | Node-link, adjacency matrices, attention maps |
| P6 | ProcessAnim | Step-by-step animation, morphing |
| P7 | ProbDist | Density, CDF, quantile, violin, swarm |
| P8 | PhaseTraj | Phase portraits, limit cycles, bifurcation |
| P9 | DecisionProcess | Flowchart, tree, DAG, Markov chain |

---

## 7. Analog Electronics & SPICE Integration

### 7.1 ob-spice

Extends Org-babel to run SPICE netlists (ngspice) from Org code blocks and capture results. Full analog design experiments in a single Org document.

```org
#+begin_src spice :results output :exports both
  * OTA AC analysis
  .include models.lib
  Vdd vdd 0 3.3
  ac dec 10 1 1e9
  ...
#+end_src
```

### 7.2 Open-Source Analog Flow (WSL2)

- **Xschem** — schematic entry
- **ngspice** — circuit simulation
- **Magic** — layout and extraction
- **Netgen** — LVS

Emacs orchestrates: SPICE runs via ob-spice, scripts for Magic/Netgen, analytical results captured in Org.

### 7.3 Schemdraw for Circuit Schematics

```python
import schemdraw.elements as elm
with schemdraw.Drawing(file='ota.svg') as d:
    d += elm.NMos().anchor('source').label('M1')
    d += elm.Resistor().right().label('R_L')
    d += elm.Ground()
```
→ Renders inline SVG in Org.

---

## 8. AI & Agentic Systems

### 8.1 Tools

| Tool | Role | Emacs Integration |
|---|---|---|
| **gptel** | General LLM chat + coding | Native Emacs package, OpenAI-compatible APIs |
| **org-ai** | AI blocks inside Org documents | `#+begin_ai` blocks for inline generation, summarization, rewriting |
| **opencode.el** | Agentic coding in Emacs | Ports opencode tools into Emacs for native agent experience |
| **MiniMax M2.7** | Cost-effective coding model | Configured as gptel backend + opencode provider |

### 8.2 Workflows

- **Paper synthesis:** org-ai block reads several literature notes → generates concept summary
- **Circuit generation:** prompt → agent generates SPICE netlist → ob-spice simulates → results plotted
- **Refactoring:** opencode agent rewrites multi-file Python projects from Emacs
- **Visualization generation:** natural language prompt in Org → agent skill generates viz → linked inline

---

## 9. 4-Stage Rollout

### Stage 1: Core Editing & Scientific Coding
Install Emacs + Doom. Configure UI/UX. Enable Python/Julia/R. Add Org-babel for literate notebooks. Set up Polars + dark theme style header.

### Stage 2: PKM & Research Workflow
Introduce Org-roam, Org-ref, Org-noter. Add Elfeed for paper discovery. Build Zettelkasten of analog design and AI concepts.

### Stage 3: Electronics & Visualization
Add ob-spice + ngspice for SPICE experiments. Install all visualization frameworks (Tier 1). Create taxonomy YAML files, code templates, agent prompts. Set up Org-babel pipeline with working examples. Run verification suite.

### Stage 4: AI & Agentic Systems
Configure gptel and org-ai. Set up opencode + MiniMax M2.7. Use agents to accelerate SPICE generation, refactoring, and data analysis. Agent-driven visualization generation from Org prompts.

---

## 10. Constraints & Limitations

- Emacs cannot render JavaScript inline (Plotly, D3.js, Three.js → open in browser)
- WSL2 required for Xschem, Magic, Netgen (Linux-native)
- JupyterLab still better for fully interactive widget-rich exploration. Emacs is the orchestrator and knowledge hub.
- Complex setup — must be adopted in stages to avoid configuration fatigue.
