const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok } = require('../shared/router');
const { getServiceProductViewAsync } = require('../shared/read-models');
const { nowIso } = require('../shared/time');
const { badRequest, notFound } = require('../shared/errors');

const routes = [
  {
    method: 'GET',
    path: '/api/v1/service-products',
    handler: async ({ query }) => {
      const status = query.status || '';
      const serviceType = query.serviceType || '';
      const products = await store.filterAsync('service_products', (item) => {
        if (status && item.status !== status) {
          return false;
        }
        if (serviceType && item.serviceType !== serviceType) {
          return false;
        }
        return true;
      });
      const views = [];
      for (let i = 0; i < products.length; i++) {
        views.push(await getServiceProductViewAsync(products[i]));
      }
      return ok(views);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/service-products',
    roles: ['ADMIN'],
    handler: async ({ body, auth }) => {
      if (!body.serviceName || !body.serviceType || body.price === undefined || body.price === null) {
        throw badRequest('serviceName, serviceType and price are required');
      }
      const createdAt = nowIso();
      const product = await store.insertAsync('service_products', {
        serviceName: body.serviceName,
        serviceType: body.serviceType,
        description: body.description || '',
        price: Number(body.price || 0),
        unit: body.unit || 'MONTH',
        gradeRange: body.gradeRange || '',
        capacity: Number(body.capacity || body.maxStudents || 0),
        maxStudents: Number(body.maxStudents || body.capacity || 0),
        currentStudents: 0,
        serviceStartDate: body.serviceStartDate || '',
        serviceEndDate: body.serviceEndDate || '',
        signInStartTime: body.signInStartTime || '',
        signInEndTime: body.signInEndTime || '',
        signOutStartTime: body.signOutStartTime || '',
        signOutEndTime: body.signOutEndTime || '',
        orgId: Number(auth.user.orgId || 1),
        orgName: 'SmartGuardian Org',
        status: 'ACTIVE',
        createdAt,
        updatedAt: createdAt
      });
      return ok(await getServiceProductViewAsync(product), 'service created');
    }
  },
  {
    method: 'GET',
    path: '/api/v1/service-products/:serviceId',
    handler: async ({ params }) => {
      const product = await store.findByIdAsync('service_products', Number(params.serviceId));
      if (!product) {
        throw notFound('Service product not found');
      }
      return ok(await getServiceProductViewAsync(product));
    }
  },
  {
    method: 'PUT',
    path: '/api/v1/service-products/:serviceId',
    roles: ['ADMIN'],
    handler: async ({ params, body }) => {
      const product = await store.updateAsync('service_products', Number(params.serviceId), {
        ...body,
        updatedAt: nowIso()
      });
      return ok(await getServiceProductViewAsync(product), 'service updated');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
