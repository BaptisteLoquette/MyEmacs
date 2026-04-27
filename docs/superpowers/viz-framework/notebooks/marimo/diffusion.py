import marimo as mo
import numpy as np

# Title markdown
mo.md("""# Reactive Diffusion — Denoising Trajectory

This Marimo notebook visualizes a **denoising diffusion trajectory** with reactive parameters.

Adjust the timestep slider to see the marginal distribution morph from noise to data.
""")

# Reactive parameter sliders
timestep = mo.ui.slider(0, 50, value=0, step=1, label="Timestep t")
noise_scale = mo.ui.slider(0.1, 2.0, value=1.0, step=0.1, label="Noise scale")
mo.hstack([timestep, noise_scale])

# Precompute trajectory (non-reactive setup)
@mo.cell
def trajectory_data():
    np.random.seed(42)
    n_samples = 1500
    mix = np.random.choice([0, 1, 2], size=n_samples, p=[0.4, 0.35, 0.25])
    means = [np.array([-1.5, -1.0]), np.array([1.5, 0.5]), np.array([0.0, 1.5])]
    covs = [np.eye(2) * 0.3, np.eye(2) * 0.25, np.eye(2) * 0.2]
    target = np.zeros((n_samples, 2))
    for i in range(n_samples):
        target[i] = np.random.multivariate_normal(means[mix[i]], covs[mix[i]])

    T = 50
    traj = []
    for t in range(T + 1):
        alpha = 1.0 - (t / T) * 0.99
        noise = np.random.randn(*target.shape)
        x_t = np.sqrt(alpha) * target + np.sqrt(1 - alpha) * noise * noise_scale.value
        traj.append(x_t)
    traj = traj[::-1]  # reverse: noise -> data
    return traj

# Reactive plot
@mo.cell
def diffusion_plot(traj=trajectory_data):
    t = timestep.value
    data = traj[t]
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(figsize=(5, 5))
    ax.scatter(data[:, 0], data[:, 1], c="steelblue", s=8, alpha=0.6)
    ax.set_xlim(-4, 4)
    ax.set_ylim(-4, 4)
    ax.set_aspect("equal")
    ax.set_title(f"Denoising Step {t}/50")
    ax.set_xlabel("x")
    ax.set_ylabel("y")
    fig.tight_layout()
    fig.savefig("diffusion_step.png", dpi=150, bbox_inches="tight")
    plt.close(fig)
    return mo.image("diffusion_step.png")

# Reactive statistics
@mo.cell
def diffusion_stats(traj=trajectory_data):
    t = timestep.value
    data = traj[t]
    mean_x = float(np.mean(data[:, 0]))
    mean_y = float(np.mean(data[:, 1]))
    std_x = float(np.std(data[:, 0]))
    std_y = float(np.std(data[:, 1]))
    return mo.md(f"""
    **Statistics at step {t}**
    - Mean = ({mean_x:.2f}, {mean_y:.2f})
    - Std  = ({std_x:.2f}, {std_y:.2f})
    """)

# Footer markdown
mo.md("""## Design Notes

- `trajectory_data` runs once because it does not depend on the timestep slider.
- `diffusion_plot` and `diffusion_stats` re-run on every slider change.
- The `noise_scale` slider triggers a full trajectory recomputation because it is referenced in `trajectory_data`.
""")
