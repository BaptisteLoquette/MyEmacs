import marimo as mo

# Title markdown
mo.md("""# Reactive Attention — BertViz-style Heatmap

This Marimo notebook creates an interactive attention heatmap without requiring a live model.

We synthesize attention weights for a toy sentence and let you explore head specialization with reactive selectors.
""")

# Reactive UI controls
sentence = mo.ui.text(value="The cat sat on the mat", label="Sentence (space-separated tokens)")
layer = mo.ui.slider(0, 3, value=0, step=1, label="Layer index")
head = mo.ui.slider(0, 3, value=0, step=1, label="Head index")
mo.hstack([sentence, layer, head])

# Reactive attention data generation
@mo.cell
def attention_data():
    text = sentence.value
    tokens = text.split() if text.strip() else ["[PAD]"]
    n = len(tokens)
    np.random.seed(layer.value * 7 + head.value * 13 + hash(text) % 1000)
    attn = np.random.rand(n, n)
    # Softmax row-wise for realism
    exp = np.exp(attn - attn.max(axis=1, keepdims=True))
    attn = exp / exp.sum(axis=1, keepdims=True)
    return tokens, attn

# Reactive heatmap plot
@mo.cell
def attention_heatmap(data=attention_data):
    tokens, attn = data
    import plotly.express as px
    import plotly.graph_objects as go

    fig = px.imshow(
        attn,
        x=tokens,
        y=tokens,
        color_continuous_scale="Viridis",
        aspect="equal",
        title=f"Attention Heatmap — Layer {layer.value}, Head {head.value}"
    )
    fig.update_layout(
        xaxis_title="Key",
        yaxis_title="Query",
        margin=dict(l=50, r=50, t=50, b=50)
    )
    return mo.ui.plotly(fig)

# Reactive summary
@mo.cell
def attention_summary(data=attention_data):
    tokens, attn = data
    n = len(tokens)
    # Find most attended token per query
    max_keys = [tokens[int(np.argmax(row))] for row in attn]
    rows = "\n".join([f"- **{q}** → mostly attends to **{k}**" for q, k in zip(tokens, max_keys)])
    return mo.md(f"""
    **Layer {layer.value}, Head {head.value} Summary**

    {rows}
    """)

# Footer markdown
mo.md("""## Notes

- `sentence` is tokenized by whitespace for simplicity; real tokenizers would use `transformers.AutoTokenizer`.
- `layer` and `head` sliders change the random seed to simulate different attention patterns.
- Row-wise softmax ensures each query distributes probability mass over keys.
""")
