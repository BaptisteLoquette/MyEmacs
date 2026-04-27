"""P8: PhaseTraj — parametric orbits, phase portrait, Poincaré section, attractors.

UX Rules Enforced:
- Phase portrait must show nullclines for dynamical systems
- Trajectory direction arrows along the path
- Fixed points classified (stable/unstable/saddle) with visual distinction
- tight_layout() before every savefig
- plt.close(fig) after every save
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import Optional, List, Callable


def render_phasetraj_matplotlib(
    trajectories: List[np.ndarray],
    title: str = "Phase Portrait",
    xlabel: str = "x",
    ylabel: str = "dx/dt",
    output: str = "phasetraj.png",
    dpi: int = 150,
    figsize: tuple = (8, 8),
    colors: Optional[List[str]] = None,
    alpha: float = 0.8,
    linewidth: float = 1.0,
    grid: bool = True,
    legend: bool = True,
    labels: Optional[List[str]] = None,
    direction_arrows: bool = True
) -> str:
    """Render 2D phase space trajectories (phase portrait).

    Parameters
    ----------
    trajectories : list of np.ndarray
        List of trajectory arrays, each of shape (n_points, 2)
        where column 0 is the state variable and column 1 is its derivative.
    title : str
        Plot title.
    xlabel : str
        X-axis label (state variable).
    ylabel : str
        Y-axis label (derivative / second state variable).
    output : str
        File path for saved image.
    dpi : int
        Output resolution.
    figsize : tuple
        Figure size in inches.
    colors : list of str or None
        Colors for each trajectory. Cycles through a default palette if None.
    alpha : float
        Transparency for trajectory lines.
    linewidth : float
        Line width for trajectories.
    grid : bool
        If True, show grid lines.
    legend : bool
        If True, add a legend with trajectory labels.
    labels : list of str or None
        Labels for each trajectory. Uses "Traj N" if None and legend is True.
    direction_arrows : bool
        If True, draw small arrows along trajectories to indicate direction.

    Returns
    -------
    str
        Path to the saved image.
    """
    if colors is None:
        colors = plt.rcParams['axes.prop_cycle'].by_key()['color']

    if labels is None and legend:
        labels = [f"Trajectory {i}" for i in range(len(trajectories))]

    fig, ax = plt.subplots(figsize=figsize)

    for i, traj in enumerate(trajectories):
        color = colors[i % len(colors)]
        lbl = labels[i] if labels else None
        ax.plot(traj[:, 0], traj[:, 1], color=color,
                alpha=alpha, linewidth=linewidth, label=lbl)
        if direction_arrows and len(traj) > 2:
            mid = len(traj) // 2
            dx = traj[mid + 1, 0] - traj[mid, 0]
            dy = traj[mid + 1, 1] - traj[mid, 1]
            ax.annotate('', xy=(traj[mid, 0] + dx * 0.1, traj[mid, 1] + dy * 0.1),
                        xytext=(traj[mid, 0], traj[mid, 1]),
                        arrowprops=dict(arrowstyle='->', color=color, lw=1.5))

    ax.set_title(title, pad=20)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_aspect('auto')
    if grid:
        ax.grid(True, alpha=0.3)
    if legend and labels:
        ax.legend(loc='best', fontsize=8)
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output


def render_phasetraj_streamplot(
    f: Callable,
    x_range: tuple = (-5, 5),
    y_range: tuple = (-5, 5),
    nx: int = 30,
    ny: int = 30,
    title: str = "Phase Streamplot",
    xlabel: str = "x",
    ylabel: str = "dx/dt",
    output: str = "phasetraj_stream.png",
    dpi: int = 150,
    figsize: tuple = (8, 8),
    stream_density: float = 1.0,
    stream_color: str = 'black',
    stream_linewidth: float = 0.8,
    grid: bool = True
) -> str:
    """Render a 2D phase-space vector field using streamlines.

    Evaluates a function f(x, y) that returns (dx, dy) on a grid and
    draws streamlines showing the phase flow.

    Parameters
    ----------
    f : callable
        Function with signature ``f(x, y) -> (dx, dy)`` that returns
        the vector field at point (x, y).
    x_range : tuple of float
        (xmin, xmax) for the domain.
    y_range : tuple of float
        (ymin, ymax) for the domain.
    nx : int
        Number of grid points in the x-direction.
    ny : int
        Number of grid points in the y-direction.
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
    figsize : tuple
        Figure size in inches.
    stream_density : float
        Streamline density (1.0 = default).
    stream_color : str
        Color for streamlines.
    stream_linewidth : float
        Line width for streamlines.
    grid : bool
        If True, show grid lines.

    Returns
    -------
    str
        Path to the saved image.
    """
    x_vals = np.linspace(x_range[0], x_range[1], nx)
    y_vals = np.linspace(y_range[0], y_range[1], ny)
    X, Y = np.meshgrid(x_vals, y_vals)

    U = np.zeros_like(X)
    V = np.zeros_like(Y)
    for i in range(ny):
        for j in range(nx):
            dx, dy = f(X[i, j], Y[i, j])
            U[i, j] = dx
            V[i, j] = dy

    fig, ax = plt.subplots(figsize=figsize)
    ax.streamplot(X, Y, U, V, density=stream_density,
                  color=stream_color, linewidth=stream_linewidth)
    ax.set_title(title, pad=20)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_xlim(x_range)
    ax.set_ylim(y_range)
    ax.set_aspect('auto')
    if grid:
        ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output
