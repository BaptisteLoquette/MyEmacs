"""P3: SignalFlow — waveform, Bode plots, spectrograms."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def render_signalflow_waveform(t, y, title="Waveform", xlabel="Time",
                                ylabel="Amplitude", output="waveform.png",
                                dpi=150, color='steelblue', linewidth=1.0,
                                grid=True):
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

    Returns
    -------
    str
        Path to the saved image.
    """
    fig, ax = plt.subplots(figsize=(12, 4))
    ax.plot(t, y, color=color, linewidth=linewidth)
    ax.set_title(title)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    if grid:
        ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(output, dpi=dpi)
    plt.close(fig)
    return output


def render_signalflow_bode(freq, mag, phase, title="Bode Plot",
                            output="bode.png", dpi=150,
                            mag_color='steelblue', phase_color='darkorange',
                            grid=True):
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

    Returns
    -------
    str
        Path to the saved image.
    """
    fig, (ax_mag, ax_phase) = plt.subplots(
        2, 1, figsize=(12, 8), sharex=True
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
    fig.savefig(output, dpi=dpi)
    plt.close(fig)
    return output


def render_signalflow_spectrogram(data, fs=1.0, title="Spectrogram",
                                   output="spectrogram.png", dpi=150,
                                   cmap='inferno', nperseg=256,
                                   noverlap=None):
    """Render a time-frequency spectrogram as a heatmap.

    Uses matplotlib's specgram to compute and display the power spectral
    density over time.

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
        Matplotlib colormap name.
    nperseg : int
        Length of each segment for FFT.
    noverlap : int or None
        Number of points to overlap between segments.
        Defaults to nperseg // 2.

    Returns
    -------
    str
        Path to the saved image.
    """
    if noverlap is None:
        noverlap = nperseg // 2

    fig, ax = plt.subplots(figsize=(12, 6))
    Pxx, freqs, bins, im = ax.specgram(
        data, NFFT=nperseg, Fs=fs, noverlap=noverlap,
        cmap=cmap, mode='psd'
    )
    cbar = fig.colorbar(im, ax=ax, label='Power/Frequency (dB/Hz)')
    ax.set_title(title)
    ax.set_xlabel("Time (s)")
    ax.set_ylabel("Frequency (Hz)")
    fig.tight_layout()
    fig.savefig(output, dpi=dpi)
    plt.close(fig)
    return output
