import marimo as mo
import numpy as np

# Title markdown
mo.md("""# Reactive By-Hand — Computation Trace

This Marimo notebook draws a **neural network forward-pass trace** with reactive dimension parameters.

Adjust the input and hidden dimensions to see how tensor shapes propagate through the graph.
""")

# Reactive parameter sliders
n_in = mo.ui.slider(2, 32, value=4, step=1, label="Input dim n")
m_hidden = mo.ui.slider(2, 64, value=8, step=1, label="Hidden dim m")
show_bias = mo.ui.checkbox(value=True, label="Show bias node")
mo.hstack([n_in, m_hidden, show_bias])

# Reactive trace drawing
@mo.cell
def trace_diagram():
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

    n = n_in.value
    m = m_hidden.value

    fig, ax = plt.subplots(figsize=(12, 5))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 5)
    ax.axis("off")

    def draw_box(ax, x, y, w, h, text, color="lightblue", fontsize=10):
        box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.05",
                             facecolor=color, edgecolor="black", linewidth=1.5)
        ax.add_patch(box)
        ax.text(x + w/2, y + h/2, text, ha="center", va="center", fontsize=fontsize, weight="bold")

    def draw_arrow(ax, start, end, text=""):
        arrow = FancyArrowPatch(start, end, arrowstyle="->", mutation_scale=20,
                                linewidth=2, color="darkslategray")
        ax.add_patch(arrow)
        if text:
            mx = (start[0] + end[0]) / 2
            my = (start[1] + end[1]) / 2 + 0.15
            ax.text(mx, my, text, ha="center", va="bottom", fontsize=9, style="italic", color="darkgreen")

    draw_box(ax, 0.5, 2.2, 1.5, 1.0, rf"$\mathbf{{x}} \in \mathbb{{R}}^{{{n}}}$", "lightyellow")
    draw_box(ax, 3.0, 2.2, 1.8, 1.0, rf"$\mathbf{{W}} \in \mathbb{{R}}^{{{m} \times {n}}}$", "lightyellow")
    draw_box(ax, 5.5, 2.2, 1.8, 1.0, rf"$\mathbf{{z}} \in \mathbb{{R}}^{{{m}}}$", "lightgreen")
    draw_box(ax, 10.0, 2.2, 1.5, 1.0, r"$\sigma(\mathbf{z})$", "salmon")

    draw_arrow(ax, (2.0, 2.7), (3.0, 2.7), "matmul")
    draw_arrow(ax, (4.8, 2.7), (5.5, 2.7))
    draw_arrow(ax, (7.3, 2.7), (8.0, 2.7))
    draw_arrow(ax, (9.5, 2.7), (10.0, 2.7), "ReLU")

    if show_bias.value:
        draw_box(ax, 8.0, 2.2, 1.5, 1.0, rf"$\mathbf{{b}} \in \mathbb{{R}}^{{{m}}}$", "lightyellow")
        draw_arrow(ax, (8.75, 2.2), (8.75, 1.8), "broadcast")
        draw_arrow(ax, (8.0, 1.8), (6.4, 2.2), "add")
    else:
        ax.annotate("Bias disabled", xy=(8.5, 2.7), fontsize=10, color="gray", style="italic")

    ax.set_title(f"Computation Trace — n={n}, m={m}")
    fig.tight_layout()
    fig.savefig("trace_reactive.png", dpi=150, bbox_inches="tight")
    plt.close(fig)
    return mo.image("trace_reactive.png")

# Reactive shape table
@mo.cell
def shape_table():
    n = n_in.value
    m = m_hidden.value
    rows = [
        ["Input", f"ℝ^{n}", f"{n} scalar values"],
        ["Weight", f"ℝ^{m}×{n}", f"{m*n} parameters"],
        ["Pre-activation", f"ℝ^{m}", f"{m} scalar values"],
        ["Bias", f"ℝ^{m}" if show_bias.value else "—", f"{m} parameters" if show_bias.value else "—"],
        ["Output", f"ℝ^{m}", f"{m} scalar values"],
    ]
    table_md = "| Tensor | Shape | Size |\n|---|---|---|\n"
    for r in rows:
        table_md += f"| {r[0]} | {r[1]} | {r[2]} |\n"
    return mo.md(table_md)

# Footer markdown
mo.md("""## Notes

- `trace_diagram` re-renders the PNG whenever `n`, `m`, or `show_bias` changes.
- `shape_table` updates the markdown table with exact parameter counts.
- This is the **by-hand** pattern: explicit shapes, explicit operations, no black boxes.
""")
