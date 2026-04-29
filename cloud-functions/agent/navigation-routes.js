/**
 * Agent navigation route table.
 * Maps natural language keywords to HarmonyOS page routes per role.
 */
const NAVIGATION_ROUTES = [
  {
    roles: ['PARENT'],
    title: '家长首页',
    routeUrl: 'pages/parent/ParentHomePage',
    moduleCode: 'home',
    keywords: ['首页', '主页', '孩子状态', '托管状态', '今日', 'home']
  },
  {
    roles: ['PARENT'],
    title: '服务报名',
    routeUrl: 'pages/parent/ParentServicesPage',
    moduleCode: 'services',
    keywords: ['服务', '报名', '课程', '托管班', '续费', 'services']
  },
  {
    roles: ['PARENT'],
    title: '订单中心',
    routeUrl: 'pages/parent/ParentOrdersPage',
    moduleCode: 'orders',
    keywords: ['订单', '缴费', '支付', '费用', '退款', 'orders']
  },
  {
    roles: ['PARENT'],
    title: '家校消息',
    routeUrl: 'pages/parent/ParentMessagesPage',
    moduleCode: 'messages',
    keywords: ['消息', '通知', '家校', '提醒', 'messages']
  },
  {
    roles: ['PARENT'],
    title: '成长动态',
    routeUrl: 'pages/parent/ParentTimelinePage',
    moduleCode: 'timeline',
    keywords: ['动态', '成长', '时间线', '记录', 'timeline']
  },
  {
    roles: ['PARENT'],
    title: '请假申请',
    routeUrl: 'pages/parent/ParentLeavePage',
    moduleCode: 'leave',
    keywords: ['请假', '病假', '事假', 'leave']
  },
  {
    roles: ['PARENT'],
    title: '异常提醒',
    routeUrl: 'pages/parent/ParentAlertsPage',
    moduleCode: 'alerts',
    keywords: ['异常', '告警', '迟到', '未签到', 'alerts']
  },
  {
    roles: ['PARENT'],
    title: '作业反馈',
    routeUrl: 'pages/parent/ParentHomeworkPage',
    moduleCode: 'homework',
    keywords: ['作业', '反馈', '辅导', 'homework']
  },
  {
    roles: ['TEACHER'],
    title: '教师首页',
    routeUrl: 'pages/teacher/TeacherHomePage',
    moduleCode: 'home',
    keywords: ['首页', '主页', '今日班次', 'home']
  },
  {
    roles: ['TEACHER'],
    title: '考勤管理',
    routeUrl: 'pages/teacher/TeacherAttendancePage',
    moduleCode: 'attendance',
    keywords: ['考勤', '签到', '签退', '点名', 'attendance']
  },
  {
    roles: ['TEACHER'],
    title: '扫码签到',
    routeUrl: 'pages/teacher/TeacherScanPage',
    moduleCode: 'scan',
    keywords: ['扫码', '二维码', '扫描', 'scan']
  },
  {
    roles: ['TEACHER'],
    title: '作业管理',
    routeUrl: 'pages/teacher/TeacherHomeworkPage',
    moduleCode: 'homework',
    keywords: ['作业', '辅导', '反馈', 'homework']
  },
  {
    roles: ['TEACHER'],
    title: '教师消息',
    routeUrl: 'pages/teacher/TeacherMessagesPage',
    moduleCode: 'messages',
    keywords: ['消息', '通知', '家校', 'messages']
  },
  {
    roles: ['ADMIN', 'ORG_ADMIN', 'SCHOOL_ADMIN', 'PLATFORM_ADMIN'],
    title: '运营首页',
    routeUrl: 'pages/admin/AdminHomePage',
    moduleCode: 'home',
    keywords: ['首页', '主页', '运营', '概览', 'home']
  },
  {
    roles: ['ADMIN', 'ORG_ADMIN', 'SCHOOL_ADMIN', 'PLATFORM_ADMIN'],
    title: '学生管理',
    routeUrl: 'pages/admin/AdminStudentsPage',
    moduleCode: 'students',
    keywords: ['学生', '学员', '孩子', '档案', 'students']
  },
  {
    roles: ['ADMIN', 'ORG_ADMIN', 'SCHOOL_ADMIN', 'PLATFORM_ADMIN'],
    title: '订单管理',
    routeUrl: 'pages/admin/AdminOrdersPage',
    moduleCode: 'orders',
    keywords: ['订单', '审核', '缴费', '支付', 'orders']
  },
  {
    roles: ['ADMIN', 'ORG_ADMIN', 'SCHOOL_ADMIN', 'PLATFORM_ADMIN'],
    title: '运营报表',
    routeUrl: 'pages/admin/AdminReportsPage',
    moduleCode: 'reports',
    keywords: ['报表', '统计', '财务', '考勤率', '经营', 'reports']
  },
  {
    roles: ['ADMIN', 'ORG_ADMIN', 'SCHOOL_ADMIN', 'PLATFORM_ADMIN'],
    title: '告警中心',
    routeUrl: 'pages/admin/AdminAlertsPage',
    moduleCode: 'alerts',
    keywords: ['告警', '异常', '处置', 'alerts']
  },
  {
    roles: ['ADMIN', 'ORG_ADMIN', 'SCHOOL_ADMIN', 'PLATFORM_ADMIN'],
    title: '班次管理',
    routeUrl: 'pages/admin/AdminSessionsPage',
    moduleCode: 'sessions',
    keywords: ['班次', '排课', '课程', 'sessions']
  },
  {
    roles: ['ADMIN', 'ORG_ADMIN', 'SCHOOL_ADMIN', 'PLATFORM_ADMIN'],
    title: '消息群发',
    routeUrl: 'pages/admin/AdminMessagesPage',
    moduleCode: 'messages',
    keywords: ['消息', '通知', '群发', 'messages']
  }
];

module.exports = { NAVIGATION_ROUTES };
