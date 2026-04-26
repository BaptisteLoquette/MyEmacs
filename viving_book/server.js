require("dotenv").config();

const express = require("express");
const crypto = require("crypto");
const path = require("path");
const fs = require("fs");
const sharp = require("sharp");
const GeminiProvider = require("./providers/gemini");
const MinimaxProvider = require("./providers/minimax");
const prompts = require("./prompts");
const qualityGate = require("./quality-gate");
const pipelineB = require("./pipeline-b");

// ── Configuration ──────────────────────────────────────────────────────────

const PORT = parseInt(process.env.PORT, 10) || 3000;
const VERSION = process.env.CACHE_VERSION || "1";
const MODEL_TIMEOUT_MS = parseInt(process.env.MODEL_TIMEOUT_MS, 10) || 120000;
const PROVIDER = process.env.IMAGE_PROVIDER || "gemini";
const GENERATED_DIR = path.join(__dirname, "generated");
const PUBLIC_DIR = path.join(__dirname, "public");

fs.mkdirSync(GENERATED_DIR, { recursive: true });

// ── Helpers ────────────────────────────────────────────────────────────────

function normalize(str) {
  return str.trim().replace(/\s+/g, " ").toLowerCase();
}

function hash(str) {
  return crypto.createHash("sha256").update(str).digest("hex");
}

function pageIdFirst(query) {
  return hash(`first${VERSION}${normalize(query)}`);
}

function pageIdChild(parentId, x, y) {
  const rx = Math.round(x * 100) / 100;
  const ry = Math.round(y * 100) / 100;
  return hash(`child${VERSION}${parentId}${rx}${ry}`);
}

const HASH_REGEX = /^[a-f0-9]{64}$/;

// ── Image Provider ─────────────────────────────────────────────────────────

let imageProvider;

function getProvider() {
  if (imageProvider) return imageProvider;
  if (PROVIDER === "gemini") {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) throw new Error("GEMINI_API_KEY not set");
    imageProvider = new GeminiProvider(
      apiKey,
      process.env.GEMINI_MODEL || "gemini-2.5-flash-image-preview"
    );
  } else if (PROVIDER === "minimax") {
    const apiKey = process.env.MINIMAX_API_KEY;
    if (!apiKey) throw new Error("MINIMAX_API_KEY not set");
    imageProvider = new MinimaxProvider(
      apiKey,
      process.env.MINIMAX_MODEL || "image-01"
    );
  } else {
    throw new Error(`Unknown image provider: ${PROVIDER}`);
  }
  return imageProvider;
}

// ── Red Marker Compositing (§7) ────────────────────────────────────────────

async function compositeRedMarker(imagePath, nx, ny) {
  const image = sharp(imagePath);
  const metadata = await image.metadata();
  const width = metadata.width;
  const height = metadata.height;

  const cx = Math.round(nx * width);
  const cy = Math.round(ny * height);
  const radius = Math.round(width * 0.04);
  const outlineW = Math.max(3, Math.round(width * 0.005));

  const svg = `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <circle cx="${cx}" cy="${cy}" r="${radius}" fill="none" stroke="red" stroke-width="${outlineW}" opacity="0.9"/>
  <circle cx="${cx}" cy="${cy}" r="${radius}" fill="red" opacity="0.25"/>
  <circle cx="${cx}" cy="${cy}" r="${Math.max(4, Math.round(radius * 0.3))}" fill="red" opacity="0.95"/>
</svg>`;

  const overlay = Buffer.from(svg);

  return image
    .composite([{ input: overlay, top: 0, left: 0 }])
    .png()
    .toBuffer();
}

// ── Request Serialization (§9) ─────────────────────────────────────────────

let generationLock = Promise.resolve();

function serialized(fn) {
  const prev = generationLock;
  let release;
  generationLock = new Promise((resolve) => {
    release = resolve;
  });
  return prev.then(() => fn()).finally(() => release());
}

// ── Generation ─────────────────────────────────────────────────────────────

async function generateImage(prompt, referenceImageBase64, issuesContext) {
  const provider = getProvider();
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), MODEL_TIMEOUT_MS);
  try {
    let finalPrompt = prompt;
    if (issuesContext && issuesContext.length > 0) {
      finalPrompt = `FIX THESE ISSUES in your output:\n${issuesContext.map((i) => `- ${i}`).join("\n")}\n\n${prompt}`;
    }
    const buffer = await provider.generate(
      finalPrompt,
      referenceImageBase64,
      controller.signal
    );
    return buffer;
  } finally {
    clearTimeout(timeout);
  }
}

// ── Express App ────────────────────────────────────────────────────────────

const app = express();
app.use(express.json());

// Serve generated images
app.use("/generated", express.static(GENERATED_DIR));

// Serve public frontend
app.use(express.static(PUBLIC_DIR));

// ── POST /api/page ─────────────────────────────────────────────────────────

app.post("/api/page", async (req, res) => {
  try {
    const body = req.body || {};

    // Determine request shape
    const isFirstPage = "query" in body;
    const isChildPage = "parentId" in body && "parentClick" in body;

    if (!isFirstPage && !isChildPage) {
      return res.status(400).json({
        error:
          'Request must have either { "query": "..." } for first page or { "parentId": "...", "parentClick": { "x": 0..1, "y": 0..1 } } for subsequent pages.',
      });
    }

    let pageId;
    let prompt;
    let referenceImageBase64 = null;

    if (isFirstPage) {
      // ── First-page validation ──
      const query = typeof body.query === "string" ? body.query : "";
      if (query.length < 1 || query.length > 300) {
        return res
          .status(400)
          .json({ error: "query must be 1-300 characters." });
      }

      const domainId = body.domain && prompts.getDomainKeywords().some(d => d.id === body.domain)
        ? body.domain
        : prompts.detectDomain(query);
      const archetype = prompts.selectArchetype(domainId);
      const pipeline = prompts.getPipeline(domainId);

      pageId = pageIdFirst(query);
      prompt = prompts.buildFirstPagePrompt(domainId, query, archetype);

      res.locals.domainId = domainId;
      res.locals.pipeline = pipeline;
      res.locals.query = query.trim();
    } else {
      // ── Child-page validation ──
      const { parentId, parentClick } = body;

      if (!HASH_REGEX.test(parentId)) {
        return res
          .status(400)
          .json({ error: "parentId must be a valid content fingerprint." });
      }

      const x = parentClick?.x;
      const y = parentClick?.y;

      if (
        typeof x !== "number" || typeof y !== "number" ||
        !isFinite(x) || !isFinite(y) ||
        x < 0 || x > 1 || y < 0 || y > 1
      ) {
        return res.status(400).json({
          error: "parentClick.x and parentClick.y must be finite floats in [0, 1].",
        });
      }

      pageId = pageIdChild(parentId, x, y);

      const parentPath = path.join(GENERATED_DIR, `${parentId}.png`);
      if (!fs.existsSync(parentPath)) {
        return res.status(400).json({ error: "Parent page not found on disk." });
      }

      const markedBuffer = await compositeRedMarker(parentPath, x, y);
      referenceImageBase64 = markedBuffer.toString("base64");

      const domainId = body.domain && prompts.getDomainKeywords().some(d => d.id === body.domain)
        ? body.domain
        : prompts.detectDomain(body.initialQuery || "general");
      const provider = getProvider();
      let contextDescription = "the area the reader pointed at";
      if (typeof provider.generateText === "function") {
        try {
          contextDescription = await provider.generateText(
            prompts.buildVisionDescribePrompt(),
            referenceImageBase64,
            new AbortController().signal
          );
        } catch (err) {
          console.log(`  Vision-describe failed: ${err.message}. Using generic fallback.`);
        }
      } else {
        console.log(`  Vision-describe skipped: provider does not support text generation`);
      }

      prompt = prompts.buildChildPagePrompt(domainId, contextDescription);

      res.locals.domainId = domainId;
      res.locals.pipeline = "A";
    }

    // ── Serialized generation + cache check (§6, §9) ──
    const imagePath = path.join(GENERATED_DIR, `${pageId}.png`);

    try {
      await serialized(async () => {
        if (fs.existsSync(imagePath) && fs.statSync(imagePath).size > 0) {
          return;
        }

        if (isFirstPage && res.locals.pipeline === "B") {
          try {
            const result = await pipelineB.generateProgrammatic(
              getProvider(),
              res.locals.query,
              res.locals.domainId,
              imagePath,
              new AbortController().signal
            );
            if (result && fs.existsSync(imagePath) && fs.statSync(imagePath).size > 0) {
              console.log(`  Pipeline B (${result}): generated successfully`);
              return;
            }
          } catch (err) {
            console.log(`  Pipeline B failed: ${err.message}. Falling back to Pipeline A.`);
          }
        }

        const topicForEval = isFirstPage
          ? res.locals.query
          : (body.initialQuery || "continuation");

        const generateFn = async (issues) => {
          let imageBuffer;
          try {
            imageBuffer = await generateImage(prompt, referenceImageBase64, issues);
          } catch (err) {
            if (err.name === "AbortError") {
              throw new Error("Image generation timed out.");
            }
            throw err;
          }
          if (!imageBuffer || imageBuffer.length === 0) {
            throw new Error("Received empty image from model.");
          }
          fs.writeFileSync(imagePath, imageBuffer);
        };

        const qResult = await qualityGate.generateWithQualityGate(
          getProvider(),
          generateFn,
          imagePath,
          topicForEval,
          new AbortController().signal
        );

        if (!qResult.passed) {
          console.log(`  Quality gate warnings: ${(qResult.warnings || []).join("; ")}`);
        } else {
          console.log(`  Quality gate passed (attempt ${qResult.attempts})`);
        }
      });
    } catch (err) {
      return res
        .status(500)
        .json({ error: `Generation failed: ${err.message}` });
    }

    return res.json({
      page: {
        id: pageId,
        imageUrl: `/generated/${pageId}.png`,
        parentId: isFirstPage ? null : body.parentId,
        parentClick: isFirstPage ? null : body.parentClick,
        initialQuery: isFirstPage ? body.query.trim() : null,
        domain: res.locals.domainId || "general-science",
      },
    });
  } catch (err) {
    if (!res.headersSent) {
      res.status(500).json({ error: `Server error: ${err.message}` });
    }
  }
});

// ── GET /api/domains ─────────────────────────────────────────────────────

app.get("/api/domains", (_req, res) => {
  res.json({ domains: prompts.getDomainKeywords() });
});

// ── Start ──────────────────────────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`Drill-Down Explainer running at http://localhost:${PORT}`);
  console.log(`Provider: ${PROVIDER}`);
  console.log(`Cache version: ${VERSION}`);
  console.log(`Generated images: ${GENERATED_DIR}`);
});
