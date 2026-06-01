import OpenAI from "openai";

export const AI_MODEL = process.env.OPENAI_MODEL || "gpt-4o-mini";

export const AI_MAX_TOKENS = parseInt(process.env.OPENAI_MAX_TOKENS) || 500;

export const AI_TEMPERATURE = parseFloat(process.env.OPENAI_TEMPERATURE) || 0.3;

let openaiClient = null;

const createOpenAIClient = () => {
  const apiKey = process.env.OPENAI_API_KEY;

  if (!apiKey) {
    console.warn("[AI] OPENAI_API_KEY not set. AI features will use fallback responses.");
    return null;
  }

  return new OpenAI({ apiKey });
};

openaiClient = createOpenAIClient();

export const getOpenAIClient = () => openaiClient;

export const isAIEnabled = () => openaiClient !== null;

export default openaiClient;
