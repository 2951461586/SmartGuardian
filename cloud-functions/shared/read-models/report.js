const store = require('../store');
const { formatMonth } = require('../time');
const { getSessionStudents, getSessionStudentsAsync } = require('./session');

function buildFinanceReport(startDate, endDate) {
  const orders = store.filter('orders', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  const refunds = store.filter('refunds', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  const totalIncome = orders.reduce((sum, item) => sum + Number(item.paidAmount || 0), 0);
  const totalRefund = refunds.reduce((sum, item) => sum + Number(item.refundAmount || 0), 0);
  const dailyMap = {};
  for (let i = 0; i < orders.length; i++) {
    const key = orders[i].createdAt.slice(0, 10);
    if (!dailyMap[key]) {
      dailyMap[key] = { date: key, income: 0, refund: 0 };
    }
    dailyMap[key].income += Number(orders[i].paidAmount || 0);
  }
  for (let i = 0; i < refunds.length; i++) {
    const key = refunds[i].createdAt.slice(0, 10);
    if (!dailyMap[key]) {
      dailyMap[key] = { date: key, income: 0, refund: 0 };
    }
    dailyMap[key].refund += Number(refunds[i].refundAmount || 0);
  }
  return {
    totalIncome,
    totalRefund,
    netIncome: totalIncome - totalRefund,
    orderCount: orders.length,
    refundedOrderCount: refunds.length,
    dailyStats: Object.values(dailyMap).sort((left, right) => left.date.localeCompare(right.date))
  };
}

async function buildFinanceReportAsync(startDate, endDate) {
  const orders = await store.filterAsync('orders', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  const refunds = await store.filterAsync('refunds', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  const totalIncome = orders.reduce((sum, item) => sum + Number(item.paidAmount || 0), 0);
  const totalRefund = refunds.reduce((sum, item) => sum + Number(item.refundAmount || 0), 0);
  const dailyMap = {};
  for (let i = 0; i < orders.length; i++) {
    const key = orders[i].createdAt.slice(0, 10);
    if (!dailyMap[key]) {
      dailyMap[key] = { date: key, income: 0, refund: 0 };
    }
    dailyMap[key].income += Number(orders[i].paidAmount || 0);
  }
  for (let i = 0; i < refunds.length; i++) {
    const key = refunds[i].createdAt.slice(0, 10);
    if (!dailyMap[key]) {
      dailyMap[key] = { date: key, income: 0, refund: 0 };
    }
    dailyMap[key].refund += Number(refunds[i].refundAmount || 0);
  }
  return {
    totalIncome,
    totalRefund,
    netIncome: totalIncome - totalRefund,
    orderCount: orders.length,
    refundedOrderCount: refunds.length,
    dailyStats: Object.values(dailyMap).sort((left, right) => left.date.localeCompare(right.date))
  };
}

function buildFinanceSummaryModel(startDate, endDate) {
  const orders = store.filter('orders', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  const refunds = store.filter('refunds', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  return {
    reportMonth: formatMonth(endDate ? `${endDate}T00:00:00.000Z` : new Date().toISOString()),
    totalOrders: orders.length,
    totalAmount: orders.reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0),
    paidAmount: orders.reduce((sum, item) => sum + Number(item.paidAmount || 0), 0),
    pendingAmount: orders.filter((item) => item.payStatus === 'UNPAID').reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0),
    refundedAmount: refunds.reduce((sum, item) => sum + Number(item.refundAmount || 0), 0),
    orderCount: orders.length,
    refundCount: refunds.length
  };
}

async function buildFinanceSummaryModelAsync(startDate, endDate) {
  const orders = await store.filterAsync('orders', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  const refunds = await store.filterAsync('refunds', (item) => {
    const createdDate = item.createdAt.slice(0, 10);
    return (!startDate || createdDate >= startDate) && (!endDate || createdDate <= endDate);
  });
  return {
    reportMonth: formatMonth(endDate ? `${endDate}T00:00:00.000Z` : new Date().toISOString()),
    totalOrders: orders.length,
    totalAmount: orders.reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0),
    paidAmount: orders.reduce((sum, item) => sum + Number(item.paidAmount || 0), 0),
    pendingAmount: orders.filter((item) => item.payStatus === 'UNPAID').reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0),
    refundedAmount: refunds.reduce((sum, item) => sum + Number(item.refundAmount || 0), 0),
    orderCount: orders.length,
    refundCount: refunds.length
  };
}

function buildDailyRevenueStats(startDate, endDate) {
  const finance = buildFinanceReport(startDate, endDate);
  return finance.dailyStats.map((item) => {
    return {
      date: item.date,
      orderCount: store.filter('orders', (order) => order.createdAt.slice(0, 10) === item.date).length,
      totalAmount: item.income,
      paidAmount: item.income,
      refundedAmount: item.refund
    };
  });
}

async function buildDailyRevenueStatsAsync(startDate, endDate) {
  const finance = await buildFinanceReportAsync(startDate, endDate);
  const orders = await store.listAsync('orders');
  return finance.dailyStats.map((item) => {
    return {
      date: item.date,
      orderCount: orders.filter((order) => order.createdAt.slice(0, 10) === item.date).length,
      totalAmount: item.income,
      paidAmount: item.income,
      refundedAmount: item.refund
    };
  });
}

function buildServiceProductRevenue(startDate, endDate) {
  const orders = store.filter('orders', (item) => {
    const date = item.createdAt.slice(0, 10);
    return (!startDate || date >= startDate) && (!endDate || date <= endDate);
  });
  const totalAmount = orders.reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0);
  const services = store.list('service_products');
  return services.map((service) => {
    const related = orders.filter((item) => Number(item.serviceProductId) === Number(service.id));
    const amount = related.reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0);
    return {
      serviceProductId: service.id,
      serviceName: service.serviceName,
      orderCount: related.length,
      totalAmount: amount,
      percentage: totalAmount === 0 ? 0 : Math.round((amount / totalAmount) * 100)
    };
  }).filter((item) => item.orderCount > 0);
}

async function buildServiceProductRevenueAsync(startDate, endDate) {
  const orders = await store.filterAsync('orders', (item) => {
    const date = item.createdAt.slice(0, 10);
    return (!startDate || date >= startDate) && (!endDate || date <= endDate);
  });
  const totalAmount = orders.reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0);
  const services = await store.listAsync('service_products');
  return services.map((service) => {
    const related = orders.filter((item) => Number(item.serviceProductId) === Number(service.id));
    const amount = related.reduce((sum, item) => sum + Number(item.actualAmount || item.amount || 0), 0);
    return {
      serviceProductId: service.id,
      serviceName: service.serviceName,
      orderCount: related.length,
      totalAmount: amount,
      percentage: totalAmount === 0 ? 0 : Math.round((amount / totalAmount) * 100)
    };
  }).filter((item) => item.orderCount > 0);
}

function buildTeacherPerformance(startDate, endDate) {
  const teachers = store.filter('users', (item) => item.roleType === 'TEACHER');
  return teachers.map((teacher) => {
    const sessions = store.filter('sessions', (item) => {
      return Number(item.teacherUserId) === Number(teacher.id) && (!startDate || item.sessionDate >= startDate) && (!endDate || item.sessionDate <= endDate);
    });
    let totalStudents = 0;
    let attendanceRate = 0;
    for (let i = 0; i < sessions.length; i++) {
      const roster = getSessionStudents(sessions[i].id);
      totalStudents += roster.length;
      const signedCount = roster.filter((item) => item.attendanceStatus === 'SIGNED_IN' || item.attendanceStatus === 'SIGNED_OUT').length;
      attendanceRate += roster.length === 0 ? 0 : Math.round((signedCount / roster.length) * 100);
    }
    const tasks = store.filter('homework_tasks', (item) => Number(item.teacherId) === Number(teacher.id));
    const homeworkCompletedCount = tasks.filter((item) => item.status === 'COMPLETED' || item.status === 'CONFIRMED').length;
    return {
      teacherId: teacher.id,
      teacherName: teacher.realName,
      totalSessions: sessions.length,
      totalStudents,
      avgAttendanceRate: sessions.length === 0 ? 0 : Math.round(attendanceRate / sessions.length),
      homeworkCompletedCount,
      avgRating: 4.7
    };
  });
}

async function buildTeacherPerformanceAsync(startDate, endDate) {
  const teachers = await store.filterAsync('users', (item) => item.roleType === 'TEACHER');
  const performance = [];
  for (let i = 0; i < teachers.length; i++) {
    const teacher = teachers[i];
    const sessions = await store.filterAsync('sessions', (item) => {
      return Number(item.teacherUserId) === Number(teacher.id) && (!startDate || item.sessionDate >= startDate) && (!endDate || item.sessionDate <= endDate);
    });
    let totalStudents = 0;
    let attendanceRate = 0;
    for (let j = 0; j < sessions.length; j++) {
      const roster = await getSessionStudentsAsync(sessions[j].id);
      totalStudents += roster.length;
      const signedCount = roster.filter((item) => item.attendanceStatus === 'SIGNED_IN' || item.attendanceStatus === 'SIGNED_OUT').length;
      attendanceRate += roster.length === 0 ? 0 : Math.round((signedCount / roster.length) * 100);
    }
    const tasks = await store.filterAsync('homework_tasks', (item) => Number(item.teacherId) === Number(teacher.id));
    const homeworkCompletedCount = tasks.filter((item) => item.status === 'COMPLETED' || item.status === 'CONFIRMED').length;
    performance.push({
      teacherId: teacher.id,
      teacherName: teacher.realName,
      totalSessions: sessions.length,
      totalStudents,
      avgAttendanceRate: sessions.length === 0 ? 0 : Math.round(attendanceRate / sessions.length),
      homeworkCompletedCount,
      avgRating: 4.7
    });
  }
  return performance;
}

function buildWorkbench(roleType) {
  const manifests = store.filter('workbench_manifests', (item) => item.roleType === roleType && item.status === 'ACTIVE');
  return manifests.length > 0 ? manifests[0].payload : null;
}

async function buildWorkbenchAsync(roleType) {
  const manifests = await store.filterAsync('workbench_manifests', (item) => item.roleType === roleType && item.status === 'ACTIVE');
  return manifests.length > 0 ? manifests[0].payload : null;
}

module.exports = {
  buildFinanceReport,
  buildFinanceReportAsync,
  buildFinanceSummaryModel,
  buildFinanceSummaryModelAsync,
  buildDailyRevenueStats,
  buildDailyRevenueStatsAsync,
  buildServiceProductRevenue,
  buildServiceProductRevenueAsync,
  buildTeacherPerformance,
  buildTeacherPerformanceAsync,
  buildWorkbench,
  buildWorkbenchAsync
};
