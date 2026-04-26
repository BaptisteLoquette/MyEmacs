"""P1: ScalarField — heatmap, contour, isosurface, colormap on geometry."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def render_scalarfield_matplotlib(data, x=None, y=None, cmap="viridis",
                                   title="", xlabel="", ylabel="",
                                   output="scalarfield.png", dpi=150,
                                   vmin=None, vmax=None,
                                   annotate_zero=True,
                                   colorbar_label=""):
    """Render a scalar field as a heatmap/contour using Matplotlib OO API.

    Parameters
    ----------
    data : np.ndarray
        2D array of scalar values.
    x : np.ndarray or None
        1D array of x-coordinates.
    y : np.ndarray or None
        1D array of y-coordinates.
    cmap : str
        Matplotlib colormap name.
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

    Returns
    -------
    str
        Path to the saved image.
    """
    fig, ax = plt.subplots(figsize=(10, 8))
    if x is None:
        x = np.arange(data.shape[1])
    if y is None:
        y = np.arange(data.shape[0])
    im = ax.pcolormesh(x, y, data, cmap=cmap, shading='auto',
                        vmin=vmin, vmax=vmax)
    if annotate_zero and np.min(data) < 0 < np.max(data):
        ax.contour(x, y, data, levels=[0], colors='white',
                    linewidths=1.5, linestyles='--')
    cbar = fig.colorbar(im, ax=ax, label=colorbar_label)
    ax.set_title(title)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_aspect('equal')
    fig.tight_layout()
    fig.savefig(output, dpi=dpi)
    plt.close(fig)
    return output


def render_scalarfield_altair(data, output="scalarfield.html"):
    """Render a scalar field as an interactive heatmap using Altair.

    Parameters
    ----------
    data : np.ndarray
        2D array of scalar values.
    output : str
        File path for saved HTML chart.

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
        x='x:O', y='index:O', color='value:Q',
        tooltip=['x', 'index', 'value']
    ).properties(width=600, height=500, title='Scalar Field')
    chart.save(output)
    return output
