import { getOpenAIClient, isAIEnabled } from "../config/openai.js";

export const extractReceiptData = async (imageBuffer, mimeType = "image/jpeg") => {
  const emptyResult = {
    merchantName: "",
    totalAmount: null,
    receiptDate: null,
    suggestedCategory: "Other",
    rawText: "",
    confidence: 0,
    source: "none",
  };

  if (!isAIEnabled()) {
    return {
      ...emptyResult,
      message: "AI not configured. Receipt data extraction requires an OpenAI API key.",
    };
  }

  const client = getOpenAIClient();

  try {
    const base64Image = imageBuffer.toString("base64");

    const response = await client.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: `Analyze this receipt image and extract the financial information. 
Respond with ONLY valid JSON in this format (no markdown):
{
  "merchantName": "store or restaurant name",
  "totalAmount": 250.50,
  "receiptDate": "2025-01-15",
  "items": [{"name": "item name", "amount": 100}],
  "suggestedCategory": "Food & Drinks",
  "rawText": "key text from receipt",
  "confidence": 0.9
}
If you cannot read the receipt clearly, return confidence: 0 and null for unknown fields.`,
            },
            {
              type: "image_url",
              image_url: {
                url: `data:${mimeType};base64,${base64Image}`,
                detail: "high",
              },
            },
          ],
        },
      ],
      max_tokens: 500,
    });

    const rawResponse = response.choices[0]?.message?.content?.trim();

    if (!rawResponse) {
      return emptyResult;
    }

    const extracted = JSON.parse(rawResponse);

    return {
      merchantName: extracted.merchantName || "",
      totalAmount: extracted.totalAmount || null,
      receiptDate: extracted.receiptDate ? new Date(extracted.receiptDate) : null,
      items: extracted.items || [],
      suggestedCategory: extracted.suggestedCategory || "Other",
      rawText: extracted.rawText || "",
      confidence: extracted.confidence || 0,
      source: "ai_vision",
    };
  } catch (error) {
    console.error("[OCR Service] Failed to extract receipt data:", error.message);
    return {
      ...emptyResult,
      error: "Failed to process receipt image",
    };
  }
};