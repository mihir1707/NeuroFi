
export const sendSuccess = (res, statusCode = 200, message = "Success", data = null) => {
  const response = { success: true, message };

  if (data !== null && data !== undefined) {
    response.data = data;
  }

  return res.status(statusCode).json(response);
};


export const sendError = (res, statusCode = 400, message = "Something went wrong", errors = null) => {
  const response = { success: false, message };

  if (errors) {
    response.errors = errors;
  }

  return res.status(statusCode).json(response);
};


export const sendPaginated = (res, statusCode = 200, message = "Success", data = [], pagination = {}) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    pagination,
  });
};
