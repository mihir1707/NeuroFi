export const PORT = parseInt(process.env.PORT) || 5000;
// 0.0.0.0 is connections from ALL IPs.
export const HOST = process.env.HOST || "0.0.0.0";
export const NODE_ENV = process.env.NODE_ENV || "development";
export const IS_PRODUCTION = NODE_ENV === "production";
export const API_PREFIX = process.env.API_PREFIX || "/api/v1";

// jwt
export const JWT_SECRET = process.env.JWT_SECRET || "your_super_secret_jwt_key_change_in_production";
export const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "7d";

// cors -> Controls which frontend apps can access backend.
export const CORS_ORIGINS = process.env.CORS_ORIGINS
  ? process.env.CORS_ORIGINS.split(",").map((o) => o.trim())
  : ["http://localhost:3000", "http://localhost:8081", "http://10.0.2.2:5000"];


  // salt rounds = Hash complexity level.
  export const BCRYPT_SALT_ROUNDS = parseInt(process.env.BCRYPT_SALT_ROUNDS) || 10;


// cloudinary
export const CLOUDINARY_CLOUD_NAME = process.env.CLOUDINARY_CLOUD_NAME || "";
export const CLOUDINARY_API_KEY = process.env.CLOUDINARY_API_KEY || "";
export const CLOUDINARY_API_SECRET = process.env.CLOUDINARY_API_SECRET || "";

export const MAX_UPLOAD_SIZE = parseInt(process.env.MAX_UPLOAD_SIZE) || 5 * 1024 * 1024;

// Email (Simple Mail Transfer Protocol) -> Used to send emails.
export const SMTP_HOST = process.env.SMTP_HOST || "";
export const SMTP_PORT = parseInt(process.env.SMTP_PORT) || 587;
export const SMTP_USER = process.env.SMTP_USER || "";
export const SMTP_PASS = process.env.SMTP_PASS || "";
export const SMTP_FROM = process.env.SMTP_FROM || "noreply@smartfinance.app"; // Sender email.

// Currency API (free, no key needed - @fawazahmed0/currency-api via jsDelivr + Cloudflare fallback)
// Primary:  https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/{code}.json
// Fallback: https://latest.currency-api.pages.dev/v1/currencies/{code}.json

// Pagination -> Splitting large data into pages.
export const DEFAULT_PAGE_SIZE = 20;
export const MAX_PAGE_SIZE = 100;

// rate limit
export const RATE_LIMIT_WINDOW_MS = 15 * 60 * 1000;
export const RATE_LIMIT_MAX = parseInt(process.env.RATE_LIMIT_MAX) || 100;

// login attempts
export const AUTH_RATE_LIMIT_MAX = parseInt(process.env.AUTH_RATE_LIMIT_MAX) || 10;

export const validateConfig = () => {
  if (!IS_PRODUCTION) return;

  const errors = [];

  if (JWT_SECRET === "your_super_secret_jwt_key_change_in_production") {
    errors.push("JWT_SECRET must be changed from the default in production");
  }

  if (!process.env.MONGO_URI) {
    errors.push("MONGO_URI must be set in production");
  }

  if (errors.length > 0) {
    throw new Error(`Configuration errors:\n${errors.join("\n")}`);
  }
};