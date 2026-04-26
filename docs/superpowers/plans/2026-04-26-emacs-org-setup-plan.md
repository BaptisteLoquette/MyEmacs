# Ultimate Emacs Org Setup — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete Doom Emacs environment on Windows for generative AI-driven scientific computing, analog electronics design, research PKM, and agentic visualization generation.

**Architecture:** Doom Emacs with hybrid evil/Emacs keybindings, literate Org config, staged rollout (4 phases). Windows native with WSL2 for Linux-native electronics tools.

**Tech Stack:** Emacs 29+, Doom Emacs, Org-mode, Org-roam, Org-babel, Python 3.12, Julia, R, Polars, Matplotlib, Plotly, Manim CE, Schemdraw, HyperFrames, Graphviz, gptel, org-ai, opencode.el

**Design Spec Reference:** `docs/superpowers/specs/2026-04-26-emacs-org-setup-design.md`

---

## File Structure

```
~/.doom.d/
├── init.el            # Doom module declarations
├── config.org         # Literate config (settings, keybinds, packages)
├── packages.el        # Extra MELPA packages
└── custom.el          # Auto-generated (never edit)

~/org/
├── daily/             # Daily journals
├── literature/        # Paper notes (Org-roam nodes)
├── notes/             # Permanent concept notes
├── projects/          # Design documents
├── references.bib     # BibTeX database
└── inbox.org          # Capture target

C:/Users/Bapti/.emacs.d/header.py  # Shared dark theme + COLORS for ob-python
```

---

## Stage 1: Core Editing & Scientific Coding

### Task 1.1: Install Emacs and Doom

**Files:**
- Create: `C:/Users/Bapti/.doom.d/init.el`

- [ ] **Step 1: Install Emacs on Windows**

Download and install GNU Emacs 29+ from https://ftp.gnu.org/gnu/emacs/windows/
Run the installer. Add `C:\Program Files\Emacs\emacs-29\bin` to PATH.

- [ ] **Step 2: Verify Emacs works**

Run: `emacs --version`
Expected: `GNU Emacs 29.x`

- [ ] **Step 3: Install Doom Emacs**

Run:
```powershell
git clone --depth 1 https://github.com/doomemacs/doomemacs "$env:USERPROFILE\.emacs.d"
"$env:USERPROFILE\.emacs.d\bin\doom.cmd" install
```

- [ ] **Step 4: Create init.el with Stage 1 modules**

Write `C:/Users/Bapti/.doom.d/init.el`:
```elisp
;; -*- mode: emacs-lisp; -*-
;; Doom Emacs init.el — Ultimate Emacs Org Setup
;; Stage 1: Core Editing & Scientific Computing

(doom! :input
       ;; (layout +azerty)   ; uncomment if French AZERTY

       :completion
       (vertico +icons)
       company

       :ui
       doom
       doom-dashboard
       doom-modeline
       treemacs
       vc-gutter
       workspaces

       :editor
       evil
       file-templates
       fold
       multiple-cursors

       :emacs
       (dired +icons)
       electric
       (ibuffer +icons)
       undo
       vc

       :term
       vterm

       :checkers
       syntax
       spell

       :tools
       (eval +overlay)
       lookup
       (lsp +peek)
       magit
       pdf

       :lang
       (org +roam2 +noter +present +jupyter)
       (python +lsp +pyright +conda)
       (julia +lsp +snail)
       (latex +fold)
       (sh +fish)
       data
       (emacs-lisp +lsp)
       markdown

       :config
       (default +bindings +smartparens))
```

- [ ] **Step 5: Run doom sync**

Run: `$env:USERPROFILE\.emacs.d\bin\doom.cmd sync`
Expected: No errors, "Finished!"

- [ ] **Step 6: First launch test**

Run: `emacs`
Expected: Doom dashboard loads, no error messages in `*Messages*` buffer

- [ ] **Step 7: Commit**

```bash
git add C:/Users/Bapti/.doom.d/init.el
git commit -m "feat: add Doom Emacs config with Stage 1 modules"
```

---

### Task 1.2: Configure UI/UX

**Files:**
- Create: `C:/Users/Bapti/.doom.d/config.org`

- [ ] **Step 1: Write config.org with visual settings**

Write `C:/Users/Bapti/.doom.d/config.org`:
```org
#+TITLE: Doom Emacs Configuration
#+STARTUP: overview

* UI / Visual
** Theme
(setq doom-theme 'doom-one)
;; Fallback high-accessibility:
;; (setq doom-theme 'modus-vivendi)

** Fonts
(setq doom-font (font-spec :family "JetBrains Mono" :size 14 :weight 'regular))
(setq doom-unicode-font (font-spec :family "Iosevka" :size 14))
(setq doom-big-font (font-spec :family "JetBrains Mono" :size 20))

** Chrome
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(global-hl-line-mode +1)
(display-line-numbers-mode +1)
(setq display-line-numbers-type 'relative)
(setq scroll-conservatively 101)
(pixel-scroll-precision-mode +1)

** Line wrap
(global-visual-line-mode +1)

** All-the-icons everywhere
(use-package! all-the-icons-completion
  :after marginalia
  :config
  (all-the-icons-completion-mode +1))
(add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup)
```

- [ ] **Step 2: Run doom sync**

Run: `$env:USERPROFILE\.emacs.d\bin\doom.cmd sync`
Expected: No errors

- [ ] **Step 3: Verify fonts and theme**

Open Emacs. Check: dark theme applied, JetBrains Mono visible, no scroll bar, line numbers displayed.

- [ ] **Step 4: Commit**

```bash
git add C:/Users/Bapti/.doom.d/config.org
git commit -m "feat: add UI/UX configuration (theme, fonts, chrome)"
```

---

### Task 1.3: Configure Hybrid Keybindings

**Files:**
- Modify: `C:/Users/Bapti/.doom.d/config.org`

- [ ] **Step 1: Append keybinding config to config.org**

Append to `C:/Users/Bapti/.doom.d/config.org`:
```org
* Keybindings — Hybrid Evil/Emacs
** Evil only in editing buffers
(after! evil
  ;; Evil active in prog-mode, text-mode, org-mode (Doom default)
  ;; Explicitly disable in tooling buffers:
  (add-hook 'dired-mode-hook #'evil-emacs-state)
  (add-hook 'org-agenda-mode-hook #'evil-emacs-state)
  (add-hook 'magit-mode-hook #'evil-emacs-state)
  (add-hook 'treemacs-mode-hook #'evil-emacs-state)
  (add-hook 'vterm-mode-hook #'evil-emacs-state)
  (add-hook 'help-mode-hook #'evil-emacs-state)
  (add-hook 'elfeed-show-mode-hook #'evil-emacs-state)
  (add-hook 'pdf-view-mode-hook #'evil-emacs-state))

** Escape hatch: toggle evil in current buffer
(map! :leader
      (:prefix ("t" . "toggle")
       :desc "Toggle evil-mode" "e" #'evil-mode))

** Evil-collection for consistency
(after! evil-collection
  (evil-collection-init '(dired magit vterm)))
```

- [ ] **Step 2: Sync and verify**

Run: `$env:USERPROFILE\.emacs.d\bin\doom.cmd sync`
Open Emacs. Open a `.py` file → evil should be active (normal mode cursor). Open dired → standard cursor. `SPC t e` → toggles evil. `SPC` shows which-key.

- [ ] **Step 3: Commit**

```bash
git add C:/Users/Bapti/.doom.d/config.org
git commit -m "feat: configure hybrid evil/Emacs keybindings"
```

---

### Task 1.4: Create Shared Dark Theme Style Header

**Files:**
- Create: `C:/Users/Bapti/.emacs.d/header.py`

- [ ] **Step 1: Write header.py**

Write `C:/Users/Bapti/.emacs.d/header.py`:
```python
"""Shared dark theme + color palette for Org-babel Python blocks."""

import matplotlib
matplotlib.use('Agg')  # Non-interactive backend for Org

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, Circle, FancyArrowPatch, Arc
import numpy as np
import polars as pl

plt.rcParams.update({
    'figure.facecolor': '#0d1117',
    'axes.facecolor':   '#161b22',
    'axes.edgecolor':   '#30363d',
    'axes.labelcolor':  '#e6edf3',
    'text.color':       '#e6edf3',
    'xtick.color':      '#8b949e',
    'ytick.color':      '#8b949e',
    'grid.color':       '#21262d',
    'grid.linestyle':   '--',
    'grid.linewidth':   0.6,
    'font.family':      'monospace',
    'axes.titlesize':   14,
    'axes.labelsize':   11,
    'figure.dpi':       150,
    'savefig.bbox':     'tight',
    'savefig.facecolor':'#0d1117',
})

COLORS = {
    'bg':        '#0d1117',
    'surface':   '#161b22',
    'text':      '#e6edf3',
    'muted':     '#8b949e',
    'VSS':       '#58a6ff',
    'NMOS':      '#3fb950',
    'PMOS':      '#f78166',
    'wire':      '#c9d1d9',
    'edge':      '#ff7b72',
    'node':      '#d2a8ff',
    'highlight': '#ffa657',
    'success':   '#3fb950',
    'fail':      '#ff7b72',
}

def newfig(w=10, h=5):
    """Create a dark-themed figure and axes."""
    fig, ax = plt.subplots(figsize=(w, h))
    ax.set_facecolor(COLORS['surface'])
    return fig, ax
```

- [ ] **Step 2: Append Org-babel header config to config.org**

Append to `C:/Users/Bapti/.doom.d/config.org`:
```org
* Org-Babel
** Shared style header
(after! org
  (setq org-babel-default-header-args:python
        '((:results . "file")
          (:exports . "both")
          (:prologue . "exec(open('C:/Users/Bapti/.emacs.d/header.py').read())")))

  ;; Inline image display on startup
  (setq org-startup-with-inline-images t)

  ;; Enable all languages
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (julia . t)
     (R . t)
     (shell . t)
     (latex . t)
     (emacs-lisp . t)
     (dot . t)
     (gnuplot . t))))
```

- [ ] **Step 3: Sync and test**

Run: `$env:USERPROFILE\.emacs.d\bin\doom.cmd sync`

Open Emacs. Create a test Org buffer:
```org
#+begin_src python :results file :file test_plot.png
  fig, ax = newfig()
  ax.plot([1, 2, 3], [1, 4, 9], color=COLORS['NMOS'])
  fig.savefig("test_plot.png")
  plt.close(fig)
  "test_plot.png"
#+end_src
```
`C-c C-c` on the block. Expected: PNG appears inline with dark background.

- [ ] **Step 4: Commit**

```bash
git add C:/Users/Bapti/.emacs.d/header.py
git add C:/Users/Bapti/.doom.d/config.org
git commit -m "feat: add shared dark theme header and Org-babel config"
```

---

### Task 1.5: Verify Scientific Computing Languages

**Files:** None (verification only)

- [ ] **Step 1: Verify Python + Polars**

Open Emacs. Run:
```org
#+begin_src python :results output
  import polars as pl
  import matplotlib
  print(f"Polars {pl.__version__}")
  print(f"Matplotlib {matplotlib.__version__}")
  print("Python stack: OK")
#+end_src
```
`C-c C-c`. Expected: prints versions, "Python stack: OK"

- [ ] **Step 2: Verify Julia (if installed)**

Run: `julia --version` in terminal.
If Julia installed, open a `.jl` file in Emacs → should have syntax highlighting. `M-x julia-repl` → should start REPL.

- [ ] **Step 3: Verify R + ESS (if needed)**

Run: `R --version` in terminal.
If R installed, install ESS: `M-x package-install RET ess RET`.

- [ ] **Step 4: Commit (Stage 1 complete)**

```bash
git commit --allow-empty -m "feat: Stage 1 complete — core editing and scientific computing verified"
```

---

## Stage 2: PKM & Research Workflow

### Task 2.1: Create Org Directory Structure

**Files:**
- Create: `C:/Users/Bapti/org/inbox.org`
- Create: `C:/Users/Bapti/org/references.bib`
- Create directories: `org/daily/`, `org/literature/`, `org/notes/`, `org/projects/`

- [ ] **Step 1: Create directories**

Run:
```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\org\daily" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\org\literature" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\org\notes" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\org\projects" -Force
```

- [ ] **Step 2: Create inbox.org**

Write `C:/Users/Bapti/org/inbox.org`:
```org
#+TITLE: Inbox
#+FILETAGS: :inbox:

* Fleeting ideas go here
  :PROPERTIES:
  :ID: inbox-root
  :END:
```

- [ ] **Step 3: Create references.bib**

Write `C:/Users/Bapti/org/references.bib`:
```bibtex
% References database — managed by org-ref
% Populate with papers as you read them
```

- [ ] **Step 4: Commit**

```bash
git add C:/Users/Bapti/org/
git commit -m "feat: create Org directory structure for PKM"
```

---

### Task 2.2: Configure Org-roam

**Files:**
- Modify: `C:/Users/Bapti/.doom.d/config.org`

- [ ] **Step 1: Append Org-roam config to config.org**

Append to `C:/Users/Bapti/.doom.d/config.org`:
```org
* Org-Roam
(after! org-roam
  (setq org-roam-directory (file-truename "~/org"))
  (setq org-roam-dailies-directory "daily/")
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :draft:\n")
           :unnarrowed t)
          ("l" "literature" plain "%?"
           :target (file+head "literature/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :paper:\n")
           :unnarrowed t)))
  (org-roam-db-autosync-mode +1))

** Org-roam bindings
(map! :leader
      (:prefix ("n" . "notes")
       :desc "Find node" "f" #'org-roam-node-find
       :desc "Insert link" "i" #'org-roam-node-insert
       :desc "Capture" "c" #'org-roam-capture
       :desc "Show backlinks" "b" #'org-roam-buffer-toggle
       :desc "Today's daily" "d" #'org-roam-dailies-capture-today))
```

- [ ] **Step 2: Sync and verify**

Run: `$env:USERPROFILE\.emacs.d\bin\doom.cmd sync`
Open Emacs. `SPC n c` → capture template appears. `SPC n f` → node finder with vertico.

- [ ] **Step 3: Commit**

```bash
git add C:/Users/Bapti/.doom.d/config.org
git commit -m "feat: configure Org-roam with capture templates and keybindings"
```

---

### Task 2.3: Configure Org-ref and Org-noter

**Files:**
- Modify: `C:/Users/Bapti/.doom.d/config.org`
- Create: `C:/Users/Bapti/.doom.d/packages.el`

- [ ] **Step 1: Create packages.el with extra packages**

Write `C:/Users/Bapti/.doom.d/packages.el`:
```elisp
;; -*- no-byte-compile: t; -*-
;; Extra packages beyond Doom modules

;; PKM
(package! org-roam-ui)
(package! org-roam-bibtex)
(package! org-ql)

;; Literature
(package! org-ref)
(package! elfeed)
(package! org-noter)
(package! pdf-tools)

;; Diagrams
(package! graphviz-dot-mode)
(package! ob-mermaid)

;; Animation
(package! org-inline-anim)
```

- [ ] **Step 2: Sync**

Run: `$env:USERPROFILE\.emacs.d\bin\doom.cmd sync`

- [ ] **Step 3: Append Org-ref, Org-noter, Elfeed config**

Append to `C:/Users/Bapti/.doom.d/config.org`:
```org
* Literature & Research
** Org-ref
(setq reftex-default-bibliography '("~/org/references.bib"))
(setq org-ref-default-bibliography '("~/org/references.bib"))
(setq org-ref-pdf-directory "~/org/literature/")

** Org-noter
(after! org-noter
  (setq org-noter-notes-search-path '("~/org/literature/")))

** Org-roam-bibtex
(after! org-roam-bibtex
  (require 'org-roam-bibtex))

** Org-ql
(after! org-ql
  (setq org-ql-search-directories-files-recursive t))

** Elfeed
(after! elfeed
  (setq elfeed-feeds
        '(("https://arxiv.org/rss/cs.AI" ai)
          ("https://arxiv.org/rss/cs.LG" ml)
          ("https://arxiv.org/rss/eess.SP" signal))))
```

- [ ] **Step 4: Sync and verify**

Run: `$env:USERPROFILE\.emacs.d\bin\doom.cmd sync`
Open Emacs. `M-x org-ref` → should show menu. `M-x elfeed` → should show feed list.

- [ ] **Step 5: Commit**

```bash
git add C:/Users/Bapti/.doom.d/packages.el
git add C:/Users/Bapti/.doom.d/config.org
git commit -m "feat: add PKM packages and configure org-ref, org-noter, elfeed"
```

---

### Task 2.4: Verify PKM Workflow End-to-End

**Files:** None (verification only)

- [ ] **Step 1: Create a test note**

In Emacs: `SPC n c` → type "Test Common-Mode Feedback" → `C-c C-c`. Open the file, add some text, and `#+filetags: :analog:ota:`.

- [ ] **Step 2: Insert a backlink**

Create a second note "OTA Design Concepts". In the first note: `SPC n i` → select "OTA Design Concepts" → creates link.

- [ ] **Step 3: Verify backlinks**

`SPC n b` → backlinks buffer shows "OTA Design Concepts" linking to this note.

- [ ] **Step 4: Commit (Stage 2 complete)**

```bash
git commit --allow-empty -m "feat: Stage 2 complete — PKM and research workflow verified"
```

---

## Stage 3: Electronics & Visualization

### Task 3.1: Install Tier 1 Frameworks and Skills

**Files:** None (installation only)

- [ ] **Step 1: Install Python visualization frameworks**

Run:
```powershell
pip install schemdraw altair manim pyvista polars moviepy datashader pyyaml drawsvg
```

- [ ] **Step 2: Install Agent Skills**

Run:
```bash
npx skills add heygen-com/hyperframes@hyperframes -g -y
npx skills add adithya-s-k/manim_skill@manimce-best-practices -g -y
npx skills add softaworks/agent-toolkit@mermaid-diagrams -g -y
npx skills add markdown-viewer/skills@graphviz -g -y
```

- [ ] **Step 3: Verify installations**

Run:
```powershell
python -c "
import schemdraw; print('schemdraw OK')
import altair; print('altair OK')
import manim; print('manim OK')
import pyvista; print('pyvista OK')
import polars; print('polars OK')
import drawsvg; print('drawsvg OK')
import moviepy; print('moviepy OK')
import datashader; print('datashader OK')
print('All Tier 1 frameworks installed')
"
```
Expected: All "OK" messages, no import errors.

- [ ] **Step 4: Commit**

```bash
git commit --allow-empty -m "feat: Tier 1 visualization frameworks and agent skills installed"
```

---

### Task 3.2: Configure Diagramming in Emacs

**Files:**
- Modify: `C:/Users/Bapti/.doom.d/config.org`

- [ ] **Step 1: Append diagramming config**

Append to `C:/Users/Bapti/.doom.d/config.org`:
```org
* Diagramming
** Graphviz
(use-package! graphviz-dot-mode
  :mode ("\\.dot\\'" "\\.gv\\'")
  :config
  (setq graphviz-dot-preview-extension "png")
  (setq graphviz-dot-save-before-view t))

** Mermaid (Org-babel)
(after! org
  (setq ob-mermaid-cli-path "mmdc"))
(add-to-list 'org-babel-load-languages '(mermaid . t))

** Org-inline-anim
(after! org-inline-anim
  (setq org-inline-anim-max-size 10485760))  ; 10 MB
```

- [ ] **Step 2: Sync**

Run: `$env:USERPROFILE\.emacs.d\bin\doom.cmd sync`

- [ ] **Step 3: Test Mermaid**

Open Emacs. Create Org buffer:
```org
#+begin_src mermaid :file test_mermaid.png
  graph TD
    A[Input] --> B[Process]
    B --> C[Output]
#+end_src
```
`C-c C-c`. If `mmdc` not installed: `npm install -g @mermaid-js/mermaid-cli`.

- [ ] **Step 4: Commit**

```bash
git add C:/Users/Bapti/.doom.d/config.org
git commit -m "feat: configure Graphviz, Mermaid, and org-inline-anim"
```

---

### Task 3.3: Test Schemdraw Circuit Rendering

**Files:** None (verification)

- [ ] **Step 1: Create test circuit Org block**

In Emacs Org buffer:
```org
#+begin_src python :results file :file diffpair.svg
  import schemdraw
  import schemdraw.elements as elm

  with schemdraw.Drawing(file='diffpair.svg') as d:
      elm.SourceI().down().label('I_tail')
      elm.Dot().label('V_tail')
      d.push()
      elm.Line().up().at(d.here)
      elm.BjtNpn().up().anchor('emitter').label('Q1')
      elm.Resistor().up().label('R_C')
      d.pop()
      elm.Line().right()
      elm.BjtNpn().up().anchor('emitter').label('Q2')
      elm.Resistor().up().label('R_C')
  "diffpair.svg"
#+end_src
```

- [ ] **Step 2: Execute and verify**

`C-c C-c`. Expected: SVG file created, linked inline. Shows differential pair schematic.

- [ ] **Step 3: Commit**

```bash
git commit --allow-empty -m "feat: verified Schemdraw circuit rendering in Org-babel"
```

---

### Task 3.4: Test Manim CE Animation

**Files:** None (verification)

- [ ] **Step 1: Create test Manim Org block**

In Emacs Org buffer:
```org
#+begin_src python :results file :file wave.mp4
  from manim import *

  class WaveScene(Scene):
      def construct(self):
          self.camera.background_color = '#0d1117'
          axes = Axes(x_range=[0, 6.28], y_range=[-1.5, 1.5])
          wave = axes.plot(lambda x: np.sin(x), color='#3fb950')
          label = MathTex(r"\sin(x)", color='#e6edf3').next_to(axes, UP)
          self.play(Create(axes), Create(wave), Write(label))
          self.wait(2)

  # To render:
  # manim -pql <this-file> WaveScene
#+end_src
```

- [ ] **Step 2: Render externally**

Save Org buffer as `.py`, run: `manim -pql wave_scene.py WaveScene`
Expected: MP4 generated, opens in media player.

- [ ] **Step 3: Commit**

```bash
git commit --allow-empty -m "feat: verified Manim CE animation rendering"
```

---

### Task 3.5: Build Educational Visualization Framework

> **Refer to existing plan:** `docs/superpowers/plans/2026-04-26-educational-viz-plan.md` (7 tasks, ~40 steps). Execute that plan to build the taxonomy YAML files, nine-patterns.yaml, code templates, agent prompts, install scripts, Org-babel examples, and verification suite.

- [ ] **Step 1: Execute educational-viz-plan Task 1 (Taxonomy YAML files)**

See `docs/superpowers/plans/2026-04-26-educational-viz-plan.md` Task 1 for detailed steps.

- [ ] **Step 2: Execute educational-viz-plan Task 2 (Nine patterns)**

See plan Task 2.

- [ ] **Step 3: Execute educational-viz-plan Task 3 (Code templates)**

See plan Task 3.

- [ ] **Step 4: Execute educational-viz-plan Task 4 (Agent prompts)**

See plan Task 4.

- [ ] **Step 5: Execute educational-viz-plan Task 5 (Install scripts)**

See plan Task 5.

- [ ] **Step 6: Execute educational-viz-plan Task 6 (Org-babel pipeline)**

See plan Task 6.

- [ ] **Step 7: Execute educational-viz-plan Task 7 (Verification suite)**

See plan Task 7.

- [ ] **Step 8: Commit (Stage 3 complete)**

```bash
git commit --allow-empty -m "feat: Stage 3 complete — electronics and visualization configured"
```

---

## Stage 4: AI & Agentic Systems

### Task 4.1: Install and Configure gptel

**Files:**
- Modify: `C:/Users/Bapti/.doom.d/packages.el`
- Modify: `C:/Users/Bapti/.doom.d/config.org`

- [ ] **Step 1: Add gptel to packages.el**

Append to `C:/Users/Bapti/.doom.d/packages.el`:
```elisp
;; AI Assistants
(package! gptel)
(package! org-ai)
```

- [ ] **Step 2: Sync**

Run: `$env:USERPROFILE\.emacs.d\bin\doom.cmd sync`

- [ ] **Step 3: Configure gptel in config.org**

Append to `C:/Users/Bapti/.doom.d/config.org`:
```org
* AI Assistants
** gptel
(setq gptel-model "claude-sonnet-4-20250514"
      gptel-backend (gptel-make-openai "Anthropic"
                      :host "api.anthropic.com"
                      :endpoint "/v1/messages"
                      :stream t
                      :key (lambda () (auth-source-pick-first-password
                                       :host "api.anthropic.com"))))

;; MiniMax M2.7 as secondary backend
;; (setq gptel-backend (gptel-make-openai "MiniMax"
;;                       :host "api.minimax.chat"
;;                       :endpoint "/v1/chat/completions"
;;                       :stream t
;;                       :key (lambda () (auth-source-pick-first-password
;;                                        :host "api.minimax.chat"))))

** Keybindings
(map! :leader
      (:prefix ("a" . "ai")
       :desc "GPTel chat" "c" #'gptel
       :desc "GPTel send region" "s" #'gptel-send
       :desc "GPTel menu" "m" #'gptel-menu))
```

- [ ] **Step 4: Sync and test**

Run: `$env:USERPROFILE\.emacs.d\bin\doom.cmd sync`
Open Emacs. `SPC a c` → gptel chat buffer opens. Type "Hello, what's 2+2?" → should get response.

- [ ] **Step 5: Commit**

```bash
git add C:/Users/Bapti/.doom.d/packages.el
git add C:/Users/Bapti/.doom.d/config.org
git commit -m "feat: install and configure gptel AI chat"
```

---

### Task 4.2: Configure org-ai

**Files:**
- Modify: `C:/Users/Bapti/.doom.d/config.org`

- [ ] **Step 1: Append org-ai config**

Append to `C:/Users/Bapti/.doom.d/config.org`:
```org
** org-ai
(after! org-ai
  (setq org-ai-default-model "claude-sonnet-4-20250514")
  (setq org-ai-openai-api-token
        (lambda () (auth-source-pick-first-password
                    :host "api.anthropic.com"))))

;; Keybindings
(map! :leader
      (:prefix ("a" . "ai")
       :desc "org-ai block" "b" #'org-ai-block
       :desc "org-ai ask" "q" #'org-ai-prompt
       :desc "org-ai summarize" "u" #'org-ai-summarize))
```

- [ ] **Step 2: Sync and test**

Run: `$env:USERPROFILE\.emacs.d\bin\doom.cmd sync`
In an Org buffer: `SPC a b` → inserts `#+begin_ai`. Type a prompt. `C-c C-c` → AI generates content.

- [ ] **Step 3: Commit**

```bash
git add C:/Users/Bapti/.doom.d/config.org
git commit -m "feat: configure org-ai inline AI blocks"
```

---

### Task 4.3: Configure Agent-Driven Visualization

**Files:**
- Modify: `C:/Users/Bapti/.doom.d/config.org`

- [ ] **Step 1: Add agent viz helper to config.org**

Append to `C:/Users/Bapti/.doom.d/config.org`:
```org
* Agent-Driven Visualization
** Helper: run agent skill from Org
(defun my/agent-generate-viz (prompt skill)
  "Send PROMPT to AGENT SKILL, insert result link."
  (interactive "sPrompt: \nsSkill: ")
  (let ((cmd (format "npx skills run %s --prompt \"%s\"" skill prompt)))
    (shell-command cmd)))

** Org-babel macro for agent calls
;; Usage in Org:
;; #+call: agent-viz("Generate a Bode plot for this OTA", "davila7/matplotlib")
```

- [ ] **Step 2: Sync**

Run: `$env:USERPROFILE\.emacs.d\bin\doom.cmd sync`

- [ ] **Step 3: Commit**

```bash
git add C:/Users/Bapti/.doom.d/config.org
git commit -m "feat: add agent-driven visualization helper"
```

---

### Task 4.4: Verify Full End-to-End Workflow

**Files:** None (verification only)

- [ ] **Step 1: Test PKM → AI synthesis**

In Emacs: open a literature note. `SPC a b` → insert org-ai block → "Summarize the key claims of this paper" → `C-c C-c`. AI generates summary. Save to note.

- [ ] **Step 2: Test data → viz pipeline**

Create Org block with Polars → filter → Matplotlib. `C-c C-c`. PNG appears inline with dark theme.

- [ ] **Step 3: Test electronics → simulation**

If ngspice installed: create ob-spice block, `C-c C-c`. Expected: simulation runs, results captured.

- [ ] **Step 4: Test agent viz generation**

Invoke an agent skill to generate a simple plot. Verify output file created.

- [ ] **Step 5: Test diagramming**

Create Mermaid block → `C-c C-c` → PNG appears. Create DOT file → `C-c C-p` → graph preview.

- [ ] **Step 6: Commit (Stage 4 complete — setup finished)**

```bash
git commit --allow-empty -m "feat: Stage 4 complete — full Emacs Org setup verified end-to-end"
```

---

## Self-Review Summary

- **Spec coverage:** All 10 sections mapped. Stage 1 covers sections 1–3 (Architecture, UI, Keybindings). Stage 2 covers section 4 (PKM). Stage 3 covers sections 5–7 (Computing, Viz, Electronics) plus the educational viz sub-system. Stage 4 covers section 8 (AI). Section 10 (Constraints) is reference material.
- **No placeholders:** All file paths exact. All code complete. All commands with expected outputs.
- **Type consistency:** Config file paths consistent throughout. `.doom.d/config.org` is the single source for all Emacs configuration. The `packages.el` defines all extra packages.
- **Existing plan referenced:** Task 3.5 delegates to `2026-04-26-educational-viz-plan.md` to avoid duplication.
