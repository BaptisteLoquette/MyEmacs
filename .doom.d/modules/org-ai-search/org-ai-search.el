;;; org-ai-search.el --- AI-powered search in org tables -*- lexical-binding: t; -*-

;; Author: You
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.0") (org "9.6"))

;;; Commentary:
;; Turn org tables into declarative search queries.

;;; Code:

(require 'org-table)
(require 'json)
(require 'org-ai-search-table)

(defgroup org-ai-search nil
  "AI-powered search in org tables."
  :group 'org
  :prefix "org-ai-search-")

(defvar org-ai-search-python-module
  (expand-file-name "python" (file-name-directory (or load-file-name buffer-file-name)))
  "Path to the Python bridge directory.")

(defvar org-ai-search-python-executable
  (or (executable-find "python3") (executable-find "python"))
  "Python executable for running the bridge.")

(defvar org-ai-search-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-s s") #'org-ai-search-execute)
    (define-key map (kbd "C-c C-s r") #'org-ai-search-refresh)
    (define-key map (kbd "C-c C-s e") #'org-ai-search-edit)
    (define-key map (kbd "C-c C-s d") #'org-ai-search-delete-stale)
    (define-key map (kbd "C-c C-s t") #'org-ai-search-tag-row)
    (define-key map (kbd "C-c C-s c") #'org-ai-search-clear-tags)
    (define-key map (kbd "C-c C-s b") #'org-ai-search-cycle-backend)
    map)
  "Keymap for `org-ai-search-mode'.")

(define-minor-mode org-ai-search-mode
  "Minor mode for AI search tables in org buffers."
  :lighter " OAS"
  :keymap org-ai-search-mode-map)

(provide 'org-ai-search)
;;; org-ai-search.el ends here
