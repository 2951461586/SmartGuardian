/**
 * SmartGuardian - Admin Home Page
 * Admin dashboard with the new light campus style.
 */

import { HarmonyReport } from '../../common/HarmonyDesign';
import { getRolePalette } from '../../common/RoleTheme';
import {
  ActivityFeedItem,
  AdminHomeOperationsSection,
  AdminHomeWorkbenchSection,
  GreetingHeader,
  HeaderTheme,
  IconActionButton,
  DashboardPageTemplate,
  LoadingSize,
  LoadingState,
  AdminSummaryHeroCard,
  StatRowItem,
} from '../../components/common';
import { RouteUrls, StorageKeys } from '../../constants/app.constants';
import { ErrorMessages } from '../../constants/ErrorMessages';
import { UserRole } from '../../models/common';
import { WorkbenchManifest, WorkbenchModule } from '../../models/workbench';
import { StudentService } from '../../services/api/auth';
import { MessageService } from '../../services/api/message';
import { ReportsService } from '../../services/api/reports';
import { OrderService } from '../../services/api/service';
import { UserStore } from '../../stores/userStore';

interface DashboardStats {
  totalStudents: number;
  presentStudents: number;
  attendanceRate: number;
  pendingOrders: number;
  unreadMessages: number;
  netIncome: number;
}

interface ActivityItem {
  title: string;
  content: string;
  time: string;
}

@Entry
@Component
struct AdminHomePage {
  build() {
    Stack() {
      AdminHomePageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct AdminHomePageContent {
  @State userName: string = '';
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State stats: DashboardStats = {
    totalStudents: 0,
    presentStudents: 0,
    attendanceRate: 0,
    pendingOrders: 0,
    unreadMessages: 0,
    netIncome: 0
  };
  @State recentActivities: ActivityItem[] = [];
  @State workbenchManifest: WorkbenchManifest | null = null;

  aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
    }
    this.loadWorkbenchManifest();
    this.loadDashboard();
  }

  private loadWorkbenchManifest(): void {
    const manifest = AppStorage.get<WorkbenchManifest>(StorageKeys.WORKBENCH_MANIFEST);
    if (manifest && (manifest.roleType === 'ORG_ADMIN' || manifest.roleType === 'ADMIN')) {
      this.workbenchManifest = manifest;
    }
  }

  async loadDashboard() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const studentsPromise = StudentService.getStudents({ pageNum: 1, pageSize: 1 });
      const attendancePromise = ReportsService.getAttendanceReport();
      const ordersPromise = OrderService.getOrders({ pageNum: 1, pageSize: 200, orderStatus: 'PENDING' });
      const messagesPromise = MessageService.getUnreadCount();
      const financePromise = ReportsService.getFinanceReport();

      const studentsResp = await studentsPromise;
      const attendanceResp = await attendancePromise;
      const ordersResp = await ordersPromise;
      const messagesResp = await messagesPromise;
      const financeResp = await financePromise;

      const totalStudents = studentsResp.code === 0 && studentsResp.data ? studentsResp.data.total : 0;
      const presentStudents = attendanceResp.code === 0 && attendanceResp.data ? attendanceResp.data.presentCount : 0;
      const attendanceRate = attendanceResp.code === 0 && attendanceResp.data ? Number(attendanceResp.data.attendanceRate ?? 0) : 0;
      const pendingOrders = ordersResp.code === 0 && ordersResp.data ? (ordersResp.data.list?.length ?? 0) : 0;
      const unreadMessages = messagesResp.code === 0 && messagesResp.data ? messagesResp.data.count : 0;
      const netIncome = financeResp.code === 0 && financeResp.data ? Number(financeResp.data.netIncome ?? 0) : 0;

      this.stats = {
        totalStudents,
        presentStudents,
        attendanceRate,
        pendingOrders,
        unreadMessages,
        netIncome
      };

      this.recentActivities = [
        { title: '学生规模', content: `系统当前共管理 ${totalStudents} 名学生。`, time: '实时' },
        { title: '待处理订单', content: `还有 ${pendingOrders} 笔订单待审核或跟进。`, time: '实时' },
        { title: '消息提醒', content: `当前工作台仍有 ${unreadMessages} 条未读通知。`, time: '实时' }
      ];
    } catch (error) {
      this.stats = {
        totalStudents: 0,
        presentStudents: 0,
        attendanceRate: 0,
        pendingOrders: 0,
        unreadMessages: 0,
        netIncome: 0
      };
      this.recentActivities = [];
      this.errorMessage = ErrorMessages.DATA_LOAD_FAILED;
    } finally {
      this.isLoading = false;
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
          hero: () => { this.buildHeroCard() },
          primary: () => { this.buildWorkbenchSection() },
          secondary: () => { this.buildOperationsSection() }
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
      greeting: this.workbenchManifest?.summary.description ?? '集中查看学生、订单流转和经营指标。',
      theme: HeaderTheme.WHITE,
      badgeText: '机构端',
      metaText: this.workbenchManifest?.visual.slogan ?? `今日出勤率：${this.stats.attendanceRate}%`
    }) {
      this.buildHeaderActions()
    }
  }

  @Builder
  private buildHeaderActions() {
    IconActionButton({
      icon: $r('app.media.ic_notification'),
      badgeCount: this.stats.unreadMessages,
      onButtonClick: () => {
        this.pushPage(RouteUrls.ADMIN_MESSAGES);
      }
    })
  }

  @Builder
  private buildHeroCard() {
    AdminSummaryHeroCard({
      netIncome: `¥${this.stats.netIncome.toFixed(0)}`,
      attendanceRate: `${this.stats.attendanceRate}%`,
      pendingOrders: `${this.stats.pendingOrders}`
    })
    .margin({ bottom: 14 })
  }

  private getTopOverviewItems(): StatRowItem[] {
    return [
      { value: `${this.stats.totalStudents}`, label: '学生总数', icon: $r('app.media.ic_user'), iconColor: getRolePalette(UserRole.ORG_ADMIN).primary },
      { value: `${this.stats.presentStudents}`, label: '今日到校', icon: $r('app.media.ic_attendance'), iconColor: HarmonyReport.positive }
    ];
  }

  private getBottomOverviewItems(): StatRowItem[] {
    return [
      { value: `${this.stats.pendingOrders}`, label: '待处理订单', icon: $r('app.media.ic_order'), iconColor: HarmonyReport.caution },
      { value: `${this.stats.unreadMessages}`, label: '未读提醒', icon: $r('app.media.ic_message'), iconColor: getRolePalette(UserRole.ORG_ADMIN).primaryDark }
    ];
  }

  private getActivityFeedItems(): ActivityFeedItem[] {
    return this.recentActivities.map((item: ActivityItem): ActivityFeedItem => {
      return {
        title: item.title,
        content: item.content,
        time: item.time
      };
    });
  }

  private getActionModules(): WorkbenchModule[] {
    const manifestModules = this.workbenchManifest?.modules?.filter((module: WorkbenchModule) => module.enabled && module.code !== 'home') ?? [];
    if (manifestModules.length > 0) {
      return manifestModules;
    }
    return [
      { code: 'students', name: '学生档案', route: '/admin/students', enabled: true },
      { code: 'messages', name: '消息中心', route: '/admin/messages', enabled: true },
      { code: 'orders', name: '订单审核', route: '/admin/orders', enabled: true },
      { code: 'reports', name: '统计报表', route: '/admin/reports', enabled: true },
      { code: 'services', name: '服务产品', route: '/admin/services', enabled: true },
      { code: 'sessions', name: '班次排期', route: '/admin/sessions', enabled: true },
      { code: 'alerts', name: '告警中心', route: '/admin/alerts', enabled: true },
      { code: 'refunds', name: '退款管理', route: '/admin/refunds', enabled: true },
      { code: 'profile', name: '我的', route: '/admin/profile', enabled: true }
    ];
  }

  private getModuleSubtitle(code: string): string {
    if (code === 'students') return '管理信息';
    if (code === 'messages') return '通知处理';
    if (code === 'orders') return '审批流转';
    if (code === 'reports') return '经营视图';
    if (code === 'services') return '产品配置';
    if (code === 'sessions') return '自动排班';
    if (code === 'alerts') return '风险处理';
    if (code === 'refunds') return '售后跟进';
    return '进入模块';
  }

  private getModuleIcon(code: string): Resource {
    if (code === 'students') return $r('app.media.ic_user');
    if (code === 'messages') return $r('app.media.ic_message');
    if (code === 'orders') return $r('app.media.ic_order');
    if (code === 'reports') return $r('app.media.ic_report');
    if (code === 'services') return $r('app.media.ic_service');
    if (code === 'sessions') return $r('app.media.ic_session');
    if (code === 'alerts') return $r('app.media.ic_alert_center');
    if (code === 'refunds') return $r('app.media.ic_refund');
    return $r('app.media.ic_home');
  }

  private getModuleBgColor(code: string): string {
    if (code === 'students' || code === 'sessions') return getRolePalette(UserRole.ORG_ADMIN).light;
    if (code === 'alerts') return HarmonyReport.dangerSurface;
    if (code === 'refunds') return HarmonyReport.cautionSurface;
    if (code === 'reports') return HarmonyReport.positiveSurface;
    return getRolePalette(UserRole.ORG_ADMIN).soft;
  }

  private getModuleIconColor(code: string): string {
    if (code === 'students' || code === 'sessions') return getRolePalette(UserRole.ORG_ADMIN).primary;
    if (code === 'reports') return HarmonyReport.positive;
    if (code === 'alerts') return HarmonyReport.danger;
    if (code === 'refunds') return HarmonyReport.caution;
    return getRolePalette(UserRole.ORG_ADMIN).primaryDark;
  }

  private openWorkbenchModule(module: WorkbenchModule): void {
    if (module.code === 'home') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 0);
      return;
    }
    if (module.code === 'students') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 1);
      return;
    }
    if (module.code === 'orders') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 2);
      return;
    }
    if (module.code === 'reports') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 3);
      return;
    }
    if (module.code === 'profile') {
      AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 4);
      return;
    }
    if (module.code === 'messages') {
      this.pushPage(RouteUrls.ADMIN_MESSAGES);
    } else if (module.code === 'services') {
      this.pushPage(RouteUrls.ADMIN_SERVICES);
    } else if (module.code === 'sessions') {
      this.pushPage(RouteUrls.ADMIN_SESSIONS);
    } else if (module.code === 'alerts') {
      this.pushPage(RouteUrls.ADMIN_ALERTS);
    } else if (module.code === 'refunds') {
      this.pushPage(RouteUrls.ADMIN_REFUNDS);
    }
  }

  private pushPage(url: string): void {
    try {
      this.getUIContext().getRouter().pushUrl({ url });
    } catch (error) {
      console.error('AdminHomePage navigate failed:', String(error));
    }
  }

  @Builder
  private buildWorkbenchSection() {
    AdminHomeWorkbenchSection({
      overviewTopItems: this.getTopOverviewItems(),
      overviewBottomItems: this.getBottomOverviewItems(),
      quickActionTitle: this.workbenchManifest?.summary.title ?? '控制台入口',
      quickActionSubtitle: this.workbenchManifest ? `能力清单：${this.workbenchManifest.version}` : '围绕学生、订单、服务和告警进入管理流程。',
      modules: this.getActionModules(),
      subtitleResolver: (code: string): string => this.getModuleSubtitle(code),
      iconResolver: (code: string): Resource => this.getModuleIcon(code),
      bgColorResolver: (code: string): string => this.getModuleBgColor(code),
      iconColorResolver: (code: string): string => this.getModuleIconColor(code),
      onModuleClick: (module: WorkbenchModule): void => this.openWorkbenchModule(module)
    })
  }

  @Builder
  private buildOperationsSection() {
    AdminHomeOperationsSection({
      operationsSubtitle: this.errorMessage ? this.errorMessage : '集中查看学生规模、考勤、订单流转和营收情况。',
      totalStudents: this.stats.totalStudents,
      presentStudents: this.stats.presentStudents,
      attendanceRateText: `${this.stats.attendanceRate}%`,
      netIncomeText: `¥${this.stats.netIncome.toFixed(0)}`,
      activityItems: this.getActivityFeedItems(),
      activityActionText: '打开报表',
      onActivityAction: (): void => {
        AppStorage.setOrCreate(StorageKeys.MAIN_CURRENT_INDEX, 2);
      }
    })
  }
}
