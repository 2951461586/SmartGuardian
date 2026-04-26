import { AlertRecord, AlertStatistics } from '../../../models/alert';
import { AttendanceRecord, LeaveRecord } from '../../../models/attendance';
import { AbnormalAlertCard, TodayStatusCard } from '../../../models/card';
import { HomeworkTask, HomeworkTaskStatus } from '../../../models/homework';
import { MessageDetail, MessageRecord, MessageStatistics } from '../../../models/message';
import { TimelineItem } from '../../../models/timeline';

export const mockAttendanceRecords: AttendanceRecord[] = [
  {
    id: 1,
    studentId: 1,
    sessionId: 1,
    signInTime: '2026-04-16T16:35:00Z',
    status: 'SIGNED_IN',
    studentName: '王小明',
    studentNo: 'S20260001',
    sessionNo: 'SES20260416001',
    attendanceDate: '2026-04-16',
    signInMethod: 'QRCODE',
    signInLocation: '实验小学托管教室A'
  },
  {
    id: 2,
    studentId: 2,
    sessionId: 1,
    status: 'ABSENT',
    abnormalFlag: true,
    abnormalType: 'ABSENT',
    abnormalDesc: '学生未到班次',
    studentName: '李小红',
    studentNo: 'S20260002',
    sessionNo: 'SES20260416001',
    attendanceDate: '2026-04-16'
  }
];

export const mockLeaveRecords: LeaveRecord[] = [
  {
    id: 1,
    studentId: 2,
    leaveDate: '2026-04-17',
    leaveType: 'SICK',
    reason: '感冒发烧请假',
    attachments: [],
    status: 'PENDING',
    reviewerId: 2,
    reviewerName: '王老师',
    createdAt: '2026-04-16T20:00:00Z',
    updatedAt: '2026-04-16T20:00:00Z'
  }
];

export const mockHomeworkTasks: HomeworkTask[] = [
  {
    id: 1,
    studentId: 1,
    taskDate: '2026-04-16',
    subject: '语文',
    title: '完成课后练习第5课',
    content: '完成练习册第12-13页',
    status: HomeworkTaskStatus.IN_PROGRESS,
    studentName: '王小明',
    teacherId: 2,
    teacherName: '王老师'
  },
  {
    id: 2,
    studentId: 1,
    taskDate: '2026-04-16',
    subject: '数学',
    title: '完成练习题',
    content: '完成口算练习第20页',
    status: HomeworkTaskStatus.PENDING,
    studentName: '王小明',
    teacherId: 2,
    teacherName: '王老师'
  }
];

export const mockMessages: MessageRecord[] = [
  {
    id: 1,
    userId: 2,
    msgType: 'ATTENDANCE',
    title: '签到通知',
    content: '王小明同学已安全到达托管教室，请家长放心。',
    readStatus: false,
    createdAt: '2026-04-16T16:36:00Z',
    updatedAt: '2026-04-16T16:36:00Z'
  },
  {
    id: 2,
    userId: 1,
    msgType: 'HOMEWORK',
    title: '作业提醒',
    content: '请完成今日语文作业。',
    readStatus: true,
    readAt: '2026-04-16T21:00:00Z',
    createdAt: '2026-04-16T18:00:00Z',
    updatedAt: '2026-04-16T21:00:00Z'
  }
];

export const mockMessageStatistics: MessageStatistics = {
  total: 2,
  unread: 1,
  byType: {
    ATTENDANCE: 1,
    HOMEWORK: 1
  }
};

export const mockMessageDetails: MessageDetail[] = [
  {
    id: 1,
    userId: 2,
    msgType: 'ATTENDANCE',
    title: '签到通知',
    content: '王小明同学已安全到达托管教室，请家长放心。',
    readStatus: false,
    createdAt: '2026-04-16T16:36:00Z',
    updatedAt: '2026-04-16T16:36:00Z',
    relatedInfo: {
      studentName: '王小明',
      actionText: '查看考勤',
      actionUrl: '/attendance/1'
    }
  }
];

export const mockTimeline: TimelineItem[] = [
  {
    id: 1,
    studentId: 1,
    timelineType: 'ATTENDANCE',
    bizId: 1,
    title: '签到成功',
    content: '王小明同学已签到到达',
    bizDate: '2026-04-16',
    timestamp: '2026-04-16T16:35:00Z',
    operatorUserId: 2,
    operatorName: '王老师'
  }
];

export const mockTodayStatusCard: TodayStatusCard = {
  date: '2026-04-16',
  studentId: 1,
  studentName: '王小明',
  sessionInfo: {
    sessionId: 1,
    sessionNo: 'SES20260416001',
    sessionDate: '2026-04-16',
    startTime: '16:30:00',
    endTime: '18:30:00',
    teacherName: '王老师',
    location: '实验小学托管教室A'
  },
  attendanceStatus: 'SIGNED_IN',
  signInTime: '16:35',
  homeworkStatus: 'IN_PROGRESS',
  homeworkCount: 2,
  completedHomework: 0,
  messages: 1
};

export const mockAbnormalAlerts: AbnormalAlertCard[] = [
  {
    alertId: 1,
    studentId: 1,
    studentName: '王小明',
    alertType: 'ATTENDANCE',
    alertLevel: 'WARNING',
    alertTitle: '迟到提醒',
    alertContent: '王小明同学今日迟到15分钟',
    alertTime: '2026-04-16T16:45:00Z',
    isRead: false
  }
];

export const mockAlerts: AlertRecord[] = [
  {
    id: 1,
    studentId: 1,
    studentName: '王小明',
    alertType: 'ATTENDANCE_ANOMALY',
    severity: 'HIGH',
    title: '未按时签到',
    description: '学生今日未在规定时间内完成签到，请及时关注',
    suggestedAction: '请联系班主任确认学生情况',
    status: 'ACTIVE',
    createdAt: '2026-04-16T09:00:00Z',
    updatedAt: '2026-04-16T09:00:00Z'
  },
  {
    id: 2,
    studentId: 1,
    studentName: '王小明',
    alertType: 'SAFETY_CONCERN',
    severity: 'MEDIUM',
    title: '位置异常',
    description: '学生签到位置与活动地点不符',
    suggestedAction: '请核实学生实际位置',
    status: 'ACTIVE',
    createdAt: '2026-04-16T10:30:00Z',
    updatedAt: '2026-04-16T10:30:00Z'
  },
  {
    id: 3,
    studentId: 2,
    studentName: '李小红',
    alertType: 'ACADEMIC_PERFORMANCE',
    severity: 'LOW',
    title: '作业完成率下降',
    description: '学生本周作业完成率较上周下降20%',
    suggestedAction: '建议与家长沟通了解情况',
    status: 'ACKNOWLEDGED',
    acknowledgedBy: 1,
    acknowledgedAt: '2026-04-16T11:00:00Z',
    createdAt: '2026-04-16T08:00:00Z',
    updatedAt: '2026-04-16T11:00:00Z'
  }
];

export const mockAlertStatistics: AlertStatistics = {
  total: 5,
  active: 2,
  acknowledged: 1,
  resolved: 2,
  byType: {
    ATTENDANCE_ANOMALY: 3,
    SAFETY_CONCERN: 1,
    ACADEMIC_PERFORMANCE: 1
  },
  bySeverity: {
    HIGH: 1,
    MEDIUM: 1,
    LOW: 3
  }
};
