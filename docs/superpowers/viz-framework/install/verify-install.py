"""Verify all frameworks and their dependencies are importable."""
import sys

frameworks = {
    'matplotlib': 'matplotlib', 'seaborn': 'seaborn', 'plotly': 'plotly',
    'kaleido': 'kaleido', 'pandas': 'pandas', 'numpy': 'numpy',
    'scipy': 'scipy', 'polars': 'polars', 'schemdraw': 'schemdraw',
    'altair': 'altair', 'manim': 'manim', 'pyvista': 'pyvista',
    'torch': 'torch', 'transformers': 'transformers', 'diffusers': 'diffusers',
    'bertviz': 'bertviz', 'ecco': 'ecco', 'torchview': 'torchview',
    'torchinfo': 'torchinfo', 'captum': 'captum', 'umap': 'umap',
    'aim': 'aim', 'drawsvg': 'drawsvg', 'moviepy': 'moviepy',
    'datashader': 'datashader', 'yaml': 'yaml',
    'pyqtgraph': 'pyqtgraph', 'bokeh': 'bokeh',
}

passed = 0
failed = []
for name, module in frameworks.items():
    try:
        __import__(module)
        passed += 1
        print(f"  [OK] {name}")
    except ImportError:
        failed.append(name)
        print(f"  [MISS] {name}")

print(f"\n{passed}/{len(frameworks)} frameworks available")
if failed:
    print(f"Missing: {', '.join(failed)}")
    sys.exit(1)
else:
    print("All frameworks verified.")
