;;; custom-post-ai.el --- AI multi-model configuration  -*- lexical-binding: t no-byte-compile: t -*-

;;; Commentary:
;;; Multi-model AI integration: gptel + org-ai backends
;;;   - GPT-4o / Claude          (default)
;;;   - MiniMax M2.7            (https://api.minimax.io, OpenAI-compatible)
;;;   - OpenCode Go             (https://opencode.ai/zen/go/, OpenAI-compatible)
;;;   - Ollama local            (http://localhost:11434)
;;;
;;; Quick switch:
;;;   M-x gptel-menu  (C-c C-g when gptel is active)
;;;   M-x my/set-gptel-backend-mini
;;;   M-x my/set-gptel-backend-opencode
;;;   M-x my/set-gptel-backend-gpt4o

;;; Code:

;; ── gptel :ensure t ──────────────────────────────────────────────────────
(use-package gptel
  :ensure t
  :defer t
  :init
  (setq gptel-default-mode 'org-mode)
  (setq gptel-use-streaming t)
  (setq gptel-org-cycle-comments t))

;; ── Backend definitions (executed after-emacs-init) ──────────────────────
;; Each call to `gptel-make-*' returns a backend object stored in gptel-backends.

(defun my/gptel-init-backends ()
  "Create all gptel backends.  Called once after init."
  ;; Claude
  (unless (gptel-get-backend "Claude")
    (ignore-errors
      (gptel-make-anthropic "Claude"
        :key (or (getenv "ANTHROPIC_API_KEY") "")
        :models '(claude-3-5-sonnet-20241022 claude-3-opus-20240229))))

  ;; GPT-4o
  (unless (gptel-get-backend "GPT-4o")
    (ignore-errors
      (gptel-make-openai "GPT-4o"
        :key (or (getenv "OPENAI_API_KEY") "")
        :models '(gpt-4o gpt-4-turbo gpt-4))))

  ;; MiniMax M2.7  (OpenAI-compatible endpoint)
  ;; Doc: https://www.minimax.io/models/text/m27
  (unless (gptel-get-backend "MiniMax")
    (ignore-errors
      (gptel-make-openai "MiniMax"
        :host "api.minimax.io"
        :endpoint "/v1/text/chatcompletion_v2"
        :key (or (getenv "MINIMAX_API_KEY") "")
        :models '("MiniMax-M2.7" "MiniMax-M2.7-highspeed")
        :stream t)))

  ;; OpenCode Go  (OpenAI-compatible aggregator)
  ;; Doc: https://opencode.ai/docs/go/
  (unless (gptel-get-backend "OpenCode Go")
    (ignore-errors
      (gptel-make-openai "OpenCode Go"
        :host "opencode.ai"
        :endpoint "/zen/go/v1/chat/completions"
        :key (or (getenv "OPENCODE_API_KEY") "")
        :models '("kimi-k2.6" "deepseek-v4-pro" "deepseek-v4-flash")
        :stream t)))

  ;; Ollama (local)
  (unless (gptel-get-backend "Ollama")
    (ignore-errors
      (gptel-make-ollama "Ollama"
        :host "localhost:11434"
        :key (or (getenv "OLLAMA_API_KEY") "")
        :models '("llama3.1" "mistral" "codellama"))))

  ;; Default backend = GPT-4o
  (setq gptel-backend (or (gptel-get-backend "GPT-4o")
                          (gptel-get-backend "OpenCode Go")
                          (gptel-get-backend "MiniMax")))
  (message "[gptel] Default backend set: %s"
           (if gptel-backend (gptel-backend-name gptel-backend) "NONE")))

;; Initialise after Emacs startup, when packages are resolved.
(add-hook 'after-init-hook #'my/gptel-init-backends)

;; ── Quick-switch commands ──────────────────────────────────────────────────
(defun my/set-gptel-backend (name)
  "Switch gptel default backend to NAME."
  (interactive)
  (let ((backend (gptel-get-backend name)))
    (if backend
        (progn (setq gptel-backend backend)
               (message "[gptel] Active backend: %s -> %s"
                        name
                        (gptel-backend-name backend)))
      (message "[gptel] Backend '%s' not found" name))))

(defun my/set-gptel-backend-gpt4o () (interactive) (my/set-gptel-backend "GPT-4o"))
(defun my/set-gptel-backend-claude () (interactive) (my/set-gptel-backend "Claude"))
(defun my/set-gptel-backend-mini () (interactive) (my/set-gptel-backend "MiniMax"))
(defun my/set-gptel-backend-opencode () (interactive) (my/set-gptel-backend "OpenCode Go"))
(defun my/set-gptel-backend-ollama () (interactive) (my/set-gptel-backend "Ollama"))

;; Keybinds for fast switching  (C-c a = AI prefix)
;; Override agent-shell's C-c a binding from init-ai.el.
;; init-ai.el binds C-c a to agent-shell; we want it for our AI prefix.
(global-unset-key (kbd "C-c a"))
(define-prefix-command 'my/ai-prefix)
(global-set-key (kbd "C-c a") 'my/ai-prefix)

;; Re-assert our binding after agent-shell loads (its use-package :bind
;; may recreate autoload keymaps that could interfere).
(with-eval-after-load 'agent-shell
  (global-set-key (kbd "C-c a") 'my/ai-prefix))

;; Suppress noisy "executable not found" errors from agent-shell adapters
;; that are not installed (droid-acp, pi-acp, etc.).
(defun my/agent-shell--start-silence-missing (orig-fn &rest args)
  "Silence agent-shell--start errors about missing executables."
  (condition-case err
      (apply orig-fn args)
    (error
     (let ((msg (error-message-string err)))
        (if (or (string-match-p "Executable .* not found" msg)
                (string-match-p "not found\\.  Do you need" msg)
                (string-match-p "command line utility not found" msg))
           (message "[agent-shell] Adapter unavailable (install to use): %s"
                    (replace-regexp-in-string "\n" " " msg))
         (signal (car err) (cdr err)))))))

(with-eval-after-load 'agent-shell
  (advice-add 'agent-shell--start :around #'my/agent-shell--start-silence-missing))

(define-key my/ai-prefix (kbd "g") 'gptel-menu)
(define-key my/ai-prefix (kbd "4") 'my/set-gptel-backend-gpt4o)
(define-key my/ai-prefix (kbd "c") 'my/set-gptel-backend-claude)
(define-key my/ai-prefix (kbd "m") 'my/set-gptel-backend-mini)
(define-key my/ai-prefix (kbd "o") 'my/set-gptel-backend-opencode)
(define-key my/ai-prefix (kbd "l") 'my/set-gptel-backend-ollama)
(define-key my/ai-prefix (kbd "q") 'my/org-ai-prompt-inline)
(define-key my/ai-prefix (kbd "s") 'my/gptel-prompt-region)

;; Nested prefix C-c a z for org-ai backend switching
(define-prefix-command 'my/ai-config-prefix)
(define-key my/ai-prefix (kbd "z") 'my/ai-config-prefix)
(define-key my/ai-config-prefix (kbd "m") 'my/org-ai-use-mini)
(define-key my/ai-config-prefix (kbd "o") 'my/org-ai-use-opencode)
(define-key my/ai-config-prefix (kbd "d") 'my/org-ai-use-openai)

;; ── org-ai :ensure t ─────────────────────────────────────────────────────
;; OpenAI-compatible backends; base-url + token decide where requests go.

(use-package org-ai
  :ensure t
  :after org
  :init
  ;; Default: GPT-4o (OpenAI)
  (setq org-ai-default-chat-model "gpt-4o")
  (setq org-ai-openai-api-base-url "https://api.openai.com/v1")
  (setq org-ai-openai-api-token (or (getenv "OPENAI_API_KEY") "")))

;; ── org-ai backend switchers ──────────────────────────────────────────────
(defun my/org-ai-use-mini ()
  "Switch org-ai to MiniMax M2.7."
  (interactive)
  (setq org-ai-default-chat-model "MiniMax-M2.7")
  (setq org-ai-openai-api-base-url "https://api.minimax.io/v1/text/chatcompletion_v2")
  (setq org-ai-openai-api-token (or (getenv "MINIMAX_API_KEY") ""))
  (message "[org-ai] → MiniMax-M2.7 (%s)" org-ai-openai-api-base-url))

(defun my/org-ai-use-opencode ()
  "Switch org-ai to OpenCode Go."
  (interactive)
  (setq org-ai-default-chat-model "kimi-k2.6")
  (setq org-ai-openai-api-base-url "https://opencode.ai/zen/go/v1/chat/completions")
  (setq org-ai-openai-api-token (or (getenv "OPENCODE_API_KEY") ""))
  (message "[org-ai] → OpenCode Go (kimi-k2.6)"))

(defun my/org-ai-use-openai ()
  "Switch org-ai back to OpenAI/GPT-4o."
  (interactive)
  (setq org-ai-default-chat-model "gpt-4o")
  (setq org-ai-openai-api-base-url "https://api.openai.com/v1")
  (setq org-ai-openai-api-token (or (getenv "OPENAI_API_KEY") ""))
  (message "[org-ai] → GPT-4o (OpenAI)"))

;; ════════════════════════════════════════════════════════════════════════
;;  Summary keymap
;; ════════════════════════════════════════════════════════════════════════
;;  C-c a g   gptel-menu          (choose backend + model in gptel)
;;  C-c a 4   → GPT-4o (gptel)
;;  C-c a c   → Claude (gptel)
;;  C-c a m   → MiniMax (gptel)
;;  C-c a o   → OpenCode Go (gptel)
;;  C-c a l   → Ollama local (gptel)
;;  C-c a q   Insert #+begin_ai / #+end_ai block (org-ai)
;;  C-c a s   Send region to gptel
;;  C-c a z m → MiniMax (org-ai)
;;  C-c a z o → OpenCode Go (org-ai)
;;  C-c a z d → GPT-4o / OpenAI (org-ai)

;;; custom-post-ai.el ends here
