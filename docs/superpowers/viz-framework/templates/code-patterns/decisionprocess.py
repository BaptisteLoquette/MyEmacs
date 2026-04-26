"""P9: DecisionProcess — Graphviz diagrams, Mermaid DSL."""

import matplotlib
matplotlib.use('Agg')


def render_decision_graphviz(graph_spec, output="decision", format="png",
                               engine="dot", rankdir="TB",
                               graph_attrs=None, node_attrs=None,
                               edge_attrs=None):
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


def render_decision_mermaid(graph_spec, output="decision.mermaid",
                              direction="TD", title="Decision Diagram"):
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
