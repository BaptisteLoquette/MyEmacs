"""Verify all visualization frameworks and their dependencies are importable."""

import sys

FRAMEWORKS = {
    # Tier 1 - Core
    'matplotlib': 'matplotlib',
    'seaborn': 'seaborn',
    'plotly': 'plotly',
    'numpy': 'numpy',
    'scipy': 'scipy',
    'polars': 'polars',
    'schemdraw': 'schemdraw',
    'altair': 'altair',
    'manim': 'manim',
    'pyvista': 'pyvista',
    'drawsvg': 'drawsvg',
    'moviepy': 'moviepy',
    'moviepy.editor': 'moviepy.editor',
    'datashader': 'datashader',
    'yaml': 'yaml',
    # Tier 2
    'bokeh': 'bokeh',
    'pyqtgraph': 'pyqtgraph',
}

TIER_SKILLS = [
    'heygen-com/hyperframes@hyperframes',
    'adithya-s-k/manim_skill@manimce-best-practices',
    'softaworks/agent-toolkit@mermaid-diagrams',
    'markdown-viewer/skills@graphviz',
]

def verify_skills():
    """Check skills are installed."""
    import subprocess
    result = subprocess.run(['npx', 'skills', 'check'], capture_output=True, text=True)
    print("\n=== Agent Skills ===")
    print(result.stdout if result.returncode == 0 else "Run 'npx skills check' manually")
    return result.returncode == 0

def main():
    print("=== Verification Suite ===\n")
    passed = 0
    failed = []
    skipped = []

    for name, module in FRAMEWORKS.items():
        try:
            __import__(module)
            passed += 1
            print(f"  [OK] {name}")
        except ImportError as e:
            failed.append((name, str(e)))
            print(f"  [MISS] {name} — {e}")

    print(f"\n{passed}/{len(FRAMEWORKS)} frameworks available")
    if failed:
        print(f"Missing ({len(failed)}):")
        for name, err in failed:
            print(f"  - {name}: {err}")

    skills_ok = verify_skills()

    if failed:
        sys.exit(1)
    print("\n=== All frameworks verified ===")

if __name__ == '__main__':
    main()
