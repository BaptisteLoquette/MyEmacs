;; ~/.doom.d/packages.el — add these packages
(package! ob-mermaid)
(package! graphviz-dot-mode)
(package! org-inline-anim)

;; ~/.doom.d/config.el — add these configs
(use-package! ob-mermaid
  :after org
  :config
  (setq ob-mermaid-cli-path "mmdc"))

(use-package! graphviz-dot-mode
  :mode ("\\.dot\\'" "\\.gv\\'")
  :config
  (setq graphviz-dot-preview-extension "png")
  (setq graphviz-dot-preview-command "dot -Tpng %s -o %s.png"))

(use-package! org-inline-anim
  :after org
  :config
  (setq org-inline-anim-max-size 10485760))  ; 10 MB

;; Org-babel languages
(after! org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (dot . t)
     (gnuplot . t)
     (mermaid . t))))

;; Shared header for Python blocks
(setq org-babel-default-header-args:python
      '((:results . "file")
        (:exports . "both")
        (:prologue . "exec(open('C:/Users/Bapti/.emacs.d/header.py').read())")))
(setq org-startup-with-inline-images t)
