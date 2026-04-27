"""P1: ScalarField — heatmap, contour, isosurface, colormap on geometry.

UX Rules Enforced:
- Colormap: viridis/cividis/plasma only (perceptually uniform, colorblind-safe)
- Colorbar range fixed via explicit vmin/vmax (no auto-rescale per frame)
- Zero-crossings annotated with white dashed contour when physically meaningful
- tight_layout() before every savefig
- plt.close(fig) after every save
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import Optional


def render_scalarfield_matplotlib(
    data: np.ndarray,
    x: Optional[np.ndarray] = None,
    y: Optional[np.ndarray] = None,
    cmap: str = "viridis",
    title: str = "",
    xlabel: str = "",
    ylabel: str = "",
    output: str = "scalarfield.png",
    dpi: int = 150,
    vmin: Optional[float] = None,
    vmax: Optional[float] = None,
    annotate_zero: bool = True,
    colorbar_label: str = "",
    figsize: tuple = (10, 8)
) -> str:
    """Render a 2D scalar field as a heatmap/contour using Matplotlib OO API.

    Parameters
    ----------
    data : np.ndarray
        2D array of scalar values.
    x : np.ndarray or None
        1D array of x-coordinates.
    y : np.ndarray or None
        1D array of y-coordinates.
    cmap : str
        Matplotlib colormap name (whitelist: viridis, cividis, plasma).
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
    vmin : float or None
        Minimum colorbar value.
    vmax : float or None
        Maximum colorbar value.
    annotate_zero : bool
        If True, draw contour at value 0 when data crosses zero.
    colorbar_label : str
        Label for the colorbar.
    figsize : tuple
        Figure size in inches.

    Returns
    -------
    str
        Path to the saved image.
    """
    assert cmap in ("viridis", "cividis", "plasma"), \
        "Colormap must be perceptually uniform: viridis, cividis, or plasma."

    fig, ax = plt.subplots(figsize=figsize)
    x_grid = x if x is not None else np.arange(data.shape[1])
    y_grid = y if y is not None else np.arange(data.shape[0])
    im = ax.pcolormesh(x_grid, y_grid, data, cmap=cmap, shading='auto',
                       vmin=vmin, vmax=vmax)
    if annotate_zero and np.min(data) < 0 < np.max(data):
        ax.contour(x_grid, y_grid, data, levels=[0], colors='white',
                   linewidths=1.5, linestyles='--', alpha=0.8)
    cbar = fig.colorbar(im, ax=ax, label=colorbar_label)
    cbar.mappable.set_clim(vmin, vmax)
    ax.set_title(title, pad=20)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_aspect('equal')
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output


def render_scalarfield_altair(
    data: np.ndarray,
    output: str = "scalarfield.html",
    title: str = "Scalar Field"
) -> str:
    """Render a scalar field as an interactive heatmap using Altair.

    Parameters
    ----------
    data : np.ndarray
        2D array of scalar values.
    output : str
        File path for saved HTML chart.
    title : str
        Chart title.

    Returns
    -------
    str
        Path to the saved HTML file.
    """
    import altair as alt
    import pandas as pd

    df = pd.DataFrame(data)
    df = df.reset_index().melt('index', var_name='x', value_name='value')
    chart = alt.Chart(df).mark_rect().encode(
        x='x:O', y='index:O',
        color=alt.Color('value:Q', scale=alt.Scale(scheme='viridis')),
        tooltip=['x', 'index', 'value']
    ).properties(width=600, height=500, title=title)
    chart.save(output)
    return output
