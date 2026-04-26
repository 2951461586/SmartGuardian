const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok, page } = require('../shared/router');
const { buildRefundStatisticsAsync, getRefundViewAsync, getOrderViewAsync } = require('../shared/read-models');
const { nowIso } = require('../shared/time');
const { badRequest, notFound } = require('../shared/errors');
const { filterRefundsForUser, filterOrdersForUser } = require('../shared/auth');

const routes = [
  {
    method: 'GET',
    path: '/api/v1/refunds',
    handler: async ({ query, auth }) => {
      const items = await store.filterAsync('refunds', (item) => {
        if (query.orderId && Number(item.orderId) !== Number(query.orderId)) {
          return false;
        }
        if (query.studentId && Number(item.studentId) !== Number(query.studentId)) {
          return false;
        }
        if (query.status && item.status !== query.status) {
          return false;
        }
        return true;
      });
      const scopedRefunds = await filterRefundsForUser(auth.user, items);
      const views = [];
      for (let i = 0; i < scopedRefunds.length; i++) {
        views.push(await getRefundViewAsync(scopedRefunds[i]));
      }
      views.sort((left, right) => right.createdAt.localeCompare(left.createdAt));
      const pageResult = store.paginate(views, query.pageNum, query.pageSize);
      return page(pageResult.list, pageResult.total, pageResult.pageNum, pageResult.pageSize);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/refunds',
    roles: ['PARENT', 'ADMIN'],
    handler: async ({ body, auth }) => {
      if (!body.orderId || !body.refundAmount || !body.reasonType || !body.reason) {
        throw badRequest('refund params are incomplete');
      }
      const order = await store.findByIdAsync('orders', Number(body.orderId));
      if (!order) {
        throw notFound('Order not found');
      }
      const scopedOrders = await filterOrdersForUser(auth.user, [order]);
      if (scopedOrders.length === 0) {
        throw notFound('Order not found');
      }
      const orderView = await getOrderViewAsync(order);
      const createdAt = nowIso();
      const refund = await store.insertAsync('refunds', {
        orderNo: order.orderNo,
        orderId: order.id,
        studentId: order.studentId,
        studentName: orderView.studentName,
        serviceProductId: order.serviceProductId,
        serviceName: orderView.serviceProductName,
        refundAmount: Number(body.refundAmount),
        reason: body.reason,
        reasonType: body.reasonType,
        description: body.description || '',
        status: 'PENDING',
        appliedAt: createdAt,
        reviewedBy: 0,
        reviewedAt: '',
        reviewRemark: '',
        processedAt: '',
        completedAt: '',
        createdAt,
        updatedAt: createdAt
      });
      await store.updateAsync('orders', order.id, {
        payStatus: 'REFUNDING',
        updatedAt: createdAt
      });
      return ok(await getRefundViewAsync(refund), 'refund created');
    }
  },
  {
    method: 'GET',
    path: '/api/v1/refunds/statistics',
    roles: ['ADMIN'],
    handler: async () => {
      return ok(await buildRefundStatisticsAsync());
    }
  },
  {
    method: 'GET',
    path: '/api/v1/refunds/calculate',
    handler: async ({ query, auth }) => {
      const order = await store.findByIdAsync('orders', Number(query.orderId || 0));
      if (!order) {
        throw notFound('Order not found');
      }
      const scopedOrders = await filterOrdersForUser(auth.user, [order]);
      if (scopedOrders.length === 0) {
        throw notFound('Order not found');
      }
      const refundableAmount = Number(order.actualAmount || order.amount || 0) * 0.8;
      return ok({
        refundable: true,
        refundAmount: Math.round(refundableAmount * 100) / 100,
        deduction: Math.round((Number(order.actualAmount || order.amount || 0) - refundableAmount) * 100) / 100,
        reason: 'calculated with 80 percent refund rate'
      });
    }
  },
  {
    method: 'GET',
    path: '/api/v1/refunds/order/:orderId',
    handler: async ({ params, auth }) => {
      const items = await store.filterAsync('refunds', (item) => Number(item.orderId) === Number(params.orderId));
      const scopedRefunds = await filterRefundsForUser(auth.user, items);
      const views = [];
      for (let i = 0; i < scopedRefunds.length; i++) {
        views.push(await getRefundViewAsync(scopedRefunds[i]));
      }
      return ok(views);
    }
  },
  {
    method: 'GET',
    path: '/api/v1/refunds/:refundId',
    handler: async ({ params, auth }) => {
      const refund = await store.findByIdAsync('refunds', Number(params.refundId));
      if (!refund) {
        throw notFound('Refund not found');
      }
      const scopedRefunds = await filterRefundsForUser(auth.user, [refund]);
      if (scopedRefunds.length === 0) {
        throw notFound('Refund not found');
      }
      return ok(await getRefundViewAsync(refund));
    }
  },
  {
    method: 'POST',
    path: '/api/v1/refunds/:refundId/cancel',
    roles: ['PARENT', 'ADMIN'],
    handler: async ({ params, body, auth }) => {
      const refund = await store.findByIdAsync('refunds', Number(params.refundId));
      if (!refund) {
        throw notFound('Refund not found');
      }
      const scopedRefunds = await filterRefundsForUser(auth.user, [refund]);
      if (scopedRefunds.length === 0) {
        throw notFound('Refund not found');
      }
      const updated = await store.updateAsync('refunds', refund.id, {
        status: 'CANCELLED',
        reviewRemark: body.reason || '',
        updatedAt: nowIso()
      });
      return ok(updated, 'refund cancelled');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
