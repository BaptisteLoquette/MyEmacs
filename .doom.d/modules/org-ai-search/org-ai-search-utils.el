;;; org-ai-search-utils.el --- Utility helpers -*- lexical-binding: t; -*-

(defun org-ai-search--read-auth-source (host)
  "Read API key for HOST from auth-source."
  (when-let ((entry (auth-source-search :host host :max 1)))
    (let ((token (plist-get (car entry) :secret)))
      (if (functionp token) (funcall token) token))))

(provide 'org-ai-search-utils)
;;; org-ai-search-utils.el ends here
