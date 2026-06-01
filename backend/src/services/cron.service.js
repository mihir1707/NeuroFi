import cron from 'node-cron';
import { getRedisClient } from '../config/redis.js';

const scheduleJob = (expression, task, jobName = "Job") => {
  const scheduledTask = cron.schedule(expression, async () => {
    try {
      console.info(`[Cron] Starting ${jobName}`);
      await task();
      console.info(`[Cron] Completed ${jobName}`);
    } catch (error) {
      console.error(`[Cron] Error in ${jobName}:`, error.message);
    }
  });

  return scheduledTask;
};

const recordJobExecution = async (jobName, status, message = "") => {
  const redisClient = getRedisClient();
  const key = `cron:job:${jobName}`;

  const jobData = {
    status,
    message,
    executedAt: new Date().toISOString(),
  };

  try {
    await redisClient.set(key, JSON.stringify(jobData), { EX: 86400 });
  } catch (error) {
    console.error(`Failed to record job execution for ${jobName}:`, error.message);
  }
};

const getLastJobExecution = async (jobName) => {
  const redisClient = getRedisClient();
  const key = `cron:job:${jobName}`;

  try {
    const data = await redisClient.get(key);
    return data ? JSON.parse(data) : null;
  } catch (error) {
    console.error(`Failed to retrieve job execution for ${jobName}:`, error.message);
    return null;
  }
};

module.exports = {
  scheduleJob,
  recordJobExecution,
  getLastJobExecution,
};
