import marimo as mo
import schemdraw
import schemdraw.elements as elm
import plotly.express as px
import numpy as np
import pandas as pd

# Title markdown
mo.md("""# Reactive Circuit — Differential Pair

This Marimo notebook uses **Schemdraw** for schematic generation and **Plotly** for interactive MOSFET I-V curves.

Adjust the slider below to change transistor width and observe the effect on drive strength.
""")

# Reactive parameter slider
width = mo.ui.slider(1, 20, value=5, label="Transistor Width W (µm)")
length = mo.ui.slider(0.18, 2.0, value=0.5, step=0.18, label="Transistor Length L (µm)")
mo.hstack([width, length])

# Reactive schematic generation
@mo.cell
def schematic():
    fname = "diffpair_marimo.svg"
    with schemdraw.Drawing(file=fname) as d:
        d.config(unit=0.5)
        elm.Ground().at((0, 0))
        elm.SourceI().up().at((0, 0)).label("$I_{tail}$")
        elm.Line().right().at((0, 2)).length(1)
        elm.Line().up().at((-1, 2)).length(1)
        elm.Line().up().at((1, 2)).length(1)
        elm.BjtNpn(circle=True).right().at((-1, 3)).label("$Q_1$")
        elm.BjtNpn(circle=True).right().at((1, 3)).label("$Q_2$")
        elm.Line().up().at((-1, 4.5)).length(1)
        elm.Line().up().at((1, 4.5)).length(1)
        elm.Resistor().right().at((-1, 5.5)).label("$R_D$")
        elm.Resistor().right().at((1, 5.5)).label("$R_D$")
        elm.Line().right().at((0, 2)).length(2)
        elm.Ground().at((2, 0))
    return mo.md(f"**Schematic** (W={width.value}µm, L={length.value}µm)") if not fname else mo.image(fname)

# Reactive I-V plot
@mo.cell
def iv_curve():
    W = width.value
    L = length.value
    Vds = np.linspace(0, 3, 200)
    Vth = 0.4
    muCox = 200e-6
    data = []
    for Vgs in np.linspace(0.6, 1.8, 5):
        Ids = np.where(
            Vds < Vgs - Vth,
            muCox * (W / L) * ((Vgs - Vth) * Vds - 0.5 * Vds**2),
            0.5 * muCox * (W / L) * (Vgs - Vth)**2
        )
        for v, i_val in zip(Vds, Ids):
            data.append({"Vds (V)": v, "Ids (A)": i_val, "Vgs": f"{Vgs:.2f}V"})
    df = pd.DataFrame(data)
    fig = px.line(
        df, x="Vds (V)", y="Ids (A)", color="Vgs",
        title=f"MOSFET I-V (W={W}µm, L={L}µm)",
        template="plotly_white"
    )
    fig.update_layout(hovermode="x unified")
    return mo.ui.plotly(fig)

# Footer markdown
mo.md("""## Notes

- **Schemdraw** renders a vector SVG schematic that updates reactively.
- **Plotly** provides zoom, pan, and hover tooltips on the I-V curves.
- Changing W or L triggers re-execution of both `@mo.cell` functions.
""")
