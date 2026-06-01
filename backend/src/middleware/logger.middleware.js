export const logger = (req, res, next) => {
  const startTime = Date.now();

  res.on("finish", () => {
    const duration = Date.now() - startTime;
    const status = res.statusCode;
    const method = req.method;
    const url = req.originalUrl;

    let statusIcon = "✅";
    if (status >= 500) statusIcon = "❌";
    else if (status >= 400) statusIcon = "⚠️ ";
    else if (status >= 300) statusIcon = "🔀";

    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${statusIcon} ${method} ${url} → ${status} (${duration}ms)`);
  });

  next();
};
