# Research: Emacs Color Schemes & Distraction-Reduction for ADHD / Deep Focus

**Date:** 2026-05-03  
**Sources:** Protesilaos Stavrou (Modus/Ef themes), Doom Emacs docs, GitHub repos, Emacs Stack Exchange, Reddit r/emacs, EmacsWiki, Kristoffer Balintona blog.

---

## 1. Emacs Themes Optimized for Focus & Low Visual Fatigue

### 1.1 Modus Themes (WCAG AAA, built into Emacs 28+)

The **Modus themes** by Protesilaos Stavrou are the gold standard for accessible readability. They conform to the highest WCAG AAA color-contrast standard (minimum 7:1 luminance ratio for small text) and are built into GNU Emacs starting with version 28.1.

**Theme variants:**

| Variant | Description |
|---------|-------------|
| `modus-operandi` | Main light theme — the reference for a highly legible "default" look. |
| `modus-vivendi` | Main dark theme — counterpart to `modus-operandi`. |
| `modus-operandi-tinted` | Light variant with toned-down intensity; earthy ochre base tones. |
| `modus-vivendi-tinted` | Dark variant with a "night sky" impression; slightly more color variety. |
| `modus-operandi-deuteranopia` | Optimized for red-green color deficiency (uses yellow/blue). |
| `modus-vivendi-deuteranopia` | Dark counterpart to the deuteranopia variant. |
| `modus-operandi-tritanopia` | Optimized for blue-yellow color deficiency (uses red/cyan). |
| `modus-vivendi-tritanopia` | Dark counterpart to the tritanopia variant. |

**Key quotes:**

> "The Modus themes are designed for accessible readability. They conform with the highest standard for color contrast between combinations of background and foreground values." — [Protesilaos Modus Themes Manual](https://protesilaos.com/emacs/modus-themes)

> "The overarching objective of this project is to always offer accessible color combinations. There shall never be a compromise on this principle." — [Protesilaos Modus Themes Manual](https://protesilaos.com/emacs/modus-themes)

**Emacs Lisp snippet:**

```elisp
;; Load a Modus theme (built-in on Emacs 28+)
(load-theme 'modus-vivendi t)

;; Or use the tinted variant for a slightly softer dark background
(load-theme 'modus-vivendi-tinted t)

;; Optional: disable other themes before loading
(setq modus-themes-disable-other-themes t)
```

**Source:** https://protesilaos.com/emacs/modus-themes

---

### 1.2 Ef (εὖ) Themes

The **Ef themes** are also by Protesilaos Stavrou. They are built on top of the Modus themes infrastructure (since v2.0.0) but offer a more colorful and eclectic palette while still maintaining legibility. They are a good choice for users who want more color variety than Modus but still want accessibility.

**Popular variants:** `ef-summer`, `ef-winter`, `ef-day`, `ef-night`, `ef-duo-dark`, `ef-duo-light`, `ef-trio-dark`, `ef-trio-light`, `ef-bio`, `ef-cherie`, `ef-cyprus`, `ef-dream`, `ef-elea`, `ef-autumn`, `ef-spring`, `ef-maris-light`, `ef-maris-dark`, `ef-rebecca`, `ef-rosa`, `ef-frost`, `ef-tritanopia-dark`, `ef-tritanopia-light`, `ef-deuteranopia-dark`, `ef-deuteranopia-light`.

**Emacs Lisp snippet:**

```elisp
(use-package ef-themes
  :ensure t
  :init
  (ef-themes-take-over-modus-themes-mode 1)
  :config
  (setq modus-themes-mixed-fonts t)
  (setq modus-themes-italic-constructs t)
  (modus-themes-load-theme 'ef-summer))
```

**Source:** https://protesilaos.com/emacs/ef-themes

---

### 1.3 Doom Themes

**Doom Themes** (from Doom Emacs) is a megapack of themes. For focus/ADHD, users on Reddit frequently recommend:

- `doom-one` — a popular dark theme with restrained colors.
- `doom-one-light` — light variant.
- `doom-city-lights`, `doom-molokai`, `doom-dracula`, `doom-gruvbox`, `doom-nord`, `doom-solarized-dark`, `doom-solarized-light`, `doom-tomorrow-day`, `doom-tomorrow-night`, `doom-vibrant`, `doom-wilmersdorf`, `doom-zenburn`, `doom-rouge`, `doom-old-hope`, `doom-peacock`, `doom-spacegrey`, `doom-opera`, `doom-opera-light`, `doom-material`, `doom-lantern`, `doom-horizon`, `doom-flatwhite`, `doom-challenger-deep`, `doom-oceanic-next`, `doom-palenight`, `doom-sourcerer`, `doom-dark+`, `doom-ephemeral`, `doom-henna`, `doom-manegarm`, `doom-miramare`, `doom-monokai-classic`, `doom-monokai-pro`, `doom-monokai-octagon`, `doom-monokai-machine`, `doom-monokai-ristretto`, `doom-monokai-spectrum`, `doom-ayu-mirage`, `doom-ayu-dark`, `doom-ayu-light`, `doom-badger`, `doom-bluloco-dark`, `doom-bluloco-light`, `doom-earl-grey`, `doom-ir-black`, `doom-fairy-floss`, `doom-homage-black`, `doom-homage-white`, `doom-ashes`, `doom-acario-dark`, `doom-acario-light`, `doom-nord-aurora`, `doom-nord-light`, `doom-nova`, `doom-selenized-dark`, `doom-selenized-light`, `doom-shades-of-purple`, `doom-snazzy`, `doom-spectrum`, `doom-tokyo-night`, `doom-tokyo-night-storm`, `doom-tokyo-night-day`, `doom-vanilla-dark`, `doom-vanilla-light`, `doom-wilmersdorf`, `doom-xcode`, `doom-zenburn`, `doom-1337`, `doom-3024`, `doom-badger`, `doom-bright`, `doom-bubblegum`, `doom-chocolate`, `doom-clairvoyant`, `doom-clean`, `doom-cobalt`, `doom-dark`, `doom-decay`, `doom-henna`, `doom-homage`, `doom-ir-black`, `doom-lantern`, `doom-laserwave`, `doom-manegarm`, `doom-material-dark`, `doom-miramare`, `doom-moonlight`, `doom-oceanic-next`, `doom-old-hope`, `doom-opera`, `doom-peacock`, `doom-rouge`, `doom-snazzy`, `doom-solarized`, `doom-sourcerer`, `doom-spacegrey`, `doom-tokyo-night`, `doom-vibrant`, `doom-wilmersdorf`, `doom-zenburn`.

**Source:** https://github.com/doomemacs/themes

---

### 1.4 Other Notable Themes

- **nano-theme** — A minimal, consistent theme inspired by Nano editor. Focuses on simplicity and a small curated color palette. Good for users who want extreme visual restraint.
- **flatwhite** — A warm, low-contrast light theme popular among Doom Emacs users for long reading sessions.

---

## 2. Syntax Highlighting Restraint

Excessive syntax highlighting can be visually fatiguing, especially for users with ADHD. Reducing `font-lock` decoration levels is a common strategy.

### 2.1 `font-lock-maximum-decoration`

> "The variable `font-lock-maximum-decoration` determines the preferred level of fontification for each major mode, where integers specify the level of decoration. The default value is t, which is equivalent to the highest available level (usually 3). A value of nil means do not fontify at all. A value of 1 or 2 requests less decoration." — [Emacs Manual](https://www.gnu.org/software/emacs/manual/html_node/emacs/Font-Lock.html)

**Emacs Lisp snippet:**

```elisp
;; Reduce syntax highlighting globally to a more restrained level
(setq font-lock-maximum-decoration 1)

;; Or set per-mode:
(setq font-lock-maximum-decoration
      '((emacs-lisp-mode . 2)
        (python-mode . 1)
        (org-mode . 1)
        (t . t))) ;; default for all other modes

;; Alternatively, disable font-lock entirely for a plain-text feel:
;; (global-font-lock-mode 0)
```

**Source:** https://emacsdocs.org/docs/emacs/Font-Lock

---

## 3. Mode-Line Customization to Reduce Visual Noise

The mode-line is a persistent source of visual clutter. Several strategies exist to reduce or hide it.

### 3.1 doom-modeline (Minimalist but Informative)

**doom-modeline** is described as "A fancy and fast mode-line inspired by minimalism design." It condenses information and uses icons, but can still be trimmed.

> "This module provides an Atom-inspired, minimalistic modeline for Doom Emacs, powered by the doom-modeline package." — [Doom Emacs Docs](https://docs.doomemacs.org/v21.12/modules/ui/modeline/)

**Emacs Lisp snippet (Doom modeline settings):**

```elisp
;; In Doom Emacs, the modeline module is :ui modeline
;; In vanilla Emacs with doom-modeline installed:
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  ;; Disable minor modes display to reduce clutter
  (setq doom-modeline-minor-modes nil)
  ;; Disable indentation info
  (setq doom-modeline-indent-info nil)
  ;; Disable encoding display
  (setq doom-modeline-buffer-encoding nil)
  ;; Disable vcs display (if you don't need it)
  (setq doom-modeline-vcs-max-length 0)
  ;; Show only filename, not full path
  (setq doom-modeline-buffer-file-name-style 'file-name))
```

**Source:** https://github.com/seagle0128/doom-modeline

---

### 3.2 Absolute Minimum / Hidden Mode-Line

For extreme focus, some users hide the mode-line entirely or reduce it to a bare minimum.

> "I don't care at all about the information that modeline shows most of the time. I want the absolute minimum." — [Reddit r/emacs](https://www.reddit.com/r/emacs/comments/s30esp/absolute_minimum_modeline/)

**Emacs Lisp snippet:**

```elisp
;; Hide the mode-line completely
(setq-default mode-line-format nil)

;; Or use a very minimal mode-line
(setq-default mode-line-format
              '(("%e" mode-line-client mode-line-modified mode-line-remote)
                mode-line-frame-identification
                " "
                mode-line-buffer-identification
                "   "
                mode-line-position
                (vc-mode vc-mode)
                "  "
                mode-line-modes))

;; Use telephone-line for a slimmer, powerline-like aesthetic
(use-package telephone-line
  :ensure t
  :config
  (telephone-line-mode 1)
  ;; Use a minimal separator
  (setq telephone-line-primary-left-separator 'telephone-line-nil
        telephone-line-secondary-left-separator 'telephone-line-nil
        telephone-line-primary-right-separator 'telephone-line-nil
        telephone-line-secondary-right-separator 'telephone-line-nil))
```

**Source:** https://www.reddit.com/r/emacs/comments/s30esp/absolute_minimum_modeline/  
**Source:** https://www.emacswiki.org/emacs/ModeLineConfiguration

---

## 4. Zen / Writer Modes

These modes transform Emacs into a distraction-free writing/coding environment by hiding UI elements, centering text, and sometimes changing fonts.

### 4.1 writeroom-mode

> "Writeroom-mode: distraction-free writing for Emacs." — [GitHub](https://github.com/joostkremers/writeroom-mode)

`writeroom-mode` is the most popular and actively maintained zen-mode package. It can:
- Center the current buffer.
- Remove superfluous UI elements (like the modeline).
- Activate `mixed-pitch-mode`.
- Scale up the buffer's text slightly.
- Make the window's borders thicker.

**Emacs Lisp snippet:**

```elisp
(use-package writeroom-mode
  :ensure t
  :config
  ;; Text scale when in writeroom
  (setq writeroom-width 80)
  (setq writeroom-maximize-window nil) ;; don't fullscreen globally by default
  ;; Custom global effects (default removes scroll bars, menu bar, tool bar)
  ;; You can customize which elements are hidden:
  (setq writeroom-global-effects
        '(writeroom-toggle-fullscreen
          writeroom-toggle-menu-bar-lines
          writeroom-toggle-tool-bar-lines
          writeroom-toggle-scroll-bars
          writeroom-toggle-vertical-scroll-bars)))

;; Key binding to toggle
(global-set-key (kbd "C-c z") 'writeroom-mode)
```

**Source:** https://github.com/joostkremers/writeroom-mode

---

### 4.2 darkroom-mode

> "Simple distraction-free editing." — [GitHub: joaotavora/darkroom](https://github.com/joaotavora/darkroom)

`darkroom-mode` (from GNU ELPA) is a simpler alternative that:
- Removes the mode-line.
- Widens margins to center text.
- Is lighter-weight than writeroom-mode.

**Emacs Lisp snippet:**

```elisp
;; darkroom is available on GNU ELPA
(use-package darkroom
  :ensure t
  :config
  ;; Toggle darkroom mode
  (global-set-key (kbd "C-c d") 'darkroom-mode)
  ;; Or toggle darkroom-tentative-mode (applies only to text modes)
  (global-set-key (kbd "C-c D") 'darkroom-tentative-mode))
```

**Source:** https://github.com/joaotavora/darkroom  
**Source:** http://elpa.gnu.org/packages/darkroom.html

---

### 4.3 olivetti

> "Olivetti — a simple Emacs minor mode for a nice writing environment." — [GitHub: rnkn/olivetti](https://github.com/rnkn/olivetti)

`olivetti` centers the text in the window by adjusting margins. It does not hide the mode-line or other UI by itself, so it pairs well with other packages.

**Emacs Lisp snippet:**

```elisp
(use-package olivetti
  :ensure t
  :config
  (setq olivetti-body-width 80)
  :hook (text-mode . olivetti-mode))
```

**Source:** https://github.com/rnkn/olivetti

---

### 4.4 focus-mode

`focus-mode` (or packages like `focus`) highlights the current sentence/paragraph and dims the rest of the text, reducing visual noise while reading or writing.

**Emacs Lisp snippet:**

```elisp
(use-package focus
  :ensure t
  :config
  ;; focus-mode highlights the current sentence/paragraph
  (global-set-key (kbd "C-c f") 'focus-mode))
```

---

### 4.5 Doom Emacs :ui zen Module

Doom Emacs has a built-in `:ui zen` module that wraps `writeroom-mode` and `mixed-pitch`.

> "This module provides two minor modes that make Emacs into a more comfortable writing or coding environment." — [Doom Emacs Docs](https://docs.doomemacs.org/v21.12/modules/ui/zen/)

**Provided commands:**
- `M-x +zen/toggle` — toggles `writeroom-mode` (restricted to current buffer).
- `M-x +zen/toggle-fullscreen` — toggles zen mode in full-screen.

**Key binding:** `SPC t z` (evil) or `C-c t z` / `M-x writeroom-mode` (non-evil).

**Source:** https://docs.doomemacs.org/v21.12/modules/ui/zen/

---

## 5. Settings to Disable Bells, Animations, Cursor Blinking, and Other Distractions

### 5.1 Disable the Audible Bell

> "The bell rings whenever function ‘ding’ is called. What the bell does depends on the value of these variables..." — [EmacsWiki: AlarmBell](https://www.emacswiki.org/emacs/AlarmBell)

**Emacs Lisp snippet:**

```elisp
;; Completely silence Emacs
(setq ring-bell-function 'ignore)
(setq visible-bell nil)

;; Or use a visible bell (flash the screen instead of sound)
(setq visible-bell t)
(setq ring-bell-function nil)
```

**Source:** https://www.emacswiki.org/emacs/AlarmBell  
**Source:** https://emacs.stackexchange.com/questions/28906/how-to-switch-off-the-sounds

---

### 5.2 Disable Cursor Blinking

A blinking cursor can be distracting and cognitively demanding.

> "Sometimes I can find a blinking cursor distracting and somewhat expectant!, so currently I am favouring a solid non blinking cursor while still being able to easily locate my cursor using hl-line-mode..." — [Emacs@Dyerdwelling](https://www.emacs.dyerdwelling.family/emacs/20230406200632-emacs--cursor-blinking-rate.html)

**Emacs Lisp snippet:**

```elisp
;; Disable cursor blinking globally
(blink-cursor-mode 0)

;; Use a solid block cursor
(setq-default cursor-type 'box)

;; Highlight the current line to help locate cursor without blinking
(global-hl-line-mode 1)

;; Set cursor color (optional, can help visibility)
(set-cursor-color "#ffaa00")
```

**Source:** https://www.gnu.org/software/emacs/manual/html_node/emacs/Cursor-Display.html  
**Source:** https://www.emacs.dyerdwelling.family/emacs/20230406200632-emacs--cursor-blinking-rate.html  
**Source:** https://jurta.org/en/prog/noblink

---

### 5.3 Disable Animations and UI Movement

```elisp
;; Disable cursor animation (pulsing cursor package, if installed)
;; If you have pulsing-cursor-mode installed:
;; (pulsing-cursor-mode 0)

;; Disable all kinds of animated UI transitions (if any packages add them)
(setq scroll-conservatively 10000)
(setq auto-window-vscroll nil)

;; Disable the toolbar, menu bar, and scroll bars for a cleaner frame
(tool-bar-mode -1)
(menu-bar-mode -1)
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'horizontal-scroll-bar-mode) (horizontal-scroll-bar-mode -1))
```

---

### 5.4 Disable Startup Screen & Messages

```elisp
;; Disable startup message
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)

;; Disable scratch buffer message
(setq initial-scratch-message nil)

;; Keep echo area / minibuffer clean
(setq echo-keystrokes 0.1)
```

---

### 5.5 Disable Fringe Indicators (Optional)

The fringe can display visual indicators (git-gutter, truncation markers) that add noise.

```elisp
;; Hide fringe bitmaps (or reduce fringe width)
(setq-default fringe-indicator-alist
              '((truncation . nil)
                (continuation . nil)
                (overlay-arrow . nil)
                (up . nil)
                (down . nil)
                (top . nil)
                (bottom . nil)
                (top-bottom . nil)
                (empty-line . nil)))

;; Or set fringe width to 0 (extreme minimalism)
;; (set-fringe-mode 0)
```

---

## 6. Transparency / Opacity Settings

### 6.1 `alpha-background` (Emacs 29+ Recommended)

Since Emacs 29 (merged January 30, 2022), the `alpha-background` frame parameter makes **only the background** transparent while keeping text fully opaque. This is far superior to the old `alpha` parameter, which made the entire window (including text) transparent.

> "The issue with `alpha` is that it sets the transparency of the *entire window*; what this means is that *text and background* become transparent together." — [Kristoffer Balintona](https://kristofferbalintona.me/posts/202206071000/)

**Emacs Lisp snippet:**

```elisp
;; Set background transparency for the current frame
(set-frame-parameter nil 'alpha-background 90)

;; Set default for all new frames
(add-to-list 'default-frame-alist '(alpha-background . 90))

;; A toggle function for background transparency
(defun kb/toggle-window-transparency ()
  "Toggle the value of `alpha-background' between 100 and 72."
  (interactive)
  (let ((transparency (pcase (frame-parameter nil 'alpha-background)
                        (72 100)
                        (100 72)
                        (t 100))))
    (set-frame-parameter nil 'alpha-background transparency)))

(global-set-key (kbd "C-c t") 'kb/toggle-window-transparency)
```

**Note:** `alpha-background` requires a compositor (e.g., Picom on Linux) and is reported to work best with cairo builds (`--with-cairo`).

**Source:** https://kristofferbalintona.me/posts/202206071000/  
**Source:** https://www.reddit.com/r/emacs/comments/v72tu6/new_emacs_frame_parameter_for/  
**Source:** https://www.emacswiki.org/emacs/TransparentEmacs

---

### 6.2 Legacy `alpha` Parameter (Whole Frame)

If using Emacs < 29 or if `alpha-background` is unavailable, the older `alpha` parameter controls the opacity of the **entire frame**.

```elisp
;; Set overall frame opacity (affects text too)
(set-frame-parameter nil 'alpha '(90 . 90))
(add-to-list 'default-frame-alist '(alpha . (90 . 90)))

;; 100 = fully opaque, 0 = fully transparent
```

**Source:** https://www.gnu.org/software/emacs/manual/html_node/elisp/Font-and-Color-Parameters.html

---

## Summary Cheat-Sheet for ADHD / Deep Focus

```elisp
;;; ============================================================
;;; ADHD / Deep Focus Configuration Cheat-Sheet
;;; ============================================================

;; --- Theme ---
(load-theme 'modus-vivendi-tinted t) ;; or 'ef-summer, 'modus-operandi-tinted

;; --- Font Lock Restraint ---
(setq font-lock-maximum-decoration 1)

;; --- Mode-Line Minimalism ---
;; Option A: Use doom-modeline with reduced segments
;; Option B: Hide mode-line entirely
;; (setq-default mode-line-format nil)

;; --- Zen Mode ---
;; Use writeroom-mode, darkroom-mode, or olivetti as needed

;; --- Silence Distractions ---
(setq ring-bell-function 'ignore)
(blink-cursor-mode 0)
(global-hl-line-mode 1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; --- Transparency (Emacs 29+) ---
(add-to-list 'default-frame-alist '(alpha-background . 92))

;; --- Clean Startup ---
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
```

---

## Source URLs

1. https://protesilaos.com/emacs/modus-themes
2. https://protesilaos.com/emacs/ef-themes
3. https://github.com/doomemacs/themes
4. https://github.com/joostkremers/writeroom-mode
5. https://github.com/joaotavora/darkroom
6. https://github.com/rnkn/olivetti
7. https://docs.doomemacs.org/v21.12/modules/ui/zen/
8. https://github.com/seagle0128/doom-modeline
9. https://www.emacswiki.org/emacs/AlarmBell
10. https://www.emacswiki.org/emacs/TransparentEmacs
11. https://kristofferbalintona.me/posts/202206071000/
12. https://www.gnu.org/software/emacs/manual/html_node/emacs/Cursor-Display.html
13. https://emacs.stackexchange.com/questions/28906/how-to-switch-off-the-sounds
14. https://www.reddit.com/r/emacs/comments/s30esp/absolute_minimum_modeline/
15. https://www.reddit.com/r/emacs/comments/1bgp3h0/beginner_setting_up_doommodeline/
