const { createClient } = require("redis");
const constants = require("./constants");

let redisClient = null;
let listenersAttached = false;

const getReconnectDelay = (retries) => {
  if (retries > 20) {
    return new Error("Redis retry attempts exhausted.");
  }

  return Math.min(retries * 100, 3000);
};

const buildClient = () => {
  return createClient({
    url: constants.redis.url,
    socket: {
      connectTimeout: constants.redis.connectTimeoutMS,
      reconnectStrategy: getReconnectDelay,
    },
  });
};

const attachListeners = (client) => {
  if (listenersAttached) {
    return;
  }

  client.on("connect", () => {
    console.info("Redis connecting...");
  });

  client.on("ready", () => {
    console.info("Redis ready.");
  });

  client.on("end", () => {
    console.warn("Redis connection closed.");
  });

  client.on("reconnecting", () => {
    console.warn("Redis reconnecting...");
  });

  client.on("error", (error) => {
    console.error("Redis error:", error.message);
  });

  listenersAttached = true;
};

const connectRedis = async () => {
  if (!redisClient) {
    redisClient = buildClient();
    attachListeners(redisClient);
  }

  if (!redisClient.isOpen) {
    await redisClient.connect();
  }

  return redisClient;
};

const getRedisClient = () => {
  if (!redisClient) {
    throw new Error("Redis client has not been initialized. Call connectRedis first.");
  }

  return redisClient;
};

const disconnectRedis = async () => {
  if (!redisClient) {
    return;
  }

  if (redisClient.isOpen) {
    await redisClient.quit();
    console.info("Redis disconnected.");
  }

  redisClient = null;
  listenersAttached = false;
};

module.exports = {
  connectRedis,
  getRedisClient,
  disconnectRedis,
};
