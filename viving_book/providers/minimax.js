class MinimaxProvider {
  constructor(apiKey, model = "image-01", baseUrl = "https://api.minimax.io") {
    this.apiKey = apiKey;
    this.model = model;
    this.baseUrl = baseUrl;
  }

  async generate(prompt, referenceImageBase64, signal) {
    const endpoint = `${this.baseUrl}/v1/image_generation`;

    const payload = {
      model: this.model,
      prompt: prompt.slice(0, 1500),
      aspect_ratio: "16:9",
      response_format: "base64",
      n: 1,
    };

    if (referenceImageBase64) {
      payload.subject_reference = [
        {
          type: "character",
          image_file: `data:image/png;base64,${referenceImageBase64}`,
        },
      ];
    }

    const response = await fetch(endpoint, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
      signal,
    });

    if (!response.ok) {
      const text = await response.text().catch(() => "");
      throw new Error(
        `MiniMax API HTTP ${response.status}: ${text.slice(0, 300)}`
      );
    }

    const result = await response.json();

    const statusCode = result.base_resp?.status_code;
    if (statusCode !== 0 && statusCode !== undefined) {
      const msg = result.base_resp?.status_msg || "Unknown error";
      throw new Error(`MiniMax API error ${statusCode}: ${msg}`);
    }

    const images = result.data?.image_base64;
    if (!images || images.length === 0) {
      throw new Error("No images in MiniMax response");
    }

    return Buffer.from(images[0], "base64");
  }
}

module.exports = MinimaxProvider;
