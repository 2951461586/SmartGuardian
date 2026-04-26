const store = require('./store');
const { addHoursFromNow, nowIso } = require('./time');
const { unauthorized, forbidden } = require('./errors');

function getTokenFromRequest(request) {
  const header = request.headers.Authorization || request.headers.authorization || '';
  if (header.indexOf('Bearer ') === 0) {
    return header.slice(7);
  }
  return '';
}

function sanitizeUser(user) {
  return {
    id: user.id,
    username: user.username,
    realName: user.realName,
    mobile: user.mobile,
    roleType: user.roleType,
    avatar: user.avatar || '',
    orgId: user.orgId,
    schoolId: user.schoolId
  };
}

async function createSession(userId) {
  const createdAt = nowIso();
  const token = `sg-token-${userId}-${Date.now()}`;
  const session = await store.insertAsync('user_sessions', {
    userId,
    token,
    sessionStatus: 'ACTIVE',
    expireAt: addHoursFromNow(24),
    createdAt,
    updatedAt: createdAt
  });
  return session;
}

async function resolveSession(request) {
  const token = getTokenFromRequest(request);
  if (!token) {
    return null;
  }
  const sessions = await store.filterAsync('user_sessions', (session) => {
    return session.token === token && session.sessionStatus === 'ACTIVE';
  });
  if (sessions.length === 0) {
    return null;
  }
  const session = sessions[0];
  if (session.expireAt <= nowIso()) {
    await store.updateAsync('user_sessions', session.id, {
      sessionStatus: 'EXPIRED',
      updatedAt: nowIso()
    });
    return null;
  }
  return session;
}

async function requireUser(request) {
  const session = await resolveSession(request);
  if (!session) {
    throw unauthorized('Session expired or missing');
  }
  const user = await store.requireByIdAsync('users', session.userId);
  return {
    session,
    user: sanitizeUser(user)
  };
}

function hasRole(user, roles) {
  if (!roles || roles.length === 0) {
    return true;
  }
  return roles.indexOf(user.roleType) >= 0;
}

function assertRole(user, roles) {
  if (!hasRole(user, roles)) {
    throw forbidden(`Role ${user.roleType} is not allowed`);
  }
}

function isParent(user) {
  return user.roleType === 'PARENT';
}

function isTeacher(user) {
  return user.roleType === 'TEACHER';
}

function isAdmin(user) {
  return user.roleType === 'ADMIN';
}

async function getScopedStudentIds(user) {
  if (isAdmin(user) || isTeacher(user)) {
    const students = await store.listAsync('students');
    return students.map((student) => Number(student.id));
  }

  const directStudents = await store.filterAsync('students', (student) => Number(student.guardianUserId || 0) === Number(user.id));
  const relationRows = await store.filterAsync('student_guardians', (relation) => Number(relation.userId || 0) === Number(user.id));
  const idMap = {};

  for (let i = 0; i < directStudents.length; i++) {
    idMap[Number(directStudents[i].id)] = true;
  }
  for (let i = 0; i < relationRows.length; i++) {
    idMap[Number(relationRows[i].studentId)] = true;
  }

  return Object.keys(idMap).map((value) => Number(value));
}

async function canAccessStudent(user, studentId) {
  if (isAdmin(user) || isTeacher(user)) {
    return true;
  }
  const scopedIds = await getScopedStudentIds(user);
  return scopedIds.indexOf(Number(studentId)) >= 0;
}

async function assertStudentAccess(user, studentId) {
  if (!(await canAccessStudent(user, studentId))) {
    throw forbidden(`User ${user.id} cannot access student ${studentId}`);
  }
}

async function filterStudentsForUser(user, students) {
  if (isAdmin(user) || isTeacher(user)) {
    return students;
  }
  const scopedIds = await getScopedStudentIds(user);
  return students.filter((student) => scopedIds.indexOf(Number(student.id)) >= 0);
}

async function filterOrdersForUser(user, orders) {
  if (isAdmin(user) || isTeacher(user)) {
    return orders;
  }
  const scopedIds = await getScopedStudentIds(user);
  return orders.filter((order) => scopedIds.indexOf(Number(order.studentId)) >= 0);
}

async function filterSessionsForUser(user, sessions) {
  if (isAdmin(user)) {
    return sessions;
  }
  if (isTeacher(user)) {
    return sessions.filter((session) => Number(session.teacherUserId || 0) === Number(user.id));
  }

  const scopedIds = await getScopedStudentIds(user);
  const roster = await store.listAsync('session_students');
  const allowedSessionMap = {};
  for (let i = 0; i < roster.length; i++) {
    if (scopedIds.indexOf(Number(roster[i].studentId)) >= 0) {
      allowedSessionMap[Number(roster[i].sessionId)] = true;
    }
  }
  return sessions.filter((session) => allowedSessionMap[Number(session.id)] === true);
}

async function filterAttendanceForUser(user, records) {
  if (isAdmin(user) || isTeacher(user)) {
    return records;
  }
  const scopedIds = await getScopedStudentIds(user);
  return records.filter((record) => scopedIds.indexOf(Number(record.studentId)) >= 0);
}

async function filterHomeworkForUser(user, tasks) {
  if (isAdmin(user)) {
    return tasks;
  }
  if (isTeacher(user)) {
    return tasks.filter((task) => Number(task.teacherId || 0) === Number(user.id));
  }
  const scopedIds = await getScopedStudentIds(user);
  return tasks.filter((task) => scopedIds.indexOf(Number(task.studentId)) >= 0);
}

async function filterRefundsForUser(user, refunds) {
  if (isAdmin(user) || isTeacher(user)) {
    return refunds;
  }
  const scopedIds = await getScopedStudentIds(user);
  return refunds.filter((refund) => scopedIds.indexOf(Number(refund.studentId)) >= 0);
}

module.exports = {
  createSession,
  requireUser,
  sanitizeUser,
  hasRole,
  assertRole,
  isParent,
  isTeacher,
  isAdmin,
  getScopedStudentIds,
  canAccessStudent,
  assertStudentAccess,
  filterStudentsForUser,
  filterOrdersForUser,
  filterSessionsForUser,
  filterAttendanceForUser,
  filterHomeworkForUser,
  filterRefundsForUser
};
