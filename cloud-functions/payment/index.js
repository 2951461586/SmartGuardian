const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok } = require('../shared/router');
const { nowIso } = require('../shared/time');
const { badRequest, notFound } = require('../shared/errors');
const { filterOrdersForUser } = require('../shared/auth');

function createPaymentNo(id) {
  return `PAY-${new Date().toISOString().slice(0, 10).replace(/-/g, '')}-${String(id).padStart(3, '0')}`;
}

const routes = [
  {
    method: 'POST',
    path: '/api/v1/payments',
    roles: ['PARENT', 'ADMIN'],
    handler: async ({ body, auth }) => {
      if (!body.orderId || !body.payChannel || !body.payAmount) {
        throw badRequest('payment params are incomplete');
      }
      const order = await store.findByIdAsync('orders', Number(body.orderId));
      if (!order) {
        throw notFound('Order not found');
      }
      const scopedOrders = await filterOrdersForUser(auth.user, [order]);
      if (scopedOrders.length === 0) {
        throw notFound('Order not found');
      }
      const createdAt = nowIso();
      const id = await store.nextIdAsync('payments');
      const payment = await store.insertAsync('payments', {
        id,
        orderId: Number(body.orderId),
        paymentNo: createPaymentNo(id),
        payChannel: body.payChannel,
        payAmount: Number(body.payAmount),
        payStatus: 'CREATED',
        payTime: '',
        expireTime: '',
        payUrl: `https://pay.smartguardian.local/pay/${id}`,
        qrCode: `SGPAY-${id}`,
        thirdTradeNo: '',
        createdAt,
        updatedAt: createdAt
      });
      return ok(payment, 'payment created');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/payments/callback',
    auth: false,
    handler: async ({ body }) => {
      const payments = await store.filterAsync('payments', (item) => item.paymentNo === body.paymentNo);
      if (payments.length === 0) {
        throw notFound('Payment not found');
      }
      const payment = payments[0];
      const payStatus = body.tradeStatus === 'SUCCESS' ? 'SUCCESS' : body.tradeStatus;
      const updated = await store.updateAsync('payments', payment.id, {
        payStatus,
        payTime: body.payTime || '',
        thirdTradeNo: body.thirdTradeNo || '',
        updatedAt: nowIso()
      });
      await store.insertAsync('payment_callbacks', {
        paymentId: payment.id,
        paymentNo: payment.paymentNo,
        tradeStatus: body.tradeStatus,
        thirdTradeNo: body.thirdTradeNo || '',
        payTime: body.payTime || '',
        rawPayload: body.rawPayload || '',
        createdAt: nowIso(),
        updatedAt: nowIso()
      });
      if (body.tradeStatus === 'SUCCESS') {
        await store.updateAsync('orders', payment.orderId, {
          payStatus: 'PAID',
          paidAmount: Number(updated.payAmount || 0),
          payTime: body.payTime || nowIso(),
          updatedAt: nowIso()
        });
      }
      return ok(null, 'payment callback handled');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
