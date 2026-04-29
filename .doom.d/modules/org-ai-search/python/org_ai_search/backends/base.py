"""Abstract backend base class."""
from abc import ABC, abstractmethod
from typing import Any


class BaseBackend(ABC):
    name: str = ""
    field_map: dict[str, str] = {}

    @abstractmethod
    def search(self, query: str, count: int, **kwargs) -> list[dict[str, Any]]:
        """Return list of result dicts. Each dict must contain 'url' and 'title'."""
        ...

    def map_fields(self, raw: dict[str, Any], params: dict[str, str]) -> dict[str, str]:
        """Map native API fields to requested param names."""
        out = {}
        for param_key, field_hint in params.items():
            # Direct key lookup first
            if field_hint in raw:
                val = raw[field_hint]
                out[param_key] = str(val) if val is not None else ""
                continue
            # Nested lookup via dot notation (e.g. "venue.name")
            parts = field_hint.split(".")
            val = raw
            for part in parts:
                if isinstance(val, dict) and part in val:
                    val = val[part]
                else:
                    val = None
                    break
            out[param_key] = str(val) if val is not None else ""
        return out
