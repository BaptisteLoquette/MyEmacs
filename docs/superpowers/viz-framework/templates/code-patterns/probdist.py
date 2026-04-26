"""P7: ProbDist — histogram, KDE, rug plot, interactive density."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def render_probdist_matplotlib(data, bins='auto', title="Distribution",
                                xlabel="Value", ylabel="Density",
                                output="probdist.png", dpi=150,
                                color='steelblue', kde=True,
                                rug=True, rug_height=0.02,
                                alpha=0.6, edgecolor='white',
                                figsize=(10, 6)):
    """Render a combined histogram + KDE + rug plot for a 1D dataset.

    Parameters
    ----------
    data : np.ndarray or list
        1D array of numeric values.
    bins : int or str
        Number of bins or binning strategy for the histogram.
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
    color : str
        Base color for histogram and KDE.
    kde : bool
        If True, overlay a kernel density estimate.
    rug : bool
        If True, draw rug ticks along the x-axis.
    rug_height : float
        Height of rug ticks as fraction of the y-axis range.
    alpha : float
        Transparency for the histogram bars.
    edgecolor : str
        Edge color for histogram bars.
    figsize : tuple of float
        (width, height) in inches.

    Returns
    -------
    str
        Path to the saved image.
    """
    from scipy.stats import gaussian_kde

    fig, ax = plt.subplots(figsize=figsize)

    ax.hist(data, bins=bins, density=True, alpha=alpha,
            color=color, edgecolor=edgecolor, label='Histogram')

    if kde and len(data) > 1:
        kde_fn = gaussian_kde(data)
        x_range = np.linspace(np.min(data), np.max(data), 500)
        ax.plot(x_range, kde_fn(x_range), color=color,
                linewidth=2, label='KDE')

    if rug:
        rug_max = 0
        for line in ax.lines:
            rug_max = max(rug_max, np.max(line.get_ydata()))
        if rug_max == 0:
            rug_max = 1.0
        ax.plot(data, np.full_like(data, -rug_height * rug_max),
                '|', color=color, markersize=8, markeredgewidth=1,
                label='Rug')

    ax.set_title(title)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.legend()
    fig.tight_layout()
    fig.savefig(output, dpi=dpi)
    plt.close(fig)
    return output


def render_probdist_altair(data, output="probdist.html",
                            title="Interactive Distribution"):
    """Render an interactive density plot using Altair.

    Creates a self-contained HTML file with an interactive histogram
    and density estimate.

    Parameters
    ----------
    data : np.ndarray or list
        1D array of numeric values.
    output : str
        File path for saved HTML.
    title : str
        Chart title.

    Returns
    -------
    str
        Path to the saved HTML file.
    """
    import altair as alt
    import pandas as pd

    df = pd.DataFrame({'value': np.asarray(data).ravel()})

    hist = alt.Chart(df).mark_bar(opacity=0.6).encode(
        alt.X('value:Q', bin=alt.Bin(maxbins=50), title='Value'),
        alt.Y('count()', title='Count'),
        tooltip=['count()']
    )

    density = alt.Chart(df).transform_density(
        'value', as_=['value', 'density']
    ).mark_line(color='darkred', strokeWidth=2).encode(
        x='value:Q',
        y='density:Q',
        tooltip=['value:Q', 'density:Q']
    )

    chart = (hist + density).properties(
        width=600, height=400, title=title
    ).interactive()
    chart.save(output)
    return output
