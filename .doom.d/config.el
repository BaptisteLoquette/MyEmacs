(when IS-WIN
  (setq shell-file-name "C:/Program Files/Git/bin/bash.exe")
  (setq explicit-shell-file-name "C:/Program Files/Git/bin/bash.exe")
  ;; vterm can still use cmdproxy if preferred
  (setq-default vterm-shell "C:/Program Files/Emacs/emacs-30.2/libexec/emacs/30.2/x86_64-w64-mingw32/cmdproxy.exe"))

;; ── Jupyter / Python config (existing) ──────────────────────────────────
(after! ob-jupyter
  ;; Make standard `python' src blocks use the Jupyter python kernel.
  (org-babel-jupyter-override-src-block "python")

  ;; Default header args for jupyter-python blocks
  (setq org-babel-default-header-args:jupyter-python
        '((:session . "py")
          (:async . "yes")
          (:kernel . "python3")
          (:results . "replace drawer")
          (:exports . "both")))

  ;; Load our dark-theme prologue into jupyter-python as well
  (add-to-list 'org-babel-default-header-args:jupyter-python
               '(:prologue . "exec(open('C:/Users/Bapti/.emacs.d/header.py').read())"))

  ;; Directory for auto-generated images from Jupyter blocks
  (setq org-babel-jupyter-resource-directory "./.jupyter-resources/")

  ;; Enable client-side request queuing (prevents kernel overload)
  (setq jupyter-org-queue-requests t))

;; ── Jupyter REPL configuration ─────────────────────────────────────────
(after! jupyter-repl
  ;; Truncate REPL buffer to prevent memory bloat
  (setq jupyter-repl-maximum-size 1000)
  ;; Allow RET to insert newlines when kernel is busy
  (setq jupyter-repl-allow-RET-when-busy t))

;; ── Helper: fetch key from auth-source by host ─────────────────────────
(defun my/gptel-key (host)
  "Return the API key for HOST from auth-source."
  (lambda ()
    (or (auth-source-pick-first-password :host host)
        (error "No auth-source entry for host: %s" host))))

;; ── 1. Anthropic (Claude) — default fallback ────────────────────────────
(setq gptel-model 'claude-sonnet-4-20250514)
(setq gptel-backend
      (gptel-make-anthropic "Anthropic"
        :host "api.anthropic.com"
        :endpoint "/v1/messages"
        :stream t
        :key (my/gptel-key "api.anthropic.com")))

;; ── 2. MiniMax Coding Plan API ──────────────────────────────────────────
(gptel-make-openai "MiniMax"
  :host "api.minimax.chat"
  :endpoint "/v1/chat/completions"
  :protocol "https"
  :stream t
  :key (my/gptel-key "api.minimax.chat")
  :models '(MiniMax-Text-01
            MiniMax-M1-Dev
            abab6.5s-chat))

;; ── 3. Opencode Go plan API ─────────────────────────────────────────────
(gptel-make-openai "Opencode"
  :host "openrouter.ai"
  :endpoint "/api/v1/chat/completions"
  :protocol "https"
  :stream t
  :key (my/gptel-key "openrouter.ai")
  :models '(gpt-4o
            claude-sonnet-4-20250514
            deepseek-chat))

;; ── 4. Hermes gateway models API ────────────────────────────────────────
(gptel-make-openai "Hermes"
  :host "openrouter.ai"
  :endpoint "/api/v1/chat/completions"
  :protocol "https"
  :stream t
  :key (my/gptel-key "openrouter.ai")
  :models '(nousresearch/hermes-3-llama-3.1-405b
            nousresearch/hermes-3-llama-3.1-70b
            nousresearch/hermes-2-pro-llama-3-8b))

(defvar my/gptel-backends '("Anthropic" "MiniMax" "Opencode" "Hermes")
  "Ordered list of registered gptel backend names.")

(defun my/gptel-cycle-backend (&optional arg)
  "Switch gptel backend to the next one in `my/gptel-backends'.
With prefix ARG, prompt for a backend directly."
  (interactive "P")
  (if arg
      (let* ((names my/gptel-backends)
             (choice (completing-read "Backend: " names nil t))
             (backend (gptel-get-backend choice)))
        (setq gptel-backend backend)
        (message "GPTel backend → %s (%s)"
                 choice (gptel-backend-name backend)))
    (let* ((current (gptel-backend-name gptel-backend))
           (idx (cl-position current my/gptel-backends :test #'string=))
           (next-idx (mod (1+ (or idx -1)) (length my/gptel-backends)))
           (next-name (nth next-idx my/gptel-backends))
           (next-backend (gptel-get-backend next-name)))
      (setq gptel-backend next-backend)
      (message "GPTel backend → %s (%s)"
               next-name (gptel-backend-name next-backend)))))

(defun my/gptel-show-backend ()
  "Display the currently active gptel backend and model."
  (interactive)
  (message "Current: %s / %s"
           (gptel-backend-name gptel-backend)
           gptel-model))

(use-package! org-ai
  :commands (org-ai-complete-block org-ai-prompt org-ai-summarize org-ai-on-region)
  :hook (org-mode . org-ai-mode)
  :config
  ;; Default to Anthropic for org-ai as well
  (setq org-ai-default-model "claude-sonnet-4-20250514")
  (setq org-ai-openai-api-token
        (lambda () (auth-source-pick-first-password :host "api.anthropic.com"))))

(after! evil
  ;; Doom's default binds SPC a to "applications" (email, irc, rss).
  ;; We have no :app modules, so reclaim SPC a for AI.
  (map! :leader
        "a" nil                       ; clear Doom's default apps prefix
        (:prefix ("a" . "ai")
         ;; gptel (chat-centric)
         :desc "GPTel chat"          "c" #'gptel
         :desc "GPTel send region"   "s" #'gptel-send
         :desc "GPTel transient menu" "m" #'gptel-menu
         ;; backend switching
         :desc "Cycle AI backend"   "." #'my/gptel-cycle-backend
         :desc "Show AI backend"    "," #'my/gptel-show-backend
         ;; org-ai (org-centric)
         :desc "org-ai complete block" "b" #'org-ai-complete-block
         :desc "org-ai prompt"        "q" #'org-ai-prompt
         :desc "org-ai summarize"     "u" #'org-ai-summarize
         :desc "org-ai on region"     "r" #'org-ai-on-region)))

(map! :leader
      (:prefix ("o" . "open")
       :desc "Jupyter REPL" "r" #'jupyter-run-repl))

;; Evil-normal-state bindings inside Jupyter REPL buffers
(after! jupyter-repl
  (evil-define-key 'normal jupyter-repl-mode-map
    (kbd "C-c C-c") #'jupyter-repl-interrupt-kernel
    (kbd "C-c C-r") #'jupyter-repl-restart-kernel
    (kbd "C-c C-o") #'jupyter-eval-remove-overlays))


;; ============================================================================
;; DRAWING, DIAGRAMS & ORG-BABEL LANGUAGES
;; ============================================================================

;; ---------------------------------------------------------------------------
;; 1. ORG-BABEL LANGUAGE REGISTRY  (single source of truth)
;; ---------------------------------------------------------------------------
;; CRITICAL: org-babel-do-load-languages REPLACES the variable; calling it
;; twice causes the second call to overwrite the first.  We therefore register
;; EVERY language in ONE place inside a single (after! org ...) block.
;; ---------------------------------------------------------------------------

(after! org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python    . t)
     (shell     . t)
     (dot       . t)
     (plantuml  . t)
     (ditaa     . t)
     (mermaid   . t)
     (gnuplot   . t)
     (latex     . t)
     (emacs-lisp . t)
     ;; ------------------------------------------------------------------
     ;; TEMPLATE — uncomment AFTER installing the external binary:
     ;; ------------------------------------------------------------------
     ;; (R       . t)   ; needs R.exe   (https://cran.r-project.org/)
     ;; (matlab  . t)   ; needs MATLAB or Octave on PATH
     ;; (ruby    . t)   ; needs ruby.exe
     ;; (js      . t)   ; needs node.exe
     ;; (sqlite  . t)   ; needs sqlite3.exe
     ;; (makefile . t)  ; needs make.exe
     )))

;; ---------------------------------------------------------------------------
;; 2. EXTERNAL-TOOL PATHS  (absolute paths avoid "command not found" on Win)
;; ---------------------------------------------------------------------------

;; --- Graphviz (dot) ---
(setq graphviz-dot-indent-width 2)
(setq graphviz-dot-program "C:/Program Files/Graphviz/bin/dot.exe")
(setq org-babel-default-header-args:dot
      '((:results . "file graphics")
        (:exports . "both")
        (:file . "images/diagram.svg")))

;; --- PlantUML ---
(setq org-plantuml-jar-path "C:/tools/plantuml.jar")
(setq org-plantuml-java-command
      "C:/Program Files/Eclipse Adoptium/jre-21.0.10.7-hotspot/bin/java.exe")
(setq org-babel-default-header-args:plantuml
      '((:results . "file graphics")
        (:exports . "both")
        (:file . "images/plantuml.png")))

;; --- Ditaa ---
(setq org-ditaa-jar-path "C:/tools/ditaa.jar")
(setq org-ditaa-java-command
      "C:/Program Files/Eclipse Adoptium/jre-21.0.10.7-hotspot/bin/java.exe")
(setq org-babel-default-header-args:ditaa
      '((:results . "file graphics")
        (:exports . "both")
        (:file . "images/ditaa.png")
        (:java . "-Dfile.encoding=UTF-8")))

;; --- Gnuplot ---
;; If you install gnuplot later, update this path:
(setq gnuplot-program
      (or (executable-find "gnuplot")
          "C:/Program Files/gnuplot/bin/gnuplot.exe"))
(setq org-babel-default-header-args:gnuplot
      '((:results . "file graphics")
        (:exports . "both")
        (:file . "images/gnuplot.svg")))

;; --- R (template — uncomment after installing R) ---
;; (setq org-babel-R-command "R.exe")
;; (setq org-babel-default-header-args:R
;;       '((:results . "file graphics")
;;         (:exports . "both")))

;; --- MATLAB / Octave (template — uncomment after installing) ---
;; Org has built-in `octave' support.  For MATLAB proper use a shell block
;; or the jupyter-matlab kernel.
;; (setq org-babel-default-header-args:octave
;;       '((:results . "file graphics")
;;         (:exports . "both")))

;; ---------------------------------------------------------------------------
;; 3. PYTHON / MATPLOTLIB (non-interactive backend for babel)
;; ---------------------------------------------------------------------------
(after! python
  (setenv "MPLBACKEND" "Agg")
  (setq org-babel-python-command "python")
  (setenv "PYTHONWARNINGS" "ignore::DeprecationWarning"))

;; ---------------------------------------------------------------------------
;; 4. DEFAULT HEADER ARGS (by language)
;; ---------------------------------------------------------------------------
(setq org-babel-default-header-args:python
      '((:results . "file graphics")
        (:session . "none")
        (:exports . "both")))

;; ---------------------------------------------------------------------------
;; 5. ASCII / UNICODE / EMBEDDED DRAWING MODES
;; ---------------------------------------------------------------------------

;; uniline-mode
(use-package! uniline
  :commands (uniline-mode)
  :init
  (map! :leader
        (:prefix ("d" . "draw")
         :desc "Uniline mode" "u" #'uniline-mode))
  :config
  (setq uniline-brush-set 'uniline-brush-set-thin))

;; el-easydraw
(use-package! edraw-org
  :after org
  :config
  (edraw-org-setup-default))

;; sketch-mode
(use-package! sketch-mode
  :commands (sketch)
  :init
  (map! :leader
        (:prefix ("d" . "draw")
         :desc "Sketch (SVG paint)" "s" #'sketch)))

;; Drawing keymap
(map! :leader
      (:prefix ("d" . "draw")
       :desc "Artist mode (mouse ASCII)" "a" #'artist-mode
       :desc "Picture mode (keyboard ASCII)" "p" #'picture-mode
       :desc "Toggle inline images" "i" #'org-toggle-inline-images))

;; ---------------------------------------------------------------------------
;; 6. INLINE IMAGE DISPLAY
;; ---------------------------------------------------------------------------
(after! org
  ;; Refresh images after babel execution
  (add-hook 'org-babel-after-execute-hook
            #'org-redisplay-inline-images)

  ;; Respect #+ATTR_* width attributes
  (setq org-image-actual-width nil)

  ;; Remote image support
  (setq org-display-remote-inline-images 'download)

  ;; SVG rendering helper (ImageMagick or similar)
  (setq org-image-convert-program
        (or (executable-find "convert")
            (executable-find "magick"))))

;; ============================================================================
;; EWW — SERIOUS READING ENVIRONMENT
;; ============================================================================

;; Keep lines at a readable width (like a book)
(setq shr-width 80)

;; Wrap lines at word boundaries
(add-hook 'eww-mode-hook 'visual-line-mode)

;; Use a proportional font for body text (monospace stays for code)
(add-hook 'eww-mode-hook 'variable-pitch-mode)

;; Use DuckDuckGo HTML lite for instant, no-JS results
(setq eww-search-prefix "https://html.duckduckgo.com/html/?q=")

;; ── Global keybindings (C-c is reserved for user bindings in Emacs) ──

;; C-c w : open link at point in EWW
(global-set-key (kbd "C-c w") 'eww-browse-url)

;; C-c s : search web for word/region at point
(global-set-key (kbd "C-c s") 'eww-search-words)

;; C-c a : search arXiv for word/region at point
(defun my/eww-search-arxiv (query)
  "Search arXiv for QUERY, or word/region at point if called interactively."
  (interactive
   (list (if (use-region-p)
             (buffer-substring-no-properties (region-beginning) (region-end))
           (thing-at-point 'word t))))
  (eww-browse-url
   (format "https://arxiv.org/search/?query=%s&searchtype=all"
           (url-hexify-string (or query "")))))
(global-set-key (kbd "C-c a") 'my/eww-search-arxiv)

;; C-c g : search Google Scholar for word/region at point
(defun my/eww-search-scholar (query)
  "Search Google Scholar for QUERY, or word/region at point if called interactively."
  (interactive
   (list (if (use-region-p)
             (buffer-substring-no-properties (region-beginning) (region-end))
           (thing-at-point 'word t))))
  (eww-browse-url
   (format "https://scholar.google.com/scholar?q=%s"
           (url-hexify-string (or query "")))))
(global-set-key (kbd "C-c g") 'my/eww-search-scholar)

;; ============================================================================
;; ELLAMA — LLM PROVIDERS (Ollama, Opencode Go, MiniMax)
;; ============================================================================

;; Reuse the auth-source helper pattern from gptel config above
(defun my/ellama-key (host)
  "Return an API key fetcher for HOST via auth-source."
  (lambda ()
    (or (auth-source-pick-first-password :host host)
        (error "No auth-source entry for host: %s" host))))

;; ── 1. OLLAMA (local / cloud instance) ─────────────────────────────────────
;; Ellama can discover Ollama models interactively, but we explicitly set a
;; default.  Change :host / :port if your Ollama runs on another machine.
(require 'llm-ollama)

(setq ellama-provider
      (make-llm-ollama
       :chat-model "qwen2.5:3b"          ; change to your preferred pulled model
       :embedding-model "nomic-embed-text"
       :default-chat-non-standard-params '(("num_ctx" . 8192))))

;; ── 2. OPENCODE GO via OpenRouter ──────────────────────────────────────────
;; OpenRouter exposes OpenAI-compatible chat completions.
(require 'llm-openai)

(defvar my/ellama-opencode-provider
  (make-llm-openai-compatible
   :url "https://openrouter.ai/api/v1/"
   :key (my/ellama-key "openrouter.ai")
   :chat-model "gpt-4o"
   :embedding-model "unset"
   :default-chat-non-standard-params '(("num_ctx" . 32768)))
  "Opencode Go provider via OpenRouter.")

;; ── 3. MINIMAX CODING PLAN API ─────────────────────────────────────────────
(defvar my/ellama-minimax-provider
  (make-llm-openai-compatible
   :url "https://api.minimax.chat/v1/"
   :key (my/ellama-key "api.minimax.chat")
   :chat-model "MiniMax-Text-01"
   :embedding-model "unset"
   :default-chat-non-standard-params '(("num_ctx" . 32768)))
  "MiniMax Coding Plan provider.")

;; ── Provider registry for interactive switching ────────────────────────────
;; Ellama uses `ellama-providers' as an alist of ("name" . provider).
;; Ollama models are auto-discovered, so we only register the cloud ones.
(setq ellama-providers
      `(("Opencode" . ,my/ellama-opencode-provider)
        ("MiniMax"  . ,my/ellama-minimax-provider)))

;; ── Optional: task-specific providers ──────────────────────────────────────
;; You can dedicate a provider to coding tasks, another to summarization, etc.
;; When nil, ellama falls back to `ellama-provider'.

;; (setq ellama-coding-provider my/ellama-minimax-provider)
;; (setq ellama-summarization-provider my/ellama-opencode-provider)
;; (setq ellama-translation-provider my/ellama-opencode-provider)

;; ── Ellama UX tweaks ───────────────────────────────────────────────────────
(setq ellama-language "English")
(setq ellama-auto-scroll t)
(setq ellama-naming-scheme 'ellama-generate-name-by-llm)

;; Keep sessions out of ~/.doom.d (avoids Org hang in Doom's doc folder)
(setq ellama-sessions-directory "~/.emacs.d/.local/cache/ellama-sessions")

;; ── Keybinding ─────────────────────────────────────────────────────────────
;; Bind the main ellama transient menu.  Change prefix if it conflicts.
(global-set-key (kbd "C-c e") 'ellama)


;; ============================================================================
;; AIDER — AI Pair Programming (multi-provider)
;; ============================================================================

;; Helper: fetch raw API key string for aider (gptel-key returns a lambda)
(defun my/aider-api-key (host)
  "Get API key string from auth-source for HOST."
  (or (auth-source-pick-first-password :host host)
      (warn "No auth-source entry for host: %s" host)))

;; Set global env vars that aider inherits.
;; OpenRouter = most versatile default (OpenCode Go, Hermes, Sonnet, etc.)
;; Ollama base = always available for local models.
(setenv "OPENROUTER_API_KEY" (my/aider-api-key "openrouter.ai"))
(setenv "OLLAMA_API_BASE" "http://127.0.0.1:11434")

(use-package! aider
  :config
  ;; Extend aider-popular-models with all providers you use.
  ;; aider-change-model (SPC A p o or C-c a o) reads from this list.
  (setq aider-popular-models
        '(
          ;; ── OpenRouter (default — most flexible) ──
          "openrouter/anthropic/claude-3.7-sonnet"
          "openrouter/openai/gpt-4o"
          "openrouter/openai/o4-mini"
          "openrouter/nousresearch/hermes-3-llama-3.1-405b"
          "openrouter/nousresearch/hermes-3-llama-3.1-70b"
          "openrouter/nousresearch/hermes-2-pro-llama-3-8b"
          "openrouter/deepseek/deepseek-chat"
          "openrouter/deepseek/deepseek-reasoner"
          ;; ── Ollama (local) ──
          "ollama_chat/qwen2.5-coder:latest"
          "ollama_chat/deepseek-r1:latest"
          "ollama_chat/llama3.2:latest"
          ;; ── MiniMax (OpenAI-compatible) ──
          "openai/MiniMax-Text-01"
          "openai/abab6.5s-chat"
          ;; ── Native aliases (if keys are set) ──
          "sonnet"
          "o4-mini"
          "deepseek/deepseek-reasoner"))

  ;; Default args: no fixed model so aider auto-picks from available keys.
  ;; --no-auto-accept-architect lets you review changes before applying.
  ;; --no-auto-commits keeps git history clean.
  (setq aider-args '("--no-auto-accept-architect" "--no-auto-commits"))

  ;; Enable official Doom integration (provides SPC A prefix in git buffers)
  (require 'aider-doom))

;; ── Provider-specific aider starters ───────────────────────────────────────
;; Each function starts a *new* aider session with the correct API endpoint.
;; Use these when you want a specific provider.  For same-provider model
;; switching, use aider-change-model (o) inside the running session.

(defun my/aider-openrouter (model)
  "Start aider with an OpenRouter MODEL."
  (interactive
   (list (completing-read "OpenRouter model: "
                          '("openrouter/anthropic/claude-3.7-sonnet"
                            "openrouter/openai/gpt-4o"
                            "openrouter/openai/o4-mini"
                            "openrouter/nousresearch/hermes-3-llama-3.1-405b"
                            "openrouter/nousresearch/hermes-3-llama-3.1-70b"
                            "openrouter/nousresearch/hermes-2-pro-llama-3-8b"
                            "openrouter/deepseek/deepseek-chat"
                            "openrouter/deepseek/deepseek-reasoner")
                          nil t)))
  (setenv "OPENROUTER_API_KEY" (my/aider-api-key "openrouter.ai"))
  (let ((aider-args `("--model" ,model
                      "--no-auto-accept-architect"
                      "--no-auto-commits")))
    (aider-run-aider)))

(defun my/aider-ollama (model)
  "Start aider with a local Ollama MODEL."
  (interactive
   (list (completing-read "Ollama model: "
                          '("ollama_chat/qwen2.5-coder:latest"
                            "ollama_chat/deepseek-r1:latest"
                            "ollama_chat/llama3.2:latest")
                          nil t)))
  (setenv "OLLAMA_API_BASE" "http://127.0.0.1:11434")
  (let ((aider-args `("--model" ,model
                      "--no-auto-accept-architect"
                      "--no-auto-commits")))
    (aider-run-aider)))

(defun my/aider-minimax (model)
  "Start aider with MiniMax MODEL via OpenAI-compatible API."
  (interactive
   (list (completing-read "MiniMax model: "
                          '("openai/MiniMax-Text-01"
                            "openai/abab6.5s-chat")
                          nil t)))
  ;; MiniMax uses OpenAI-compatible endpoint; we override OPENAI_API_BASE.
  ;; This means you cannot mix MiniMax with real OpenAI in the same session.
  (setenv "OPENAI_API_BASE" "https://api.minimax.chat/v1")
  (setenv "OPENAI_API_KEY" (my/aider-api-key "api.minimax.chat"))
  (let ((aider-args `("--model" ,model
                      "--no-auto-accept-architect"
                      "--no-auto-commits")))
    (aider-run-aider)))

;; ── Integration into existing SPC a AI prefix ──────────────────────────────
(after! evil
  (map! :leader
        (:prefix ("a" . "ai")
         :desc "Aider (OpenRouter)" "d" #'my/aider-openrouter
         :desc "Aider (Ollama)"     "D" #'my/aider-ollama
         :desc "Aider (MiniMax)"    "M" #'my/aider-minimax)))

;; Auto-revert buffers so aider's file changes appear instantly
(global-auto-revert-mode 1)


;; ============================================================================
;; WINDOWS-SPECIFIC FIXES
;; ============================================================================

;; ── 1. Julia module bug: modulep! fails in declare completion predicates ───
;; Doom's julia autoloads use (modulep! +snail) inside `declare' forms.
;; When read-extended-command-predicate evaluates them, modulep! can't
;; resolve the current module from init.30.2.el and errors repeatedly.
;; Fix: suppress the broken completion properties on these commands.
(after! julia
  (put '+julia/open-repl 'completion nil)
  (put '+julia/open-snail-repl 'completion nil))

;; ── 2. undo-fu-session needs gzip (not installed by default on Windows) ────
;; Option A: tell undo-fu-session not to compress (no gzip required)
(after! undo-fu-session
  (setq undo-fu-session-compression nil))
;; Option B: install gzip (e.g. via Git for Windows / MSYS2) and uncomment:
;; (add-to-list 'exec-path "C:/Program Files/Git/usr/bin")

;; ── 3. ispell dictionary not found on Windows ──────────────────────────────
;; Disable ispell completion backend if no dictionary is installed,
;; or install a dictionary (e.g. hunspell-en-us) and set the path:
;; (setq ispell-alternate-dictionary "C:/path/to/english.words")
(after! ispell
  ;; Silence the "No plain word-list found" warning by disabling lookup
  (setq ispell-lookup-words-function nil))

;; ── 4. Enable shift-selection in Org mode ──────────────────────────────────
;; Allows holding Shift + arrow keys to select text in Org buffers.
(after! org
  (setq org-support-shift-select t))

;; ── 5. Copilot language server path hint ───────────────────────────────────
;; If you install @github/copilot-language-server via npm, point copilot to it:
;; (setq copilot-server-executable
;;       "C:/Users/Bapti/AppData/Roaming/npm/node_modules/@github/copilot-language-server/dist/language-server.exe")
;; Or install globally:  npm install -g @github/copilot-language-server
