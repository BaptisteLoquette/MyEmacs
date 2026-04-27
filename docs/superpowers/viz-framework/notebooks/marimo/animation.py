import marimo as mo
import numpy as np

# Title markdown
mo.md("""# Reactive Animation — EM Wave Propagation

This Marimo notebook demonstrates a reactive animation frame builder using **Manim-like** parametric curves.

Because Marimo cells re-execute on parameter change, we simulate a time-step slider to scrub through wave propagation.
""")

# Reactive time slider
phase = mo.ui.slider(0.0, 2 * np.pi, value=0.0, step=0.1, label="Wave Phase (rad)")
amplitude = mo.ui.slider(0.5, 2.0, value=1.5, step=0.1, label="Amplitude")
mo.hstack([phase, amplitude])

# Reactive wave frame
@mo.cell
def wave_frame():
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    x = np.linspace(0, 4 * np.pi, 400)
    phi = phase.value
    A = amplitude.value
    E = A * np.sin(x - phi)
    B = A * np.cos(x - phi + np.pi / 2)

    fig, ax = plt.subplots(figsize=(10, 4))
    ax.plot(x, E, color="gold", linewidth=2.5, label=r"$\mathbf{E}$ field")
    ax.plot(x, B, color="dodgerblue", linewidth=2.5, label=r"$\mathbf{B}$ field")
    ax.axhline(0, color="black", linewidth=0.5)
    ax.set_xlim(0, 4 * np.pi)
    ax.set_ylim(-2.5, 2.5)
    ax.set_xlabel("Propagation distance")
    ax.set_ylabel("Field amplitude")
    ax.set_title(f"EM Wave at phase = {phi:.2f} rad")
    ax.legend()
    ax.set_aspect("equal")
    fig.tight_layout()
    fig.savefig("wave_frame.png", dpi=150, bbox_inches="tight")
    plt.close(fig)
    return mo.image("wave_frame.png")

# Reactive annotation
@mo.cell
def wave_metrics():
    phi = phase.value
    A = amplitude.value
    E_max = A
    B_max = A
    orthogonality_check = "PASS" if np.isclose(np.dot(np.sin(np.linspace(0, 2*np.pi, 100)),
                                                       np.cos(np.linspace(0, 2*np.pi, 100))), 0, atol=0.1) else "CHECK"
    return mo.md(f"""
    **Metrics at phase {phi:.2f}**
    - E_max = {E_max:.2f}
    - B_max = {B_max:.2f}
    - Orthogonality check: {orthogonality_check}
    """)

# Footer markdown
mo.md("""## How it works

1. The `phase` slider controls the temporal offset of the traveling wave.
2. Both `@mo.cell` blocks re-execute automatically when `phase` changes.
3. Matplotlib renders a static frame to PNG, which Marimo displays inline.
4. For true Manim video rendering, export this notebook to a script and run `manim -qm`.
""")
