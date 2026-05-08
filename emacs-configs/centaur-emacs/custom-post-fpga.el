;;; custom-post-fpga.el --- FPGA, RTL & Hardware Design -*- lexical-binding: t no-byte-compile: t -*-

;;; Commentary:
;;; Complete FPGA development environment for Emacs:
;;;   - Verilog / SystemVerilog : verilog-ext, verilog-ts-mode
;;;   - VHDL                    : vhdl-ext, vhdl-ts-mode
;;;   - Unified workflow        : fpga (synthesis, simulation, programming)
;;;   - Waveform viewing        : integration with GTKWave (open-source)
;;;
;;; External tools installed:
;;;   OSS CAD Suite (C:\Users\Bapti\tools\oss-cad-suite\oss-cad-suite)
;;;     - Yosys, Icarus Verilog, GTKWave, Verilator, nextpnr
;;;   NOTE: GHDL is NOT bundled in the Windows OSS CAD Suite.
;;;         Install separately if you need VHDL simulation (see below).
;;;
;;; Optional vendor stacks:
;;;     - AMD/Xilinx  Vivado + Vitis
;;;     - Intel/Altera Quartus Prime
;;;     - Lattice     Diamond / Radiant

;;; Code:

;; ── OSS CAD Suite PATH injection ───────────────────────────────────────
(defvar my/oss-cad-suite-dir
  (expand-file-name "~/tools/oss-cad-suite/oss-cad-suite")
  "Root directory of the OSS CAD Suite installation.")

;; Ensure the OSS CAD Suite binaries are on Emacs' exec-path
(let ((oss-bin (expand-file-name "bin" my/oss-cad-suite-dir)))
  (when (and (file-directory-p oss-bin)
             (not (member oss-bin exec-path)))
    (add-to-list 'exec-path oss-bin)))

;; Platform-aware binary suffix (Windows needs .exe, WSL/Linux does not)
(defvar my/oss-bin-suffix (if (eq system-type 'windows-nt) ".exe" "")
  "Suffix for OSS CAD Suite binaries (.exe on Windows, empty on Linux/WSL).")

;; ════════════════════════════════════════════════════════════════════════
;; 1. Prefix keymap for FPGA commands
;; ════════════════════════════════════════════════════════════════════════
(define-prefix-command 'my/fpga-map)
(global-set-key (kbd "C-c f") 'my/fpga-map)

;; ════════════════════════════════════════════════════════════════════════
;; 2. Verilog / SystemVerilog
;; ════════════════════════════════════════════════════════════════════════

;; Tree-sitter based major mode (Emacs 29+) — preferred when available
(when (and (fboundp 'treesit-available-p) (treesit-available-p))
  (use-package verilog-ts-mode
    :ensure t
    :mode (("\\.v\\'"   . verilog-ts-mode)
           ("\\.sv\\'"  . verilog-ts-mode)
           ("\\.svh\\'" . verilog-ts-mode))
    :config
    (setq verilog-ts-indent-level 2
          verilog-ts-indent-level-module 2
          verilog-ts-indent-level-declaration 2)))

;; Enhanced verilog-mode with navigation, lint, beautify, compilation
(use-package verilog-ext
  :ensure t
  :after (verilog-mode verilog-ts-mode)
  :hook ((verilog-mode  . verilog-ext-mode)
         (verilog-ts-mode . verilog-ext-mode))
  :init
  ;; Pick LSP client based on Centaur config
  (setq verilog-ext-lsp-client (if (eq centaur-lsp 'eglot) 'eglot 'lsp-mode))
  :config
  (setq verilog-ext-feature-list
        '(fontification
          xref
          capf
          hierarchy
          imenu
          navigation
          template
          formatter
          lsp
          flycheck
          beautify
          ports
          snippets
          indentation))
  (verilog-ext-mode-setup)
  ;; Compilation / simulation helpers
  (setq verilog-ext-compile-command "iverilog -g2012 -Wall -o sim.out"
        verilog-ext-simulator "vvp"))

;; ════════════════════════════════════════════════════════════════════════
;; 3. VHDL
;; ════════════════════════════════════════════════════════════════════════

;; Tree-sitter based major mode (Emacs 29+) — preferred when available
(when (and (fboundp 'treesit-available-p) (treesit-available-p))
  (use-package vhdl-ts-mode
    :ensure t
    :mode (("\\.vhd\\'"  . vhdl-ts-mode)
           ("\\.vhdl\\'" . vhdl-ts-mode))
    :config
    (setq vhdl-ts-indent-level 2)))

;; Enhanced vhdl-mode with navigation, imenu, LSP, templates
(use-package vhdl-ext
  :ensure t
  :after (vhdl-mode vhdl-ts-mode)
  :hook ((vhdl-mode  . vhdl-ext-mode)
         (vhdl-ts-mode . vhdl-ext-mode))
  :init
  (setq vhdl-ext-lsp-client (if (eq centaur-lsp 'eglot) 'eglot 'lsp-mode))
  :config
  (setq vhdl-ext-feature-list
        '(fontification
          xref
          capf
          hierarchy
          imenu
          navigation
          template
          formatter
          lsp
          flycheck
          beautify
          ports
          snippets
          indentation))
  (vhdl-ext-mode-setup)
  ;; Default to GHDL for compilation (install separately if needed)
  (setq vhdl-ext-compile-command "ghdl -a --std=08"
        vhdl-ext-elab-command    "ghdl -e --std=08"
        vhdl-ext-simulator       "ghdl -r --std=08"))

;; ════════════════════════════════════════════════════════════════════════
;; 4. Unified FPGA workflow (fpga.el)
;; ════════════════════════════════════════════════════════════════════════
(use-package fpga
  :ensure t
  :after (verilog-ext vhdl-ext)
  :init
  ;; Use OSS CAD Suite paths when available (platform-aware)
  (setq fpga-yosys-path   (expand-file-name (concat "bin/yosys" my/oss-bin-suffix)
                                            my/oss-cad-suite-dir)
        fpga-nextpnr-path (expand-file-name (concat "bin/nextpnr-ice40" my/oss-bin-suffix)
                                            my/oss-cad-suite-dir)
        fpga-icestorm-path (expand-file-name (concat "bin/icepack" my/oss-bin-suffix)
                                             my/oss-cad-suite-dir)
        ;; Vendor tools (install separately and customise paths if needed)
        fpga-vivado-path  "vivado"
        fpga-quartus-path "quartus_sh")
  :config
  ;; Show FPGA targets in a dedicated buffer
  (setq fpga-build-show-output t)
  ;; Keybinds under C-c f
  :bind (:map my/fpga-map
              ("p" . fpga-program)      ; program / flash bitstream
              ("b" . fpga-build)        ; synthesis / build
              ("c" . fpga-clean)        ; clean artifacts
              ("r" . fpga-run)          ; run simulation
              ("s" . fpga-synth)        ; synthesis only
              ("i" . fpga-impl)         ; implementation / P&R
              ("t" . fpga-testbench)    ; generate testbench stub
              ("w" . fpga-waveform)     ; open GTKWave
              ("d" . fpga-drc)          ; design rule check
              ("l" . fpga-lint)))        ; linter

;; ════════════════════════════════════════════════════════════════════════
;; 5. Waveform & simulation helpers
;; ════════════════════════════════════════════════════════════════════════

(defun my/gtkwave-open (vcd-file)
  "Open VCD-FILE in GTKWave."
  (interactive (list (read-file-name "VCD file: " nil nil t "*.vcd")))
  (start-process "gtkwave" nil "gtkwave" (expand-file-name vcd-file)))

(defun my/verilator-lint (file)
  "Run Verilator lint on FILE."
  (interactive (list (or (buffer-file-name)
                         (read-file-name "File to lint: "))))
  (compile (format "verilator --lint-only -Wall %s" (shell-quote-argument file))))

(defun my/yosys-synth-ice40 (top)
  "Quick Yosys synthesis script for iCE40 targeting TOP module."
  (interactive "sTop module name: ")
  (let ((script (make-temp-file "yosys-" nil ".ys")))
    (with-temp-file script
      (insert (format "read_verilog -sv %s\n" (shell-quote-argument (buffer-file-name))))
      (insert (format "synth_ice40 -top %s -json output.json\n" top)))
    (compile (format "yosys %s" (shell-quote-argument script)))))

;; Bind waveform / sim helpers
(define-key my/fpga-map (kbd "g") #'my/gtkwave-open)
(define-key my/fpga-map (kbd "v") #'my/verilator-lint)
(define-key my/fpga-map (kbd "y") #'my/yosys-synth-ice40)

;; ════════════════════════════════════════════════════════════════════════
;;  Org-Babel integration for literate hardware design
;; ════════════════════════════════════════════════════════════════════════
;; Verilog/VHDL babel registration is handled in the consolidated babel block
;; in custom-post-data.el. No duplicate registration here.

;; Quick template for a literate FPGA design block
(defun my/insert-fpga-org-template (language)
  "Insert an Org Babel FPGA template for LANGUAGE (verilog or vhdl)."
  (interactive (list (completing-read "Language: " '("verilog" "vhdl"))))
  (insert (format "#+title: FPGA Design Block\n"))
  (insert (format "#+date: %s\n\n" (format-time-string "%Y-%m-%d")))
  (insert "* Specification\n  Describe the module interface & behaviour.\n\n")
  (insert (format "* RTL Source (%s)\n" (upcase language)))
  (if (string= language "verilog")
      (progn
        (insert "#+begin_src verilog\n")
        (insert "module counter #(parameter WIDTH = 8)\n")
        (insert "  (input  wire clk,\n")
        (insert "   input  wire rst,\n")
        (insert "   output reg [WIDTH-1:0] count);\n\n")
        (insert "  always @(posedge clk or posedge rst)\n")
        (insert "    if (rst) count <= 0;\n")
        (insert "    else     count <= count + 1;\n")
        (insert "endmodule\n")
        (insert "#+end_src\n\n")
        (insert "* Testbench\n")
        (insert "#+begin_src verilog\n")
        (insert "`timescale 1ns/1ps\n")
        (insert "module tb;\n  reg clk=0, rst=0;\n  wire [7:0] count;\n")
        (insert "  counter #(.WIDTH(8)) uut (.clk(clk),.rst(rst),.count(count));\n")
        (insert "  initial begin\n    $dumpfile(\"dump.vcd\");\n    $dumpvars(0, tb);\n")
        (insert "    rst = 1; #10 rst = 0;\n    #200 $finish;\n  end\n")
        (insert "  always #5 clk = ~clk;\nendmodule\n")
        (insert "#+end_src\n\n"))
    (progn
      (insert "#+begin_src vhdl\n")
      (insert "library ieee;\nuse ieee.std_logic_1164.all;\n")
      (insert "use ieee.numeric_std.all;\n\n")
      (insert "entity counter is\n  generic (WIDTH : natural := 8);\n")
      (insert "  port (clk  : in  std_logic;\n")
      (insert "        rst  : in  std_logic;\n")
      (insert "        count: out unsigned(WIDTH-1 downto 0));\n")
      (insert "end entity;\n\n")
      (insert "architecture rtl of counter is\n")
      (insert "  signal cnt : unsigned(WIDTH-1 downto 0);\n")
      (insert "begin\n  count <= cnt;\n\n")
      (insert "  process(clk, rst)\n  begin\n")
      (insert "    if rst = '1' then\n      cnt <= (others => '0');\n")
      (insert "    elsif rising_edge(clk) then\n      cnt <= cnt + 1;\n")
      (insert "    end if;\n  end process;\nend architecture;\n")
      (insert "#+end_src\n\n")))
  (insert "* Simulation / Synthesis\n")
  (insert "  Use C-c f r to run simulation or C-c f b to build.\n\n")
  (insert "* Waveform\n  #+RESULTS:\n  [[file:waveform.png]]\n\n")
  (insert "* Notes\n  Trade-offs, timing results, next steps.\n"))

(define-key my/fpga-map (kbd "T") #'my/insert-fpga-org-template)

;; ════════════════════════════════════════════════════════════════════════
;; 7. Quick project scaffolding
;; ════════════════════════════════════════════════════════════════════════
(defun my/fpga-new-project (name language)
  "Create a minimal FPGA project skeleton named NAME in LANGUAGE (verilog/vhdl)."
  (interactive (list (read-string "Project name: ")
                     (completing-read "Language: " '("verilog" "vhdl"))))
  (let ((dir (read-directory-name "Create project in: " "~/fpga-projects/")))
    (make-directory (expand-file-name name dir) t)
    (make-directory (expand-file-name "rtl" (expand-file-name name dir)) t)
    (make-directory (expand-file-name "sim"  (expand-file-name name dir)) t)
    (make-directory (expand-file-name "tb"   (expand-file-name name dir)) t)
    (make-directory (expand-file-name "constraints" (expand-file-name name dir)) t)
    (let ((topfile (expand-file-name (format "rtl/%s.%s" name
                                             (if (string= language "verilog") "v" "vhd"))
                                     (expand-file-name name dir))))
      (with-temp-file topfile
        (if (string= language "verilog")
            (progn
              (insert (format "module %s (\n" name))
              (insert "  input  wire clk,\n")
              (insert "  input  wire rst,\n")
              (insert "  output reg  [7:0] out\n")
              (insert ");\n\n")
              (insert "  // TODO: implement\n\n")
              (insert "endmodule\n"))
          (progn
            (insert (format "library ieee;\nuse ieee.std_logic_1164.all;\n\n"))
            (insert (format "entity %s is\n  port (\n" name))
            (insert "    clk : in  std_logic;\n")
            (insert "    rst : in  std_logic;\n")
            (insert "    out : out std_logic_vector(7 downto 0)\n")
            (insert "  );\nend entity;\n\n")
            (insert (format "architecture rtl of %s is\n" name))
            (insert "begin\n  -- TODO: implement\nend architecture;\n"))))
      (message "Created FPGA project: %s" (expand-file-name name dir))
      (find-file topfile))))

(define-key my/fpga-map (kbd "n") #'my/fpga-new-project)

(provide 'custom-post-fpga)
;;; custom-post-fpga.el ends here
