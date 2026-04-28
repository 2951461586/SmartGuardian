/**
 * SmartGuardian - Teacher Home Page
 * Teacher dashboard refactored into shared dashboard sections.
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { getRolePalette } from '../../common/RoleTheme';
import {
  DashboardPageTemplate,
  GreetingHeader,
  HeaderTheme,
  IconActionButton,
  LoadingSize,
  LoadingState,
  TeacherHomeSessionSection,
  TeacherHomeWorkbenchSection,
  TeacherSessionHeroCard,
  TeacherSessionListItemData,
  TeacherSessionSummaryData,
  StatRowItem
} from '../../components/common';
import { RouteUrls, StorageKeys } from '../../constants/app.constants';
import { ErrorMessages } from '../../constants/ErrorMessages';
import { AttendanceRecord } from '../../models/attendance';
import { UserRole } from '../../models/common';
import { WorkbenchManifest, WorkbenchModule } from '../../models/workbench';
import { AttendanceService } from '../../services/api/attendance';
import { MessageService } from '../../services/api/message';
import { SessionSchedule, SessionService } from '../../services/api/service';
import { HarmonyCapabilityService } from '../../services/HarmonyCapabilityService';
import { UserStore } from '../../stores/userStore';
import { formatDate, formatTime } from '../../utils/date';

interface SessionQueryParams {
  sessionDate: string;
  teacherUserId?: number;
}

@Entry
@Component
struct TeacherHomePage {
  build() {
    Stack() {
      TeacherHomePageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct TeacherHomePageContent {
  @State userName: string = '';
  @State todaySessions: SessionSchedule[] = [];
  @State todayAttendance: AttendanceRecord[] = [];
  @State isLoading: boolean = true;
  @State currentSession: SessionSchedule | null = null;
  @State errorMessage: string = '';
  @State unreadCount: number = 0;
  @State workbenchManifest: WorkbenchManifest | null = null;

  async aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
    }
    this.loadWorkbenchManifest();
    await this.loadData();
  }

  private loadWorkbenchManifest(): void {
    const manifest = AppStorage.get<WorkbenchManifest>(StorageKeys.WORKBENCH_MANIFEST);
    if (manifest && manifest.roleType === 'TEACHER') {
      this.workbenchManifest = manifest;
    }
  }

  async loadData() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const today = formatDate(new Date());
      const teacherUserId = UserStore.getUserInfo()?.id;
      const sessionParams: SessionQueryParams = { sessionDate: today };
      if (teacherUserId) {
        sessionParams.teacherUserId = teacherUserId;
      }

      const sessionsResp = await SessionService.getSessions(sessionParams);
      const unreadResp = await MessageService.getUnreadCount();

      if (sessionsResp.code === 0 && sessionsResp.data) {
        this.todaySessions = sessionsResp.data;
        this.currentSession = this.resolveCurrentSession();
      } else {
        this.todaySessions = [];
        this.currentSession = null;
      }

      this.unreadCount = unreadResp.code === 0 && unreadResp.data ? unreadResp.data.count : 0;
      await HarmonyCapabilityService.syncMessageBadge(this.unreadCount);

      if (this.currentSession) {
        const attendanceResp = await AttendanceService.getAttendanceList({
          sessionId: this.currentSession.id,
          attendanceDate: today
        });
        if (attendanceResp.code === 0 && attendanceResp.data && attendanceResp.data.list) {
          this.todayAttendance = attendanceResp.data.list;
        } else {
          this.todayAttendance = [];
        }
      } else {
        this.todayAttendance = [];
      }
    } catch (error) {
      this.todaySessions = [];
      this.todayAttendance = [];
      this.currentSession = null;
      this.unreadCount = 0;
      this.errorMessage = ErrorMessages.DATA_LOAD_FAILED;
      await HarmonyCapabilityService.syncMessageBadge(0);
    } finally {
      this.isLoading = false;
    }
  }

  private resolveCurrentSession(): SessionSchedule | null {
    const ongoingSession = this.todaySessions.find((session: SessionSchedule) => session.status === 'ONGOING');
    if (ongoingSession) {
      return ongoingSession;
    }
    if (this.todaySessions.length > 0) {
      return this.todaySessions[0];
    }
    return null;
  }

  private getDisplaySession(): SessionSchedule | null {
    return this.currentSession ?? this.resolveCurrentSession();
  }

  private hasDisplaySession(): boolean {
    return this.getDisplaySession() !== null;
  }

  private getSignedCount(): number {
    return this.todayAttendance.filter((record: AttendanceRecord) =>
      record.status === 'SIGNED_IN' || record.status === 'SIGNED_OUT'
    ).length;
  }

  private getUnsignedCount(): number {
    return this.todayAttendance.filter((record: AttendanceRecord) => record.status === 'NOT_SIGNED').length;
  }

  private getSessionStatusText(status?: string): string {
    if (status === 'ONGOING') {
      return '进行中';
    }
    if (status === 'ENDED') {
      return '已结束';
    }
    return '待开始';
  }

  private getSessionStatusColor(status?: string): string {
    if (status === 'ONGOING') {
      return HarmonyReport.positive;
    }
    if (status === 'ENDED') {
      return HarmonyColor.textSecondary;
    }
    return HarmonyColor.info;
  }

  private getSessionStatusBgColor(status?: string): string {
    if (status === 'ONGOING') {
      return HarmonyReport.positiveSurface;
    }
    if (status === 'ENDED') {
      return HarmonyColor.surfaceSubtle;
    }
    return HarmonyReport.accentSurface;
  }

  private getHeroTitle(): string {
    return this.getDisplaySession()?.serviceProductName ?? '今日暂无授课班次';
  }

  private getHeroTimeText(): string {
    const session = this.getDisplaySession();
    if (!session) {
      return '可前往课程安排查看后续排班';
    }
    return `${formatTime(session.startTime)} - ${formatTime(session.endTime)}`;
  }

  private getHeroStatusText(): string {
    return this.getSessionStatusText(this.getDisplaySession()?.status);
  }

  private getSessionSummaryData(): TeacherSessionSummaryData {
    const session = this.getDisplaySession();
    return {
      title: session?.serviceProductName ?? '托管班次',
      timeText: session ? `${formatTime(session.startTime)} - ${formatTime(session.endTime)}` : '',
      statusText: this.getSessionStatusText(session?.status),
      statusColor: this.getSessionStatusColor(session?.status),
      statusBgColor: this.getSessionStatusBgColor(session?.status),
      signedCount: `${this.getSignedCount()}`,
      unsignedCount: `${this.getUnsignedCount()}`
    };
  }

  private getSessionListItems(): TeacherSessionListItemData[] {
    const todayText = formatDate(new Date());
    return this.todaySessions.map((session: SessionSchedule): TeacherSessionListItemData => {
      return {
        id: session.id,
        title: session.serviceProductName ?? '托管班次',
        subtitle: `${formatTime(session.startTime)} - ${formatTime(session.endTime)} | ${todayText}`,
        statusText: this.getSessionStatusText(session.status),
        statusColor: this.getSessionStatusColor(session.status),
        statusBgColor: this.getSessionStatusBgColor(session.status)
      };
    });
  }

  private getTopOverviewItems(): StatRowItem[] {
    return [
      {
        value: `${this.todaySessions.length}`,
        label: '今日班次',
        icon: $r('app.media.ic_calendar'),
        iconColor: HarmonyReport.positive
      },
      {
        value: `${this.getUnsignedCount()}`,
        label: '待签到',
        icon: $r('app.media.ic_warning'),
        iconColor: HarmonyReport.caution
      }
    ];
  }

  private getBottomOverviewItems(): StatRowItem[] {
    return [
      {
        value: `${this.getSignedCount()}`,
        label: '已签到',
        icon: $r('app.media.ic_attendance'),
        iconColor: HarmonyReport.positive
      },
      {
        value: `${this.unreadCount}`,
        label: '未读消息',
        icon: $r('app.media.ic_message'),
        iconColor: getRolePalette(UserRole.TEACHER).primary
      }
    ];
  }

  private getActionModules(): WorkbenchModule[] {
    const manifestModules = this.workbenchManifest?.modules?.filter((module: WorkbenchModule) => module.enabled && module.code !== 'home') ?? [];
    if (manifestModules.length > 0) {
      return manifestModules;
    }
    return [
      { code: 'scan', name: '扫码签到', route: '/teacher/scan', enabled: true },
      { code: 'attendance', name: '考勤管理', route: '/teacher/attendance', enabled: true },
      { code: 'homework', name: '作业管理', route: '/teacher/homework', enabled: true },
      { code: 'schedule', name: '课程安排', route: '/teacher/schedule', enabled: true },
      { code: 'messages', name: '家校消息', route: '/teacher/messages', enabled: true },
      { code: 'students', name: '学生档案', route: '/teacher/students', enabled: true },
      { code: 'resources', name: '教学资源', route: '/teacher/resources', enabled: true },
      { code: 'profile', name: '我的', route: '/teacher/profile', enabled: true }
    ];
  }

  private getModuleSubtitle(code: string): string {
    if (code === 'scan') return '快速核验';
    if (code === 'attendance') return '查看明细';
    if (code === 'homework') return '布置反馈';
    if (code === 'schedule') return '查看排班';
    if (code === 'messages') return '联系家长';
    if (code === 'students') return '学生档案';
    if (code === 'resources') return '资料沉淀';
    if (code === 'profile') return '个人设置';
    return '进入模块';
  }

  private getModuleIcon(code: string): Resource {
    if (code === 'scan') return $r('app.media.ic_qrcode');
    if (code === 'attendance') return $r('app.media.ic_attendance');
    if (code === 'homework') return $r('app.media.ic_homework');
    if (code === 'schedule') return $r('app.media.ic_calendar');
    if (code === 'messages') return $r('app.media.ic_message');
    if (code === 'students') return $r('app.media.ic_child');
    if (code === 'resources') return $r('app.media.ic_service');
    if (code === 'profile') return $r('app.media.ic_profile');
    return $r('app.media.ic_home');
  }

  private getModuleBgColor(code: string): string {
    if (code === 'homework') return HarmonyReport.cautionSurface;
    if (code === 'schedule' || code === 'messages') return getRolePalette(UserRole.TEACHER).light;
    return HarmonyReport.positiveSurface;
  }

  private getModuleIconColor(code: string): string {
    if (code === 'homework') return HarmonyReport.caution;
    if (code === 'schedule' || code === 'messages') return getRolePalette(UserRole.TEACHER).primary;
    return HarmonyReport.positive;
  }

  private openWorkbenchModule(module: WorkbenchModule): void {
    if (module.code === 'home') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 0);
      return;
    }
    if (module.code === 'attendance') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 1);
      return;
    }
    if (module.code === 'messages') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 2);
      return;
    }
    if (module.code === 'homework') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 3);
      return;
    }
    if (module.code === 'profile') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 4);
      return;
    }
    if (module.code === 'scan') {
      this.pushPage(RouteUrls.TEACHER_SCAN);
    } else if (module.code === 'schedule') {
      this.pushPage(RouteUrls.TEACHER_SCHEDULE);
    } else if (module.code === 'students') {
      this.pushPage(RouteUrls.TEACHER_STUDENT_DETAIL);
    }
  }

  private pushPage(url: string): void {
    try {
      this.getUIContext().getRouter().pushUrl({ url });
    } catch (error) {
      console.error('TeacherHomePage navigate failed:', String(error));
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        LoadingState({ loadingSize: LoadingSize.DEFAULT })
      } else {
        DashboardPageTemplate({
          scrollable: true,
          enableWideContent: true,
          header: () => { this.buildHeader() },
          hero: () => { this.buildHero() },
          primary: () => { this.buildWorkbenchSection() },
          secondary: () => { this.buildSessionSection() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildHeader() {
    GreetingHeader({
      userName: this.userName,
      greeting: this.workbenchManifest?.summary.description ?? '统一查看班次安排、考勤进度和作业处理情况。',
      theme: HeaderTheme.WHITE,
      badgeText: '教师端',
      metaText: this.workbenchManifest?.visual.slogan ?? (this.currentSession?.serviceProductName ? `当前班次：${this.currentSession.serviceProductName}` : '今日授课安排与签到状态总览')
    }) {
      this.buildHeaderActions()
    }
  }

  @Builder
  private buildHeaderActions() {
    IconActionButton({
      icon: $r('app.media.ic_notification'),
      badgeCount: this.unreadCount,
      onButtonClick: () => {
        this.pushPage(RouteUrls.TEACHER_MESSAGES);
      }
    })
  }

  @Builder
  private buildHero() {
    TeacherSessionHeroCard({
      sessionTitle: this.getHeroTitle(),
      timeText: this.getHeroTimeText(),
      sessionCount: `${this.todaySessions.length}`,
      signedCount: `${this.getSignedCount()}`,
      statusText: this.getHeroStatusText()
    })
      .margin({ bottom: 14 })
  }

  @Builder
  private buildWorkbenchSection() {
    TeacherHomeWorkbenchSection({
      overviewTopItems: this.getTopOverviewItems(),
      overviewBottomItems: this.getBottomOverviewItems(),
      quickActionTitle: this.workbenchManifest?.summary.title ?? '常用操作',
      quickActionSubtitle: this.workbenchManifest ? `能力清单：${this.workbenchManifest.version}` : '把高频教学任务集中到首页。',
      modules: this.getActionModules(),
      subtitleResolver: (code: string): string => this.getModuleSubtitle(code),
      iconResolver: (code: string): Resource => this.getModuleIcon(code),
      bgColorResolver: (code: string): string => this.getModuleBgColor(code),
      iconColorResolver: (code: string): string => this.getModuleIconColor(code),
      onModuleClick: (module: WorkbenchModule): void => this.openWorkbenchModule(module)
    })
  }

  @Builder
  private buildSessionSection() {
    TeacherHomeSessionSection({
      hasSession: this.hasDisplaySession(),
      statsSubtitle: this.currentSession ? '聚焦当前进行中的班次和签到进度。' : '当前没有进行中的班次，展示今日最近安排。',
      statsEmptyDescription: this.errorMessage || '稍后刷新，或前往课程安排查看最新计划。',
      sessionSummary: this.getSessionSummaryData(),
      sessionItems: this.getSessionListItems(),
      sessionEmptyDescription: this.errorMessage || '当前没有可展示的班次数据。',
      onSessionAction: (): void => {
        this.pushPage(RouteUrls.TEACHER_SCHEDULE);
      }
    })
  }
}
