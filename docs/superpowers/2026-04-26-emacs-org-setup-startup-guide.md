# Emacs Org Setup — Startup Guide

> Your first 10 minutes, first day, and first week with this setup. No internals, just what to press.

---

## First Launch

```powershell
emacs
```

**What to expect:** Doom dashboard appears. First launch compiles packages (~1-2 min). Subsequent launches are ~3 seconds.

**If something looks broken:** `SPC h d d` (doom doctor) for a health check.

---

## What You're Looking At

```
┌─────────────────────────────────────────────────┐
│  [Doom Dashboard]                    [modeline]  │
│                                                  │
│  ┌──────────┬─────────────────────┬───────────┐  │
│  │          │                     │           │  │
│  │ treemacs │    main buffer      │           │  │
│  │ (F8 to   │                     │           │  │
│  │ toggle)  │                     │           │  │
│  │          │                     │           │  │
│  └──────────┴─────────────────────┴───────────┘  │
│  [doom-modeline: file | git branch | cursor]     │
│  [minibuffer: vertico completion]                │
└─────────────────────────────────────────────────┘
```

**Key:** Treemacs is hidden by default. `SPC o p` opens it. `F8` toggles.

---

## Your Keyboard Mental Model

You're in **hybrid mode**. That means:

| When you're... | Keys work like... |
|---|---|
| Editing code or text | **Vim** — `i` to insert, `Esc` for normal, `:w` to save |
| Browsing files, git, agenda | **Normal keys** — `Ctrl+c` copy, arrows navigate |

**If you ever get stuck:** `SPC t e` toggles Vim mode off completely. Press again to restore.

**To discover commands:** Press `SPC` and wait — a menu appears showing all available commands.

---

## Day 1: The 10 Commands You Actually Need

### Navigation
| Keys | What |
|---|---|
| `SPC f f` | Open any file |
| `SPC f r` | Recent files |
| `SPC b b` | Switch buffer |
| `SPC /` | Search across project (ripgrep) |

### Editing
| Keys | What |
|---|---|
| `SPC f s` | Save file |
| `SPC q q` | Quit Emacs |
| `SPC w v` | Split window vertically |
| `SPC w h/j/k/l` | Move between windows |

### Git
| Keys | What |
|---|---|
| `SPC g g` | Magit status |
| `SPC g s` | Stage current file |
| `SPC g c c` | Commit |

---

## Day 1: Taking Your First Note

Doom provides org-roam under `SPC n r` (notes → roam):

```
SPC n r n                  # Org-roam capture
  → "Today's note"         # Type your note title
  → C-c C-c                # Confirm
```

Now type your note. To link to another note:

```
SPC n r i                  # Insert a link to another note
  → Start typing...        # Search for existing note
  → Enter                  # Insert the link
SPC n r r                  # Toggle roam buffer (see backlinks)
```

### Daily journal

```
SPC n r d n                # Capture today's journal entry
SPC n r d t                # Go to today's journal entry
```

Your journals live in `~/org/daily/`. They're full Org-mode documents.

---

## Day 1: Your First Literate Computing Block

Your setup uses **emacs-jupyter** for Python blocks, giving you a live Jupyter kernel session with rich output (images, HTML, LaTeX, Pandas tables) right inside Org.

### Quick example

```
#+begin_src python :session py :results replace drawer
  fig, ax = newfig()                    # Dark theme auto-applied
  ax.plot([1,2,3,4], [1,4,9,16], color=COLORS['NMOS'])
  ax.set_title("My First Plot", color=COLORS['text'])
  fig.savefig("myplot.png")
  plt.close(fig)
  "myplot.png"
#+end_src
```

`C-c C-c` on the block → executes via the Jupyter kernel → PNG appears inline.

**Pre-loaded for you:** `newfig()`, `COLORS`, `pl` (Polars as `pl`), `np`, `plt`, `mpatches`. No imports needed.

### Why Jupyter blocks are better than plain ob-python

| Feature | Plain ob-python | Jupyter (your setup) |
|---|---|---|
| Session persistence | No — each block is fresh | Yes — variables persist across blocks |
| Rich output | PNG only | PNG, SVG, HTML, LaTeX, Pandas tables |
| Async execution | No | Yes — `C-c C-c` returns immediately |
| Completion | No | Yes — `TAB` completes inside blocks |
| Inspection | No | Yes — `M-i` shows docs for symbol at point |
| REPL interaction | No | Yes — live REPL buffer linked to session |

### Jupyter sessions explained

The `:session py` parameter links all blocks with the same session name to one running Python kernel.

```
Block 1                           Block 2 (same session)
#+begin_src python :session py    #+begin_src python :session py
  x = 42                            x * 2
#+end_src                         #+end_src
  → x = 42 stored in kernel       → Result: 84
```

Start a fresh session by changing the session name (e.g. `:session py2`) or restart the kernel with `C-c C-r` in the REPL.

### Start a Jupyter REPL manually

```
SPC o r                    # Start Jupyter REPL
  → Choose kernel: python3
  → REPL buffer opens
  → Type Python interactively
```

In the REPL:
- `S-RET` — send current cell
- `M-n` / `M-p` — navigate history
- `C-c C-c` — interrupt kernel
- `C-c C-r` — restart kernel
- `M-i` — inspect symbol at point

---

## Day 1: Reading a Paper

```
SPC o E                    # Elfeed (RSS feeds)
  → Browse arXiv feeds
  → Enter on a paper       # Read abstract
  → o                      # Open in browser
  → Download PDF
```

To annotate a PDF:

```
SPC f f → ~/org/literature/some-paper.pdf
  → pdf-tools opens the PDF
SPC n r n                  # Create a literature note
  → Takes you to a new Org-roam note linked to this paper
  → org-noter syncs PDF position with your note
```

---

## Day 2-3: The Power Moves

### Quick capture (capture ideas instantly)

```
SPC X                      # Org-capture menu (capital X)
  → t                      # Todo item
  → Type your thought
  → C-c C-c                # Done — saved to inbox.org
```

Even if Emacs isn't running, you can capture:
```powershell
emacsclient -e "(+popup/buffer)"   # Opens a capture frame
```

### Search everything you've written

```
SPC n r f                  # Find any Org-roam note by title
SPC s p                    # Project-wide text search
  → "feedback"             # Finds every mention in every file
```

### Query your knowledge base

```
M-x org-ql-search
  → Query: "tags:analog,ota"       # Find all OTA notes
  → Query: "todo:TODO"             # Find all open tasks
  → Query: "ts:on=today"           # Today's entries
```

---

## Day 3-7: Visualizations

### Circuit schematic

```
#+begin_src python :results file :file diffpair.svg
  import schemdraw
  import schemdraw.elements as elm
  with schemdraw.Drawing(file='diffpair.svg') as d:
      d += elm.NMos().anchor('source').label('M1')
      d += elm.Resistor().right().label('R_L')
      d += elm.Ground()
  "diffpair.svg"
#+end_src
```
`C-c C-c` → SVG rendered inline.

### Diagram (flowchart)

```
#+begin_src mermaid :file flowchart.png
  graph TD
    A[Research Question] --> B[Literature Review]
    B --> C[Experiment Design]
    C --> D[Simulation]
    D --> E[Analysis]
    E --> F[Paper]
#+end_src
```
`C-c C-c` → PNG rendered inline.

### "By Hand" computation trace

```
SPC a b                    # Insert org-ai block
  → "Generate a color-coded by-hand computation
     trace of a transformer self-attention calculation
     in Tom Yeh style: blue inputs, green weights,
     orange activations"
  → C-c C-c                # AI generates the visualization
```

---

## Day 3-7: AI Assistants

### Configure your API keys (one-time setup)

Your AI backends read keys from `~/.authinfo` (or `~/.authinfo.gpg` for encryption).
A template was created at `~/.authinfo.template`. Copy it and fill in your keys:

```powershell
copy ~/.authinfo.template ~/.authinfo
notepad ~/.authinfo
```

Replace `YOUR_..._API_KEY_HERE` with real keys.  Four providers are pre-configured:

| Provider | Auth-source host | Where to get a key |
|---|---|---|
| Anthropic (Claude) | `api.anthropic.com` | https://console.anthropic.com/ |
| MiniMax Coding Plan | `api.minimax.chat` | https://platform.minimaxi.com/ |
| Opencode Go plan | `openrouter.ai` *(default)* | Your Opencode plan dashboard |
| Hermes gateway | `openrouter.ai` *(default)* | OpenRouter or your private gateway |

> **If your Opencode or Hermes plan uses a different host** (e.g. `gateway.my-org.com`), edit `~/.doom.d/config.org` → search for `:host "openrouter.ai"` under the Opencode/Hermes sections and change it to your real host.  Add a matching `machine <host>` line in `~/.authinfo`.

After editing authinfo, restart Emacs or run `M-x auth-source-forget-all-cached`.

### Chat with AI

```
SPC a c                              # Open gptel chat
  → "Explain how a differential pair works"
```

### Switch AI backend on the fly

Four backends are registered.  Cycle through them instantly:

```
SPC a .                    # Switch to next backend (Anthropic → MiniMax → Opencode → Hermes)
C-u SPC a .                # Pick a specific backend from the list
SPC a ,                    # Show which backend is currently active
```

Each backend carries its own model list.  After switching, the transient menu (`SPC a m`) shows the models available on that backend.

### AI inside your notes

```
SPC a b                              # Insert org-ai block (or <A TAB)
  → "Summarize the key claims
     in the three linked papers above"
  → C-c C-c                          # AI reads context, generates summary
```

### Agent-driven visualization

```
SPC a b
  → "Generate a Manim animation showing
     how a MOSFET channel forms under gate voltage"
  → C-c C-c
  → MP4 file linked inline
```

---

## Essential Keybindings Reference

### Org-mode

| Keys | Action |
|---|---|
| `TAB` | Fold/unfold heading |
| `S-TAB` | Cycle global visibility |
| `M-RET` | New heading |
| `M-LEFT/RIGHT` | Promote/demote heading |
| `M-UP/DOWN` | Move heading |
| `C-c C-c` | Execute source block / toggle checkbox |
| `C-c C-t` | Cycle TODO state |
| `C-c C-s` | Schedule a task |
| `C-c C-d` | Set deadline |
| `C-c [` | Add file tag |
| `C-c ,` | Insert citation (org-ref) |

### Org-roam (under SPC n r)

| Keys | Action |
|---|---|
| `SPC n r f` | Find node |
| `SPC n r i` | Insert node link |
| `SPC n r n` | Capture to node |
| `SPC n r r` | Toggle roam buffer |
| `SPC n r d n` | Capture today's journal |
| `SPC n r d t` | Goto today's journal |

### Jupyter (inside Org source blocks)

| Keys | Action |
|---|---|
| `C-c C-c` | Execute block via Jupyter kernel |
| `TAB` | Code completion (when inside a block) |
| `M-i` | Inspect symbol at point (show docs) |
| `C-c '` | Edit block in dedicated buffer (with completion) |
| `C-c C-r` | Restart kernel (in REPL buffer) |
| `C-c C-c` | Interrupt kernel (in REPL buffer) |

### AI (under SPC a)

| Keys | Action |
|---|---|
| `SPC a c` | GPTel chat |
| `SPC a s` | GPTel send region |
| `SPC a m` | GPTel menu (transient) — set model, temperature, system prompt |
| `SPC a .` | Cycle to next AI backend (Anthropic → MiniMax → Opencode → Hermes) |
| `C-u SPC a .` | Pick a specific backend |
| `SPC a ,` | Show current backend & model |
| `SPC a b` | org-ai complete block |
| `SPC a q` | org-ai prompt |
| `SPC a u` | org-ai summarize |
| `SPC a r` | org-ai on region |

### Reading/Annotating PDFs

| Keys | Action |
|---|---|
| `j/k` | Scroll down/up |
| `SPC n r n` | Create linked note |
| `m` | Place annotation marker |
| `C-c C-c` | Open the linked note |

### Magit (git)

| Keys | Action |
|---|---|
| `SPC g g` | Open magit |
| `s` | Stage file under cursor |
| `u` | Unstage |
| `c c` | Commit |
| `P p` | Push |
| `F p` | Pull |
| `l l` | Log |
| `q` | Quit magit |

---

## Where Your Files Live

| What | Path |
|---|---|
| Daily notes | `~/org/daily/2026-04-26.org` |
| Paper notes | `~/org/literature/smith2025_ota_noise.org` |
| Concept notes | `~/org/notes/common_mode_feedback.org` |
| Project docs | `~/org/projects/amplifier_design.org` |
| Capture inbox | `~/org/inbox.org` |
| Bibliography | `~/org/references.bib` |
| Viz examples | `~/docs/superpowers/viz-framework/org/examples/` |

---

## Daily Routine

**Morning:**
1. `emacs`
2. `SPC n r d t` — open today's journal
3. Write what you plan to do

**During the day:**
1. `SPC X t` — quick capture ideas (capital X)
2. `SPC o E` — check arXiv feeds in Elfeed
3. `SPC a c` — ask AI when stuck

**Evening:**
1. Review inbox.org — refile items into proper notes
2. `SPC g g` — commit changes to git
3. `SPC n r d t` — journal what you learned

---

## When Something Goes Wrong

| Problem | Fix |
|---|---|
| Emacs feels slow | `SPC h d d` (doom doctor) |
| Package error | `doom sync -u` in terminal |
| Can't find a note | `SPC /` and search for a word you remember |
| Vim keys in wrong place | `SPC t e` toggles evil-mode |
| Image won't show | `C-c C-c` on the `#+RESULTS` line |
| Everything is broken | See `docs/superpowers/2026-04-26-emacs-org-setup-maintainability.md` |

---

## Next Steps

After your first week:
1. Read the maintainability guide at `docs/superpowers/2026-04-26-emacs-org-setup-maintainability.md`
2. Explore the viz examples in `docs/superpowers/viz-framework/org/examples/`
3. Read the design spec for the full vision: `docs/superpowers/specs/2026-04-26-emacs-org-setup-design.md`
4. Install **Stage 3** frameworks (Streamlit, Remotion) when you need dashboards
5. Customize the **model lists** in `~/.doom.d/config.org` if your plan includes different model names than the defaults
