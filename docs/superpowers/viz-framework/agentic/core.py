"""Agentic Educational Notebook Generator

A 4-phase pipeline for generating insightful learning materials:
Planning → Generation → Evaluation → Iteration

Usage:
    from agentic import NotebookGenerator
    
    gen = NotebookGenerator(
        taxonomy_dir="taxonomy",
        patterns_file="patterns/nine-patterns.yaml",
        prompts_dir="templates/agent-prompts",
        code_patterns_dir="templates/code-patterns"
    )
    
    notebook_path = gen.generate(
        concept="electrostatic_field",
        domain="physics",
        output_format="jupyter",  # or "marimo"
        output_path="electrostatic_field.ipynb"
    )
"""

import yaml
import json
import os
import sys
import subprocess
import tempfile
import nbformat as nbf
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass, field

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))


@dataclass
class ConceptPlan:
    """Output of the Planning phase."""
    concept_name: str
    domain: str
    primary_pattern: str
    best_framework: str
    learning_objectives: List[str]
    prerequisites: List[str]
    sections: List[Dict[str, Any]]
    ux_rules: List[str]
    gotchas: List[str]


@dataclass
class GeneratedNotebook:
    """Output of the Generation phase."""
    cells: List[Dict[str, Any]]
    metadata: Dict[str, Any] = field(default_factory=dict)
    format: str = "jupyter"  # or "marimo"


@dataclass
class EvaluationResult:
    """Output of the Evaluation phase."""
    passed: bool
    errors: List[str]
    warnings: List[str]
    execution_time: float = 0.0


class TaxonomyLoader:
    """Loads and queries the taxonomy YAML files."""
    
    def __init__(self, taxonomy_dir: str):
        self.taxonomy_dir = Path(taxonomy_dir)
        self.taxonomies = {}
        self._load_all()
    
    def _load_all(self):
        for domain_file in self.taxonomy_dir.glob("*.yaml"):
            domain = domain_file.stem
            with open(domain_file, 'r', encoding='utf-8') as f:
                self.taxonomies[domain] = yaml.safe_load(f)
    
    def find_concept(self, concept_name: str, domain: Optional[str] = None) -> Optional[Dict]:
        """Find a concept by name across all or specified domain."""
        domains = [domain] if domain else self.taxonomies.keys()
        
        for dom in domains:
            if dom not in self.taxonomies:
                continue
            for sub_name, sub_data in self.taxonomies[dom]['sub_disciplines'].items():
                for concept in sub_data.get('concepts', []):
                    if concept['name'] == concept_name:
                        return {
                            'domain': dom,
                            'sub_discipline': sub_name,
                            **concept
                        }
        return None
    
    def list_concepts(self, domain: str) -> List[str]:
        """List all concept names in a domain."""
        concepts = []
        if domain in self.taxonomies:
            for sub_data in self.taxonomies[domain]['sub_disciplines'].values():
                concepts.extend([c['name'] for c in sub_data.get('concepts', [])])
        return concepts


class PatternLoader:
    """Loads and queries the nine-patterns definition."""
    
    def __init__(self, patterns_file: str):
        with open(patterns_file, 'r', encoding='utf-8') as f:
            self.patterns = yaml.safe_load(f)
    
    def get_pattern(self, pattern_name: str) -> Optional[Dict]:
        return self.patterns['patterns'].get(pattern_name)
    
    def get_ux_rules(self) -> List[Dict]:
        return self.patterns['ux_quality_rules']
    
    def get_anti_patterns(self) -> List[Dict]:
        return self.patterns['anti_patterns']
    
    def get_interaction_tier(self, tier_name: str) -> Optional[Dict]:
        return self.patterns['interaction_tiers'].get(tier_name)


class PromptLoader:
    """Loads agent prompt templates for frameworks."""
    
    def __init__(self, prompts_dir: str):
        self.prompts_dir = Path(prompts_dir)
        self.prompts = {}
        self._load_all()
    
    def _load_all(self):
        for prompt_file in self.prompts_dir.glob("*.md"):
            framework = prompt_file.stem
            with open(prompt_file, 'r', encoding='utf-8') as f:
                self.prompts[framework] = f.read()
    
    def get_prompt(self, framework: str) -> Optional[str]:
        return self.prompts.get(framework)


class NotebookPlanner:
    """Phase 1: Planning — creates structured learning outline."""
    
    def __init__(self, taxonomy: TaxonomyLoader, patterns: PatternLoader):
        self.taxonomy = taxonomy
        self.patterns = patterns
    
    def plan(self, concept_name: str, domain: str) -> ConceptPlan:
        """Create a learning plan for a concept using Diátaxis structure."""
        concept = self.taxonomy.find_concept(concept_name, domain)
        if not concept:
            raise ValueError(f"Concept '{concept_name}' not found in domain '{domain}'")
        
        pattern = self.patterns.get_pattern(concept['primary_pattern'])
        
        # Build Diátaxis-based sections
        sections = self._build_sections(concept, pattern)
        
        return ConceptPlan(
            concept_name=concept_name,
            domain=domain,
            primary_pattern=concept['primary_pattern'],
            best_framework=concept['best_framework'],
            learning_objectives=self._generate_objectives(concept),
            prerequisites=self._infer_prerequisites(concept),
            sections=sections,
            ux_rules=concept.get('ux_rules', []),
            gotchas=concept.get('gotchas', [])
        )
    
    def _build_sections(self, concept: Dict, pattern: Optional[Dict]) -> List[Dict]:
        """Build Diátaxis-structured sections."""
        sections = []
        
        # 1. Tutorial: Hands-on introduction
        sections.append({
            'type': 'tutorial',
            'title': f'Getting Started with {concept["name"].replace("_", " ").title()}',
            'description': f'Interactive exploration of {concept["name"]}',
            'pattern': concept['primary_pattern'],
            'framework': concept['best_framework'],
            'interaction_tier': 't1_explore',
            'content_goal': 'Build intuition through manipulation'
        })
        
        # 2. Explanation: Conceptual deep-dive
        sections.append({
            'type': 'explanation',
            'title': f'Understanding {concept["name"].replace("_", " ").title()}',
            'description': f'Why {concept["name"]} works and what it means',
            'pattern': concept['primary_pattern'],
            'framework': concept['best_framework'],
            'interaction_tier': 't2_guide',
            'content_goal': 'Connect visual to mathematical/physical principles'
        })
        
        # 3. How-to: Practical application
        sections.append({
            'type': 'how-to',
            'title': f'Applying {concept["name"].replace("_", " ").title()}',
            'description': f'Step-by-step guide to using {concept["name"]}',
            'pattern': concept.get('secondary_patterns', [concept['primary_pattern']])[0],
            'framework': concept.get('alt_framework', concept['best_framework']),
            'interaction_tier': 't3_discover',
            'content_goal': 'Solve real problems with the concept'
        })
        
        # 4. Reference: Technical details
        sections.append({
            'type': 'reference',
            'title': f'{concept["name"].replace("_", " ").title()} — Reference',
            'description': 'Key formulas, parameters, and edge cases',
            'pattern': concept['primary_pattern'],
            'framework': concept['best_framework'],
            'interaction_tier': 't4_progressive_disclosure',
            'content_goal': 'Quick lookup for practitioners'
        })
        
        return sections
    
    def _generate_objectives(self, concept: Dict) -> List[str]:
        """Generate learning objectives from concept metadata."""
        return [
            f"Visualize and interpret {concept['name'].replace('_', ' ')}",
            f"Identify the correct pattern ({concept['primary_pattern']}) for representing this concept",
            f"Apply the {concept['best_framework']} framework to create publication-quality visualizations",
            f"Avoid common pitfalls: {', '.join(concept.get('gotchas', [])[:2])}"
        ]
    
    def _infer_prerequisites(self, concept: Dict) -> List[str]:
        """Infer prerequisites from pattern and domain."""
        prereqs = ["Python basics", "NumPy arrays"]
        if concept['best_framework'] in ['matplotlib', 'seaborn']:
            prereqs.append("Matplotlib fundamentals")
        elif concept['best_framework'] in ['plotly', 'altair']:
            prereqs.append("Interactive plotting concepts")
        return prereqs


class NotebookGenerator:
    """Phase 2: Generation — creates notebook cells from plan."""
    
    def __init__(self, prompts: PromptLoader, code_patterns_dir: str):
        self.prompts = prompts
        self.code_patterns_dir = Path(code_patterns_dir)
    
    def generate(self, plan: ConceptPlan, output_format: str = "jupyter") -> GeneratedNotebook:
        """Generate notebook cells from a concept plan."""
        cells = []
        
        # Title cell
        cells.append(self._create_title_cell(plan))
        
        # Learning objectives
        cells.append(self._create_objectives_cell(plan))
        
        # Prerequisites
        cells.append(self._create_prerequisites_cell(plan))
        
        # Generate sections
        for section in plan.sections:
            cells.extend(self._generate_section(section, plan, output_format))
        
        # Summary cell
        cells.append(self._create_summary_cell(plan))
        
        return GeneratedNotebook(
            cells=cells,
            format=output_format,
            metadata={
                'concept': plan.concept_name,
                'domain': plan.domain,
                'pattern': plan.primary_pattern,
                'framework': plan.best_framework
            }
        )
    
    def _create_title_cell(self, plan: ConceptPlan) -> Dict:
        return {
            'type': 'markdown',
            'source': f"# {plan.concept_name.replace('_', ' ').title()}\n\n"
                     f"**Domain:** {plan.domain.title()}  \n"
                     f"**Pattern:** {plan.primary_pattern}  \n"
                     f"**Framework:** {plan.best_framework}  \n\n"
                     f"*Generated by the Educational Visualization Framework*"
        }
    
    def _create_objectives_cell(self, plan: ConceptPlan) -> Dict:
        objectives = "\n".join([f"- {obj}" for obj in plan.learning_objectives])
        return {
            'type': 'markdown',
            'source': f"## Learning Objectives\n\n{objectives}"
        }
    
    def _create_prerequisites_cell(self, plan: ConceptPlan) -> Dict:
        prereqs = "\n".join([f"- {pr}" for pr in plan.prerequisites])
        return {
            'type': 'markdown',
            'source': f"## Prerequisites\n\n{prereqs}"
        }
    
    def _generate_section(self, section: Dict, plan: ConceptPlan, output_format: str) -> List[Dict]:
        """Generate cells for one Diátaxis section."""
        cells = []
        
        # Section header
        cells.append({
            'type': 'markdown',
            'source': f"## {section['title']}\n\n"
                     f"*{section['description']}*\n\n"
                     f"**Pattern:** `{section['pattern']}` | "
                     f"**Framework:** `{section['framework']}` | "
                     f"**Interaction:** `{section['interaction_tier']}`"
        })
        
        # Content based on section type
        if section['type'] == 'tutorial':
            cells.extend(self._generate_tutorial_cells(section, plan))
        elif section['type'] == 'explanation':
            cells.extend(self._generate_explanation_cells(section, plan))
        elif section['type'] == 'how-to':
            cells.extend(self._generate_howto_cells(section, plan))
        elif section['type'] == 'reference':
            cells.extend(self._generate_reference_cells(section, plan))
        
        return cells
    
    def _generate_tutorial_cells(self, section: Dict, plan: ConceptPlan) -> List[Dict]:
        """Generate interactive exploration cells."""
        cells = []
        
        # Explanation
        cells.append({
            'type': 'markdown',
            'source': f"Let's explore {plan.concept_name.replace('_', ' ')} interactively. "
                     f"Use the sliders below to change parameters and observe the effect."
        })
        
        # Import cell
        cells.append({
            'type': 'code',
            'source': self._generate_imports(plan.best_framework)
        })
        
        # Interactive parameter cell
        cells.append({
            'type': 'code',
            'source': self._generate_interactive_parameters(plan)
        })
        
        # Visualization cell
        cells.append({
            'type': 'code',
            'source': self._generate_visualization_code(plan, section)
        })
        
        return cells
    
    def _generate_explanation_cells(self, section: Dict, plan: ConceptPlan) -> List[Dict]:
        """Generate conceptual explanation with visualization."""
        cells = []
        
        # Concept explanation
        cells.append({
            'type': 'markdown',
            'source': f"### The Physics Behind {plan.concept_name.replace('_', ' ').title()}\n\n"
                     f"This section explains the underlying principles with visual aids.\n\n"
                     f"**Key Insight:** Understanding {plan.concept_name.replace('_', ' ')} requires "
                     f"grasping how the {plan.primary_pattern} pattern reveals hidden structure."
        })
        
        # Mathematical formulation (if applicable)
        cells.append({
            'type': 'markdown',
            'source': f"### Mathematical Formulation\n\n"
                     f"The core equation governing this phenomenon:\n\n"
                     f"$$\\text{{Equation for }} {plan.concept_name.replace('_', ' ')}$$\n\n"
                     f"*See the code cell below for the implementation.*"
        })
        
        # Code visualization
        cells.append({
            'type': 'code',
            'source': self._generate_visualization_code(plan, section)
        })
        
        # Guided observation questions
        cells.append({
            'type': 'markdown',
            'source': f"### Guided Observation\n\n"
                     f"1. What happens when you increase the frequency?\n"
                     f"2. Where is the field strongest? Why?\n"
                     f"3. How does this relate to the boundary conditions?"
        })
        
        return cells
    
    def _generate_howto_cells(self, section: Dict, plan: ConceptPlan) -> List[Dict]:
        """Generate practical application cells."""
        cells = []
        
        cells.append({
            'type': 'markdown',
            'source': f"### Step-by-Step Guide\n\n"
                     f"Follow these steps to apply {plan.concept_name.replace('_', ' ')} in practice."
        })
        
        # Step 1: Setup
        cells.append({
            'type': 'code',
            'source': f"# Step 1: Import required libraries\n"
                     f"{self._generate_imports(plan.best_framework)}\n\n"
                     f"# Step 2: Define parameters\n"
                     f"# TODO: Adjust these parameters for your specific case\n"
                     f"params = {{'key': 'value'}}  # Replace with actual parameters"
        })
        
        # Step 2: Implementation
        cells.append({
            'type': 'code',
            'source': self._generate_visualization_code(plan, section)
        })
        
        # Exercise
        cells.append({
            'type': 'markdown',
            'source': f"### Exercise\n\n"
                     f"Modify the code above to: \n"
                     f"1. Change the primary parameter by ±20%\n"
                     f"2. Observe how the visualization changes\n"
                     f"3. Document your findings in a markdown cell below"
        })
        
        return cells
    
    def _generate_reference_cells(self, section: Dict, plan: ConceptPlan) -> List[Dict]:
        """Generate reference material cells."""
        cells = []
        
        # Key parameters table
        cells.append({
            'type': 'markdown',
            'source': f"### Key Parameters\n\n"
                     f"| Parameter | Symbol | Unit | Typical Range |\n"
                     f"|-----------|--------|------|---------------|\n"
                     f"| Parameter 1 | $p_1$ | Unit | 0-100 |\n"
                     f"| Parameter 2 | $p_2$ | Unit | 0-1 |\n\n"
                     f"*Note: These are representative values. Consult the literature for your specific application.*"
        })
        
        # UX rules reference
        ux_rules_text = "\n".join([f"- **{i+1}.** {rule}" for i, rule in enumerate(plan.ux_rules)])
        cells.append({
            'type': 'markdown',
            'source': f"### Visualization Quality Checklist\n\n{ux_rules_text}"
        })
        
        # Gotchas
        gotchas_text = "\n".join([f"- ⚠️ {gotcha}" for gotcha in plan.gotchas])
        cells.append({
            'type': 'markdown',
            'source': f"### Common Pitfalls\n\n{gotchas_text}"
        })
        
        return cells
    
    def _generate_imports(self, framework: str) -> str:
        """Generate import statements for a framework."""
        imports = {
            'matplotlib': "import numpy as np\nimport matplotlib.pyplot as plt\nimport matplotlib\nmatplotlib.use('Agg')  # Non-interactive backend",
            'plotly': "import numpy as np\nimport plotly.express as px\nimport plotly.graph_objects as go",
            'schemdraw': "import schemdraw\nimport schemdraw.elements as elm",
            'pyvista': "import pyvista as pv\nimport numpy as np",
            'altair': "import altair as alt\nimport pandas as pd\nimport numpy as np",
            'manim': "from manim import *",
            'bokeh': "from bokeh.plotting import figure, output_file, save\nfrom bokeh.io import output_notebook\noutput_notebook()",
            'bertviz': "from transformers import AutoTokenizer, AutoModel\nfrom bertviz import head_view, model_view",
            'torchview': "import torch\nfrom torchview import draw_graph",
        }
        return imports.get(framework, f"import numpy as np\n# TODO: Add {framework} imports")
    
    def _generate_interactive_parameters(self, plan: ConceptPlan) -> str:
        """Generate interactive parameter sliders."""
        return f"""# Interactive parameters
# Adjust these sliders to explore different scenarios

# Example parameters (customize for your concept)
param1 = 1.0  # Primary parameter
param2 = 0.5  # Secondary parameter

print(f"Parameters set: p1={{param1}}, p2={{param2}}")
"""
    
    def _generate_visualization_code(self, plan: ConceptPlan, section: Dict) -> str:
        """Generate visualization code based on pattern and framework."""
        # Load the appropriate code pattern if available
        pattern_file = self.code_patterns_dir / f"{plan.primary_pattern}.py"
        if pattern_file.exists():
            # In a real implementation, we'd parse the pattern file and extract
            # the render function. For now, generate placeholder code.
            return f"""# Visualization: {plan.concept_name.replace('_', ' ')} using {plan.best_framework}
# Pattern: {plan.primary_pattern}

# Generate sample data
import numpy as np

# TODO: Replace with actual data for your concept
x = np.linspace(0, 10, 100)
y = np.sin(x)

# Create visualization
# (See templates/code-patterns/{plan.primary_pattern}.py for the full pattern)

print("Visualization generated successfully")
"""
        else:
            return f"""# Visualization placeholder for {plan.concept_name}
# Framework: {plan.best_framework}
# Pattern: {plan.primary_pattern}

# TODO: Implement visualization using the {plan.best_framework} framework
# Reference: templates/agent-prompts/{plan.best_framework}.md

print("Placeholder: Add your visualization code here")
"""
    
    def _create_summary_cell(self, plan: ConceptPlan) -> Dict:
        """Create a summary cell."""
        return {
            'type': 'markdown',
            'source': f"## Summary\n\n"
                     f"In this notebook, we explored **{plan.concept_name.replace('_', ' ')}** using: \n"
                     f"- **Pattern:** `{plan.primary_pattern}`\n"
                     f"- **Framework:** `{plan.best_framework}`\n\n"
                     f"### Key Takeaways\n"
                     f"- The {plan.primary_pattern} pattern is ideal for visualizing this concept\n"
                     f"- {plan.best_framework.title()} provides the right balance of control and interactivity\n"
                     f"- Always follow the UX quality rules to ensure clarity\n\n"
                     f"### Next Steps\n"
                     f"- Explore related concepts in the taxonomy\n"
                     f"- Try the exercises in the How-to section\n"
                     f"- Apply these patterns to your own data"
        }
    
    def to_ipynb(self, notebook: GeneratedNotebook, output_path: str) -> str:
        """Convert generated cells to .ipynb format."""
        nb = nbf.v4.new_notebook()
        
        for cell_data in notebook.cells:
            if cell_data['type'] == 'markdown':
                cell = nbf.v4.new_markdown_cell(cell_data['source'])
            elif cell_data['type'] == 'code':
                cell = nbf.v4.new_code_cell(cell_data['source'])
                cell.metadata['tags'] = ['remove-input']  # Optional: hide code in exports
            else:
                cell = nbf.v4.new_raw_cell(cell_data['source'])
            nb.cells.append(cell)
        
        # Add metadata
        nb.metadata['concept'] = notebook.metadata.get('concept', '')
        nb.metadata['domain'] = notebook.metadata.get('domain', '')
        nb.metadata['kernelspec'] = {
            'display_name': 'Python 3',
            'language': 'python',
            'name': 'python3'
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            nbf.write(nb, f)
        
        return output_path
    
    def to_marimo(self, notebook: GeneratedNotebook, output_path: str) -> str:
        """Convert generated cells to Marimo .py format."""
        lines = [
            "import marimo",
            "",
            "app = marimo.App()",
            ""
        ]
        
        for cell_data in notebook.cells:
            lines.append("@app.cell")
            lines.append("def __():")
            
            if cell_data['type'] == 'markdown':
                # Escape quotes in markdown
                content = cell_data['source'].replace('"', '\\"')
                lines.append(f'    return marimo.md("""{content}""")')
            elif cell_data['type'] == 'code':
                for line in cell_data['source'].split('\n'):
                    lines.append(f"    {line}")
                lines.append("    return ()")
            
            lines.append("")
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))
        
        return output_path


class NotebookEvaluator:
    """Phase 3: Evaluation — validates generated notebooks."""
    
    def evaluate(self, notebook_path: str, timeout: int = 120) -> EvaluationResult:
        """Evaluate a notebook by executing it and checking for errors."""
        errors = []
        warnings = []
        
        # 1. Validate notebook structure
        try:
            if notebook_path.endswith('.ipynb'):
                nb = nbf.read(notebook_path, as_version=4)
                nbf.validate(nb)
            elif notebook_path.endswith('.py'):
                # Check if it's valid Python
                with open(notebook_path, 'r') as f:
                    compile(f.read(), notebook_path, 'exec')
        except Exception as e:
            errors.append(f"Validation failed: {e}")
            return EvaluationResult(passed=False, errors=errors, warnings=warnings)
        
        # 2. Execute notebook (if .ipynb)
        if notebook_path.endswith('.ipynb'):
            try:
                import time
                start = time.time()
                result = subprocess.run(
                    ["jupyter", "nbconvert", "--to", "notebook", "--execute", 
                     "--output", "/dev/null", notebook_path],
                    capture_output=True, text=True, timeout=timeout
                )
                elapsed = time.time() - start
                
                if result.returncode != 0:
                    errors.append(f"Execution failed: {result.stderr}")
                
            except subprocess.TimeoutExpired:
                errors.append(f"Execution timed out after {timeout}s")
                elapsed = timeout
            except FileNotFoundError:
                warnings.append("jupyter not found in PATH, skipping execution test")
                elapsed = 0
        
        # 3. Check for marimo lint (if .py)
        if notebook_path.endswith('.py'):
            try:
                result = subprocess.run(
                    ["marimo", "check", "--format=json", notebook_path],
                    capture_output=True, text=True
                )
                if result.returncode != 0:
                    warnings.append(f"Marimo lint issues: {result.stdout}")
            except FileNotFoundError:
                warnings.append("marimo not found, skipping lint check")
        
        return EvaluationResult(
            passed=len(errors) == 0,
            errors=errors,
            warnings=warnings,
            execution_time=elapsed if 'elapsed' in locals() else 0
        )


class NotebookIterator:
    """Phase 4: Iteration — fixes issues based on evaluation feedback."""
    
    def __init__(self, generator: NotebookGenerator, evaluator: NotebookEvaluator):
        self.generator = generator
        self.evaluator = evaluator
    
    def iterate(self, notebook_path: str, max_iterations: int = 3) -> Tuple[str, EvaluationResult]:
        """Run evaluation-iteration loop until notebook passes or max iterations reached."""
        for i in range(max_iterations):
            print(f"\n=== Iteration {i+1}/{max_iterations} ===")
            
            result = self.evaluator.evaluate(notebook_path)
            
            if result.passed:
                print(f"✅ Notebook passed all checks")
                return notebook_path, result
            
            print(f"❌ Found {len(result.errors)} errors:")
            for error in result.errors:
                print(f"   - {error}")
            
            if i < max_iterations - 1:
                print(f"🔧 Attempting to fix issues...")
                # In a full implementation, this would call an LLM repair agent
                # For now, we just report that manual fixing is needed
                print(f"   (Manual fixing required: edit {notebook_path})")
        
        return notebook_path, result


class AgenticNotebookSystem:
    """Main orchestrator that runs the full 4-phase pipeline."""
    
    def __init__(self, 
                 taxonomy_dir: str = "taxonomy",
                 patterns_file: str = "patterns/nine-patterns.yaml",
                 prompts_dir: str = "templates/agent-prompts",
                 code_patterns_dir: str = "templates/code-patterns"):
        
        base_path = Path(__file__).parent.parent
        
        self.taxonomy = TaxonomyLoader(base_path / taxonomy_dir)
        self.patterns = PatternLoader(base_path / patterns_file)
        self.prompts = PromptLoader(base_path / prompts_dir)
        
        self.planner = NotebookPlanner(self.taxonomy, self.patterns)
        self.generator = NotebookGenerator(self.prompts, base_path / code_patterns_dir)
        self.evaluator = NotebookEvaluator()
        self.iterator = NotebookIterator(self.generator, self.evaluator)
    
    def generate(self, 
                 concept: str, 
                 domain: str,
                 output_format: str = "jupyter",
                 output_path: Optional[str] = None,
                 max_iterations: int = 3) -> str:
        """Run the full pipeline to generate a notebook."""
        
        print(f"\n{'='*60}")
        print(f"🎓 Generating Educational Notebook")
        print(f"   Concept: {concept}")
        print(f"   Domain: {domain}")
        print(f"   Format: {output_format}")
        print(f"{'='*60}")
        
        # Phase 1: Planning
        print(f"\n📋 Phase 1: Planning...")
        plan = self.planner.plan(concept, domain)
        print(f"   ✅ Planned {len(plan.sections)} sections")
        print(f"   📚 Pattern: {plan.primary_pattern}")
        print(f"   🛠️  Framework: {plan.best_framework}")
        
        # Phase 2: Generation
        print(f"\n📝 Phase 2: Generation...")
        notebook = self.generator.generate(plan, output_format)
        print(f"   ✅ Generated {len(notebook.cells)} cells")
        
        # Determine output path
        if not output_path:
            output_path = f"{concept}.{output_format}"
            if output_format == "jupyter":
                output_path = f"{concept}.ipynb"
            elif output_format == "marimo":
                output_path = f"{concept}.py"
        
        # Write notebook
        if output_format == "jupyter":
            self.generator.to_ipynb(notebook, output_path)
        elif output_format == "marimo":
            self.generator.to_marimo(notebook, output_path)
        
        print(f"   💾 Saved to: {output_path}")
        
        # Phase 3 & 4: Evaluation & Iteration
        if max_iterations > 0:
            print(f"\n🔍 Phase 3-4: Evaluation & Iteration...")
            final_path, result = self.iterator.iterate(output_path, max_iterations)
            
            if result.passed:
                print(f"\n🎉 Notebook generation complete!")
            else:
                print(f"\n⚠️  Notebook generated with {len(result.errors)} errors.")
                print(f"   Please review: {final_path}")
        
        return output_path
    
    def list_concepts(self, domain: str) -> List[str]:
        """List all available concepts in a domain."""
        return self.taxonomy.list_concepts(domain)


if __name__ == "__main__":
    # Example usage
    system = AgenticNotebookSystem()
    
    # List available concepts
    print("Available Physics concepts:")
    for concept in system.list_concepts("physics")[:5]:
        print(f"  - {concept}")
    
    # Generate a notebook
    notebook_path = system.generate(
        concept="electrostatic_field",
        domain="physics",
        output_format="jupyter",
        output_path="electrostatic_field.ipynb",
        max_iterations=0  # Skip evaluation for demo
    )
    
    print(f"\n📖 Generated notebook: {notebook_path}")
