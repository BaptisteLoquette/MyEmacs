"""arXiv backend using Atom API."""
import requests
import xml.etree.ElementTree as ET

from org_ai_search.backends.base import BaseBackend
from org_ai_search.config import register_backend


class ArxivBackend(BaseBackend):
    name = "arxiv"
    base_url = "http://export.arxiv.org/api/query"
    field_map = {
        "summary": "summary",
        "pdf link": "pdf_link",
        "categories": "categories",
        "published": "published",
        "updated": "updated",
    }

    def search(self, query: str, count: int = 10, **kwargs) -> list[dict]:
        resp = requests.get(
            self.base_url,
            params={
                "search_query": f"all:{query}",
                "start": 0,
                "max_results": count,
            },
            timeout=30,
        )
        resp.raise_for_status()
        ns = {
            "atom": "http://www.w3.org/2005/Atom",
            "arxiv": "http://arxiv.org/schemas/atom",
        }
        root = ET.fromstring(resp.content)
        results = []
        for entry in root.findall("atom:entry", ns):
            id_elem = entry.find("atom:id", ns)
            title = entry.find("atom:title", ns)
            summary = entry.find("atom:summary", ns)
            published = entry.find("atom:published", ns)
            updated = entry.find("atom:updated", ns)
            cats = [c.get("term", "") for c in entry.findall("atom:category", ns)]
            pdf_link = None
            for link in entry.findall("atom:link", ns):
                if link.get("title") == "pdf":
                    pdf_link = link.get("href")
                    break
            arxiv_id = id_elem.text.split("/")[-1] if id_elem is not None else ""
            results.append({
                "url": f"https://arxiv.org/abs/{arxiv_id}",
                "title": title.text.strip() if title is not None else "",
                "summary": summary.text.strip() if summary is not None else "",
                "published": published.text if published is not None else "",
                "updated": updated.text if updated is not None else "",
                "categories": ", ".join(cats),
                "pdf_link": pdf_link or "",
                "arxiv_id": arxiv_id,
            })
        return results


register_backend("arxiv", ArxivBackend)
