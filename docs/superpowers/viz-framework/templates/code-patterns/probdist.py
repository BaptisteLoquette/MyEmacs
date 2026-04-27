"""P7: ProbDist — distribution, density, histogram, box/violin, uncertainty.

UX Rules Enforced:
- Distributions must integrate to 1 — normalize explicitly
- Show both PDF and CDF when physical interpretation needs both
- 3σ or 95% CI bounds annotated when comparing distributions
- tight_layout() before every savefig
- plt.close(fig) after every save
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import Optional, Any


def render_probdist_matplotlib(
    data: np.ndarray,
    bins: Any = 'auto',
    title: str = "Distribution",
    xlabel: str = "Value",
    ylabel: str = "Density",
    output: str = "probdist.png",
    dpi: int = 150,
    color: str = "steelblue",
    kde: bool = True,
    rug: bool = True,
    rug_height: float = 0.02,
    alpha: float = 0.6,
    edgecolor: str = "white",
    figsize: tuple = (10, 6),
    annotate_ci: bool = True
) -> str:
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
    figsize : tuple
        Figure size in inches.
    annotate_ci : bool
        If True, annotate 95% confidence interval bounds.

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
        rug_max = 0.0
        for line in ax.lines:
            rug_max = max(rug_max, np.max(line.get_ydata()))
        if rug_max == 0:
            rug_max = 1.0
        ax.plot(data, np.full_like(data, -rug_height * rug_max),
                '|', color=color, markersize=8, markeredgewidth=1,
                label='Rug')

    if annotate_ci and len(data) > 1:
        lo, hi = np.percentile(data, [2.5, 97.5])
        ax.axvline(lo, color='red', linestyle='--', linewidth=1, alpha=0.7)
        ax.axvline(hi, color='red', linestyle='--', linewidth=1, alpha=0.7)
        ax.text(lo, ax.get_ylim()[1] * 0.9, f'2.5%\n{lo:.2g}',
                color='red', fontsize=8, ha='center')
        ax.text(hi, ax.get_ylim()[1] * 0.9, f'97.5%\n{hi:.2g}',
                color='red', fontsize=8, ha='center')

    ax.set_title(title, pad=20)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.legend()
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output


def render_probdist_altair(
    data: np.ndarray,
    output: str = "probdist.html",
    title: str = "Interactive Distribution"
) -> str:
    """Render an interactive density plot using Altair.

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
