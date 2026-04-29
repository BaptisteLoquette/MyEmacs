;; -*- no-byte-compile: t; -*-
;; Extra packages beyond Doom modules

;; PKM
(package! org-roam-ui)
(package! org-roam-bibtex)
(package! org-ql)

;; Literature
(package! org-ref)
(package! elfeed)
(package! org-noter)
(package! pdf-tools)

;; Diagrams
(package! graphviz-dot-mode)
(package! ob-mermaid)

;; ASCII / Unicode Drawing
(package! uniline)

;; Embedded SVG Drawing
(package! edraw-org
  :recipe (:host github :repo "misohena/el-easydraw" :files ("*.el" "*.svg")))
(package! sketch-mode)

;; Animation & Video
(package! org-inline-anim)
(package! svg-lib)

;; Visualization & Plots
;; ob-gnuplot is built into modern org-mode (obsoleted on MELPA)
;; (package! ob-gnuplot)
;; ob-ipython is superseded by built-in ob-jupyter
;; (package! ob-ipython)

;; AI Assistants
(package! gptel)
(package! org-ai)
(package! aider
  :recipe (:host github :repo "tninja/aider.el" :files ("*.el" "snippets")))
(package! ellama)
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))

;; Org-AI-Search (local)
(package! org-ai-search
  :recipe (:local-repo "modules/org-ai-search"
           :files (:defaults "python" "python/**/*")))
