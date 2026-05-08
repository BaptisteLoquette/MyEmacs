# Emacs Configuration — Reproduction Guide

Complete documentation for reproducing both Centaur Emacs and Doom Emacs setups
on Fedora (and other Linux distributions). All custom modules, AI integrations,
FPGA/EDA tooling, diagramming, and PKM workflows are covered.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Centaur Emacs Setup](#2-centaur-emacs-setup)
3. [Doom Emacs Setup](#3-doom-emacs-setup)
4. [External Tools (Fedora)](#4-external-tools-fedora)
5. [Python Bridges](#5-python-bridges)
6. [Environment Variables & Auth-Source](#6-environment-variables--auth-source)
7. [Keybinding Reference](#7-keybinding-reference)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Architecture Overview

There are two active Emacs configurations:

| Config | Path | Profile Switcher | Use Case |
|--------|------|-------------------|----------|
| **Centaur** | `~/emacs-configs/centaur-emacs/` | Chemacs2 | Full R&D workstation: FPGA, EDA, diagrams, PKM, AI |
| **Doom**    | `~/emacs-configs/doom-emacs/`  | Chemacs2 | Scientific computing: Jupyter, Julia, Python, plots |

Both are switched via [Chemacs2](https://github.com/plexus/chemacs2) (`~/.emacs.d`).

### Centaur Configuration Files

```
centaur-emacs/
├── early-init.el              ; Startup perf (GC, file-name-handler-alist)
├── init.el                    ; Main loader — requires init-const → init-custom → init-funcs → packages
├── custom.el                  ; Early user settings (theme, LSP, proxy) ← YOUR EDITS HERE
├── custom-post.el             ; Post-init orchestrator — loads all domain files
│   ├── custom-post-data.el    ; Org, roam, babel, RSS, tables
│   ├── custom-post-ai.el      ; gptel + org-ai multi-model backends
│   ├── custom-post-pkm.el     ; Denote, org-brain, svg-tag-mode
│   ├── custom-post-viz.el     ; Matplotlib, Plotly, Manim templates
│   ├── custom-post-eda.el     ; ob-spice, matlab, Xschem/Magic
│   ├── custom-post-fpga.el    ; Verilog/VHDL, Yosys, GTKWave
│   ├── custom-post-diagram.el ; PlantUML, TikZ, Graphviz, Mermaid
│   ├── custom-post-sketch.el  ; Excalidraw, artist-mode, ASCII
│   └── custom-post-adhd-focus.el ; UI: fonts, themes, writeroom, focus
├── env.el                     ; PATH, UTF-8, LSP env vars ← YOUR EDITS HERE
└── lisp/                      ; Core Centaur modules (do NOT modify)
```

### Doom Configuration Files

```
doom-emacs/              ; Doom framework (upstream)
~/.doom.d/
├── init.el              ; Doom modules enabled
├── config.org           ; Literate config (tangled to config.el)
├── config.el            ; Tangled output — DO NOT EDIT DIRECTLY
├── packages.el          ; Extra packages beyond Doom modules
├── custom.el            ; `custom-set-variables` output
└── modules/
    └── org-ai-search/
        ├── org-ai-search.el          ; Minor mode & commands
        ├── org-ai-search-table.el    ; Table parse/render
        ├── org-ai-search-utils.el    ; Auth helpers
        └── python/
            ├── requirements.txt         ; requests>=2.31.0
            └── org_ai_search/
                ├── __main__.py
                ├── core.py
                ├── config.py
                └── backends/
                    ├── base.py
                    ├── semantic_scholar.py
                    ├── arxiv.py
                    └── github.py
```

---

## 2. Centaur Emacs Setup

### 2.1 Prerequisites (Fedora)

```bash
# Emacs 29+ ( Centaur requires 28.1+, recommend 30.2+ )
sudo dnf install emacs

# Git
sudo dnf install git

# Fonts (JetBrains Mono, Lexend Deca)
# Download from:
#   https://www.jetbrains.com/lp/mono/
#   https://www.lexend.com/
# Install to ~/.local/share/fonts/ then: fc-cache -fv

# Python (for babel/Jupyter)
sudo dnf install python3 python3-pip

# Optional: Ngspice (EDA), Graphviz, Java (PlantUML), TeX Live (TikZ)
sudo dnf install ngspice graphviz java-latest-openjdk texlive-scheme-full
```

### 2.2 Clone and Configure

```bash
# 1. Install Chemacs2 (profile switcher)
git clone https://github.com/plexus/chemacs2.git ~/.emacs.d

# 2. Create profile selector
cat > ~/.emacs-profiles.el << 'EOF'
(("centaur" . ((user-emacs-directory . "~/emacs-configs/centaur-emacs")
                (env . (("CENTAUR_PROFILE" . "r&d")))))
 ("doom"    . ((user-emacs-directory . "~/emacs-configs/doom-emacs")
                (env . (("DOOMDIR" . "~/.doom.d"))))))
EOF

# 3. Clone this repo
git clone https://github.com/BaptisteLoquette/MyEmacs.git ~/emacs-configs

# 4. Create env.el from template
cp ~/emacs-configs/centaur-emacs/env-example.el \
   ~/emacs-configs/centaur-emacs/env.el

# 5. Create custom.el from template
cp ~/emacs-configs/centaur-emacs/custom-example.el \
   ~/emacs-configs/centaur-emacs/custom.el
```

### 2.3 Required `custom.el` Changes (Fedora)

Edit `~/emacs-configs/centaur-emacs/custom.el`:

```elisp
;; User info
(setq centaur-full-name "Your Name")
(setq centaur-mail-address "your@email.com")

;; Theme
(setq centaur-theme 'modus-vivendi-tinted)

;; LSP
(setq centaur-lsp 'lsp-mode)

;; Disable Windows-specific hacks
;; (remove or comment out Windows-only sections)
```

### 2.4 Required `env.el` Changes (Fedora)

Edit `~/emacs-configs/centaur-emacs/env.el`:

```elisp
;; UTF-8 is default on Linux; keep for safety
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

;; Add OSS CAD Suite to PATH (FPGA tools)
(setenv "PATH"
  (concat (expand-file-name "~/tools/oss-cad-suite/bin")
          ":" (getenv "PATH")))

;; Optional: LSP performance
;; (setenv "LSP_USE_PLISTS" "true")
```

### 2.5 First Launch

```bash
# Launch Centaur profile
emacs --with-profile centaur

# First startup will install all packages via MELPA (takes 5-15 minutes)
```

### 2.6 Centaur Domain Modules Reference

| File | Domain | Key Packages |
|------|--------|--------------|
| `custom-post-data.el` | Org, Roam, Babel, PDF, RSS | org-roam, org-ql, org-transclusion, org-ref, pdf-tools, jupyter, elfeed |
| `custom-post-ai.el` | Multi-model AI | gptel (GPT-4o, Claude, MiniMax, OpenCode, Ollama), org-ai |
| `custom-post-pkm.el` | PKM tools | denote, org-brain, svg-tag-mode, org-side-tree, org-fragtog |
| `custom-post-viz.el` | Visualization | Matplotlib, Plotly, Manim (via Org babel templates) |
| `custom-post-eda.el` | EDA / Simulation | ob-spice, matlab-mode, Xschem/Magic shell helpers |
| `custom-post-fpga.el` | FPGA / RTL | verilog-ts-mode, verilog-ext, vhdl-ts-mode, vhdl-ext, fpga.el |
| `custom-post-diagram.el` | Technical diagrams | PlantUML, TikZ, Graphviz, Mermaid, Ditaa |
| `custom-post-sketch.el` | Freehand sketches | artist-mode, picture-mode, Excalidraw (commented) |
| `custom-post-adhd-focus.el` | UI / Focus | writeroom-mode, olivetti, focus, dimmer, visual-fill-column |

---

## 3. Doom Emacs Setup

### 3.1 Prerequisites (Fedora)

```bash
# Emacs 29+ with native compilation
sudo dnf install emacs

# Git and ripgrep
sudo dnf install git ripgrep

# Doom CLI prerequisites
sudo dnf install fd-find

# Python for Jupyter bridge
sudo dnf install python3 python3-pip
pip3 install jupyter matplotlib numpy pandas

# Julia (optional)
sudo dnf install julia
```

### 3.2 Install Doom

```bash
# 1. Clone Doom into the tracked directory
git clone --depth 1 https://github.com/doomemacs/doomemacs.git \
  ~/emacs-configs/doom-emacs

# 2. Link DOOMDIR
ln -s ~/.doom.d ~/.doom.d || true

# 3. Clone this repo (already done in Centaur step)
#    ~/.doom.d/ is inside ~/emacs-configs/ via the repo

# 4. Doom install
cd ~/emacs-configs/doom-emacs
~/.emacs.d/bin/doom install

# 5. Sync after any config change
~/.emacs.d/bin/doom sync
```

### 3.3 Required Doom `init.el` Overview

The `~/.doom.d/init.el` enables these Doom modules:

```elisp
(doom!
  :completion (vertico +icons) company
  :ui doom doom-dashboard doom-modeline treemacs vc-gutter workspaces
  :editor evil file-templates fold multiple-cursors
  :emacs (dired +icons) electric (ibuffer +icons) undo vc
  :term vterm
  :checkers syntax spell
  :tools (eval +overlay) lookup (lsp +peek) magit pdf
  :lang (org +roam2 +noter +present +jupyter)
        (python +lsp +pyright +conda)
        (julia +lsp +snail)
        (latex +fold)
        (sh +fish)
        data (emacs-lisp +lsp) markdown
  :config (default +bindings +smartparens))
```

### 3.4 Doom `packages.el` Extra Packages

```elisp
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

;; Drawing
(package! uniline)
(package! edraw-org
  :recipe (:host github :repo "misohena/el-easydraw"))
(package! sketch-mode)

;; AI Assistants
(package! gptel)
(package! org-ai)
(package! aider
  :recipe (:host github :repo "tninja/aider.el"))
(package! ellama)
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el"))

;; Custom module
(package! org-ai-search
  :recipe (:local-repo "modules/org-ai-search"
           :files (:defaults "python" "python/**/*")))
```

### 3.5 Fedorizing Doom `config.org`

The `config.org` (which tangles to `config.el`) contains Windows-absolute paths
that must be adapted for Fedora. Replace these sections:

**Git Bash shell:**
```elisp
;; BEFORE (Windows):
(setq shell-file-name "C:/Program Files/Git/bin/bash.exe")

;; AFTER (Fedora — already has /bin/bash):
(setq shell-file-name "/bin/bash")
```

**Python / Matplotlib prologue:**
```elisp
;; BEFORE:
(:prologue . "exec(open('C:/Users/Bapti/.emacs.d/header.py').read())")

;; AFTER:
(:prologue . "exec(open('~/.emacs.d/header.py').read())")
```

**External tool paths:**
```elisp
;; BEFORE (Windows absolutes):
(setq org-plantuml-jar-path "C:/tools/plantuml.jar")
(setq org-plantuml-java-command "C:/Program Files/.../java.exe")

;; AFTER (Fedora — let `executable-find` or package manager handle it):
(setq org-plantuml-jar-path (expand-file-name "~/tools/plantuml.jar"))
(setq org-plantuml-java-command (or (executable-find "java") "java"))
```

**Then re-tangle:**
```bash
# Inside Emacs:
M-x org-babel-tangle    ; on config.org
# Or run:
cd ~/.doom.d && emacs --batch config.org -f org-babel-tangle
```

### 3.6 First Launch

```bash
# In emacs-configs repo with Chemacs2 already installed:
emacs --with-profile doom

# Doom will compile packages on first run
```

---

## 4. External Tools (Fedora)

### 4.1 OSS CAD Suite (FPGA)

```bash
# Download from https://github.com/YosysHQ/oss-cad-suite-build
cd ~/tools
curl -L -o oss-cad-suite-linux-x64.tgz \
  "https://github.com/YosysHQ/oss-cad-suite-build/releases/latest/download/oss-cad-suite-linux-x64.tgz"
tar xzf oss-cad-suite-linux-x64.tgz

# Already referenced in custom-post-fpga.el via ~/tools/oss-cad-suite/
```

### 4.2 Java (PlantUML, Ditaa)

```bash
sudo dnf install java-latest-openjdk
# Verify: java -version
```

### 4.3 TeX Live (TikZ Diagrams)

```bash
sudo dnf install texlive-scheme-full
# Or minimal: texlive-latex texlive-pgfplots texlive-circuitikz
```

### 4.4 Graphviz

```bash
sudo dnf install graphviz
# Verify: dot -V
```

### 4.5 Mermaid CLI

```bash
sudo dnf install nodejs npm
npm install -g @mermaid-js/mermaid-cli
# Verify: mmdc --version
```

### 4.6 Ngspice (EDA)

```bash
sudo dnf install ngspice
# Verify: ngspice --version
```

### 4.7 FFmpeg (Manim Animations)

```bash
sudo dnf install ffmpeg
# Verify: ffmpeg -version
```

### 4.8 Pandoc (Web Capture Fallback)

```bash
sudo dnf install pandoc
# Verify: pandoc --version
```

---

## 5. Python Bridges

### 5.1 Org-AI-Search Python Bridge

```bash
cd ~/.doom.d/modules/org-ai-search/python
pip3 install -r requirements.txt    # requests>=2.31.0

# Optional API keys in ~/.authinfo:
# machine api.semanticscholar.org password YOUR_KEY
# machine api.github.com password YOUR_TOKEN
```

### 5.2 Centaur Babel Languages

These require system binaries:

| Language | Binary | Install Command |
|----------|--------|----------------|
| python   | python3 | `sudo dnf install python3` |
| R        | R       | `sudo dnf install R` |
| julia    | julia   | `sudo dnf install julia` |
| shell    | bash    | preinstalled |
| gnuplot  | gnuplot | `sudo dnf install gnuplot` |
| plantuml | java + jar | see section 4.2 |
| ditaa    | java + jar | bundled with Org |
| dot      | dot     | `sudo dnf install graphviz` |
| mermaid  | mmdc    | `npm install -g @mermaid-js/mermaid-cli` |
| spice    | ngspice | `sudo dnf install ngspice` |
| latex    | pdflatex | `sudo dnf install texlive-scheme-full` |
| verilog  | iverilog | in OSS CAD Suite |

---

## 6. Environment Variables & Auth-Source

### 6.1 Centaur AI Backends (custom-post-ai.el)

Uses environment variables (no hardcoded keys):

| Variable | Backend |
|----------|---------|
| `OPENAI_API_KEY` | GPT-4o, org-ai default |
| `ANTHROPIC_API_KEY` | Claude (gptel) |
| `MINIMAX_API_KEY` | MiniMax M2.7 |
| `OPENCODE_API_KEY` | OpenCode Go |
| `OLLAMA_API_KEY` | Ollama local |

Set in your shell profile (`~/.bashrc` / `~/.zshrc`) or via auth-source.

### 6.2 Doom Auth-Source (`~/.authinfo` or `~/.authinfo.gpg`)

Doom uses `auth-source` for all API keys. Create:

```bash
# ~/.authinfo (chmod 600)
machine api.anthropic.com password sk-ant-...
machine api.minimax.chat password YOUR_MINIMAX_KEY
machine openrouter.ai password YOUR_OPENROUTER_KEY
machine api.semanticscholar.org password YOUR_S2_KEY
machine api.github.com password ghp_...
```

### 6.3 Ellama Session Directory

Doom config sets:
```elisp
(setq ellama-sessions-directory "~/.emacs.d/.local/cache/ellama-sessions")
```

On Fedora with Chemacs2, `~/.emacs.d` points to Chemacs2; sessions go there.
Adjust if you want them in `~/emacs-configs/doom-emacs/.local/cache/ellama-sessions`.

---

## 7. Keybinding Reference

### 7.1 Centaur — Global Prefix Maps

| Prefix | Domain | Files |
|--------|--------|-------|
| `C-c a` | AI (gptel, org-ai) | custom-post-ai.el |
| `C-c n` | Org / Roam / Notes | custom-post-data.el |
| `C-c p` | PKM (Denote, brain) | custom-post-pkm.el |
| `C-c v` | Visualization | custom-post-viz.el |
| `C-c e` | EDA / Simulation | custom-post-eda.el |
| `C-c f` | FPGA / RTL | custom-post-fpga.el |
| `C-c d` | Diagrams / Sketch | custom-post-diagram.el, custom-post-sketch.el |
| `C-c w` | Web capture | custom-post-data.el |
| `C-c r` | RSS / Elfeed | custom-post-data.el |
| `C-c t` | Table helpers | custom-post-data.el |
| `C-c z` | Writeroom toggle | custom-post-adhd-focus.el |

### 7.2 Centaur — AI Keybindings (`C-c a`)

| Key | Action |
|-----|--------|
| `C-c a g` | gptel-menu |
| `C-c a 4` | Switch to GPT-4o |
| `C-c a c` | Switch to Claude |
| `C-c a m` | Switch to MiniMax |
| `C-c a o` | Switch to OpenCode Go |
| `C-c a l` | Switch to Ollama |
| `C-c a q` | Insert org-ai block |
| `C-c a s` | Send region to gptel |
| `C-c a z m` | Switch org-ai to MiniMax |
| `C-c a z o` | Switch org-ai to OpenCode |
| `C-c a z d` | Switch org-ai to GPT-4o |

### 7.3 Centaur — Org / Roam (`C-c n`)

| Key | Action |
|-----|--------|
| `C-c n f` | org-roam-node-find |
| `C-c n i` | org-roam-node-insert |
| `C-c n l` | org-roam-buffer-toggle |
| `C-c n c` | org-roam-capture |
| `C-c n s` | Search roam by current tag |
| `C-c n .` | Insert roam link by tag |
| `C-c n #` | org-ql by current tag |
| `C-c n t` | org-transclusion-add |
| `C-c n T` | org-transclusion-mode |
| `C-c n d` | Open Research Dashboard |

### 7.4 Centaur — FPGA (`C-c f`)

| Key | Action |
|-----|--------|
| `C-c f p` | fpga-program |
| `C-c f b` | fpga-build |
| `C-c f c` | fpga-clean |
| `C-c f r` | fpga-run (simulation) |
| `C-c f s` | fpga-synth |
| `C-c f i` | fpga-impl |
| `C-c f t` | fpga-testbench |
| `C-c f w` | fpga-waveform (GTKWave) |
| `C-c f d` | fpga-drc |
| `C-c f l` | fpga-lint |
| `C-c f g` | Open VCD in GTKWave |
| `C-c f v` | Verilator lint |
| `C-c f y` | Yosys synthesis |
| `C-c f T` | Insert FPGA Org template |
| `C-c f n` | New FPGA project skeleton |

### 7.5 Centaur — Diagrams (`C-c d`)

| Key | Action |
|-----|--------|
| `C-c d u` | Insert PlantUML block |
| `C-c d t` | Insert Ditaa block |
| `C-c d z` | Insert TikZ block |
| `C-c d b` | Insert TikZ bit-field |
| `C-c d c` | Insert TikZ circuit |
| `C-c d p` | Insert TikZ physics diagram |
| `C-c d m` | Insert TikZ math plot |
| `C-c d g` | Insert Graphviz block |
| `C-c d M` | Insert Mermaid block |
| `C-c d f` | Insert LaTeX formula |
| `C-c d B` | Generate bit-field (interactive) |
| `C-c d D` | Ensure diagram output dir |
| `C-c d ?` | Show diagram tool status |

### 7.6 Doom — Leader Key (`SPC`)

| Key | Action |
|-----|--------|
| `SPC a c` | GPTel chat |
| `SPC a s` | GPTel send region |
| `SPC a m` | GPTel menu |
| `SPC a .` | Cycle AI backend |
| `SPC a ,` | Show AI backend |
| `SPC a b` | org-ai complete block |
| `SPC a d` | Aider (OpenRouter) |
| `SPC a D` | Aider (Ollama) |
| `SPC o r` | Jupyter REPL |
| `SPC o E` | Elfeed RSS |
| `SPC d a` | Artist mode |
| `SPC d p` | Picture mode |
| `SPC d u` | Uniline mode |
| `SPC d s` | Sketch mode |

### 7.7 Doom — Org-AI-Search (`C-c C-s`)

| Key | Action |
|-----|--------|
| `C-c C-s s` | Execute discovery table |
| `C-c C-s r` | Refresh results (preserve tags) |
| `C-c C-s e` | Edit discovery row |
| `C-c C-s d` | Delete stale rows |
| `C-c C-s t` | Tag current output row |
| `C-c C-s c` | Clear tags on current row |
| `C-c C-s b` | Cycle backend |

---

## 8. Troubleshooting

### 8.1 "Emacs fails to start on Fedora"

Check Centaur bootstrap order:
```bash
# Minimum test
emacs -Q -l ~/emacs-configs/centaur-emacs/init-mini.el
```

### 8.2 "Packages not found"

```elisp
;; In custom.el, ensure you use a reachable archive
(setq centaur-package-archives 'melpa)
M-x package-refresh-contents
```

### 8.3 "org-roam-db-sync blocks startup" (Windows symptom on Linux too)

```elisp
;; In custom-post-data.el — autosync is already conditional:
(unless (eq system-type 'windows-nt)
  (org-roam-db-autosync-mode))
;; Run M-x org-roam-db-sync manually after startup.
```

### 8.4 "PlantUML / TikZ diagrams don't render"

```bash
# Verify tools are on PATH
which java pdflatex dot mmdc ngspice

# Run diagram status in Emacs
M-x my/diagram-status
```

### 8.5 "Python babel blocks hang"

```elisp
;; In env.el or custom.el
(setq python-shell-interpreter "python3")
(setq org-babel-python-command "python3")
```

### 8.6 "No fonts (JetBrains Mono / Lexend Deca)"

```bash
# Download and install manually
mkdir -p ~/.local/share/fonts
cp JetBrainsMono-*.ttf ~/.local/share/fonts/
cp LexendDeca-*.ttf ~/.local/share/fonts/
fc-cache -fv
```

### 8.7 "Windows paths leaking into Linux"

Several Centaur files hardcode `C:/` paths (e.g., `custom-post-diagram.el`).
These are guarded by `executable-find` / `file-exists-p` and will gracefully
degrade on Linux. To fully Fedorize:

1. Replace hard `C:/` tool paths with `(executable-find "toolname")`
2. Re-tangle Doom `config.org` after path edits
3. Update `org-ai-search-python-executable` to `"python3"`

### 8.8 "Doom sync fails"

```bash
cd ~/emacs-configs/doom-emacs
~/.emacs.d/bin/doom sync --purge
# If still broken:
rm -rf ~/.emacs.d/.local
~/.emacs.d/bin/doom install
```

---

## Maintenance Checklist

| Task | Command / Action | Frequency |
|------|----------------|-----------|
| Update Centaur packages | `M-x centaur-update` | Weekly |
| Update Doom packages | `~/.emacs.d/bin/doom upgrade` | Weekly |
| Sync org-roam DB | `M-x org-roam-db-sync` | After bulk file ops |
| Clean stale search rows | `C-c C-s d` in org-ai-search | As needed |
| Re-tangle config.org | `M-x org-babel-tangle` on `~/.doom.d/config.org` | After edits |
| Refresh auth-source | `M-x auth-source-forget-all-cached` | After key rotation |

---

## Fedora Quick-Start Summary

```bash
# 1. System deps
sudo dnf install emacs git ripgrep fd-find python3 texlive-scheme-full \
  graphviz java-latest-openjdk ngspice ffmpeg nodejs julia R

# 2. Install fonts (JetBrains Mono, Lexend Deca) to ~/.local/share/fonts/

# 3. Install Chemacs2
git clone https://github.com/plexus/chemacs2.git ~/.emacs.d

# 4. Clone config
git clone https://github.com/BaptisteLoquette/MyEmacs.git ~/emacs-configs

# 5. Set up profiles
cat > ~/.emacs-profiles.el << 'EOF'
(("centaur" . ((user-emacs-directory . "~/emacs-configs/centaur-emacs")))
 ("doom"    . ((user-emacs-directory . "~/emacs-configs/doom-emacs")
                (env . (("DOOMDIR" . "~/.doom.d"))))))
EOF

# 6. Create Centaur user files from templates
cp ~/emacs-configs/centaur-emacs/env-example.el ~/emacs-configs/centaur-emacs/env.el
cp ~/emacs-configs/centaur-emacs/custom-example.el ~/emacs-configs/centaur-emacs/custom.el

# 7. Install Doom CLI
cd ~/emacs-configs/doom-emacs
~/.emacs.d/bin/doom install

# 8. Sync extra Doom packages
~/.emacs.d/bin/doom sync

# 9. Install Python bridge deps
pip3 install -r ~/.doom.d/modules/org-ai-search/python/requirements.txt

# 10. Set API keys in ~/.authinfo (chmod 600)

# 11. Launch!
emacs --with-profile centaur   # or --with-profile doom
```
