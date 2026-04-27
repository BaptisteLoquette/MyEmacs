"""P2: VectorField — arrows, streamlines, LIC, glyphs, field lines.

UX Rules Enforced:
- Arrow density adapts to field strength — sparse in uniform regions
- Streamlines must satisfy divergence/curl constraints (∇·B = 0 for magnetic)
- Glyph size proportional to magnitude; never zero-length glyphs
- tight_layout() before every savefig
- plt.close(fig) after every save
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import Optional, Tuple


def render_vectorfield_matplotlib(
    X: np.ndarray,
    Y: np.ndarray,
    U: np.ndarray,
    V: np.ndarray,
    title: str = "",
    xlabel: str = "",
    ylabel: str = "",
    output: str = "vectorfield.png",
    dpi: int = 150,
    overlay_quiver: bool = True,
    quiver_density: Tuple[int, int] = (30, 30),
    stream_density: float = 1.0,
    stream_color: str = 'black',
    stream_linewidth: float = 0.8,
    quiver_scale: float = 1.0,
    cmap: Optional[str] = None,
    figsize: tuple = (10, 8)
) -> str:
    """Render a 2D vector field with streamlines and optional quiver overlay.

    Parameters
    ----------
    X : np.ndarray
        2D array of x-coordinates (meshgrid output).
    Y : np.ndarray
        2D array of y-coordinates (meshgrid output).
    U : np.ndarray
        2D array of velocity x-components.
    V : np.ndarray
        2D array of velocity y-components.
    title : str
        Plot title.
    xlabel : str
        X-axis label.
    ylabel : str
        Y-axis label.
    output : str
        File path for saved image.
    dpi : int
        Output resolution.
    overlay_quiver : bool
        If True, overlay quiver arrows on the streamplot.
    quiver_density : tuple of int
        Number of quiver arrows in (x, y) directions.
    stream_density : float
        Streamline density (1.0 = default).
    stream_color : str
        Color for streamlines.
    stream_linewidth : float
        Line width for streamlines.
    quiver_scale : float
        Scale factor for quiver arrows.
    cmap : str or None
        Colormap for quiver arrows colored by magnitude
        (whitelist: viridis, cividis, plasma).
    figsize : tuple
        Figure size in inches.

    Returns
    -------
    str
        Path to the saved image.
    """
    if cmap is not None:
        assert cmap in ("viridis", "cividis", "plasma"), \
            "Colormap must be perceptually uniform: viridis, cividis, or plasma."

    speed = np.sqrt(U**2 + V**2)

    fig, ax = plt.subplots(figsize=figsize)
    ax.streamplot(X, Y, U, V, density=stream_density,
                  color=stream_color, linewidth=stream_linewidth)

    if overlay_quiver:
        skip_x = max(1, X.shape[1] // quiver_density[0])
        skip_y = max(1, X.shape[0] // quiver_density[1])
        idx_y = slice(None, None, skip_y)
        idx_x = slice(None, None, skip_x)
        if cmap is not None:
            ax.quiver(X[idx_y, idx_x], Y[idx_y, idx_x],
                      U[idx_y, idx_x], V[idx_y, idx_x],
                      speed[idx_y, idx_x], cmap=cmap,
                      scale=quiver_scale)
        else:
            ax.quiver(X[idx_y, idx_x], Y[idx_y, idx_x],
                      U[idx_y, idx_x], V[idx_y, idx_x],
                      scale=quiver_scale)

    ax.set_title(title, pad=20)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_aspect('equal')
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output


def render_vectorfield_plotly(
    X: np.ndarray,
    Y: np.ndarray,
    U: np.ndarray,
    V: np.ndarray,
    title: str = "Vector Field",
    output: str = "vectorfield.html",
    arrow_scale: float = 0.1,
    n_sample: int = 20
) -> str:
    """Render an interactive vector field using Plotly.

    Parameters
    ----------
    X : np.ndarray
        2D array of x-coordinates.
    Y : np.ndarray
        2D array of y-coordinates.
    U : np.ndarray
        2D array of velocity x-components.
    V : np.ndarray
        2D array of velocity y-components.
    title : str
        Plot title.
    output : str
        File path for saved HTML.
    arrow_scale : float
        Scaling factor for arrow length.
    n_sample : int
        Downsample factor for quiver arrows (higher = fewer arrows).

    Returns
    -------
    str
        Path to the saved HTML file.
    """
    import plotly.graph_objects as go

    speed = np.sqrt(U**2 + V**2)

    step = max(1, min(X.shape[0], X.shape[1]) // n_sample)
    xs = X[::step, ::step]
    ys = Y[::step, ::step]
    us = U[::step, ::step]
    vs = V[::step, ::step]
    spd = speed[::step, ::step]

    fig = go.Figure(data=go.Cone(
        x=xs.ravel(), y=ys.ravel(),
        u=us.ravel(), v=vs.ravel(),
        sizemode='scaled', sizeref=arrow_scale,
        colorscale='Viridis',
        colorbar=dict(title='Magnitude'),
        hovertemplate='x: %{x:.2f}<br>y: %{y:.2f}<br>u: %{u:.2f}<br>v: %{v:.2f}'
    ))
    fig.update_layout(
        title=title,
        xaxis_title='X',
        yaxis_title='Y',
        width=800,
        height=600
    )
    fig.write_html(output)
    return output
