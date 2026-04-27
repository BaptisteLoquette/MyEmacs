import marimo as mo
import numpy as np

# Title markdown
mo.md("""# Reactive Embedding — UMAP 3D Scatter

This Marimo notebook performs **UMAP** dimensionality reduction reactively.

Adjust the number of neighbors and minimum distance to explore the embedding landscape.
""")

# Reactive parameter sliders
n_neighbors = mo.ui.slider(5, 50, value=15, step=1, label="UMAP n_neighbors")
min_dist = mo.ui.slider(0.0, 0.99, value=0.1, step=0.05, label="UMAP min_dist")
n_components = mo.ui.dropdown(options=["2", "3"], value="3", label="Dimensions")
mo.hstack([n_neighbors, min_dist, n_components])

# Synthetic high-dimensional data (computed once)
@mo.cell
def high_dim_data():
    np.random.seed(42)
    n_per_class = 300
    categories = ["electronics", "biology", "physics", "literature"]
    X_list = []
    labels = []
    for cat in categories:
        center = np.random.randn(64) * 2
        X_list.append(np.random.randn(n_per_class, 64) + center)
        labels.extend([cat] * n_per_class)
    X = np.vstack(X_list)
    # standardize
    X = (X - X.mean(axis=0)) / (X.std(axis=0) + 1e-8)
    return X, labels, categories

# Reactive UMAP projection
@mo.cell
def umap_projection(data=high_dim_data):
    X, labels, categories = data
    import umap
    import pandas as pd

    n_comp = int(n_components.value)
    reducer = umap.UMAP(
        n_components=n_comp,
        n_neighbors=n_neighbors.value,
        min_dist=min_dist.value,
        random_state=42
    )
    emb = reducer.fit_transform(X)

    if n_comp == 3:
        df = pd.DataFrame({
            "UMAP-1": emb[:, 0],
            "UMAP-2": emb[:, 1],
            "UMAP-3": emb[:, 2],
            "Category": labels
        })
        import plotly.express as px
        fig = px.scatter_3d(
            df, x="UMAP-1", y="UMAP-2", z="UMAP-3",
            color="Category",
            opacity=0.7,
            title=f"UMAP 3D (n_neighbors={n_neighbors.value}, min_dist={min_dist.value})",
            template="plotly_white",
            color_discrete_sequence=px.colors.qualitative.Vivid
        )
        fig.update_traces(marker=dict(size=3))
    else:
        df = pd.DataFrame({
            "UMAP-1": emb[:, 0],
            "UMAP-2": emb[:, 1],
            "Category": labels
        })
        import plotly.express as px
        fig = px.scatter(
            df, x="UMAP-1", y="UMAP-2",
            color="Category",
            opacity=0.7,
            title=f"UMAP 2D (n_neighbors={n_neighbors.value}, min_dist={min_dist.value})",
            template="plotly_white",
            color_discrete_sequence=px.colors.qualitative.Vivid
        )
        fig.update_traces(marker=dict(size=6))

    fig.update_layout(margin=dict(l=0, r=0, b=0, t=40))
    return mo.ui.plotly(fig)

# Reactive silhouette-style metric
@mo.cell
def embedding_metric(data=high_dim_data):
    X, labels, categories = data
    # Use a lightweight proxy metric: average within-class variance ratio
    from sklearn.decomposition import PCA
    pca2 = PCA(n_components=2).fit_transform(X)
    overall_var = np.var(pca2, axis=0).sum()
    within_var = 0.0
    for cat in categories:
        mask = np.array([l == cat for l in labels])
        within_var += np.var(pca2[mask], axis=0).sum()
    ratio = overall_var / (within_var / len(categories) + 1e-8)
    return mo.md(f"""
    **Embedding Quality Proxy**
    - Overall variance / avg within-class variance = **{ratio:.2f}**
    - Higher values suggest better class separation (very approximate).
    """)

# Footer markdown
mo.md("""## Notes

- `high_dim_data` is computed once and cached.
- `umap_projection` re-runs when `n_neighbors`, `min_dist`, or `n_components` change.
- Switching to 2D collapses the z-axis and uses `px.scatter` instead of `px.scatter_3d`.
""")
