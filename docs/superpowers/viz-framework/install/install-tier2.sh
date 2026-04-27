#!/bin/bash
# Tier 2 — Install when needed
set -e

pip install pyqtgraph PyQt5 bokeh

npx skills add remotion-dev/skills@remotion-best-practices -g -y
npx skills add streamlit/agent-skills@developing-with-streamlit -g -y
npx skills add vibe-motion/skills@svg-assembly-animator -g -y

echo "=== Tier 2 complete ==="
