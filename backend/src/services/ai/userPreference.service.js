import UserMerchantPreference from "../../models/UserMerchantPreference.js";

export const lookupUserPreference = async (userId, merchantKey) => {
  if (!userId || !merchantKey) return null;

  const record = await UserMerchantPreference.findOne({
    user: userId,
    merchantKey,
  }).lean();

  return record || null;
};

export const saveUserCorrection = async (
  userId,
  merchantKey,
  category,
  icon = "📦",
  previousCategory = null
) => {
  const record = await UserMerchantPreference.findOneAndUpdate(
    { user: userId, merchantKey },
    {
      $set: {
        category,
        icon,
        lastCorrectedAt: new Date(),
        ...(previousCategory && { previousCategory }),
      },
      $inc: { totalCorrections: 1 },
      $setOnInsert: { user: userId, merchantKey },
    },
    { upsert: true, new: true, setDefaultsOnInsert: true }
  ).lean();

  return record;
};

export const listUserPreferences = async (userId, limit = 50) => {
  return UserMerchantPreference.find({ user: userId })
    .sort({ lastCorrectedAt: -1 })
    .limit(limit)
    .lean();
};

export const deleteUserPreference = async (userId, merchantKey) => {
  const result = await UserMerchantPreference.deleteOne({ user: userId, merchantKey });
  return result.deletedCount > 0;
};
