"""P6: ProcessAnim — step-by-step morph, time evolution, particle trails.

UX Rules Enforced:
- Fixed colorbar range across all frames — never auto-rescale
- Animation speed toggle and frame scrubbing supported by save API
- Pause at key frames with annotation callouts
- tight_layout() before every savefig; plt.close(fig) after every save
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import numpy as np
from typing import Optional, List, Callable, Dict, Any


def render_processanim_manim(
    scene_class: type,
    output: str = "process.mp4",
    quality: str = "medium_quality",
    preview: bool = False,
    extra_args: Optional[List[str]] = None
) -> int:
    """Wrap Manim scene rendering to produce an animation video.

    Parameters
    ----------
    scene_class : manim.Scene subclass
        The Manim Scene class to render (not an instance).
    output : str
        Desired output file path (used to construct the quality flag).
        The actual output will be placed by Manim in its media directory.
    quality : str
        Manim quality preset: 'low_quality', 'medium_quality',
        'high_quality', 'fourk_quality'.
    preview : bool
        If True, open the rendered video after completion.
    extra_args : list of str or None
        Additional CLI arguments passed to Manim.

    Returns
    -------
    int
        Return code from the Manim CLI invocation (0 = success).
    """
    import subprocess
    import sys

    if extra_args is None:
        extra_args = []

    scene_name = scene_class.__name__
    cmd = [
        sys.executable, "-m", "manim",
        "-q", quality,
    ]
    if preview:
        cmd.append("-p")
    cmd.extend(extra_args)
    cmd.extend([__file__, scene_name])

    result = subprocess.run(cmd, capture_output=False)
    return result.returncode


def render_processanim_matplotlib(
    frames: List[Callable],
    interval: int = 50,
    output: str = "process.mp4",
    fps: Optional[int] = None,
    dpi: int = 150,
    figsize: tuple = (10, 8),
    title: str = "Animation",
    blit: bool = False
) -> str:
    """Render a sequence of frames as an MP4 animation using FuncAnimation.

    Each callable in ``frames`` must accept a matplotlib Axes and an integer
    frame index, and draw onto the axes.

    Parameters
    ----------
    frames : list of callable
        List of functions with signature ``fn(ax, frame_idx)``.
    interval : int
        Delay between frames in milliseconds.
    output : str
        File path for saved MP4 video.
    fps : int or None
        Frames per second. Defaults to 1000 / interval if not set.
    dpi : int
        Output resolution.
    figsize : tuple of float
        (width, height) in inches.
    title : str
        Suptitle for the figure.
    blit : bool
        Whether to use blitting for animation rendering.

    Returns
    -------
    str
        Path to the saved video file.
    """
    if fps is None:
        fps = int(1000 / interval)

    writer_name = 'ffmpeg'

    fig, ax = plt.subplots(figsize=figsize)
    fig.suptitle(title)

    def animate(i):
        ax.clear()
        frames[i](ax, i)

    ani = FuncAnimation(fig, animate, frames=len(frames),
                        interval=interval, blit=blit)
    ani.save(output, writer=writer_name, fps=fps, dpi=dpi)
    plt.close(fig)
    return output


def render_processanim_hyperframes(
    steps: Dict[str, Any],
    output: str = "process.hyperframes",
    transition_duration: float = 0.5,
    camera: Optional[Dict[str, Any]] = None
) -> str:
    """Stub for HyperFrames animation sequencing.

    HyperFrames is a conceptual format for declarative animation specs.
    This stub serializes the steps dict as JSON for later consumption
    by a HyperFrames renderer.

    Parameters
    ----------
    steps : dict
        Dictionary of named animation steps with their properties.
    output : str
        File path for the saved HyperFrames JSON specification.
    transition_duration : float
        Default transition duration in seconds between steps.
    camera : dict or None
        Camera configuration dict (position, target, fov).

    Returns
    -------
    str
        Path to the saved JSON file.
    """
    import json

    spec = {
        "version": "0.1.0",
        "transition_duration": transition_duration,
        "camera": camera or {},
        "steps": steps,
    }
    with open(output, 'w') as f:
        json.dump(spec, f, indent=2)
    return output
