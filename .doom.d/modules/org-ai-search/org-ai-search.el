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

(defun org-ai-search-execute ()
  "Execute the discovery table at point."
  (interactive)
  (unless (org-at-table-p)
    (user-error "Not on a table"))
  (let* ((discovery (org-ai-search--parse-discovery-table))
         (backend (or (plist-get discovery :backend) "semantic-scholar"))
         (count (or (plist-get discovery :count) "10"))
         (headers (plist-get discovery :headers))
         (rows (plist-get discovery :rows))
         (json-rows nil))
    ;; Build JSON rows
    (dolist (row rows)
      (let ((query (cdr (assoc "QUERY" row)))
            (params nil)
            (row-backend nil)
            (row-count nil))
        (dolist (cell row)
          (let ((k (car cell))
                (v (cdr cell)))
            (cond
             ((equal k "QUERY") nil)
             ((equal k "Backend") (setq row-backend v))
             ((equal k "Count") (setq row-count v))
             ((and v (not (string= v ""))) (push (cons k v) params)))))
        (push `((query . ,query)
                (backend . ,(or row-backend backend))
                (count . ,(or row-count count))
                (params . ,params)
                (tags . ""))
              json-rows)))
    (let* ((req `((command . "execute")
                  (default_backend . ,backend)
                  (default_count . ,(string-to-number count))
                  (rows . ,(vconcat (nreverse json-rows)))))
           (json-str (json-encode req))
           (default-directory org-ai-search-python-module)
           (process-environment
            (append
             (list (format "ORG_AI_S2_KEY=%s"
                           (or (condition-case nil
                                   (auth-source-pick-first-password :host "api.semanticscholar.org")
                                 (error nil))
                               ""))
                   (format "ORG_AI_GITHUB_TOKEN=%s"
                           (or (condition-case nil
                                   (auth-source-pick-first-password :host "api.github.com")
                                 (error nil))
                               "")))
             process-environment))
           (output
            (with-temp-buffer
              (let ((status
                     (call-process-region json-str nil
                                          org-ai-search-python-executable
                                          nil t nil
                                          "-m" "org_ai_search")))
                (if (eq status 0)
                    (buffer-string)
                  (error "Python bridge failed: %s" (buffer-string))))))
           (result (json-read-from-string output)))
      (if (assoc 'error result)
          (message "org-ai-search error: %s" (cdr (assoc 'error result)))
        (org-ai-search--render-output-table result)
        (message "Search complete: %d results"
                 (length (cdr (assoc 'rows result))))))))

(provide 'org-ai-search)
;;; org-ai-search.el ends here
