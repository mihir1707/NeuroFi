import mongoose from "mongoose";
import dns from "node:dns/promises";

dns.setServers(["8.8.8.8","8.8.4.4"]);
mongoose.set("strictQuery", true);

let listenersAttached = false;

const attachConnectionListeners = () => {
  if (listenersAttached) return;

  mongoose.connection.on("disconnected", () => {
    console.warn("[MongoDB] Disconnected from database");
  });

  mongoose.connection.on("reconnected", () => {
    console.info("[MongoDB] Reconnected to database");
  });

  mongoose.connection.on("error", (error) => {
    console.error("[MongoDB] Connection error:", error.message);
  });

  listenersAttached = true;
};

const buildDirectUri = (srvUri) => {
  try {
    const url = new URL(srvUri);
    const host = url.hostname;
    const user = url.username;
    const pass = url.password;
    const db   = url.pathname.replace("/", "") || "smart_finance_tracker";

    // Convert cluster0.7lg6whp.mongodb.net → shard hosts
    // Standard Atlas direct shard format
    const clusterBase = host.replace("cluster0.", "");
    const directHost  = `cluster0-shard-00-00.${clusterBase}:27017,cluster0-shard-00-01.${clusterBase}:27017,cluster0-shard-00-02.${clusterBase}:27017`;

    return `mongodb://${user}:${pass}@${directHost}/${db}?ssl=true&replicaSet=atlas-${clusterBase.split(".")[0]}-shard-0&authSource=admin&retryWrites=true`;
  } catch {
    return null;
  }
};

export const connectDB = async () => {
  if (mongoose.connection.readyState === 1) {
    console.info("[MongoDB] Already connected");
    return mongoose.connection;
  }

  attachConnectionListeners();

  const mongoURI = process.env.MONGO_URI;

  try {
    await mongoose.connect(mongoURI, {
      maxPoolSize: 10,
      minPoolSize: 2,
      serverSelectionTimeoutMS: 8000,
      socketTimeoutMS: 45000,
    });
    console.info("[MongoDB] Connected successfully (SRV)");
    return mongoose.connection;
  } catch (srvError) {
    console.warn("[MongoDB] SRV connection failed:", srvError.message);
  }

  if (mongoURI.startsWith("mongodb+srv://")) {
    console.info("[MongoDB] Trying direct connection...");
    const directUri = buildDirectUri(mongoURI);

    if (directUri) {
      try {
        await mongoose.connect(directUri, {
          maxPoolSize: 10,
          minPoolSize: 2,
          serverSelectionTimeoutMS: 10000,
          socketTimeoutMS: 45000,
          tls: true,
          tlsAllowInvalidCertificates: false,
        });
        console.info("[MongoDB] Connected successfully (direct)");
        return mongoose.connection;
      } catch (directError) {
        console.error("[MongoDB] Direct connection failed:", directError.message);
      }
    }
  }

  throw new Error("MongoDB: All connection attempts failed. Check MONGO_URI and network access.");
};

export const disconnectDB = async () => {
  if (mongoose.connection.readyState === 0) return;
  await mongoose.connection.close(false);
  console.info("[MongoDB] Connection closed gracefully");
};