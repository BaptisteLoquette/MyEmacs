"""P4: Geom3D — surface, volume, mesh, lattice, cross-section.

UX Rules Enforced:
- Camera position must reveal the feature of interest by default
- Mesh resolution balanced — too coarse hides features, too fine kills FPS
- Walls/cross-sections clearly annotated with axis orientation
- tight_layout() or equivalent before save; plt.close(fig) after every save
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import Optional, Tuple


def render_geom3d_matplotlib(
    X: np.ndarray,
    Y: np.ndarray,
    Z: np.ndarray,
    scalars: Optional[np.ndarray] = None,
    cmap: str = "viridis",
    title: str = "",
    xlabel: str = "X",
    ylabel: str = "Y",
    zlabel: str = "Z",
    output: str = "geom3d.png",
    dpi: int = 150,
    vmin: Optional[float] = None,
    vmax: Optional[float] = None,
    figsize: tuple = (10, 8),
    elev: float = 30.0,
    azim: float = -60.0
) -> str:
    """Render a 3D surface using Matplotlib's 3D plotting.

    Parameters
    ----------
    X : np.ndarray
        2D array of x-coordinates.
    Y : np.ndarray
        2D array of y-coordinates.
    Z : np.ndarray
        2D array of z-coordinates (surface height).
    scalars : np.ndarray or None
        Optional scalar field to color the surface. Uses Z if None.
    cmap : str
        Matplotlib colormap name (whitelist: viridis, cividis, plasma).
    title : str
        Plot title.
    xlabel : str
        X-axis label.
    ylabel : str
        Y-axis label.
    zlabel : str
        Z-axis label.
    output : str
        File path for saved image.
    dpi : int
        Output resolution.
    vmin : float or None
        Minimum colorbar value.
    vmax : float or None
        Maximum colorbar value.
    figsize : tuple
        Figure size in inches.
    elev : float
        Elevation angle for the 3D camera.
    azim : float
        Azimuth angle for the 3D camera.

    Returns
    -------
    str
        Path to the saved image.
    """
    assert cmap in ("viridis", "cividis", "plasma"), \
        "Colormap must be perceptually uniform: viridis, cividis, or plasma."

    colors = scalars if scalars is not None else Z

    fig = plt.figure(figsize=figsize)
    ax = fig.add_subplot(111, projection='3d')
    surf = ax.plot_surface(
        X, Y, Z, facecolors=plt.cm.get_cmap(cmap)(
            (colors - (vmin if vmin is not None else np.min(colors))) /
            ((vmax if vmax is not None else np.max(colors)) -
             (vmin if vmin is not None else np.min(colors)))
        ),
        rstride=1, cstride=1, antialiased=True, shade=False
    )
    # Re-normalize for colorbar
    norm = plt.Normalize(vmin=(vmin if vmin is not None else np.min(colors)),
                         vmax=(vmax if vmax is not None else np.max(colors)))
    mappable = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
    mappable.set_array([])
    fig.colorbar(mappable, ax=ax, shrink=0.5, aspect=10)
    ax.set_title(title, pad=20)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_zlabel(zlabel)
    ax.view_init(elev=elev, azim=azim)
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output


def render_geom3d_pyvista(
    mesh,
    scalars: Optional[np.ndarray] = None,
    cmap: str = "viridis",
    title: str = "",
    output: str = "geom3d.png",
    screenshot_size: Tuple[int, int] = (1024, 768),
    off_screen: bool = True,
    show_edges: bool = False,
    camera_position: Optional[list] = None
) -> str:
    """Render a 3D mesh surface using PyVista.

    Parameters
    ----------
    mesh : pyvista.PolyData or pyvista.StructuredGrid or pyvista.UnstructuredGrid
        The PyVista mesh to render.
    scalars : np.ndarray or None
        Scalar values to map onto the mesh surface colors.
    cmap : str
        Matplotlib colormap name (whitelist: viridis, cividis, plasma).
    title : str
        Plot title (rendered as text on the plot).
    output : str
        File path for saved image.
    screenshot_size : tuple of int
        (width, height) of the screenshot in pixels.
    off_screen : bool
        If True, render without a display window.
    show_edges : bool
        If True, show mesh edges.
    camera_position : list or None
        Camera position as [x, y, z] or predefined string like 'xy'.

    Returns
    -------
    str
        Path to the saved image.
    """
    assert cmap in ("viridis", "cividis", "plasma"), \
        "Colormap must be perceptually uniform: viridis, cividis, or plasma."

    import pyvista as pv

    plotter = pv.Plotter(off_screen=off_screen,
                         window_size=screenshot_size)
    plotter.add_mesh(mesh, scalars=scalars, cmap=cmap,
                     show_edges=show_edges, lighting=True)
    if title:
        plotter.add_title(title, font_size=12)
    if camera_position is not None:
        plotter.camera_position = camera_position
    plotter.show(screenshot=output)
    plotter.close()
    return output
