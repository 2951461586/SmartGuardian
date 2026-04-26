import { UserRole } from '../../../models/common';
import { WorkbenchManifest, WorkbenchModule } from '../../../models/workbench';
import { ApiEndpoints } from '../../../constants/ApiEndpoints';
import { HttpMethod, HttpResponse } from '../../../utils/request';
import { MockSessionState } from '../shared/mockState';
import { mockNotFound, mockResponse } from '../shared/mockUtils';

function teacherModules(): WorkbenchModule[] {
  return [
    { code: 'home', name: '工作台', route: '/teacher/home', enabled: true },
    { code: 'scan', name: '扫码签到', route: '/teacher/scan', enabled: true },
    { code: 'attendance', name: '考勤签到', route: '/teacher/attendance', enabled: true },
    { code: 'homework', name: '作业反馈', route: '/teacher/homework', enabled: true },
    { code: 'schedule', name: '班次日程', route: '/teacher/schedule', enabled: true },
    { code: 'messages', name: '家校消息', route: '/teacher/messages', enabled: true },
    { code: 'profile', name: '我的', route: '/teacher/profile', enabled: true }
  ];
}

function adminModules(): WorkbenchModule[] {
  return [
    { code: 'home', name: '运营总览', route: '/admin/home', enabled: true },
    { code: 'orders', name: '订单审核', route: '/admin/orders', enabled: true },
    { code: 'services', name: '服务管理', route: '/admin/services', enabled: true },
    { code: 'students', name: '学生档案', route: '/admin/students', enabled: true },
    { code: 'reports', name: '统计报表', route: '/admin/reports', enabled: true },
    { code: 'profile', name: '我的', route: '/admin/profile', enabled: true }
  ];
}

function parentModules(): WorkbenchModule[] {
  return [
    { code: 'home', name: '今日托管', route: '/parent/home', enabled: true },
    { code: 'services', name: '托管服务', route: '/parent/services', enabled: true },
    { code: 'orders', name: '我的订单', route: '/parent/orders', enabled: true },
    { code: 'timeline', name: '成长动态', route: '/parent/timeline', enabled: true },
    { code: 'messages', name: '家校消息', route: '/parent/messages', enabled: true },
    { code: 'payment', name: '费用缴纳', route: '/parent/payment', enabled: true },
    { code: 'profile', name: '家庭与设置', route: '/parent/profile', enabled: true }
  ];
}

export class WorkbenchMockHandler {
  static async getWorkbenchManifest(): Promise<HttpResponse<WorkbenchManifest>> {
    const currentUser = MockSessionState.getCurrentUser();
    const roleType = currentUser.roleType === UserRole.TEACHER
      ? UserRole.TEACHER
      : currentUser.roleType === UserRole.PARENT ? UserRole.PARENT : UserRole.ORG_ADMIN;
    const isTeacher = roleType === UserRole.TEACHER;
    const isAdmin = roleType === UserRole.ORG_ADMIN;
    const modules = isTeacher ? teacherModules() : isAdmin ? adminModules() : parentModules();
    return mockResponse({
      roleType,
      version: '2026.04.p1-mock-split',
      visual: {
        primary: isTeacher ? '#5D8267' : isAdmin ? '#7B6D96' : '#526F95',
        light: isTeacher ? '#EEF6F0' : isAdmin ? '#F2F0F7' : '#EEF4FA',
        surface: '浅灰蓝页面底 + 白色卡片',
        componentTone: '圆角卡片、柔和描边、轻阴影',
        slogan: isTeacher ? '教学管理更聚焦' : isAdmin ? '运营治理更统一' : '家校协同更安心'
      },
      summary: {
        title: isTeacher ? '教师工作台' : isAdmin ? '机构工作台' : '家长工作台',
        description: isTeacher ? '聚合签到、作业反馈和沟通处理。' : isAdmin ? '聚合订单、班次、服务和报表治理。' : '聚合今日托管、订单、消息和成长动态。',
        metrics: isTeacher ? ['今日班次', '待签到', '待反馈'] : isAdmin ? ['待审核订单', '班次负载', '活跃告警'] : ['今日状态', '待确认反馈', '未读消息']
      },
      primaryFlows: isTeacher ? [
        { code: 'attendance_peak', name: '高峰签到', description: '班次名册、扫码签到和异常复核闭环。' },
        { code: 'homework_feedback', name: '作业辅导', description: '进度记录、反馈提交和家长确认。' },
        { code: 'parent_message', name: '家校沟通', description: '围绕学生动态快速触达家长。' }
      ] : isAdmin ? [
        { code: 'order_audit', name: '订单审核', description: '预约、支付、审核和退款状态统一追踪。' },
        { code: 'session_capacity', name: '班次资源', description: '教师、教室、容量和名册统一调度。' },
        { code: 'operation_report', name: '经营分析', description: '考勤、财务和告警看板汇总。' }
      ] : [
        { code: 'today_guardian', name: '今日托管', description: '签到、辅导和异常提醒一屏掌握。' },
        { code: 'booking_payment', name: '预约支付', description: '浏览服务、创建订单和退款申请。' },
        { code: 'growth_timeline', name: '成长时间线', description: '作业反馈、老师评价和重要动态沉淀。' }
      ],
      modules: modules,
      integration: {
        apiBase: '/api/v1',
        auth: 'Bearer JWT',
        mockDefault: true,
        acceptance: ['Mock 演示可跑通', 'AGC 契约已对齐', '前端模型与工作台壳同源']
      }
    });
  }

  static async handleRequest<T>(path: string, method: HttpMethod): Promise<HttpResponse<T>> {
    if (path === ApiEndpoints.WORKBENCH_MANIFEST && method === HttpMethod.GET) {
      return this.getWorkbenchManifest() as Promise<HttpResponse<T>>;
    }
    return mockNotFound<T>();
  }
}
