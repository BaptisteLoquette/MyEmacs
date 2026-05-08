;;; custom-post-adhd-focus.el --- ADHD & Deep Focus UI Parameters -*- lexical-binding: t no-byte-compile: t -*-

;;; Commentary:
;;; Optimises Emacs UI for ADHD and deep focus based on research-backed
;;; parameters.  Covers typography, themes, chrome reduction, Org mode,
;;; programming (Python/Verilog/VHDL/MATLAB/Julia/R), FPGA, web browsing,
;;; PDF/media reading, and annotation workflows.
;;;
;;; Quick toggles:
;;;   C-c z      → writeroom-mode (distraction-free)
;;;   C-c n n    → org-narrow-to-subtree / widen
;;;   C-c n N    → org-tree-to-indirect-buffer (focus subtree)
;;;   C-c F      → focus-mode (dim surrounding text)
;;;   C-<tab>    → cycle hideshow fold at point

;;; Code:

;; ════════════════════════════════════════════════════════════════════════
;; 1. GLOBAL VISUAL BASE
;; ════════════════════════════════════════════════════════════════════════

;; ── Fonts (ADHD-optimised) ─────────────────────────────────────────────
;; Install JetBrains Mono and Lexend Deca for best results.
(when (member "JetBrains Mono" (font-family-list))
  (set-face-attribute 'default nil :family "JetBrains Mono" :height 140))
(when (member "Lexend Deca" (font-family-list))
  (set-face-attribute 'variable-pitch nil :family "Lexend Deca" :height 150))

;; ── Line spacing ─────────────────────────────────────────────────────────
(setq-default line-spacing 0.25)

;; ── Cursor: solid bar, no blink ────────────────────────────────────────
(setq-default cursor-type 'bar)
(blink-cursor-mode -1)
(global-hl-line-mode +1)

;; ── UI Chrome removal ────────────────────────────────────────────────────
(menu-bar-mode -1)
(tool-bar-mode -1)
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'horizontal-scroll-bar-mode) (horizontal-scroll-bar-mode -1))
(fringe-mode 8)

;; ── Scroll behaviour: conservative, smooth ───────────────────────────────
(setq scroll-margin 3)
(setq scroll-conservatively 101)
(setq scroll-step 1)
(setq auto-window-vscroll nil)

;; ── Window dividers ─────────────────────────────────────────────────────
(setq window-divider-default-places 'right-only)
(setq window-divider-default-right-width 1)
(setq window-divider-default-bottom-width 1)
(window-divider-mode +1)

;; ── Distractions ────────────────────────────────────────────────────────
(setq ring-bell-function 'ignore)
(setq visible-bell nil)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)
(setq initial-scratch-message nil)
(setq echo-keystrokes 0.1)

;; ── Transparency (Emacs 29+ background-only) ────────────────────────────
(when (>= emacs-major-version 29)
  (add-to-list 'default-frame-alist '(alpha-background . 92)))

;; ── Theme / syntax highlighting ──────────────────────────────────────
;; Level 2 = balanced: enough color for RTL debugging, not overwhelming.
;; (Level 1 was too minimal for Verilog/VHDL signal tracing.)
(setq font-lock-maximum-decoration 2)

;; ── Line numbers ───────────────────────────────────────────────────────
(global-display-line-numbers-mode -1)

;; ── Modeline minimalism ────────────────────────────────────────────────
;; Centaur already uses doom-modeline.  Strip segments for ADHD focus.
(with-eval-after-load 'doom-modeline
  (setq doom-modeline-minor-modes nil)
  (setq doom-modeline-indent-info nil)
  (setq doom-modeline-buffer-encoding nil)
  (setq doom-modeline-vcs-max-length 12)
  (setq doom-modeline-buffer-file-name-style 'file-name))

;; ════════════════════════════════════════════════════════════════════════
;; 2. DEEP FOCUS ZEN MODES
;; ════════════════════════════════════════════════════════════════════════

(use-package writeroom-mode
  :ensure t
  :config
  (setq writeroom-width 80)
  (setq writeroom-maximize-window nil)
  ;; Don't let writeroom toggle scroll-bars or fullscreen —
  ;; visual-fill-column and olivetti handle centering.
  (setq writeroom-global-effects
        '(writeroom-toggle-menu-bar-lines
          writeroom-toggle-tool-bar-lines))
  :bind ("C-c z" . writeroom-mode))

(use-package olivetti
  :ensure t
  :hook ((org-mode . olivetti-mode)
         (text-mode . olivetti-mode)
         (eww-mode . olivetti-mode))
  :config
  (setq olivetti-body-width 0.65)
  (setq olivetti-minimum-body-width 72)
  (setq olivetti-recall-visual-line-mode-entry-state t))

(use-package focus
  :ensure t
  :bind ("C-c F" . focus-mode))

(use-package dimmer
  :ensure t
  :config
  (setq dimmer-fraction 0.45)
  (dimmer-mode +1))

;; ════════════════════════════════════════════════════════════════════════
;; 3. ORG MODE & ORG TABLE
;; ════════════════════════════════════════════════════════════════════════

;; ── Mixed fonts: variable-pitch prose, fixed-pitch tables/code ───────────
;; CRITICAL: this function MUST run after org-modern-mode, otherwise
;; org-modern overwrites the face attributes we set here.
(defun my/org-mixed-fonts ()
  "Enable mixed fonts in Org: variable-pitch for prose, fixed for code/tables."
  (variable-pitch-mode +1)
  (mapc (lambda (face)
          (when (facep face)
            (set-face-attribute face nil :inherit 'fixed-pitch)))
        '(org-table
          org-table-header
          org-formula
          org-block
          org-block-begin-line
          org-block-end-line
          org-code
          org-verbatim
          org-special-keyword
          org-meta-line
          org-date
          org-drawer
          org-property-value
          org-property-block
          org-document-info-keyword
          org-formula
          org-column
          org-column-title
          line-number
          line-number-current-line)))
(add-hook 'org-mode-hook #'my/org-mixed-fonts -90)  ; run late (after org-modern)

;; ── Heading scale (hierarchy: each level clearly distinct) ─────────────
(with-eval-after-load 'org
  (set-face-attribute 'org-document-title nil :height 1.60 :weight 'bold)
  (set-face-attribute 'org-level-1 nil :height 1.35 :weight 'bold)
  (set-face-attribute 'org-level-2 nil :height 1.20 :weight 'bold)
  (set-face-attribute 'org-level-3 nil :height 1.10 :weight 'semi-bold)
  (set-face-attribute 'org-level-4 nil :height 1.05 :weight 'semi-bold))

;; ── Org visual settings ─────────────────────────────────────────────────
(with-eval-after-load 'org
  (setq org-hide-emphasis-markers t)
  (setq org-pretty-entities t)
  (setq org-ellipsis "…")
  (setq org-startup-indented t)
  (setq org-auto-align-tags nil)
  (setq org-tags-column 0)
  ;; Limit image width to avoid visual overload
  (setq org-image-actual-width '(300))
  ;; Do NOT auto-preview images or LaTeX on startup (ADHD-friendly)
  (setq org-startup-with-inline-images nil)
  (setq org-startup-with-latex-preview nil))

;; ── org-modern tweaks (loaded earlier in custom-post-data) ──────────────
(with-eval-after-load 'org-modern
  (setq org-modern-star nil)
  (setq org-modern-hide-stars t))
  ;; Note: org-modern-table is disabled (set to nil in custom-post-data.el)
  ;; so no table face fix needed — Org's native tables handle alignment.

;; ── Narrowing & deep-focus commands ─────────────────────────────────────
(global-set-key (kbd "C-c n n") #'org-narrow-to-subtree)
(global-set-key (kbd "C-c n w") #'widen)
(global-set-key (kbd "C-c n N") #'org-tree-to-indirect-buffer)

;; ── Visual fill column for centred text ─────────────────────────────────
(use-package visual-fill-column
  :ensure t
  :hook ((text-mode . visual-fill-column-mode)
         (org-mode . visual-fill-column-mode))
  :config
  (setq visual-fill-column-width 80)
  (setq visual-fill-column-center-text t))

;; ════════════════════════════════════════════════════════════════════════
;; 4. PROGRAMMING MODES
;; ════════════════════════════════════════════════════════════════════════

;; ── Tree-sitter: restrained font-lock ───────────────────────────────────
(when (and (>= emacs-major-version 29) (treesit-available-p))
  (setq treesit-font-lock-level 2))

;; ── LSP UI minimisation ────────────────────────────────────────────────
(with-eval-after-load 'lsp-mode
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-sideline-enable nil)
  (setq lsp-ui-sideline-show-hover nil)
  (setq lsp-ui-sideline-show-diagnostics nil)
  (setq lsp-ui-sideline-show-code-actions nil)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-modeline-code-actions-enable nil)
  (setq lsp-signature-auto-activate nil)
  (setq lsp-signature-render-documentation nil)
  (setq lsp-lens-enable nil)
  (setq lsp-completion-show-detail nil)
  (setq lsp-completion-show-kind nil)
  (setq lsp-auto-configure nil))

(with-eval-after-load 'lsp-ui
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-sideline-enable nil))

;; ── Completion popup restraint ──────────────────────────────────────────
(with-eval-after-load 'corfu
  (setq corfu-preview-current nil)
  (setq corfu-popupinfo-delay nil))

(with-eval-after-load 'company
  (setq company-tooltip-limit 5)
  (setq company-idle-delay 0.3)
  (setq company-minimum-prefix-length 3)
  (setq company-show-numbers nil))

;; ── Eldoc restraint ─────────────────────────────────────────────────────
(setq eldoc-idle-delay 1.0)
(setq eldoc-echo-area-use-multiline-p nil)

;; ── Code folding ────────────────────────────────────────────────────────
(add-hook 'prog-mode-hook #'hs-minor-mode)

(defun my/hs-cycle ()
  "Cycle hideshow fold state at point."
  (interactive)
  (if (hs-already-hidden-p)
      (hs-show-block)
    (hs-hide-block)))
(global-set-key (kbd "C-<tab>") #'my/hs-cycle)

;; ── Flycheck restraint ────────────────────────────────────────────────
(with-eval-after-load 'flycheck
  (setq flycheck-display-errors-function nil)
  (setq flycheck-indication-mode nil)
  (setq flycheck-check-syntax-automatically '(save mode-enabled)))

;; ════════════════════════════════════════════════════════════════════════
;; 5. LANGUAGE-SPECIFIC UI (FPGA / EDA / DATA)
;; ════════════════════════════════════════════════════════════════════════

;; Python
(add-hook 'python-ts-mode-hook
          (lambda ()
            (setq-local treesit-font-lock-level 2)
            (setq-local lsp-inlay-hint-enable nil)))

;; Verilog / SystemVerilog
(add-hook 'verilog-mode-hook
          (lambda ()
            (setq verilog-auto-newline nil)
            (setq verilog-auto-indent-on-newline nil)))
(add-hook 'verilog-ts-mode-hook
          (lambda ()
            (setq verilog-ts-indent-level 2)
            (setq verilog-ts-indent-level-module 2)))

;; VHDL
(add-hook 'vhdl-mode-hook
          (lambda ()
            (setq vhdl-electric-mode nil)
            (setq vhdl-stutter-mode nil)))
(add-hook 'vhdl-ts-mode-hook
          (lambda ()
            (setq vhdl-ts-indent-level 2)))

;; MATLAB
(add-hook 'matlab-mode-hook
          (lambda ()
            (setq matlab-show-mlint-warnings nil)
            (setq matlab-highlight-cross-function-variables nil)))

;; Julia
(add-hook 'julia-mode-hook
          (lambda ()
            (setq-local font-lock-maximum-decoration 1)))

;; R / ESS
(add-hook 'ess-r-mode-hook
          (lambda ()
            (setq ess-describe-at-point-method nil)))

;; ════════════════════════════════════════════════════════════════════════
;; 6. WEB BROWSING, MEDIA & RESEARCH
;; ════════════════════════════════════════════════════════════════════════

;; ── EWW / SHR ───────────────────────────────────────────────────────────
;; Use system browser for most URLs (Plotly, modern sites, etc.)
;; EWW is available via M-x eww for lightweight reading.
(setq browse-url-browser-function 'browse-url-default-browser)
(setq shr-inhibit-images t)
(setq shr-use-fonts t)
(setq shr-max-image-proportion 0.3)
(setq shr-width 80)
(add-hook 'eww-after-render-hook #'eww-readable-mode)
(add-hook 'eww-mode-hook #'olivetti-mode)

;; ── PDF Tools ───────────────────────────────────────────────────────────
(add-hook 'pdf-view-mode-hook #'pdf-view-midnight-minor-mode)
(setq pdf-view-midnight-colors '("#c8c8c8" . "#1a1a1a"))
(setq-default pdf-view-display-size 'fit-width)
(setq pdf-cache-image-limit 8)
(setq pdf-view-use-scaling t)

;; ── Window management ───────────────────────────────────────────────────
(winner-mode +1)

;; popper-reference-buffers: extend Centaur's default list without
;; double-starting the mode (avoid conflict with popper-tab-line-mode).
(with-eval-after-load 'popper
  (setq popper-reference-buffers
        (append '("\\*Messages\\*"
                  "\\*Help\\*"
                  "\\*Compile-Log\\*"
                  help-mode
                  compilation-mode)
                popper-reference-buffers)))

;; ── Deep focus reading toggle ───────────────────────────────────────────
(defun my/deep-focus-reading ()
  "Enable all distraction-reduction modes for reading."
  (interactive)
  (writeroom-mode +1)
  (unless (derived-mode-p 'prog-mode)
    (setq-local mode-line-format nil))
  (set-window-fringes (selected-window) 0 0)
  (message "Deep focus ON"))

(defun my/deep-focus-off ()
  "Restore normal editing UI."
  (interactive)
  (writeroom-mode -1)
  (kill-local-variable 'mode-line-format)
  (set-window-fringes (selected-window) nil nil)
  (message "Deep focus OFF"))

;; ════════════════════════════════════════════════════════════════════════
;; 7. ANNOTATIONS & RESEARCH SIDEBAR
;; ════════════════════════════════════════════════════════════════════════

;; PDF annotation colours (calm ADHD-friendly palette)
(with-eval-after-load 'pdf-annot
  (setq pdf-annot-default-markup-annotation-properties
        '((color . "#f1fa8c") (opacity . 0.4))))

;; org-noter layout (enabled later if user re-enables the package)
(with-eval-after-load 'org-noter
  (setq org-noter-notes-window-location 'horizontal)
  (setq org-noter-auto-save-last-location t))

;; ════════════════════════════════════════════════════════════════════════
;; 8. VISUAL POLISH
;; ════════════════════════════════════════════════════════════════════════

;; ── Link faces: better contrast on dark themes ────────────────────────
;; Default org-mode links are hard to read on dark backgrounds.
(with-eval-after-load 'org
  ;; Links (file:, id:, http:, etc.)
  (set-face-attribute 'org-link nil
                      :foreground "#82aaff"   ; soft blue, readable on dark bg
                      :weight 'normal
                      :underline t)
  ;; Verbatim/code inline
  (set-face-attribute 'org-verbatim nil
                      :foreground "#c3e88d"   ; soft green
                      :weight 'semi-bold)
  (set-face-attribute 'org-code nil
                      :foreground "#c3e88d")
  ;; Tags (ensure readable)
  (set-face-attribute 'org-tag nil
                      :foreground "#b0bec5"   ; muted grey
                      :weight 'normal
                      :height 0.85)
  ;; Properties
  (set-face-attribute 'org-property-value nil
                      :foreground "#90a4ae"
                      :height 0.9)
  ;; Drawer delimiters (:PROPERTIES:, :END:)
  (set-face-attribute 'org-drawer nil
                      :foreground "#616161"
                      :height 0.85))

;; ── Table separator: use thin single-line instead of heavy double ─────
;; ── Table separator: org-modern-table is disabled — no box-drawing needed.
;; Org's native |----+----| tables auto-realign on every edit.

;; ── Fix: manual command to force monospace tables and realign ─────────
(defun my/org-force-monospace-tables ()
  "Force all Org table faces to use monospace font and realign tables.
Run this if tables look misaligned after opening a file."
  (interactive)
  ;; Reset table faces to monospace
  (dolist (face '(org-table org-table-header org-formula
                  org-column org-column-title))
    (when (facep face)
      (set-face-attribute face nil :family nil :inherit 'fixed-pitch)))
  ;; Realign all tables in the buffer
  (when (derived-mode-p 'org-mode)
    (org-table-map-tables (lambda () (org-table-align)) t))
  (message "Table faces reset to monospace & tables realigned"))

(provide 'custom-post-adhd-focus)
;;; custom-post-adhd-focus.el ends here
