;;; custom-post-pkm.el --- PKM & Note-taking enhancements -*- lexical-binding: t no-byte-compile: t -*-

;;; Commentary:
;;; Complements Centaur's org-modern + org-appear with additional PKM tools:
;;;   - Denote (filesystem-based note organisation, signpost naming)
;;;   - org-brain (concept maps, The Brain style)
;;;   - svg-tag-mode (coloured visual tags inline)
;;;   - org-side-tree (outline sidebar)
;;;   - org-fragtog (LaTeX preview auto-toggle)
;;;   - org-noter (PDF annotation alongside Org notes)
;;;
;;; Keymaps:
;;;   C-c p d  → denote  |  C-c p b  → org-brain-visualize
;;;   C-c p t  → svg-tag |  C-c p s  → org-side-tree

;;; Code:

;; Define PKM prefix map BEFORE use-package bindings
(define-prefix-command 'my/pkm-map)
(global-set-key (kbd "C-c p") 'my/pkm-map)

;; ── Denote: filesystem-first note management ─────────────────────────
;; Signpost naming: 20240101T120000--title__tag1_tag2.org
(use-package denote
  :ensure t
  :after org
  :init
  (setq denote-directory (expand-file-name "~/org/denote/"))
  (setq denote-known-keywords '("research" "idea" "draft" "paper" "meeting" "todo"))
  (setq denote-file-type 'org)
  :bind (:map my/pkm-map
              ("d" . denote)
              ("D" . denote-open-or-create)
              ("r" . denote-rename-file)
              ("l" . denote-link)
              ("L" . denote-backlinks)))

;; ── org-brain: concept maps (The Brain style) ────────────────────────
;; Visual hierarchical knowledge graph.
(use-package org-brain
  :ensure t
  :after org
  :init
  (setq org-brain-path (expand-file-name "~/org/brain/"))
  (setq org-id-track-globally t)
  ;; org-id-locations-file is set in custom-post-data.el — no duplicate needed
  :bind (("C-c p b" . org-brain-visualize)
         :map org-mode-map
         ("C-c p i" . org-brain-insert-resource))
  :config
  ;; Speed up: don't ask for a headline every time
  (setq org-brain-include-file-entries t)
  (setq org-brain-file-entries-use-title t))

;; ── svg-tag-mode: colourful inline visual tags ──────────────────────
;; Turns :tag: into a styled pill badge in Org headings.
(use-package svg-tag-mode
  :ensure t
  :after org
  :hook (org-mode . svg-tag-mode)
  :config
  (setq svg-tag-tags
        '((":TODO:"  . (lambda () (svg-tag-make "TODO"  :face 'warning :radius 4 :inverse t)))
          (":DONE:"  . (lambda () (svg-tag-make "DONE"  :face 'success :radius 4 :inverse t)))
          (":IDEA:"  . (lambda () (svg-tag-make "IDEA"  :face 'highlight :radius 4 :inverse t)))
          (":PAPER:" . (lambda () (svg-tag-make "PAPER" :face 'info :radius 4 :inverse t)))
          (":DRAFT:" . (lambda () (svg-tag-make "DRAFT" :face 'org-todo :radius 4 :inverse t))))))

;; ── org-side-tree: persistent outline sidebar ───────────────────────
(use-package org-side-tree
  :ensure t
  :after org
  :bind (("C-c p s" . org-side-tree)))

;; ── org-fragtog: auto-toggle LaTeX preview ──────────────────────────
;; Cursor enters a fragment → preview it. Leaves → revert to source.
(use-package org-fragtog
  :ensure t
  :after org
  :hook (org-mode . org-fragtog-mode)
  :config
  ;; Centaur already enables org-latex-preview; fragtog makes it smarter
  (setq org-fragtog-preview-delay 0.3))

;; ── org-noter: annotate PDFs alongside Org notes ────────────────────
;; Syncs PDF page ↔ Org heading. Great for paper reading workflow.
;; DISABLED on Windows: compilation has issues; re-enable after pdf-tools works.
;; (use-package org-noter
;;   :ensure t
;;   :after (org pdf-tools)
;;   :bind (("C-c p n" . org-noter)))

;; ── Denote ↔ org-roam bridge: open roam node in denote directory ───
(defun my/denote-roam-capture ()
  "Capture a new idea using Denote naming, then add to org-roam.
Useful when you want both filesystem structure (Denote) + graph (roam)."
  (interactive)
  (let ((denote-file (denote)))
    (when denote-file
      (with-current-buffer (find-file-noselect denote-file)
        (org-roam-tag-add '("denote"))
        (save-buffer)
        (message "Created %s — tagged in org-roam" denote-file)))))

(define-key my/pkm-map (kbd "c") #'my/denote-roam-capture)

(provide 'custom-post-pkm)
;;; custom-post-pkm.el ends here
