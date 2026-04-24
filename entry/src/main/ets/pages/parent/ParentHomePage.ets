/**
 * SmartGuardian - Parent Home Page
 * Parent dashboard refactored into the new light campus style
 */

import {
  Card,
  GreetingHeader,
  HeaderTheme,
  IconActionButton,
  LoadingSize,
  LoadingState
} from '../../components/common';
import { ErrorMessages } from '../../constants/ErrorMessages';
import { TodayStatusCard } from '../../models/card';
import { HomeworkQueryParams } from '../../models/common';
import { HomeworkTask } from '../../models/homework';
import { WorkbenchManifest, WorkbenchModule } from '../../models/workbench';
import { CardService } from '../../services/api/card';
import { HomeworkService } from '../../services/api/homework';
import { MessageService } from '../../services/api/message';
import { StudentStore } from '../../stores/studentStore';
import { UserStore } from '../../stores/userStore';

@Component
export struct ParentHomePage {
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
    const manifest = AppStorage.get<WorkbenchManifest>('workbench_manifest');
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

  private getSessionTitle(): string {
    return this.todaySummary?.sessionName || '今日托管课程';
  }

  build() {
    Column() {
      GreetingHeader({
        userName: this.userName,
        greeting: this.workbenchManifest?.summary.description ?? '欢迎使用智慧学生管理系统 · 家长端',
        theme: HeaderTheme.WHITE,
        badgeText: '家长端',
        metaText: this.workbenchManifest?.visual.slogan ?? (this.todaySummary?.studentName ? `当前关注：${this.todaySummary.studentName}` : '实时同步学生签到、作业与托管安排')
      }) {
        this.buildHeaderActions()
      }

      if (this.isLoading) {
        LoadingState({ loadingSize: LoadingSize.DEFAULT })
      } else {
        this.buildContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildHeaderActions() {
    Row() {
      IconActionButton({
        icon: $r('app.media.ic_notification'),
        badgeCount: this.unreadCount,
        onButtonClick: () => {
          AppStorage.setOrCreate('main_current_index', 2);
        }
      })

      Blank().width(10)

      IconActionButton({
        icon: $r('app.media.ic_qrcode'),
        onButtonClick: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentQRCodePage' });
        }
      })
    }
  }

  @Builder
  private buildContent() {
    Scroll() {
      Column() {
        this.buildStudentHeroCard()
        this.buildNoticeCard()
        this.buildQuickActionsCard()
        this.buildScheduleCard()
        this.buildHomeworkCard()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 24 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  private buildStudentHeroCard() {
    Row() {
      Row() {
        Image($r('app.media.ic_default_avatar'))
          .width(70)
          .height(70)
          .objectFit(ImageFit.Cover)
      }
      .width(86)
      .height(86)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')
      .borderRadius(43)

      Column() {
        Row() {
          Text(this.getDisplayStudentName())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.getDisplayStudentMeta())
            .fontSize(11)
            .fontColor('#0A59F7')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor('#EEF4FA')
            .borderRadius(999)
            .margin({ left: 10 })
        }
        .width('100%')

        Text(`学号：${this.getDisplayStudentNo()}`)
          .fontSize(14)
          .fontColor('#FFFFFFD9')
          .margin({ top: 10 })

        Text(`学校：${this.getDisplaySchoolName()}`)
          .fontSize(14)
          .fontColor('#FFFFFFD9')
          .margin({ top: 6 })

        Text(this.getSessionTitle())
          .fontSize(13)
          .fontColor('#FFFFFFCC')
          .margin({ top: 10 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })

      Image($r('app.media.sg_illustration_children'))
        .width(104)
        .height(92)
        .objectFit(ImageFit.Contain)
        .opacity(0.88)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .linearGradient({
      angle: 130,
      colors: [['#0A59F7', 0], ['#4D8DFF', 0.62], ['#DCEAFF', 1]]
    })
    .border({
      width: 1,
      color: '#D8E6FF',
      radius: 28,
      style: BorderStyle.Solid
    })
    .borderRadius(28)
    .shadow({
      radius: 18,
      color: '#0A59F726',
      offsetX: 0,
      offsetY: 10
    })
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: 14 })
  }

  @Builder
  private buildNoticeCard() {
    Row() {
      Column() {
        Text('系统')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary'))

        Text('通知')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary'))
          .margin({ top: 2 })
      }
      .width(48)
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(this.getNoticeSummary())
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12, right: 12 })

      Text(this.todaySummary?.date ? this.todaySummary.date.slice(5) : '今日')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(22)
    .border({
      width: 1,
      color: '#E6ECF5',
      radius: 22,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 12,
      color: '#526F950D',
      offsetX: 0,
      offsetY: 6
    })
    .margin({ bottom: 14 })
  }

  @Builder
  private buildQuickActionsCard() {
    Card({
      title: this.workbenchManifest?.summary.title ?? '常用功能',
      subtitle: this.workbenchManifest ? `能力清单：${this.workbenchManifest.version}` : '预约、订单、消息和学生动态入口。',
      actionText: '全部功能',
      onAction: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentServicesPage' });
      },
      content: this.buildQuickActionsContent
    })
  }

  @Builder
  private buildQuickActionsContent() {
    Column() {
      Row() {
        ForEach(this.getFirstActionRow(), (module: WorkbenchModule) => {
          this.buildManifestFeatureItem(module)
        })
      }
      .width('100%')

      if (this.getSecondActionRow().length > 0) {
        Row() {
          ForEach(this.getSecondActionRow(), (module: WorkbenchModule) => {
            this.buildManifestFeatureItem(module)
          })
        }
        .width('100%')
        .margin({ top: 14 })
      }
    }
    .width('100%')
  }

  @Builder
  private buildManifestFeatureItem(module: WorkbenchModule) {
    this.buildFeatureItem(module.name, this.getModuleSubtitle(module.code), this.getModuleIcon(module.code), this.getModuleBgColor(module.code), this.getModuleIconColor(module.code), () => {
      this.openWorkbenchModule(module);
    })
  }

  @Builder
  private buildFeatureItem(title: string, subtitle: string, icon: Resource, bgColor: string, iconColor: string, onClick: () => void) {
    Column() {
      Column() {
        Image(icon)
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
          .fillColor(iconColor)
      }
      .width(52)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(bgColor)
      .borderRadius(18)

      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 10 })

      Text(subtitle)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => onClick())
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

  private getFirstActionRow(): WorkbenchModule[] {
    return this.getActionModules().slice(0, 5);
  }

  private getSecondActionRow(): WorkbenchModule[] {
    return this.getActionModules().slice(5, 10);
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
    if (code === 'orders' || code === 'homework' || code === 'profile') return '#F6F0E9';
    if (code === 'messages') return '#F2F0F7';
    if (code === 'alerts') return '#F8EEEE';
    return '#EEF4FA';
  }

  private getModuleIconColor(code: string): string {
    if (code === 'orders' || code === 'profile') return '#8A6A4E';
    if (code === 'timeline' || code === 'sessions') return '#5D8267';
    if (code === 'messages') return '#7B6D96';
    if (code === 'homework') return '#A9794E';
    if (code === 'alerts') return '#A75A61';
    return '#526F95';
  }

  private openWorkbenchModule(module: WorkbenchModule): void {
    if (module.code === 'home') {
      AppStorage.setOrCreate('main_current_index', 0);
      return;
    }
    if (module.code === 'services') {
      AppStorage.setOrCreate('main_current_index', 1);
      return;
    }
    if (module.code === 'messages') {
      AppStorage.setOrCreate('main_current_index', 2);
      return;
    }
    if (module.code === 'timeline') {
      AppStorage.setOrCreate('main_current_index', 3);
      return;
    }
    if (module.code === 'profile') {
      AppStorage.setOrCreate('main_current_index', 4);
      return;
    }
    if (module.code === 'orders') {
      this.pushPage('pages/parent/ParentOrdersPage');
    } else if (module.code === 'children') {
      this.pushPage('pages/parent/ParentChildrenPage');
    } else if (module.code === 'payment') {
      this.pushPage('pages/parent/ParentPaymentPage');
    } else if (module.code === 'homework') {
      this.pushPage('pages/parent/ParentHomeworkPage');
    } else if (module.code === 'sessions') {
      this.pushPage('pages/parent/ParentSessionsPage');
    } else if (module.code === 'alerts') {
      this.pushPage('pages/parent/ParentAlertsPage');
    }
  }

  private pushPage(url: string): void {
    try {
      this.getUIContext().getRouter().pushUrl({ url });
    } catch (error) {
      console.error('ParentHomePage navigate failed:', String(error));
    }
  }

  @Builder
  private buildScheduleCard() {
    Card({
      title: '今日托管安排',
      actionText: '查看全部',
      onAction: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentTimelinePage' });
      },
      content: this.buildScheduleContent
    })
  }

  @Builder
  private buildScheduleContent() {
    Column() {
      this.buildScheduleItem(this.todaySummary?.signInTime || '16:30', '入校签到', this.getSignStatusText(), this.getSignStatusColor(), this.getSignStatusBgColor())
      this.buildScheduleItem(this.todaySummary?.sessionTime || '16:40 - 17:30', this.getSessionTitle(), this.getHomeworkStatusText(), this.getHomeworkStatusColor(), this.getHomeworkStatusBgColor())
      this.buildScheduleItem(this.todaySummary?.signOutTime || '17:30 - 18:00', '家长接送', this.getSignOutStatusText(), this.getSignOutStatusColor(), this.getSignOutStatusBgColor())

      Row() {
        Image($r('app.media.ic_info'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.primary'))

        Text('温馨提示：请关注孩子的托管时间安排，及时查看动态。')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 12, bottom: 12 })
      .backgroundColor('#F7FAFE')
      .borderRadius(16)
      .margin({ top: 16 })
    }
    .width('100%')
  }

  @Builder
  private buildScheduleItem(time: string, title: string, statusText: string, statusColor: string, statusBgColor: string) {
    Row() {
      Text(time)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .width(94)

      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)

      Text(statusText)
        .fontSize(12)
        .fontColor(statusColor)
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor(statusBgColor)
        .borderRadius(999)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  @Builder
  private buildHomeworkCard() {
    Card({
      title: '学习反馈',
      subtitle: this.errorMessage ? this.errorMessage : '及时了解老师反馈和最近作业进度。',
      actionText: '查看全部',
      onAction: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentHomeworkPage' });
      },
      content: this.buildHomeworkContent
    })
  }

  @Builder
  private buildHomeworkContent() {
    if (this.recentHomework.length > 0) {
      Column() {
        ForEach(this.recentHomework, (item: HomeworkTask, index: number) => {
          Row() {
            Column() {
              Text(item.title || '今日学习任务')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(item.subject || item.content || '查看老师布置的最新任务与反馈')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .lineHeight(18)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: 6 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(item.status || '待查看')
              .fontSize(12)
              .fontColor($r('app.color.primary'))
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .backgroundColor('#EEF4FA')
              .borderRadius(999)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })

          if (index < this.recentHomework.length - 1) {
            Divider()
              .color($r('app.color.divider'))
              .margin({ top: 10, bottom: 10 })
          }
        })
      }
      .width('100%')
    } else {
      Column() {
        Text(this.todaySummary?.latestDynamic || this.todaySummary?.teacherFeedback || '老师暂未更新新的学习反馈。')
          .fontSize(14)
          .lineHeight(22)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  private getSignStatusText(): string {
    if (this.todaySummary?.status === 'SIGNED_IN' || this.todaySummary?.status === 'SIGNED_OUT' || this.todaySummary?.status === 'IN_PROGRESS') {
      return '已签到';
    }
    return '待签到';
  }

  private getSignStatusColor(): string {
    return this.todaySummary?.status === 'NOT_SIGNED' ? '#A9794E' : '#5D8267';
  }

  private getSignStatusBgColor(): string {
    return this.todaySummary?.status === 'NOT_SIGNED' ? '#F6F0E9' : '#EEF4FA';
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
      return '#5D8267';
    }
    if (progress > 0) {
      return '#526F95';
    }
    return '#8C9A93';
  }

  private getHomeworkStatusBgColor(): string {
    const progress = this.todaySummary?.homeworkProgress ?? 0;
    if (progress >= 100) {
      return '#EEF4FA';
    }
    if (progress > 0) {
      return '#EEF4FA';
    }
    return '#F5F1E8';
  }

  private getSignOutStatusText(): string {
    return this.todaySummary?.status === 'SIGNED_OUT' ? '已完成' : '未开始';
  }

  private getSignOutStatusColor(): string {
    return this.todaySummary?.status === 'SIGNED_OUT' ? '#2F9E77' : '#8C9A93';
  }

  private getSignOutStatusBgColor(): string {
    return this.todaySummary?.status === 'SIGNED_OUT' ? '#EEF4FA' : '#F5F1E8';
  }
}

