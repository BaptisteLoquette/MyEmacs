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
  (or (executable-find "python3")
      (executable-find "python")
      (when (eq system-type 'windows-nt)
        "C:/Users/Bapti/AppData/Local/Programs/Python/Python312/python.exe")
      "python")
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

(defun org-ai-search--build-request (discovery)
  "Build JSON request alist from DISCOVERY plist."
  (let* ((backend (or (plist-get discovery :backend) "semantic-scholar"))
         (count (or (plist-get discovery :count) "10"))
         (rows (plist-get discovery :rows))
         (json-rows nil))
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
    `((command . "execute")
      (default_backend . ,backend)
      (default_count . ,(string-to-number count))
      (rows . ,(vconcat (nreverse json-rows))))))

(defun org-ai-search--run-search (req)
  "Send REQ to Python bridge and return parsed result alist."
  (let* ((json-str (json-encode req))
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
                (error "Python bridge failed: %s" (buffer-string)))))))
    (json-read-from-string output)))

(defun org-ai-search-execute ()
  "Execute the discovery table at point."
  (interactive)
  (unless (org-at-table-p)
    (user-error "Not on a table"))
  (let* ((discovery (org-ai-search--parse-discovery-table))
         (req (org-ai-search--build-request discovery))
         (result (org-ai-search--run-search req)))
    (if (assoc 'error result)
        (message "org-ai-search error: %s" (cdr (assoc 'error result)))
      (org-ai-search--render-output-table result)
      (message "Search complete: %d results"
               (length (cdr (assoc 'rows result)))))))

(defun org-ai-search-tag-row ()
  "Tag the current output table row."
  (interactive)
  (unless (org-at-table-p)
    (user-error "Not on a table"))
  (let* ((current (org-table-get-field))
         (tags (read-string "Tags (e.g. :research:priority:): " current)))
    (org-table-put (org-table-current-dline) 1 tags)
    (org-table-align)))

(defun org-ai-search-clear-tags ()
  "Clear tags on current output table row."
  (interactive)
  (unless (org-at-table-p)
    (user-error "Not on a table"))
  (org-table-put (org-table-current-dline) 1 "")
  (org-table-align))

(defvar org-ai-search-backends
  '("semantic-scholar" "arxiv" "github")
  "List of available backends.")

(defun org-ai-search-cycle-backend ()
  "Cycle the default backend for the current heading."
  (interactive)
  (org-back-to-heading)
  (let* ((current (or (org-ai-search--get-property "AI_SEARCH_BACKEND")
                      (car org-ai-search-backends)))
         (next (or (cadr (member current org-ai-search-backends))
                   (car org-ai-search-backends))))
    (org-ai-search--set-property "AI_SEARCH_BACKEND" next)
    (message "Backend set to: %s" next)))

(defun org-ai-search--collect-output-rows ()
  "Collect rows from the output table below current heading.
Returns an alist keyed by URL, each value is a plist with :tags and :data."
  (let ((bounds (org-ai-search--find-output-table))
        (rows (make-hash-table :test 'equal)))
    (when bounds
      (save-excursion
        (goto-char (car bounds))
        (let* ((table (org-table-to-lisp))
               (headers (car table))
               (data (cdr table)))
          (dolist (row data)
            (let ((url nil)
                  (tags "")
                  (data-alist nil))
              (cl-loop for h in headers
                       for v in row
                       do (progn
                            (push (cons h v) data-alist)
                            (when (equal h "URL") (setq url v))
                            (when (equal h "Tags") (setq tags v))))
              (when url
                (puthash url (list :tags tags :data (nreverse data-alist)) rows)))))))
    rows))

(defun org-ai-search--prepend-stale (tags)
  "Prepend :stale: to TAGS if not already present."
  (let ((clean (string-trim tags)))
    (if (string-match-p ":stale:" clean)
        clean
      (concat ":stale:" clean))))

(defun org-ai-search--merge-results (new-result old-rows)
  "Merge NEW-RESULT with OLD-ROWS hash table.
URLs in both keep old tags; URLs only in old get :stale:; URLs only in new are new.
Returns a result alist suitable for rendering."
  (let* ((new-cols (cdr (assoc 'output_columns new-result)))
         (new-rows (cdr (assoc 'rows new-result)))
         (all-cols new-cols)
         (merged nil)
         (seen-old nil))
    ;; First: process new rows, preserving old tags
    (dolist (nrow new-rows)
      (let* ((url (cdr (assoc 'URL nrow)))
             (old (when url (gethash url old-rows)))
             (tags (if old (plist-get old :tags) "")))
        (when old (push url seen-old))
        (push (append nrow `((Tags . ,tags))) merged)))
    ;; Second: add old rows not in new results, marked stale
    (maphash
     (lambda (url old)
       (unless (member url seen-old)
         (let* ((old-data (plist-get old :data))
                (stale-tags (org-ai-search--prepend-stale (plist-get old :tags)))
                (stale-row nil))
           ;; Build a row with all columns, filling missing with ""
           (dolist (col all-cols)
             (let ((val (or (cdr (assoc col old-data)) "")))
               (when (equal col "Tags")
                 (setq val stale-tags))
               (push (cons (intern col) val) stale-row)))
           (push (nreverse stale-row) merged))))
     old-rows)
    `((status . "completed")
      (output_columns . ,(append '("Tags") (remove "Tags" all-cols)))
      (rows . ,(nreverse merged))
      (metadata . ,(cdr (assoc 'metadata new-result))))))

(defun org-ai-search-refresh ()
  "Refresh the search results.
Preserves existing tags, marks missing rows as :stale:."
  (interactive)
  (unless (org-at-table-p)
    (user-error "Not on a table"))
  (let* ((discovery (org-ai-search--parse-discovery-table))
         (old-rows (org-ai-search--collect-output-rows))
         (req (org-ai-search--build-request discovery))
         (result (org-ai-search--run-search req)))
    (if (assoc 'error result)
        (message "org-ai-search error: %s" (cdr (assoc 'error result)))
      (let ((merged (org-ai-search--merge-results result old-rows)))
        (org-ai-search--render-output-table merged)
        (let ((new-count (length (cdr (assoc 'rows result))))
              (stale-count (cl-count-if
                            (lambda (r) (string-match-p ":stale:" (or (cdr (assoc 'Tags r)) "")))
                            (cdr (assoc 'rows merged)))))
          (message "Refresh complete: %d new, %d stale kept"
                   new-count stale-count))))))

(defun org-ai-search-delete-stale ()
  "Delete rows tagged :stale: from output table."
  (interactive)
  (let ((bounds (org-ai-search--find-output-table)))
    (unless bounds
      (user-error "No output table found"))
    (let ((count 0))
      (save-excursion
        (goto-char (car bounds))
        (forward-line 2) ;; skip header + hline
        (while (and (< (point) (cdr bounds)) (org-at-table-p))
          (let ((tags (org-table-get-field)))
            (if (string-match-p ":stale:" tags)
                (progn
                  (org-table-kill-row)
                  (cl-incf count))
              (forward-line)))))
      (message "Deleted %d stale rows" count))))

(provide 'org-ai-search)
;;; org-ai-search.el ends here
