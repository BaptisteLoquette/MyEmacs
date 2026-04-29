"""Core execution: parse request, dispatch backends, merge results."""
from typing import Any

from org_ai_search.config import get_backend

# Import backends to trigger self-registration
import org_ai_search.backends.semantic_scholar  # noqa: F401
import org_ai_search.backends.arxiv             # noqa: F401
import org_ai_search.backends.github            # noqa: F401


def execute_search(req: dict[str, Any]) -> dict[str, Any]:
    default_backend = req.get("default_backend", "semantic-scholar")
    default_count = int(req.get("default_count", 10))
    rows = req.get("rows", [])

    all_rows = []
    all_columns = {"Tags", "Source Query", "URL"}
    search_meta = []

    for row in rows:
        backend_name = row.get("backend") or default_backend
        count = int(row.get("count") or default_count)
        query = row.get("query", "")
        params = row.get("params", {})
        tags = row.get("tags", "")

        try:
            backend = get_backend(backend_name)
            raw_results = backend.search(query, count=count)
        except Exception as e:
            search_meta.append({
                "backend": backend_name,
                "query": query,
                "error": str(e),
            })
            continue

        for r in raw_results:
            mapped = backend.map_fields(r, params)
            all_columns.update(mapped.keys())
            all_rows.append({
                "Tags": tags,
                "Source Query": query,
                "URL": r.get("url", ""),
                **mapped,
            })

        search_meta.append({
            "backend": backend_name,
            "query": query,
            "results_found": len(raw_results),
        })

    # Deduplicate by URL
    seen = set()
    deduped = []
    for r in all_rows:
        url = r.get("URL", "")
        if url and url in seen:
            continue
        seen.add(url)
        deduped.append(r)

    # Ensure all rows have all columns
    output_columns = list(all_columns)
    for r in deduped:
        for col in output_columns:
            if col not in r:
                r[col] = ""

    return {
        "status": "completed",
        "output_columns": output_columns,
        "rows": deduped,
        "metadata": {
            "searches": search_meta,
        },
    }
