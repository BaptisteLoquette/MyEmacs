# Centaur Emacs — Interactive Test Checklist

Run these commands one at a time after launching Centaur (`emacs --with-profile centaur`).
Mark each line `[x]` once you confirm it works.

---

## □ 1. Launch Centaur

```powershell
# In PowerShell:
& "C:\Program Files\Emacs\emacs-30.2\bin\emacs.exe" --with-profile centaur --debug-init
```

- [ ] Centaur dashboard appears (or a clean Emacs frame)
- [ ] No red error messages in the echo area (bottom of screen)
- [ ] `C-h e` (open *Messages*) shows no `Error: ...` near the end

---

## □ 2. Check Package Installation (first boot only)

On first launch Centaur downloads ~30 packages. This can take 2-5 minutes.

- [ ] `M-x list-packages` → shows packages from MELPA
- [ ] No "Failed to install X" messages in *Messages*

---

## □ 3. Org Mode Baseline

Open a test Org file:
```
C-x C-f ~/org/test.org
```

Type and verify:
- [ ] `* Heading 1` → press `TAB` → folds correctly
- [ ] `** Sub-heading :math:` → `C-c C-q` shows `:math:` tag
- [ ] Inline image display: paste a `[file:~/org/images/test.png]` link → renders inline (if file exists)

---

## □ 4. Org Babel (Code Execution)

In `test.org`, insert:
```org
#+begin_src python :results output
print("Hello from Emacs")
#+end_src
```

- [ ] `C-c C-c` on the block → mini-buffer asks "Evaluate?" → confirm
- [ ] `#+RESULTS:` appears with output

---

## □ 5. Org-roam v2

```
C-c n r    (org-roam-node-random)   → opens a random node (empty on first run)
C-c n f    (org-roam-node-find)     → creates a new node
```

- [ ] Type "Test Node" → new file `~/org/roam/20260430-test_node.org` created
- [ ] File has an `#+title: Test Node` property

---

## □ 6. Org-ql Tag Search

In the test.org file, create:
```org
* Test Heading :math:
** Sub with :math:
```

- [ ] `C-c n #` on the first heading → `org-ql by tag:` → pick `:math:` → results buffer appears
- [ ] Results show all headings tagged `:math:`

---

## □ 7. Tag-Based Node Navigation

Create two roam nodes with the same tag:
```
C-c n f → "Algebra" (add tag :math:)
C-c n f → "Calculus" (add tag :math:)
```

Place cursor in the "Algebra" heading.
- [ ] `C-c n s` → shows completions `"math"` → select → all `:math:` nodes listed
- [ ] Pick "Calculus" → opens the Calculus node
- [ ] `C-c n .` on "Algebra" → inserts `[[id:...][Calculus]]` at point

---

## □ 8. Org-transclusion

In `test.org`:
```org
#+transclude: [[file:~/org/roam/algebra.org]]
```

- [ ] `C-c n t` on the link → content of Algebra.org appears inline
- [ ] `C-c n T` → toggle transclusion off/on

---

## □ 9. PDF Tools

Open a PDF:
```
C-x C-f C:\Users\Bapti\Downloads\some-paper.pdf
```

- [ ] PDF renders inside Emacs (not external Acrobat)
- [ ] Scroll with `C-v` / `M-v` works

---

## □ 10. Citation (citar)

In `test.org`:
```
C-c o b    (citar-insert-citation)
```

- [ ] Shows authors from `~/org/references.bib`
- [ ] Select one → `[cite:@smith2024]` inserted at point

---

## □ 11. Web Capture (org-web-tools)

Select any URL in a buffer or type manually:

- [ ] `C-c w o` → prompt for URL → `https://en.wikipedia.org/wiki/Org-mode`
- [ ] New Org buffer appears with page content
- [ ] `C-x C-w ~/org/wiki-org.org` → save the file

- [ ] `C-c w a` → URL prompt → same Wikipedia page
- [ ] File saved to `~/org/web-archive/2026-04-30-org-mode.org`
- [ ] File opens, `org-remark-mode` enabled

---

## □ 12. Org-remark (Annotation)

In the captured web file:
- [ ] Select some text → `C-c w h` → highlight appears
- [ ] `C-c w n` → opens `~/org/margin-notes.org` with annotation
- [ ] Edit the annotation → save → `C-x C-s`
- [ ] Close and reopen the web file → `C-c w m` shows highlights

---

## □ 13. AI / GPTel

Set API keys first (via system environment variables).

- [ ] `C-c a g` → `gptel-menu` opens
- [ ] Type a prompt → press `RET` → response appears in buffer
- [ ] `C-c a m` → switches to MiniMax backend
- [ ] `C-c a o` → switches to OpenCode Go backend

---

## □ 14. org-ai (in Org blocks)

In `test.org`:
```org
#+begin_ai
What is the derivative of x²?
#+end_ai
```

- [ ] `C-c C-c` on the block → prompts `org-ai-openai-api-token` if not set
- [ ] After setting token → response fills the block

---

## □ 15. Diagnostics

- [ ] `M-x org-roam-db-sync` → no error
- [ ] `M-x org-id-update-id-locations` → no error, file created

---

## Troubleshooting

### "Could not read org-id-locations"
Already fixed. But if it happens:
```
M-x org-id-update-id-locations
```

### "Package X not found"
Package not yet installed. Wait for Centaur to finish downloading, or:
```
M-x package-refresh-contents
M-x package-install RET X RET
```

### "No roam nodes found"
Need to create roam directory:
```
M-x mkdir RET ~/org/roam RET
```
Then `C-c n f` to create nodes.

### "curl not found" (web tools)
Windows doesn't ship curl by default. Options:
1. Install git-for-windows (includes curl) → https://git-scm.com/download/win
2. Enable Windows subsystem: `dism /online /Enable-Feature /FeatureName:TelnetClient` (not ideal)
3. Place `curl.exe` in PATH

### "pandoc not found"
Optional. Install via:
```powershell
winget install JohnMacFarlane.Pandoc
```
