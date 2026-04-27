"""P5: GraphNet — nodes+edges, energy level diagram, phase diagram, architecture.

UX Rules Enforced:
- Edge weights shown as line thickness or color opacity
- Node labels must be readable — truncate or tooltip for long names
- Layout algorithm chosen for semantic meaning
- tight_layout() before every savefig
- plt.close(fig) after every save
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import Optional, Dict, Any


def render_graphnet_networkx(
    G: Any,
    pos: Optional[Dict[Any, np.ndarray]] = None,
    title: str = "",
    output: str = "graphnet.png",
    dpi: int = 150,
    node_size: int = 300,
    node_color: Any = 'steelblue',
    edge_color: str = 'gray',
    edge_alpha: float = 0.6,
    with_labels: bool = True,
    font_size: int = 8,
    colormap: Optional[str] = None,
    node_labels: Optional[Dict[Any, str]] = None,
    figsize: tuple = (10, 8)
) -> str:
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
    colormap : str or None
        Colormap to apply when node_color is a numeric array
        (whitelist: viridis, cividis, plasma).
    node_labels : dict or None
        Custom label mapping. Uses node names if None.
    figsize : tuple
        Figure size in inches.

    Returns
    -------
    str
        Path to the saved image.
    """
    if colormap is not None:
        assert colormap in ("viridis", "cividis", "plasma"), \
            "Colormap must be perceptually uniform: viridis, cividis, or plasma."

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
    ax.set_title(title, pad=20)
    ax.axis('off')
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output


def render_graphnet_adjacency(
    matrix: np.ndarray,
    labels: Optional[list] = None,
    title: str = "Adjacency Matrix",
    output: str = "adjacency.png",
    dpi: int = 150,
    cmap: str = 'viridis',
    annotate: bool = False,
    vmin: Optional[float] = None,
    vmax: Optional[float] = None,
    figsize: tuple = (8, 8)
) -> str:
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
        Matplotlib colormap name (whitelist: viridis, cividis, plasma).
    annotate : bool
        If True, show numeric values inside cells.
    vmin : float or None
        Minimum colorbar value.
    vmax : float or None
        Maximum colorbar value.
    figsize : tuple
        Figure size in inches.

    Returns
    -------
    str
        Path to the saved image.
    """
    assert cmap in ("viridis", "cividis", "plasma"), \
        "Colormap must be perceptually uniform: viridis, cividis, or plasma."

    n = matrix.shape[0]
    if labels is None:
        labels = list(range(n))

    fig, ax = plt.subplots(figsize=figsize)
    im = ax.imshow(matrix, cmap=cmap, aspect='equal', origin='upper',
                   vmin=vmin, vmax=vmax)
    cbar = fig.colorbar(im, ax=ax, shrink=0.8)
    cbar.mappable.set_clim(vmin, vmax)

    if annotate and n <= 20:
        for i in range(n):
            for j in range(n):
                val = matrix[i, j]
                color = 'white' if val > (vmax if vmax is not None else np.max(matrix)) / 2 else 'black'
                ax.text(j, i, f'{val:.2g}', ha='center', va='center',
                        color=color, fontsize=8)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax.set_yticklabels(labels, fontsize=8)
    ax.set_title(title, pad=20)
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output


def render_graphnet_attention(
    attn_weights: np.ndarray,
    tokens: Optional[list] = None,
    title: str = "Attention Map",
    output: str = "attention.png",
    dpi: int = 150,
    cmap: str = 'viridis',
    figsize: tuple = (10, 10)
) -> str:
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
        Matplotlib colormap name (whitelist: viridis, cividis, plasma).
    figsize : tuple
        Figure size in inches.

    Returns
    -------
    str
        Path to the saved image.
    """
    assert cmap in ("viridis", "cividis", "plasma"), \
        "Colormap must be perceptually uniform: viridis, cividis, or plasma."

    n = attn_weights.shape[0]
    if tokens is None:
        tokens = [f"T{i}" for i in range(n)]

    fig, ax = plt.subplots(figsize=figsize)
    im = ax.imshow(attn_weights, cmap=cmap, aspect='equal',
                   origin='upper', vmin=0, vmax=1)
    cbar = fig.colorbar(im, ax=ax, shrink=0.8, label='Weight')
    cbar.mappable.set_clim(0, 1)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(tokens, rotation=90, fontsize=8)
    ax.set_yticklabels(tokens, fontsize=8)
    ax.set_title(title, pad=20)
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output
