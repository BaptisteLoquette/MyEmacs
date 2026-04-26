// Archetypes: layout+composition instructions per domain.
// Each domain has 4-5 archetypes. On generation, one is randomly selected.

const ARCHETYPES = {
  physics: [
    {
      name: "feynman-diagram",
      instruction: "Use a Feynman diagram layout. Time axis vertical (upward). Label all vertices and propagator lines. Include coupling constants at vertices if applicable.",
    },
    {
      name: "field-visualization",
      instruction: "Visualize the field with direction arrows, equipotential contours, or field lines. Show source charges or sources. Use streamlines for continuous fields. Label key regions.",
    },
    {
      name: "equation-breakdown",
      instruction: "Display the key equation prominently. Annotate each term with a connecting line to a visual representation of that term's physical meaning. Use callout boxes.",
    },
    {
      name: "spacetime-diagram",
      instruction: "Use a Minkowski spacetime diagram. Time on vertical axis, space on horizontal. Show worldlines, light cones (45°), and key events labeled. Dashed lines for spacelike intervals.",
    },
    {
      name: "experimental-setup",
      instruction: "Show a schematic of the experimental apparatus. Label each component (source, detector, sample, etc.). Show the interaction region highlighted. Include measurement readouts.",
    }
  ],
  electronics: [
    {
      name: "circuit-schematic",
      instruction: "Draw a clean circuit schematic using standard IEEE/ANSI symbols. Label all components with values (R1=10k, C1=100n, etc.). Show voltage sources, ground. Use horizontal/vertical lines only — no diagonal wires.",
    },
    {
      name: "block-diagram",
      instruction: "Create a functional block diagram with rectangular blocks connected by signal flow arrows. Label each block with its function. Show input on left, output on right. Include feedback loops if applicable.",
    },
    {
      name: "timing-diagram",
      instruction: "Display digital timing with labeled signal transitions. Show clock, data, and control signals aligned vertically. Label setup/hold times, propagation delays. Use square waves with clear edges.",
    },
    {
      name: "bode-plot",
      instruction: "Show magnitude (dB) vs frequency and phase (deg) vs frequency subplots. Mark -3dB point, unity gain frequency, and phase margin. Log scale on frequency axis. Label poles and zeros contributions.",
    },
    {
      name: "device-cross-section",
      instruction: "Show a cross-sectional view of the semiconductor device. Label each layer (oxide, channel, source, drain, gate). Show doping regions (n+, p-well). Include band diagram overlay if relevant.",
    }
  ],
  "ai-ml": [
    {
      name: "architecture-diagram",
      instruction: "Show neural network layers as stacked rectangles with dimensions labeled. Use arrows for data flow direction. Label activation functions and layer types. Include input/output shapes.",
    },
    {
      name: "attention-visualization",
      instruction: "Visualize the attention mechanism: show Query, Key, Value matrices. Display attention score heatmap. Show multi-head splitting and concatenation. Label dimensions throughout.",
    },
    {
      name: "training-pipeline",
      instruction: "Create a pipeline flowchart: Data → Preprocessing → Model → Loss → Optimizer → Update. Label each stage. Show batch flow. Include evaluation branch. Add typical hyperparameters as annotations.",
    },
    {
      name: "loss-landscape",
      instruction: "Show a 3D or contour plot of the loss landscape. Mark the optimization trajectory from initialization to convergence. Label local minima, saddle points, and the global minimum. Show gradient arrows.",
    },
    {
      name: "embedding-projection",
      instruction: "Display a 2D projection (t-SNE/UMAP style) of embeddings. Color-code clusters by category. Label representative points. Add a legend. Show distance relationships.",
    }
  ],
  math: [
    {
      name: "proof-walkthrough",
      instruction: "Display the theorem statement at top. Number each proof step below. Use connecting arrows between steps showing logical flow. Highlight the key insight step with a different color.",
    },
    {
      name: "function-plot",
      instruction: "Plot the function on labeled Cartesian axes. Mark key features: roots, extrema, inflection points, asymptotes (with dashed lines). Shade regions of interest. Include derivative/second derivative insets.",
    },
    {
      name: "geometric-construction",
      instruction: "Create a precise geometric diagram. Label all points (A, B, C), lines, angles, and circles. Show construction steps with progressively lighter lines. Include angle and length annotations.",
    },
    {
      name: "commutative-diagram",
      instruction: "Draw a commutative diagram with objects (A, B, C) as nodes and morphisms (f, g, h) as arrows. Show the composition equalities clearly. Use curved arrows for natural transformations.",
    },
  ],
  "data-viz": [
    {
      name: "multi-panel",
      instruction: "Create 2-4 related plots arranged in a grid. Each panel has its own labeled axes. Add a shared title at top. Use consistent color mapping across panels. Include panel labels (a), (b), etc.",
    },
    {
      name: "distribution-analysis",
      instruction: "Show a histogram overlaid with a fitted probability density curve. Display summary statistics in a box (mean, median, std, n). Mark quartiles. Use a clean color palette with semi-transparent bars.",
    },
    {
      name: "comparison-chart",
      instruction: "Create a side-by-side or grouped comparison. Use bar charts, line charts, or box plots. Label groups clearly. Add error bars or confidence intervals. Use contrasting but harmonious colors.",
    },
    {
      name: "heatmap-matrix",
      instruction: "Display a correlation or confusion matrix as a heatmap. Include a color scale legend. Label rows and columns clearly. Show numeric values inside cells. Use a diverging colormap centered at zero.",
    },
  ],
  "concept-map": [
    {
      name: "hierarchical-tree",
      instruction: "Show a hierarchical tree: main concept at top or center → sub-concepts branching → details at leaves. Use consistent rectangular nodes. Connect with clean lines. Color-code by level.",
    },
    {
      name: "network-graph",
      instruction: "Display an interconnected network of concepts. Place related nodes near each other. Use edge thickness to indicate relationship strength. Label all nodes and key edges. Use force-directed or layered layout.",
    },
    {
      name: "flow-diagram",
      instruction: "Create a sequential flow diagram left-to-right or top-to-bottom. Use distinct shapes for different step types (process = rectangle, decision = diamond, start/end = rounded). Label all paths.",
    },
    {
      name: "comparison-matrix",
      instruction: "Show a 2x2 matrix or comparison table. Label axes clearly. Place contrasting elements in each quadrant. Use subtle background shading for each cell. Include a takeaway annotation.",
    },
  ],
  "general-science": [
    {
      name: "annotated-diagram",
      instruction: "Create a central illustration with numbered callout labels around it. Each callout explains a key component. Use thin connector lines. Minimal but clear visual style. White background.",
    },
    {
      name: "process-flow",
      instruction: "Show a step-by-step process. Numbered stages with illustrations or icons for each. Arrows between stages. Brief descriptions under each stage. Clean horizontal or vertical layout.",
    },
    {
      name: "cross-section",
      instruction: "Show a cutaway or cross-sectional view revealing internal structure. Label each layer or component. Use subtle color differentiation. Include a scale reference if relevant.",
    },
    {
      name: "comparison-side-by-side",
      instruction: "Display two or more concepts side by side for comparison. Same scale, same perspective. Highlight differences with contrasting colors. Include a clear title for each panel.",
    },
  ]
};

module.exports = { ARCHETYPES };
