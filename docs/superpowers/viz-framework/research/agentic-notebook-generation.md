# Agentic Notebook Generation: Research Report

**Research Date:** 2026-04-27
**Topic:** Best practices and tools for building AI agentic systems that automatically generate educational Jupyter and Marimo notebooks.

---

## Executive Summary

This report investigates the architecture, tools, and best practices for building AI agentic systems that programmatically generate educational Jupyter and Marimo notebooks. The notebook generation ecosystem has matured significantly, with three primary programmatic pathways emerging: (1) **`nbformat`** for direct JSON-level construction of `.ipynb` files; (2) **`jupytext`** for bidirectional conversion between notebooks and plain-text formats (`.py`, `.md`); and (3) **Marimo's pure-Python format** combined with its `marimo new` text-to-notebook AI generation. For agentic systems, the most robust architecture follows a four-phase pipeline: **Planning** (topic selection, learning objective mapping, prerequisite analysis), **Generation** (markdown prose, code cells, visualizations), **Evaluation** (execution validation, accuracy checks, linter feedback), and **Iteration** (self-correction based on evaluation feedback). Key findings include: Jupyter AI and Marimo now provide first-class agent interfaces (MCP servers, chat-based notebook editing) that allow AI agents to create and modify notebooks interactively; the Diátaxis framework (tutorials, how-to guides, explanations, reference) provides the most effective structural scaffold for educational content; and Marimo's `marimo check` linter is specifically designed to give agents programmatic feedback for self-correction. Systems like DecipherIt demonstrate that multi-agent CrewAI architectures can successfully orchestrate research pipelines that output structured notebook-like content.

---

## 1. Introduction

### 1.1 Scope and Objectives

The objective of this research is to identify the optimal tools, libraries, and architectural patterns for constructing an AI agentic system capable of autonomously generating high-quality educational notebooks. The research spans:

- **Notebook formats and programmatic APIs**: How to create `.ipynb` and Marimo `.py` notebooks without manual intervention.
- **Content architecture**: How to structure educational material so that it is not merely correct, but pedagogically effective.
- **Agent design patterns**: How to decompose the content creation workflow into planning, generation, evaluation, and iteration phases.
- **Existing implementations**: What can be learned from Jupyter AI, nbdev, Marimo's AI features, and research assistants like DecipherIt.

### 1.2 Methodology

This report synthesizes information from official documentation (nbformat, jupytext, marimo, Jupyter AI, papermill), technical tutorials, GitHub issues, and research into active open-source projects. Sources were triangulated across documentation, code repositories, and third-party analyses to ensure accuracy.

---

## 2. Notebook Generation Tools

### 2.1 nbformat: The Foundation of Programmatic `.ipynb` Creation

The **`nbformat`** library is the official reference implementation for the Jupyter Notebook format and provides the lowest-level, most explicit API for creating notebooks programmatically. A Jupyter Notebook is fundamentally a JSON document with a well-defined schema; `nbformat` wraps this schema in Python objects.

#### 2.1.1 Core API

The `nbformat.v4` module provides constructor functions for all notebook components [1][2]:

- `nbformat.v4.new_notebook()` – Creates an empty notebook.
- `nbformat.v4.new_markdown_cell(source)` – Creates a markdown cell.
- `nbformat.v4.new_code_cell(source)` – Creates a code cell.
- `nbformat.v4.new_raw_cell(source)` – Creates a raw cell.
- `nbformat.read(fp, as_version=4)` – Reads an existing notebook.
- `nbformat.write(nb, fp)` – Writes a notebook to disk.

#### 2.1.2 Basic Example

```python
import nbformat as nbf

# Create a new notebook
nb = nbf.v4.new_notebook()

# Add a title markdown cell
title = nbf.v4.new_markdown_cell("# Introduction to Linear Regression")
nb.cells.append(title)

# Add an explanation markdown cell
explanation = nbf.v4.new_markdown_cell(
    "Linear regression models the relationship between a dependent variable "
    "and one or more independent variables by fitting a linear equation."
)
nb.cells.append(explanation)

# Add a code cell
code = nbf.v4.new_code_cell(
    "import numpy as np\n"
    "import matplotlib.pyplot as plt\n\n"
    "# Generate sample data\n"
    "np.random.seed(42)\n"
    "X = 2 * np.random.rand(100, 1)\n"
    "y = 4 + 3 * X + np.random.randn(100, 1)\n\n"
    "plt.scatter(X, y)\n"
    "plt.xlabel('X')\n"
    "plt.ylabel('y')\n"
    "plt.title('Sample Data')\n"
    "plt.show()"
)
nb.cells.append(code)

# Save the notebook
with open("linear_regression.ipynb", "w", encoding="utf-8") as f:
    nbf.write(nb, f)
```

#### 2.1.3 Advanced Patterns

**Inserting cells at specific positions:** Use `nb.cells.insert(index, cell)` rather than `append()` to control narrative flow [3].

**Cell metadata:** Attach tags to cells for post-processing. For example, tag a code cell with `"tags": ["remove-input"]` to hide the code during HTML/PDF export via `nbconvert` [3]:

```python
code_cell = nbf.v4.new_code_cell("print('Hello')")
code_cell.metadata["tags"] = ["remove-input"]
nb.cells.append(code_cell)
```

**Dynamic content from DataFrames:** Convert pandas DataFrames to markdown tables and embed them directly:

```python
import pandas as pd

df = pd.DataFrame({
    "Concept": ["Slope", "Intercept", "R-squared"],
    "Description": ["Rate of change", "Starting value", "Goodness of fit"]
})
markdown_table = df.to_markdown(index=False)
nb.cells.append(nbf.v4.new_markdown_cell(f"## Key Concepts\n{markdown_table}"))
```

#### 2.1.4 Validation

`nbformat.validate(nb)` checks whether a notebook object conforms to the JSON schema. This is critical in agentic pipelines to catch malformed output before saving [1].

### 2.2 jupytext: Bridging Plain Text and Notebooks

**Jupytext** provides two-way conversion between Jupyter notebooks and several text-based formats, most importantly Python scripts (`py:percent` or `py:light`) and Markdown (`md` or `md:myst`) [4][5]. This is invaluable for agentic systems because:

1. **Version control**: Text formats yield clean diffs, making it easier for agents to read, modify, and patch notebooks.
2. **IDE compatibility**: Agents can operate on `.py` files using standard Python tooling (linters, formatters) and convert to `.ipynb` on demand.
3. **Simpler generation**: Generating a `.py` file with `# %% [markdown]` and `# %%` cell markers is often easier than manipulating JSON.

#### 2.2.1 Key CLI Commands

```bash
# Pair a notebook with a Python script
jupytext --set-formats ipynb,py:percent notebook.ipynb

# Convert a script to a notebook
jupytext --to ipynb notebook.py

# Convert with execution
jupytext --to ipynb --execute notebook.py

# Sync paired files
jupytext --sync notebook.ipynb

# Convert all markdown files to notebooks
jupytext --to ipynb *.md
```

#### 2.2.2 The `py:percent` Format

A Python script in `py:percent` format uses explicit cell markers [4]:

```python
# %% [markdown]
# # My Notebook Title
# This is a markdown cell.

# %%
import numpy as np
x = np.array([1, 2, 3])

# %% [markdown]
# ## Next Section
# Another markdown cell.

# %%
print(x.mean())
```

This format is ideal for agents because it is linear, human-readable, and supported by VS Code, PyCharm, and Spyder.

#### 2.2.3 Programmatic Usage

Jupytext can be used as a Python library within an agent pipeline:

```python
import jupytext

# Read a notebook from a Python script
nb = jupytext.read("notebook.py", fmt="py:percent")

# Modify the notebook programmatically...

# Write back to .ipynb
jupytext.write(nb, "notebook.ipynb")
```

### 2.3 Marimo: The Reactive, Pure-Python Notebook

**Marimo** represents a paradigm shift: notebooks are stored as pure Python (`.py`) files rather than JSON. They feature reactive execution (cells auto-update based on a DAG), are Git-friendly by default, and can be run as scripts or deployed as apps [6][7].

#### 2.3.1 Marimo File Format

A marimo notebook is a Python script decorated with `@app.cell`:

```python
import marimo

app = marimo.App()

@app.cell
def __():
    import marimo as mo
    return (mo,)

@app.cell
def __(mo):
    mo.md("# Hello, marimo!")
    return

@app.cell
def __():
    x = 10
    return (x,)

@app.cell
def __(x):
    print(x * 2)
    return
```

Because marimo notebooks are valid Python, they integrate seamlessly with standard tooling: `pytest`, `ruff`, `mypy`, and CI pipelines [8].

#### 2.3.2 Programmatic Creation (Current State)

As of the research date, marimo does **not** expose a high-level public API for constructing notebooks programmatically from scratch. GitHub issue #4801 explicitly requests public helpers for this use case, noting that users currently rely on private functions that may change [9]. However, agents can:

1. **Write `.py` files directly**: Since marimo notebooks are pure Python, an agent can simply write a `.py` file with `@app.cell` decorators.
2. **Use `marimo new`**: Marimo supports generating entire notebooks from a natural language prompt via the CLI [10]:
   ```bash
   marimo new "Plot an interactive 3D surface with matplotlib."
   ```
3. **Use the AI completion API**: The marimo editor has a chat panel and cell generation that can be driven by prompts, including an "Agent" mode that can edit notebook cells programmatically [11].

#### 2.3.3 `marimo check`: A Linter for Agents

A critical tool for agentic generation is `marimo check`, introduced in September 2025. It validates marimo notebooks from the command line, catching issues like multiple variable definitions across cells, circular dependencies, and formatting problems [8]. It supports `--fix` and `--unsafe-fixes` flags for auto-correction, and outputs JSON for agent consumption:

```bash
marimo check --format=json notebook.py | jq '.issues[] | select(.severity == "breaking")'
```

This enables an **evaluation-iteration loop**: an agent generates a notebook, runs `marimo check`, reads the JSON output, and fixes issues automatically.

#### 2.3.4 Marimo's AI-Native Features

Marimo is explicitly designed for AI-assisted coding [11]:

- **Cell generation**: `Ctrl/Cmd-shift-e` to refactor a cell with AI.
- **Chat panel**: Manual, Ask, and Agent modes. Agent mode can add, remove, update cells and run stale cells.
- **Variable context**: The AI assistant has access to variables in memory; users can reference variables with `@` (e.g., `@df` passes dataframe schema to the AI).
- **Custom rules**: Users can configure preferred plotting libraries, data handling, and code style in `marimo.toml`, which constrains AI-generated code.
- **External agents**: Supports Claude Code, Codex, and Gemini CLI via `marimo pair` [6].

### 2.4 Papermill: Parameterized Notebook Execution

While `nbformat` creates notebooks, **papermill** executes them with injected parameters. It is essential for the evaluation phase of an agentic pipeline [12][13].

#### 2.4.1 How It Works

1. A template notebook contains a cell tagged `parameters` with default values.
2. Papermill injects an `injected-parameters` cell after it with runtime values.
3. The notebook executes, producing a new output notebook with results.

```python
import papermill as pm

pm.execute_notebook(
    input_path="template.ipynb",
    output_path="output.ipynb",
    parameters={
        "topic": "Neural Networks",
        "difficulty": "intermediate"
    }
)
```

#### 2.4.2 Agentic Use Case

An agent can generate a template notebook with placeholder sections, then use papermill to render topic-specific variants at scale. This separates the "structure generation" concern from the "content population" concern.

### 2.5 nbdev: Notebook-Driven Development

**nbdev** (by fast.ai) is a platform for developing Python libraries entirely within notebooks. While its primary use case is software development, its best-practices documentation provides the most mature framework for structuring high-quality notebook content [14].

Key relevant features:

- **Diátaxis documentation system**: nbdev organizes content into four forms—tutorials, how-to guides, explanations, and reference [14].
- **Weaving code, tests, and docs**: Every code cell is executable documentation; assertions serve as tests.
- **Export to packages**: Notebooks become installable Python packages.
- **Git-friendly by default**: Encourages small cells with immediate demonstrations.

For an educational notebook generator, nbdev's best practices suggest that notebooks should contain short code cells, each followed by explanatory markdown and working examples.

---

## 3. Agentic Notebook Generation Pipelines

### 3.1 Existing Systems

#### 3.1.1 Jupyter AI

Jupyter AI is an official Project Jupyter extension that integrates generative AI into JupyterLab [15][16]. Its agentic capabilities include:

- **`/generate` command**: Produces entire notebooks from text prompts [16].
- **Jupyternaut**: An experimental chat-based agent that can generate, explain, and fix code [15].
- **Notebook tools**: AI personas have access to MCP (Model Context Protocol) servers that allow them to create/edit notebooks, run code cells, and open files [17].
- **Magic commands**: `%%ai` allows inline LLM interaction within cells.
- **Learning from local files**: The `/learn` and `/ask` commands build a local vector database from project files, enabling RAG-based notebook generation [15].

#### 3.1.2 Marimo's Text-to-Notebook

Marimo's `marimo new PROMPT` is a purpose-built text-to-notebook generator. It understands marimo-specific UI elements (sliders, tables, plots) and can produce interactive educational content [10]. Because marimo stores notebooks as `.py` files, the generated artifacts are immediately reusable as scripts or modules.

#### 3.1.3 DecipherIt (CrewAI Multi-Agent Research)

DecipherIt is a research assistant inspired by Google NotebookLM that demonstrates a full multi-agent pipeline for generating structured research output [18]. Its architecture is directly applicable to educational notebook generation:

| Crew | Agent | Task |
|------|-------|------|
| **Planning** | Web Scraping Strategy Expert | Generate targeted search queries |
| **Link Discovery** | Link Discovery Specialist | Find authoritative sources |
| **Web Scraping** | Expert Web Scraping Engineer | Extract clean markdown content |
| **Research Analysis** | Senior Research Analyst | Synthesize multi-source data |
| **Content Creation** | Research Analyst + Content Writer | Create structured analyses and FAQs |
| **Audio Overview** | Research Analyst + Conversation Planner + Script Writer | Generate podcast transcripts |
| **Mindmap Generation** | Content Analyzer + Mindmap Creator | Build hierarchical visualizations |
| **Chat Response** | Analytical Assistant | Answer questions with source citations |

This crew-based architecture maps cleanly to educational notebook generation: planning → content synthesis → structured output → interactive visualization.

### 3.2 Recommended Architecture for Educational Notebook Generation

Based on the analysis of existing tools and systems, the following four-phase architecture is recommended for an agentic educational notebook generator.

#### Phase 1: Planning

**Objective:** Define what to teach, in what order, and with what prerequisites.

**Components:**

- **Topic Analyzer**: Decomposes a high-level topic (e.g., "Gradient Descent") into sub-concepts using an LLM with chain-of-thought prompting.
- **Learning Objective Generator**: Uses Bloom's taxonomy or similar frameworks to generate measurable objectives for each sub-concept.
- **Prerequisite Mapper**: Builds a dependency graph of concepts. This directly mirrors marimo's reactive DAG philosophy—if concept B depends on A, A must appear first.
- **Outline Builder**: Structures the notebook using the **Diátaxis framework** [14]:
  - **Tutorial**: A guided, hands-on introduction.
  - **How-to Guide**: Task-oriented instructions.
  - **Explanation**: Conceptual deep-dives.
  - **Reference**: API docs, formula sheets.

**Example output (YAML/JSON):**

```yaml
topic: "Linear Regression"
objectives:
  - "Understand the intuition behind fitting a line to data"
  - "Implement ordinary least squares in NumPy"
  - "Evaluate model performance using R-squared"
prerequisites:
  - "Python basics"
  - "NumPy arrays"
  - "Basic statistics (mean, variance)"
sections:
  - type: explanation
    title: "What is Linear Regression?"
    concepts: ["dependent variable", "independent variable", "residuals"]
  - type: tutorial
    title: "Fitting Your First Model"
    tasks: ["Generate data", "Compute coefficients", "Plot result"]
  - type: how-to
    title: "Evaluating Model Fit"
    tasks: ["Calculate MSE", "Interpret R-squared"]
  - type: reference
    title: "OLS Formula Sheet"
```

#### Phase 2: Generation

**Objective:** Produce notebook cells (markdown and code) based on the outline.

**Components:**

- **Markdown Generator**: Writes prose explanations. Should be constrained by style rules (e.g., "Use second person", "Keep paragraphs under 5 sentences").
- **Code Generator**: Produces executable Python cells. Must be aware of:
  - Required imports and their ordering.
  - Variable naming consistency across cells.
  - Visualization libraries (matplotlib, plotly, altair) and embedding best practices.
- **Visualization Generator**: Creates charts, diagrams, and interactive widgets. Key principle: every visualization should be accompanied by interpretive text.
- **Exercise Generator**: Creates code cells with `# TODO` comments or assertion-based challenges.

**Implementation strategies:**

1. **nbformat direct construction**: For Jupyter notebooks requiring precise metadata control.
2. **jupytext `py:percent` generation**: For easier agent manipulation and version control.
3. **marimo `.py` generation**: For reactive, Git-friendly output with interactive widgets.

**Example pattern for a marimo generator:**

```python
def generate_marimo_notebook(sections: list[dict]) -> str:
    lines = ["import marimo", "", "app = marimo.App()", ""]
    
    for section in sections:
        if section["type"] == "markdown":
            lines.append('@app.cell')
            lines.append('def __():')
            lines.append(f'    return marimo.md("""{section["content"]}""")')
            lines.append('')
        elif section["type"] == "code":
            lines.append('@app.cell')
            lines.append('def __():')
            for line in section["content"].split('\n'):
                lines.append(f'    {line}')
            lines.append('    return ()')
            lines.append('')
    
    return '\n'.join(lines)
```

#### Phase 3: Evaluation

**Objective:** Verify that generated notebooks are correct, runnable, and pedagogically sound.

**Components:**

- **Execution Validator**: Runs every code cell using `nbval`, `pytest-notebook`, or papermill. Must catch:
  - Syntax errors.
  - Missing imports.
  - Runtime exceptions.
  - Infinite loops or excessive execution time.
- **Output Verification**: Compares actual outputs against expected outputs (for deterministic examples). For stochastic examples (e.g., random data), use seeded RNGs and check output types/shapes.
- **Linter Integration**:
  - For Jupyter: `nbconvert` + `ruff` on extracted `.py` files.
  - For Marimo: `marimo check --strict` (catches multiple variable definitions, circular deps) [8].
- **Scientific Accuracy Checker**: Use an LLM with retrieval-augmented generation (RAG) against authoritative sources (textbooks, papers) to verify factual claims in markdown cells.
- **Readability Metrics**: Flesch-Kincaid reading ease, code complexity (cyclomatic), cell length.

**Example evaluation pipeline:**

```python
import subprocess
import nbformat

def evaluate_notebook(path: str) -> dict:
    results = {"passed": False, "errors": []}
    
    # 1. Validation
    try:
        nb = nbformat.read(path, as_version=4)
        nbformat.validate(nb)
    except Exception as e:
        results["errors"].append(f"Validation failed: {e}")
        return results
    
    # 2. Execution
    try:
        subprocess.run(
            ["jupyter", "nbconvert", "--to", "notebook", "--execute", path],
            check=True, capture_output=True, timeout=120
        )
    except subprocess.TimeoutExpired:
        results["errors"].append("Execution timed out")
    except subprocess.CalledProcessError as e:
        results["errors"].append(f"Execution failed: {e.stderr.decode()}")
    
    # 3. Lint (for marimo)
    if path.endswith(".py"):
        lint = subprocess.run(
            ["marimo", "check", "--format=json", path],
            capture_output=True, text=True
        )
        if lint.returncode != 0:
            results["errors"].append(f"Lint issues: {lint.stdout}")
    
    results["passed"] = len(results["errors"]) == 0
    return results
```

#### Phase 4: Iteration

**Objective:** Improve the notebook based on evaluation feedback.

**Components:**

- **Error Classifier**: Parses evaluation output (tracebacks, lint JSON) to categorize issues (import error, variable redefinition, timeout).
- **Repair Agent**: An LLM sub-agent receives the error context and the problematic cell, then proposes a fix.
- **Regression Tester**: After repair, re-runs evaluation to ensure the fix worked and did not break other cells.
- **Human-in-the-loop**: For pedagogical quality ("Is this explanation clear?"), human review may be required. However, automated readability metrics and A/B testing against benchmark notebooks can serve as proxies.

**Self-correction loop pattern:**

```python
max_iterations = 3
for i in range(max_iterations):
    eval_result = evaluate_notebook("generated.ipynb")
    if eval_result["passed"]:
        break
    
    fix_prompt = f"""
    The following notebook failed evaluation:
    Errors: {eval_result['errors']}
    
    Please fix the notebook and return the corrected version.
    """
    notebook = repair_agent.generate(fix_prompt, notebook=notebook)
```

---

## 4. Educational Content Generation by AI Agents

### 4.1 Structuring Learning Materials

The most effective framework for structuring educational content is the **Diátaxis system**, adopted by nbdev and widely used in technical documentation [14]. It classifies content into four forms based on the learner's needs:

| Form | Orientation | Purpose |
|------|-------------|---------|
| **Tutorial** | Learning-oriented | Guides the learner through a hands-on experience. "We are going to build X." |
| **How-to Guide** | Problem-oriented | Provides steps to solve a real-world problem. "How do I do X?" |
| **Explanation** | Understanding-oriented | Deepens conceptual understanding. "Why does X work?" |
| **Reference** | Information-oriented | Provides precise technical details. "What are the parameters of X?" |

For an agentic notebook generator, each section in the outline should be tagged with one of these forms. The agent then selects the appropriate prompt template:

- **Tutorial template**: "Write a step-by-step guide where the learner implements [concept]. Include runnable code after each step. Do not skip steps."
- **Explanation template**: "Explain [concept] using analogies and visual descriptions. Include a mathematical formulation if relevant."
- **How-to template**: "Provide concise, copy-pasteable code to accomplish [task]. Assume the reader knows the basics."
- **Reference template**: "List all parameters, return types, and edge cases for [API/function]."

### 4.2 Insightful vs. Merely Correct Content

AI-generated educational content often suffers from being "correct but shallow." To make it insightful, agents should be prompted to [14]:

1. **Use lots of code examples, pictures, plots, and videos**: Every concept should be demonstrated immediately after introduction.
2. **Keep explanations short, then elaborate in separate cells**: This mirrors nbdev's best practice—short docstrings with executable elaboration.
3. **Document error cases as tests**: Instead of saying "This raises an error," show the failing code with an assertion. This builds debugging intuition.
4. **Add rich representations**: Use `_repr_markdown_`, `_repr_html_`, or interactive widgets to make abstract concepts tangible.
5. **Reference related concepts**: Use doclinks or explicit "See also" sections to build knowledge graphs.
6. **Start with the problem, not the solution**: Tutorials should present a motivating problem before introducing the tool.

### 4.3 Embedding Interactive Visualizations

Interactive visualizations are what distinguish notebooks from static documents. Best practices for agent-generated visualizations include:

- **Library selection**: For static plots, use matplotlib or seaborn. For interactivity, prefer Plotly, Altair, or Bokeh [11]. Marimo's AI rules can be configured to default to specific libraries.
- **Widget integration**: In Jupyter, use `ipywidgets`. In Marimo, use `mo.ui.slider`, `mo.ui.dropdown`, etc., which are reactive by default [7].
- **Progressive disclosure**: Start with a static plot showing the concept, then add an interactive version that lets the learner explore parameters.
- **Annotation**: Every plot must have axis labels, a title, and a caption explaining what to observe.

**Example marimo interactive cell:**

```python
@app.cell
def __(mo):
    amplitude = mo.ui.slider(0.1, 2.0, step=0.1, value=1.0, label="Amplitude")
    frequency = mo.ui.slider(1, 10, step=1, value=2, label="Frequency")
    mo.hstack([amplitude, frequency])
    return amplitude, frequency

@app.cell
def __(amplitude, frequency, np, plt):
    x = np.linspace(0, 2 * np.pi, 500)
    y = amplitude.value * np.sin(frequency.value * x)
    plt.figure(figsize=(8, 4))
    plt.plot(x, y)
    plt.title(f"Sine Wave: A={amplitude.value}, f={frequency.value}")
    plt.xlabel("x")
    plt.ylabel("y")
    plt.grid(True)
    plt.show()
    return
```

---

## 5. Specific Libraries and Tools Summary

### 5.1 Essential Python Libraries

| Library | Purpose | Installation |
|---------|---------|--------------|
| `nbformat` | Read/write `.ipynb` files programmatically | `pip install nbformat` |
| `jupytext` | Convert between `.ipynb`, `.py`, and `.md` | `pip install jupytext` |
| `papermill` | Parameterize and execute notebooks | `pip install papermill` |
| `nbconvert` | Export notebooks to HTML, PDF, etc. | `pip install nbconvert` |
| `marimo` | Reactive pure-Python notebooks | `pip install marimo` |
| `pytest-notebook` | Test notebooks with pytest | `pip install pytest-notebook` |
| `nbval` | Validate notebook outputs | `pip install nbval` |

### 5.2 AI Agent Frameworks

| Framework | Role |
|-----------|------|
| **Jupyter AI** | Native JupyterLab agent for notebook generation and editing |
| **Marimo AI** | Native marimo cell/notebook generation with variable context |
| **CrewAI** | Multi-agent orchestration (planning, research, writing crews) |
| **LangChain / LangGraph** | Chaining LLM calls with tool use (e.g., `nbformat` as a tool) |
| **LiteLLM** | Universal LLM API gateway (used by Jupyter AI) |

### 5.3 Notebook Format Comparison for Agents

| Feature | Jupyter `.ipynb` | Jupytext `.py` | Marimo `.py` |
|---------|------------------|----------------|--------------|
| **Format** | JSON | Python script | Python script |
| **Human-readable** | No | Yes | Yes |
| **Git diff friendly** | No | Yes | Yes |
| **Agent editable** | Hard (JSON) | Easy | Easy |
| **Reactive execution** | No | No | Yes |
| **Interactive widgets** | ipywidgets | N/A (needs conversion) | Native `mo.ui.*` |
| **Direct execution** | Needs Jupyter | Python interpreter | Python interpreter |
| **Linter support** | Indirect | Direct (ruff, mypy) | Direct (`marimo check`) |
| **AI generation support** | Jupyter AI, nbdev | Jupytext + any code agent | `marimo new`, marimo AI |

---

## 6. Recommendations

### 6.1 For Building an Agentic Notebook Generator

1. **Use a multi-phase pipeline**: Planning → Generation → Evaluation → Iteration. Do not attempt to generate a complete notebook in a single LLM call.

2. **Choose the notebook format based on your agent's capabilities**:
   - If your agent excels at manipulating Python code and you need reactive notebooks → **Marimo `.py`**.
   - If you need maximum compatibility with the Jupyter ecosystem → **`nbformat` + `.ipynb`**.
   - If you want the best of both worlds (easy editing + Jupyter execution) → **Jupytext paired `.ipynb` + `.py`**.

3. **Leverage existing AI integrations rather than building from scratch**:
   - Jupyter AI's MCP server and notebook tools allow agents to create and edit `.ipynb` files interactively [17].
   - Marimo's Agent mode and `marimo check` provide a closed loop for generating and validating `.py` notebooks [8][11].

4. **Structure content with Diátaxis**: Tag each generated section as tutorial, how-to, explanation, or reference, and use form-specific prompt templates.

5. **Make evaluation mandatory**: Every generated notebook must pass execution and linting before being delivered. Use `papermill` for parameterized execution, `marimo check` for marimo notebooks, and `nbval` for output verification.

6. **Enable self-correction**: Feed linter and execution errors back to a repair sub-agent. The `marimo check --format=json` output is especially well-suited for this because its error messages are actionable [8].

### 6.2 Example Minimal Agent Architecture

```python
"""
Minimal agentic notebook generator using nbformat + evaluation loop.
"""
import nbformat as nbf
from openai import OpenAI
import subprocess

client = OpenAI()

def plan(topic: str) -> dict:
    """Phase 1: Generate an outline."""
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{
            "role": "system",
            "content": "You are a curriculum designer. Output a JSON outline with sections (type: explanation|tutorial|how-to|reference)."
        }, {
            "role": "user",
            "content": f"Design a lesson on: {topic}"
        }]
    )
    return parse_json(response.choices[0].message.content)

def generate(outline: dict) -> nbf.NotebookNode:
    """Phase 2: Build notebook from outline."""
    nb = nbf.v4.new_notebook()
    nb.metadata.kernelspec = {"display_name": "Python 3", "language": "python", "name": "python3"}
    
    for section in outline["sections"]:
        nb.cells.append(nbf.v4.new_markdown_cell(f"## {section['title']}"))
        
        # Generate prose
        prose = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": f"Write a {section['type']} about {section['title']}. Include a code example."}]
        ).choices[0].message.content
        
        # Split prose from code (simple heuristic)
        if "```python" in prose:
            md_part, code_part = prose.split("```python", 1)
            code_part = code_part.split("```", 1)[0]
            nb.cells.append(nbf.v4.new_markdown_cell(md_part.strip()))
            nb.cells.append(nbf.v4.new_code_cell(code_part.strip()))
        else:
            nb.cells.append(nbf.v4.new_markdown_cell(prose))
    
    return nb

def evaluate(nb: nbf.NotebookNode) -> dict:
    """Phase 3: Execute and validate."""
    nbf.write(nb, "draft.ipynb")
    result = subprocess.run(
        ["jupyter", "nbconvert", "--to", "notebook", "--execute", "draft.ipynb"],
        capture_output=True, text=True, timeout=120
    )
    return {"success": result.returncode == 0, "stderr": result.stderr}

def iterate(nb: nbf.NotebookNode, errors: str) -> nbf.NotebookNode:
    """Phase 4: Fix errors."""
    # In practice, pass errors + notebook to a repair agent
    fixed = client.chat.completions.create(
        model="gpt-4o",
        messages=[{
            "role": "user",
            "content": f"Fix this notebook. Errors: {errors}\nNotebook JSON: {nbf.writes(nb)}"
        }]
    ).choices[0].message.content
    return nbf.reads(fixed, as_version=4)

# Main pipeline
topic = "Gradient Descent"
outline = plan(topic)
nb = generate(outline)

for attempt in range(3):
    eval_result = evaluate(nb)
    if eval_result["success"]:
        nbf.write(nb, "final.ipynb")
        break
    nb = iterate(nb, eval_result["stderr"])
```

---

## 7. Limitations and Caveats

- **Marimo programmatic API is unstable**: Public helpers for creating marimo notebooks programmatically do not yet exist; agents must write raw `@app.cell` Python or use `marimo new` [9].
- **LLM hallucinations in educational content**: While code can be validated by execution, markdown prose may contain subtle factual errors. RAG against authoritative sources is recommended but not foolproof.
- **Execution safety**: Automatically executing AI-generated code is inherently risky. Sandboxing (e.g., Docker, restricted kernel) is essential.
- **Pedagogical quality is hard to automate**: Readability metrics and execution checks verify syntax and runtime, but they cannot fully assess whether an explanation is intuitive. Human review or A/B learner testing remains valuable.
- **Jupyter AI's `/generate` is experimental**: The exact capabilities and constraints of notebook generation via Jupyternaut are still evolving [15].

---

## 8. Bibliography

[1] nbformat Documentation, "Python API for working with notebook files," nbformat.readthedocs.io. https://nbformat.readthedocs.io/en/latest/api.html

[2] Jupyter, "nbformat: Jupyter Notebook Format," GitHub. https://github.com/jupyter/nbformat

[3] PythonTutorials.net, "How to Programmatically Add Cells to Jupyter Notebooks for Automated Report Generation," Nov 29, 2025. https://www.pythontutorials.net/blog/programmatically-add-cells-to-an-ipython-notebook-for-report-generation/

[4] Jupytext Documentation, "Jupytext CLI," jupytext.readthedocs.io. https://jupytext.readthedocs.io/en/latest/using-cli.html

[5] M. Wouts, "Jupytext FAQ," GitHub. https://github.com/mwouts/jupytext/blob/main/docs/faq.md

[6] marimo Documentation, "API Reference," docs.marimo.io. https://docs.marimo.io/api/

[7] I. Eyre, "marimo: A Reactive, Reproducible Notebook," Real Python, May 26, 2025. https://realpython.com/marimo-notebook/

[8] D. Madisetti, "marimo check: a notebook linter for agents and humans," marimo blog, Sep 26, 2025. https://marimo.io/blog/marimo-check

[9] e10v, "Add public API helpers for programmatically creating notebooks," GitHub Issue #4801, marimo-team/marimo, May 4, 2025. https://github.com/marimo-team/marimo/issues/4801

[10] marimo Documentation, "Generate entire notebooks with AI," docs.marimo.io. https://docs.marimo.io/guides/generate_with_ai/text_to_notebook/

[11] marimo Documentation, "AI-assisted coding," docs.marimo.io. https://docs.marimo.io/guides/editor_features/ai_completion/

[12] nteract, "Papermill: Parameterize, execute, and analyze Jupyter Notebooks," GitHub. https://github.com/nteract/papermill

[13] Papermill Documentation, "Parameterize," papermill.readthedocs.io. https://papermill.readthedocs.io/en/latest/usage-parameterize.html

[14] nbdev Documentation, "Notebook Best Practices," nbdev.fast.ai. https://nbdev.fast.ai/tutorials/best_practices.html

[15] K.C. Sabreena Basheer, "Meet Jupyter AI: Unleashing the Power of Artificial Intelligence in Jupyter Notebooks," Analytics Vidhya, Aug 8, 2023. https://www.analyticsvidhya.com/blog/2023/08/meet-jupyter-ai-unleashing-the-power-of-artificial-intelligence-in-jupyter-notebooks/

[16] A. Hoblitzell, "Jupyter AI Brings Generative AI to Notebooks," InfoQ, Aug 15, 2023. https://www.infoq.com/news/2023/08/jupyter-ai-notebooks/

[17] Jupyter AI Documentation, "User Guide," jupyter-ai.readthedocs.io. https://jupyter-ai.readthedocs.io/en/latest/users/index.html

[18] A. Wani, "DecipherIt: Building a NotebookLM-Inspired AI Research Assistant powered by Bright Data," DEV Community, May 25, 2025. https://dev.to/mtwn105/decipherit-building-a-notebooklm-inspired-ai-research-assistant-powered-by-bright-data-ckf

[19] Jupyter AI Documentation, "Jupyternaut (optional)," jupyter-ai.readthedocs.io. https://jupyter-ai.readthedocs.io/en/latest/users/jupyternaut/index.html

[20] marimo Documentation, "Running the marimo backend programmatically," docs.marimo.io. https://docs.marimo.io/guides/deploying/programmatically/

---

## 9. Methodology Appendix

This research was conducted using a combination of direct documentation review, web search, and synthesis of findings from authoritative sources. Search queries included the specific terms requested by the user ("nbformat programmatic notebook generation", "jupytext convert python to jupyter notebook", "marimo create notebook programmatically", "AI agent educational content generation pipeline", "jupyter ai notebook generation", "agentic notebook creation system"), supplemented by targeted fetches of official documentation pages and technical blogs. Sources were evaluated for credibility based on whether they were official project documentation, widely recognized technical publications, or active open-source repositories. The report was structured according to the deep-research methodology, with explicit triangulation of claims across multiple sources where possible.
