const store = require('../store');

function getRefundView(refund) {
  return {
    ...refund
  };
}

async function getRefundViewAsync(refund) {
  return {
    ...refund
  };
}

function buildRefundStatistics() {
  const refunds = store.list('refunds');
  return {
    total: refunds.length,
    pending: refunds.filter((item) => item.status === 'PENDING').length,
    processing: refunds.filter((item) => item.status === 'PROCESSING').length,
    completed: refunds.filter((item) => item.status === 'COMPLETED').length,
    totalAmount: refunds.reduce((sum, item) => sum + Number(item.refundAmount || 0), 0)
  };
}

async function buildRefundStatisticsAsync() {
  const refunds = await store.listAsync('refunds');
  return {
    total: refunds.length,
    pending: refunds.filter((item) => item.status === 'PENDING').length,
    processing: refunds.filter((item) => item.status === 'PROCESSING').length,
    completed: refunds.filter((item) => item.status === 'COMPLETED').length,
    totalAmount: refunds.reduce((sum, item) => sum + Number(item.refundAmount || 0), 0)
  };
}

module.exports = {
  getRefundView,
  getRefundViewAsync,
  buildRefundStatistics,
  buildRefundStatisticsAsync
};
