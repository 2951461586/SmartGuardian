const store = require('../store');
const { getStudent, getStudentAsync } = require('./base');

function getMessageDetailView(message) {
  const detail = {
    ...message
  };

  if (message.bizType === 'ATTENDANCE') {
    const attendance = store.findById('attendance_records', message.bizId);
    const student = attendance ? getStudent(attendance.studentId) : null;
    detail.relatedInfo = {
      studentName: student ? student.name : '',
      actionText: 'View attendance',
      actionUrl: '/parent/alerts'
    };
  } else if (message.bizType === 'HOMEWORK') {
    const task = store.findById('homework_tasks', message.bizId);
    const student = task ? getStudent(task.studentId) : null;
    detail.relatedInfo = {
      studentName: student ? student.name : '',
      actionText: 'View homework',
      actionUrl: '/parent/homework'
    };
  } else if (message.bizType === 'ORDER') {
    detail.relatedInfo = {
      studentName: '',
      actionText: 'View order',
      actionUrl: '/parent/orders'
    };
  }

  return detail;
}

async function getMessageDetailViewAsync(message) {
  const detail = {
    ...message
  };

  if (message.bizType === 'ATTENDANCE') {
    const attendance = await store.findByIdAsync('attendance_records', message.bizId);
    const student = attendance ? await getStudentAsync(attendance.studentId) : null;
    detail.relatedInfo = {
      studentName: student ? student.name : '',
      actionText: 'View attendance',
      actionUrl: '/parent/alerts'
    };
  } else if (message.bizType === 'HOMEWORK') {
    const task = await store.findByIdAsync('homework_tasks', message.bizId);
    const student = task ? await getStudentAsync(task.studentId) : null;
    detail.relatedInfo = {
      studentName: student ? student.name : '',
      actionText: 'View homework',
      actionUrl: '/parent/homework'
    };
  } else if (message.bizType === 'ORDER') {
    detail.relatedInfo = {
      studentName: '',
      actionText: 'View order',
      actionUrl: '/parent/orders'
    };
  }

  return detail;
}

function buildMessageStatistics(userId) {
  const messages = store.filter('messages', (item) => Number(item.userId) === Number(userId));
  const byType = {};
  for (let i = 0; i < messages.length; i++) {
    const key = messages[i].msgType;
    byType[key] = (byType[key] || 0) + 1;
  }
  return {
    total: messages.length,
    unread: messages.filter((item) => !item.readStatus).length,
    byType
  };
}

async function buildMessageStatisticsAsync(userId) {
  const messages = await store.filterAsync('messages', (item) => Number(item.userId) === Number(userId));
  const byType = {};
  for (let i = 0; i < messages.length; i++) {
    const key = messages[i].msgType;
    byType[key] = (byType[key] || 0) + 1;
  }
  return {
    total: messages.length,
    unread: messages.filter((item) => !item.readStatus).length,
    byType
  };
}

module.exports = {
  getMessageDetailView,
  getMessageDetailViewAsync,
  buildMessageStatistics,
  buildMessageStatisticsAsync
};
