# Research Plan: ADHD & Deep Focus Emacs UI Parameters

## Main Research Question
What are the ultimate sets of Emacs UI parameters (fonts, colors, spacing, modes, settings) to create the best interface for ADHD and deep focus across multiple use cases: Org mode/Org Table, Python/Verilog/VHDL/MATLAB/Julia/R programming, FPGA/Electronic Design, Web Browsing, Media Consuming, Paper Research/Reading, and Annotations?

## Subtopics

### 1. Typography & Visual Base Settings for ADHD
- **Scope**: Font families (monospace, variable-pitch), font sizes, line spacing, cursor settings, fringe/margin widths, scroll behavior, window dividers.
- **Expected Info**: Evidence-backed font recommendations for ADHD (e.g., OpenDyslexic, Iosevka, Monaspace), optimal font sizes for focus, line spacing ratios that reduce visual fatigue, minimal cursor distraction settings.

### 2. Color Schemes & Distraction Reduction
- **Scope**: Themes optimized for focus (low contrast, dark mode, syntax highlighting restraint), mode-line customization, minimization of UI chrome, zen/writer modes, disabling bells/animations.
- **Expected Info**: Specific Emacs themes (ef-themes, modus-themes, doom-themes variants), `zone` and distraction-blocking settings, transparency/opacity settings, `focus-mode` or `darkroom` configurations.

### 3. Org Mode & Org Table Deep Focus Settings
- **Scope**: Org-mode visual tweaks, Org-table alignment and fontification, heading sizes, bullets/stars hiding, indentation guides, org-superstar, org-modern.
- **Expected Info**: Settings for `org-modern`, variable-pitch fonts in Org, heading font scaling, table formatting optimizations, narrowing commands (org-narrow-to-subtree), and agenda visualization tweaks.

### 4. Programming Language UI Optimizations
- **Scope**: Python, Verilog, VHDL, MATLAB, Julia, R — font-lock/highlighting settings, LSP UI tweaks (lsp-ui, sideline, doc popup), tree-sitter fontification, line numbers, folding, context isolation.
- **Expected Info**: Tree-sitter highlight remapping, LSP UI minimization, breadcrumb settings, imenu/listing simplification, flycheck/flymake error display restraint, focus-mode for code.

### 5. Web, Media, Research & Annotation Workflows
- **Scope**: Emacs web browsing (eww, shr), PDF reading (pdf-tools), image display, video handling, annotation tools (org-noter, citar, marginalia), bibliography visualization.
- **Expected Info**: `pdf-tools` dark mode, `org-noter` layout settings, `eww`/`shr` readability settings, image scaling defaults, annotation highlighting colors, research sidebar management.

## Synthesis Strategy
Each subtopic will be researched by a dedicated subagent. Results will be merged into a single structured response organized by parameter category: Typography, Colors, Layout, Mode-Specific Settings, and Behavioral Tweaks. The final output will provide concrete Emacs Lisp snippets ready for the user's configuration.
