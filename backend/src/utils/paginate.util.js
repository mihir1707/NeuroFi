import { DEFAULT_PAGE_SIZE, MAX_PAGE_SIZE } from "../config/constants.js";

export const parsePagination = (query = {}) => {
  let page = parseInt(query.page, 10) || 1;
  let limit = parseInt(query.limit, 10) || DEFAULT_PAGE_SIZE;

  if (page < 1) page = 1;
  if (limit < 1) limit = DEFAULT_PAGE_SIZE;
  if (limit > MAX_PAGE_SIZE) limit = MAX_PAGE_SIZE;

  const skip = (page - 1) * limit;

  return { page, limit, skip };
};


export const buildPagination = ({ page = 1, limit = DEFAULT_PAGE_SIZE, total = 0 } = {}) => {
  const pages = Math.ceil(total / limit) || 1;

  return {
    page,
    limit,
    total,
    pages,
    hasNext: page < pages,
    hasPrev: page > 1,
  };
};
