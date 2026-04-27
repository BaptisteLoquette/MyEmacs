#!/bin/bash
# Tier 1 — Core frameworks (install immediately)
set -e

echo "=== Installing Tier 1: Core Python Frameworks ==="
pip install matplotlib seaborn plotly kaleido pandas numpy scipy polars
pip install schemdraw altair manim pyvista torch transformers diffusers
pip install bertviz ecco torchview torchinfo captum umap-learn aim
pip install drawsvg moviepy datashader pyyaml

echo "=== Installing Tier 1: Agent Skills ==="
npx skills add heygen-com/hyperframes@hyperframes -g -y
npx skills add adithya-s-k/manim_skill@manimce-best-practices -g -y
npx skills add softaworks/agent-toolkit@mermaid-diagrams -g -y
npx skills add markdown-viewer/skills@graphviz -g -y

echo "=== Tier 1 complete ==="
echo "Run: python C:/Users/Bapti/docs/superpowers/viz-framework/install/verify-install.py"
