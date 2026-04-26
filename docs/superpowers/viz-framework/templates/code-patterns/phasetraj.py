"""P8: PhaseTraj — phase portraits, streamlines in phase space."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def render_phasetraj_matplotlib(trajectories, title="Phase Portrait",
                                  xlabel="x", ylabel="dx/dt",
                                  output="phasetraj.png", dpi=150,
                                  figsize=(8, 8), colors=None,
                                  alpha=0.8, linewidth=1.0,
                                  grid=True, legend=True,
                                  labels=None):
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
    figsize : tuple of float
        (width, height) in inches.
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

    ax.set_title(title)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_aspect('auto')
    if grid:
        ax.grid(True, alpha=0.3)
    if legend and labels:
        ax.legend(loc='best', fontsize=8)
    fig.tight_layout()
    fig.savefig(output, dpi=dpi)
    plt.close(fig)
    return output


def render_phasetraj_streamplot(f, x_range=(-5, 5), y_range=(-5, 5),
                                 nx=30, ny=30, title="Phase Streamplot",
                                 xlabel="x", ylabel="dx/dt",
                                 output="phasetraj_stream.png",
                                 dpi=150, figsize=(8, 8),
                                 stream_density=1.0,
                                 stream_color='black',
                                 stream_linewidth=0.8,
                                 grid=True):
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
    figsize : tuple of float
        (width, height) in inches.
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
    ax.set_title(title)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_xlim(x_range)
    ax.set_ylim(y_range)
    ax.set_aspect('auto')
    if grid:
        ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(output, dpi=dpi)
    plt.close(fig)
    return output
