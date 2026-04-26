// Pipeline B: Programmatic diagram rendering.
// Routes structured diagram types (flowcharts, schematics, architecture diagrams)
// to Mermaid or Graphviz for deterministic, text-perfect rendering.

const { execSync } = require("child_process");
const path = require("path");
const fs = require("fs");

const GENERATED_DIR = path.join(__dirname, "generated");

// ── Pipeline routing ───────────────────────────────────────────────────────

function selectFramework(domainId, query) {
  const normalized = query.toLowerCase();

  if (
    domainId === "concept-map" ||
    normalized.includes("flowchart") ||
    normalized.includes("workflow") ||
    normalized.includes("process") ||
    normalized.includes("pipeline")
  ) {
    return "mermaid";
  }

  if (
    normalized.includes("architecture") ||
    normalized.includes("system") ||
    normalized.includes("network") ||
    normalized.includes("graph") ||
    normalized.includes("topology")
  ) {
    return "graphviz";
  }

  if (domainId === "concept-map") {
    return "mermaid";
  }

  return null;
}

// ── Mermaid generation ─────────────────────────────────────────────────────

const MERMAID_PROMPT = `You are generating a Mermaid.js diagram from a user's topic description.
Write ONLY valid Mermaid.js syntax, no markdown wrapping, no explanation.

Choose the best diagram type:
- flowchart TD/LR for processes, workflows, pipelines
- graph TD/LR for relationships, architectures, networks
- mindmap for hierarchical concept breakdowns
- timeline for chronological sequences

Rules:
- Use clear, concise labels (1-5 words per node)
- Group related nodes visually
- Use direction: TD (top-down) or LR (left-right)
- Color-code categories with style directives if helpful
- Keep the diagram to a single page — not more than ~30 nodes

Topic: {query}

Output ONLY the Mermaid.js code:`;

async function generateMermaid(provider, query, signal) {
  const prompt = MERMAID_PROMPT.replace("{query}", query);
  const mermaidCode = await provider.generateText(prompt, null, signal);

  const cleaned = mermaidCode
    .replace(/^```mermaid\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/```\s*$/, "")
    .trim();

  return cleaned;
}

function renderMermaid(mermaidCode, outputPath) {
  const tmpFile = outputPath.replace(".png", ".mmd");
  fs.writeFileSync(tmpFile, mermaidCode, "utf-8");

  try {
    execSync(
      `npx -y @mermaid-js/mermaid-cli mmdc -i "${tmpFile}" -o "${outputPath}" -b white --scale 2`,
      { timeout: 30000, stdio: "pipe" }
    );
  } catch (err) {
    throw new Error(`Mermaid render failed: ${err.message}`);
  } finally {
    try { fs.unlinkSync(tmpFile); } catch (_) {}
  }
}

// ── Graphviz generation ─────────────────────────────────────────────────────

const GRAPHVIZ_PROMPT = `You are generating a Graphviz DOT diagram from a user's topic description.
Write ONLY valid DOT syntax, no markdown wrapping, no explanation.

Rules:
- Use digraph for directed graphs, graph for undirected
- Use rankdir=LR for left-to-right, rankdir=TB for top-to-bottom
- Node labels should be short (1-4 words)
- Use consistent node shapes (box, ellipse, diamond, etc.)
- Group related nodes with subgraph clusters
- Keep the diagram to a single page — not more than ~30 nodes
- Use sensible colors (light blue fill, dark text)

Topic: {query}

Output ONLY the DOT code:`;

async function generateGraphviz(provider, query, signal) {
  const prompt = GRAPHVIZ_PROMPT.replace("{query}", query);
  const dotCode = await provider.generateText(prompt, null, signal);

  const cleaned = dotCode
    .replace(/^```dot\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/```\s*$/, "")
    .trim();

  return cleaned;
}

function renderGraphviz(dotCode, outputPath) {
  const tmpFile = outputPath.replace(".png", ".dot");
  fs.writeFileSync(tmpFile, dotCode, "utf-8");

  try {
    execSync(`dot -Tpng "${tmpFile}" -o "${outputPath}" -Gdpi=150`, {
      timeout: 15000,
      stdio: "pipe",
    });
  } catch (err) {
    try {
      execSync("dot -V", { timeout: 5000, stdio: "pipe" });
    } catch (_) {
      throw new Error(
        "Graphviz (dot) is not installed. Install it from https://graphviz.org/download/ or use 'winget install graphviz' on Windows."
      );
    }
    throw new Error(`Graphviz render failed: ${err.message}`);
  } finally {
    try { fs.unlinkSync(tmpFile); } catch (_) {}
  }
}

// ── Main Pipeline B entry point ────────────────────────────────────────────

async function generateProgrammatic(provider, query, domainId, outputPath, signal) {
  const framework = selectFramework(domainId, query);

  if (!framework) {
    return null;
  }

  if (framework === "mermaid") {
    const mermaidCode = await generateMermaid(provider, query, signal);
    renderMermaid(mermaidCode, outputPath);
    return "mermaid";
  }

  if (framework === "graphviz") {
    const dotCode = await generateGraphviz(provider, query, signal);
    renderGraphviz(dotCode, outputPath);
    return "graphviz";
  }

  return null;
}

module.exports = { generateProgrammatic };
