# Agentic Educational Notebook Generator

An AI-powered system that automatically generates insightful, interactive educational notebooks (Jupyter and Marimo) using the visualization taxonomy and design framework.

## Architecture: 4-Phase Pipeline

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Phase 1   │───▶│   Phase 2   │───▶│   Phase 3   │───▶│   Phase 4   │
│   PLANNING  │    │  GENERATION │    │  EVALUATION │    │  ITERATION  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
     │                   │                   │                   │
     ▼                   ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│• Concept    │    │• Markdown   │    │• Execute    │    │• Error      │
│  lookup     │    │  cells      │    │  cells      │    │  classifier │
│• Diátaxis   │    │• Code cells │    │• Lint       │    │• Repair     │
│  structure  │    │• Visuals    │    │  check      │    │  agent      │
│• Learning   │    │• Exercises  │    │• Scientific │    │• Re-test    │
│  objectives │    │             │    │  accuracy   │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

## Quick Start

### 1. Generate Your First Notebook

```python
from agentic.core import AgenticNotebookSystem

# Initialize
system = AgenticNotebookSystem()

# Generate a Jupyter notebook
notebook_path = system.generate(
    concept="electrostatic_field",    # From taxonomy
    domain="physics",                  # Domain in taxonomy
    output_format="jupyter",           # or "marimo"
    output_path="my_notebook.ipynb"
)
```

### 2. Run the Example

```bash
cd agentic/examples
python generate_notebook.py
```

### 3. Open Generated Notebook

**Jupyter:**
```bash
jupyter lab my_notebook.ipynb
```

**Marimo:**
```bash
marimo run my_notebook.py
```

## How It Works

### Phase 1: Planning

The system looks up your concept in the taxonomy and creates a structured learning plan:

```python
plan = system.planner.plan("skin_effect", "physics")
# Returns: ConceptPlan with Diátaxis sections
```

Each plan includes:
- **Learning objectives** (measurable goals)
- **Prerequisites** (what you need to know first)
- **4 Diátaxis sections**:
  - **Tutorial**: Hands-on exploration with sliders
  - **Explanation**: Conceptual deep-dive with visual aids
  - **How-to**: Step-by-step practical guide
  - **Reference**: Formulas, parameters, edge cases

### Phase 2: Generation

Converts the plan into notebook cells:

```python
notebook = system.generator.generate(plan, output_format="jupyter")
# Returns: GeneratedNotebook with markdown + code cells
```

Each section gets:
- Contextual markdown (explanations, questions)
- Framework-specific code (matplotlib, plotly, schemdraw, etc.)
- Interactive elements (sliders, dropdowns)
- Exercises with TODO comments

### Phase 3: Evaluation

Validates the generated notebook:

```python
result = system.evaluator.evaluate("my_notebook.ipynb")
# Checks: structure, execution, lint, scientific accuracy
```

### Phase 4: Iteration

Auto-fixes issues using the repair loop:

```python
final_path, result = system.iterator.iterate("my_notebook.ipynb", max_iterations=3)
```

## Usage Patterns

### Pattern 1: Batch Generation

Generate notebooks for all concepts in a domain:

```python
system = AgenticNotebookSystem()

for concept in system.list_concepts("electronics"):
    system.generate(
        concept=concept,
        domain="electronics",
        output_format="jupyter",
        output_path=f"notebooks/{concept}.ipynb",
        max_iterations=0  # Skip evaluation for speed
    )
```

### Pattern 2: Custom Learning Path

Chain multiple concepts into a learning progression:

```python
prerequisites = ["ohms_law", "kirchhoffs_laws", "amplifier_topologies"]

for concept in prerequisites:
    system.generate(
        concept=concept,
        domain="electronics",
        output_format="marimo",
        output_path=f"course/{concept}.py"
    )
```

### Pattern 3: Interactive Exploration

Generate and immediately view:

```python
path = system.generate(
    concept="diffusion_models",
    domain="genai",
    output_format="jupyter"
)

# Open in browser
import subprocess
subprocess.run(["jupyter", "lab", path])
```

## Customization

### Using Your Own Taxonomy

```python
system = AgenticNotebookSystem(
    taxonomy_dir="my_taxonomy",
    patterns_file="my_patterns.yaml",
    prompts_dir="my_prompts",
    code_patterns_dir="my_patterns"
)
```

### Adding Custom Patterns

1. Add to `patterns/nine-patterns.yaml`
2. Create `templates/code-patterns/your_pattern.py`
3. Create `templates/agent-prompts/your_framework.md`

### Extending the Generator

Subclass `NotebookGenerator` to add custom cell types:

```python
class MyGenerator(NotebookGenerator):
    def _generate_tutorial_cells(self, section, plan):
        cells = super()._generate_tutorial_cells(section, plan)
        # Add custom quiz cell
        cells.append({
            'type': 'code',
            'source': '# Quiz: What happens when frequency doubles?\nanswer = ""  # Type your answer\nprint(f"Your answer: {answer}")'
        })
        return cells
```

## Output Formats

### Jupyter (.ipynb)
- Standard Jupyter notebook format
- Works with JupyterLab, VS Code, Google Colab
- Supports ipywidgets for interactivity
- Best for: Traditional notebook workflows

### Marimo (.py)
- Pure Python reactive notebooks
- Git-friendly (diffable)
- Reactive by default (cells auto-update)
- Best for: Version-controlled educational content

## Integration with Taxonomy

The generator uses the taxonomy to make intelligent decisions:

| Concept | Pattern | Framework | Generated Content |
|---------|---------|-----------|-------------------|
| `electrostatic_field` | vectorfield | plotly | 3D quiver plot + potential heatmap |
| `amplifier_topologies` | graphnet | schemdraw | Circuit schematics + gain plots |
| `diffusion_models` | processanim | matplotlib | Denoising trajectory animation |
| `attention_heatmaps` | scalarfield | bertviz | Interactive attention visualization |

## Error Handling

The evaluation phase catches:
- **Syntax errors**: Missing imports, typos
- **Runtime errors**: Division by zero, shape mismatches
- **UX violations**: Overlapping labels, bad colormaps
- **Scientific errors**: Incorrect formulas, wrong units

Common fixes:
```python
# If execution fails
result = system.evaluator.evaluate("notebook.ipynb")
if not result.passed:
    print("Errors:", result.errors)
    # Manually fix or use repair agent
```

## Best Practices

1. **Start with taxonomy lookup** — Ensure your concept is well-defined
2. **Use appropriate format** — Jupyter for exploration, Marimo for production
3. **Run evaluation** — Always check generated notebooks execute correctly
4. **Iterate** — Use max_iterations=3 for auto-fixing common issues
5. **Review UX rules** — The generator enforces patterns, but human review ensures quality

## Troubleshooting

**Issue**: `ModuleNotFoundError` for taxonomy imports
**Fix**: Run from project root or add to PYTHONPATH:
```python
import sys
sys.path.insert(0, 'docs/superpowers/viz-framework')
```

**Issue**: Jupyter not found during evaluation
**Fix**: Install jupyter or skip evaluation:
```python
system.generate(..., max_iterations=0)
```

**Issue**: Marimo lint errors
**Fix**: Run `marimo check --fix notebook.py`

## API Reference

### AgenticNotebookSystem

Main orchestrator class.

**Methods:**
- `generate(concept, domain, output_format, output_path, max_iterations)` → str
- `list_concepts(domain)` → List[str]

### NotebookPlanner

Creates learning plans from taxonomy.

**Methods:**
- `plan(concept_name, domain)` → ConceptPlan

### NotebookGenerator

Generates notebook cells.

**Methods:**
- `generate(plan, output_format)` → GeneratedNotebook
- `to_ipynb(notebook, path)` → str
- `to_marimo(notebook, path)` → str

### NotebookEvaluator

Validates notebooks.

**Methods:**
- `evaluate(notebook_path, timeout)` → EvaluationResult

### NotebookIterator

Auto-fixes issues.

**Methods:**
- `iterate(notebook_path, max_iterations)` → Tuple[str, EvaluationResult]

## Examples

See `agentic/examples/` for complete examples:
- `generate_notebook.py` — Basic usage
- `batch_generate.py` — Generate all concepts in a domain
- `custom_generator.py` — Extend with custom patterns

## Citation

If you use this system in research or education:

```bibtex
@software{agentic_edu_viz,
  title={Agentic Educational Visualization Framework},
  author={AI Agentic R&D Engineer},
  year={2026},
  url={https://github.com/your-repo}
}
```
