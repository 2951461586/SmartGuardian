const store = require('../store');

function buildAlertStatistics() {
  const alerts = store.list('alerts');
  const byType = {};
  const bySeverity = {};
  for (let i = 0; i < alerts.length; i++) {
    const alert = alerts[i];
    byType[alert.alertType] = (byType[alert.alertType] || 0) + 1;
    bySeverity[alert.severity] = (bySeverity[alert.severity] || 0) + 1;
  }
  return {
    total: alerts.length,
    active: alerts.filter((item) => item.status === 'ACTIVE').length,
    acknowledged: alerts.filter((item) => item.status === 'ACKNOWLEDGED').length,
    resolved: alerts.filter((item) => item.status === 'RESOLVED').length,
    byType,
    bySeverity
  };
}

async function buildAlertStatisticsAsync() {
  const alerts = await store.listAsync('alerts');
  const byType = {};
  const bySeverity = {};
  for (let i = 0; i < alerts.length; i++) {
    const alert = alerts[i];
    byType[alert.alertType] = (byType[alert.alertType] || 0) + 1;
    bySeverity[alert.severity] = (bySeverity[alert.severity] || 0) + 1;
  }
  return {
    total: alerts.length,
    active: alerts.filter((item) => item.status === 'ACTIVE').length,
    acknowledged: alerts.filter((item) => item.status === 'ACKNOWLEDGED').length,
    resolved: alerts.filter((item) => item.status === 'RESOLVED').length,
    byType,
    bySeverity
  };
}

module.exports = {
  buildAlertStatistics,
  buildAlertStatisticsAsync
};
