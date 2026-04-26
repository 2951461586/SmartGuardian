const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok, page } = require('../shared/router');
const { getStudentViewAsync } = require('../shared/read-models');
const { nowIso } = require('../shared/time');
const { badRequest, notFound } = require('../shared/errors');
const { filterStudentsForUser, assertStudentAccess } = require('../shared/auth');

const routes = [
  {
    method: 'GET',
    path: '/api/v1/students',
    handler: async ({ query, auth }) => {
      const keyword = query.keyword || '';
      const classId = query.classId ? Number(query.classId) : 0;
      const students = await store.filterAsync('students', (item) => {
        if (keyword && item.name.indexOf(keyword) < 0 && item.studentNo.indexOf(keyword) < 0) {
          return false;
        }
        if (classId && Number(item.classId) !== classId) {
          return false;
        }
        return true;
      });
      const scopedStudents = await filterStudentsForUser(auth.user, students);
      const views = [];
      for (let i = 0; i < scopedStudents.length; i++) {
        views.push(await getStudentViewAsync(scopedStudents[i]));
      }
      const pageResult = store.paginate(views, query.pageNum, query.pageSize);
      return page(pageResult.list, pageResult.total, pageResult.pageNum, pageResult.pageSize);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/students',
    roles: ['ADMIN'],
    handler: async ({ body, auth }) => {
      if (!body.name || !body.studentNo || !body.guardianUserId) {
        throw badRequest('studentNo, name and guardianUserId are required');
      }
      const createdAt = nowIso();
      const student = await store.insertAsync('students', {
        studentNo: body.studentNo,
        name: body.name,
        schoolId: Number(body.schoolId || auth.user.schoolId || 1001),
        classId: body.classId ? Number(body.classId) : 0,
        className: body.className || '',
        grade: body.grade || '',
        gender: body.gender || 'MALE',
        birthDate: body.birthDate || '',
        guardianUserId: Number(body.guardianUserId),
        healthNotes: body.healthNotes || '',
        orgId: Number(auth.user.orgId || 1),
        status: 'ACTIVE',
        schoolName: '智慧实验小学',
        createdAt,
        updatedAt: createdAt
      });
      return ok(await getStudentViewAsync(student), 'student created');
    }
  },
  {
    method: 'GET',
    path: '/api/v1/students/:studentId',
    handler: async ({ params, auth }) => {
      const studentId = Number(params.studentId);
      await assertStudentAccess(auth.user, studentId);
      const student = await store.findByIdAsync('students', studentId);
      if (!student) {
        throw notFound('Student not found');
      }
      return ok(await getStudentViewAsync(student));
    }
  },
  {
    method: 'PUT',
    path: '/api/v1/students/:studentId',
    roles: ['ADMIN'],
    handler: async ({ params, body }) => {
      const updated = await store.updateAsync('students', Number(params.studentId), {
        ...body,
        updatedAt: nowIso()
      });
      return ok(await getStudentViewAsync(updated), 'student updated');
    }
  },
  {
    method: 'GET',
    path: '/api/v1/students/:studentId/guardians',
    handler: async ({ params, auth }) => {
      const studentId = Number(params.studentId);
      await assertStudentAccess(auth.user, studentId);
      const relationRows = await store.filterAsync('student_guardians', (item) => Number(item.studentId) === studentId);
      const relations = [];
      for (let i = 0; i < relationRows.length; i++) {
        const item = relationRows[i];
        const user = await store.findByIdAsync('users', item.userId);
        relations.push({
          ...item,
          guardianName: user ? user.realName : '',
          guardianMobile: user ? user.mobile : ''
        });
      }
      return ok(relations);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/students/:studentId/guardians',
    roles: ['ADMIN'],
    handler: async ({ params, body }) => {
      const studentId = Number(params.studentId);
      if (!body.userId || !body.relation) {
        throw badRequest('userId and relation are required');
      }
      const createdAt = nowIso();
      const relation = await store.insertAsync('student_guardians', {
        studentId,
        userId: Number(body.userId),
        relation: body.relation,
        isPrimary: Boolean(body.isPrimary),
        authorizedPickup: Boolean(body.authorizedPickup),
        pickupCode: body.pickupCode || `PK-${studentId}-${Date.now().toString().slice(-4)}`,
        createdAt,
        updatedAt: createdAt
      });
      return ok(relation, 'guardian bound');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
