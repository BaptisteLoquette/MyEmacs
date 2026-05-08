# Emacs Typography & Visual Base Settings for ADHD and Deep Focus

> Research compilation dated 2026-05-03. Sources cited inline.

---

## 1. Font Families for ADHD

### 1.1 Variable-Pitch (Prose / Reading)

| Font | Why It Helps | Source |
|------|-------------|--------|
| **Lexend** | Designed by Dr. Bonnie Shaver-Troup to reduce visual stress. Optimized letter spacing reduces *visual crowding*—the #1 obstacle for ADHD readers. Backed by research showing improved reading speed and comprehension. Multiple weights (Deca, Giga, etc.). Free on Google Fonts. | [Google Design](https://design.google/library/lexend-readability), [Lexend.com](https://www.lexend.com/) |
| **Atkinson Hyperlegible** | Created by the Braille Institute. Maximizes distinction between similar characters (`I`/`l`/`1`, `O`/`0`). Remains legible at any size. Low-vision design also benefits ADHD by reducing disambiguation effort. | [Nook Blog 2026](https://getnook.net/blog/best-fonts-for-adhd-reading) |
| **OpenDyslexic** | Weighted bottoms anchor letters visually, preventing them from "flipping." Particularly useful when ADHD co-occurs with dyslexic traits. Open-source. | [OpenDyslexic.org](https://opendyslexic.org/) |
| **Comic Neue / Sassoon** | Informal, rounded shapes reduce reading anxiety. Good for long-form prose when formality is not required. | [Lexifont 2026](https://lexifont.com/blog/best-fonts-for-dyslexia-2026) |

**Key insight from research:**
> "For ADHD readers specifically, reducing visual crowding and letter confusion means the brain spends less energy on decoding and has more capacity for comprehension and focus."
> — [Nook Blog, "7 Best ADHD Fonts for Reading (Tested in 2026)"](https://getnook.net/blog/best-fonts-for-adhd-reading)

### 1.2 Monospace (Programming / Code)

| Font | Why It Helps | Source |
|------|-------------|--------|
| **JetBrains Mono** | Increased x-height, clear distinction between look-alikes, ligatures optional. Designed specifically for IDE readability and long coding sessions. | [Snappify 2025](https://snappify.com/blog/best-fonts-for-coding) |
| **Iosevka** | Tall, narrow, and highly configurable. Fits more columns on screen while maintaining crisp outlines. Extensive variant family (Aile, Etoile, Curly, etc.). Good for ADHD brains that like density but need clarity. | [GitHub be5invis/Iosevka](https://github.com/be5invis/Iosevka) |
| **Monaspace** | GitHub Next superfamily. Offers "texture healing" (harmonizing glyph density) and stylistic sets for ligatures. Can be tuned per-language. | [Monaspace](https://monaspace.githubnext.com/) |
| **Fira Code / Cascadia Code** | Well-tested, excellent ligature support, large community. Safe defaults. | [Ordoh 2026](https://www.ordoh.com/best-coding-fonts-2026/) |

**Recommendation:** Try **Lexend Deca** for variable-pitch prose and **JetBrains Mono** or **Iosevka** for code. ADHD brains vary—switching should be easy.

---

## 2. Optimal Font Sizes & Line Spacing

### 2.1 Evidence

- **"Make It Big!" (Rello et al., 2016):** Eye-tracking study with 104 participants found that larger font sizes measurably improve online readability and reduce fixation counts. [PDF](https://pielot.org/pubs/Rello2016-Fontsize.pdf)
- **NCBI / PMC Study:** Near viewing distance and longer viewing times are associated with myopia. Identifying font size that guarantees appropriate visual ergonomics is critical. [PMC10151978](https://pmc.ncbi.nlm.nih.gov/articles/PMC10151978/)
- **USWDS Typography Guide:** Typesetting controls readability through size, style, and spacing. [Digital.gov](https://designsystem.digital.gov/components/typography/)

### 2.2 Concrete Recommendations

| Context | Font Size | Line Height / Spacing | Rationale |
|---------|-----------|----------------------|-----------|
| Body text / prose | **14–16 pt** (minimum 14) | **1.5–1.7** | Reduces visual crowding; 1.5x is the WCAG accessibility baseline. |
| Code / monospace | **13–15 pt** | **1.4–1.6** | Slightly tighter than prose, but still generous. Tight packing increases cognitive load for ADHD. |
| UI / minibuffer | **12–13 pt** | — | Should remain smaller but not strain. |

> "Good fonts have natural rhythm that helps your eyes move smoothly across the page. Bad fonts create stuttering, choppy reading."
> — [Nook Blog](https://getnook.net/blog/best-fonts-for-adhd-reading)

### 2.3 Emacs Lisp Snippets

```elisp
;; Base font settings
(setq doom-font (font-spec :family "JetBrains Mono" :size 14))
(setq doom-variable-pitch-font (font-spec :family "Lexend Deca" :size 15))

;; Line spacing (in pixels added between lines)
(setq-default line-spacing 0.25)  ; ~1.25x visual spacing; increase to 0.4 for 1.5x feel

;; Or use line-height proportionally via face remap (requires Emacs 29+)
;; (set-face-attribute 'default nil :height 140)
```

---

## 3. Cursor, Fringe, Margin & Scroll Behavior

### 3.1 Cursor Settings

| Setting | Recommendation | Why |
|---------|---------------|-----|
| **Cursor type** | `bar` (vertical line) | Less visually "heavy" than block; reduces constant peripheral distraction. |
| **Blinking** | **OFF** solid cursor | Blinking is inherently attention-grabbing and creates a sense of expectancy. Many Emacs users explicitly disable it for focus. [Emacs@Dyerdwelling](https://www.emacs.dyerdwelling.family/emacs/20230406200632-emacs--cursor-blinking-rate) |
| **Color** | High-contrast but calm (e.g., `#7FBAFF` on dark, `#0066CC` on light) | Must be locatable without screaming for attention. |

```elisp
;; Solid bar cursor — minimal distraction
(setq-default cursor-type 'bar)
(blink-cursor-mode -1)

;; Optional: highlight current line to aid cursor location without blinking
(global-hl-line-mode +1)
(set-face-attribute 'hl-line nil :background "#1a1a2e" :extend t)
```

### 3.2 Fringes & Margins

| Setting | Recommendation | Why |
|---------|---------------|-----|
| **Fringe width** | 8–12 px | Just wide enough for fringe indicators (git-gutter, etc.) without eating horizontal space. Too wide = visual clutter. |
| **Left margin** | Minimal or managed by `visual-fill-column` | Large margins can help center content and reduce eye travel. |
| **Right margin** | Let `visual-fill-column` handle it | Keeps line length within readable bounds (~50–75 chars). |

```elisp
;; Fringe width (in pixels)
(setq-default left-fringe-width 8)
(setq-default right-fringe-width 8)

;; Or use fringe-mode shorthand
(fringe-mode 8)

;; Scroll margin: keep cursor N lines from top/bottom edge
(setq scroll-margin 3)

;; Smooth / conservative scrolling: avoid big jumps
(setq scroll-conservatively 101)    ; never recenter automatically
(setq scroll-step 1)
(setq auto-window-vscroll nil)
```

### 3.3 Scroll Behavior

- **Conservative scrolling** (`scroll-conservatively > 100`) prevents Emacs from recentering the cursor aggressively, which is disorienting for ADHD.
- **Keep cursor stationary** when scrolling with mouse/trackpad if possible; Emacs tends to move point with scroll, which can break flow.

---

## 4. Window Dividers & Frame Settings (Minimize Visual Clutter)

### 4.1 Window Dividers

Window dividers are the bars between split windows. For deep focus, they should be as subtle as possible or removed entirely.

```elisp
;; Subtle or no window dividers
(setq window-divider-default-places 'right-only)   ; or 'bottom-only
(setq window-divider-default-right-width 1)
(setq window-divider-default-bottom-width 1)
(window-divider-mode +1)   ; or -1 to disable completely
```

### 4.2 Frame & UI Chrome

| Element | Recommendation | Emacs Lisp |
|---------|---------------|------------|
| **Menu bar** | Hide | `(menu-bar-mode -1)` |
| **Tool bar** | Hide | `(tool-bar-mode -1)` |
| **Scroll bars** | Hide | `(scroll-bar-mode -1)` |
| **Fringes** | Minimal | `(fringe-mode 8)` |
| **Modeline** | Simplify or hide in zen mode | Use `doom-modeline` with minimal style, or hide in `writeroom-mode` |
| **Window borders** | Thin / same color as background | `(set-face-background 'vertical-border "#000000")` etc. |

```elisp
;; Maximum minimalism base settings
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(fringe-mode 8)

;; Make vertical borders invisible (blend with background)
(set-face-foreground 'vertical-border (face-background 'default))
```

### 4.3 Doom Emacs `:ui zen` Module (`writeroom-mode`)

Doom’s zen module provides an all-in-one distraction-free mode:

- Centers the current buffer (`visual-fill-column`).
- Removes the modeline.
- Activates `mixed-pitch-mode` (variable pitch for prose, fixed for code blocks).
- Slightly scales up text (`+zen-text-scale`).
- Thickens window borders (`+zen-window-divider-size`).

```elisp
;; In config.el or +zen module configuration
(setq +zen-text-scale 1.1)           ; subtle scale up
(setq +zen-window-divider-size 2)      ; thicker borders for spatial separation
(setq writeroom-fullscreen-effect t)   ; enable fullscreen on activation

;; Toggle with SPC t z (evil) or M-x +zen/toggle
```

Reference: [Doom Emacs :ui zen docs](https://docs.doomemacs.org/v21.12/modules/ui/zen/)

### 4.4 Centered Writing / Reading with `visual-fill-column`

Even outside zen mode, keeping text centered and line-length bounded reduces eye fatigue:

```elisp
(use-package! visual-fill-column
  :hook (text-mode . visual-fill-column-mode)
  :config
  (setq visual-fill-column-width 80)
  (setq visual-fill-column-center-text t))
```

---

## 5. Summary Cheat Sheet

```elisp
;;; ADHD Deep-Focus Base Visual Settings for Emacs / Doom
;;; Paste into ~/.doom.d/config.el or equivalent

;; 1. FONTS
(setq doom-font (font-spec :family "JetBrains Mono" :size 14))
(setq doom-variable-pitch-font (font-spec :family "Lexend Deca" :size 15))
(setq-default line-spacing 0.25)

;; 2. CURSOR
(setq-default cursor-type 'bar)
(blink-cursor-mode -1)
(global-hl-line-mode +1)

;; 3. CHROME REMOVAL
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(fringe-mode 8)

;; 4. SCROLL BEHAVIOR
(setq scroll-margin 3)
(setq scroll-conservatively 101)
(setq scroll-step 1)

;; 5. WINDOW DIVIDERS
(setq window-divider-default-places 'right-only)
(setq window-divider-default-right-width 1)
(window-divider-mode +1)

;; 6. ZEN SETTINGS (if using :ui zen in Doom)
(setq +zen-text-scale 1.1)
(setq +zen-window-divider-size 2)

;; 7. VISUAL FILL COLUMN (centered text)
(use-package! visual-fill-column
  :hook (text-mode . visual-fill-column-mode)
  :config
  (setq visual-fill-column-width 80)
  (setq visual-fill-column-center-text t))
```

---

## 6. Key Sources

1. **Nook Blog** — "7 Best ADHD Fonts for Reading (Tested in 2026)" — [https://getnook.net/blog/best-fonts-for-adhd-reading](https://getnook.net/blog/best-fonts-for-adhd-reading)
2. **Google Design** — "Struggling to Read? A Font May Help" (Lexend case study) — [https://design.google/library/lexend-readability](https://design.google/library/lexend-readability)
3. **Lexifont** — "Best fonts for dyslexia in 2026 — a research-first guide" — [https://lexifont.com/blog/best-fonts-for-dyslexia-2026](https://lexifont.com/blog/best-fonts-for-dyslexia-2026)
4. **Doom Emacs Docs** — `:ui zen` module — [https://docs.doomemacs.org/v21.12/modules/ui/zen/](https://docs.doomemacs.org/v21.12/modules/ui/zen/)
5. **GNU Emacs Manual** — "Window Dividers" — [https://www.gnu.org/software/emacs/manual/html_node/emacs/Window-Dividers.html](https://www.gnu.org/software/emacs/manual/html_node/emacs/Window-Dividers.html)
6. **Rello et al. (2016)** — "Make It Big!: The Effect of Font Size and Line Spacing on Online Readability" — [PDF](https://pielot.org/pubs/Rello2016-Fontsize.pdf)
7. **PMC / NCBI** — "Evaluating the optimised font size and viewing time of online text" — [PMC10151978](https://pmc.ncbi.nlm.nih.gov/articles/PMC10151978/)
8. **USWDS Typography** — [https://designsystem.digital.gov/components/typography/](https://designsystem.digital.gov/components/typography/)
9. **Emacs@Dyerdwelling** — "Cursor Blinking Rate" — [https://www.emacs.dyerdwelling.family/emacs/20230406200632-emacs--cursor-blinking-rate](https://www.emacs.dyerdwelling.family/emacs/20230406200632-emacs--cursor-blinking-rate)
10. **OpenDyslexic** — [https://opendyslexic.org/](https://opendyslexic.org/)
11. **JetBrains Mono** — [https://www.jetbrains.com/lp/mono/](https://www.jetbrains.com/lp/mono/)
12. **Iosevka** — [https://github.com/be5invis/Iosevka](https://github.com/be5invis/Iosevka)
13. **Monaspace** — [https://monaspace.githubnext.com/](https://monaspace.githubnext.com/)

---

*End of findings.*
