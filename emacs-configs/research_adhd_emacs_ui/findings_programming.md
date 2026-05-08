# Emacs UI Parameters for Programming Language Editing: ADHD & Deep Focus

> Research findings for Python, Verilog, VHDL, MATLAB, Julia, and R.  
> Focus: reducing visual noise, minimizing popups, isolating context, and keeping the editor out of the way.

---

## 1. Syntax Highlighting Restraint

### Key Fact
Too many colors compete for attention. For ADHD users, restrained highlighting (fewer faces, lower decoration levels) reduces cognitive load and helps maintain deep focus.

### Old World: `font-lock-maximum-decoration`
Traditional Emacs modes use regex-based `font-lock`. The coarse knob is `font-lock-maximum-decoration`:

```elisp
;; Reduce syntax highlighting to a minimum globally
(setq font-lock-maximum-decoration 1)

;; Or per-mode
(setq font-lock-maximum-decoration
      '((python-mode . 1)
        (verilog-mode . 1)
        (vhdl-mode . 1)
        (matlab-mode . 1)
        (julia-mode . 1)
        (ess-r-mode . 1)))
```

> Source: GNU Emacs Manual – Font Lock Mode  
> <https://www.gnu.org/software/emacs/manual/html_node/emacs/Font-Lock.html>

### New World: Tree-sitter Feature Levels
Tree-sitter modes (Emacs 29+) use `treesit-font-lock-level` and named **features** instead of a raw decoration dial.

**Recommended conventions per level:**
- **Level 1** – absolute minimum: `comment`, `definition`
- **Level 2** – key constructs: `keyword`, `string`, `type`
- **Level 3** – everything reasonably fontified (default)
- **Level 4** – marginal: `bracket`, `delimiter`, `operator`

```elisp
;; Global restraint
(setq treesit-font-lock-level 2)

;; Per-mode hook for fine-grained control
(defun my-minimal-font-lock ()
  (setq-local treesit-font-lock-level 2))

(add-hook 'python-ts-mode-hook #'my-minimal-font-lock)
(add-hook 'c-ts-mode-hook #'my-minimal-font-lock)
```

### Cherry-Picking Features (Fine Knob)
Disable specific distracting features regardless of level:

```elisp
(defun my-python-focus-font-lock ()
  (treesit-font-lock-recompute-features
   '(comment definition keyword string type number) ;; enable
   '(bracket delimiter operator function)))         ;; disable
(add-hook 'python-ts-mode-hook #'my-python-focus-font-lock)
```

> Source: Bozhidar Batsov, "Customizing Font-Lock in the Age of Tree-sitter" (Emacs Redux, 2026-03-08)  
> <https://emacsredux.com/blog/2026/03/08/customizing-font-lock-in-the-age-of-tree-sitter/>

> Quote: *"The feature system with its levels, cherry-picking, and custom rules gives you more control than the old `font-lock-maximum-decoration` ever did."*

### Investigate Mode Feature Lists
Run inside a tree-sitter buffer to see what features are available:
```
M-x describe-variable RET treesit-font-lock-feature-list
```

---

## 2. LSP UI Minimization

### Key Fact
`lsp-mode` auto-enables many UI modules by default. For ADHD users, constant sideline annotations, doc popups, and breadcrumbs are a major source of distraction.

### Turn-off Guide
The official `lsp-mode` tutorial lists how to disable each feature:

```elisp
;; Disable lsp-ui completely (if using lsp-ui)
(setq lsp-ui-doc-enable nil)
(setq lsp-ui-sideline-enable nil)
(setq lsp-ui-sideline-show-hover nil)
(setq lsp-ui-sideline-show-diagnostics nil)
(setq lsp-ui-sideline-show-code-actions nil)

;; Disable headerline / breadcrumb
(setq lsp-headerline-breadcrumb-enable nil)

;; Disable modeline code actions
(setq lsp-modeline-code-actions-enable nil)

;; Disable signature help popups
(setq lsp-signature-auto-activate nil)
(setq lsp-signature-render-documentation nil)

;; Disable lens (code lens inline annotations)
(setq lsp-lens-enable nil)

;; Disable completion detail/kind icons in popup
(setq lsp-completion-show-detail nil)
(setq lsp-completion-show-kind nil)

;; Keep only the core LSP backend; disable all UI
(setq lsp-auto-configure nil)
```

> Source: LSP Mode Docs, "A guide on disabling/enabling lsp-mode features"  
> <https://emacs-lsp.github.io/lsp-mode/tutorials/how-to-turn-off/>

### Corfu / Company Popup Restraint
If using `corfu` (lightweight) or `company` (legacy), constrain popup behavior:

```elisp
;; Corfu — minimal, no doc popup, no preview
(setq corfu-auto t
      corfu-auto-delay 0.3
      corfu-auto-prefix 3
      corfu-preview-current nil
      corfu-popupinfo-delay nil)

;; Company — if still used
(setq company-tooltip-limit 5
      company-idle-delay 0.3
      company-minimum-prefix-length 3
      company-show-numbers nil)
```

### Eldoc Restraint
Eldoc can flood the echo area with type signatures. Suppress or delay it:

```elisp
(setq eldoc-idle-delay 1.0)       ;; Wait longer before showing
(setq eldoc-echo-area-use-multiline-p nil) ;; Force single-line
```

> Source: Emacs Stack Exchange – "lsp-mode: disable documentation popup"  
> <https://emacs.stackexchange.com/questions/63961/lsp-mode-disable-documentation-popup>

---

## 3. Line Numbers and Relative Line Numbers

### Trade-offs
| Mode | Pros | Cons for ADHD |
|------|------|---------------|
| **Absolute** (`t`) | Stable, good for stack traces / grep | Constantly changing numbers when scrolling large files |
| **Relative** (`relative`) | Fast `C-u N C-n` jumps; less visual clutter at margins | Numbers still change on every line movement |
| **Off** (`nil`) | Zero visual noise | Hard to orient, no jump target |

### Recommendation for Deep Focus
Use **absolute line numbers in a low-contrast face**, or disable entirely and rely on `avy-goto-line` / `consult-line` for navigation.

```elisp
;; Low-contrast absolute numbers
(setq display-line-numbers-type t)
(global-display-line-numbers-mode +1)

;; If you still want relative (e.g., with evil-mode)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode +1)

;; Or disable entirely for maximum calm
(global-display-line-numbers-mode -1)
```

> Source: Bozhidar Batsov, "Relative Line Numbers" (Emacs Redux, 2025-03-19)  
> <https://emacsredux.com/blog/2025/03/19/relative-line-numbers/>

> Source: Chris Maiorana, "Relative Line Numbers in Emacs" (2024-06-21)  
> <https://chrismaiorana.com/relative-line-numbers-in-emacs/>

---

## 4. Code Folding and Narrowing

### Key Fact
Folding hides implementation details, letting you focus on structure. Narrowing (`narrow-to-defun`, `narrow-to-region`) is even stronger—it literally removes everything else from view.

### Hideshow (`hs-minor-mode`)
Built-in. Works with regex blocks. Good for C-like languages.

```elisp
(add-hook 'prog-mode-hook #'hs-minor-mode)

;; Simple Org-like cycle for hideshow
(defun hs-cycle (&optional level)
  (interactive "p")
  (let (message-log-max (inhibit-message t))
    (if (= level 1)
        (pcase last-command
          ('hs-cycle (hs-hide-level 1)
                     (setq this-command 'hs-cycle-children))
          ('hs-cycle-children
           (save-excursion (hs-show-block))
           (hs-show-block)
           (setq this-command 'hs-cycle-subtree))
          ('hs-cycle-subtree (hs-hide-block))
          (_ (if (not (hs-already-hidden-p))
                 (hs-hide-block)
               (hs-hide-level 1)
               (setq this-command 'hs-cycle-children))))
      (hs-hide-level level)
      (setq this-command 'hs-hide-level))))

(defun hs-global-cycle ()
  (interactive)
  (pcase last-command
    ('hs-global-cycle
     (save-excursion (hs-show-all))
     (setq this-command 'hs-global-show))
    (_ (hs-hide-all))))

;; Bind to easy keys
(define-key hs-minor-mode-map (kbd "C-<tab>") #'hs-cycle)
(define-key hs-minor-mode-map (kbd "C-S-<tab>") #'hs-global-cycle)
```

> Source: Karthik Chikmagalur, "Simple folding with Hideshow" (2021-12-20)  
> <https://karthinks.com/software/simple-folding-with-hideshow/>

### Outline Minor Mode
Best for languages with clear heading/block structure. Emacs 28+ has `outline-cycle`.

```elisp
(add-hook 'prog-mode-hook #'outline-minor-mode)
(define-key outline-minor-mode-map (kbd "<tab>") #'outline-cycle)
```

### Narrowing (Nuclear Option)
When you need *total* isolation from the rest of the file:

```elisp
;; Narrow to current function / block
(defun narrow-to-defun-or-block ()
  (interactive)
  (if (use-region-p)
      (narrow-to-region (region-beginning) (region-end))
    (narrow-to-defun)))

(global-set-key (kbd "C-x n n") #'narrow-to-defun-or-block)
(global-set-key (kbd "C-x n w") #'widen)
```

> Tip: Combine narrowing with `dimmer.el` (see §5) for maximum context isolation.

---

## 5. Context Isolation: Active Window Highlighting

### Key Fact
When split windows are open, the eye is drawn to inactive panes. Dimming or accenting the active window reduces peripheral visual noise.

### `dimmer.el` — Dim Inactive Buffers
Popular, actively maintained. Dims faces in all non-selected windows.

```elisp
(use-package dimmer
  :config
  (setq dimmer-fraction 0.4)       ;; 0.0 = black, 1.0 = normal
  (dimmer-mode +1))
```

> Source: gonewest818/dimmer.el on GitHub  
> <https://github.com/gonewest818/dimmer.el>

### `selected-window-accent-mode` — Accent the Active Window
Newer package (2024). Instead of dimming others, it accents the selected window via fringes, mode line, header line, and margins.

```elisp
(use-package selected-window-accent-mode
  :config
  (selected-window-accent-mode +1))
```

> Source: captainflasmr/selected-window-accent-mode on GitHub  
> <https://github.com/captainflasmr/selected-window-accent-mode>

### `hiwin-mode` — Visible Active Window
Changes background of the active window. Older but functional.

```elisp
(use-package hiwin
  :config
  (hiwin-activate))
```

> Source: fenril058/hiwin-mode on GitHub  
> <https://github.com/fenril058/hiwin-mode>

### Recommendation for ADHD
**`dimmer.el`** is the most battle-tested. Start with a fraction of `0.4`–`0.5`. If you find dimming too aggressive, try `selected-window-accent-mode` for a subtler cue.

---

## 6. Flycheck / Flymake Error Display Restraint

### Key Fact
Inline error underlines + constant minibuffer messages create a "death by a thousand cuts" effect. For ADHD, it’s better to batch-check or suppress real-time popups.

### Flycheck — Suppress Popups
```elisp
;; Disable error popup / tooltip
(setq flycheck-display-errors-function nil)
(setq flycheck-help-echo-function nil)

;; Only show errors on explicit request (C-c ! l)
(setq flycheck-indication-mode nil)
```

### Flymake — Suppress Echo-Area Noise
```elisp
;; Flymake: don't show diagnostics in echo area automatically
(setq flymake-show-diagnostics-at-end-of-line nil)
(setq help-at-pt-display-when-idle nil)
```

### On-Demand Error List
Instead of constant inline noise, open the error list only when needed:

```elisp
;; Flycheck error list
(global-set-key (kbd "C-c ! l") #'flycheck-list-errors)

;; Flymake diagnostics buffer
(global-set-key (kbd "C-c ! d") #'flymake-show-diagnostics-buffer)
```

### Inline Overlay Alternative (`flyover`)
If you *must* have inline errors, `flyover` renders them as beautiful but unobtrusive overlays:

```elisp
(use-package flyover
  :after flycheck)  ;; or flymake
```

> Source: konrad1977/flyover on GitHub  
> <https://github.com/konrad1977/flyover>

### Manual-Check Strategy
For extreme focus, disable on-the-fly checking entirely and run checks explicitly:

```elisp
;; Flycheck: only check on save, not while typing
(setq flycheck-check-syntax-automatically '(save mode-enabled))
```

> Source: Flycheck 36.0 Docs – "Error List"  
> <https://www.flycheck.org/en/latest/user/error-list.html>

> Source: Reddit r/emacs, "The State of Flycheck: Alive and Kicking" (2024-02-10)  
> <https://www.reddit.com/r/emacs/comments/1angve3/the_state_of_flycheck_alive_and_kicking/>

---

## 7. Language-Specific UI Tweaks

### Python
- Use `python-ts-mode` (tree-sitter) for more accurate, less visually noisy highlighting.
- Set `treesit-font-lock-level` to `2` to avoid drowning in decorator / delimiter colors.
- `lsp-pyright` or `pylsp`: disable inlay type hints (`lsp-inlay-hint-enable nil`).

```elisp
(add-hook 'python-ts-mode-hook
          (lambda ()
            (setq-local treesit-font-lock-level 2)
            (setq-local lsp-inlay-hint-enable nil)))
```

### Verilog / SystemVerilog
- `verilog-mode` (built-in) or `verilog-ext` (community) for modern SV.
- `verilog-mode` can be verbose with indent messages; suppress them:

```elisp
(setq verilog-indent-level 2)
(setq verilog-indent-level-module 2)
(setq verilog-indent-level-declaration 2)
(setq verilog-case-indent 2)
(setq verilog-auto-newline nil)        ;; Less automatic noise
(setq verilog-auto-indent-on-newline nil)
```

> Source: GNU ELPA – verilog-mode  
> <https://elpa.gnu.org/packages/verilog-mode.html>

> Source: Reddit r/emacs – verilog-ext / vhdl-ext discussion (2023-01-29)  
> <https://www.reddit.com/r/emacs/comments/10oig9m/verilogextvhdlext_systemverilogvhdl/>

### VHDL
- `vhdl-mode` is built-in and highly configurable. It can produce a lot of electric-indent and template noise.

```elisp
(setq vhdl-basic-offset 2)
(setq vhdl-indent-level 2)
(setq vhdl-electric-mode nil)          ;; Disable automatic template insertion
(setq vhdl-stutter-mode nil)           ;; Disable double-key shortcuts
```

> Source: GNU Emacs Manual – VHDL Mode  
> <https://www.gnu.org/software/emacs/manual/html_mono/vhdl-mode.html>

### MATLAB
- `matlab-mode` (from MathWorks or emacsmirror) has linting and cell-mode UI.
- Suppress auto-output and lint popups:

```elisp
(setq matlab-show-mlint-warnings nil)
(setq matlab-highlight-cross-function-variables nil)
(setq matlab-indent-level 2)
(setq matlab-functions-have-end t)
```

> Source: mathworks/Emacs-MATLAB-Mode on GitHub  
> <https://github.com/mathworks/Emacs-MATLAB-Mode>

### Julia
- `julia-mode` + `julia-ts-mode` (if available). Julia’s heavy use of Unicode can look busy; restrain `font-lock`.
- `julia-repl` can pop up a terminal window—use `popper` or `vterm-toggle` to manage it cleanly.

```elisp
(add-hook 'julia-mode-hook
          (lambda ()
            (setq-local font-lock-maximum-decoration 1)))
```

> Source: Julia Discourse – "Code folding for emacs?" (2020-06-15)  
> <https://discourse.julialang.org/t/code-folding-for-emacs/41421>

### R (ESS)
- `ess` is powerful but has many UI elements: tracebacks, help buffers, roxygen highlights.
- Suppress auto-help and limit font-lock:

```elisp
(setq ess-help-kill-buffers t)
(setq ess-describe-at-point-method nil)   ;; Don't popup help on hover
(setq ess-r-package-auto-set-evaluation-env nil)
```

---

## 8. Summary Cheat Sheet

| Concern | ADHD-Friendly Setting |
|---------|----------------------|
| Syntax highlighting | `treesit-font-lock-level 2` or `font-lock-maximum-decoration 1` |
| LSP doc popups | `lsp-ui-doc-enable nil`, `lsp-signature-auto-activate nil` |
| LSP sideline | `lsp-ui-sideline-enable nil` |
| Breadcrumbs | `lsp-headerline-breadcrumb-enable nil` |
| Completion popups | `corfu-popupinfo-delay nil`, `company-idle-delay 0.3` |
| Eldoc echo area | `eldoc-idle-delay 1.0`, single-line only |
| Line numbers | `display-line-numbers-type nil` (or low-contrast absolute) |
| Code folding | `hs-minor-mode` + `hs-cycle` on `C-<tab>` |
| Narrowing | `narrow-to-defun` / `widen` on quick keys |
| Context isolation | `dimmer-mode` at fraction `0.4` |
| Flycheck noise | `flycheck-display-errors-function nil`, check on save only |
| Flymake noise | `flymake-show-diagnostics-at-end-of-line nil` |

---

## Sources

1. Bozhidar Batsov, "Customizing Font-Lock in the Age of Tree-sitter" — Emacs Redux, 2026-03-08  
   <https://emacsredux.com/blog/2026/03/08/customizing-font-lock-in-the-age-of-tree-sitter/>

2. LSP Mode Docs, "A guide on disabling/enabling lsp-mode features"  
   <https://emacs-lsp.github.io/lsp-mode/tutorials/how-to-turn-off/>

3. Bozhidar Batsov, "Relative Line Numbers" — Emacs Redux, 2025-03-19  
   <https://emacsredux.com/blog/2025/03/19/relative-line-numbers/>

4. Karthik Chikmagalur, "Simple folding with Hideshow" — Karthinks, 2021-12-20  
   <https://karthinks.com/software/simple-folding-with-hideshow/>

5. Karthik Chikmagalur, "The Emacs Window Management Almanac" — Karthinks, 2024-05-10  
   <https://karthinks.com/software/emacs-window-management-almanac/>

6. gonewest818/dimmer.el — GitHub  
   <https://github.com/gonewest818/dimmer.el>

7. captainflasmr/selected-window-accent-mode — GitHub  
   <https://github.com/captainflasmr/selected-window-accent-mode>

8. Fenril058/hiwin-mode — GitHub  
   <https://github.com/fenril058/hiwin-mode>

9. Flycheck 36.0 Documentation — Error List  
   <https://www.flycheck.org/en/latest/user/error-list.html>

10. Emacs Stack Exchange — "lsp-mode: disable documentation popup"  
    <https://emacs.stackexchange.com/questions/63961/lsp-mode-disable-documentation-popup>

11. GNU Emacs Manual — VHDL Mode  
    <https://www.gnu.org/software/emacs/manual/html_mono/vhdl-mode.html>

12. mathworks/Emacs-MATLAB-Mode — GitHub  
    <https://github.com/mathworks/Emacs-MATLAB-Mode>

13. GNU ELPA — verilog-mode  
    <https://elpa.gnu.org/packages/verilog-mode.html>

14. konrad1977/flyover — GitHub  
    <https://github.com/konrad1977/flyover>

15. Reddit r/emacs — "Me, emacs, Autism, and ADHD." (2021-12-07)  
    <https://www.reddit.com/r/emacs/comments/rapk9f/me_emacs_autism_and_adhd/>
