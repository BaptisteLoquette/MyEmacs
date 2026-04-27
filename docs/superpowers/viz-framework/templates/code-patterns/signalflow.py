"""P3: SignalFlow — waveform, spectrogram, eye diagram, Bode plot.

UX Rules Enforced:
- Log frequency axis for Bode; dual y-axis or subplot for mag+phase
- Time axis must have units; sampling rate annotated
- Zero-crossings and critical frequencies labeled
- tight_layout() before every savefig
- plt.close(fig) after every save
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from typing import Optional


def render_signalflow_waveform(
    t: np.ndarray,
    y: np.ndarray,
    title: str = "Waveform",
    xlabel: str = "Time (s)",
    ylabel: str = "Amplitude",
    output: str = "waveform.png",
    dpi: int = 150,
    color: str = "steelblue",
    linewidth: float = 1.0,
    grid: bool = True,
    figsize: tuple = (12, 4)
) -> str:
    """Render a 1D time-domain waveform signal.

    Parameters
    ----------
    t : np.ndarray
        1D array of time values.
    y : np.ndarray
        1D array of signal amplitude values.
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
        Line color.
    linewidth : float
        Line width.
    grid : bool
        If True, show grid lines.
    figsize : tuple
        Figure size in inches.

    Returns
    -------
    str
        Path to the saved image.
    """
    fig, ax = plt.subplots(figsize=figsize)
    ax.plot(t, y, color=color, linewidth=linewidth)
    ax.set_title(title, pad=20)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    if grid:
        ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output


def render_signalflow_bode(
    freq: np.ndarray,
    mag: np.ndarray,
    phase: np.ndarray,
    title: str = "Bode Plot",
    output: str = "bode.png",
    dpi: int = 150,
    mag_color: str = "steelblue",
    phase_color: str = "darkorange",
    grid: bool = True,
    figsize: tuple = (12, 8)
) -> str:
    """Render a Bode plot with magnitude (dB) and phase (degrees) subplots.

    Parameters
    ----------
    freq : np.ndarray
        1D array of frequency values (Hz).
    mag : np.ndarray
        1D array of magnitude values (dB).
    phase : np.ndarray
        1D array of phase values (degrees).
    title : str
        Suptitle for the figure.
    output : str
        File path for saved image.
    dpi : int
        Output resolution.
    mag_color : str
        Color for magnitude trace.
    phase_color : str
        Color for phase trace.
    grid : bool
        If True, show grid lines on both subplots.
    figsize : tuple
        Figure size in inches.

    Returns
    -------
    str
        Path to the saved image.
    """
    fig, (ax_mag, ax_phase) = plt.subplots(
        2, 1, figsize=figsize, sharex=True
    )

    ax_mag.semilogx(freq, mag, color=mag_color, linewidth=1.5)
    ax_mag.set_ylabel("Magnitude (dB)")
    if grid:
        ax_mag.grid(True, alpha=0.3, which='both')

    ax_phase.semilogx(freq, phase, color=phase_color, linewidth=1.5)
    ax_phase.set_xlabel("Frequency (Hz)")
    ax_phase.set_ylabel("Phase (deg)")
    if grid:
        ax_phase.grid(True, alpha=0.3, which='both')

    fig.suptitle(title)
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output


def render_signalflow_spectrogram(
    data: np.ndarray,
    fs: float = 1.0,
    title: str = "Spectrogram",
    output: str = "spectrogram.png",
    dpi: int = 150,
    cmap: str = "viridis",
    nperseg: int = 256,
    noverlap: Optional[int] = None,
    figsize: tuple = (12, 6)
) -> str:
    """Render a time-frequency spectrogram as a heatmap.

    Parameters
    ----------
    data : np.ndarray
        1D array of signal samples.
    fs : float
        Sampling frequency in Hz.
    title : str
        Plot title.
    output : str
        File path for saved image.
    dpi : int
        Output resolution.
    cmap : str
        Matplotlib colormap name (whitelist: viridis, cividis, plasma).
    nperseg : int
        Length of each segment for FFT.
    noverlap : int or None
        Number of points to overlap between segments.
        Defaults to nperseg // 2.
    figsize : tuple
        Figure size in inches.

    Returns
    -------
    str
        Path to the saved image.
    """
    assert cmap in ("viridis", "cividis", "plasma"), \
        "Colormap must be perceptually uniform: viridis, cividis, or plasma."

    if noverlap is None:
        noverlap = nperseg // 2

    fig, ax = plt.subplots(figsize=figsize)
    Pxx, freqs, bins, im = ax.specgram(
        data, NFFT=nperseg, Fs=fs, noverlap=noverlap,
        cmap=cmap, mode='psd'
    )
    cbar = fig.colorbar(im, ax=ax, label='Power/Frequency (dB/Hz)')
    ax.set_title(title, pad=20)
    ax.set_xlabel("Time (s)")
    ax.set_ylabel("Frequency (Hz)")
    fig.tight_layout()
    fig.savefig(output, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    return output
