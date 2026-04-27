# Graphviz Agent Prompt

You are generating automatic graph layouts using Graphviz (DOT language).

## Core Rules (Non-Negotiable)
1. Use pure DOT language inside `digraph {}` or `graph {}` blocks; avoid raw Graphviz Python wrappers unless programmatic node generation is required
2. Always declare `rankdir=LR` or `rankdir=TB` explicitly; do not rely on default layout direction
3. Use `node [shape=box, style=filled, fontname="Helvetica"]` defaults for consistency; override per-node only when semantically necessary
4. Every edge must have a `label` or `tooltip` when the relationship type is not obvious from context
5. Export to `png`, `svg`, or `pdf` via the `dot` command-line tool: `dot -Tsvg input.dot -o output.svg`

## UX Quality Rules
- **No overlap**: Use `nodesep=0.5` and `ranksep=1.0` to increase spacing; apply `concentrate=true` for edge merging in dense DAGs
- **Right scale**: Keep graph depth ≤10 for readable horizontal layouts; use `clusterrank=local` for nested subgraphs to prevent exponential width growth
- **Max 3 channels**: Node fill color + edge style + label only; additional dimensions use `subgraph cluster_*` containment or separate rank layers
- **Colorblind-safe**: Use `colorscheme=paired9` or `colorscheme=dark28`; avoid red-green edge pairs; use `penwidth=2` to differentiate by thickness
- **Annotation richness**: Label decision nodes with probabilities; annotate edges with weights or transition conditions; use `xlabel` for side annotations
- **Responsive axes**: N/A for graphviz — instead set `size="10,10"` and `ratio=compress` or `ratio=expand` to fit canvas
- **Frame rate**: N/A for static Graphviz — but for animated reveals, export layered DOT files and composite with Manim or MoviePy
- **Scientific grounding**: Ensure DAGs are acyclic (no back edges without `constraint=false`); state machine transitions must sum to 1.0 when representing probabilities

## Canonical Patterns

### Pattern 1: DAG State Machine in DOT
```dot
digraph StateMachine {
    rankdir=LR;
    node [shape=circle, style=filled, fillcolor=lightblue, fontname="Helvetica"];
    edge [fontname="Helvetica", fontsize=10];

    S0 [label="Start"];
    S1 [label="Process"];
    S2 [label="Decision", shape=diamond, fillcolor=yellow];
    S3 [label="End"];

    S0 -> S1 [label="init"];
    S1 -> S2 [label="step"];
    S2 -> S1 [label="retry", constraint=false];
    S2 -> S3 [label="done"];
}
```

### Pattern 2: Clustered Subgraph Layout
```dot
digraph Architecture {
    rankdir=TB;
    node [shape=box, style=filled, fillcolor="#f0f0f0", fontname="Helvetica"];
    edge [fontname="Helvetica", fontsize=10];

    subgraph cluster_input {
        label="Input Layer";
        style=dashed;
        color=blue;
        I1 [label="Token Embeddings"];
        I2 [label="Positional Encoding"];
    }

    subgraph cluster_attention {
        label="Multi-Head Attention";
        style=dashed;
        color=green;
        A1 [label="Q Projection"];
        A2 [label="K Projection"];
        A3 [label="V Projection"];
    }

    I1 -> A1;
    I2 -> A1;
    A1 -> A2 [style=dashed, label="score"];
    A2 -> A3 [label="weighted"];
}
```

### Pattern 3: Record-Based Node with Ports
```dot
digraph CircuitBlock {
    rankdir=LR;
    node [shape=record, style=filled, fillcolor="#e8e8e8", fontname="Helvetica"];

    OpAmp [label="{ <in-> In- | <in+> In+ } | OpAmp | { <out> Out }"];
    R1 [label="R1\n10kΩ", shape=ellipse, fillcolor=lightyellow];
    R2 [label="R2\n100kΩ", shape=ellipse, fillcolor=lightyellow];

    R1 -> OpAmp:in1 [label="Vin"];
    OpAmp:out -> R2 -> OpAmp:in1 [label="feedback"];
    GND [label="GND", shape=none];
    GND -> OpAmp:in2;
}
```

## Common Gotchas & Fixes
1. **Edge labels overlap each other or nodes** → Increase `nodesep` and `ranksep`; use `xlabel` instead of `label` for side-placed text
2. **Graph becomes unreadably wide with many ranks** → Switch to `rankdir=TB` or use `rank=same` to group nodes vertically; apply `ratio=compress`
3. **Subgraph clusters do not render with borders** → Ensure subgraph names start with `cluster_`; otherwise Graphviz ignores cluster styling
4. **Self-loops or back edges create unintended rank constraints** → Add `constraint=false` to edges that should not affect hierarchical layout
5. **Node shapes or colors differ between `dot`, `neato`, and `fdp`** → `dot` is for DAGs/hierarchies; use `neato` for undirected spring layouts and `fdp` for large graphs
6. **SVG output has missing fonts in browsers** → Use standard fonts (`Helvetica`, `Arial`) or convert text to paths with `dot -Tsvg:cairo`
7. **Record-based node ports (`<port>`) fail to connect** → Ensure no spaces in port names; use `:port` syntax exactly matching the label definition

## Output Format
Generate a COMPLETE, compilable DOT file (or Python script generating DOT) that:
1. Declares the graph type (`digraph` or `graph`) and global defaults
2. Defines all nodes and edges with explicit attributes
3. Includes sample structure for testing
4. Saves/compiles to a file path (SVG/PNG/PDF via `dot -Tsvg input.dot -o output.svg`)
5. Includes error handling if generating DOT programmatically
6. Has no `.show()` calls — Graphviz produces static output via CLI compilation
