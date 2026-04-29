;;; org-ai-search-table.el --- Table parsing and rendering -*- lexical-binding: t; -*-

(require 'org-table)
(require 'org-element)

(defun org-ai-search--get-property (prop)
  "Get property PROP from the current heading's drawer."
  (org-entry-get (point) prop t))

(defun org-ai-search--set-property (prop value)
  "Set property PROP to VALUE in the current heading."
  (org-entry-put (point) prop value))

(defun org-ai-search--parse-discovery-table ()
  "Parse the discovery table at point.
Returns a plist with :backend, :count, :rows.
Each row is an alist of column header -> cell value."
  (when (org-at-table-p)
    (let* ((table (org-table-to-lisp))
           (headers (car table))
           (data-rows (cdr table)))
      (unless (equal (car headers) "QUERY")
        (user-error "First column must be QUERY"))
      (let ((rows nil))
        (dolist (row data-rows)
          (let ((alist nil))
            (cl-loop for h in headers
                     for v in row
                     do (push (cons h v) alist))
            (push (nreverse alist) rows)))
        (list :backend (org-ai-search--get-property "AI_SEARCH_BACKEND")
              :count (org-ai-search--get-property "AI_SEARCH_COUNT")
              :rows (nreverse rows)
              :headers headers)))))

(defun org-ai-search--find-output-table ()
  "Find the output table below current heading.
Returns (BEGIN . END) positions or nil."
  (save-excursion
    (org-back-to-heading)
    (forward-line)
    (let ((start nil)
          (end nil))
      (while (and (not start) (not (eobp)))
        (when (looking-at "^[ \t]*#\\+NAME:")
          (forward-line)
          (when (org-at-table-p)
            (setq start (line-beginning-position))
            (org-table-goto-line 1)
            (goto-char (org-table-end))
            (setq end (point))))
        (forward-line))
      (when start (cons start end)))))

(defun org-ai-search--render-output-table (result)
  "Insert or replace output table from Python RESULT (alist).
RESULT must have :output_columns and :rows."
  (let* ((cols (cdr (assoc 'output_columns result)))
         (rows (cdr (assoc 'rows result)))
         (table-name (concat "ai-results-"
                             (replace-regexp-in-string
                              "[^a-zA-Z0-9-]" "-"
                              (downcase (org-get-heading t t t t)))))
         (output (concat "\n#+NAME: " table-name "\n")))
    ;; Build org table
    (setq output (concat output "|" (mapconcat #'identity cols "|") "|\n"))
    (setq output (concat output "|" (mapconcat (lambda (_) "-") cols "+") "|\n"))
    (dolist (row rows)
      (setq output
            (concat output
                    "|"
                    (mapconcat (lambda (col)
                                 (let ((val (cdr (assoc (intern col) row))))
                                   (if (and val (not (string= val "")))
                                       (cond
                                        ((string= col "URL")
                                         (format "[[%s][%s]]" val
                                                 (or (url-host (url-generic-parse-url val)) val)))
                                        (t val))
                                     "")))
                               cols
                               "|")
                    "|\n")))
    ;; Find and replace or insert
    (let ((bounds (org-ai-search--find-output-table)))
      (if bounds
          (progn
            (delete-region (car bounds) (cdr bounds))
            (goto-char (car bounds))
            (insert output))
        (goto-char (org-table-end))
        (insert output)))
    (org-table-align)))

(provide 'org-ai-search-table)
;;; org-ai-search-table.el ends here
