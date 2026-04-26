function nowIso() {
  return new Date().toISOString();
}

function todayDate() {
  return nowIso().slice(0, 10);
}

function addDays(baseDate, days) {
  const date = new Date(`${baseDate}T00:00:00.000Z`);
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString().slice(0, 10);
}

function addHoursFromNow(hours) {
  const date = new Date();
  date.setHours(date.getHours() + hours);
  return date.toISOString();
}

function formatMonth(isoString) {
  return isoString.slice(0, 7);
}

function createCode(prefix, id) {
  return `${prefix}-${String(id).padStart(4, '0')}`;
}

module.exports = {
  nowIso,
  todayDate,
  addDays,
  addHoursFromNow,
  formatMonth,
  createCode
};
