"""Shared dark theme + color palette for Org-babel Python blocks."""

import matplotlib
matplotlib.use('Agg')  # Non-interactive backend for Org

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, Circle, FancyArrowPatch, Arc
import numpy as np
import polars as pl

plt.rcParams.update({
    'figure.facecolor': '#0d1117',
    'axes.facecolor':   '#161b22',
    'axes.edgecolor':   '#30363d',
    'axes.labelcolor':  '#e6edf3',
    'text.color':       '#e6edf3',
    'xtick.color':      '#8b949e',
    'ytick.color':      '#8b949e',
    'grid.color':       '#21262d',
    'grid.linestyle':   '--',
    'grid.linewidth':   0.6,
    'font.family':      'monospace',
    'axes.titlesize':   14,
    'axes.labelsize':   11,
    'figure.dpi':       150,
    'savefig.bbox':     'tight',
    'savefig.facecolor':'#0d1117',
})

COLORS = {
    'bg':        '#0d1117',
    'surface':   '#161b22',
    'text':      '#e6edf3',
    'muted':     '#8b949e',
    'VSS':       '#58a6ff',
    'NMOS':      '#3fb950',
    'PMOS':      '#f78166',
    'wire':      '#c9d1d9',
    'edge':      '#ff7b72',
    'node':      '#d2a8ff',
    'highlight': '#ffa657',
    'success':   '#3fb950',
    'fail':      '#ff7b72',
}

def newfig(w=10, h=5):
    """Create a dark-themed figure and axes."""
    fig, ax = plt.subplots(figsize=(w, h))
    ax.set_facecolor(COLORS['surface'])
    return fig
