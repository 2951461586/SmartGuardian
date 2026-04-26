const contract = require('./contract.json');
const store = require('../shared/store');
const { createDomainHandler, ok, page } = require('../shared/router');
const { getHomeworkTaskViewAsync, getHomeworkFeedbackViewAsync } = require('../shared/read-models');
const { nowIso } = require('../shared/time');
const { badRequest, notFound } = require('../shared/errors');
const { filterHomeworkForUser, assertStudentAccess } = require('../shared/auth');

const routes = [
  {
    method: 'GET',
    path: '/api/v1/homework/tasks',
    handler: async ({ query, auth }) => {
      const items = await store.filterAsync('homework_tasks', (item) => {
        if (query.studentId && Number(item.studentId) !== Number(query.studentId)) {
          return false;
        }
        if (query.status && item.status !== query.status) {
          return false;
        }
        if (query.taskDate && item.taskDate !== query.taskDate) {
          return false;
        }
        if (query.sessionId && Number(item.sessionId || 0) !== Number(query.sessionId)) {
          return false;
        }
        return true;
      });
      const scopedTasks = await filterHomeworkForUser(auth.user, items);
      const views = [];
      for (let i = 0; i < scopedTasks.length; i++) {
        views.push(await getHomeworkTaskViewAsync(scopedTasks[i]));
      }
      views.sort((left, right) => right.taskDate.localeCompare(left.taskDate));
      const pageResult = store.paginate(views, query.pageNum, query.pageSize);
      return page(pageResult.list, pageResult.total, pageResult.pageNum, pageResult.pageSize);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/homework/tasks',
    roles: ['TEACHER', 'ADMIN'],
    handler: async ({ body, auth }) => {
      if (!body.studentId || !body.taskDate || !body.subject || !body.title) {
        throw badRequest('homework task params are incomplete');
      }
      const createdAt = nowIso();
      const task = await store.insertAsync('homework_tasks', {
        studentId: Number(body.studentId),
        taskDate: body.taskDate,
        subject: body.subject,
        title: body.title,
        content: body.content || '',
        sourceType: body.sourceType || 'TEACHER',
        status: 'PENDING',
        taskNo: `HW-${Date.now()}`,
        sessionId: Number(body.sessionId || 0),
        teacherId: auth.user.id,
        attachments: body.attachments || [],
        completedTime: '',
        createdAt,
        updatedAt: createdAt
      });
      return ok(await getHomeworkTaskViewAsync(task), 'task created');
    }
  },
  {
    method: 'GET',
    path: '/api/v1/homework/tasks/:taskId',
    handler: async ({ params, auth }) => {
      const task = await store.findByIdAsync('homework_tasks', Number(params.taskId));
      if (!task) {
        throw notFound('Homework task not found');
      }
      const scopedTasks = await filterHomeworkForUser(auth.user, [task]);
      if (scopedTasks.length === 0) {
        throw notFound('Homework task not found');
      }
      return ok(await getHomeworkTaskViewAsync(task));
    }
  },
  {
    method: 'POST',
    path: '/api/v1/homework/tasks/:taskId/status',
    roles: ['TEACHER', 'ADMIN'],
    handler: async ({ params, body, auth }) => {
      const task = await store.findByIdAsync('homework_tasks', Number(params.taskId));
      if (!task) {
        throw notFound('Homework task not found');
      }
      const scopedTasks = await filterHomeworkForUser(auth.user, [task]);
      if (scopedTasks.length === 0) {
        throw notFound('Homework task not found');
      }
      const updated = await store.updateAsync('homework_tasks', task.id, {
        status: body.status,
        completedTime: body.status === 'COMPLETED' || body.status === 'CONFIRMED' ? nowIso() : task.completedTime,
        updatedAt: nowIso()
      });
      return ok(await getHomeworkTaskViewAsync(updated), 'task status updated');
    }
  },
  {
    method: 'GET',
    path: '/api/v1/homework/tasks/:taskId/feedbacks',
    handler: async ({ params, auth }) => {
      const taskId = Number(params.taskId);
      const task = await store.findByIdAsync('homework_tasks', taskId);
      if (!task) {
        throw notFound('Homework task not found');
      }
      const scopedTasks = await filterHomeworkForUser(auth.user, [task]);
      if (scopedTasks.length === 0) {
        throw notFound('Homework task not found');
      }
      const items = await store.filterAsync('homework_feedback', (item) => Number(item.taskId) === taskId);
      const views = [];
      for (let i = 0; i < items.length; i++) {
        views.push(await getHomeworkFeedbackViewAsync(items[i]));
      }
      return ok(views);
    }
  },
  {
    method: 'POST',
    path: '/api/v1/homework/feedback',
    roles: ['TEACHER', 'ADMIN'],
    handler: async ({ body, auth }) => {
      if (!body.taskId || !body.feedbackContent) {
        throw badRequest('taskId and feedbackContent are required');
      }
      const task = await store.findByIdAsync('homework_tasks', Number(body.taskId));
      if (!task) {
        throw notFound('Homework task not found');
      }
      const createdAt = nowIso();
      const feedback = await store.insertAsync('homework_feedback', {
        taskId: Number(body.taskId),
        teacherId: auth.user.id,
        teacherName: auth.user.realName,
        studentId: task.studentId,
        feedbackContent: body.feedbackContent,
        performance: body.performance || 'GOOD',
        attachments: body.attachments || [],
        status: task.status,
        guardianConfirmTime: '',
        guardianRemark: '',
        createdAt,
        updatedAt: createdAt
      });
      return ok(await getHomeworkFeedbackViewAsync(feedback), 'feedback submitted');
    }
  },
  {
    method: 'POST',
    path: '/api/v1/homework/feedback/:feedbackId/confirm',
    roles: ['PARENT', 'ADMIN'],
    handler: async ({ params, body, auth }) => {
      const feedback = await store.findByIdAsync('homework_feedback', Number(params.feedbackId));
      if (!feedback) {
        throw notFound('Homework feedback not found');
      }
      await assertStudentAccess(auth.user, Number(feedback.studentId));
      const updated = await store.updateAsync('homework_feedback', feedback.id, {
        status: body.confirmStatus === 'CONFIRMED' ? 'CONFIRMED' : feedback.status,
        guardianConfirmTime: nowIso(),
        guardianRemark: body.guardianRemark || '',
        updatedAt: nowIso()
      });
      if (body.confirmStatus === 'CONFIRMED') {
        await store.updateAsync('homework_tasks', feedback.taskId, {
          status: 'CONFIRMED',
          updatedAt: nowIso()
        });
      }
      return ok(await getHomeworkFeedbackViewAsync(updated), 'feedback confirmed');
    }
  }
];

exports.handler = createDomainHandler(contract, routes);
