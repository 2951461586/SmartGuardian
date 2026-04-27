/**
 * SmartGuardian - Parent Home Page
 * Parent dashboard refactored into the new light campus style
 */

import {
  IconActionButton,
  LoadingSize,
  LoadingState,
  ParentScheduleNode,
  WorkbenchActionGrid
} from '../../components/common';
import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { getRolePalette } from '../../common/RoleTheme';
import { RouteUrls, StorageKeys } from '../../constants/app.constants';
import { ErrorMessages } from '../../constants/ErrorMessages';
import { TodayStatusCard } from '../../models/card';
import { HomeworkQueryParams, UserRole } from '../../models/common';
import { HomeworkTask } from '../../models/homework';
import { WorkbenchManifest, WorkbenchModule } from '../../models/workbench';
import { CardService } from '../../services/api/card';
import { HomeworkService } from '../../services/api/homework';
import { MessageService } from '../../services/api/message';
import { HarmonyCapabilityService } from '../../services/HarmonyCapabilityService';
import { StudentStore } from '../../stores/studentStore';
import { UserStore } from '../../stores/userStore';

@Entry
@Component
struct ParentHomePage {
  build() {
    Stack() {
      ParentHomePageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct ParentHomePageContent {
  @State userName: string = '';
  @State todaySummary: TodayStatusCard | null = null;
  @State recentHomework: HomeworkTask[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State unreadCount: number = 0;
  @State alertSummary: string = '';
  @State workbenchManifest: WorkbenchManifest | null = null;

  aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
    }
    this.loadWorkbenchManifest();
    this.loadData();
  }

  private loadWorkbenchManifest(): void {
    const manifest = AppStorage.get<WorkbenchManifest>(StorageKeys.WORKBENCH_MANIFEST);
    if (manifest && manifest.roleType === 'PARENT') {
      this.workbenchManifest = manifest;
    }
  }

  async loadData() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const studentId = StudentStore.getCurrentStudentId() ?? undefined;
      const params: HomeworkQueryParams = { pageSize: 3 };

      const summaryPromise = CardService.getTodayStatus(studentId);
      const homeworkPromise = HomeworkService.getTasks(params);
      const unreadPromise = MessageService.getUnreadCount();
      const alertPromise = CardService.getAbnormalAlert(studentId);

      const summaryResp = await summaryPromise;
      const homeworkResp = await homeworkPromise;
      const unreadResp = await unreadPromise;
      const alertResp = await alertPromise;

      if (summaryResp.code === 0 && summaryResp.data) {
        this.todaySummary = summaryResp.data;
      }

      if (homeworkResp.code === 0 && homeworkResp.data && homeworkResp.data.list) {
        this.recentHomework = homeworkResp.data.list;
      } else {
        this.recentHomework = [];
      }

      this.unreadCount = unreadResp.code === 0 && unreadResp.data ? unreadResp.data.count : (this.todaySummary?.messages ?? 0);
      await HarmonyCapabilityService.syncMessageBadge(this.unreadCount);

      if (alertResp.code === 0 && alertResp.data) {
        this.alertSummary = alertResp.data.alertTitle || alertResp.data.alertContent || '';
      } else {
        this.alertSummary = '';
      }
    } catch (error) {
      this.errorMessage = ErrorMessages.DATA_LOAD_FAILED;
      this.todaySummary = null;
      this.recentHomework = [];
      this.unreadCount = 0;
      await HarmonyCapabilityService.syncMessageBadge(0);
      this.alertSummary = '';
    } finally {
      this.isLoading = false;
    }
  }

  private getCurrentStudent() {
    return StudentStore.getCurrentStudent();
  }

  private getDisplayStudentName(): string {
    return this.getCurrentStudent()?.name ?? this.todaySummary?.studentName ?? '当前学生';
  }

  private getDisplayStudentMeta(): string {
    const student = this.getCurrentStudent();
    const metaParts: string[] = [];
    if (student?.grade) {
      metaParts.push(student.grade);
    }
    if (student?.className) {
      metaParts.push(student.className);
    }
    return metaParts.length > 0 ? metaParts.join(' ') : '今日托管安排';
  }

  private getDisplayStudentNo(): string {
    return this.getCurrentStudent()?.studentNo ?? '--';
  }

  private getDisplaySchoolName(): string {
    return this.getCurrentStudent()?.schoolName ?? '智慧校园';
  }

  private getNoticeSummary(): string {
    return this.alertSummary || '关于近期托管服务安排的通知';
  }

  private getNoticeDateText(): string {
    if (this.todaySummary?.date) {
      return this.todaySummary.date.slice(5);
    }
    return '今日';
  }

  private getSessionTitle(): string {
    return this.todaySummary?.sessionName || '今日托管课程';
  }

  private getHomeworkFallbackText(): string {
    return this.todaySummary?.latestDynamic || this.todaySummary?.teacherFeedback || '老师暂未更新新的学习反馈。';
  }

  private getScheduleItems(): ParentScheduleNode[] {
    return [
      {
        time: this.todaySummary?.signInTime || '16:30',
        title: '入校签到',
        statusText: this.getSignStatusText(),
        statusColor: this.getSignStatusColor(),
        statusBgColor: this.getSignStatusBgColor()
      },
      {
        time: this.todaySummary?.sessionTime || '16:40 - 17:30',
        title: this.getSessionTitle(),
        statusText: this.getHomeworkStatusText(),
        statusColor: this.getHomeworkStatusColor(),
        statusBgColor: this.getHomeworkStatusBgColor()
      },
      {
        time: this.todaySummary?.signOutTime || '17:30 - 18:00',
        title: '家长接送',
        statusText: this.getSignOutStatusText(),
        statusColor: this.getSignOutStatusColor(),
        statusBgColor: this.getSignOutStatusBgColor()
      }
    ];
  }

  build() {
    Column() {
      this.buildDirectHeader()

      if (this.isLoading) {
        LoadingState({ loadingSize: LoadingSize.DEFAULT })
          .layoutWeight(1)
      } else {
        Scroll() {
          this.buildContent()
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildDirectHeader() {
    Row() {
      Column() {
        Text(this.userName.length > 0 ? `${this.userName}，您好` : '家长，您好')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Text(this.workbenchManifest?.visual.slogan ?? (this.todaySummary?.studentName ? `当前关注：${this.todaySummary.studentName}` : '实时同步学生签到、作业与托管安排'))
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 6 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      this.buildHeaderActions()
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 14 })
    .backgroundColor($r('app.color.card_background'))
    .border({
      width: { bottom: 1 },
      color: $r('app.color.divider'),
      style: BorderStyle.Solid
    })
  }

  @Builder
  private buildHeaderActions() {
    Row() {
      IconActionButton({
        icon: $r('app.media.ic_notification'),
        badgeCount: this.unreadCount,
        onButtonClick: () => {
          AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 2);
        }
      })

      Blank().width(10)

      IconActionButton({
        icon: $r('app.media.ic_qrcode'),
        onButtonClick: () => {
          this.pushPage(RouteUrls.PARENT_QRCODE);
        }
      })
    }
  }

  @Builder
  private buildContent() {
    Column() {
      Column() {
        Text(this.getDisplayStudentName())
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Text(`${this.getDisplaySchoolName()} · ${this.getDisplayStudentMeta()}`)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 6 })

        Text(`学号：${this.getDisplayStudentNo()}`)
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 6 })
      }
      .width('100%')
      .padding(18)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(20)
      .border({
        width: 1,
        color: $r('app.color.divider'),
        radius: 20,
        style: BorderStyle.Solid
      })

      this.buildScheduleCard()
      this.buildQuickActionsCard()
      this.buildHomeworkCard()
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 18 })
  }

  @Builder
  private buildScheduleCard() {
    Column() {
      Text('今日托管')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      ForEach(this.getScheduleItems(), (item: ParentScheduleNode) => {
        Row() {
          Text(item.time)
            .width(92)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))

          Column() {
            Text(item.title)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))

            Text(item.statusText)
              .fontSize(12)
              .fontColor(item.statusColor)
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ top: 12 })
      }, (item: ParentScheduleNode) => `${item.time}-${item.title}`)
    }
    .width('100%')
    .padding(18)
    .margin({ top: 12 })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(20)
    .border({
      width: 1,
      color: $r('app.color.divider'),
      radius: 20,
      style: BorderStyle.Solid
    })
  }

  @Builder
  private buildQuickActionsCard() {
    Column() {
      Text(this.workbenchManifest?.summary.title ?? '常用功能')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Text(this.workbenchManifest ? `能力清单：${this.workbenchManifest.version}` : '预约、订单、消息和学生动态入口。')
        .width('100%')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 6, bottom: 14 })

      this.buildQuickActionsContent()
    }
    .width('100%')
    .padding(18)
    .margin({ top: 12 })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(20)
    .border({
      width: 1,
      color: $r('app.color.divider'),
      radius: 20,
      style: BorderStyle.Solid
    })
  }

  @Builder
  private buildHomeworkCard() {
    Column() {
      Text('学习反馈')
        .width('100%')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      if (this.recentHomework.length > 0) {
        ForEach(this.recentHomework, (task: HomeworkTask) => {
          Text(task.title)
            .width('100%')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 10 })
        }, (task: HomeworkTask) => `${task.id}`)
      } else {
        Text(this.getHomeworkFallbackText())
          .width('100%')
          .fontSize(13)
          .lineHeight(20)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 10 })
      }
    }
    .width('100%')
    .padding(18)
    .margin({ top: 12 })
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(20)
    .border({
      width: 1,
      color: $r('app.color.divider'),
      radius: 20,
      style: BorderStyle.Solid
    })
  }

  @Builder
  private buildQuickActionsContent() {
    WorkbenchActionGrid({
      modules: this.getActionModules(),
      titleFontSize: $r('app.float.text_secondary_size'),
      subtitleResolver: (code: string): string => this.getModuleSubtitle(code),
      iconResolver: (code: string): Resource => this.getModuleIcon(code),
      bgColorResolver: (code: string): string => this.getModuleBgColor(code),
      iconColorResolver: (code: string): string => this.getModuleIconColor(code),
      onModuleClick: (module: WorkbenchModule): void => this.openWorkbenchModule(module)
    })
  }

  private getActionModules(): WorkbenchModule[] {
    const manifestModules = this.workbenchManifest?.modules?.filter((module: WorkbenchModule) => module.enabled && module.code !== 'home') ?? [];
    if (manifestModules.length > 0) {
      return manifestModules;
    }
    return [
      { code: 'services', name: '托管预约', route: '/parent/services', enabled: true },
      { code: 'orders', name: '我的订单', route: '/parent/orders', enabled: true },
      { code: 'timeline', name: '成长动态', route: '/parent/timeline', enabled: true },
      { code: 'messages', name: '家校消息', route: '/parent/messages', enabled: true },
      { code: 'homework', name: '作业辅导', route: '/parent/homework', enabled: true },
      { code: 'sessions', name: '在校安排', route: '/parent/sessions', enabled: true },
      { code: 'alerts', name: '安全守护', route: '/parent/alerts', enabled: true },
      { code: 'profile', name: '家庭与设置', route: '/parent/profile', enabled: true },
      { code: 'children', name: '孩子档案', route: '/parent/children', enabled: true },
      { code: 'payment', name: '费用缴纳', route: '/parent/payment', enabled: true }
    ];
  }

  private getModuleSubtitle(code: string): string {
    if (code === 'services') return '在线预约';
    if (code === 'orders') return '查看订单';
    if (code === 'timeline') return '成长记录';
    if (code === 'messages') return '联系老师';
    if (code === 'homework') return '作业与反馈';
    if (code === 'sessions') return '查看安排';
    if (code === 'alerts') return '风险提醒';
    if (code === 'profile') return '家庭资料';
    if (code === 'children') return '学生档案';
    if (code === 'payment') return '在线缴费';
    return '进入模块';
  }

  private getModuleIcon(code: string): Resource {
    if (code === 'services') return $r('app.media.ic_calendar');
    if (code === 'orders') return $r('app.media.ic_order');
    if (code === 'timeline') return $r('app.media.ic_child');
    if (code === 'messages') return $r('app.media.ic_message');
    if (code === 'homework') return $r('app.media.ic_homework');
    if (code === 'sessions') return $r('app.media.ic_attendance');
    if (code === 'alerts') return $r('app.media.ic_warning');
    if (code === 'profile') return $r('app.media.ic_profile');
    if (code === 'children') return $r('app.media.ic_child');
    if (code === 'payment') return $r('app.media.ic_money');
    return $r('app.media.ic_home');
  }

  private getModuleBgColor(code: string): string {
    if (code === 'orders' || code === 'homework' || code === 'profile') return HarmonyReport.cautionSurface;
    if (code === 'messages') return getRolePalette(UserRole.ORG_ADMIN).light;
    if (code === 'alerts') return HarmonyReport.dangerSurface;
    if (code === 'timeline' || code === 'sessions') return HarmonyReport.positiveSurface;
    return HarmonyReport.accentSurface;
  }

  private getModuleIconColor(code: string): string {
    if (code === 'orders' || code === 'homework' || code === 'profile') return HarmonyReport.caution;
    if (code === 'timeline' || code === 'sessions') return HarmonyReport.positive;
    if (code === 'messages') return getRolePalette(UserRole.ORG_ADMIN).primary;
    if (code === 'alerts') return HarmonyReport.danger;
    return HarmonyColor.info;
  }

  private openWorkbenchModule(module: WorkbenchModule): void {
    if (module.code === 'home') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 0);
      return;
    }
    if (module.code === 'services') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 1);
      return;
    }
    if (module.code === 'messages') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 2);
      return;
    }
    if (module.code === 'timeline') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 3);
      return;
    }
    if (module.code === 'profile') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 4);
      return;
    }
    if (module.code === 'orders') {
      this.pushPage(RouteUrls.PARENT_ORDERS);
    } else if (module.code === 'children') {
      this.pushPage(RouteUrls.PARENT_CHILDREN);
    } else if (module.code === 'payment') {
      this.pushPage(RouteUrls.PARENT_PAYMENT);
    } else if (module.code === 'homework') {
      this.pushPage(RouteUrls.PARENT_HOMEWORK);
    } else if (module.code === 'sessions') {
      this.pushPage(RouteUrls.PARENT_SESSIONS);
    } else if (module.code === 'alerts') {
      this.pushPage(RouteUrls.PARENT_ALERTS);
    }
  }

  private pushPage(url: string): void {
    try {
      this.getUIContext().getRouter().pushUrl({ url });
    } catch (error) {
      console.error('ParentHomePage navigate failed:', String(error));
    }
  }

  private getSignStatusText(): string {
    if (this.todaySummary?.status === 'SIGNED_IN' || this.todaySummary?.status === 'SIGNED_OUT' || this.todaySummary?.status === 'IN_PROGRESS') {
      return '已签到';
    }
    return '待签到';
  }

  private getSignStatusColor(): string {
    return this.todaySummary?.status === 'NOT_SIGNED' ? HarmonyReport.caution : HarmonyReport.positive;
  }

  private getSignStatusBgColor(): string {
    return this.todaySummary?.status === 'NOT_SIGNED' ? HarmonyReport.cautionSurface : HarmonyReport.positiveSurface;
  }

  private getHomeworkStatusText(): string {
    const progress = this.todaySummary?.homeworkProgress ?? 0;
    if (progress >= 100) {
      return '已完成';
    }
    if (progress > 0) {
      return '进行中';
    }
    return '未开始';
  }

  private getHomeworkStatusColor(): string {
    const progress = this.todaySummary?.homeworkProgress ?? 0;
    if (progress >= 100) {
      return HarmonyReport.positive;
    }
    if (progress > 0) {
      return HarmonyColor.info;
    }
    return HarmonyColor.textTertiary;
  }

  private getHomeworkStatusBgColor(): string {
    const progress = this.todaySummary?.homeworkProgress ?? 0;
    if (progress >= 100) {
      return HarmonyReport.positiveSurface;
    }
    if (progress > 0) {
      return HarmonyReport.accentSurface;
    }
    return HarmonyColor.surfaceSubtle;
  }

  private getSignOutStatusText(): string {
    return this.todaySummary?.status === 'SIGNED_OUT' ? '已完成' : '未开始';
  }

  private getSignOutStatusColor(): string {
    return this.todaySummary?.status === 'SIGNED_OUT' ? HarmonyReport.positive : HarmonyColor.textTertiary;
  }

  private getSignOutStatusBgColor(): string {
    return this.todaySummary?.status === 'SIGNED_OUT' ? HarmonyReport.positiveSurface : HarmonyColor.surfaceSubtle;
  }
}

