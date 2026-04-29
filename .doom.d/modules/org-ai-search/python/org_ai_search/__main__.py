#!/usr/bin/env python3
import json
import sys

from org_ai_search.core import execute_search

def main():
    raw = sys.stdin.read()
    if not raw.strip():
        print(json.dumps({"error": "empty input"}))
        return
    try:
        req = json.loads(raw)
    except json.JSONDecodeError as e:
        print(json.dumps({"error": f"invalid JSON: {e}"}))
        return
    if req.get("command") != "execute":
        print(json.dumps({"error": "unknown command"}))
        return
    result = execute_search(req)
    print(json.dumps(result, ensure_ascii=False))

if __name__ == "__main__":
    main()
