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
