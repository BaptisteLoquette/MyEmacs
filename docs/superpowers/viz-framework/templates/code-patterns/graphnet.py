"""P5: GraphNet — node-link diagrams, adjacency matrices, attention maps."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def render_graphnet_networkx(G, pos=None, title="", output="graphnet.png",
                              dpi=150, node_size=300, node_color='steelblue',
                              edge_color='gray', edge_alpha=0.6,
                              with_labels=True, font_size=8,
                              colormap=None, node_labels=None,
                              figsize=(10, 8)):
    """Render a node-link diagram using NetworkX and Matplotlib.

    Parameters
    ----------
    G : networkx.Graph
        The graph to visualize.
    pos : dict or None
        Node position dict (e.g. from nx.spring_layout). Computed if None.
    title : str
        Plot title.
    output : str
        File path for saved image.
    dpi : int
        Output resolution.
    node_size : int or list
        Size(s) for nodes.
    node_color : str or list
        Color(s) for nodes.
    edge_color : str
        Color for edges.
    edge_alpha : float
        Transparency for edges (0-1).
    with_labels : bool
        If True, draw node labels.
    font_size : int
        Font size for labels.
    colormap : matplotlib colormap or None
        Colormap to apply when node_color is a numeric array.
    node_labels : dict or None
        Custom label mapping. Uses node names if None.
    figsize : tuple of float
        (width, height) of the figure in inches.

    Returns
    -------
    str
        Path to the saved image.
    """
    import networkx as nx

    if pos is None:
        pos = nx.spring_layout(G, seed=42)

    fig, ax = plt.subplots(figsize=figsize)
    nx.draw_networkx_nodes(G, pos, ax=ax, node_size=node_size,
                           node_color=node_color, cmap=colormap)
    nx.draw_networkx_edges(G, pos, ax=ax, edge_color=edge_color,
                           alpha=edge_alpha)
    if with_labels:
        labels = node_labels if node_labels is not None else {
            n: str(n) for n in G.nodes()
        }
        nx.draw_networkx_labels(G, pos, ax=ax, labels=labels,
                                font_size=font_size)
    ax.set_title(title)
    ax.axis('off')
    fig.tight_layout()
    fig.savefig(output, dpi=dpi)
    plt.close(fig)
    return output


def render_graphnet_adjacency(matrix, labels=None, title="Adjacency Matrix",
                               output="adjacency.png", dpi=150,
                               cmap='Blues', annotate=False,
                               figsize=(8, 8)):
    """Render an adjacency matrix as a heatmap.

    Parameters
    ----------
    matrix : np.ndarray
        Square adjacency matrix (N x N).
    labels : list of str or None
        Tick labels for rows/columns. Uses range(N) if None.
    title : str
        Plot title.
    output : str
        File path for saved image.
    dpi : int
        Output resolution.
    cmap : str
        Matplotlib colormap name.
    annotate : bool
        If True, show numeric values inside cells.
    figsize : tuple of float
        (width, height) in inches.

    Returns
    -------
    str
        Path to the saved image.
    """
    n = matrix.shape[0]
    if labels is None:
        labels = list(range(n))

    fig, ax = plt.subplots(figsize=figsize)
    im = ax.imshow(matrix, cmap=cmap, aspect='equal', origin='upper')
    cbar = fig.colorbar(im, ax=ax, shrink=0.8)

    if annotate and n <= 20:
        for i in range(n):
            for j in range(n):
                val = matrix[i, j]
                color = 'white' if val > np.max(matrix) / 2 else 'black'
                ax.text(j, i, f'{val:.2g}', ha='center', va='center',
                        color=color, fontsize=8)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax.set_yticklabels(labels, fontsize=8)
    ax.set_title(title)
    fig.tight_layout()
    fig.savefig(output, dpi=dpi)
    plt.close(fig)
    return output


def render_graphnet_attention(attn_weights, tokens=None, title="Attention Map",
                               output="attention.png", dpi=150,
                               cmap='OrRd', figsize=(10, 10)):
    """Render an attention weight matrix as a heatmap with token labels.

    Parameters
    ----------
    attn_weights : np.ndarray
        2D array of attention weights (N x N or seq_len x seq_len).
    tokens : list of str or None
        Token labels for both axes. Uses range(N) if None.
    title : str
        Plot title.
    output : str
        File path for saved image.
    dpi : int
        Output resolution.
    cmap : str
        Matplotlib colormap name.
    figsize : tuple of float
        (width, height) in inches.

    Returns
    -------
    str
        Path to the saved image.
    """
    n = attn_weights.shape[0]
    if tokens is None:
        tokens = [f"T{i}" for i in range(n)]

    fig, ax = plt.subplots(figsize=figsize)
    im = ax.imshow(attn_weights, cmap=cmap, aspect='equal',
                   origin='upper', vmin=0, vmax=1)
    cbar = fig.colorbar(im, ax=ax, shrink=0.8, label='Weight')

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(tokens, rotation=90, fontsize=8)
    ax.set_yticklabels(tokens, fontsize=8)
    ax.set_title(title)
    fig.tight_layout()
    fig.savefig(output, dpi=dpi)
    plt.close(fig)
    return output
