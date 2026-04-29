/**
 * Read models - re-export from domain sub-modules.
 *
 * Split into: base, session, attendance, homework, message, alert, refund, card, report.
 * This file preserves backward compatibility for all existing consumers.
 */
module.exports = require('./read-models/index');
