# Emacs UI Parameters for Web Browsing, Media, Research, and Annotations
## Tailored for ADHD and Deep Focus

> **Research Date:** 2026-05-03  
> **Sources:** GNU Emacs Manual, Emacs Stack Exchange, Reddit r/emacs, Karthik Chikmagalur (karthinks.com), Protesilaos Stavrou, Kristoffer Balintona, and various package repositories.

---

## 1. Web Browsing Inside Emacs (EWW / SHR)

### 1.1 Readability & Distraction Reduction

EWW (Emacs Web Wowser) uses `shr.el` for HTML rendering. For ADHD-friendly reading, the key is reducing visual noise and enforcing a clean text layout.

**Key Settings:**

```elisp
;; Use EWW as the default browser for URLs opened in Emacs
(setq browse-url-browser-function 'eww-browse-url)

;; Auto-enable readable mode (strips sidebars/ads) when possible
(setq eww-auto-rename-buffer "title")   ; name buffers by page title

;; Block images by default to reduce visual clutter
(setq shr-inhibit-images t)

;; Use proportional fonts for HTML text (easier reading)
(setq shr-use-fonts t)

;; Maximum image width so images never overflow
(setq shr-max-image-proportion 0.3)

;; Discard alt text placeholders for images (less noise)
(setq shr-image-animate nil)

;; Cookie handling: disable sending/receiving to avoid tracking
(setq url-cookie-trusted-urls nil)
(setq url-cookie-untrusted-urls '(".*"))

;; eww-readable-mode: strip page to essential content
;; Bound to R in eww-mode by default; enable automatically:
(add-hook 'eww-after-render-hook
          (lambda () (eww-readable-mode)))
```

**Source:**
- GNU Emacs Manual — EWW Advanced: https://www.gnu.org/software/emacs/manual/html_node/eww/Advanced.html
- EmacsWiki — eww: https://www.emacswiki.org/emacs/eww
- Emacs Stack Exchange — "How to open eww in readable mode?": https://emacs.stackexchange.com/questions/36284/how-to-open-eww-in-readable-mode

### 1.2 eww-readable-mode

`eww-readable-mode` (bound to `R` in `eww-mode`) removes sidebars, headers, and ads, leaving only the article text. This is the single most impactful ADHD tweak for web reading in Emacs.

```elisp
;; Always enter readable mode after page load
(defun my/eww-auto-readable ()
  "Enable readable mode in EWW if it looks like an article."
  (when (and (derived-mode-p 'eww-mode)
             (not (bound-and-true-p eww-readable-mode)))
    (eww-readable-mode)))

(add-hook 'eww-after-render-hook #'my/eww-auto-readable)
```

### 1.3 Image Blocking & Network Restraint

For ADHD, images are often attention magnets. Blocking them entirely or limiting their display is critical.

```elisp
;; Completely prevent shr from making external image requests
(setq shr-inhibit-images t)

;; If you sometimes want images, toggle with a command:
(defun my/shr-toggle-images ()
  "Toggle image display in SHR-based modes (eww, mu4e, etc.)."
  (interactive)
  (setq-local shr-inhibit-images (not shr-inhibit-images))
  (message "Images: %s" (if shr-inhibit-images "BLOCKED" "allowed"))
  (when (derived-mode-p 'eww-mode)
    (eww-reload)))

;; Keep page width narrow for reading (apply olivetti or visual-fill-column)
(add-hook 'eww-mode-hook #'olivetti-mode)
```

**Source:**
- Emacs Stack Exchange — "How to prevent shr from making network connections": https://emacs.stackexchange.com/questions/3553/how-to-prevent-shr-from-making-network-connections
- Emacs Stack Exchange — "How can I toggle displaying images in eww without a page refresh?": https://emacs.stackexchange.com/questions/561/how-can-i-toggle-displaying-images-in-eww-without-a-page-refresh

### 1.4 Font Settings for HTML Rendering

`shr-use-fonts` enables proportional font rendering, which is easier on the eyes for long-form reading.

```elisp
(setq shr-use-fonts t)            ; Use variable-pitch faces
(setq shr-use-colors nil)         ; Ignore page CSS colors; use Emacs theme
(setq shr-width 80)               ; Wrap text to 80 columns
(setq shr-hr-line "\n---\n")      ; Simpler horizontal rules
```

---

## 2. PDF Reading with pdf-tools

### 2.1 Dark / Midnight Mode

`pdf-tools` provides a "midnight mode" that inverts colors, producing light text on a dark background. This is essential for long reading sessions and reduces eye strain.

```elisp
;; Enable midnight mode automatically for all PDFs
(add-hook 'pdf-view-mode-hook #'pdf-view-midnight-minor-mode)

;; Customize midnight colors to fit your theme
(setq pdf-view-midnight-colors '("#c8c8c8" . "#1a1a1a"))
;;            ^ foreground      ^ background

;; Alternative: pdf-view-dark-minor-mode (uses Emacs theme colors)
;; (add-hook 'pdf-view-mode-hook #'pdf-view-dark-minor-mode)
```

**Source:**
- Reddit — "View PDF in dark mode with pdf-tools": https://www.reddit.com/r/emacs/comments/opkzxm/view_pdf_in_dark_mode_with_pdf/
- GitHub — vedang/pdf-tools: https://github.com/vedang/pdf-tools

### 2.2 Fit Settings & Window Sizing

```elisp
;; Fit the PDF width to the window on open
(setq-default pdf-view-display-size 'fit-width)

;; Or fit entire page to window
;; (setq-default pdf-view-display-size 'fit-page)

;; Auto-revert PDFs when file changes on disk
(add-hook 'pdf-view-mode-hook #'auto-revert-mode)
```

### 2.3 Continuous Scroll

`pdf-tools` jumps discretely from page to page, which can break reading flow. The third-party package `pdf-continuous-scroll-mode` adds smooth scrolling.

```elisp
;; Install via quelpa/straight or Doom's :tools pdf module
(use-package pdf-continuous-scroll-mode
  :after pdf-tools
  :config
  (add-hook 'pdf-view-mode-hook #'pdf-continuous-scroll-mode))
```

**Source:**
- GitHub — dalanicolai/pdf-continuous-scroll-mode.el: https://github.com/dalanicolai/pdf-continuous-scroll-mode.el
- Reddit — "Improved continuous scroll for pdf-tools": https://www.reddit.com/r/emacs/comments/skcny0/improved_continuous_scroll_for/

### 2.4 Annotation Highlight Colors

`pdf-tools` supports annotations with customizable colors. For ADHD, using distinct, calming colors helps separate types of notes.

```elisp
;; Annotation color palette (ADHD-friendly: calm, distinguishable)
(setq pdf-annot-default-markup-annotation-properties
      '((color . "#f1fa8c")              ; Yellow highlight
        (opacity . 0.4)))

;; Define quick color toggles for different note types
(defun my/pdf-annot-set-color-yellow () (interactive) (pdf-annot-set-color "#f1fa8c"))
(defun my/pdf-annot-set-color-blue ()   (interactive) (pdf-annot-set-color "#8be9fd"))
(defun my/pdf-annot-set-color-green ()  (interactive) (pdf-annot-set-color "#50fa7b"))
(defun my/pdf-annot-set-color-pink ()   (interactive) (pdf-annot-set-color "#ff79c6"))
```

### 2.5 Hide Empty Margins (Small Screens)

For ADHD, visual clutter like large white margins can be distracting.

```elisp
;; Crop empty margins automatically (requires pdf-tools)
(add-hook 'pdf-view-mode-hook #'pdf-view-auto-slice-minor-mode)
```

---

## 3. Video Handling & Image Display Restraint

### 3.1 No Native Video in Emacs

Emacs does not natively play video. Options:
- Open external links with `browse-url` (e.g., `mpv`, `vlc`).
- Use `emms` (Emacs Multimedia System) for audio, but video support is limited.
- For research: avoid embedding video inside Emacs; open externally to prevent task-switching and loss of focus.

```elisp
;; Open media links externally rather than inside Emacs
(setq browse-url-handlers
      '(("\\.\\(mp4\\|webm\\|mkv\\|avi\\)\\'" . browse-url-default-browser)))
```

### 3.2 Image Display Restraint

```elisp
;; Do not show images inline in eww/mu4e by default
(setq shr-inhibit-images t)

;; In Gnus / mu4e, you can also use:
(setq mm-inline-large-images 'resize)
(setq mm-inline-max-width 400)
(setq mm-inline-max-height 300)

;; image-mode: open images in a dedicated frame or avoid auto-display
(add-hook 'image-mode-hook
          (lambda () (message "Image loaded. Press q to close.")))
```

---

## 4. Annotation Workflows

### 4.1 org-noter: Synchronized PDF + Org Notes

`org-noter` creates a side-by-side layout: PDF on one side, Org notes on the other. Notes are synchronized to the document location.

```elisp
(use-package org-noter
  :after (org pdf-tools)
  :config
  ;; Default notes file location
  (setq org-noter-notes-search-path '("~/org/research/"))

  ;; Auto-synchronize notes with document location
  (setq org-noter-auto-save-last-location t)

  ;; Set a default title for notes
  (setq org-noter-default-heading-title "Note")

  ;; Hide other windows to reduce clutter when starting org-noter
  (setq org-noter-always-create-frame nil)

  ;; Highlight the relevant PDF region when selecting a note
  (setq org-noter-highlight-selected-region t)

  ;; Use a vertical split (PDF left, notes right)
  (setq org-noter-notes-window-location 'horizontal))
```

**Source:**
- GitHub — weirdNox/org-noter: https://github.com/weirdNox/org-noter
- Reddit — "Org-noter - A synchronized, Org-mode, document annotator": https://www.reddit.com/r/emacs/comments/7tvz89/orgnoter_a_synchronized_orgmod/

### 4.2 citar + marginalia: Fast Bibliography Navigation

`citar` (formerly `bibtex-actions`) provides a fast, completion-based interface to bibliography entries, with `marginalia` showing extra context.

```elisp
(use-package citar
  :custom
  (org-cite-global-bibliography '("~/org/references.bib"))
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  :hook
  (org-mode . citar-capf-setup)
  :bind
  (:map org-mode-map
        ("C-c b" . citar-insert-citation)
        ("C-c B" . citar-open)))

;; Enable marginalia for richer annotations in minibuffer
(use-package marginalia
  :config
  (marginalia-mode))
```

**Source:**
- GitHub — emacs-citar/citar: https://github.com/emacs-citar/citar
- Kristoffer Balintona — "Citations in org-mode: Org-cite and Citar": https://kristofferbalintona.me/posts/202206141852/

### 4.3 bibtex-completion

`bibtex-completion` is the backend used by `citar` / `helm-bibtex` / `ivy-bibtex`. It manages PDFs and notes associated with entries.

```elisp
(setq bibtex-completion-bibliography '("~/org/references.bib"))
(setq bibtex-completion-library-path '("~/org/papers/"))
(setq bibtex-completion-notes-path "~/org/research/")
(setq bibtex-completion-pdf-field "file")
```

### 4.4 org-pdftools

`org-pdftools` links allow jumping directly from an Org link to a specific PDF page/location.

```elisp
(use-package org-pdftools
  :hook (org-mode . org-pdftools-setup-link))

;; Example Org link syntax after setup:
;; [[pdf:~/papers/example.pdf::2][Open page 2]]
```

---

## 5. Research Sidebar and Window Management

### 5.1 winner-mode: Undo Window Layouts

For ADHD, accidentally destroying a carefully-arranged research layout is frustrating. `winner-mode` lets you undo/redo window configurations with `C-c <left>` / `C-c <right>`.

```elisp
(winner-mode 1)   ; Enable globally

;; Key bindings (default):
;; C-c <left>  — undo last window change
;; C-c <right> — redo window change
```

**Source:**
- Karthik Chikmagalur — "The Emacs Window Management Almanac": https://karthinks.com/software/emacs-window-management-almanac/

### 5.2 popper: Tame Popups

`popper` turns temporary buffers (help, compile, messages) into summonable/dismissable popups. This prevents random popups from destroying your reading layout.

```elisp
(use-package popper
  :config
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "\\*Help\\*"
          "\\*Compile-Log\\*"
          help-mode
          compilation-mode))
  (popper-mode 1)
  (popper-echo-mode 1))   ; Show popup indicator in echo area

;; Key bindings:
;; C-`   — toggle latest popup
;; M-`   — cycle popups
```

**Source:**
- GitHub — karthink/popper: https://github.com/karthink/popper
- GNU ELPA — popper: https://elpa.gnu.org/packages/popper.html

### 5.3 shackle: Enforce Popup Rules

`shackle` declaratively controls where popups appear. It complements `popper` or can be used standalone.

```elisp
(use-package shackle
  :config
  (setq shackle-rules
        '(("\\*Help\\*" :popup t :align right :size 0.4)
          ("\\*Compile-Log\\*" :popup t :align bottom :size 0.2)
          ("\\*eww\\*" :same t)               ; Don't popup EWW
          ("\\*PDF\\*" :same t)))               ; Keep PDF in current window
  (shackle-mode 1))
```

**Source:**
- shackle documentation: https://depp.brause.cc/shackle/
- Reddit — "Shackle rules for multiple popups": https://www.reddit.com/r/emacs/comments/o15wrl/shackle_rules_for_multiple_pop/

### 5.4 display-buffer-alist (Built-in Alternative)

If you prefer no third-party packages, Emacs' built-in `display-buffer-alist` gives full control.

```elisp
(add-to-list 'display-buffer-alist
             '("\\*Help\\*"
               (display-buffer-in-side-window)
               (side . right)
               (window-width . 0.4)))
```

---

## 6. Distraction Reduction for Reading

### 6.1 olivetti: Centered Text Width

`olivetti` narrows the buffer to a comfortable reading width, centering it on screen. This reduces eye movement and visual fatigue.

```elisp
(use-package olivetti
  :config
  (setq olivetti-body-width 0.65)         ; 65% of window width
  (setq olivetti-minimum-body-width 72)
  (setq olivetti-recall-visual-line-mode-entry-state t)
  :hook ((text-mode . olivetti-mode)
         (eww-mode . olivetti-mode)
         (pdf-view-mode . olivetti-mode)))
```

**Source:**
- Protesilaos Stavrou — "Focused editing tools for Emacs": https://protesilaos.com/codelog/2020-07-16-emacs-focused-editing/
- Phil Newton — "Distraction free writing with Emacs": https://www.philnewton.net/blog/distraction-free-writing-with-emacs/

### 6.2 darkroom-mode / writeroom-mode: Full Distraction-Free

`writeroom-mode` is the most complete distraction-free package: it hides the modeline, fringes, menu bar, and centers text. `darkroom` is a simpler built-in alternative.

```elisp
;; Option A: writeroom-mode (more features, third-party)
(use-package writeroom-mode
  :config
  (setq writeroom-width 80)
  (setq writeroom-mode-line t)   ; nil to hide modeline
  (setq writeroom-fullscreen-effect 'maximized)
  :bind ("C-c z" . writeroom-mode))

;; Option B: darkroom (simpler, on GNU ELPA)
(use-package darkroom
  :config
  (setq darkroom-margins 0.15)   ; 15% margins on each side
  :bind ("C-c d" . darkroom-mode))
```

**Source:**
- GitHub — joostkremers/writeroom-mode: https://github.com/joostkremers/writeroom-mode
- GitHub — joaotavora/darkroom: https://github.com/joaotavora/darkroom
- GNU ELPA — darkroom: http://elpa.gnu.org/packages/darkroom.html

### 6.3 Combining Modes for Deep Focus

For a "deep focus" reading session (ADHD-optimized), combine multiple toggles:

```elisp
(defun my/deep-focus-reading ()
  "Enable all distraction-reduction modes for reading."
  (interactive)
  (writeroom-mode 1)
  (olivetti-mode 1)
  (unless (derived-mode-p 'prog-mode)
    (setq-local mode-line-format nil))
  (set-window-fringes (selected-window) 0 0)
  (message "Deep focus ON"))

(defun my/deep-focus-off ()
  "Restore normal editing UI."
  (interactive)
  (writeroom-mode -1)
  (olivetti-mode -1)
  (kill-local-variable 'mode-line-format)
  (set-window-fringes (selected-window) nil nil)
  (message "Deep focus OFF"))
```

### 6.4 Global UI Cleanup

Hide decorative UI elements globally to reduce visual clutter:

```elisp
;; Hide menu bar, tool bar, scroll bars
(when (fboundp 'menu-bar-mode)   (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode)   (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; Disable audible bell; use visual flash instead
(setq visible-bell t)
(setq ring-bell-function 'ignore)
```

---

## Summary Table: ADHD-Optimized Emacs Research UI

| Concern                  | Primary Tool          | Key Variable / Mode                        |
|--------------------------|----------------------|--------------------------------------------|
| Web readability          | `eww-readable-mode`  | `eww-after-render-hook`                    |
| Web image blocking       | `shr-inhibit-images` | `t`                                        |
| PDF dark mode            | `pdf-tools`          | `pdf-view-midnight-minor-mode`             |
| PDF continuous scroll    | `pdf-continuous-scroll-mode` | `pdf-continuous-scroll-mode`         |
| PDF fit settings         | `pdf-tools`          | `pdf-view-display-size`                    |
| PDF annotations          | `pdf-tools`          | `pdf-annot-default-markup-annotation-properties` |
| Video handling           | External players     | `browse-url-handlers`                      |
| Note sync with PDF       | `org-noter`          | `org-noter-notes-window-location`          |
| Bibliography completion  | `citar` + `marginalia` | `org-cite-insert-processor`              |
| Window undo              | `winner-mode`        | `winner-mode`                              |
| Popup control            | `popper` / `shackle` | `popper-reference-buffers`                 |
| Reading width control    | `olivetti`           | `olivetti-body-width`                      |
| Full distraction-free    | `writeroom-mode`     | `writeroom-mode`                           |
| UI element cleanup       | Built-in             | `menu-bar-mode`, `tool-bar-mode`           |

---

## Follow-up Actions

1. **Test `pdf-continuous-scroll-mode`** — Installation can be tricky on some systems (see Emacs Stack Exchange thread for quelpa issues).
2. **Tune midnight colors** — Depending on your theme (e.g., Modus, Doom Nord), adjust `pdf-view-midnight-colors` to avoid clashing.
3. **Integrate `org-noter` with `org-roam-bibtex`** if using Zotero + org-roam for a full knowledge pipeline.
4. **Evaluate `popper` vs. Doom's built-in `:ui popup`** if you are a Doom Emacs user, to avoid redundancy.
