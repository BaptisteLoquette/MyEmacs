"""Semantic Scholar backend."""
import requests

from org_ai_search.backends.base import BaseBackend
from org_ai_search.config import get_auth, register_backend


class SemanticScholarBackend(BaseBackend):
    name = "semantic-scholar"
    base_url = "https://api.semanticscholar.org/graph/v1"
    field_map = {
        "summary": "abstract",
        "citation count": "citationCount",
        "open access?": "isOpenAccess",
        "venue": "venue",
        "year": "year",
        "authors": "authors",
        "pdf": "openAccessPdf",
    }

    def search(self, query: str, count: int = 10, **kwargs) -> list[dict]:
        api_key = get_auth("ORG_AI_S2_KEY")
        headers = {"x-api-key": api_key} if api_key else {}
        fields = (
            "title,authors,year,abstract,citationCount,referenceCount,"
            "venue,fieldsOfStudy,isOpenAccess,openAccessPdf"
        )
        url = f"{self.base_url}/paper/search"
        resp = requests.get(
            url,
            headers=headers,
            params={"query": query, "limit": count, "fields": fields},
            timeout=30,
        )
        resp.raise_for_status()
        data = resp.json()
        results = []
        for item in data.get("data", []):
            paper_id = item.get("paperId", "")
            results.append({
                "url": f"https://www.semanticscholar.org/paper/{paper_id}",
                "title": item.get("title", ""),
                **item,
            })
        return results


register_backend("semantic-scholar", SemanticScholarBackend)
