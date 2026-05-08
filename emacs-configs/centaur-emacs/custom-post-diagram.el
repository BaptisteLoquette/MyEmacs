;;; custom-post-diagram.el --- Diagrams, sketches & visualizations -*- lexical-binding: t no-byte-compile: t -*-

;;; Commentary:
;;;  Full-featured diagramming setup for Org-Babel:
;;;    - PlantUML  (UML, flowcharts, sequences, classes, state machines)
;;;    - Ditaa     (ASCII block diagrams → PNG)
;;;    - TikZ/LaTeX (scientific diagrams, math, physics, electronics, bit-fields)
;;;    - Graphviz  (graphs, trees, DAGs)
;;;    - Mermaid   (modern web-friendly diagrams, conditional)
;;;
;;;  Quick-insert helpers under C-c d prefix:
;;;    C-c d u   → PlantUML block
;;;    C-c d t   → Ditaa ASCII diagram
;;;    C-c d z   → TikZ scientific diagram
;;;    C-c d b   → TikZ bit-field / register layout
;;;    C-c d c   → TikZ circuit diagram
;;;    C-c d p   → TikZ physics / mechanics diagram
;;;    C-c d m   → TikZ math function plot
;;;    C-c d g   → Graphviz DOT diagram
;;;    C-c d M   → Mermaid diagram (if mmdc installed)
;;;    C-c d f   → Quick formula (LaTeX fragment)
;;;
;;;  Requires:
;;;    - Java (for PlantUML & ditaa)
;;;    - PlantUML jar (auto-downloads if missing)
;;;    - MiKTeX / TeX Live (for TikZ)
;;;    - ImageMagick (for PNG export from LaTeX)

;;; Code:

;; ═══════════════════════════════════════════════════════════════════════════
;; 1. TOOL PATHS — resolve Windows installations automatically
;; ═══════════════════════════════════════════════════════════════════════════

(defgroup my-diagram nil
  "Diagramming tool paths and settings."
  :group 'org)

;; ── Java ──────────────────────────────────────────────────────────────────
(defcustom my/java-path
  (or (executable-find "java")
      (let ((candidates
             (list
              "C:/Program Files/Eclipse Adoptium/jdk-21.0.11.10-hotspot/bin/java.exe"
              "C:/Program Files/Java/jdk-21/bin/java.exe"
              "C:/Program Files (x86)/Common Files/Oracle/Java/javaapath/java.exe")))
        (cl-find-if #'file-exists-p candidates)))
  "Path to Java executable."
  :type 'string
  :group 'my-diagram)

;; Add Java bin to exec-path if found (critical for PlantUML & ditaa)
(when (and my/java-path (file-exists-p my/java-path))
  (let ((bin-dir (file-name-directory my/java-path)))
    (add-to-list 'exec-path bin-dir)
    (setenv "PATH" (concat bin-dir path-separator (getenv "PATH")))
    (message "[diagram] Java added to PATH: %s" bin-dir)))

;; ── PlantUML ──────────────────────────────────────────────────────────────
(defcustom my/plantuml-jar
  (let ((paths (list
                (expand-file-name "~/tools/plantuml.jar")
                "C:/tools/plantuml.jar"
                (expand-file-name "plantuml.jar" user-emacs-directory))))
    (cl-find-if #'file-exists-p paths))
  "Path to PlantUML JAR file."
  :type 'string
  :group 'my-diagram)

;; Auto-download PlantUML if missing
(defun my/ensure-plantuml-jar ()
  "Download PlantUML jar if it doesn't exist."
  (interactive)
  (unless (and my/plantuml-jar (file-exists-p my/plantuml-jar))
    (let* ((jar-dir (expand-file-name "~/tools"))
           (jar-path (expand-file-name "plantuml.jar" jar-dir)))
      (message "[diagram] PlantUML jar not found. Downloading...")
      (make-directory jar-dir t)
      (url-copy-file
       "https://github.com/plantuml/plantuml/releases/download/v1.2024.7/plantuml-1.2024.7.jar"
       jar-path t)
      (setq my/plantuml-jar jar-path)
      (setq org-plantuml-jar-path jar-path)
      (message "[diagram] PlantUML jar saved to %s" jar-path))))

;; ── MiKTeX / TeX Live ────────────────────────────────────────────────────
(defcustom my/miktex-bin
  (or (executable-find "pdflatex")
      (let ((candidates
             (list
              (expand-file-name "AppData/Local/Programs/MiKTeX/miktex/bin/x64/pdflatex.exe" "~")
              "C:/Program Files/MiKTeX/miktex/bin/x64/pdflatex.exe"
              "C:/texlive/2024/bin/windows/pdflatex.exe")))
        (cl-find-if #'file-exists-p candidates)))
  "Path to pdflatex executable."
  :type 'string
  :group 'my-diagram)

;; Add MiKTeX bin to exec-path if found
(when my/miktex-bin
  (let ((bin-dir (file-name-directory my/miktex-bin)))
    (add-to-list 'exec-path bin-dir)
    (setenv "PATH" (concat bin-dir path-separator (getenv "PATH")))))

;; ── ImageMagick ───────────────────────────────────────────────────────────
(defcustom my/imagemagick-path
  (or (executable-find "magick")
      (let ((candidates
             (list
              "C:/Program Files/ImageMagick-7.1.2-Q16-HDRI/magick.exe"
              "C:/Program Files/ImageMagick-7.1.1-Q16-HDRI/magick.exe"
              "C:/Program Files/ImageMagick-7.0.11-Q16-HDRI/magick.exe")))
        (cl-find-if #'file-exists-p candidates)))
  "Path to ImageMagick magick executable."
  :type 'string
  :group 'my-diagram)

;; Add ImageMagick to exec-path if found
(when my/imagemagick-path
  (let ((bin-dir (file-name-directory my/imagemagick-path)))
    (add-to-list 'exec-path bin-dir)
    (setenv "PATH" (concat bin-dir path-separator (getenv "PATH")))))

;; ── Mermaid CLI ───────────────────────────────────────────────────────────
(defcustom my/mermaid-cli
  (or (executable-find "mmdc")
      (executable-find "mmdc.exe"))
  "Path to Mermaid CLI (mmdc)."
  :type '(choice string (const nil))
  :group 'my-diagram)

;; ═══════════════════════════════════════════════════════════════════════════
;; 2. ORG-BABEL DIAGRAM LANGUAGE SETUP
;; ═══════════════════════════════════════════════════════════════════════════

(with-eval-after-load 'org
  ;; PlantUML jar path (fixes the user's error)
  (when (and my/plantuml-jar (file-exists-p my/plantuml-jar))
    (setq org-plantuml-jar-path my/plantuml-jar)
    (message "[diagram] PlantUML jar: %s" org-plantuml-jar-path))

  ;; Ensure PlantUML is available
  (my/ensure-plantuml-jar)

  ;; Explicitly set Java command for PlantUML (fixes "java not found" on Windows)
  (when (and my/java-path (file-exists-p my/java-path))
    (setq org-plantuml-java-command my/java-path)
    (message "[diagram] PlantUML will use Java: %s" org-plantuml-java-command))

  ;; Register diagram languages in babel
  (org-babel-do-load-languages
   'org-babel-load-languages
   (append org-babel-load-languages
           '((plantuml . t)
             (ditaa    . t)
             (latex    . t)
             (dot      . t))))

  ;; Mermaid (conditional)
  (when my/mermaid-cli
    (org-babel-do-load-languages
     'org-babel-load-languages
     (append org-babel-load-languages
             '((mermaid . t))))
    (message "[diagram] Mermaid CLI found: %s" my/mermaid-cli))

  ;; LaTeX → PNG conversion for inline preview
  (setq org-latex-create-formula-image-program 'dvisvgm)

  ;; TikZ-specific: allow standalone preview
  (setq org-latex-packages-alist
        '("" "tikz" t
          "" "xcolor" t
          "" "amsmath" t
          "" "amssymb" t
          "" "standalone" t
          "" "pgfplots" t
          "" "circuitikz" t))

  ;; Inline image display after babel execution
  (add-hook 'org-babel-after-execute-hook #'org-display-inline-images)

  ;; Auto-approve trusted diagram blocks
  (setq org-confirm-babel-evaluate
        (lambda (lang body)
          (let ((file (or (buffer-file-name) ""))
                (trusted-langs '("plantuml" "ditaa" "latex" "dot" "mermaid")))
            (if (and (member lang trusted-langs)
                     (string-prefix-p (expand-file-name "~/org/") file))
                nil
              t)))))

;; ═══════════════════════════════════════════════════════════════════════════
;; 3. DIAGRAM OUTPUT DIRECTORY
;; ═══════════════════════════════════════════════════════════════════════════

(defcustom my/diagram-output-dir
  (expand-file-name "~/org/diagrams/")
  "Default directory for generated diagram images."
  :type 'string
  :group 'my-diagram)

(defun my/ensure-diagram-dir ()
  "Create diagram output directory if it doesn't exist."
  (interactive)
  (make-directory my/diagram-output-dir t)
  (message "[diagram] Output dir ready: %s" my/diagram-output-dir))

;; ═══════════════════════════════════════════════════════════════════════════
;; 4. QUICK INSERT HELPERS — minimal syntax, maximum output
;; ═══════════════════════════════════════════════════════════════════════════

;; ── 4.1 PlantUML (UML, flowcharts, sequences) ─────────────────────────────

(defun my/insert-plantuml-block (&optional type)
  "Insert a PlantUML diagram block.
TYPE can be: class, sequence, activity, state, component, usecase."
  (interactive
   (list (completing-read
          "Diagram type: "
          '("class" "sequence" "activity" "state" "component" "usecase" "empty")
          nil nil "empty")))
  (let* ((fname (format-time-string "plantuml-%Y%m%d-%H%M%S.png"))
         (template
          (pcase type
            ("class" "@startuml\nskinparam style strict\nclass MyClass {\n  +field\n  +method()\n}\n@enduml\n")
            ("sequence" "@startuml\nAlice -> Bob: Request\nBob --> Alice: Response\n@enduml\n")
            ("activity" "@startuml\nstart\n:Action 1;\n:Action 2;\nstop\n@enduml\n")
            ("state" "@startuml\n[*] -> State1\nState1 -> State2 : Event\nState2 -> [*]\n@enduml\n")
            ("component" "@startuml\n[Component] as C\n[Interface] as I\nC --> I\n@enduml\n")
            ("usecase" "@startuml\nleft to right direction\nactor User\nrectangle System {\n  User --> (Use Case)\n}\n@enduml\n")
            (_ "@startuml\n!theme plain\n\n' Your diagram here\n\n@enduml\n"))))
    (insert (format "#+begin_src plantuml :file %s%s\n"
                    my/diagram-output-dir fname))
    (insert template)
    (insert "#+end_src\n\n")
    (message "C-c C-c to render PlantUML → %s%s" my/diagram-output-dir fname)))

;; ── 4.2 Ditaa (ASCII block diagrams) ──────────────────────────────────────

(defun my/insert-ditaa-block ()
  "Insert a Ditaa ASCII-to-diagram source block."
  (interactive)
  (let ((fname (format-time-string "ditaa-%Y%m%d-%H%M%S.png")))
    (insert (format "#+begin_src ditaa :file %s%s :exports both\n"
                    my/diagram-output-dir fname))
    (insert "+--------+  +--------+\n")
    (insert "|  Box 1 |  |  Box 2 |\n")
    (insert "+---+----+  +----+---+\n")
    (insert "    |            |\n")
    (insert "    +-----+------+\n")
    (insert "          |\n")
    (insert "    +-----+------+\n")
    (insert "    v            v\n")
    (insert "+---+----+  +----+---+\n")
    (insert "| Output |  | Output |\n")
    (insert "+--------+  +--------+\n")
    (insert "#+end_src\n\n")
    (message "C-c C-c to render Ditaa → %s%s" my/diagram-output-dir fname)))

;; ── 4.3 TikZ / LaTeX (scientific & math diagrams) ─────────────────────────

(defun my/insert-tikz-block ()
  "Insert a generic TikZ diagram block (PNG output for inline preview)."
  (interactive)
  (let ((fname (format-time-string "tikz-%Y%m%d-%H%M%S.png")))
    (insert (format "#+begin_src latex :file %s%s :imagemagick yes :iminoptions -density 300\n"
                    my/diagram-output-dir fname))
    (insert "\\begin{tikzpicture}\n")
    (insert "  % Your TikZ code here\n")
    (insert "  \\draw (0,0) -- (4,0);\n")
    (insert "  \\draw (0,0) -- (0,3);\n")
    (insert "  \\node at (2,2) {$E = mc^2$};\n")
    (insert "\\end{tikzpicture}\n")
    (insert "#+end_src\n\n")
    (message "C-c C-c to render TikZ → %s%s" my/diagram-output-dir fname)))

;; ── 4.4 TikZ Bit-Field / Register Layout ──────────────────────────────────

(defun my/insert-tikz-bitfield ()
  "Insert a TikZ bit-field diagram template (e.g., IEEE 754, CPU register)."
  (interactive)
  (let ((fname (format-time-string "bitfield-%Y%m%d-%H%M%S.png")))
    (insert (format "#+begin_src latex :file %s%s :imagemagick yes :iminoptions -density 300\n"
                    my/diagram-output-dir fname))
    (insert "\\begin{tikzpicture}[\n")
    (insert "    box/.style={draw, minimum width=8mm, minimum height=8mm, font=\\small\\bfseries, text=white},\n")
    (insert "    label/.style={font=\\small}\n")
    (insert "]\n")
    (insert "  % Labels above brackets\n")
    (insert "  \\node[label] at (0.4,1.2) {$s$};\n")
    (insert "  \\node[label] at (3.2,1.2) {$e = \\text{exponent}$};\n")
    (insert "  \\node[label] at (7.5,1.2) {$m = \\text{mantissa}$};\n\n")
    (insert "  % Brackets\n")
    (insert "  \\draw[decorate,decoration={brace,amplitude=6pt}] (-0.4,0.5) -- (0.8,0.5);\n")
    (insert "  \\draw[decorate,decoration={brace,amplitude=6pt}] (1.2,0.5) -- (5.2,0.5);\n")
    (insert "  \\draw[decorate,decoration={brace,amplitude=6pt}] (5.6,0.5) -- (10,0.5);\n\n")
    (insert "  % Colored boxes\n")
    (insert "  \\node[box, fill=orange!60] at (0,0) {31};\n")
    (insert "  \\node[box, fill=green!50] at (1,0) {30};\n")
    (insert "  \\node[minimum width=12mm] at (2,0) {...};\n")
    (insert "  \\node[box, fill=green!50] at (3,0) {25};\n")
    (insert "  \\node[box, fill=green!50] at (4,0) {23};\n")
    (insert "  \\node[box, fill=cyan] at (5,0) {22};\n")
    (insert "  \\node[minimum width=12mm] at (6.2,0) {...};\n")
    (insert "  \\node[box, fill=cyan] at (8.5,0) {1};\n")
    (insert "  \\node[box, fill=cyan] at (9.5,0) {0};\n\n")
    (insert "  % Formula\n")
    (insert "  \\node at (4.5,-1.2) {$\\text{number} = (-1)^s \\times (1.m) \\times 2^{e-127}$};\n")
    (insert "\\end{tikzpicture}\n")
    (insert "#+end_src\n\n")
    (message "C-c C-c to render bit-field → %s%s" my/diagram-output-dir fname)))

;; ── 4.5 TikZ Circuit Diagram ──────────────────────────────────────────────

(defun my/insert-tikz-circuit ()
  "Insert a TikZ circuit diagram template (uses circuitikz)."
  (interactive)
  (let ((fname (format-time-string "circuit-%Y%m%d-%H%M%S.png")))
    (insert (format "#+begin_src latex :file %s%s :imagemagick yes :iminoptions -density 300\n"
                    my/diagram-output-dir fname))
    (insert "\\begin{tikzpicture}[circuitikz/european]\n")
    (insert "  % Power supply\n")
    (insert "  \\draw (0,0) to[V, v=$V_{in}$] (0,3);\n")
    (insert "  \\draw (0,3) to[R, l=$R_1$] (3,3);\n")
    (insert "  \\draw (3,3) to[C, l=$C_1$] (3,0);\n")
    (insert "  \\draw (3,0) -- (0,0);\n")
    (insert "  \\node at (1.5,-0.5) {RC Low-Pass Filter};\n")
    (insert "\\end{tikzpicture}\n")
    (insert "#+end_src\n\n")
    (message "C-c C-c to render circuit → %s%s" my/diagram-output-dir fname)))

;; ── 4.6 TikZ Physics / Mechanics Diagram ──────────────────────────────────

(defun my/insert-tikz-physics ()
  "Insert a TikZ physics/mechanics diagram template."
  (interactive)
  (let ((fname (format-time-string "physics-%Y%m%d-%H%M%S.png")))
    (insert (format "#+begin_src latex :file %s%s :imagemagick yes :iminoptions -density 300\n"
                    my/diagram-output-dir fname))
    (insert "\\begin{tikzpicture}\n")
    (insert "  % Ground line\n")
    (insert "  \\draw[thick] (-1,0) -- (6,0);\n")
    (insert "  \\foreach \\x in {-1,...,6} \\draw (\\x,0) -- ++(0,-0.2);\n\n")
    (insert "  % Inclined plane\n")
    (insert "  \\draw[fill=gray!20] (0,0) -- (4,0) -- (4,2) -- cycle;\n")
    (insert "  \\draw[->, thick, red] (3,1.5) -- (4.5,2.5) node[right] {$\\vec{F}$};\n")
    (insert "  \\draw[->, thick, blue] (3,1.5) -- (3,0.5) node[below] {$\\vec{g}$};\n\n")
    (insert "  % Angle\n")
    (insert "  \\draw (3.5,0) arc (0:26.57:0.5) node[midway, right] {$\\theta$};\n")
    (insert "\\end{tikzpicture}\n")
    (insert "#+end_src\n\n")
    (message "C-c C-c to render physics → %s%s" my/diagram-output-dir fname)))

;; ── 4.7 TikZ Math Function Plot ───────────────────────────────────────────

(defun my/insert-tikz-math-plot ()
  "Insert a TikZ math function plot template (uses pgfplots)."
  (interactive)
  (let ((fname (format-time-string "plot-%Y%m%d-%H%M%S.png")))
    (insert (format "#+begin_src latex :file %s%s :imagemagick yes :iminoptions -density 300\n"
                    my/diagram-output-dir fname))
    (insert "\\begin{tikzpicture}\n")
    (insert "  \\begin{axis}[\n")
    (insert "      axis lines=middle,\n")
    (insert "      xlabel=$x$, ylabel=$y$,\n")
    (insert "      xmin=-5, xmax=5,\n")
    (insert "      ymin=-2, ymax=2,\n")
    (insert "      grid=both,\n")
    (insert "      width=10cm, height=6cm\n")
    (insert "  ]\n")
    (insert "    \\addplot[domain=-5:5, samples=100, thick, blue] {sin(deg(x))};\n")
    (insert "    \\addplot[domain=-5:5, samples=100, thick, red, dashed] {cos(deg(x))};\n")
    (insert "    \\legend{$\\sin(x)$, $\\cos(x)$}\n")
    (insert "  \\end{axis}\n")
    (insert "\\end{tikzpicture}\n")
    (insert "#+end_src\n\n")
    (message "C-c C-c to render plot → %s%s" my/diagram-output-dir fname)))

;; ── 4.8 Graphviz DOT ──────────────────────────────────────────────────────

(defun my/insert-graphviz-block ()
  "Insert a Graphviz DOT diagram block."
  (interactive)
  (let ((fname (format-time-string "graphviz-%Y%m%d-%H%M%S.png")))
    (insert (format "#+begin_src dot :file %s%s\n"
                    my/diagram-output-dir fname))
    (insert "digraph G {\n")
    (insert "    rankdir=LR;\n")
    (insert "    node [shape=box, style=\"rounded,filled\", fillcolor=lightblue];\n")
    (insert "    A [label=\"Start\"];\n")
    (insert "    B [label=\"Process\"];\n")
    (insert "    C [label=\"End\"];\n")
    (insert "    A -> B;\n")
    (insert "    B -> C;\n")
    (insert "}\n")
    (insert "#+end_src\n\n")
    (message "C-c C-c to render Graphviz → %s%s" my/diagram-output-dir fname)))

;; ── 4.9 Mermaid ───────────────────────────────────────────────────────────

(defun my/insert-mermaid-block ()
  "Insert a Mermaid diagram source block."
  (interactive)
  (if (not my/mermaid-cli)
      (message "[diagram] Mermaid CLI (mmdc) not found. Install: npm install -g @mermaid-js/mermaid-cli")
    (let ((fname (format-time-string "mermaid-%Y%m%d-%H%M%S.png")))
      (insert (format "#+begin_src mermaid :file %s%s\n"
                      my/diagram-output-dir fname))
      (insert "graph TD\n")
      (insert "    A[Start] --> B{Decision}\n")
      (insert "    B -->|Yes| C[Action 1]\n")
      (insert "    B -->|No| D[Action 2]\n")
      (insert "#+end_src\n\n")
      (message "C-c C-c to render Mermaid → %s%s" my/diagram-output-dir fname))))

;; ── 4.10 Quick LaTeX Formula ──────────────────────────────────────────────

(defun my/insert-latex-formula ()
  "Insert an inline LaTeX formula block."
  (interactive)
  (insert "\\[\n")
  (insert "  \\int_{-\\infty}^{+\\infty} e^{-x^2} \\, dx = \\sqrt{\\pi}\n")
  (insert "\\]\n")
  (message "C-c C-x C-l to preview LaTeX fragment"))

;; ═══════════════════════════════════════════════════════════════════════════
;; 5. ADVANCED: GENERIC BIT-FIELD GENERATOR
;; ═══════════════════════════════════════════════════════════════════════════

(defun my/generate-bitfield (name fields formula)
  "Generate a TikZ bit-field diagram from a specification.

NAME  : string title of the register/word
FIELDS: list of (label bit-count color) tuples
FORMULA: optional string shown below the diagram

Example:\n  (my/generate-bitfield \"IEEE 754\"
    '((\"s\" 1 \"orange\") (\"e\" 8 \"green\") (\"m\" 23 \"cyan\"))
    \"(-1)^s * (1.m) * 2^(e-127)\")"
  (interactive
   (list (read-string "Register name: " "MyRegister")
         (read-string "Fields (label:bits:color,...): "
                      "s:1:orange,e:8:green,m:23:cyan")
         (read-string "Formula (optional): " "")))
  (let* ((parsed-fields
          (mapcar (lambda (s)
                    (let ((parts (split-string s ":")))
                      (list (nth 0 parts)
                            (string-to-number (nth 1 parts))
                            (or (nth 2 parts) "gray"))))
                  (split-string fields ",")))
         (fname (format-time-string "bitfield-%Y%m%d-%H%M%S.png"))
         (total-bits (cl-reduce #'+ parsed-fields :key #'cadr))
         (box-width 8)
         (current-x 0))
    (insert (format "#+begin_src latex :file %s%s :imagemagick yes :iminoptions -density 300\n"
                    my/diagram-output-dir fname))
    (insert "\\begin{tikzpicture}[\n")
    (insert "    box/.style={draw, minimum width=8mm, minimum height=8mm, font=\\small\\bfseries, text=white},\n")
    (insert "    label/.style={font=\\small}\n")
    (insert "]\n\n")
    (insert (format "  %% %s (%d bits)\n" name total-bits))

    ;; Draw boxes
    (dolist (field parsed-fields)
      (let* ((label (car field))
             (bits (cadr field))
             (color (caddr field))
             (width (* bits box-width)))
        (insert (format "  \\node[box, fill=%s!60, minimum width=%dmm] at (%d,0) {%s};\n"
                        color width current-x label))
        (setq current-x (+ current-x width))))

    (insert "\n")

    ;; Draw formula if provided
    (when (and formula (not (string-empty-p formula)))
      (insert (format "  \\node at (%d,-1.2) {$%s$};\n"
                      (/ (* total-bits box-width) 2) formula)))

    (insert "\\end{tikzpicture}\n")
    (insert "#+end_src\n\n")
    (message "C-c C-c to render bit-field → %s%s" my/diagram-output-dir fname)))

;; ═══════════════════════════════════════════════════════════════════════════
;; 6. KEYMAP BINDINGS
;; ═══════════════════════════════════════════════════════════════════════════

;; Re-use or extend the C-c d prefix from custom-post-sketch.el
(unless (boundp 'my/sketch-prefix)
  (define-prefix-command 'my/sketch-prefix)
  (global-set-key (kbd "C-c d") 'my/sketch-prefix))

(define-key my/sketch-prefix (kbd "u") #'my/insert-plantuml-block)
(define-key my/sketch-prefix (kbd "t") #'my/insert-ditaa-block)
(define-key my/sketch-prefix (kbd "z") #'my/insert-tikz-block)
(define-key my/sketch-prefix (kbd "b") #'my/insert-tikz-bitfield)
(define-key my/sketch-prefix (kbd "c") #'my/insert-tikz-circuit)
(define-key my/sketch-prefix (kbd "p") #'my/insert-tikz-physics)
(define-key my/sketch-prefix (kbd "m") #'my/insert-tikz-math-plot)
(define-key my/sketch-prefix (kbd "g") #'my/insert-graphviz-block)
(define-key my/sketch-prefix (kbd "M") #'my/insert-mermaid-block)
(define-key my/sketch-prefix (kbd "f") #'my/insert-latex-formula)
(define-key my/sketch-prefix (kbd "B") #'my/generate-bitfield)
(define-key my/sketch-prefix (kbd "D") #'my/ensure-diagram-dir)

;; ═══════════════════════════════════════════════════════════════════════════
;; 7. DIAGNOSTIC / STATUS COMMAND
;; ═══════════════════════════════════════════════════════════════════════════

(defun my/diagram-status ()
  "Show status of all diagram tools."
  (interactive)
  (with-output-to-temp-buffer "*Diagram Status*"
    (princ "═══════════════════════════════════════════════════\n")
    (princ "  DIAGRAM TOOL STATUS\n")
    (princ "═══════════════════════════════════════════════════\n\n")
    (princ (format "Java         : %s\n"
                   (if my/java-path my/java-path "NOT FOUND")))
    (princ (format "PlantUML jar : %s\n"
                   (if (and my/plantuml-jar (file-exists-p my/plantuml-jar))
                       my/plantuml-jar "NOT FOUND")))
    (princ (format "LaTeX        : %s\n"
                   (if my/miktex-bin my/miktex-bin "NOT FOUND")))
    (princ (format "ImageMagick  : %s\n"
                   (if my/imagemagick-path my/imagemagick-path "NOT FOUND")))
    (princ (format "Mermaid CLI  : %s\n"
                   (if my/mermaid-cli my/mermaid-cli "NOT FOUND")))
    (princ (format "Output dir   : %s\n" my/diagram-output-dir))
    (princ "\n═══════════════════════════════════════════════════\n")
    (princ "Keymap: C-c d [key]\n")
    (princ "  u → PlantUML    t → Ditaa      z → TikZ generic\n")
    (princ "  b → Bit-field   c → Circuit    p → Physics\n")
    (princ "  m → Math plot   g → Graphviz   M → Mermaid\n")
    (princ "  f → Formula     B → Gen bit-field  D → Ensure dir\n")
    (princ "═══════════════════════════════════════════════════\n")))

(define-key my/sketch-prefix (kbd "?") #'my/diagram-status)

;; ═══════════════════════════════════════════════════════════════════════════
;; 8. INITIALISATION MESSAGE
;; ═══════════════════════════════════════════════════════════════════════════

(message "[diagram] custom-post-diagram.el loaded — C-c d ? for status")

;;; custom-post-diagram.el ends here
