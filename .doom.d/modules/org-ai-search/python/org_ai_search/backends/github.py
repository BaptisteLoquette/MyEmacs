"""GitHub backend."""
import requests

from org_ai_search.backends.base import BaseBackend
from org_ai_search.config import get_auth, register_backend


class GitHubBackend(BaseBackend):
    name = "github"
    base_url = "https://api.github.com/search/repositories"
    field_map = {
        "description": "description",
        "stars": "stargazers_count",
        "language": "language",
        "updated": "updated_at",
        "license": "license_name",
    }

    def search(self, query: str, count: int = 10, **kwargs) -> list[dict]:
        token = get_auth("ORG_AI_GITHUB_TOKEN")
        headers = {}
        if token:
            headers["Authorization"] = f"token {token}"
        resp = requests.get(
            self.base_url,
            headers=headers,
            params={
                "q": query,
                "per_page": count,
                "sort": "stars",
                "order": "desc",
            },
            timeout=30,
        )
        resp.raise_for_status()
        data = resp.json()
        results = []
        for item in data.get("items", []):
            lic = item.get("license") or {}
            results.append({
                "url": item.get("html_url", ""),
                "title": item.get("full_name", ""),
                "description": item.get("description") or "",
                "stargazers_count": str(item.get("stargazers_count", "")),
                "language": item.get("language") or "",
                "updated_at": item.get("updated_at", ""),
                "license_name": lic.get("spdx_id") or "",
            })
        return results


register_backend("github", GitHubBackend)
