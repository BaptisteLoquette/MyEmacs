# Org-AI-Search Design Spec

**Date:** 2026-04-28  
**Topic:** Integrating Org Table Mode with AI-Powered Research & Development Search  
**Status:** Approved

---

## 1. Overview

Org-AI-Search is an Emacs minor mode that turns ordinary org tables into a declarative search DSL. Users write a **Discovery Table** where each row is a query and each column header (after `QUERY`) is an enrichment prompt. Executing the table runs searches against academic and development APIs, then renders a combined **Output Table** with AI-extracted or API-native fields. Users tag rows inline; refreshes merge new results and mark stale rows.

---

## 2. Goals

- **Native org UX:** Search and enrichment are expressed as org tables — no external UI.
- **Pluggable backends:** One unified interface for academic (Semantic Scholar, arXiv, OpenAlex, CORE, Crossref, PubMed, dblp) and development (GitHub, Hacker News, Brave, Firecrawl) APIs.
- **Structured-first enrichment:** Leverage native API fields when possible; fall back to LLM extraction only when necessary.
- **Persistent curation:** Tags survive refreshes. Stale results are marked, not deleted.
- **Composability:** A single discovery table can dispatch different rows to different backends.

---

## 3. Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 1: Emacs UI (org-ai-search.el)                       │
│  — Minor mode, keybindings, table parsing/rendering         │
│    Property drawer management, minibuffer prompts           │
├─────────────────────────────────────────────────────────────┤
│  LAYER 2: Python Bridge (org_ai_search/)                    │
│  — Normalizes all backends to common JSON schema            │
│    Field-mapping enrichment, async handling, caching        │
│    LLM fallback for unstructured prompts                    │
├─────────────────────────────────────────────────────────────┤
│  LAYER 3: Backend Adapters (org_ai_search/backends/)        │
│  — semantic_scholar.py, arxiv.py, openalex.py, core.py     │
│    crossref.py, pubmed.py, dblp.py, github.py              │
│    hackernews.py, brave.py, firecrawl.py                   │
└─────────────────────────────────────────────────────────────┘
```

**Communication:** Emacs calls Python as a subprocess with JSON arguments via stdin; Python returns JSON via stdout. Emacs owns the buffer; Python owns the network.

---

## 4. Discovery Table DSL

### 4.1 Structure

A Discovery Table is any org table where the **first column header is exactly `QUERY`**.

```org
* Neural Architecture Search Research
:PROPERTIES:
:AI_SEARCH_BACKEND: semantic-scholar
:AI_SEARCH_COUNT: 15
:END:

| QUERY                                         | summary | citation count | open access? | venue | year |
|-----------------------------------------------+---------+----------------+--------------+-------+------|
| Neural architecture search survey             | tldr    | citationCount  | isOpenAccess | venue | year |
| Efficient NAS for edge deployment             | tldr    | citationCount  | isOpenAccess | venue | year |
| Hardware-aware neural architecture search     | tldr    | citationCount  | isOpenAccess | venue | year |
```

### 4.2 Column Conventions

| Column | Required | Meaning |
|--------|----------|---------|
| `QUERY` | Yes (first col) | Natural language search query per row |
| `param1...paramN` | No | Enrichment prompts. Each becomes a column in the output. Value in the discovery cell is a hint for the backend adapter (e.g., native field name or natural language prompt). |
| `Backend` | No | Override the default backend for that row |
| `Count` | No | Override result count for that row |

### 4.3 Property Drawer

Stored above the discovery table:

- `:AI_SEARCH_BACKEND:` — default backend for rows without explicit `Backend` column
- `:AI_SEARCH_COUNT:` — default number of results per query
- `:AI_SEARCH_ID:` — opaque search session ID (set by system on first execution)
- `:AI_SEARCH_TIME:` — timestamp of last execution

---

## 5. Output Table

### 5.1 Structure

Inserted directly below the discovery table. Linked by `#+NAME:` derived from the heading.

```org
#+NAME: ai-results-neural-architecture-search
| Tags       | Source Query                              | URL                                              | summary                                      | citation count | open access? | venue         | year |
|------------+-------------------------------------------+--------------------------------------------------+----------------------------------------------+----------------+--------------+---------------+------|
| :priority: | Neural architecture search survey         | [[https://semanticscholar.org/paper/abc][DARTS: Differentiable Architecture Search]]       | Introduces differentiable NAS...             | 4521           | yes          | ICLR          | 2019 |
| :research: | Neural architecture search survey         | [[https://semanticscholar.org/paper/def][NAS-Bench-101: Towards Reproducible NAS]]         | First NAS benchmark...                       | 892            | yes          | ICML          | 2019 |
|            | Efficient NAS for edge deployment         | [[https://semanticscholar.org/paper/ghi][Once-for-All: Train One Network]]                 | Progressive shrinking for mobile deployment  | 1234           | yes          | NeurIPS       | 2020 |
| :stale:    | Hardware-aware neural architecture search | [[https://semanticscholar.org/paper/old][Outdated HW-NAS Survey]]                          | Early survey of hardware-aware methods       | 45             | no           | arXiv preprint| 2018 |
```

### 5.2 Output Columns

Always present:
- `Tags` — user-curated org tags (e.g., `:research:`, `:priority:`)
- `Source Query` — which discovery row produced this result
- `URL` — clickable link to the result

Dynamic columns:
- Union of all `param` columns from all discovery rows. If a result's source row did not define a param, the cell is empty.

---

## 6. Backend Registry

### 6.1 Academic / Research Backends

| Backend | Auth | Native Fields | Field Map Examples |
|---------|------|---------------|-------------------|
| **Semantic Scholar** | Free API key | title, authors, year, abstract, citationCount, referenceCount, venue, fieldsOfStudy, openAccessPdf, tldr | `summary`→`tldr`, `citation count`→`citationCount`, `open access?`→`isOpenAccess`, `venue`→`venue.name` |
| **arXiv** | None | title, authors, summary, published, updated, primary_category, pdf_link, doi | `summary`→`summary`, `pdf link`→`link[title="pdf"]`, `categories`→`category`, `published`→`published` |
| **OpenAlex** | None | title, authors, publication_year, cited_by_count, concepts, open_access, host_venue, biblio | `cited by`→`cited_by_count`, `concepts`→`concepts.display_name` |
| **CORE** | Free API key | title, authors, year, abstract, downloadUrl, publisher | `pdf`→`downloadUrl`, `publisher`→`publisher` |
| **Crossref** | None (polite pool) | title, authors, published, publisher, DOI, reference-count, type | `doi`→`DOI`, `references`→`reference-count` |
| **PubMed** | None | title, authors, pubDate, journal, abstract, meshTerms, pmcid | `journal`→`journal.title`, `mesh`→`meshTerms` |
| **dblp** | None | title, authors, year, venue, ee (URL), type | `url`→`ee`, `venue`→`venue` |

### 6.2 Development / Web Backends

| Backend | Auth | Native Fields | Enrichment Strategy |
|---------|------|---------------|-------------------|
| **GitHub** | Free token | name, description, stars, language, updated_at, url, topics, license | `description`→`description`, `stars`→`stargazers_count`, `language`→`language` |
| **Hacker News** | None | title, url, score, author, created_at, descendants | `score`→`score`, `comments`→`descendants`; unstructured params need LLM |
| **Brave** | Free API key | title, url, description, age | All params beyond title/url/description require LLM + page fetch |
| **Firecrawl** | Free API key | (Any URL → markdown, title, links, metadata) | Acts as enrichment engine, not primary search |

### 6.3 Backend Configuration in Emacs

```elisp
(setq org-ai-search-backends
  '((semantic-scholar :type academic   :auth api-key  :enrichment native)
    (arxiv           :type academic   :auth none     :enrichment native)
    (openalex        :type academic   :auth none     :enrichment native)
    (core            :type academic   :auth api-key  :enrichment native)
    (crossref        :type academic   :auth none     :enrichment native)
    (pubmed          :type academic   :auth none     :enrichment native)
    (dblp            :type academic   :auth none     :enrichment native)
    (github          :type dev        :auth token    :enrichment native)
    (hackernews      :type dev        :auth none     :enrichment llm-fallback)
    (brave           :type web        :auth api-key  :enrichment llm-fallback)
    (firecrawl       :type scrape     :auth api-key  :enrichment native)))
```

---

## 7. Enrichment Architecture

### 7.1 Three-Tier Strategy

1. **Native field mapping** — If the param prompt matches a backend's field map, extract directly from API response. No LLM call. This is the fast path for research APIs.
2. **Content + LLM** — If no native field matches (e.g., `"key insight"`, `"reproducibility score"`), fetch page content (via Firecrawl or raw HTTP) and run structured LLM extraction. Batched per URL: one fetch, all params extracted in a single LLM call returning JSON.
3. **Cached fallback** — Session-level LRU cache keyed by `(url, param_prompt)` hash. Survives refreshes within the same Emacs session.

### 7.2 LLM Fallback Integration

Uses the user's existing gptel configuration. Python bridge calls a lightweight wrapper that hits the same endpoints configured in `config.org` (Claude, MiniMax, OpenRouter, Hermes). Prompt template:

```
Given the following page content, extract these fields as JSON:
Fields: [param1, param2, ...]
Content: <page markdown>
Return only valid JSON with the requested keys.
```

---

## 8. Execution Flow

1. **Parse** — Emacs extracts discovery table, property drawer, and per-row overrides.
2. **Dispatch** — Emacs calls Python subprocess once with full discovery table JSON.
3. **Search** — Python runs each row's query against its backend. Parallel where possible.
4. **Enrich** — For each result, apply native field mapping first, then LLM fallback for unmatched params.
5. **Merge** — Union all results into one JSON array. Deduplicate by URL.
6. **Render** — Emacs inserts/replaces the output table below the discovery table.

**Async handling:** Semantic Scholar and arXiv are sync. Brave/GitHub are sync. No true async backends in MVP. If Exa is added later, Python handles polling internally and returns partial results with a `pending` flag.

---

## 9. Interaction Model

### 9.1 Keybindings (prefix `C-c C-s`)

| Key | Context | Action |
|-----|---------|--------|
| `C-c C-s s` | Discovery table | **Execute** — run all queries, render output table |
| `C-c C-s r` | Output table | **Refresh** — re-run discovery, merge results, mark stale |
| `C-c C-s e` | Discovery table | **Edit** — tweak query/count/backend inline and re-run |
| `C-c C-s d` | Output table | **Delete stale** — remove all rows tagged `:stale:` |
| `C-c C-s t` | Output row | **Tag** — add/edit tags for current row |
| `C-c C-s c` | Output row | **Clear tags** — remove tags from current row |
| `C-c C-s b` | Anywhere | **Backend cycle** — rotate default backend |

### 9.2 Tagging

- Tags are freeform text in the `Tags` cell. User types whatever they want: `:research:`, `:priority:`, `:ml:`, `:hardware:`.
- Completion offered from existing tags in the file + `org-tag-alist`.
- Multiple tags: `:research:ml:`
- No presets forced.

### 9.3 Stale Handling

On refresh:
- Match new results to old by `URL` (stable key).
- Matched rows: keep tags, update other cells.
- New rows: append at bottom with empty tags.
- Missing rows: prepend `:stale:` to existing tags.
- `C-c C-s d` deletes all rows whose Tags cell starts with `:stale:`.

---

## 10. Python Bridge Contract

### 10.1 Emacs → Python

```json
{
  "command": "execute",
  "default_backend": "semantic-scholar",
  "default_count": 15,
  "rows": [
    {
      "query": "Neural architecture search survey",
      "backend": "semantic-scholar",
      "count": 15,
      "params": {
        "summary": "tldr",
        "citation count": "citationCount",
        "open access?": "isOpenAccess",
        "venue": "venue.name",
        "year": "year"
      }
    }
  ],
  "enrichment_strategy": "native-first",
  "gptel_backend": "Anthropic"
}
```

### 10.2 Python → Emacs

```json
{
  "status": "completed",
  "output_columns": ["Tags", "Source Query", "URL", "summary", "citation count", "open access?", "venue", "year"],
  "rows": [
    {
      "Tags": "",
      "Source Query": "Neural architecture search survey",
      "URL": "https://www.semanticscholar.org/paper/abc",
      "summary": "Introduces differentiable NAS...",
      "citation count": "4521",
      "open access?": "yes",
      "venue": "ICLR",
      "year": "2019"
    }
  ],
  "metadata": {
    "searches": [
      {"backend": "semantic-scholar", "query": "...", "results_found": 15, "time_ms": 1200}
    ],
    "enrichments": {"native": 45, "llm": 3, "cached": 12, "failed": 0}
  }
}
```

---

## 11. File Layout

```
~/.doom.d/
├── config.org                  (add keybindings, backend config)
└── modules/
    └── org-ai-search/          (package directory)
        ├── org-ai-search.el    (main minor mode, commands)
        ├── org-ai-search-table.el  (table parse/render, stale logic)
        ├── org-ai-search-utils.el  (helpers, completion)
        └── python/
            ├── org_ai_search/
            │   ├── __init__.py
            │   ├── __main__.py
            │   ├── core.py         (CLI, caching, normalization)
            │   ├── config.py       (backend registry, auth, field maps)
            │   ├── enrich.py       (LLM fallback, structured extraction)
            │   └── backends/
            │       ├── __init__.py
            │       ├── base.py
            │       ├── semantic_scholar.py
            │       ├── arxiv.py
            │       ├── openalex.py
            │       ├── core.py
            │       ├── crossref.py
            │       ├── pubmed.py
            │       ├── dblp.py
            │       ├── github.py
            │       ├── hackernews.py
            │       ├── brave.py
            │       └── firecrawl.py
            └── requirements.txt
```

---

## 12. Error Handling

- **API failure:** Python returns `{"error": "...", "backend": "...", "retry_after": N}`. Emacs shows in minibuffer.
- **Rate limit:** Automatic exponential backoff in Python (max 3 retries).
- **Empty results:** Output table still rendered with header row and zero data rows.
- **Malformed discovery table:** Emacs signals error before calling Python if `QUERY` column missing.

---

## 13. Security

- API keys/tokens stored in `~/.authinfo` or `~/.authinfo.gpg`, read via `auth-source` (same pattern as gptel config).
- Python reads keys from environment variables injected by Emacs: `ORG_AI_S2_KEY`, `ORG_AI_BRAVE_KEY`, etc.
- No keys committed to code.

---

## 14. Future Work (Out of Scope for MVP)

- **Exa Websets** integration (async polling, native enrichment)
- **Monitors** — scheduled refresh via cron
- **Citation graph traversal** — expand references/citations from a seed paper
- **Export** to BibTeX, org-ref, or org-roam nodes
- **Multi-backend parallel execution** within one discovery table
- **Search composition** — row N feeds into row N+1 via scope/exclude

---

## 15. MVP Scope

**Phase 1:**
- Emacs minor mode with keybindings
- Python bridge with JSON contract
- Discovery table parsing + output table rendering
- **3 backends:** Semantic Scholar, arXiv, GitHub
- Native field-mapping enrichment
- Tagging (`C-c C-s t`, `C-c C-s c`)
- Refresh with stale marking (`:stale:` prefix)
- gptel LLM fallback for unmatched params

**Phase 2:**
- Add OpenAlex, CORE, Crossref, PubMed, dblp
- Add Hacker News, Brave, Firecrawl
- Per-row backend override via `Backend` column
- Caching layer

**Phase 3:**
- Parallel multi-backend execution
- Citation graph expansion
- Export integrations
