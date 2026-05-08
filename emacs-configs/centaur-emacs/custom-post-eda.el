;;; custom-post-eda.el --- EDA & Simulation workflow -*- lexical-binding: t no-byte-compile: t -*-

;;; Commentary:
;;; Electronic Design Automation within Org-Babel:
;;;   - ob-spice (ngspice inline netlists) — *requires ngspice installed*
;;;   - matlab-mode + matlab-shell
;;;   - Shell-babel helpers for Xschem / Magic VLSI tools
;;;
;;; System prerequisites (install separately):
;;;   - ngspice:  winget install ngspice (or choco install ngspice)
;;;   - MATLAB:  add to PATH or set matlab-shell-command
;;;   - Xschem:  usually on Linux/macOS; on Windows use WSL + shell blocks

;;; Code:

;; ── ob-spice / ngspice integration ───────────────────────────────────
;; ob-spice may not be available on MELPA. Try to load it gracefully.
;; Spice babel registration is handled in the consolidated babel block
;; in custom-post-data.el (conditional on ob-spice + ngspice availability).
(use-package ob-spice
  :ensure t
  :after org
  :if (locate-library "ob-spice")
  :config
  (setq org-babel-spice-command "ngspice")
  (setq org-babel-spice-options "-b -o"))

;; Fallback message if ob-spice not available
(with-eval-after-load 'org
  (unless (locate-library "ob-spice")
    (message "[EDA] ob-spice not available — use #+begin_src shell for ngspice")))

;; Define EDA prefix BEFORE matlab-mode bindings
(define-prefix-command 'my/eda-map)
(global-set-key (kbd "C-c e") 'my/eda-map)

;; ── matlab-mode ─────────────────────────────────────────────────────
(use-package matlab-mode
  :ensure t
  :mode "\\.m\\'"
  :interpreter "matlab"
  :init
  ;; Path to MATLAB executable (adjust if installed in non-default location)
  (setq matlab-shell-command "matlab")
  (setq matlab-shell-command-switches "-nodesktop -nosplash")
  :config
  (setq matlab-indent-function t)
  (setq matlab-highlight-cross-function-variables t)
  ;; Keybinds under C-c e = EDA prefix
  :bind (:map my/eda-map
              ("m" . matlab-shell)))

;; ── Xschem / Magic / PEX / LVS via shell-babel ──────────────────────
;; These tools are native to Linux. On Windows, install via WSL and call
;; through shell blocks.  Provide convenience functions.

(defun my/xschem-run (schematic)
  "Run xschem on SCHEMATIC file via shell (expects xschem in PATH).
On Windows, ensure xschem is in WSL and accessible."
  (interactive (list (read-file-name "Schematic (.sch): " nil nil t "*.sch")))
  (let ((cmd (format "xschem -n -s -o %s" (shell-quote-argument schematic))))
    (compile cmd)))

(defun my/magic-run-lvs (layout netlist)
  "Run Magic LVS on LAYOUT against NETLIST via shell."
  (interactive (list (read-file-name "Layout (.mag): ")
                     (read-file-name "Netlist (.spice): ")))
  (let ((cmd (format "magic -dnull -noconsole -rcfile %s <<'EOF'
load %s
extract
 ext2spice
quit
EOF"
                     (shell-quote-argument layout))))
    (compile cmd)))

;; Bind under C-c e prefix (already defined above as my/eda-map)
(define-key my/eda-map (kbd "x") #'my/xschem-run)
(define-key my/eda-map (kbd "l") #'my/magic-run-lvs)
(define-key my/eda-map (kbd "s") #'matlab-shell)
(define-key my/eda-map (kbd "n") #'my/ngspice-quick-run)

;; Quick ngspice shell block helper
(defun my/ngspice-quick-run ()
  "Insert a ngspice shell block at point with common template."
  (interactive)
  (insert "#+begin_src shell :results output\n")
  (insert "ngspice -b netlist.cir\n")
  (insert "#+end_src\n"))

;; ── Workflow template for literate hardware design ──────────────────
(defun my/insert-eda-org-template ()
  "Insert a full literate-EDA Org template at point."
  (interactive)
  (insert "#+title: EDA Design Block\n")
  (insert "#+date: " (format-time-string "%Y-%m-%d") "\n\n")
  (insert "* Theory\n  Describe the circuit / algorithm here.\n\n")
  (insert "* Schematic / Netlist\n")
  (insert "#+begin_src spice :results file :file figs/sim_out.png\n")
  (insert "* Simple RC circuit\nV1 in 0 DC 1\nR1 in out 1k\nC1 out 0 1u\n.end\n")
  (insert "#+end_src\n\n")
  (insert "* Simulation Results\n  #+RESULTS:\n  [[file:figs/sim_out.png]]\n\n")
  (insert "* Conclusions\n  Performance, trade-offs, next steps.\n"))

(define-key my/eda-map (kbd "t") #'my/insert-eda-org-template)

(provide 'custom-post-eda)
;;; custom-post-eda.el ends here
