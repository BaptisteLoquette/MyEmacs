const { DOMAINS } = require("./taxonomy/domains");
const { ARCHETYPES } = require("./taxonomy/archetypes");

// ── Shared quality baseline (injected into all prompts) ─────────────────────

const QUALITY_BASELINE = `Visual quality directives:
- Clean, precise vector-aesthetic rendering — like a textbook or Nature figure
- Black/dark lines on white or very light background
- High contrast, sharp lines, no blur, no compression artifacts
- Publication-quality: suitable for a scientific journal figure
- Colorblind-safe palette (viridis, cividis, or muted blues/grays)
- Flat 2D orthographic view (unless 3D is explicitly requested)
- No decorative elements, no 3D renders, no photorealism, no watermarks`;

// ── UX quality rules (from educational-viz §4.4) ────────────────────────────

const UX_RULES = `Quality requirements:
- Labels and annotations must not overlap. Place them clearly with connector lines.
- Axes must have physical units in labels. Use log scale when spanning >2 decades.
- Max 3 visual channels per figure (color + size + position).
- Key features must be annotated: maxima, minima, zero-crossings, boundaries, critical points.
- All text must be crisp, legible, and correctly spelled. No garbled or blurry text.
- Maintain consistent notation throughout. Variables in italic, units in regular.`;

// ── Anti-patterns (negative instructions) ──────────────────────────────────

const ANTI_PATTERNS = `Strictly avoid:
- Overlay overload (more than 4 traces/series on one plot)
- Static dump (cramming everything without clear composition)
- Equation vomit (displaying math without visual counterparts)
- Fake physics (violating known constraints: divB=0, conservation laws, etc.)
- Garbled or hallucinated text in labels and annotations
- Rainbow/jet colormaps — use perceptually uniform colormaps only
- Missing axis labels, missing units, missing legends`;

// ── Domain detection ────────────────────────────────────────────────────────

function detectDomain(query) {
  const normalized = query.toLowerCase();

  const scores = DOMAINS.map((domain) => {
    let score = 0;
    for (const kw of domain.keywords) {
      if (normalized.includes(kw)) {
        score += kw.length;
      }
    }
    return { domain: domain.id, score };
  });

  scores.sort((a, b) => b.score - a.score);
  const best = scores[0];

  if (best.score === 0) {
    return "general-science";
  }

  return best.domain;
}

function getDomainLabel(domainId) {
  const domain = DOMAINS.find((d) => d.id === domainId);
  return domain ? domain.label : "General";
}

function getPipeline(domainId) {
  const domain = DOMAINS.find((d) => d.id === domainId);
  return domain ? domain.pipeline : "A";
}

function getDomainKeywords() {
  return DOMAINS.map((d) => ({ id: d.id, label: d.label }));
}

// ── Archetype selection ─────────────────────────────────────────────────────

const archetypeHistory = {};

function selectArchetype(domainId) {
  const archetypes = ARCHETYPES[domainId] || ARCHETYPES["general-science"];
  if (!archetypes || archetypes.length === 0) {
    return { name: "standard", instruction: "" };
  }

  if (!archetypeHistory[domainId]) {
    archetypeHistory[domainId] = [];
  }

  const history = archetypeHistory[domainId];

  const unused = archetypes.filter((a) => !history.includes(a.name));
  if (unused.length > 0) {
    const pick = unused[Math.floor(Math.random() * unused.length)];
    history.push(pick.name);
    return pick;
  }

  const lru = history.shift();
  history.push(lru);
  return archetypes.find((a) => a.name === lru) || archetypes[0];
}

// ── Domain-specific style conventions ───────────────────────────────────────

const DOMAIN_STYLES = {
  physics: `Physics diagram conventions:
- Feynman diagrams: labeled vertices, propagator lines, time axis upward
- Force diagrams: labeled vectors with arrowheads, coordinate axes, free-body isolation
- Field visualizations: equipotential lines, field direction arrows, field magnitude colormap
- Use SI units on all axes. Variables in italic (E, B, F, m).`,
  electronics: `Electronics diagram conventions:
- Standard IEEE/ANSI schematic symbols (zigzag resistors, parallel-plate capacitors, coil inductors)
- Block diagrams: rectangular blocks with signal flow arrows
- Signal labels: voltage (V), current (I), frequency (f, Hz), impedance (Z, Ω)
- Clean horizontal/vertical wire routing, no diagonal lines in schematics`,
  "ai-ml": `AI/ML diagram conventions:
- Layers shown as labeled rectangles with dimensions (e.g., "Linear 768×3072")
- Data flow: left-to-right arrows
- Attention: Q/K/V matrices, attention score heatmaps, multi-head grouping
- Loss curves: iteration/epoch on x-axis (log scale often), loss value on y-axis
- Architectural blocks clearly separated: encoder, decoder, embeddings, projection`,
  math: `Mathematics diagram conventions:
- LaTeX-quality equation rendering: clean serif math font, proper spacing
- Proofs: numbered steps with logical connectors
- Function plots: Cartesian axes with labeled features (roots, extrema, asymptotes)
- Commutative diagrams: objects as labeled nodes, morphisms as arrows
- Geometric constructions: labeled points (A, B, C), angle arcs, length marks`,
  "data-viz": `Data visualization conventions:
- All axes labeled with quantity and units
- Legend clearly placed, not overlapping data
- Statistical annotations: error bars, confidence intervals, p-values
- Color scales with explicit legend
- Multi-panel figures: panel labels (a), (b), (c) in top-left of each panel`,
  "concept-map": `Concept map conventions:
- Clean node-link diagrams, nodes as rounded rectangles
- Clear hierarchy or network layout, no tangled edges
- Color-coded by category or level
- Short, precise labels inside or near nodes
- Directional arrows where relationships are asymmetric`,
  "general-science": `Scientific illustration conventions:
- Clean technical diagram style
- Labeled components with leader lines
- Professional textbook quality
- Clear figure title
- Logical composition with breathing room`,
};

// ── Prompt builders ─────────────────────────────────────────────────────────

function buildStyleDescription(domainId) {
  const domainStyle = DOMAIN_STYLES[domainId] || DOMAIN_STYLES["general-science"];
  return `${QUALITY_BASELINE}\n\n${domainStyle}\n\n${UX_RULES}\n\n${ANTI_PATTERNS}`;
}

function buildFirstPagePrompt(domainId, query, archetype) {
  const style = buildStyleDescription(domainId);
  const archInstr = archetype && archetype.instruction ? `\nLayout: ${archetype.instruction}` : "";

  return `${style}

Subject: ${query}
${archInstr}

Generate a single 16:9 scientific explanatory figure about the subject above.
Choose the diagram type that best explains this specific concept.
The figure must be self-contained — a viewer should understand the key idea
from this single image without reading external text.

Output a single PNG image, 16:9 aspect ratio. Include a clear descriptive title.`;
}

function buildChildPagePrompt(domainId, contextDescription) {
  const style = buildStyleDescription(domainId);

  return `${style}

You are continuing a scientific explanation. The provided image is the
previous figure. A red circle marks the area the reader wants to explore deeper.

The red circle covers: ${contextDescription}

Generate the next page: a single 16:9 scientific figure that goes deeper
into the marked area — zoom in, expand detail, show internal mechanism,
or reveal the underlying principle.

Critical: match the diagram style, notation conventions, and visual language
of the provided image exactly. The two pages must feel like consecutive figures
in the same publication.

Do NOT include the red circle or any cursor mark in the output.

Output a single PNG image, 16:9.`;
}

function buildVisionDescribePrompt() {
  return `The provided image has a red circle drawn on it. Describe in 1-2 sentences exactly what object, component, structure, or concept the red circle is on. Be specific and technical. For example: "The red circle is on the emitter terminal of a bipolar junction transistor in a common-emitter amplifier circuit" or "The red circle is on the event horizon boundary in a black hole spacetime diagram."`;
}

module.exports = {
  detectDomain,
  getDomainLabel,
  getPipeline,
  getDomainKeywords,
  selectArchetype,
  buildFirstPagePrompt,
  buildChildPagePrompt,
  buildVisionDescribePrompt,
};
