const store = require('../store');
const { todayDate } = require('../time');
const { getStudent, getStudentAsync } = require('./base');
const { getSessionView, getSessionViewAsync } = require('./session');

function buildTodayStatusCard(studentId) {
  const targetStudent = getStudent(studentId);
  if (!targetStudent) {
    return null;
  }
  const date = todayDate();
  const sessions = store.filter('sessions', (session) => session.sessionDate === date);
  const sessionRoster = store.filter('session_students', (item) => Number(item.studentId) === Number(studentId));
  let matchedSession = null;
  for (let i = 0; i < sessionRoster.length; i++) {
    const session = sessions.find((candidate) => Number(candidate.id) === Number(sessionRoster[i].sessionId));
    if (session) {
      matchedSession = session;
      break;
    }
  }
  const attendance = store.filter('attendance_records', (record) => Number(record.studentId) === Number(studentId) && record.attendanceDate === date)[0];
  const homeworkList = store.filter('homework_tasks', (item) => Number(item.studentId) === Number(studentId) && item.taskDate === date);
  const messageCount = store.filter('messages', (item) => Number(item.userId) === Number(targetStudent.guardianUserId) && !item.readStatus).length;
  const feedback = store.filter('homework_feedback', (item) => Number(item.studentId) === Number(studentId))[0];
  const sessionView = matchedSession ? getSessionView(matchedSession) : null;

  return {
    date,
    studentId: targetStudent.id,
    studentName: targetStudent.name,
    sessionInfo: matchedSession ? {
      sessionId: matchedSession.id,
      sessionNo: matchedSession.sessionNo,
      sessionDate: matchedSession.sessionDate,
      startTime: matchedSession.startTime,
      endTime: matchedSession.endTime,
      teacherName: sessionView ? sessionView.teacherName : '',
      location: matchedSession.location
    } : undefined,
    attendanceStatus: attendance ? attendance.status : 'NOT_SIGNED',
    signInTime: attendance ? attendance.signInTime : '',
    signOutTime: attendance ? attendance.signOutTime : '',
    homeworkStatus: homeworkList.length > 0 ? homeworkList[0].status : 'PENDING',
    homeworkCount: homeworkList.length,
    completedHomework: homeworkList.filter((item) => item.status === 'COMPLETED' || item.status === 'CONFIRMED').length,
    messages: messageCount,
    sessionName: sessionView ? sessionView.serviceProductName : 'Today session',
    sessionTime: matchedSession ? `${matchedSession.startTime} - ${matchedSession.endTime}` : '',
    status: attendance ? attendance.status : 'NOT_SIGNED',
    latestDynamic: feedback ? feedback.feedbackContent : '',
    homeworkProgress: homeworkList.length > 0 ? Math.round((homeworkList.filter((item) => item.status !== 'PENDING').length / homeworkList.length) * 100) : 0,
    teacherFeedback: feedback ? feedback.feedbackContent : ''
  };
}

async function buildTodayStatusCardAsync(studentId) {
  const targetStudent = await getStudentAsync(studentId);
  if (!targetStudent) {
    return null;
  }
  const date = todayDate();
  const sessions = await store.filterAsync('sessions', (session) => session.sessionDate === date);
  const sessionRoster = await store.filterAsync('session_students', (item) => Number(item.studentId) === Number(studentId));
  let matchedSession = null;
  for (let i = 0; i < sessionRoster.length; i++) {
    const rosterItem = sessionRoster[i];
    const session = sessions.find((candidate) => Number(candidate.id) === Number(rosterItem.sessionId));
    if (session) {
      matchedSession = session;
      break;
    }
  }
  const attendanceList = await store.filterAsync('attendance_records', (record) => Number(record.studentId) === Number(studentId) && record.attendanceDate === date);
  const homeworkList = await store.filterAsync('homework_tasks', (item) => Number(item.studentId) === Number(studentId) && item.taskDate === date);
  const messages = await store.filterAsync('messages', (item) => Number(item.userId) === Number(targetStudent.guardianUserId) && !item.readStatus);
  const feedbackList = await store.filterAsync('homework_feedback', (item) => Number(item.studentId) === Number(studentId));
  const attendance = attendanceList.length > 0 ? attendanceList[0] : null;
  const feedback = feedbackList.length > 0 ? feedbackList[0] : null;
  const sessionView = matchedSession ? await getSessionViewAsync(matchedSession) : null;

  return {
    date,
    studentId: targetStudent.id,
    studentName: targetStudent.name,
    sessionInfo: matchedSession ? {
      sessionId: matchedSession.id,
      sessionNo: matchedSession.sessionNo,
      sessionDate: matchedSession.sessionDate,
      startTime: matchedSession.startTime,
      endTime: matchedSession.endTime,
      teacherName: sessionView ? sessionView.teacherName : '',
      location: matchedSession.location
    } : undefined,
    attendanceStatus: attendance ? attendance.status : 'NOT_SIGNED',
    signInTime: attendance ? attendance.signInTime : '',
    signOutTime: attendance ? attendance.signOutTime : '',
    homeworkStatus: homeworkList.length > 0 ? homeworkList[0].status : 'PENDING',
    homeworkCount: homeworkList.length,
    completedHomework: homeworkList.filter((item) => item.status === 'COMPLETED' || item.status === 'CONFIRMED').length,
    messages: messages.length,
    sessionName: sessionView ? sessionView.serviceProductName : 'Today session',
    sessionTime: matchedSession ? `${matchedSession.startTime} - ${matchedSession.endTime}` : '',
    status: attendance ? attendance.status : 'NOT_SIGNED',
    latestDynamic: feedback ? feedback.feedbackContent : '',
    homeworkProgress: homeworkList.length > 0 ? Math.round((homeworkList.filter((item) => item.status !== 'PENDING').length / homeworkList.length) * 100) : 0,
    teacherFeedback: feedback ? feedback.feedbackContent : ''
  };
}

function buildAbnormalAlertCard(studentId) {
  const alerts = store.filter('alerts', (item) => Number(item.studentId) === Number(studentId) && item.status === 'ACTIVE');
  if (alerts.length === 0) {
    return null;
  }
  const latest = alerts.sort((left, right) => right.createdAt.localeCompare(left.createdAt))[0];
  return {
    alertId: latest.id,
    studentId: latest.studentId,
    studentName: latest.studentName,
    alertType: latest.alertType === 'ATTENDANCE_ANOMALY' ? 'ATTENDANCE' : 'OTHER',
    alertLevel: latest.severity === 'HIGH' || latest.severity === 'CRITICAL' ? 'ERROR' : 'WARNING',
    alertTitle: latest.title,
    alertContent: latest.description,
    alertTime: latest.createdAt,
    isRead: latest.status !== 'ACTIVE',
    relatedData: {
      suggestedAction: latest.suggestedAction
    }
  };
}

async function buildAbnormalAlertCardAsync(studentId) {
  const alerts = await store.filterAsync('alerts', (item) => Number(item.studentId) === Number(studentId) && item.status === 'ACTIVE');
  if (alerts.length === 0) {
    return null;
  }
  const latest = alerts.sort((left, right) => right.createdAt.localeCompare(left.createdAt))[0];
  return {
    alertId: latest.id,
    studentId: latest.studentId,
    studentName: latest.studentName,
    alertType: latest.alertType === 'ATTENDANCE_ANOMALY' ? 'ATTENDANCE' : 'OTHER',
    alertLevel: latest.severity === 'HIGH' || latest.severity === 'CRITICAL' ? 'ERROR' : 'WARNING',
    alertTitle: latest.title,
    alertContent: latest.description,
    alertTime: latest.createdAt,
    isRead: latest.status !== 'ACTIVE',
    relatedData: {
      suggestedAction: latest.suggestedAction
    }
  };
}

module.exports = {
  buildTodayStatusCard,
  buildTodayStatusCardAsync,
  buildAbnormalAlertCard,
  buildAbnormalAlertCardAsync
};
