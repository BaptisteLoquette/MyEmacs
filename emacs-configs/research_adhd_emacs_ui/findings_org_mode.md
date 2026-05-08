# Research: Ultimate Emacs UI Parameters for Org Mode & Org Tables — ADHD & Deep Focus

> **Scope:** Visual packages, typography, table alignment, narrowing/focus commands, agenda/todo visualization, and image/LaTeX preview settings.  
> **Sources:** Protesilaos Stavrou, Lucid Manager / Emacs Writing Studio, Sophie Bosio, GNU ELPA org-modern, Karthink (org-latex-preview), Hugo Cisneros, zzamboni.org, Org mode manual, Reddit r/emacs & r/orgmode, Emacs StackExchange.  
> **Date researched:** 2026-05-03

---

## 1. Visual Packages: org-modern, org-superstar, org-bullets, org-indent

### org-modern (recommended as the modern all-in-one replacement)
- **Source:** [GNU ELPA — org-modern](https://elpa.gnu.org/packages/org-modern.html) | [GitHub minad/org-modern](https://github.com/minad/org-modern)
- **Key fact:** `org-modern` is a full replacement for both `org-superstar` and `org-bullets`. It styles headlines, keywords, tables, source blocks, timestamps, and tags using **text properties** (considered more future-proof than character composition).
- **ADHD / focus angle:** Reduces visual clutter by replacing noisy markup with subtle styling while keeping text editable.

**Minimal activation snippet:**
```elisp
(add-hook 'org-mode-hook #'org-modern-mode)
(add-hook 'org-agenda-finalize-hook #'org-modern-agenda)
;; Or globally:
(with-eval-after-load 'org (global-org-modern-mode))
```

**Focus-friendly org-modern customization (from ELPA docs):**
```elisp
(setq
 org-auto-align-tags nil
 org-tags-column 0
 org-catch-invisible-edits 'show-and-error
 org-special-ctrl-a/e t
 org-insert-heading-respect-content t
 org-hide-emphasis-markers t
 org-pretty-entities t
 org-agenda-tags-column 0
 org-ellipsis "…")
```

**Selective disabling for ADHD users** (from [Lucid Manager](https://lucidmanager.org/productivity/ricing-org-mode/)):
> "Hiding indicators is not always a good idea." — Peter Prevos
```elisp
(use-package org-modern
  :hook (org-mode . global-org-modern-mode)
  :custom
  (org-modern-keyword nil)
  (org-modern-checkbox nil)
  (org-modern-table nil))
```

### org-superstar (legacy but still widely used)
- **Source:** [GitHub integral-dw/org-superstar-mode](https://github.com/integral-dw/org-superstar-mode) | [Protesilaos — tweaked focused writing](https://protesilaos.com/codelog/2020-07-18-emacs-concept-org-tweaked-focus/)
- **Key fact:** Supersedes `org-bullets`. Can remove leading stars and replace bullets with custom characters.
- **ADHD tip:** Hiding leading stars dramatically reduces visual noise.

**Protesilaos’ focused-writing config:**
```elisp
(use-package org-superstar
  :ensure
  :after org
  :config
  (setq org-superstar-remove-leading-stars t)
  (setq org-superstar-headline-bullets-list '(" ")) ;; empty for minimalism
  (setq org-superstar-item-bullet-alist
        '((?+ . ?•)
          (?* . ?➤)
          (?- . ?–)))
  (org-superstar-mode -1)) ;; toggled on only during focus mode
```

**Sophie Bosio’s more decorative variant** ([source](https://sophiebos.io/posts/prettifying-emacs-org-mode/)):
```elisp
(use-package org-superstar
  :config
  (setq org-superstar-leading-bullet " ")
  (setq org-superstar-headline-bullets-list '("◉" "○" "⚬" "◈" "◇"))
  (setq org-superstar-special-todo-items t)
  (setq org-superstar-todo-bullet-alist
        '(("TODO" . 9744)
          ("WAIT" . 9744)
          ("READ" . 9744)
          ("PROG" . 9744)
          ("DONE" . 9745)))
  :hook (org-mode . org-superstar-mode))
```

### org-indent
- **Source:** [Lucid Manager](https://lucidmanager.org/productivity/ricing-org-mode/)
- **Key fact:** `org-startup-indented` aligns text under headings and removes leading stars for a clean hierarchical view.
```elisp
(setq-default org-startup-indented t)
```
- **Caveat:** If `org-indent-mode` is enabled, `org-modern` disables its block prettification in the fringe. Use [org-modern-indent](https://github.com/jdtsmith/org-modern-indent) as an alternative block-styling mechanism.

---

## 2. Typography Within Org: Variable-Pitch vs Monospace & Heading Scaling

### Mixed-font philosophy
- **Source:** [Protesilaos — configuring mixed fonts in Org mode](https://protesilaos.com/codelog/2020-07-17-emacs-mixed-fonts-org/) | [zzamboni.org](https://zzamboni.org/post/beautifying-org-mode-in-emacs/)
- **Key quote:**
> "The idea is to use this for `org-mode` so that you can have some text use a monospaced font to keep its alignment properties intact, while the rest of the buffer switched to a proportionately-spaced font that is more natural to read for large portions of text." — Protesilaos

**Core face setup (Protesilaos):**
```elisp
(set-face-attribute 'default nil :font "Hack-16")
(set-face-attribute 'fixed-pitch nil :font "Hack-16")
(set-face-attribute 'variable-pitch nil :font "FiraGO-18")
```

**Critical theme requirement:**
> "Your theme must have configured everything properly… all indentation or spacing-sensitive faces are designed to always inherit from `fixed-pitch`." — Protesilaos

**Faces that MUST inherit `fixed-pitch` for mixed fonts to work:**
- `org-block`
- `org-block-begin-line`
- `org-block-end-line`
- `org-code`
- `org-document-info-keyword`
- `org-meta-line`
- `org-table`
- `org-verbatim`

### Variable-pitch for prose, fixed-pitch for tables/code
- **Source:** [Sophie Bosio](https://sophiebos.io/posts/prettifying-emacs-org-mode/) | [Hugo Cisneros](https://hugocisneros.com/org-config/)

**Sophie Bosio’s approach:**
```elisp
(when (member "Roboto Mono" (font-family-list))
  (set-face-attribute 'default nil :font "Roboto Mono" :height 108)
  (set-face-attribute 'fixed-pitch nil :family "Roboto Mono"))
(when (member "Source Sans Pro" (font-family-list))
  (set-face-attribute 'variable-pitch nil :family "Source Sans Pro" :height 1.18))

;; Resize Org headings
(dolist (face '((org-level-1 . 1.35)
                (org-level-2 . 1.3)
                (org-level-3 . 1.2)
                (org-level-4 . 1.1)
                (org-level-5 . 1.1)
                (org-level-6 . 1.1)
                (org-level-7 . 1.1)
                (org-level-8 . 1.1)))
  (set-face-attribute (car face) nil :font "Source Sans Pro" :weight 'bold :height (cdr face)))

;; Make document title bigger
(set-face-attribute 'org-document-title nil :font "Source Sans Pro" :weight 'bold :height 1.8)

;; Keep spacing-sensitive faces fixed-pitch
(set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch :height 0.85)
(set-face-attribute 'org-code nil :inherit '(shadow fixed-pitch) :height 0.85)
(set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch) :height 0.85)
(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch) :height 0.85)
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

;; Always use variable-pitch in Org buffers
(add-hook 'org-mode-hook 'variable-pitch-mode)
```

**Hugo Cisneros’ proportional-width hook (ADHD-friendly):**
```elisp
(defun my/buffer-face-mode-variable ()
  "Set font to a variable width (proportional) fonts in current buffer"
  (interactive)
  (setq buffer-face-mode-face '(:family "Roboto Slab"
                                :height 150
                                :width normal))
  (buffer-face-mode))

(defun my/set-general-faces-org ()
  (my/buffer-face-mode-variable)
  (setq line-spacing 0.1
        org-pretty-entities t
        org-startup-indented t
        org-adapt-indentation nil)
  (variable-pitch-mode +1)
  (mapc
   (lambda (face)
     (set-face-attribute face nil :inherit 'fixed-pitch))
   (list 'org-block
         'org-table
         'org-verbatim
         'org-block-begin-line
         'org-block-end-line
         'org-meta-line
         'org-date
         'org-drawer
         'org-property-value
         'org-special-keyword
         'org-document-info-keyword))
  (mapc
   (lambda (face)
     (set-face-attribute face nil :height 0.8))
   (list 'org-document-info-keyword
         'org-block-begin-line
         'org-block-end-line
         'org-meta-line
         'org-drawer
         'org-property-value)))
```

### Line spacing for readability
- **Source:** [Lucid Manager](https://lucidmanager.org/productivity/ricing-org-mode/)
```elisp
;; Increase line spacing (pixels or scaling factor)
(setq-default line-spacing 2)   ;; 2 pixels extra
;; OR for a softer look:
(setq-default line-spacing 0.1) ;; scaling factor
```

---

## 3. Org Table Alignment, Fontification, and Border Settings

### Table fontification basics
- **Source:** [Protesilaos — mixed fonts](https://protesilaos.com/codelog/2020-07-17-emacs-mixed-fonts-org/)
- **Key fact:** `org-table` must inherit from `fixed-pitch` or tables will misalign when `variable-pitch-mode` is active.
```elisp
(set-face-attribute 'org-table nil :inherit 'fixed-pitch)
```

### org-modern table styling
- **Source:** [GNU ELPA org-modern](https://elpa.gnu.org/packages/org-modern.html)
- `org-modern-table` prettifies table borders and dividers. For ADHD users who find borders distracting, **disable it**:
```elisp
(setq org-modern-table nil)
```

### org-modern block styling caveat with org-indent
- If `org-indent-mode` is enabled, `org-modern` disables fringe-based block prettification. Alternative: [org-modern-indent](https://github.com/jdtsmith/org-modern-indent).

### Table alignment in mixed-font buffers
- **Source:** [StackOverflow — variable-pitch for org-mode, fixed-pitch for tables](https://stackoverflow.com/questions/3758139/variable-pitch-for-org-mode-fixed-pitch-for-tables)
- **Key fact:** Emacs’ `variable-pitch-mode` applies variable pitch to all faces that don’t explicitly specify a font. To keep tables aligned, ensure `org-table` explicitly inherits `fixed-pitch`.

---

## 4. Narrowing and Focus Commands (Deep Work)

### org-narrow-to-subtree
- **Built-in command:** `C-x n s` (`org-narrow-to-subtree`) — narrows buffer to current heading.
- **Widen:** `C-x n w` (`widen`)

### Indirect buffers for side-by-side focus
- **Source:** [Emacs StackExchange — org-tree-to-indirect-buffer](https://emacs.stackexchange.com/questions/66653/how-to-use-org-tree-to-indirect-buffer-and-turn-off-org-indent-mode-in-the-new-indirect-buffer-with-a-toggle-to-go-back-all-in-a-single-key-binding) | [Steven Brown blog](https://www.stevenbrown.ca/blog/archives/2130)
- **Key fact:** Indirect buffers let you edit a subtree in isolation while preserving the original file structure.

**Critical setting for ADHD workflow:**
```elisp
(setq org-indirect-buffer-display 'new-frame) ;; or 'current-window / 'other-window
```

**Toggle function (from Emacs StackExchange):**
```elisp
(defun my/org-focus-toggle ()
  "Narrow to subtree in an indirect buffer for distraction-free editing."
  (interactive)
  (if (buffer-base-buffer)
      (kill-buffer)
    (org-tree-to-indirect-buffer)
    (org-indent-mode -1)))
```

### org-tree-to-indirect-buffer with narrowing
- **Source:** [Emacs StackExchange — narrow to current subtree instead of new frame](https://emacs.stackexchange.com/questions/70791/how-to-let-org-tree-to-indirect-buffer-narrow-to-the-current-subtree)
- The default opens a new frame; to keep it in the same window, customize display actions or use `org-narrow-to-subtree` instead.

### 2-pane writing setup
- **Source:** [Emacs StackExchange — Org-mode 2-pane writing setup](https://emacs.stackexchange.com/questions/47246/org-mode-2-pane-writing-setup-using-indirect-buffers)
- Useful for ADHD users who want an outline in one pane and the focused section in another.

### Reddit ADHD-specific tip
- **Source:** [r/orgmode — Focus on Single Org SubTree](https://www.reddit.com/r/orgmode/comments/gm3g46/focus_on_single_org_subtree/)
- Users with large notes.org files recommend `org-tree-to-indirect-buffer` as the primary focus mechanism.

---

## 5. Agenda and Todo Visualization Tweaks (Colors, Habits, Log View)

### org-habit for ADHD-friendly routine tracking
- **Source:** [Org Manual — Tracking your habits](https://orgmode.org/manual/Tracking-your-habits.html) | [Worg tutorial](https://orgmode.org/worg/org-tutorials/tracking-habits.html)
- **Key fact:** `org-habit` provides a visual consistency graph for recurring tasks. To use it, add `habit` to `org-modules`.

```elisp
(add-to-list 'org-modules 'org-habit)
```

**Habit graph color meaning (from [Emacs StackExchange](https://emacs.stackexchange.com/questions/59529/how-shall-i-understand-org-mode-habits-graph-colors)):**
- **Blue:** Task was not to be done yet on that day.
- **Green:** Task could have been done on that day.
- **Yellow:** Task was to be done that day but wasn’t.
- **Red:** Task missed that day.

**Habit setup example (from Worg):**
```elisp
** TODO Exercise
   SCHEDULED: <2009-01-22 Thu +1d>
   :PROPERTIES:
   :STYLE: habit
   :END:
```

### Custom agenda view for habits (from Worg)
```elisp
(setq org-agenda-custom-commands
      '(("h" "Daily habits"
         ((agenda ""))
         ((org-agenda-show-log t)
          (org-agenda-ndays 7)
          (org-agenda-log-mode-items '(state))
          (org-agenda-skip-function '(org-agenda-skip-entry-if 'notregexp ":DAILY:"))))))
```

### Todo keyword faces & colors
- **Source:** [Hugo Cisneros](https://hugocisneros.com/org-config/) | [Sophie Bosio](https://sophiebos.io/posts/prettifying-emacs-org-mode/)

**Hugo Cisneros’ keyword setup:**
```elisp
(setq org-todo-keywords
    (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
            (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)"))))

(setq org-todo-keyword-faces
    (quote (("TODO" :foreground "red" :weight bold)
            ("NEXT" :foreground "blue" :weight bold)
            ("DONE" :foreground "forest green" :weight bold)
            ("WAITING" :foreground "orange" :weight bold)
            ("HOLD" :foreground "magenta" :weight bold)
            ("CANCELLED" :foreground "forest green" :weight bold))))
```

**Sophie Bosio’s priority colors (Nord palette):**
```elisp
(setq org-lowest-priority ?F)
(setq org-default-priority ?E)
(setq org-priority-faces
      '((65 . "#BF616A")  ;; A
        (66 . "#EBCB8B")  ;; B
        (67 . "#B48EAD")  ;; C
        (68 . "#81A1C1")  ;; D
        (69 . "#5E81AC")  ;; E
        (70 . "#4C566A"))) ;; F
```

### Agenda style for reduced clutter
- **Source:** [Hugo Cisneros](https://hugocisneros.com/org-config/)
```elisp
(setq org-agenda-tags-column 0)
(setq org-agenda-prefix-format '((agenda . "  %?-12t% s")))
```

### Logging & state tracking
- **Source:** [Worg — Tracking Habits](https://orgmode.org/worg/org-tutorials/tracking-habits.html)
```elisp
(setq org-log-done 'time)       ;; or 'note for more detail
(setq org-log-repeat 'time)
```

---

## 6. Images and LaTeX Previews — Avoiding Visual Overload

### Inline images
- **Source:** [Lucid Manager](https://lucidmanager.org/productivity/ricing-org-mode/)
- **Key fact:** `org-startup-with-inline-images` auto-shows images on open. For ADHD users, this can be overwhelming.

**Restrict image width to prevent overwhelm:**
```elisp
(setq-default org-startup-with-inline-images t)
(setq org-image-actual-width '(300)) ;; cap at 300px; allows #+attr_org: :width override
```

**To completely disable inline images at startup:**
```elisp
(setq-default org-startup-with-inline-images nil)
```

### LaTeX previews
- **Source:** [Karthink — org-latex-preview setup](https://abode.karthinks.com/org-latex-preview/) | [Org Manual](https://orgmode.org/manual/Previewing-LaTeX-fragments.html) | [Lucid Manager](https://lucidmanager.org/productivity/ricing-org-mode/)

**Default scale adjustment (prevents tiny, hard-to-read previews):**
```elisp
(plist-put org-format-latex-options :scale 2)
;; Or for the new org-latex-preview system:
(plist-put org-latex-preview-appearance-options :scale 2.0)
```

**Auto-foreground/background to match theme (Lucid Manager):**
```elisp
(plist-put org-format-latex-options :foreground 'auto)
(plist-put org-format-latex-options :background 'auto)
```

**Disable startup LaTeX previews to avoid load-time visual overload:**
```elisp
(setq org-startup-with-latex-preview nil)
```

**org-fragtog for on-demand toggling (Lucid Manager):**
> "The package is loaded after the Org package has loaded… toggles between the source and the preview of the formulas, which means you don’t have to use the `org-latex-preview` function repeatedly."

```elisp
(use-package org-fragtog
  :after org
  :hook (org-mode . org-fragtog-mode)
  :custom
  (org-startup-with-latex-preview nil)
  (org-format-latex-options
   (plist-put org-format-latex-options :scale 2)
   (plist-put org-format-latex-options :foreground 'auto)
   (plist-put org-format-latex-options :background 'auto)))
```

**New `org-latex-preview` system (Karthink) — sample config:**
```elisp
(use-package org-latex-preview
  :config
  (plist-put org-latex-preview-appearance-options :page-width 0.8)
  ;; Turn on org-latex-preview-mode (built-in, faster than org-fragtog)
  (add-hook 'org-mode-hook 'org-latex-preview-mode)
  ;; Live previews (can be distracting — disable for strict focus)
  (setq org-latex-preview-mode-display-live t)
  (setq org-latex-preview-mode-update-delay 0.25))
```

> **ADHD recommendation:** Keep `org-startup-with-latex-preview` **nil** and toggle previews manually (`C-c C-x C-l`) or via `org-fragtog-mode` / `org-latex-preview-mode` only when needed.

---

## 7. Bonus: Distraction-Free Writing Environment (Olivetti)

- **Source:** [Protesilaos](https://protesilaos.com/codelog/2020-07-18-emacs-concept-org-tweaked-focus/) | [Lucid Manager](https://lucidmanager.org/productivity/ricing-org-mode/)

**Olivetti setup for deep focus:**
```elisp
(use-package olivetti
  :config
  (setq olivetti-body-width 0.65)
  (setq olivetti-minimum-body-width 72)
  (setq olivetti-recall-visual-line-mode-entry-state t))

;; Protesilaos’ custom focused-writing minor mode
(define-minor-mode prot/olivetti-mode
  "Toggle buffer-local `olivetti-mode' with additional parameters."
  :init-value nil
  :global nil
  (if prot/olivetti-mode
      (progn
        (olivetti-mode 1)
        (set-window-fringes (selected-window) 0 0)
        (prot/variable-pitch-mode 1)
        (prot/cursor-type-mode 1)
        (unless (derived-mode-p 'prog-mode)
          (prot/hidden-mode-line-mode 1))
        (window-divider-mode 1)
        (when (eq major-mode 'org-mode)
          (org-superstar-mode 1)))
    (olivetti-mode -1)
    (set-window-fringes (selected-window) nil nil)
    (prot/variable-pitch-mode -1)
    (prot/cursor-type-mode -1)
    (unless (derived-mode-p 'prog-mode)
      (prot/hidden-mode-line-mode -1))
    (window-divider-mode -1)
    (when (eq major-mode 'org-mode)
      (org-superstar-mode -1))))
```

**Lucid Manager’s simpler distraction-free toggle:**
```elisp
(defun ews-distraction-free ()
  "Toggle distraction-free writing mode."
  (interactive)
  (if olivetti-mode
      (progn
        (olivetti-mode -1)
        (text-scale-decrease 2))
    (progn
      (window-configuration-to-register :before-olivetti)
      (delete-other-windows)
      (text-scale-increase 2)
      (olivetti-mode 1))))
```

---

## 8. Summary Cheat-Sheet for ADHD / Deep Focus

| Goal | Setting |
|------|---------|
| Hide leading stars | `org-superstar-remove-leading-stars t` or `org-startup-indented t` |
| Hide emphasis markers | `org-hide-emphasis-markers t` |
| Pretty entities | `org-pretty-entities t` |
| Use proportional font for prose | `(add-hook 'org-mode-hook 'variable-pitch-mode)` |
| Keep tables/code monospaced | `org-table`, `org-block`, `org-code` inherit `fixed-pitch` |
| Scale headings for hierarchy | `(set-face-attribute 'org-level-1 nil :height 1.35)` etc. |
| Narrow to subtree | `C-x n s` / `org-narrow-to-subtree` |
| Focus subtree in indirect buffer | `org-tree-to-indirect-buffer` |
| Distraction-free writing | `olivetti-mode` + hide modeline + fringes |
| Limit image width | `org-image-actual-width '(300)` |
| Disable startup LaTeX previews | `org-startup-with-latex-preview nil` |
| Toggle LaTeX on demand | `org-fragtog-mode` or `org-latex-preview-mode` |
| Track habits visually | `org-habit` + `:STYLE: habit` |
| Custom agenda for habits | `org-agenda-custom-commands` with `org-agenda-show-log t` |
| Reduce tag clutter | `org-auto-align-tags nil`, `org-tags-column 0` |
| Increase breathing room | `line-spacing 2` or `0.1`–`0.4` |

---

## Sources Index

1. Protesilaos Stavrou — *Emacs: configuring mixed fonts in Org mode* (2020) — https://protesilaos.com/codelog/2020-07-17-emacs-mixed-fonts-org/
2. Protesilaos Stavrou — *Emacs proof-of-concept: tweaked focused writing for Org* (2020) — https://protesilaos.com/codelog/2020-07-18-emacs-concept-org-tweaked-focus/
3. Peter Prevos (Lucid Manager) — *Ricing Org Mode: A Beautiful Writing Environment* (2025 update) — https://lucidmanager.org/productivity/ricing-org-mode/
4. Sophie Bosio — *Prettifying Emacs Org Mode* (2023) — https://sophiebos.io/posts/prettifying-emacs-org-mode/
5. GNU ELPA — *org-modern* package documentation — https://elpa.gnu.org/packages/org-modern.html
6. Karthink — *org-latex-preview: Set up and troubleshooting* (2025) — https://abode.karthinks.com/org-latex-preview/
7. Hugo Cisneros — *Org-mode configuration for Emacs* — https://hugocisneros.com/org-config/
8. Diego Zamboni (zzamboni.org) — *Beautifying Org Mode in Emacs* (2018) — https://zzamboni.org/post/beautifying-org-mode-in-emacs/
9. Org mode manual — *Previewing LaTeX fragments* — https://orgmode.org/manual/Previewing-LaTeX-fragments.html
10. Org mode Worg — *Tracking Habits with Org-mode* — https://orgmode.org/worg/org-tutorials/tracking-habits.html
11. Org mode manual — *Tracking your habits* — https://orgmode.org/manual/Tracking-your-habits.html
12. Reddit r/orgmode — *Focus on Single Org SubTree* — https://www.reddit.com/r/orgmode/comments/gm3g46/focus_on_single_org_subtree/
13. Emacs StackExchange — *How to use org-tree-to-indirect-buffer and turn off org-indent-mode* — https://emacs.stackexchange.com/questions/66653
14. Emacs StackExchange — *How shall I understand org-mode Habits Graph Colors?* — https://emacs.stackexchange.com/questions/59529
15. Steven Brown — *Org-mode: Indirect Buffer, Narrowing to tree* — https://www.stevenbrown.ca/blog/archives/2130
