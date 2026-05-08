;;; custom-post-data.el --- Research & development, Org, data science -*- lexical-binding: t no-byte-compile: t -*-

;;; Commentary:
;;;   Org-centric R&D setup:
;;;     - org-mode (base Centaur already configures)
;;;     - org-roam v2 + org-roam-ui + org-roam-bibtex
;;;     - org-ql  (search/filter headline queries)
;;;     - org-transclusion (include content from other files)
;;;     - org-ref + pdf-tools (academic workflow)
;;;     - org-babel (Python/R/Julia/Jupyter/gnuplot)
;;;     - org-id-locations fix (squelch init warning)
;;;     - TAG-based workflow (find by current tag, org-ql tag search)
;;;     - Web capture: org-web-tools + org-remark

;;; Code:

;; ── 1. org-id-locations fix ──────────────────────────────────────────
;; The default relative path resolves to `user-emacs-directory' while
;; Centaur loads, producing:
;;   "Could not read `org-id-locations' from
;;    ~/emacs-configs/centaur-emacs/.org-id-locations"
;; Fix: absolute path in Chemacs ~/.emacs.d/ (shared across profiles).
(setq org-id-locations-file
      (expand-file-name "~/.emacs.d/.org-id-locations"))

;; When org-id loads, make sure global tracking is on.
(with-eval-after-load 'org-id
  (setq org-id-track-globally t))

;; ── 2. Org-mode overrides (after Centaur's init-org loads) ───────────
;; Centaur already sets: org-directory, agenda-files, babel languages,
;; todo keywords, capture templates, etc.  We layer R&D-specific tweaks.

(with-eval-after-load 'org
  ;; Image & display
  ;; NOTE: org-startup-with-inline-images is set to nil in custom-post-adhd-focus.el
  ;; (ADHD-friendly: don't auto-show images). Use C-c C-x C-v to toggle manually.
  ;; We still hook inline image display after babel execution so results show up.
  (add-hook 'org-babel-after-execute-hook #'org-display-inline-images)

  ;; Ask before running babel blocks from untrusted files.
  ;; Auto-approve blocks inside our own ~/org/ tree.
  (setq org-confirm-babel-evaluate
        (lambda (lang body)
          (let ((file (or (buffer-file-name) "")))
            (if (string-prefix-p (expand-file-name "~/org/") file)
                nil        ; trusted — don't ask
              t))))        ; untrusted — ask
  (setq org-src-fontify-natively t)
  (setq org-src-tab-acts-natively t)

  ;; ── Babel language list (SINGLE SOURCE OF TRUTH) ─────────────────────
  ;; All babel languages are registered here. Other files (sketch, eda, fpga)
  ;; do NOT re-register — they only set language-specific variables.
  ;;
  ;; NOTE: use 'C' for C/C++ (covers both). 'c++' causes ob-c++ not found error.
  ;;
  ;; Optional languages (require external tools or extra packages) are loaded
  ;; conditionally with locate-library / executable-find guards.
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python    . t)
     (R         . t)
     (julia     . t)
     (shell     . t)
     (sql       . t)
     (gnuplot   . t)
     (latex     . t)
     (C         . t)
     (js        . t)
     (java      . t)
     (plantuml  . t)
     (ditaa     . t)
     (dot       . t)))

  ;; ── Optional babel backends (loaded conditionally) ───────────────────

  ;; Verilog / SystemVerilog (requires ob-verilog from org-contrib)
  (when (locate-library "ob-verilog")
    (add-to-list 'org-babel-load-languages '(verilog . t))
    (org-babel-do-load-languages 'org-babel-load-languages
                                 org-babel-load-languages)
    (message "[babel] ob-verilog loaded"))

  ;; VHDL (custom ob-vhdl in lisp/ — uses GHDL)
  (when (locate-library "ob-vhdl")
    (add-to-list 'org-babel-load-languages '(vhdl . t))
    (org-babel-do-load-languages 'org-babel-load-languages
                                 org-babel-load-languages)
    (message "[babel] ob-vhdl loaded"))

  ;; Mermaid (requires mmdc CLI: npm install -g @mermaid-js/mermaid-cli)
  (when (or (executable-find "mmdc") (executable-find "mmdc.exe"))
    (add-to-list 'org-babel-load-languages '(mermaid . t))
    (org-babel-do-load-languages 'org-babel-load-languages
                                 org-babel-load-languages)
    (message "[babel] mermaid loaded (mmdc found)"))

  ;; Spice / ngspice (requires ob-spice package + ngspice binary)
  (when (and (locate-library "ob-spice")
             (or (executable-find "ngspice") (executable-find "ngspice.exe")))
    (add-to-list 'org-babel-load-languages '(spice . t))
    (org-babel-do-load-languages 'org-babel-load-languages
                                 org-babel-load-languages)
    (message "[babel] spice loaded (ngspice found)"))

  ;; Jupyter (requires emacs-jupyter package)
  (with-eval-after-load 'jupyter
    (require 'ob-jupyter nil t))

  ;; LaTeX preview quality
  (setq org-latex-pdf-process
        '("latexmk -f -pdf -%latex -output-directory=%o %f"))

  ;; Agenda scope: our research org tree
  (setq org-agenda-files '("~/org/inbox.org"
                           "~/org/projects.org"
                           "~/org/papers.org"
                           "~/org/notes.org"))

  ;; Archiving
  (setq org-archive-location "~/org/archive/%s_archive::")

  ;; Table rendering: fixes drift from long URLs, auto-realign
  (setq org-table-automatic-realign t)
  (setq org-startup-align-all-tables t)  ; align tables when opening files
  (setq org-startup-truncated nil))   ; wrap prose; reactive hook truncates tables

;; ── Org UI / Rendering ─────────────────────────────────────────────────
;; Fixes broken table layout from long URLs and wrapped lines.
(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :config
  ;; org-modern-table DISABLED: box-drawing tables break alignment on
  ;; window resize and when variable-pitch fonts leak in.
  ;; Org's native |----+----| tables auto-realign on every edit and
  ;; adapt to any window width — much more robust.
  (setq org-modern-table nil
        org-modern-block t
        org-modern-keyword t
        org-modern-todo t
        org-modern-priority t
        org-modern-tags t
        org-modern-statistics t
        org-modern-star nil
        ;; org-modern-hide-stars: overridden to t in custom-post-adhd-focus.el
        org-modern-hide-stars nil))

(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autolinks t
        org-appear-autosubmarkers t
        org-appear-autoentities t)
  ;; Guard: prevent org-element-at-point warning in minibuffer.
  ;; org-appear uses org-element functions that error in non-Org buffers.
  (defun my/org-appear--guard (orig-fn &rest args)
    "Only run ORIG-FN in an Org buffer."
    (when (derived-mode-p 'org-mode)
      (apply orig-fn args)))
  (advice-add 'org-appear--post-command :around #'my/org-appear--guard))

(defun my/org-table-shorten-urls ()
  "In the current Org table row, replace raw URLs >40 chars with [[url][label]].
Prompts for a short label per URL."
  (interactive)
  (unless (org-at-table-p)
    (user-error "Not inside an Org table"))
  (save-excursion
    (let ((row-beg (line-beginning-position))
          (row-end (line-end-position)))
      (goto-char row-beg)
      (while (re-search-forward "https?://[^[:space:]|\\n]+" row-end t)
        (let* ((url (match-string 0))
               (beg (match-beginning 0))
               (end (match-end 0)))
          (when (> (length url) 40)
            (let ((label (read-string
                          (format "Label for URL (%d chars): "
                                  (length url))
                          (if (string-match "https?://\\([^/]+\\)" url)
                              (match-string 1 url)
                            "link"))))
              (goto-char beg)
              (delete-region beg end)
              (insert (format "[[%s][%s]]" url label))
              (setq row-end (line-end-position)))))))))

;; ── 3. org-ql (structured queries over Org headlines) ──────────────────
(use-package org-ql
  :ensure t
  :after org
  :bind (("C-c o q" . org-ql-search)
         ("C-c o v" . org-ql-view))
  :config
  ;; Predefined view: active headings by tag
  (setq org-ql-views
        '(("Active by tag :math"
           :buffers-files org-agenda-files
           :query (and (tags "math")
                       (not (todo "DONE")))
           :sort (todo priority date)
           :super-groups ((:auto-property "project")))
          ("Research papers"
           :buffers-files org-agenda-files
           :query (tags "paper")
           :sort (-date)
           :narrow t))))

;; ── 4. org-transclusion (include other files inline) ─────────────────
(use-package org-transclusion
  :ensure t
  :after org
  :bind (("C-c n t" . org-transclusion-add)
         ("C-c n T" . org-transclusion-mode))
  :config
  (setq org-transclusion-include-first-section nil)
  (setq org-transclusion-indent nil))

;; ── 5. Org-roam v2 (Second Brain) ───────────────────────────────────
(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/org/roam/"))
  (org-roam-completion-everywhere t)
  (org-roam-db-location (expand-file-name "~/.emacs.d/org-roam.db"))
  :bind (("C-c n l"   . org-roam-buffer-toggle)
         ("C-c n f"   . org-roam-node-find)
         ("C-c n i"   . org-roam-node-insert)
         ("C-c n r"   . org-roam-node-random)
         ("C-c n c"   . org-roam-capture)
         ("C-c n g"   . org-roam-graph)
         ("C-c n s"   . my/org-roam-search-by-current-tag)
         ("C-c n ."   . my/org-roam-insert-by-current-tag)
         ("C-c n #"   . my/org-roam-ql-by-current-tag))
  :config
  ;; Org-roam DB autosync — SKIP on Windows first run (blocks startup).
  ;; Run `M-x org-roam-db-sync` manually after startup, or sync when idle.
  (unless (eq system-type 'windows-nt)
    (org-roam-db-autosync-mode))

  ;; Suppress spurious "Invalid ref" warnings from table content (e.g. "2x2")
  ;; org-roam parses Org syntax and mistakes table cell content for refs.
  (advice-add 'org-roam-warn :around
              (lambda (orig-fn fmt &rest args)
                (unless (string-match-p "Invalid ref" (apply #'format fmt args))
                  (apply orig-fn fmt args)))))

;; Org-roam UI (knowledge graph in browser)
(use-package org-roam-ui
  :ensure t
  :after org-roam
  :init
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

;; Org-roam-bibtex (tie roam nodes to biblio entries)
;; DISABLED: orb-autoloads missing on Windows install; enable manually after org-ref works.
;; (use-package org-roam-bibtex
;;   :ensure t
;;   :after (org-roam org-ref))

;; ── 6. Bibliography & PDF ────────────────────────────────────────────
(use-package org-ref
  :ensure t
  :after org
  :config
  (setq org-ref-default-bibliography '("~/org/references.bib"))
  (setq org-ref-pdf-directory "~/org/papers/")
  ;; Fix for "no PDF viewer found" on Windows
  (setq bibtex-completion-pdf-open-function
        (lambda (fpath)
          (call-process "explorer.exe" nil 0 nil fpath))))

(use-package pdf-tools
  :ensure t
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  ;; Skip epdfinfo build on Windows (hangs); pdf-view still works
  (unless (eq system-type 'windows-nt)
    (pdf-tools-install))
  (setq pdf-cache-image-limit 8
        pdf-view-use-scaling t))

;; ── 7. Jupyter (emacs-jupyter via org-babel) ─────────────────────────
(use-package jupyter
  :ensure t
  :after org)

;; ── 8. CSV / ESS (R) / data helpers / orgtbl-aggregate ──────────────
(use-package csv-mode  :ensure t)
(use-package ess       :ensure t)

;; Mermaid diagrams: only enable babel support if mmdc CLI is available.
;; Install via: npm install -g @mermaid-js/mermaid-cli
;; NOTE: mermaid babel registration is handled in the consolidated babel block
;; above. This section only sets the CLI path for ob-mermaid.
(use-package ob-mermaid
  :ensure t
  :after org
  :config
  (when-let ((mmdc (or (executable-find "mmdc")
                       (executable-find "mmdc.exe"))))
    (setq ob-mermaid-cli-path mmdc)
    (message "[ob-mermaid] CLI found: %s" mmdc))
  (unless ob-mermaid-cli-path
    (message "[ob-mermaid] mmdc not found. Install: npm install -g @mermaid-js/mermaid-cli")))

;; orgtbl-aggregate: build summary / pivot tables from Org tables
(use-package orgtbl-aggregate
  :ensure t
  :after org
  :config
  ;; Example: select tags, count papers per tag
  (setq orgtbl-aggregate-default-columns 80))

;; ── 9. Global hook: ensure roam DB stays healthy ──────────────────────
(add-hook 'org-roam-find-file-hook
          (lambda ()
            (setq-local org-id-link-to-org-use-id t)))

;; ════════════════════════════════════════════════════════════════════════
;; RSS: Elfeed (feeds read inside Emacs)
;; ════════════════════════════════════════════════════════════════════════
;; C-c r e    elfeed  (open feed reader)
;; C-c r u    elfeed-update
;; C-c r s    elfeed-search-live-filter

;; Define C-c r as feed prefix (was C-c f, moved to avoid conflict with FPGA)
(define-prefix-command 'my/feed-prefix)
(global-set-key (kbd "C-c r") 'my/feed-prefix)

(use-package elfeed
  :ensure t
  :init
  (setq elfeed-db-directory (expand-file-name "~/org/elfeed/"))
  (setq elfeed-search-filter "+unread @4-weeks-ago")
  :bind (:map my/feed-prefix
              ("e" . elfeed)
              ("u" . elfeed-update)
              ("s" . elfeed-search-live-filter)
              ("b" . elfeed-search-set-filter)))

;; Configure Elfeed via an Org file: headings = feeds, tags = categories
(use-package elfeed-org
  :ensure t
  :after (elfeed org)
  :init
  (setq rmh-elfeed-org-files (list (expand-file-name "~/org/elfeed.org")))
  (setq rmh-elfeed-org-tree-id "elfeed")
  :config
  (elfeed-org))

;; ════════════════════════════════════════════════════════════════════════
;; VISUAL-LINE-MODE: wrap long prose, truncate tables
;; ════════════════════════════════════════════════════════════════════════
;;
;; PROBLEM: visual-line-mode wraps ALL lines, including table rows.
;; When a table row wraps, the | pipes don't align → broken table grid.
;;
;; SOLUTION: reactive truncation. When point is INSIDE a table, enable
;; truncate-lines so pipes stay aligned. When in prose, disable it so
;; long sentences wrap naturally. This runs on post-command-hook and is
;; very cheap (org-at-table-p is a simple regex check).

(defun my/org-table-truncate-toggle ()
  "Switch between truncate (in tables) and wrap (in prose).
Runs on `post-command-hook' in Org buffers."
  (when (derived-mode-p 'org-mode)
    (let ((in-table (org-at-table-p)))
      ;; Only update when state changes (avoid unnecessary redraws)
      (cond
       (in-table
        (unless truncate-lines
          (setq-local truncate-lines t)
          (setq-local word-wrap nil)))
       (t
        (when truncate-lines
          (setq-local truncate-lines nil)
          (setq-local word-wrap t)))))))

(add-hook 'org-mode-hook
          (lambda ()
            (visual-line-mode 1)
            (setq word-wrap t)
            ;; Reactive: truncate in tables, wrap in prose
            (add-hook 'post-command-hook #'my/org-table-truncate-toggle nil t)))
(setq visual-fill-column-width 80)  ; overridden in custom-post-adhd-focus.el
(setq visual-fill-column-center-text t)

;; Avoid "Can't guess python-indent-offset" warning on Windows
(setq python-indent-offset 4)

;; ════════════════════════════════════════════════════════════════════════
;; ORG-REMARK ADVANCED: heavy highlighting + margin notes
;; ════════════════════════════════════════════════════════════════════════
;; org-remark is already installed above.  Add advanced config here:

;; Define custom faces BEFORE org-remark loads (org-remark 1.3.0 only
;; provides `org-remark-highlighter' and `org-remark-highlighter-warning').
(defface org-remark-yellow-highlight
  '((t :background "#f5e6a0" :foreground "#1a1a1a" :extend t))
  "Custom yellow highlighter pen for org-remark.")

(defface org-remark-green-highlight
  '((t :background "#a8f0a8" :foreground "#1a1a1a" :extend t))
  "Custom green highlighter pen for org-remark.")

(defface org-remark-pink-highlight
  '((t :background "#f5b0c8" :foreground "#1a1a1a" :extend t))
  "Custom pink highlighter pen for org-remark.")

(with-eval-after-load 'org-remark
  ;; Make highlights visible in every major mode
  (setq org-remark-highlight-always-visible t)
  ;; Use property drawers (marginalia) for notes — no inline noise
  (setq org-remark-use-property-drawer t)
  ;; Allow multiple highlights on the same line
  (setq org-remark-highlights-in-region t)
  ;; Export highlights as annotations list
  (defun my/org-remark-export-highlights ()
    "Export all highlights in current buffer as an Org list."
    (interactive)
    (let ((notes (org-remark-notes-get-buffer)))
      (if notes
          (with-current-buffer (get-buffer-create "*Remark Export*")
            (erase-buffer)
            (insert "#+title: Extracted Highlights\n\n")
            (dolist (note notes)
              (insert (format "- *%s*\n   %s\n"
                              (plist-get note :title)
                              (or (plist-get note :body) ""))))
            (org-mode)
            (pop-to-buffer (current-buffer)))
        (message "No highlights found in buffer.")))))

;; ════════════════════════════════════════════════════════════════════════
;; TAG-BASED ORG-ROAM WORKFLOW

(defun my/org-get-current-tags ()
  "Return the tag list from the heading at point (or empty list)."
  (save-excursion
    (when (org-at-heading-p)
      (append (org-get-tags nil t)
              (org-get-tags)))))

(defun my/org-roam-search-by-current-tag ()
  "Read tags of current heading, pick one, list all org-roam nodes with it."
  (interactive)
  (require 'org-roam)
  (let* ((tags (my/org-get-current-tags))
         (chosen
          (if (= (length tags) 0)
              (completing-read "Tag (no tags on heading): "
                               (org-roam-tag-completions))
            (completing-read "Search org-roam by tag: " tags nil t
                             nil nil (car tags))))
         (nodes
          (seq-filter
           (lambda (node)
             (member chosen (org-roam-node-tags node)))
           (org-roam-node-list))))
    (if nodes
        (let* ((titles (mapcar #'org-roam-node-title nodes))
               (pick (completing-read
                      (format "Nodes tagged :%s: (%d found) "
                              chosen (length nodes))
                      titles nil t)))
          (when pick
            (let ((node
                   (cl-find-if (lambda (n)
                                 (string= pick (org-roam-node-title n)))
                               nodes)))
              (org-roam-node-visit node))))
      (message "No org-roam nodes found with tag: :%s:" chosen))))

(defun my/org-roam-insert-by-current-tag ()
  "Read tags of current heading, pick one, insert link to chosen node."
  (interactive)
  (require 'org-roam)
  (let* ((tags (my/org-get-current-tags))
         (chosen
          (if (= (length tags) 0)
              (completing-read "Tag (no tags on heading): "
                               (org-roam-tag-completions))
            (completing-read "Insert link by tag: " tags nil t
                             nil nil (car tags))))
         (nodes
          (seq-filter
           (lambda (node)
             (member chosen (org-roam-node-tags node)))
           (org-roam-node-list))))
    (if nodes
        (let* ((titles (mapcar #'org-roam-node-title nodes))
               (pick (completing-read
                      (format "Link to node tagged :%s: (%d found) "
                              chosen (length nodes))
                      titles nil t)))
          (when pick
            (let ((node
                   (cl-find-if (lambda (n)
                                 (string= pick (org-roam-node-title n)))
                               nodes)))
              (insert (org-link-make-string
                       (concat "id:" (org-roam-node-id node))
                       pick)))))
      (message "No org-roam nodes found with tag: :%s:" chosen))))

(defun my/org-roam-ql-by-current-tag ()
  "Run org-ql search across agenda files filtered by any tag on current heading."
  (interactive)
  (let ((tags (my/org-get-current-tags)))
    (if (= (length tags) 0)
        (message "Current heading has no tags.")
      (let ((chosen (completing-read "org-ql by tag: " tags nil t
                                    nil nil (car tags))))
        (org-ql-search
         org-agenda-files
         `(tags ,chosen)
         :sort '(todo priority date))))))

;; ── 10. org-ref + citar (modern citation frontend) ───────────────────
(use-package citar
  :ensure t
  :after org
  :bind (:map org-mode-map
              ("C-c o b" . citar-insert-citation)
              ("C-c o B" . citar-open))
  :config
  (setq citar-bibliography '("~/org/references.bib")))

;; ════════════════════════════════════════════════════════════════════════
;; WEB CAPTURE: org-web-tools + org-remark
;; ════════════════════════════════════════════════════════════════════════
;;
;;  C-c w o    org-web-tools-read-url-as-org       → URL → Org buffer
;;  C-c w i    org-web-tools-insert-web-page-as-entry → Insert at point
;;  C-c w a    my/capture-web-page                 → Save + open + annotate
;;  C-c w m    org-remark-mode                     → Toggle annotation
;;  C-c w h    org-remark-mark                     → Highlight selection
;;  C-c w r    org-remark-remove                   → Remove highlight
;;  C-c w n    org-remark-open                     → Show margin notes
;;
;;  Requires: curl (for org-web-tools), pandoc (optional fallback)

;; Define C-c w as a prefix key BEFORE any sub-bindings
(define-prefix-command 'my/web-prefix)
(global-set-key (kbd "C-c w") 'my/web-prefix)

;; ── org-web-tools: fetch URL → readable Org ──────────────────────────
(use-package org-web-tools
  :ensure t
  :after org
  :init
  (setq org-web-tools-archive-directory "~/org/web-archive/"))

;; ── org-remark: highlight & annotate any Org file ────────────────────
;;   Highlights persist as property drawers in a side "margin notes" file.
(use-package org-remark
  :ensure t
  :after org
  :init
  ;; Auto-load margin-notes when opening annotated files
  (org-remark-global-tracking-mode +1)
  :config
  ;; NOTE: org-remark-notes-get-file-name calls this with 0 args in
  ;; org-remark 1.3.0, so the parameter must be optional.
  (setq org-remark-notes-file-name
        (lambda (&optional _filename)
          (expand-file-name "~/org/margin-notes.org"))))

;; Define sub-keymap under the C-c w prefix
(define-key my/web-prefix (kbd "o") #'org-web-tools-read-url-as-org)
(define-key my/web-prefix (kbd "i") #'org-web-tools-insert-web-page-as-entry)
(define-key my/web-prefix (kbd "m") #'org-remark-mode)
(define-key my/web-prefix (kbd "h") #'org-remark-mark)
(define-key my/web-prefix (kbd "r") #'org-remark-remove)
(define-key my/web-prefix (kbd "n") #'org-remark-open)
(define-key my/web-prefix (kbd "p") #'org-remark-prev)
(define-key my/web-prefix (kbd "s") #'org-remark-next)

;; ── org-remark extra: auto-enable on Org files ─────────────────────────
;; Turn on org-remark-mode in every Org file for instant annotation.
;; (Remove this hook if you prefer to toggle manually with C-c w m.)
;;
;; Uncomment the next line to auto-enable:
;; (add-hook 'org-mode-hook #'org-remark-mode)

;; ── Capture workflow: URL → save → annotate ──────────────────────────
(defun my/capture-web-page ()
  "Prompt for URL, fetch via org-web-tools, save to ~/org/web-archive/.
Opens the new file with `org-remark-mode' enabled for annotation."
  (interactive)
  (let* ((url (read-string "URL to capture: "
                           (when (string-match-p "^https?://"
                                                 (or (car kill-ring) ""))
                             (car kill-ring))))
         (raw-title (ignore-errors (org-web-tools--get-url-title url)))
         (title (read-string "Title for this capture: "
                             (or raw-title "Untitled")))
         (date (format-time-string "%Y-%m-%d"))
         (slug (replace-regexp-in-string
                "[^a-z0-9]" "-" (downcase title)))
         (outdir (expand-file-name "~/org/web-archive/"))
         (outfile (expand-file-name
                   (format "%s-%s.org" date slug) outdir)))
    ;; Ensure directory exists
    (make-directory outdir t)
    ;; Fetch and convert body
    (let ((body (condition-case err
                    (org-web-tools--url-as-readable-org url)
                  (error
                   (message "Fetch failed: %s" (error-message-string err))
                   ""))))
      (with-temp-file outfile
        (insert (format "#+title: %s\n" title))
        (insert (format "#+date: %s\n" date))
        (insert (format "#+source_url: %s\n" url))
        (insert "#+tags: :web:captured:\n\n")
        (insert body)
        (insert "\n\n")))
    ;; Open and enable annotation
    (find-file outfile)
    (org-remark-mode 1)
    (message "Captured to %s — C-c w h to highlight, C-c w n for notes"
             (abbreviate-file-name outfile))))

;; Define capture under the prefix
(define-key my/web-prefix (kbd "a") #'my/capture-web-page)

;; ── org-capture template for web articles ──────────────────────────────
(with-eval-after-load 'org-capture
  (add-to-list
   'org-capture-templates
   '("w" "Web page / Article" entry
     (file+olp "~/org/inbox.org" "Web captures")
     "* %^{Title} :web:\n  :PROPERTIES:\n  :URL: %^{URL}\n  :DATE: %U\n  :END:\n\n%?\n"
     :empty-lines 1)))

;; ── Pandoc fallback: convert local HTML → Org ─────────────────────────
(defun my/html-to-org (html-file)
  "Convert HTML-FILE to Org via pandoc and insert into current buffer.
Requires pandoc: https://pandoc.org/installing.html"
  (interactive (list (read-file-name "HTML file: ")))
  (unless (executable-find "pandoc")
    (user-error "pandoc not found. Install via: winget install JohnMacFarlane.Pandoc"))
  (let ((org-out (make-temp-file "pandoc-org-")))
    (call-process "pandoc" nil nil nil
                  "-f" "html" "-t" "org"
                  "-o" org-out
                  (expand-file-name html-file))
    (insert-file-contents org-out)
    (delete-file org-out)
    (message "Inserted %s as Org via pandoc" html-file)))

;; ════════════════════════════════════════════════════════════════════════
;; ORG TABLE PRETTIFICATION: C-c t prefix
;; ════════════════════════════════════════════════════════════════════════

(define-prefix-command 'my/table-prefix)
(global-set-key (kbd "C-c t") 'my/table-prefix)

;; â”€â”€ org-pretty-table: box-drawing borders (not on MELPA, manual install) â”€
;; Download: https://github.com/Fuco1/org-pretty-table/raw/master/org-pretty-table.el
;; into site-lisp/org-pretty-table.el, then this block will activate.
(add-to-list 'load-path (expand-file-name "site-lisp" user-emacs-directory))
(use-package org-pretty-table
  :ensure nil
  :after org
  :if (locate-library "org-pretty-table")
  :hook (org-mode . org-pretty-table-mode)
  :bind (:map my/table-prefix
              ("p" . org-pretty-table-mode)))

;; ── valign: vertical-align mixed-content cells ──────────────────────
;; Aligns images / LaTeX fragments so row heights stay uniform.
(use-package valign
  :ensure t
  :after org
  :hook (org-mode . valign-mode)
  :config
  (setq valign-fancy-bar t)     ; use bar separator, not space
  (setq valign-separator-width 1))

;; ── org-appear for table formula symbols ──────────────────────────────
(with-eval-after-load 'org-appear
  (setq org-appear-autoentities t)
  (setq org-appear-autosubmarkers t))

;; ── Table helpers ───────────────────────────────────────────────────
(defun my/org-table-wrap-cell (width)
  "Wrap the current table cell to WIDTH columns using `fill-region'.
Inserts line-breaks inside the cell so the column stays narrow."
  (interactive "nWrap cell to width: ")
  (unless (org-at-table-p)
    (user-error "Not inside an Org table"))
  (let* ((field (org-table-get-field))
         (beg (car field))
         (end (cdr field))
         (fill-column width))
    (save-excursion
      (narrow-to-region beg end)
      (fill-region beg end)
      (widen))
    (org-table-align)))

(defun my/org-table-pretty-align ()
  "Re-align the current table, then optionally toggle pretty borders."
  (interactive)
  (org-table-align)
  (when (fboundp 'org-pretty-table-mode)
    (org-pretty-table-mode 1))
  (message "Table aligned & prettified"))

(defun my/org-table-toggle-pretty ()
  "Toggle between raw ASCII table and rendered pretty table."
  (interactive)
  (if (not (fboundp 'org-pretty-table-mode))
      (message "org-pretty-table not installed")
    (if (bound-and-true-p org-pretty-table-mode)
        (progn (org-pretty-table-mode -1)
               (message "Raw table"))
      (org-pretty-table-mode 1)
      (message "Pretty table"))))

;; Bind helpers under C-c t
(define-key my/table-prefix (kbd "a") #'my/org-table-pretty-align)
(define-key my/table-prefix (kbd "w") #'my/org-table-wrap-cell)
(define-key my/table-prefix (kbd "t") #'my/org-table-toggle-pretty)
(define-key my/table-prefix (kbd "s") #'my/org-table-shorten-urls)

;; ════════════════════════════════════════════════════════════════════════
;; YANK-MEDIA: paste images from clipboard into Org files
;; ════════════════════════════════════════════════════════════════════════
;; Emacs 29+ has `yank-media' but Org-mode doesn't register a handler.
;; This registers one so Ctrl+V pastes images as [[file:...]] links.
;;
;; CRITICAL: `yank-media-handler' sets a BUFFER-LOCAL variable.
;; If called once in `with-eval-after-load', it only registers in the
;; buffer that was current when org loaded (typically *scratch*), NOT in
;; Org buffers.  We must register in org-mode-hook so every Org buffer
;; gets the handler.
(when (>= emacs-major-version 29)
  (defun my/org-yank-image-handler (type data)
    "Handle pasted image data of TYPE from clipboard into Org.
DATA is the raw image bytes.  Prompts for a save location,
writes the file, and inserts an Org link."
    (let* ((ext (cond
                 ((string-match-p "png" type) ".png")
                 ((string-match-p "jpeg\\|jpg" type) ".jpg")
                 ((string-match-p "gif" type) ".gif")
                 ((string-match-p "webp" type) ".webp")
                 (t ".png")))
           (default-dir (if (buffer-file-name)
                            (expand-file-name
                             "images/"
                             (file-name-directory (buffer-file-name)))
                          (expand-file-name "~/org/images/")))
           (default-name (format "pasted-%s%s"
                                 (format-time-string "%Y%m%d-%H%M%S")
                                 ext))
           (file (read-file-name "Save image to: "
                                 default-dir nil nil default-name)))
      (make-directory (file-name-directory file) t)
      (with-temp-file file
        (set-buffer-multibyte nil)
        (insert data))
      (insert (format "[[file:%s]]\n" (file-relative-name
                                        file
                                        (file-name-directory
                                         (or (buffer-file-name) default-dir)))))
      (message "Image saved: %s" file)))

  (defun my/org-register-yank-media-handler ()
    "Register yank-media image handler in the current Org buffer.
Must run in `org-mode-hook' because `yank-media-handler' is buffer-local."
    (when (fboundp 'yank-media-handler)
      (yank-media-handler "image/.*" #'my/org-yank-image-handler)))

  (add-hook 'org-mode-hook #'my/org-register-yank-media-handler))

;; ════════════════════════════════════════════════════════════════════════
;;  Summary: Web capture keymap
;; ════════════════════════════════════════════════════════════════════════
;;
;;  C-c w o    org-web-tools-read-url-as-org       → URL → temporary Org buffer
;;  C-c w i    org-web-tools-insert-web-page-as-entry → Insert page at point
;;  C-c w a    my/capture-web-page                 → Save, open, annotate
;;  C-c w m    org-remark-mode                     → Toggle annotation mode
;;  C-c w h    org-remark-mark                     → Highlight selection
;;  C-c w r    org-remark-remove                   → Remove highlight
;;  C-c w n    org-remark-open                     → Open margin notes file
;;  C-c w p    org-remark-prev                     → Previous highlight
;;  C-c w s    org-remark-next                     → Next highlight
;;
;;  C-c C-c    (on #+begin_ai block)               → Run org-ai
;;  C-c a g    gptel-menu                          → Multi-backend chat
;;  C-c a m    → MiniMax / C-c a o → OpenCode Go / C-c a 4 → GPT-4o
;;  C-c n s    → Tag based roam search              → C-c n . → Tag based roam insert

;;; custom-post-data.el ends here
