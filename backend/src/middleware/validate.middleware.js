// Joi is a very popular, powerful Data Validation Library for JavaScript.

import Joi from "joi";

export const validate = (schemas = {}) => {
  return (req, res, next) => {
    const errors = [];

    if (schemas.body) {
      const { error, value } = schemas.body.validate(req.body, {
        abortEarly: false,  
        stripUnknown: true,
      });

      if (error) {
        errors.push(...error.details.map((d) => ({
          location: "body",
          field: d.path.join("."),
          message: d.message.replace(/"/g, ""),
        })));
      } else {
        req.body = value; 
      }
    }

    if (schemas.query) {
      const { error, value } = schemas.query.validate(req.query, {
        abortEarly: false,
        stripUnknown: true,
        allowUnknown: false,
      });

      if (error) {
        errors.push(...error.details.map((d) => ({
          location: "query",
          field: d.path.join("."),
          message: d.message.replace(/"/g, ""),
        })));
      } else {
        req.query = value;
      }
    }

    if (schemas.params) {
      const { error, value } = schemas.params.validate(req.params, {
        abortEarly: false,
        stripUnknown: true,
      });

      if (error) {
        errors.push(...error.details.map((d) => ({
          location: "params",
          field: d.path.join("."),
          message: d.message.replace(/"/g, ""),
        })));
      } else {
        req.params = value;
      }
    }

    if (errors.length > 0) {
      return res.status(400).json({
        success: false,
        message: "Validation failed. Please check your input.",
        errors,
      });
    }

    next();
  };
};

export const objectId = Joi.string().hex().length(24).messages({
  "string.hex": "Invalid ID format",
  "string.length": "Invalid ID format",
});

export const currencyCode = Joi.string().length(3).uppercase().trim();

export const hexColor = Joi.string().pattern(/^#([0-9a-f]{3}|[0-9a-f]{6})$/i);