"""P4: Geom3D — 3D surface rendering, mesh examples."""

import matplotlib
matplotlib.use('Agg')
import numpy as np


def render_geom3d_pyvista(mesh, scalars=None, cmap="viridis",
                            title="", output="geom3d.png",
                            screenshot_size=(1024, 768),
                            off_screen=True, show_edges=False,
                            camera_position=None):
    """Render a 3D mesh surface using PyVista.

    Parameters
    ----------
    mesh : pyvista.PolyData or pyvista.StructuredGrid or pyvista.UnstructuredGrid
        The PyVista mesh to render.
    scalars : np.ndarray or None
        Scalar values to map onto the mesh surface colors.
    cmap : str
        Matplotlib colormap name for scalar coloring.
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


def render_geom3d_examples(output_dir=".", screenshot_size=(1024, 768)):
    """Generate and render example 3D meshes: sphere, torus, and custom grid.

    Creates three PyVista mesh objects, renders each to a PNG file,
    and returns a dict mapping mesh names to output file paths.

    Parameters
    ----------
    output_dir : str
        Directory in which to save the example images.
    screenshot_size : tuple of int
        (width, height) for each screenshot.

    Returns
    -------
    dict
        Mapping of mesh name to saved file path.
    """
    import pyvista as pv
    import os

    results = {}

    sphere = pv.Sphere(radius=1.0)
    sphere_path = os.path.join(output_dir, "geom3d_sphere.png")
    render_geom3d_pyvista(sphere, title="Sphere",
                          output=sphere_path,
                          screenshot_size=screenshot_size,
                          show_edges=True)
    results['sphere'] = sphere_path

    torus = pv.Torus()
    torus['scalars'] = torus.points[:, 0]
    torus_path = os.path.join(output_dir, "geom3d_torus.png")
    render_geom3d_pyvista(torus, scalars='scalars', cmap='coolwarm',
                          title="Torus (colored by x)",
                          output=torus_path,
                          screenshot_size=screenshot_size)
    results['torus'] = torus_path

    x = np.linspace(-2, 2, 50)
    y = np.linspace(-2, 2, 50)
    xx, yy = np.meshgrid(x, y)
    zz = np.sin(np.sqrt(xx**2 + yy**2))
    grid = pv.StructuredGrid(xx, yy, zz)
    grid_path = os.path.join(output_dir, "geom3d_grid.png")
    render_geom3d_pyvista(grid, scalars=zz.ravel(order='F'),
                          cmap='plasma',
                          title="Custom Grid: z = sin(r)",
                          output=grid_path,
                          screenshot_size=screenshot_size)
    results['grid'] = grid_path

    return results
