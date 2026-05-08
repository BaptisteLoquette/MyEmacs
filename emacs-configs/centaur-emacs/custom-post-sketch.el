;;; custom-post-sketch.el --- Sketching & Drawing utilities -*- lexical-binding: t no-byte-compile: t -*-

;;; Commentary:
;;; Quick sketching and diagramming inside Emacs:
;;;   - org-excalidraw (manage Excalidraw diagrams as Org links)
;;;   - artist-mode (ASCII art with mouse / keyboard drawing)
;;;   - picture-mode (keyboard-only block drawing)
;;;   - Enhanced Mermaid / PlantUML / Ditaa via Org-Babel
;;;   - Quick diagram templates and helpers
;;;
;;; Keymaps:
;;;   C-c d e  → org-excalidraw (create/open diagram)
;;;   C-c d a  → artist-mode
;;;   C-c d p  → picture-mode
;;;   C-c d m  → insert mermaid block
;;;   C-c d u  → insert plantuml block
;;;   C-c d t  → insert ditaa block
;;;   C-c d g  → insert graphviz block

;;; Code:

;; Define sketch prefix map
(define-prefix-command 'my/sketch-prefix)
(global-set-key (kbd "C-c d") 'my/sketch-prefix)   ; d = draw / diagram

;; ════════════════════════════════════════════════════════════════════════
;; 1. org-excalidraw (virtual whiteboard diagrams)
;; ════════════════════════════════════════════════════════════════════════
;; org-excalidraw is NOT on MELPA. Install manually to site-lisp/ if desired.
;; Repo: https://github.com/wdavew/org-excalidraw
;; Requires: excalidraw_export (npm), Chrome PWA, File Handling API.
;;
;; (use-package org-excalidraw
;;   :ensure nil
;;   :after org
;;   :init
;;   (setq org-excalidraw-directory (expand-file-name "~/org/diagrams/excalidraw/"))
;;   :config
;;   (setq org-excalidraw-open-in-browser t)
;;   :bind (:map my/sketch-prefix
;;               ("e" . org-excalidraw-create-link)
;;               ("E" . org-excalidraw-open-current-link)))

;; ════════════════════════════════════════════════════════════════════════
;; 2. Artist-mode (freehand ASCII drawing with mouse/keyboard)
;; ════════════════════════════════════════════════════════════════════════
;; Built-in.  Keys:  left-drag = draw line;  S-left-drag = erase;
;;                   C-c C-a C-k = pick pen character

;; Helper to toggle artist-mode in current buffer (useful in text/org buffers)
(defun my/artist-mode-toggle ()
  "Toggle artist-mode, preserving original major mode on exit."
  (interactive)
  (if (eq major-mode 'artist-mode)
      (artist-mode -1)
    (artist-mode 1)))

;; Set pen to box-drawing characters for cleaner diagrams
(add-hook 'artist-mode-hook
          (lambda ()
            (setq artist-ellipses-char 32)
            (setq artist-fill-char 32)
            (setq artist-line-char 45)
            (setq artist-rectangle-char 35)))

(define-key my/sketch-prefix (kbd "a") #'my/artist-mode-toggle)

;; ════════════════════════════════════════════════════════════════════════
;; 3. Picture-mode (structured block/line ASCII drawing)
;; ════════════════════════════════════════════════════════════════════════
;; Built-in.  Better for precise geometric diagrams.

(defun my/picture-mode-toggle ()
  "Toggle picture-mode, restoring original mode on exit."
  (interactive)
  (if (eq major-mode 'picture-mode)
      (picture-mode-disable)
    (picture-mode)))

(define-key my/sketch-prefix (kbd "p") #'my/picture-mode-toggle)

;; ════════════════════════════════════════════════════════════════════════
;; 4. Diagram block templates (Org Babel)
;; ════════════════════════════════════════════════════════════════════════
;; One-liners to insert #+begin_src blocks for common diagram languages.

(defun my/insert-mermaid-block ()
  "Insert a Mermaid diagram source block."
  (interactive)
  (insert "#+begin_src mermaid :file diagrams/flowchart.png\n")
  (insert "graph TD\n")
  (insert "    A[Start] --> B{Decision}\n")
  (insert "    B -->|Yes| C[Action 1]\n")
  (insert "    B -->|No| D[Action 2]\n")
  (insert "#+end_src\n\n")
  (if (or (executable-find "mmdc") (executable-find "mmdc.exe")
          ob-mermaid-cli-path)
      (message "Edit the Mermaid diagram, then C-c C-c to render.")
    (message "[mermaid] mmdc not found. Install: npm install -g @mermaid-js/mermaid-cli")))

(defun my/insert-plantuml-block ()
  "Insert a PlantUML diagram source block."
  (interactive)
  (insert "#+begin_src plantuml :file diagrams/class.png\n")
  (insert "@startuml\n")
  (insert "!theme plain\n")
  (insert "skinparam style strict\n")
  (insert "class MyClass {\n")
  (insert "  +field\n")
  (insert "  +method()\n")
  (insert "}\n")
  (insert "@enduml\n")
  (insert "#+end_src\n\n"))

(defun my/insert-ditaa-block ()
  "Insert a Ditaa ASCII-to-diagram source block."
  (interactive)
  (insert "#+begin_src ditaa :file diagrams/overview.png\n")
  (insert "+--------+  +--------+\n")
  (insert "| Input  |  | Output |\n")
  (insert "|  Data  |  |  File  |\n")
  (insert "+---+----+  +----+---+\n")
  (insert "    |            ^\n")
  (insert "    +------->----+|\n")
  (insert "      Processing |\n")
  (insert "#+end_src\n\n"))

(defun my/insert-graphviz-block ()
  "Insert a Graphviz DOT source block."
  (interactive)
  (insert "#+begin_src dot :file diagrams/digraph.png\n")
  (insert "digraph G {\n")
  (insert "    rankdir=LR;\n")
  (insert "    node [shape=box];\n")
  (insert "    A -> B;\n")
  (insert "    B -> C;\n")
  (insert "}\n")
  (insert "#+end_src\n\n"))

;; Ensure diagrams output directory exists
(defun my/ensure-diagrams-dir ()
  "Create ~/org/diagrams/ if it doesn't exist."
  (interactive)
  (make-directory (expand-file-name "~/org/diagrams/") t)
  (message "Diagram directory ready: ~/org/diagrams/"))

;; Bind diagram block templates
(define-key my/sketch-prefix (kbd "m") #'my/insert-mermaid-block)
(define-key my/sketch-prefix (kbd "u") #'my/insert-plantuml-block)
(define-key my/sketch-prefix (kbd "t") #'my/insert-ditaa-block)
(define-key my/sketch-prefix (kbd "g") #'my/insert-graphviz-block)
(define-key my/sketch-prefix (kbd "D") #'my/ensure-diagrams-dir)

;; ════════════════════════════════════════════════════════════════════════
;; 5. ASCII helper: insert a box or arrow interactively
;; ════════════════════════════════════════════════════════════════════════

(defun my/insert-ascii-box (text)
  "Insert a centered ASCII box around TEXT."
  (interactive "sText for box: ")
  (let* ((len (length text))
         (border (make-string (+ len 4) ?-)))
    (insert (format "+%s+\n" border))
    (insert (format "|  %s  |\n" text))
    (insert (format "+%s+\n" border))))

(defun my/insert-ascii-arrow (direction)
  "Insert an ASCII arrow (up/down/left/right/bi)."
  (interactive
   (list (completing-read "Direction: " '("right" "left" "up" "down" "bi"))))
  (insert (pcase direction
            ("right"  " ------> ")
            ("left"   " <------ ")
            ("up"     "   ^\n   |\n   |\n")
            ("down"   "   |\n   |\n   v\n")
            ("bi"     " <---> "))))

(define-key my/sketch-prefix (kbd "b") #'my/insert-ascii-box)
(define-key my/sketch-prefix (kbd "r") #'my/insert-ascii-arrow)

;; ════════════════════════════════════════════════════════════════════════
;; 6. org-babel: diagram languages
;; ════════════════════════════════════════════════════════════════════════
;; PlantUML, Ditaa, and Graphviz (dot) are registered in the consolidated
;; babel block in custom-post-data.el. No duplicate registration here.

;; ════════════════════════════════════════════════════════════════════════
;; Summary keymap
;; ════════════════════════════════════════════════════════════════════════
;;
;;  C-c d e   org-excalidraw-create-link      → New Excalidraw diagram
;;  C-c d E   org-excalidraw-open-current-link  → Edit existing diagram
;;  C-c d a   my/artist-mode-toggle            → Freehand ASCII draw
;;  C-c d p   my/picture-mode-toggle           → Precise ASCII block draw
;;  C-c d m   my/insert-mermaid-block        → Insert Mermaid diagram
;;  C-c d u   my/insert-plantuml-block       → Insert PlantUML diagram
;;  C-c d t   my/insert-ditaa-block          → Insert Ditaa diagram
;;  C-c d g   my/insert-graphviz-block       → Insert Graphviz DOT diagram
;;  C-c d b   my/insert-ascii-box            → Insert ASCII box
;;  C-c d r   my/insert-ascii-arrow          → Insert ASCII arrow
;;  C-c d D   my/ensure-diagrams-dir         → Create diagrams folder

(provide 'custom-post-sketch)
;;; custom-post-sketch.el ends here
