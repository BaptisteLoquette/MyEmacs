;;; ob-vhdl.el --- Org-babel support for VHDL via GHDL -*- lexical-binding: t no-byte-compile: t -*-

;;; Commentary:
;;;
;;; Minimal Org-Babel backend for VHDL using GHDL as the compiler/simulator.
;;;
;;; Usage:
;;;   #+begin_src vhdl :results output :cmdline --std=08
;;;   library ieee;
;;;   use ieee.std_logic_1164.all;
;;;   entity counter is
;;;     port (clk : in std_logic; count : out integer);
;;;   end entity;
;;;   architecture rtl of counter is
;;;   begin
;;;     process(clk) variable c : integer := 0;
;;;   begin
;;;     if rising_edge(clk) then c := c + 1; end if;
;;;     count <= c;
;;;   end process;
;;;   end architecture;
;;;   #+end_src
;;;
;;; With elaboration and run:
;;;   #+begin_src vhdl :results output :top counter :cmdline --std=08
;;;   ...
;;;   #+end_src
;;;
;;; Header arguments:
;;;   :results output  — capture stdout from GHDL analysis (+ elaboration + run)
;;;   :cmdline FLAGS   — extra flags passed to GHDL (default: --std=08)
;;;   :top ENTITY      — top-level entity to elaborate and run (optional)
;;;   :file OUT.vcd    — if set, generate VCD waveform via --vcd=<file>
;;;
;;; Requires:
;;;   - GHDL installed and on PATH (or set `org-babel-vhdl-command')
;;;     Windows: winget install ghdl
;;;     Linux:   apt install ghdl / brew install ghdl
;;;
;;; Code:

(require 'ob)
(require 'ob-ref)
(require 'ob-eval)

;; ── Customisation ─────────────────────────────────────────────────────

(defcustom org-babel-vhdl-command "ghdl"
  "Command to run GHDL."
  :group 'org-babel
  :type 'string)

(defcustom org-babel-vhdl-default-std "08"
  "Default VHDL standard for GHDL (--std= flag)."
  :group 'org-babel
  :type 'string)

;; ── Org-babel interface ──────────────────────────────────────────────

(defvar org-babel-default-header-args:vhdl
  '((:results . "output")
    (:cmdline . ""))
  "Default header arguments for VHDL src blocks.")

(defun org-babel-expand-body:vhdl (body params)
  "Expand BODY with variable substitutions from PARAMS.
Variables from :var headers are prepended as VHDL constants."
  (let ((vars (org-babel--get-vars params)))
    (if vars
        (concat
         (mapconcat
          (lambda (pair)
            (format "-- variable: %s = %s" (car pair) (cdr pair)))
          vars "\n")
         "\n" body)
      body)))

(defun org-babel-execute:vhdl (body params)
  "Execute a VHDL code block with GHDL.
BODY is the VHDL source code.  PARAMS is the header argument alist."
  (let* ((tmp-dir (org-babel-temp-directory))
         (base-name (make-temp-name "ob-vhdl-"))
         (vhd-file (expand-file-name (concat base-name ".vhd") tmp-dir))
         (work-dir (expand-file-name "work" tmp-dir))
         (cmdline (or (cdr (assq :cmdline params)) ""))
         (std-flag (if (string-match-p "--std=" cmdline)
                       ""
                     (concat "--std=" org-babel-vhdl-default-std)))
         (top (cdr (assq :top params)))
         (vcd-file (cdr (assq :file params)))
         (full-body (org-babel-expand-body:vhdl body params))
         (extra-flags (string-trim (concat std-flag " " cmdline))))

    ;; Verify GHDL is available
    (unless (executable-find org-babel-vhdl-command)
      (user-error "GHDL not found. Install: winget install ghdl (Windows) or apt install ghdl (Linux)"))

    ;; Ensure work directory exists
    (make-directory work-dir t)

    ;; Write VHDL source to temp file
    (with-temp-file vhd-file
      (insert full-body))

    ;; Build GHDL command sequence
    (let* ((ghdl org-babel-vhdl-command)
           ;; Step 1: Analyse (compile)
           (analyse-cmd (string-trim
                         (format "%s -a --workdir=%s %s %s"
                                 ghdl
                                 (shell-quote-argument work-dir)
                                 extra-flags
                                 (shell-quote-argument vhd-file))))
           ;; Step 2: Elaborate (link) — only if :top specified
           (elab-cmd (when top
                       (string-trim
                        (format "%s -e --workdir=%s %s %s"
                                ghdl
                                (shell-quote-argument work-dir)
                                extra-flags
                                top))))
           ;; Step 3: Run — only if :top specified
           (run-cmd (when top
                      (string-trim
                       (format "%s -r --workdir=%s %s %s %s"
                               ghdl
                               (shell-quote-argument work-dir)
                               extra-flags
                               top
                               (if vcd-file
                                   (concat "--vcd="
                                           (shell-quote-argument
                                            (expand-file-name vcd-file tmp-dir)))
                                 "")))))
           (output ""))

      ;; Execute analyse
      (setq output (org-babel-eval analyse-cmd ""))

      ;; Execute elaborate (if :top)
      (when elab-cmd
        (setq output (concat output "\n" (org-babel-eval elab-cmd ""))))

      ;; Execute run (if :top)
      (when run-cmd
        (setq output (concat output "\n" (org-babel-eval run-cmd ""))))

      ;; Return output or VCD file path
      (if vcd-file
          (expand-file-name vcd-file tmp-dir)
        (string-trim output)))))

;; ── Font-lock support ────────────────────────────────────────────────
;; Ensure VHDL code blocks get proper syntax highlighting in Org.
(with-eval-after-load 'org-src
  (add-to-list 'org-src-lang-modes '("vhdl" . vhdl)))

(provide 'ob-vhdl)
;;; ob-vhdl.el ends here
