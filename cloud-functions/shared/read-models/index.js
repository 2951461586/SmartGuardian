const base = require('./base');
const session = require('./session');
const attendance = require('./attendance');
const homework = require('./homework');
const message = require('./message');
const alert = require('./alert');
const refund = require('./refund');
const card = require('./card');
const report = require('./report');

module.exports = {
  ...base,
  ...session,
  ...attendance,
  ...homework,
  ...message,
  ...alert,
  ...refund,
  ...card,
  ...report
};
