const store = require('../store');
const { getUser, getUserAsync, getStudent, getStudentAsync, getServiceProduct, getServiceProductAsync } = require('./base');

function getSessionView(session) {
  const service = getServiceProduct(session.serviceProductId);
  const teacher = session.teacherUserId ? getUser(session.teacherUserId) : null;
  return {
    ...session,
    serviceProductName: service ? service.serviceName : '',
    teacherId: session.teacherUserId || 0,
    teacherName: teacher ? teacher.realName : ''
  };
}

async function getSessionViewAsync(session) {
  const service = await getServiceProductAsync(session.serviceProductId);
  const teacher = session.teacherUserId ? await getUserAsync(session.teacherUserId) : null;
  return {
    ...session,
    serviceProductName: service ? service.serviceName : '',
    teacherId: session.teacherUserId || 0,
    teacherName: teacher ? teacher.realName : ''
  };
}

function getSessionStudents(sessionId) {
  const roster = store.filter('session_students', (item) => Number(item.sessionId) === Number(sessionId));
  return roster.map((item) => {
    const student = getStudent(item.studentId);
    const attendance = store.filter('attendance_records', (record) => {
      return Number(record.sessionId) === Number(sessionId) && Number(record.studentId) === Number(item.studentId);
    })[0];
    return {
      studentId: item.studentId,
      studentName: student ? student.name : '',
      studentNo: student ? student.studentNo : '',
      attendanceStatus: attendance ? attendance.status : 'NOT_SIGNED',
      signInTime: attendance ? attendance.signInTime : '',
      signOutTime: attendance ? attendance.signOutTime : ''
    };
  });
}

async function getSessionStudentsAsync(sessionId) {
  const roster = await store.filterAsync('session_students', (item) => Number(item.sessionId) === Number(sessionId));
  const students = [];
  for (let i = 0; i < roster.length; i++) {
    const rosterItem = roster[i];
    const student = await getStudentAsync(rosterItem.studentId);
    const attendanceList = await store.filterAsync('attendance_records', (record) => {
      return Number(record.sessionId) === Number(sessionId) && Number(record.studentId) === Number(rosterItem.studentId);
    });
    const attendance = attendanceList.length > 0 ? attendanceList[0] : null;
    students.push({
      studentId: rosterItem.studentId,
      studentName: student ? student.name : '',
      studentNo: student ? student.studentNo : '',
      attendanceStatus: attendance ? attendance.status : 'NOT_SIGNED',
      signInTime: attendance ? attendance.signInTime : '',
      signOutTime: attendance ? attendance.signOutTime : ''
    });
  }
  return students;
}

module.exports = {
  getSessionView,
  getSessionViewAsync,
  getSessionStudents,
  getSessionStudentsAsync
};
