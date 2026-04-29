const store = require('../store');
const { getStudent, getStudentAsync, getSession, getSessionAsync, getUser, getUserAsync } = require('./base');

function getAttendanceView(record) {
  const student = getStudent(record.studentId);
  const session = getSession(record.sessionId);
  const operator = record.operatorUserId ? getUser(record.operatorUserId) : null;
  return {
    ...record,
    operatorName: operator ? operator.realName : '',
    studentName: student ? student.name : '',
    studentNo: student ? student.studentNo : '',
    orderId: 0,
    sessionNo: session ? session.sessionNo : '',
    attendanceDate: record.attendanceDate || (session ? session.sessionDate : '')
  };
}

async function getAttendanceViewAsync(record) {
  const student = await getStudentAsync(record.studentId);
  const session = await getSessionAsync(record.sessionId);
  const operator = record.operatorUserId ? await getUserAsync(record.operatorUserId) : null;
  return {
    ...record,
    operatorName: operator ? operator.realName : '',
    studentName: student ? student.name : '',
    studentNo: student ? student.studentNo : '',
    orderId: 0,
    sessionNo: session ? session.sessionNo : '',
    attendanceDate: record.attendanceDate || (session ? session.sessionDate : '')
  };
}

function buildAttendanceReport(startDate, endDate) {
  const records = store.filter('attendance_records', (item) => {
    return (!startDate || item.attendanceDate >= startDate) && (!endDate || item.attendanceDate <= endDate);
  });
  const totalStudents = store.list('students').length;
  const presentCount = records.filter((item) => item.status === 'SIGNED_IN' || item.status === 'SIGNED_OUT').length;
  const absentCount = records.filter((item) => item.status === 'NOT_SIGNED' || item.status === 'ABSENT').length;
  const lateCount = records.filter((item) => item.status === 'LATE').length;
  const leaveCount = records.filter((item) => item.status === 'LEAVE').length;
  const rate = totalStudents === 0 ? 0 : Math.round((presentCount / totalStudents) * 100);
  const dailyBuckets = {};
  for (let i = 0; i < records.length; i++) {
    const key = records[i].attendanceDate;
    if (!dailyBuckets[key]) {
      dailyBuckets[key] = {
        date: key,
        presentCount: 0,
        absentCount: 0,
        lateCount: 0
      };
    }
    if (records[i].status === 'SIGNED_IN' || records[i].status === 'SIGNED_OUT') {
      dailyBuckets[key].presentCount += 1;
    } else if (records[i].status === 'LATE') {
      dailyBuckets[key].lateCount += 1;
    } else {
      dailyBuckets[key].absentCount += 1;
    }
  }
  return {
    totalStudents,
    presentCount,
    absentCount,
    lateCount,
    leaveCount,
    attendanceRate: rate,
    dailyStats: Object.values(dailyBuckets).sort((left, right) => left.date.localeCompare(right.date))
  };
}

async function buildAttendanceReportAsync(startDate, endDate) {
  const records = await store.filterAsync('attendance_records', (item) => {
    return (!startDate || item.attendanceDate >= startDate) && (!endDate || item.attendanceDate <= endDate);
  });
  const students = await store.listAsync('students');
  const totalStudents = students.length;
  const presentCount = records.filter((item) => item.status === 'SIGNED_IN' || item.status === 'SIGNED_OUT').length;
  const absentCount = records.filter((item) => item.status === 'NOT_SIGNED' || item.status === 'ABSENT').length;
  const lateCount = records.filter((item) => item.status === 'LATE').length;
  const leaveCount = records.filter((item) => item.status === 'LEAVE').length;
  const rate = totalStudents === 0 ? 0 : Math.round((presentCount / totalStudents) * 100);
  const dailyBuckets = {};
  for (let i = 0; i < records.length; i++) {
    const key = records[i].attendanceDate;
    if (!dailyBuckets[key]) {
      dailyBuckets[key] = {
        date: key,
        presentCount: 0,
        absentCount: 0,
        lateCount: 0
      };
    }
    if (records[i].status === 'SIGNED_IN' || records[i].status === 'SIGNED_OUT') {
      dailyBuckets[key].presentCount += 1;
    } else if (records[i].status === 'LATE') {
      dailyBuckets[key].lateCount += 1;
    } else {
      dailyBuckets[key].absentCount += 1;
    }
  }
  return {
    totalStudents,
    presentCount,
    absentCount,
    lateCount,
    leaveCount,
    attendanceRate: rate,
    dailyStats: Object.values(dailyBuckets).sort((left, right) => left.date.localeCompare(right.date))
  };
}

function buildAttendanceDailyStats(startDate, endDate) {
  const report = buildAttendanceReport(startDate, endDate);
  return report.dailyStats.map((item) => {
    const totalStudents = store.list('students').length;
    return {
      date: item.date,
      totalStudents,
      presentStudents: item.presentCount,
      absentStudents: item.absentCount,
      lateStudents: item.lateCount,
      leaveStudents: 0,
      attendanceRate: totalStudents === 0 ? 0 : Math.round((item.presentCount / totalStudents) * 100)
    };
  });
}

async function buildAttendanceDailyStatsAsync(startDate, endDate) {
  const report = await buildAttendanceReportAsync(startDate, endDate);
  return report.dailyStats.map((item) => {
    const totalStudents = report.totalStudents;
    return {
      date: item.date,
      totalStudents,
      presentStudents: item.presentCount,
      absentStudents: item.absentCount,
      lateStudents: item.lateCount,
      leaveStudents: 0,
      attendanceRate: totalStudents === 0 ? 0 : Math.round((item.presentCount / totalStudents) * 100)
    };
  });
}

function buildStudentAttendanceSummary(startDate, endDate) {
  const students = store.list('students');
  return students.map((student) => {
    const records = store.filter('attendance_records', (item) => {
      return Number(item.studentId) === Number(student.id) && (!startDate || item.attendanceDate >= startDate) && (!endDate || item.attendanceDate <= endDate);
    });
    const totalDays = records.length;
    const presentDays = records.filter((item) => item.status === 'SIGNED_IN' || item.status === 'SIGNED_OUT').length;
    const absentDays = records.filter((item) => item.status === 'NOT_SIGNED' || item.status === 'ABSENT').length;
    const lateDays = records.filter((item) => item.status === 'LATE').length;
    const leaveDays = records.filter((item) => item.status === 'LEAVE').length;
    return {
      studentId: student.id,
      studentName: student.name,
      studentNo: student.studentNo,
      totalDays,
      presentDays,
      absentDays,
      lateDays,
      leaveDays,
      attendanceRate: totalDays === 0 ? 0 : Math.round((presentDays / totalDays) * 100)
    };
  });
}

async function buildStudentAttendanceSummaryAsync(startDate, endDate) {
  const students = await store.listAsync('students');
  const summaries = [];
  for (let i = 0; i < students.length; i++) {
    const student = students[i];
    const records = await store.filterAsync('attendance_records', (item) => {
      return Number(item.studentId) === Number(student.id) && (!startDate || item.attendanceDate >= startDate) && (!endDate || item.attendanceDate <= endDate);
    });
    const totalDays = records.length;
    const presentDays = records.filter((item) => item.status === 'SIGNED_IN' || item.status === 'SIGNED_OUT').length;
    const absentDays = records.filter((item) => item.status === 'NOT_SIGNED' || item.status === 'ABSENT').length;
    const lateDays = records.filter((item) => item.status === 'LATE').length;
    const leaveDays = records.filter((item) => item.status === 'LEAVE').length;
    summaries.push({
      studentId: student.id,
      studentName: student.name,
      studentNo: student.studentNo,
      totalDays,
      presentDays,
      absentDays,
      lateDays,
      leaveDays,
      attendanceRate: totalDays === 0 ? 0 : Math.round((presentDays / totalDays) * 100)
    });
  }
  return summaries;
}

module.exports = {
  getAttendanceView,
  getAttendanceViewAsync,
  buildAttendanceReport,
  buildAttendanceReportAsync,
  buildAttendanceDailyStats,
  buildAttendanceDailyStatsAsync,
  buildStudentAttendanceSummary,
  buildStudentAttendanceSummaryAsync
};
