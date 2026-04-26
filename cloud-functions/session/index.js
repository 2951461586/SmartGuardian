const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok } = require('../shared/router');
const { getSessionViewAsync, getSessionStudentsAsync, getServiceProductAsync } = require('../shared/read-models');
const { addDays, nowIso } = require('../shared/time');
const { badRequest, notFound } = require('../shared/errors');
const { filterSessionsForUser } = require('../shared/auth');

function createSessionNo(id) {
  return `SESS-${new Date().toISOString().slice(0, 10).replace(/-/g, '')}-${String(id).padStart(3, '0')}`;
}

const routes = [
  {
    method: 'GET',
    path: '/api/v1/sessions',
    handler: async ({ query, auth }) => {
      const sessions = await store.filterAsync('sessions', (item) => {
        if (query.sessionDate && item.sessionDate !== query.sessionDate) {
          return false;
        }
        if (query.teacherUserId && Number(item.teacherUserId || 0) !== Number(query.teacherUserId)) {
          return false;
        }
        if (query.serviceProductId && Number(item.serviceProductId) !== Number(query.serviceProductId)) {
          return false;
        }
        if (query.status && item.status !== query.status) {
          return false;
        }
        return true;
      });
      const scopedSessions = await filterSessionsForUser(auth.user, sessions);
      const views = [];
      for (let i = 0; i < scopedSessions.length; i++) {
        views.push(await getSessionViewAsync(scopedSessions[i]));
      }
      views.sort((left, right) => `${left.sessionDate} ${left.startTime}`.localeCompare(`${right.sessionDate} ${right.startTime}`));
      return ok(views);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/sessions',
    roles: ['ADMIN'],
    handler: async ({ body }) => {
      if (!body.serviceProductId || !body.sessionDate || !body.startTime || !body.endTime) {
        throw badRequest('serviceProductId, sessionDate, startTime and endTime are required');
      }
      const service = await getServiceProductAsync(Number(body.serviceProductId));
      if (!service) {
        throw badRequest('serviceProductId is invalid');
      }
      const createdAt = nowIso();
      const id = await store.nextIdAsync('sessions');
      const session = await store.insertAsync('sessions', {
        id,
        sessionDate: body.sessionDate,
        startTime: body.startTime,
        endTime: body.endTime,
        teacherUserId: Number(body.teacherUserId || 0),
        capacity: Number(body.capacity || body.maxCapacity || service.capacity || 0),
        currentCount: Number(body.currentCount || 0),
        sessionNo: createSessionNo(id),
        serviceProductId: Number(body.serviceProductId),
        maxCapacity: Number(body.maxCapacity || body.capacity || service.capacity || 0),
        location: body.location || '',
        status: body.status || 'SCHEDULED',
        createdAt,
        updatedAt: createdAt
      });
      return ok(await getSessionViewAsync(session), 'session created');
    }
  },
  {
    method: 'GET',
    path: '/api/v1/sessions/:sessionId',
    handler: async ({ params, auth }) => {
      const session = await store.findByIdAsync('sessions', Number(params.sessionId));
      if (!session) {
        throw notFound('Session not found');
      }
      const scopedSessions = await filterSessionsForUser(auth.user, [session]);
      if (scopedSessions.length === 0) {
        throw notFound('Session not found');
      }
      return ok({
        ...await getSessionViewAsync(session),
        students: await getSessionStudentsAsync(session.id)
      });
    }
  },
  {
    method: 'POST',
    path: '/api/v1/sessions/:sessionId',
    roles: ['ADMIN'],
    handler: async ({ params, body }) => {
      const updated = await store.updateAsync('sessions', Number(params.sessionId), {
        ...body,
        updatedAt: nowIso()
      });
      return ok(await getSessionViewAsync(updated), 'session updated');
    }
  },
  {
    method: 'PUT',
    path: '/api/v1/sessions/:sessionId',
    roles: ['ADMIN'],
    handler: async ({ params, body }) => {
      const updated = await store.updateAsync('sessions', Number(params.sessionId), {
        ...body,
        updatedAt: nowIso()
      });
      return ok(await getSessionViewAsync(updated), 'session updated');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/sessions/generate',
    roles: ['ADMIN'],
    handler: async ({ body }) => {
      if (!body.serviceProductId || !body.startDate || !body.endDate || !body.weekdays || !body.startTime || !body.endTime) {
        throw badRequest('generate schedule params are incomplete');
      }
      const created = [];
      let cursor = body.startDate;
      while (cursor <= body.endDate) {
        const weekday = new Date(`${cursor}T00:00:00.000Z`).getUTCDay();
        if (body.weekdays.indexOf(weekday) >= 0) {
          const nextId = await store.nextIdAsync('sessions');
          const session = await store.insertAsync('sessions', {
            id: nextId,
            sessionDate: cursor,
            startTime: body.startTime,
            endTime: body.endTime,
            teacherUserId: Number((body.teacherIds || [0])[0] || 0),
            capacity: Number(body.maxCapacity || 0),
            currentCount: 0,
            sessionNo: createSessionNo(nextId),
            serviceProductId: Number(body.serviceProductId),
            maxCapacity: Number(body.maxCapacity || 0),
            location: body.location || '',
            status: 'SCHEDULED',
            createdAt: nowIso(),
            updatedAt: nowIso()
          });
          created.push(await getSessionViewAsync(session));
        }
        cursor = addDays(cursor, 1);
      }
      return ok(created, 'sessions generated');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
