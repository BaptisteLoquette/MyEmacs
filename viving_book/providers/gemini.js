const { GoogleGenerativeAI } = require("@google/generative-ai");

class GeminiProvider {
  constructor(apiKey, model = "gemini-2.5-flash-image-preview") {
    this.genAI = new GoogleGenerativeAI(apiKey);
    this.model = model;
  }

  async generate(prompt, referenceImageBase64, signal) {
    const model = this.genAI.getGenerativeModel({
      model: this.model,
      generationConfig: {
        responseModalities: ["image", "text"],
      },
    });

    const parts = [{ text: prompt }];

    if (referenceImageBase64) {
      parts.push({
        inlineData: {
          mimeType: "image/png",
          data: referenceImageBase64,
        },
      });
    }

    const result = await model.generateContent(
      { contents: [{ role: "user", parts }] },
      { signal }
    );

    const response = result.response;
    if (!response || !response.candidates || response.candidates.length === 0) {
      throw new Error("No response from Gemini");
    }

    const candidate = response.candidates[0];
    if (!candidate.content || !candidate.content.parts) {
      throw new Error("No content in Gemini response");
    }

    for (const part of candidate.content.parts) {
      if (part.inlineData && part.inlineData.data) {
        return Buffer.from(part.inlineData.data, "base64");
      }
    }

    throw new Error("No inline image in Gemini response");
  }

  async generateText(prompt, imageBase64, signal) {
    const model = this.genAI.getGenerativeModel({
      model: this.model,
    });

    const parts = [{ text: prompt }];

    if (imageBase64) {
      parts.push({
        inlineData: {
          mimeType: "image/png",
          data: imageBase64,
        },
      });
    }

    const result = await model.generateContent(
      { contents: [{ role: "user", parts }] },
      { signal }
    );

    const response = result.response;
    if (!response || !response.candidates || response.candidates.length === 0) {
      throw new Error("No response from Gemini");
    }

    const text = response.text();
    if (!text || text.trim().length === 0) {
      throw new Error("Empty text response from Gemini");
    }

    return text.trim();
  }
}

module.exports = GeminiProvider;
