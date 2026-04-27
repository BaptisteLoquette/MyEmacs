"""Example: Generate an educational notebook using the agentic system."""

import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from agentic.core import AgenticNotebookSystem


def main():
    # Initialize the system
    print("🚀 Initializing Agentic Notebook Generator...")
    system = AgenticNotebookSystem()
    
    # Show available concepts
    print("\n📚 Available Electronics concepts:")
    for concept in system.list_concepts("electronics")[:10]:
        print(f"  • {concept}")
    
    # Generate a notebook for a specific concept
    print("\n" + "="*60)
    print("GENERATING NOTEBOOK: Amplifier Topologies")
    print("="*60)
    
    notebook_path = system.generate(
        concept="amplifier_topologies",
        domain="electronics",
        output_format="jupyter",
        output_path="amplifier_topologies.ipynb",
        max_iterations=0  # Set to 3 for full evaluation loop
    )
    
    print(f"\n✅ Notebook generated: {notebook_path}")
    print("\nNext steps:")
    print(f"  1. Open {notebook_path} in JupyterLab or VS Code")
    print(f"  2. Run all cells to see the visualization")
    print(f"  3. Modify the parameters and re-run")
    
    # Generate another in Marimo format
    print("\n" + "="*60)
    print("GENERATING MARIMO NOTEBOOK: Skin Effect")
    print("="*60)
    
    marimo_path = system.generate(
        concept="skin_effect",
        domain="physics",
        output_format="marimo",
        output_path="skin_effect.py",
        max_iterations=0
    )
    
    print(f"\n✅ Marimo notebook generated: {marimo_path}")
    print(f"\nTo run: marimo run {marimo_path}")


if __name__ == "__main__":
    main()
