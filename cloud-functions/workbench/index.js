const contract = require('./contract.json');
const { createDomainHandler, ok } = require('../shared/router');
const { buildWorkbenchAsync } = require('../shared/read-models');

const routes = [
  {
    method: 'GET',
    path: '/api/v1/workbench/manifest',
    handler: async ({ auth }) => {
      const manifest = await buildWorkbenchAsync(auth.user.roleType);
      return ok(manifest);
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
