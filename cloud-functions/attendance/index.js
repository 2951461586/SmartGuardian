const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok, page } = require('../shared/router');
const { getAttendanceViewAsync } = require('../shared/read-models');
const { nowIso } = require('../shared/time');
const { badRequest } = require('../shared/errors');
const { filterAttendanceForUser, assertStudentAccess } = require('../shared/auth');

async function getOrCreateAttendance(studentId, sessionId, attendanceDate) {
  const existing = await store.filterAsync('attendance_records', (item) => {
    return Number(item.studentId) === Number(studentId) && Number(item.sessionId) === Number(sessionId) && item.attendanceDate === attendanceDate;
  });
  if (existing.length > 0) {
    return existing[0];
  }
  const createdAt = nowIso();
  return store.insertAsync('attendance_records', {
    studentId: Number(studentId),
    sessionId: Number(sessionId),
    signInTime: '',
    signOutTime: '',
    signInMethod: '',
    signOutMethod: '',
    signInLocation: '',
    signOutLocation: '',
    operatorUserId: 0,
    abnormalFlag: false,
    abnormalType: '',
    abnormalDesc: '',
    status: 'NOT_SIGNED',
    attendanceDate,
    createdAt,
    updatedAt: createdAt
  });
}

const routes = [
  {
    method: 'GET',
    path: '/api/v1/attendance',
    handler: async ({ query, auth }) => {
      const items = await store.filterAsync('attendance_records', (item) => {
        if (query.studentId && Number(item.studentId) !== Number(query.studentId)) {
          return false;
        }
        if (query.sessionId && Number(item.sessionId) !== Number(query.sessionId)) {
          return false;
        }
        if (query.attendanceDate && item.attendanceDate !== query.attendanceDate) {
          return false;
        }
        if (query.status && item.status !== query.status) {
          return false;
        }
        return true;
      });
      const scopedRecords = await filterAttendanceForUser(auth.user, items);
      const views = [];
      for (let i = 0; i < scopedRecords.length; i++) {
        views.push(await getAttendanceViewAsync(scopedRecords[i]));
      }
      const pageResult = store.paginate(views, query.pageNum, query.pageSize);
      return page(pageResult.list, pageResult.total, pageResult.pageNum, pageResult.pageSize);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/attendance/sign-in',
    roles: ['TEACHER', 'ADMIN'],
    handler: async ({ body, auth }) => {
      if (!body.studentId || !body.sessionId) {
        throw badRequest('studentId and sessionId are required');
      }
      const session = await store.requireByIdAsync('sessions', Number(body.sessionId));
      const baseRecord = await getOrCreateAttendance(body.studentId, body.sessionId, session.sessionDate);
      const updated = await store.updateAsync('attendance_records', baseRecord.id, {
        signInTime: nowIso(),
        signInMethod: body.signMethod || 'MANUAL',
        signInLocation: body.location || '',
        operatorUserId: auth.user.id,
        abnormalFlag: body.signInType === 'LATE',
        abnormalType: body.signInType === 'LATE' ? 'LATE_SIGN_IN' : '',
        abnormalDesc: body.signInType === 'LATE' ? 'late sign in' : '',
        status: body.signInType === 'LATE' ? 'LATE' : 'SIGNED_IN',
        updatedAt: nowIso()
      });
      return ok(await getAttendanceViewAsync(updated), 'signed in');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/attendance/sign-out',
    roles: ['TEACHER', 'ADMIN'],
    handler: async ({ body, auth }) => {
      if (!body.studentId || !body.sessionId) {
        throw badRequest('studentId and sessionId are required');
      }
      const session = await store.requireByIdAsync('sessions', Number(body.sessionId));
      const baseRecord = await getOrCreateAttendance(body.studentId, body.sessionId, session.sessionDate);
      const updated = await store.updateAsync('attendance_records', baseRecord.id, {
        signOutTime: nowIso(),
        signOutMethod: body.signMethod || 'MANUAL',
        signOutLocation: body.location || '',
        operatorUserId: auth.user.id,
        status: 'SIGNED_OUT',
        updatedAt: nowIso()
      });
      return ok(await getAttendanceViewAsync(updated), 'signed out');
    }
  },
  {
    method: 'GET',
    path: '/api/v1/attendance/abnormal-events',
    roles: ['TEACHER', 'ADMIN'],
    handler: async ({ query }) => {
      const items = await store.filterAsync('attendance_records', (item) => item.abnormalFlag === true);
      const views = [];
      for (let i = 0; i < items.length; i++) {
        views.push(await getAttendanceViewAsync(items[i]));
      }
      const pageResult = store.paginate(views, query.pageNum, query.pageSize);
      return page(pageResult.list, pageResult.total, pageResult.pageNum, pageResult.pageSize);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/attendance/leave',
    roles: ['PARENT', 'ADMIN'],
    handler: async ({ body, auth }) => {
      if (!body.studentId || !body.leaveDate || !body.leaveType || !body.reason) {
        throw badRequest('leave params are incomplete');
      }
      await assertStudentAccess(auth.user, Number(body.studentId));
      const createdAt = nowIso();
      const leave = await store.insertAsync('leave_requests', {
        studentId: Number(body.studentId),
        leaveDate: body.leaveDate,
        leaveType: body.leaveType,
        reason: body.reason,
        attachments: body.attachments || [],
        status: 'PENDING',
        reviewerId: 0,
        reviewRemark: '',
        reviewedAt: '',
        createdAt,
        updatedAt: createdAt
      });
      return ok(leave, 'leave submitted');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
