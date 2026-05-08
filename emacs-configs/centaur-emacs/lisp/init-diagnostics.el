;;; init-diagnostics.el --- Startup diagnostic logging -*- lexical-binding: t no-byte-compile: t -*-
;;; Commentary:
;;; Provides comprehensive startup logging for Centaur Emacs
;;; When used, dumps full startup state to file for offline analysis
;;; Usage: add to your init chain and then: emacs --with-profile centaur --debug-init

;;; Code:

(defvar diag-log-file nil
  "Path to the diagnostic log file.")

(defvar diag-start-time (current-time)
  "Absolute start time of the diagnostics.")

(defun diag-write (format-string &rest args)
  "Append formatted text to DIAG-LOG-FILE."
  (let ((text (apply 'format format-string args)))
    (with-current-buffer (get-buffer-create " *diag-log*")
      (goto-char (point-max))
      (insert text "\n"))
    (when diag-log-file
      (with-temp-buffer
        (insert text "\n")
        (write-region (point-min) (point-max) diag-log-file t)))))

(defun diag-init-log-file ()
  "Set up the log file path."
  (setq diag-log-file
        (expand-file-name
         (format-time-string
          "logs/centaur-startup-%Y%m%d-%H%M%S.log"
          diag-start-time)
         user-emacs-directory))
  ;; Ensure log directory exists
  (let ((log-dir (file-name-directory diag-log-file)))
    (unless (file-directory-p log-dir)
      (make-directory log-dir t)))
  (diag-write ";;; Centaur Emacs Startup Diagnostic Log")
  (diag-write ";;; Profile: centaur")
  (diag-write ";;; User: %s" user-login-name)
  (diag-write ";;; Emacs version: %s" emacs-version)
  (diag-write ";;; System type: %s" system-type))

(defun diag-log-time (event-name)
  "Log EVENT-NAME with its elapsed time."
  (diag-write "[T+%010.4fms] %s"
              (* 1000.0 (float-time (time-since diag-start-time)))
              event-name))

(defun diag-log-separator ()
  "Log a visual separator."
  (diag-write "═══════════════════════════════════════════════════════════════"))

(defun diag-log-section (section-name)
  "Log a section header."
  (diag-log-separator)
  (diag-write "SECTION: %s" section-name)
  (diag-log-separator))

(defun diag-log-variable (var-name)
  "Log the value of variable VAR-NAME."
  (diag-write "  %s = %S" var-name (symbol-value var-name)))

(defun diag-log-variables-list (var-names)
  "Log values of all variables in VAR-NAMES."
  (dolist (var var-names)
    (diag-log-variable var)))

(defun diag-log-backtrace ()
  "Log a call stack backtrace."
  (diag-write "--- Backtrace ---")
  (mapbacktrace
   (lambda (evald func args flags)
     (let* ((name (if (symbolp func)
                      (symbol-name func)
                    (format "%s" func))))
       (diag-write "  %s%s"
                   name
                   (if evald " [evaluated]" "")))))
  (diag-write "--- End Backtrace ---"))

(defun diag-log-errors ()
  "Log any unhandled errors."
  (when (boundp 'after-init-hook)
    (add-hook 'after-init-hook
              (lambda ()
                (diag-log-section "After Init")
                (diag-log-time "after-init-hook completed")))

    (add-hook 'emacs-startup-hook
              (lambda ()
                (diag-log-section "Startup Complete")
                (diag-log-time "emacs-startup-hook completed")
                (diag-write ";;; Diagnostics complete. Log: %s" diag-log-file)
                (message "Centaur diagnostics saved to: %s" diag-log-file)))))

(defun diag-log-package-errors ()
  "Hook into use-package to log package loading errors."
  (eval-after-load 'use-package-core
    '(progn
       (advice-add 'use-package-log :after
                   (lambda (label &rest args)
                     (diag-write "use-package: %s %s" label args)))

       (advice-add 'use-package-error :before
                   (lambda (arg0)
                     (diag-write "use-package ERROR: %s" arg0))))))

(defun diag-log-all-requires ()
  "Log every require call."
  (advice-add 'require :before
              (lambda (feature &rest _) (diag-write "  require: %s" feature))))

(defun diag-dump-state ()
  "Dump comprehensive state to log."
  (diag-log-section "Full System State")
  (diag-log-time "Full state dump")
  (diag-write "user-emacs-directory: %s" user-emacs-directory)
  (diag-write "load-path entries: %d" (length load-path))
  (diag-write "package-user-dir: %s" (if (boundp 'package-user-dir) package-user-dir "N/A"))
  (diag-write "package-archives: %S" (if (boundp 'package-archives) package-archives "N/A"))
  (diag-write "features: %S" features)

  (diag-log-separator)
  (diag-write "Active processes:")
  (dolist (proc (process-list))
    (diag-write "  - %s: %s" (process-name proc) (process-status proc)))

  (diag-log-separator)
  (diag-write "Open buffers:")
  (dolist (buf (buffer-list))
    (diag-write "  - %s" (buffer-name buf)))

  (diag-log-separator)
  (diag-write "Loaded modules:")
  (dolist (feature features)
    (diag-write "  - %s" feature))

  (diag-log-separator)
  (diag-write "Full load-path:")
  (dolist (path load-path)
    (diag-write "  %s" path)))

;; Initialize
(diag-init-log-file)
(diag-log-section "Diagnostics Initialized")
(diag-log-time "init-diagnostics.el loaded")

;; Error handlers
(defun diag--debug-error (error data)
  "Log errors as they happen."
  (diag-write "!!! UNCAUGHT ERROR !!!")
  (diag-write "  Signal: %S" error)
  (diag-write "  Data: %S" data)
  (diag-log-backtrace))

;; DON'T set debug-on-error t — it opens a debugger which BLOCKS
;; startup when any package fails to install, preventing timers
;; and hooks from ever running.  Instead we log silently.
;; (setq debug-on-error t)

;; Use condition-case to catch and log errors during startup
(defun diag-debug-on-error-wrapper (fn &rest args)
  "Wrap debug-on-error handler to log first."
  (apply #'diag--debug-error args)
  (apply fn args))

;; Log all requires for traceability
(diag-log-all-requires)

;; Register error logging hooks
(diag-log-errors)

;; Try to dump more state later
(run-with-timer 2 nil 'diag-dump-state)

;; ── NEW: capture *Messages* buffer post-startup ────────────────────────
;; The *Messages* buffer contains ALL minibuffer output: use-package errors,
;; package download info, etc.  We dump it 10 seconds after startup so
;; even slow package installs are captured.

(defun diag-dump-messages ()
  "Append current contents of *Messages* to a dedicated messages log."
  (let* ((msg nil)
         (msg-log (expand-file-name
                   (format-time-string "logs/centaur-messages-%Y%m%d-%H%M%S.txt"
                                     diag-start-time)
                   user-emacs-directory)))
    (with-current-buffer (get-buffer-create "*Messages*")
      (setq msg (buffer-string)))
    (with-temp-file msg-log
      (insert ";;; *Messages* dump from Centaur startup\n")
      (insert ";;; Timestamp: " (current-time-string) "\n\n")
      (insert msg)
      (insert "\n;;; END OF MESSAGES DUMP\n"))
    (message "[diag] Messages saved to: %s" msg-log)
    msg-log))

;; Dump ~10 seconds after startup to catch package install errors
(add-hook 'emacs-startup-hook
          (lambda ()
            (run-with-timer 10 nil (lambda ()
                                     (diag-dump-messages)
                                     (diag-log-time "*Messages* dumped"))))
          t)

(provide 'init-diagnostics)

;;; init-diagnostics.el ends here
