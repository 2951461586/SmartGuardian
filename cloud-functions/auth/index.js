const contract = require('./contract.json');
const store = require('../shared/store');
const { createSession, requireUser } = require('../shared/auth');
const { createDomainHandler, detail, command } = require('../shared/router');
const { unauthorized } = require('../shared/errors');
const { nowIso } = require('../shared/time');
const { sanitizeUser } = require('../shared/auth');

const routes = [
  {
    method: 'POST',
    path: '/api/v1/auth/login',
    auth: false,
    bodyRules: [
      { name: 'username', required: true, type: 'string' },
      { name: 'password', required: true, type: 'string' }
    ],
    handler: async ({ body }) => {
      const username = body.username || '';
      const password = body.password || '';
      const roleType = body.roleType || '';

      const usersFromStore = await store.filterAsync('users', (item) => {
        return (item.username === username || item.mobile === username) && item.password === password && item.status === 'ACTIVE';
      });
      const candidates = usersFromStore;
      if (candidates.length === 0) {
        throw unauthorized('Invalid username or password');
      }

      const user = candidates[0];
      if (roleType && user.roleType !== roleType) {
        throw unauthorized('Selected role does not match the account');
      }

      const session = await createSession(user.id);
      return detail({
        token: session.token,
        expiresIn: 86400,
        userInfo: sanitizeUser(user)
      }, 'login success');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/auth/session-device',
    bodyRules: [
      { name: 'deviceId', required: true, type: 'string' },
      { name: 'notificationToken', required: true, type: 'string' },
      { name: 'notificationProvider', required: true, type: 'string' }
    ],
    handler: async ({ request, body }) => {
      const auth = await requireUser(request);
      const deviceId = body.deviceId || '';
      const notificationToken = body.notificationToken || '';
      const notificationProvider = body.notificationProvider || '';
      const authUid = body.authUid || '';
      const authPhone = body.authPhone || '';
      const clientVersion = body.clientVersion || '';
      const clientPlatform = body.clientPlatform || '';

      const updatedAt = nowIso();
      const updatedSession = await store.updateAsync('user_sessions', auth.session.id, {
        deviceId,
        notificationToken,
        notificationProvider,
        authUid,
        authPhone,
        clientVersion,
        clientPlatform,
        lastActiveAt: updatedAt,
        updatedAt
      });

      return command({
        sessionId: updatedSession.id,
        userId: updatedSession.userId,
        deviceId: updatedSession.deviceId || '',
        notificationProvider: updatedSession.notificationProvider || '',
        notificationTokenBound: !!updatedSession.notificationToken,
        authUid: updatedSession.authUid || '',
        lastActiveAt: updatedSession.lastActiveAt || '',
        persisted: true,
        compatibilityMode: ''
      }, 'session device bound');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/auth/logout',
    handler: async ({ request }) => {
      const auth = await requireUser(request);
      await store.updateAsync('user_sessions', auth.session.id, {
        sessionStatus: 'LOGGED_OUT',
        updatedAt: nowIso()
      });
      return command(null, 'logout success');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/auth/refresh',
    handler: async ({ request }) => {
      const auth = await requireUser(request);
      await store.updateAsync('user_sessions', auth.session.id, {
        sessionStatus: 'EXPIRED',
        updatedAt: nowIso()
      });
      const session = await createSession(auth.user.id);
      return detail({
        token: session.token,
        expiresIn: 86400,
        userInfo: auth.user
      }, 'refresh success');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
