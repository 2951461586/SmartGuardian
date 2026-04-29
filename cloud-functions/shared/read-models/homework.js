const store = require('../store');
const { getStudent, getStudentAsync, getSession, getSessionAsync, getUser, getUserAsync } = require('./base');

function getHomeworkTaskView(task) {
  const student = getStudent(task.studentId);
  const session = task.sessionId ? getSession(task.sessionId) : null;
  const teacher = task.teacherId ? getUser(task.teacherId) : null;
  return {
    ...task,
    studentName: student ? student.name : '',
    sessionNo: session ? session.sessionNo : '',
    teacherName: teacher ? teacher.realName : ''
  };
}

async function getHomeworkTaskViewAsync(task) {
  const student = await getStudentAsync(task.studentId);
  const session = task.sessionId ? await getSessionAsync(task.sessionId) : null;
  const teacher = task.teacherId ? await getUserAsync(task.teacherId) : null;
  return {
    ...task,
    studentName: student ? student.name : '',
    sessionNo: session ? session.sessionNo : '',
    teacherName: teacher ? teacher.realName : ''
  };
}

function getHomeworkFeedbackView(feedback) {
  const task = store.findById('homework_tasks', feedback.taskId);
  const teacher = feedback.teacherId ? getUser(feedback.teacherId) : null;
  return {
    ...feedback,
    teacherName: teacher ? teacher.realName : feedback.teacherName,
    studentId: task ? task.studentId : feedback.studentId
  };
}

async function getHomeworkFeedbackViewAsync(feedback) {
  const task = await store.findByIdAsync('homework_tasks', feedback.taskId);
  const teacher = feedback.teacherId ? await getUserAsync(feedback.teacherId) : null;
  return {
    ...feedback,
    teacherName: teacher ? teacher.realName : feedback.teacherName,
    studentId: task ? task.studentId : feedback.studentId
  };
}

module.exports = {
  getHomeworkTaskView,
  getHomeworkTaskViewAsync,
  getHomeworkFeedbackView,
  getHomeworkFeedbackViewAsync
};
