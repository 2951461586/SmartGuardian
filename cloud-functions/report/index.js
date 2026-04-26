const contract = require('./contract.json');
const { createDomainHandler, ok } = require('../shared/router');
const {
  buildAttendanceReportAsync,
  buildAttendanceDailyStatsAsync,
  buildStudentAttendanceSummaryAsync,
  buildFinanceReportAsync,
  buildFinanceSummaryModelAsync,
  buildDailyRevenueStatsAsync,
  buildServiceProductRevenueAsync,
  buildTeacherPerformanceAsync
} = require('../shared/read-models');

const routes = [
  {
    method: 'GET',
    path: '/api/v1/reports/attendance',
    roles: ['ADMIN'],
    handler: async ({ query }) => {
      return ok(await buildAttendanceReportAsync(query.startDate || '', query.endDate || ''));
    }
  },
  {
    method: 'GET',
    path: '/api/v1/reports/finance',
    roles: ['ADMIN'],
    handler: async ({ query }) => {
      const summary = await buildFinanceReportAsync(query.startDate || '', query.endDate || '');
      return ok({
        totalIncome: summary.totalIncome,
        totalRefund: summary.totalRefund,
        netIncome: summary.netIncome,
        orderCount: summary.orderCount,
        refundedOrderCount: summary.refundedOrderCount,
        dailyStats: summary.dailyStats
      });
    }
  },
  {
    method: 'GET',
    path: '/api/v1/reports/performance',
    roles: ['ADMIN'],
    handler: async ({ query }) => {
      return ok(await buildTeacherPerformanceAsync(query.startDate || '', query.endDate || ''));
    }
  },
  {
    method: 'GET',
    path: '/api/v1/reports/attendance/daily',
    roles: ['ADMIN'],
    handler: async ({ query }) => {
      return ok(await buildAttendanceDailyStatsAsync(query.startDate || '', query.endDate || ''));
    }
  },
  {
    method: 'GET',
    path: '/api/v1/reports/attendance/students',
    roles: ['ADMIN'],
    handler: async ({ query }) => {
      return ok(await buildStudentAttendanceSummaryAsync(query.startDate || '', query.endDate || ''));
    }
  },
  {
    method: 'GET',
    path: '/api/v1/reports/finance/daily',
    roles: ['ADMIN'],
    handler: async ({ query }) => {
      return ok(await buildDailyRevenueStatsAsync(query.startDate || '', query.endDate || ''));
    }
  },
  {
    method: 'GET',
    path: '/api/v1/reports/finance/products',
    roles: ['ADMIN'],
    handler: async ({ query }) => {
      return ok(await buildServiceProductRevenueAsync(query.startDate || '', query.endDate || ''));
    }
  },
  {
    method: 'GET',
    path: '/api/v1/reports/finance/summary-model',
    roles: ['ADMIN'],
    handler: async ({ query }) => {
      return ok(await buildFinanceSummaryModelAsync(query.startDate || '', query.endDate || ''));
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
