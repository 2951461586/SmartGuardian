const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok } = require('../shared/router');
const { sanitizeUser } = require('../shared/auth');
const { notFound } = require('../shared/errors');

const routes = [
  {
    method: 'GET',
    path: '/api/v1/auth/me',
    handler: async ({ auth }) => {
      return ok(auth.user);
    }
  },
  {
    method: 'GET',
    path: '/api/v1/users',
    roles: ['ADMIN'],
    handler: async ({ query }) => {
      const roleType = query.roleType || '';
      const items = await store.filterAsync('users', (item) => {
        return !roleType || item.roleType === roleType;
      });
      const users = items.map((item) => sanitizeUser(item));
      return ok(users);
    }
  },
  {
    method: 'GET',
    path: '/api/v1/users/:userId',
    roles: ['ADMIN'],
    handler: async ({ params }) => {
      const user = await store.findByIdAsync('users', Number(params.userId));
      if (!user) {
        throw notFound('User not found');
      }
      return ok(sanitizeUser(user));
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
