// Domain definitions with keyword maps for Tier-1 routing.
// Each domain has: name, label, keywords, and pipeline preference.

const DOMAINS = [
  {
    id: "physics",
    label: "Physics",
    keywords: [
      "quantum", "particle", "field", "wave", "spacetime", "relativity",
      "electromagnetic", "feynman", "schrodinger", "hamiltonian", "lagrangian",
      "entropy", "thermodynamic", "carnot", "oscillator", "resonance",
      "maxwell", "diffraction", "interference", "polarization", "optics",
      "band structure", "phonon", "semiconductor", "superconductor",
      "nuclear", "fusion", "plasma", "gravitational", "cosmology",
      "tunneling", "entanglement", "superposition", "wavefunction",
      "poynting", "waveguide", "mechanics", "kinematics", "momentum",
      "force diagram", "free-body", "potential energy", "phase transition"
    ],
    pipeline: "A"
  },
  {
    id: "electronics",
    label: "Electronics",
    keywords: [
      "circuit", "transistor", "voltage", "current", "resistor", "capacitor",
      "inductor", "pcb", "schematic", "signal", "amplifier", "op-amp",
      "differential pair", "current mirror", "bandgap", "oscillator",
      "pll", "adc", "dac", "ldo", "dc-dc", "charge pump", "mosfet",
      "cmos", "bjt", "jfet", "gain", "bandwidth", "impedance", "transfer function",
      "bode plot", "pole", "zero", "stability", "feedback", "noise",
      "eye diagram", "s-parameter", "smith chart", "transmission line",
      "crosstalk", "signal integrity", "spice", "vco", "mixer", "filter",
      "photonic", "waveguide", "laser", "photodetector", "led", "vlsi",
      "neuromorphic", "spiking", "memristor", "chopper", "subthreshold"
    ],
    pipeline: "A"
  },
  {
    id: "ai-ml",
    label: "AI / ML",
    keywords: [
      "neural network", "transformer", "attention", "deep learning",
      "gradient", "backprop", "loss function", "embedding", "token",
      "llm", "gpt", "bert", "diffusion model", "denoising", "score function",
      "classifier", "regression", "clustering", "reinforcement learning",
      "policy gradient", "actor critic", "ppo", "q-learning", "mdp",
      "gan", "vae", "autoencoder", "encoder", "decoder", "softmax",
      "layer norm", "batch norm", "dropout", "activation", "relu", "gelu",
      "cross-entropy", "adam", "sgd", "learning rate", "overfitting",
      "regularization", "convolution", "pooling", "resnet", "unet",
      "rnn", "lstm", "gru", "seq2seq", "beam search", "temperature",
      "top-k", "top-p", "sampling", "inference", "fine-tuning", "lora",
      "rag", "retrieval", "vector database", "mechanistic interpretability",
      "superposition", "sparse autoencoder", "activation patching"
    ],
    pipeline: "A"
  },
  {
    id: "math",
    label: "Mathematics",
    keywords: [
      "theorem", "proof", "equation", "calculus", "algebra", "geometry",
      "topology", "manifold", "group", "ring", "field", "vector space",
      "eigenvalue", "eigenvector", "matrix", "determinant", "integral",
      "derivative", "differential", "laplacian", "fourier", "laplace",
      "category theory", "functor", "commutative diagram", "homology",
      "cohomology", "probability", "statistic", "distribution",
      "stochastic", "markov", "bayesian", "optimization", "convex",
      "linear programming", "graph theory", "number theory", "set theory",
      "logic", "combinatorics", "knot theory", "dynamical system",
      "chaos", "fractal", "riemann", "hilbert", "functional analysis"
    ],
    pipeline: "A"
  },
  {
    id: "data-viz",
    label: "Data Visualization",
    keywords: [
      "chart", "plot", "histogram", "heatmap", "scatter", "distribution",
      "statistical", "bar chart", "line chart", "pie chart", "box plot",
      "correlation", "regression", "trend", "time series", "dashboard",
      "infographic", "dataviz", "data visualization", "figure", "panel"
    ],
    pipeline: "A"
  },
  {
    id: "concept-map",
    label: "Concept Map",
    keywords: [
      "flowchart", "mind map", "system diagram",
      "pipeline", "workflow", "process", "lifecycle", "taxonomy",
      "hierarchy", "comparison", "timeline", "roadmap", "framework",
      "overview", "structure", "relationship", "dependency"
    ],
    pipeline: "B"
  },
  {
    id: "general-science",
    label: "General Science",
    keywords: [
      "biology", "chemistry", "molecule", "cell", "dna", "protein",
      "crispr", "gene", "enzyme", "reaction", "experiment", "method",
      "hypothesis", "research", "study", "analysis", "scientific",
      "lab", "microscope", "spectrum", "astronomy", "geology"
    ],
    pipeline: "A"
  }
];

module.exports = { DOMAINS };
