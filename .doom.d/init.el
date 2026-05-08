;; -*- mode: emacs-lisp; -*-
;; Doom Emacs init.el — Ultimate Emacs Org Setup
;; Stage 1: Core Editing & Scientific Computing

(doom! :input
       ;; (layout +azerty)   ; uncomment if French AZERTY

        :completion
        (vertico +icons)
        company

        :ui
        doom
        doom-dashboard
        doom-modeline
        treemacs
        vc-gutter
        workspaces

        :editor
        evil
        file-templates
        fold
        multiple-cursors

        :emacs
        (dired +icons)
        electric
        (ibuffer +icons)
        undo
        vc

        :term
        vterm

        :checkers
        syntax
        spell

        :tools
        (eval +overlay)
        lookup
        (lsp +peek)
        magit
        pdf

        :lang
        (org +roam2 +noter +present +jupyter)
        (python +lsp +pyright +conda)
        (julia +lsp +snail)
        (latex +fold)
        (sh +fish)
        data
        (emacs-lisp +lsp)
        markdown

        :config
        (default +bindings +smartparens))

;; Show inline images automatically when opening Org files.
;; Wrapped in (after! org) so it only evals once Org is loaded — zero
;; risk of undefined-variable errors at startup.
(after! org
  (setq org-startup-with-inline-images t))
