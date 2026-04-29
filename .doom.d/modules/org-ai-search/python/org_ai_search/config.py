"""Backend registry and configuration."""
import os
from typing import Type

from org_ai_search.backends.base import BaseBackend

BACKEND_REGISTRY: dict[str, Type[BaseBackend]] = {}


def get_backend(name: str) -> BaseBackend:
    cls = BACKEND_REGISTRY.get(name)
    if not cls:
        raise ValueError(f"Unknown backend: {name}")
    return cls()


def get_auth(key_name: str) -> str | None:
    return os.environ.get(key_name)


def register_backend(name: str, cls: Type[BaseBackend]) -> None:
    BACKEND_REGISTRY[name] = cls
