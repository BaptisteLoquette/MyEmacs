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

```
SPC n c                    # Org-roam capture
  → "Today's note"         # Type your note title  
  → C-c C-c                # Confirm
```

Now type your note. To link to another note:

```
SPC n i                    # Insert a link to another note
  → Start typing...        # Search for existing note
  → Enter                  # Insert the link
SPC n b                    # See which notes link to this one
```

### Daily journal

```
SPC n d                    # Create/open today's journal entry
```

Your journals live in `~/org/daily/`. They're full Org-mode documents.

---

## Day 1: Your First Literate Computing Block

In any Org file:

```
#+begin_src python :results file :file myplot.png
  fig, ax = newfig()                    # Dark theme auto-applied
  ax.plot([1,2,3,4], [1,4,9,16], color=COLORS['NMOS'])
  ax.set_title("My First Plot", color=COLORS['text'])
  fig.savefig("myplot.png")
  plt.close(fig)
  "myplot.png"
#+end_src
```

`C-c C-c` on the block → executes → PNG appears inline.

**Pre-loaded for you:** `newfig()`, `COLORS`, `pl` (Polars as `pl`), `np`, `plt`, `mpatches`. No imports needed.

---

## Day 1: Reading a Paper

```
SPC a f                  # Elfeed (paper feeds)
  → Browse arXiv feeds
  → Enter on a paper    # Read abstract
  → o                   # Open in browser
  → Download PDF
```

To annotate a PDF:

```
SPC f f → ~/org/literature/some-paper.pdf
  → pdf-tools opens the PDF
SPC n c l                # Create a literature note
  → Takes you to a new Org-roam note linked to this paper
  → org-noter syncs PDF position with your note
```

---

## Day 2-3: The Power Moves

### Quick capture (capture ideas instantly)

```
SPC x                    # Org-capture menu
  → t                    # Todo item
  → Type your thought
  → C-c C-c              # Done — saved to inbox.org
```

Even if Emacs isn't running, you can capture:
```powershell
emacsclient -e "(+popup/buffer)"   # Opens a capture frame
```

### Search everything you've written

```
SPC n f                             # Find any Org-roam note by title
SPC s p                             # Project-wide text search
  → "feedback"                      # Finds every mention in every file
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

### Chat with AI

```
SPC a c                              # Open gptel chat
  → "Explain how a differential pair works"
```

### AI inside your notes

```
SPC a b                              # Insert org-ai block
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

### Reading/Annotating PDFs

| Keys | Action |
|---|---|
| `j/k` | Scroll down/up |
| `SPC n c` | Create linked note |
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
2. `SPC n d` — open today's journal
3. Write what you plan to do

**During the day:**
1. `SPC x t` — quick capture ideas
2. `SPC a f` — check arXiv for new papers
3. `SPC a c` — ask AI when stuck

**Evening:**
1. Review inbox.org — refile items into proper notes
2. `SPC g g` — commit changes to git
3. `SPC n d` — journal what you learned

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
5. Configure **gptel API keys** when ready for AI features
