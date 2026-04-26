const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok, page } = require('../shared/router');
const { getMessageDetailViewAsync, buildMessageStatisticsAsync } = require('../shared/read-models');
const { nowIso } = require('../shared/time');
const { badRequest, notFound } = require('../shared/errors');

async function markMessageRead(messageId) {
  const message = await store.findByIdAsync('messages', messageId);
  if (!message) {
    throw notFound('Message not found');
  }
  return store.updateAsync('messages', messageId, {
    readStatus: true,
    readAt: nowIso(),
    updatedAt: nowIso()
  });
}

const routes = [
  {
    method: 'GET',
    path: '/api/v1/messages',
    handler: async ({ query, auth }) => {
      const items = await store.filterAsync('messages', (item) => {
        if (Number(item.userId) !== Number(auth.user.id)) {
          return false;
        }
        if (query.msgType && item.msgType !== query.msgType) {
          return false;
        }
        if (query.readStatus !== undefined && String(item.readStatus) !== String(query.readStatus)) {
          return false;
        }
        return true;
      });
      items.sort((left, right) => right.createdAt.localeCompare(left.createdAt));
      const pageResult = store.paginate(items, query.pageNum, query.pageSize);
      return page(pageResult.list, pageResult.total, pageResult.pageNum, pageResult.pageSize);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/messages',
    roles: ['ADMIN', 'TEACHER'],
    handler: async ({ body, auth }) => {
      if ((body.userId === undefined || body.userId === null) || !body.msgType || !body.title || !body.content) {
        throw badRequest('message params are incomplete');
      }
      const createdAt = nowIso();
      const targetUserIds = [];
      if (Number(body.userId) === 0) {
        const users = await store.filterAsync('users', (item) => {
          if (item.status !== 'ACTIVE') {
            return false;
          }
          if (Number(item.orgId || 0) !== Number(auth.user.orgId || 0)) {
            return false;
          }
          return Number(item.id) !== Number(auth.user.id);
        });
        for (let i = 0; i < users.length; i++) {
          targetUserIds.push(Number(users[i].id));
        }
      } else {
        targetUserIds.push(Number(body.userId));
      }

      if (targetUserIds.length === 0) {
        throw badRequest('No active recipients matched the message target');
      }

      const createdMessages = [];
      for (let i = 0; i < targetUserIds.length; i++) {
        const message = await store.insertAsync('messages', {
          userId: targetUserIds[i],
          msgType: body.msgType,
          title: body.title,
          content: body.content,
          bizType: body.bizType || '',
          bizId: Number(body.bizId || 0),
          readStatus: false,
          readAt: '',
          createdAt,
          updatedAt: createdAt
        });
        createdMessages.push(message);
      }

      return ok(createdMessages[0], `message sent to ${createdMessages.length} recipient(s)`);
    }
  },
  {
    method: 'GET',
    path: '/api/v1/messages/unread-count',
    handler: async ({ auth }) => {
      const messages = await store.filterAsync('messages', (item) => Number(item.userId) === Number(auth.user.id) && !item.readStatus);
      return ok({ count: messages.length });
    }
  },
  {
    method: 'GET',
    path: '/api/v1/messages/statistics',
    handler: async ({ auth }) => {
      return ok(await buildMessageStatisticsAsync(auth.user.id));
    }
  },
  {
    method: 'POST',
    path: '/api/v1/messages/batch-read',
    handler: async ({ body, auth }) => {
      const messageIds = body.messageIds || [];
      for (let i = 0; i < messageIds.length; i++) {
        const target = await store.findByIdAsync('messages', Number(messageIds[i]));
        if (target && Number(target.userId) === Number(auth.user.id)) {
          await markMessageRead(target.id);
        }
      }
      return ok(null, 'messages marked as read');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/messages/read-all',
    handler: async ({ auth }) => {
      const messages = await store.filterAsync('messages', (item) => Number(item.userId) === Number(auth.user.id) && !item.readStatus);
      for (let i = 0; i < messages.length; i++) {
        await markMessageRead(messages[i].id);
      }
      return ok(null, 'all messages marked as read');
    }
  },
  {
    method: 'GET',
    path: '/api/v1/messages/:messageId',
    handler: async ({ params, auth }) => {
      const message = await store.findByIdAsync('messages', Number(params.messageId));
      if (!message || Number(message.userId) !== Number(auth.user.id)) {
        throw notFound('Message not found');
      }
      return ok(await getMessageDetailViewAsync(message));
    }
  },
  {
    method: 'POST',
    path: '/api/v1/messages/:messageId/read',
    handler: async ({ params, auth }) => {
      const message = await store.findByIdAsync('messages', Number(params.messageId));
      if (!message || Number(message.userId) !== Number(auth.user.id)) {
        throw notFound('Message not found');
      }
      return ok(await markMessageRead(message.id), 'message marked as read');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/messages/:messageId/delete',
    handler: async ({ params, auth }) => {
      const message = await store.findByIdAsync('messages', Number(params.messageId));
      if (!message || Number(message.userId) !== Number(auth.user.id)) {
        throw notFound('Message not found');
      }
      await store.removeAsync('messages', message.id);
      return ok(null, 'message deleted');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
