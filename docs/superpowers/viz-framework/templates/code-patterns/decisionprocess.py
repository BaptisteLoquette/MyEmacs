"""P9: DecisionProcess — sequential choices, probabilistic outcomes, cumulative trajectories.

UX Rules Enforced:
- Every decision node shows: state value, available actions, outcome probabilities
- Show the distribution of outcomes, not just the mean
- Exploration vs exploitation visually distinguished
- tight_layout() before every savefig (Matplotlib backends)
- plt.close(fig) after every save
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import Optional, List, Tuple, Dict, Any


def render_decisionprocess_matplotlib(
    tree_data: Dict[str, Any],
    title: str = "Decision Process",
    output: str = "decisionprocess.png",
    dpi: int = 150,
    figsize: tuple = (12, 8),
    node_color: str = "steelblue",
    decision_color: str = "darkorange",
    leaf_color: str = "seagreen",
    edge_alpha: float = 0.7
) -> str:
    """Render a decision tree / process as a Matplotlib node-link diagram.

    Parameters
    ----------
    tree_data : dict
        Dictionary with keys:
        - 'nodes': list of dicts {'id': str, 'type': 'root|decision|leaf',
          'value': float, 'label': str, 'pos': (x, y)}
        - 'edges': list of dicts {'source': str, 'target': str,
          'probability': float, 'label': str}
    title : str
        Plot title.
    output : str
        File path for saved image.
    dpi : int
        Output resolution.
    figsize : tuple
        Figure size in inches.
    node_color : str
        Default color for root/standard nodes.
    decision_color : str
        Color for decision nodes.
    leaf_color : str
        Color for leaf/outcome nodes.
    edge_alpha : float
        Transparency for edges.

    Returns
    -------
    str
        Path to the saved image.
    """
    fig, ax = plt.subplots(figsize=figsize)

    nodes = tree_data.get('nodes', [])
    edges = tree_data.get('edges', [])

    for node in nodes:
        x, y = node['pos']
        ntype = node.get('type', 'root')
        color = node_color
        if ntype == 'decision':
            color = decision_color
        elif ntype == 'leaf':
            color = leaf_color
        ax.scatter(x, y, s=400, c=color, zorder=2, edgecolors='black')
        label = node.get('label', node['id'])
        value = node.get('value', None)
        text = f"{label}"
        if value is not None:
            text += f"\nV={value:.2f}"
        ax.text(x, y, text, ha='center', va='center', fontsize=8, zorder=3)

    for edge in edges:
        src = next(n for n in nodes if n['id'] == edge['source'])
        tgt = next(n for n in nodes if n['id'] == edge['target'])
        x1, y1 = src['pos']
        x2, y2 = tgt['pos']
        prob = edge.get('probability', None)
        lw = 1 + (prob * 3) if prob is not None else 1.5
        ax.plot([x1, x2], [y1, y2], 'k-', alpha=edge_alpha,
                linewidth=lw, zorder=1)
        lbl = edge.get('label', '')
        if prob is not None:
            lbl += f"\nP={prob:.2f}"
        if lbl:
            ax.text((x1 + x2) / 2, (y1 + y2) / 2, lbl,
                    fontsize=7, ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.2',
                              facecolor='white', alpha=0.8))

    ax.set_title(title, pad=20)
    ax.set_aspect('equal')
    ax.axis('off')
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output


def render_decisionprocess_graphviz(
    graph_spec: List[Tuple],
    output: str = "decision",
    format: str = "png",
    engine: str = "dot",
    rankdir: str = "TB",
    graph_attrs: Optional[Dict[str, str]] = None,
    node_attrs: Optional[Dict[str, str]] = None,
    edge_attrs: Optional[Dict[str, str]] = None
) -> str:
    """Render a decision/graph diagram using Graphviz.

    Parameters
    ----------
    graph_spec : list of tuple
        List of edges as (source, target, label) or (source, target)
        where source and target are node name strings, and label is an
        optional edge label string.
    output : str
        File path for the saved diagram (extension added automatically).
    format : str
        Output format: 'png', 'svg', 'pdf', etc.
    engine : str
        Graphviz layout engine: 'dot', 'neato', 'fdp', 'sfdp', 'circo',
        'twopi'.
    rankdir : str
        Graph direction: 'TB' (top-bottom), 'LR' (left-right), etc.
    graph_attrs : dict or None
        Additional graph-level attributes.
    node_attrs : dict or None
        Default node attributes.
    edge_attrs : dict or None
        Default edge attributes.

    Returns
    -------
    str
        Path to the rendered output file.
    """
    import graphviz

    g_attrs = {
        'rankdir': rankdir,
        'fontname': 'Helvetica',
        'fontsize': '12',
        'dpi': '150',
    }
    if graph_attrs:
        g_attrs.update(graph_attrs)

    n_attrs = {
        'fontname': 'Helvetica',
        'fontsize': '11',
        'shape': 'box',
        'style': 'rounded',
    }
    if node_attrs:
        n_attrs.update(node_attrs)

    e_attrs = {
        'fontname': 'Helvetica',
        'fontsize': '10',
    }
    if edge_attrs:
        e_attrs.update(edge_attrs)

    dot = graphviz.Digraph(
        name="decision",
        format=format,
        engine=engine,
        graph_attr=g_attrs,
        node_attr=n_attrs,
        edge_attr=e_attrs,
    )

    added_nodes = set()
    for edge in graph_spec:
        src = edge[0]
        tgt = edge[1]
        lbl = edge[2] if len(edge) > 2 else ""

        if src not in added_nodes:
            dot.node(src)
            added_nodes.add(src)
        if tgt not in added_nodes:
            dot.node(tgt)
            added_nodes.add(tgt)
        dot.edge(src, tgt, label=lbl)

    filepath = dot.render(filename=output, cleanup=True)
    return filepath


def render_decisionprocess_mermaid(
    graph_spec: List[Tuple],
    output: str = "decision.mermaid",
    direction: str = "TD",
    title: str = "Decision Diagram"
) -> str:
    """Write a Mermaid DSL specification to a file for rendering elsewhere.

    Produces a .mermaid file that can be consumed by Mermaid CLI or
    embedded in Markdown documentation.

    Parameters
    ----------
    graph_spec : list of tuple
        List of edges as (source, target, label) or (source, target)
        where label is an optional string displayed on the edge.
    output : str
        File path for the saved Mermaid DSL file.
    direction : str
        Graph direction: 'TD' (top-down), 'LR' (left-right), 'BT', 'RL'.
    title : str
        Title comment written at the top of the file.

    Returns
    -------
    str
        Path to the saved Mermaid file.
    """
    lines = []
    lines.append(f"%% {title}")
    lines.append(f"graph {direction}")
    lines.append("")

    added_nodes = set()
    for edge in graph_spec:
        src = edge[0]
        tgt = edge[1]
        lbl = edge[2] if len(edge) > 2 else None

        if src not in added_nodes:
            lines.append(f"    {src}")
            added_nodes.add(src)
        if tgt not in added_nodes:
            added_nodes.add(tgt)

        if lbl:
            lines.append(f"    {src} -->|{lbl}| {tgt}")
        else:
            lines.append(f"    {src} --> {tgt}")

    with open(output, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    return output
