const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok } = require('../shared/router');
const { buildTodayStatusCardAsync, buildAbnormalAlertCardAsync } = require('../shared/read-models');
const { getScopedStudentIds, assertStudentAccess } = require('../shared/auth');
const { refreshFormCardsAsync } = require('../shared/events');
const { nowIso } = require('../shared/time');

async function getStudentId(query, auth) {
  if (query.studentId) {
    const studentId = Number(query.studentId);
    await assertStudentAccess(auth.user, studentId);
    return studentId;
  }
  const scopedStudentIds = await getScopedStudentIds(auth.user);
  if (scopedStudentIds.length > 0) {
    return scopedStudentIds[0];
  }
  return 0;
}

function hasTodayStatusPayload(payload) {
  return !!payload &&
    Number(payload.studentId || 0) > 0 &&
    !!payload.studentName &&
    !!payload.attendanceStatus;
}

async function getFreshTodayStatusCardAsync(studentId) {
  await refreshFormCardsAsync(studentId);
  const rows = await store.filterAsync('form_cards', (item) => {
    return item.cardType === 'TODAY_STATUS' && item.targetRole === 'PARENT' && Number(item.studentId || 0) === Number(studentId);
  });
  if (rows.length > 0 && hasTodayStatusPayload(rows[0].payload)) {
    return rows[0].payload;
  }
  return buildTodayStatusCardAsync(studentId);
}

function samePayload(left, right) {
  return JSON.stringify(left || null) === JSON.stringify(right || null);
}

async function getCachedCardAsync(cardType, studentId) {
  const rows = await store.filterAsync('form_cards', (item) => {
    return item.cardType === cardType && item.targetRole === 'PARENT' && Number(item.studentId || 0) === Number(studentId);
  });
  return rows.length > 0 ? rows[0] : null;
}

async function buildConsistencyAsync(studentId, refresh) {
  if (refresh) {
    await refreshFormCardsAsync(studentId);
  }

  const todayCache = await getCachedCardAsync('TODAY_STATUS', studentId);
  const abnormalCache = await getCachedCardAsync('ABNORMAL_ALERT', studentId);
  const todayFresh = await buildTodayStatusCardAsync(studentId);
  const abnormalFresh = await buildAbnormalAlertCardAsync(studentId);
  const todayConsistent = !!todayCache && hasTodayStatusPayload(todayCache.payload) && samePayload(todayCache.payload, todayFresh);
  const abnormalConsistent = (!abnormalCache && !abnormalFresh) || (!!abnormalCache && samePayload(abnormalCache.payload, abnormalFresh));

  return {
    studentId,
    checkedAt: nowIso(),
    consistent: todayConsistent && abnormalConsistent,
    todayStatus: {
      consistent: todayConsistent,
      cacheUpdatedAt: todayCache ? todayCache.updatedAt : '',
      cachedPayload: todayCache ? todayCache.payload : null,
      freshPayload: todayFresh
    },
    abnormalAlert: {
      consistent: abnormalConsistent,
      cacheUpdatedAt: abnormalCache ? abnormalCache.updatedAt : '',
      cachedPayload: abnormalCache ? abnormalCache.payload : null,
      freshPayload: abnormalFresh
    }
  };
}

const routes = [
  {
    method: 'GET',
    path: '/api/v1/cards/today-status',
    handler: async ({ query, auth }) => {
      const studentId = await getStudentId(query, auth);
      const cached = await store.filterAsync('form_cards', (item) => {
        return item.cardType === 'TODAY_STATUS' && item.targetRole === 'PARENT' && Number(item.studentId || 0) === Number(studentId);
      });
      if (cached.length > 0 && hasTodayStatusPayload(cached[0].payload)) {
        return ok(cached[0].payload);
      }
      return ok(await getFreshTodayStatusCardAsync(studentId));
    }
  },
  {
    method: 'GET',
    path: '/api/v1/cards/abnormal-alert',
    handler: async ({ query, auth }) => {
      const studentId = await getStudentId(query, auth);
      const cached = await store.filterAsync('form_cards', (item) => {
        return item.cardType === 'ABNORMAL_ALERT' && item.targetRole === 'PARENT' && Number(item.studentId || 0) === Number(studentId);
      });
      const card = cached.length > 0 ? cached[0].payload : await buildAbnormalAlertCardAsync(studentId);
      return ok(card);
    }
  },
  {
    method: 'GET',
    path: '/api/v1/cards/consistency',
    handler: async ({ query, auth }) => {
      const studentId = await getStudentId(query, auth);
      const refresh = query.refresh === true || query.refresh === 'true';
      return ok(await buildConsistencyAsync(studentId, refresh));
    }
  },
  {
    method: 'POST',
    path: '/api/v1/cards/refresh',
    handler: async ({ body, auth }) => {
      const studentId = await getStudentId(body, auth);
      return ok(await buildConsistencyAsync(studentId, true), 'form card cache refreshed');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
