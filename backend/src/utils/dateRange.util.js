export const getMonthRange = (year = new Date().getFullYear(), month = new Date().getMonth() + 1) => {
  const start = new Date(year, month - 1, 1, 0, 0, 0, 0);
  const end = new Date(year, month, 0, 23, 59, 59, 999); // Day 0 of next month = last day of this month

  return { start, end };
};


export const getYearRange = (year = new Date().getFullYear()) => {
  const start = new Date(year, 0, 1, 0, 0, 0, 0);  // Jan 1
  const end = new Date(year, 11, 31, 23, 59, 59, 999); // Dec 31

  return { start, end };
};


export const getWeekRange = (referenceDate = new Date()) => {
  const date = new Date(referenceDate);
  const dayOfWeek = date.getDay();

  const start = new Date(date);
  start.setDate(date.getDate() - dayOfWeek);
  start.setHours(0, 0, 0, 0);

  const end = new Date(start);
  end.setDate(start.getDate() + 6);
  end.setHours(23, 59, 59, 999);

  return { start, end };
};

export const getTodayRange = () => {
  const start = new Date();
  start.setHours(0, 0, 0, 0);

  const end = new Date();
  end.setHours(23, 59, 59, 999);

  return { start, end };
};


export const getDateRange = (period = "month", options = {}) => {
  const now = new Date();
  const year = options.year || now.getFullYear();
  const month = options.month || now.getMonth() + 1;

  switch (period.toLowerCase()) {
    case "today":
      return getTodayRange();
    case "week":
      return getWeekRange();
    case "month":
      return getMonthRange(year, month);
    case "year":
      return getYearRange(year);
    default:
      return getMonthRange(year, month);
  }
};