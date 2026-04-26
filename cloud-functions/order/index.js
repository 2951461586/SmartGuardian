const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok, page } = require('../shared/router');
const { getOrderViewAsync, getStudentAsync, getServiceProductAsync } = require('../shared/read-models');
const { nowIso } = require('../shared/time');
const { badRequest, conflict, notFound } = require('../shared/errors');
const { filterOrdersForUser, assertStudentAccess } = require('../shared/auth');

function createOrderNo(id) {
  return `ORD-${new Date().toISOString().slice(0, 10).replace(/-/g, '')}-${String(id).padStart(3, '0')}`;
}

const routes = [
  {
    method: 'GET',
    path: '/api/v1/orders',
    handler: async ({ query, auth }) => {
      const items = await store.filterAsync('orders', (item) => {
        if (query.orderStatus && item.orderStatus !== query.orderStatus) {
          return false;
        }
        if (query.payStatus && item.payStatus !== query.payStatus) {
          return false;
        }
        if (query.studentId && Number(item.studentId) !== Number(query.studentId)) {
          return false;
        }
        return true;
      });
      const scopedOrders = await filterOrdersForUser(auth.user, items);
      const views = [];
      for (let i = 0; i < scopedOrders.length; i++) {
        views.push(await getOrderViewAsync(scopedOrders[i]));
      }
      views.sort((left, right) => right.createdAt.localeCompare(left.createdAt));
      const pageResult = store.paginate(views, query.pageNum, query.pageSize);
      return page(pageResult.list, pageResult.total, pageResult.pageNum, pageResult.pageSize);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/orders',
    roles: ['PARENT', 'ADMIN'],
    handler: async ({ body, auth }) => {
      await assertStudentAccess(auth.user, Number(body.studentId));
      const student = await getStudentAsync(Number(body.studentId));
      const service = await getServiceProductAsync(Number(body.serviceProductId));
      if (!student || !service) {
        throw badRequest('studentId or serviceProductId is invalid');
      }
      const createdAt = nowIso();
      const id = await store.nextIdAsync('orders');
      const totalAmount = Number(body.totalAmount || service.price);
      const discountAmount = Number(body.discountAmount || 0);
      const actualAmount = totalAmount - discountAmount;
      const order = await store.insertAsync('orders', {
        id,
        orderNo: createOrderNo(id),
        studentId: student.id,
        serviceProductId: service.id,
        orderStatus: 'PENDING',
        amount: actualAmount,
        paidAmount: 0,
        payStatus: 'UNPAID',
        auditStatus: 'PENDING',
        startDate: body.startDate || '',
        endDate: body.endDate || '',
        totalAmount,
        discountAmount,
        actualAmount,
        createdAt,
        updatedAt: createdAt
      });
      await store.insertAsync('order_items', {
        orderId: order.id,
        serviceProductId: service.id,
        quantity: 1,
        unitPrice: service.price,
        createdAt,
        updatedAt: createdAt
      });
      return ok(await getOrderViewAsync(order), 'order created');
    }
  },
  {
    method: 'GET',
    path: '/api/v1/orders/:orderId',
    handler: async ({ params, auth }) => {
      const order = await store.findByIdAsync('orders', Number(params.orderId));
      if (!order) {
        throw notFound('Order not found');
      }
      const scopedOrders = await filterOrdersForUser(auth.user, [order]);
      if (scopedOrders.length === 0) {
        throw notFound('Order not found');
      }
      return ok(await getOrderViewAsync(order));
    }
  },
  {
    method: 'POST',
    path: '/api/v1/orders/:orderId/audit',
    roles: ['ADMIN'],
    handler: async ({ params, body, auth }) => {
      const orderId = Number(params.orderId);
      const order = await store.findByIdAsync('orders', orderId);
      if (!order) {
        throw notFound('Order not found');
      }
      if (order.auditStatus === 'APPROVED' && body.auditStatus === 'APPROVED') {
        throw conflict('Order already approved');
      }
      const updated = await store.updateAsync('orders', orderId, {
        auditStatus: body.auditStatus,
        orderStatus: body.auditStatus === 'APPROVED' ? 'APPROVED' : 'REJECTED',
        auditTime: nowIso(),
        auditUserId: auth.user.id,
        auditRemark: body.auditRemark || '',
        updatedAt: nowIso()
      });
      await store.insertAsync('order_audits', {
        orderId,
        auditStatus: body.auditStatus,
        auditorId: auth.user.id,
        auditRemark: body.auditRemark || '',
        createdAt: nowIso(),
        updatedAt: nowIso()
      });
      return ok(await getOrderViewAsync(updated), 'order audited');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/orders/:orderId/refund',
    roles: ['PARENT', 'ADMIN'],
    handler: async ({ params, body, auth }) => {
      const orderId = Number(params.orderId);
      const order = await store.findByIdAsync('orders', orderId);
      if (!order) {
        throw notFound('Order not found');
      }
      const scopedOrders = await filterOrdersForUser(auth.user, [order]);
      if (scopedOrders.length === 0) {
        throw notFound('Order not found');
      }
      if (order.payStatus !== 'PAID') {
        throw conflict('Only paid orders can apply for refund');
      }
      const existing = await store.filterAsync('refunds', (item) => Number(item.orderId) === orderId && item.status !== 'CANCELLED');
      if (existing.length > 0) {
        throw conflict('Refund already exists for this order');
      }
      const student = await getStudentAsync(order.studentId);
      const service = await getServiceProductAsync(order.serviceProductId);
      const createdAt = nowIso();
      await store.insertAsync('refunds', {
        orderNo: order.orderNo,
        orderId,
        studentId: order.studentId,
        studentName: student ? student.name : '',
        serviceProductId: order.serviceProductId,
        serviceName: service ? service.serviceName : '',
        refundAmount: Number(body.refundAmount || order.actualAmount || order.amount),
        reason: body.refundReason || '',
        reasonType: 'OTHER',
        description: '',
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
      const updatedOrder = await store.updateAsync('orders', orderId, {
        payStatus: 'REFUNDING',
        updatedAt: createdAt
      });
      return ok(await getOrderViewAsync(updatedOrder), 'refund applied');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
