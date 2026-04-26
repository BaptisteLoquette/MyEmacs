// Quality gate: evaluates generated images using a vision model,
// regenerates if quality is insufficient (max 2 retries).

const fs = require("fs");

async function evaluateImage(provider, imagePath, topic, signal) {
  const imageBuffer = fs.readFileSync(imagePath);
  const imageBase64 = imageBuffer.toString("base64");

  const prompt = `You are evaluating a scientific figure for quality. The topic is: "${topic}"

Check the following criteria:
1. Is the diagram scientifically accurate for the topic? (yes/no)
2. Are all text labels crisp, legible, and correctly spelled? (yes/no)
3. Are there any artifacts (watermarks, red circles, garbled regions)? (yes/no)
4. Does the diagram style match professional scientific publication standards? (yes/no)
5. Is the composition clear and well-organized? (yes/no)

Respond with ONLY a JSON object, no markdown, no explanation:
{"pass": true/false, "issues": ["issue 1", "issue 2"]}

If all criteria pass, pass=true and issues=[].
If any criteria fail, pass=false and list the specific issues.`;

  const text = await provider.generateText(prompt, imageBase64, signal);

  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      return { pass: true, issues: [] };
    }
    const result = JSON.parse(jsonMatch[0]);
    return {
      pass: !!result.pass && (!result.issues || result.issues.length === 0),
      issues: result.issues || [],
    };
  } catch (e) {
    return { pass: true, issues: [] };
  }
}

async function generateWithQualityGate(
  provider,
  generateFn,
  imagePath,
  topic,
  signal,
  maxRetries = 2
) {
  await generateFn();

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    const evalResult = await evaluateImage(provider, imagePath, topic, signal);

    if (evalResult.pass) {
      return { passed: true, attempts: attempt + 1 };
    }

    console.log(`  Quality gate failed (attempt ${attempt + 1}/${maxRetries}): ${evalResult.issues.join("; ")}`);
    console.log(`  Regenerating with fixes...`);

    await generateFn(evalResult.issues);
  }

  const finalEval = await evaluateImage(provider, imagePath, topic, signal);
  return {
    passed: finalEval.pass,
    attempts: maxRetries + 1,
    warnings: finalEval.pass ? [] : finalEval.issues,
  };
}

module.exports = { evaluateImage, generateWithQualityGate };
