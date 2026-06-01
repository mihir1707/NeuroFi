// Multer is a popular, open-source Node.js middleware for handling

import multer from "multer";
import { MAX_UPLOAD_SIZE } from "../config/constants.js";

const ALLOWED_MIME_TYPES = ["image/jpeg", "image/jpg", "image/png", "image/webp"];

const fileFilter = (req, file, cb) => {
  // mime type -> File type identifier.
  if (ALLOWED_MIME_TYPES.includes(file.mimetype)) {
    // callback
    cb(null, true);
  } else {
    cb(
      new Error("Invalid file type. Only JPEG, PNG, and WebP images are allowed."),
      false
    );
  }
};

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: MAX_UPLOAD_SIZE,
    files: 1,                   
  },
  fileFilter,
});

export const uploadReceipt = upload.single("receipt");

export const uploadProfileImage = upload.single("profileImage");

export const handleUploadError = (error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        success: false,
        message: `File too large. Maximum size is ${MAX_UPLOAD_SIZE / (1024 * 1024)}MB.`,
      });
    }
    return res.status(400).json({
      success: false,
      message: `Upload error: ${error.message}`,
    });
  }

  if (error) {
    return res.status(400).json({
      success: false,
      message: error.message,
    });
  }

  next();
};