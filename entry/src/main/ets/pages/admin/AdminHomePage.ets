/**
 * SmartGuardian - Admin Home Page
 * Admin dashboard with the new light campus style
 */

import {
  Card,
  EmptyState,
  EmptyType,
  GreetingHeader,
  HeaderTheme,
  IconActionButton,
  LoadingSize,
  LoadingState,
  StatCard
} from '../../components/common';
import { ErrorMessages } from '../../constants/ErrorMessages';
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

@Component
export struct AdminHomePage {
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
    const manifest = AppStorage.get<WorkbenchManifest>('workbench_manifest');
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
      const attendanceRate = attendanceResp.code === 0 && attendanceResp.data
        ? Math.round((attendanceResp.data.attendanceRate ?? 0) * 100)
        : 0;
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
      GreetingHeader({
        userName: this.userName,
        greeting: this.workbenchManifest?.summary.description ?? '集中查看学生、订单流转和经营指标。',
        theme: HeaderTheme.WHITE,
        badgeText: '机构端',
        metaText: this.workbenchManifest?.visual.slogan ?? `今日出勤率：${this.stats.attendanceRate}%`
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
    IconActionButton({
      icon: $r('app.media.ic_notification'),
      badgeCount: this.stats.unreadMessages,
      onButtonClick: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminMessagesPage' });
      }
    })
  }

  @Builder
  private buildContent() {
    Scroll() {
      Column() {
        this.buildHeroCard()
        this.buildOverviewPanel()
        this.buildControlDeck()
        this.buildStatsSection()
        this.buildActivityCard()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 24 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  private buildHeroCard() {
    Row() {
      Column() {
        Text('经营总览')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#7B6D96')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#F2F0F7')
          .borderRadius(999)

        Text(`￥${this.stats.netIncome.toFixed(0)}`)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 14 })

        Text('当前统计周期净收入')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })

        Row() {
          this.buildHeroMetric(`${this.stats.attendanceRate}%`, '出勤率')
          Blank().width(12)
          this.buildHeroMetric(`${this.stats.pendingOrders}`, '待处理')
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text('今日摘要')
          .fontSize(12)
          .fontColor('#7B6D96')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#F2F0F7')
          .borderRadius(999)

        Image($r('app.media.sg_illustration_education'))
          .width(108)
          .height(92)
          .objectFit(ImageFit.Contain)
          .opacity(0.88)
          .margin({ top: 16 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .linearGradient({
      angle: 145,
      colors: [['#FFFFFF', 0], ['#F6F4FA', 1]]
    })
    .border({
      width: 1,
      color: '#DED8EA',
      radius: 28,
      style: BorderStyle.Solid
    })
    .borderRadius(28)
    .shadow({
      radius: 18,
      color: '#7B6D9612',
      offsetX: 0,
      offsetY: 10
    })
    .margin({ bottom: 14 })
  }

  @Builder
  private buildHeroMetric(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#574A72')

      Text(label)
        .fontSize(12)
        .fontColor('#66738A')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFFCC')
    .borderRadius(18)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildOverviewPanel() {
    Column() {
      Row() {
        StatCard({
          value: `${this.stats.totalStudents}`,
          label: '学生总数',
          icon: $r('app.media.ic_user'),
          iconColor: '#7B6D96'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: `${this.stats.presentStudents}`,
          label: '今日到校',
          icon: $r('app.media.ic_attendance'),
          iconColor: '#2F9E77'
        })
        .layoutWeight(1)
      }
      .width('100%')

      Row() {
        StatCard({
          value: `${this.stats.pendingOrders}`,
          label: '待处理订单',
          icon: $r('app.media.ic_order'),
          iconColor: '#E8A23A'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: `${this.stats.unreadMessages}`,
          label: '未读提醒',
          icon: $r('app.media.ic_message'),
          iconColor: '#6E5BAA'
        })
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .margin({ bottom: 14 })
  }

  @Builder
  private buildControlDeck() {
    Card({
      title: this.workbenchManifest?.summary.title ?? '控制台入口',
      subtitle: this.workbenchManifest ? `能力清单：${this.workbenchManifest.version}` : '围绕学生、订单、服务和告警进入管理流程。',
      content: this.buildQuickActions
    })
  }

  @Builder
  private buildQuickActions() {
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
        .fontSize(14)
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

  private getFirstActionRow(): WorkbenchModule[] {
    return this.getActionModules().slice(0, 5);
  }

  private getSecondActionRow(): WorkbenchModule[] {
    return this.getActionModules().slice(5, 10);
  }

  private getModuleSubtitle(code: string): string {
    if (code === 'students') return '管理信息';
    if (code === 'messages') return '通知处理';
    if (code === 'orders') return '审批流转';
    if (code === 'reports') return '经营视图';
    if (code === 'services') return '模板配置';
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
    if (code === 'students' || code === 'sessions') return '#F1EDFB';
    if (code === 'alerts') return '#FFF0F1';
    return '#F2F0F7';
  }

  private getModuleIconColor(code: string): string {
    if (code === 'students' || code === 'sessions') return '#6E5BAA';
    if (code === 'reports') return '#2F9E77';
    if (code === 'alerts') return '#D94B5A';
    if (code === 'refunds') return '#8A6A4E';
    return '#7B6D96';
  }

  private openWorkbenchModule(module: WorkbenchModule): void {
    if (module.code === 'home') {
      AppStorage.setOrCreate('main_current_index', 0);
      return;
    }
    if (module.code === 'students') {
      AppStorage.setOrCreate('main_current_index', 1);
      return;
    }
    if (module.code === 'orders') {
      AppStorage.setOrCreate('main_current_index', 2);
      return;
    }
    if (module.code === 'reports') {
      AppStorage.setOrCreate('main_current_index', 3);
      return;
    }
    if (module.code === 'profile') {
      AppStorage.setOrCreate('main_current_index', 4);
      return;
    }
    if (module.code === 'messages') {
      this.pushPage('pages/admin/AdminMessagesPage');
    } else if (module.code === 'services') {
      this.pushPage('pages/admin/AdminServicesPage');
    } else if (module.code === 'sessions') {
      this.pushPage('pages/admin/AdminSessionsPage');
    } else if (module.code === 'alerts') {
      this.pushPage('pages/admin/AdminAlertsPage');
    } else if (module.code === 'refunds') {
      this.pushPage('pages/admin/AdminRefundsPage');
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
  private buildStatsSection() {
    Card({
      title: '运营概览',
      subtitle: this.errorMessage ? this.errorMessage : '集中查看学生规模、考勤、订单流转和营收情况。',
      content: this.buildStatsContent
    })
  }

  @Builder
  private buildStatsContent() {
    Column() {
      Row() {
        StatCard({
          value: this.stats.totalStudents,
          label: '学生',
          icon: $r('app.media.ic_user'),
          iconColor: '#6E5BAA'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.stats.presentStudents,
          label: '到校',
          icon: $r('app.media.ic_attendance'),
          iconColor: '#2F9E77'
        })
        .layoutWeight(1)
      }
      .width('100%')

      Row() {
        StatCard({
          value: `${this.stats.attendanceRate}%`,
          label: '出勤率',
          icon: $r('app.media.ic_home'),
          iconColor: '#7B6D96'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: `￥${this.stats.netIncome.toFixed(0)}`,
          label: '净收入',
          icon: $r('app.media.ic_money'),
          iconColor: '#E8A23A'
        })
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
  }

  @Builder
  private buildActivityCard() {
    Card({
      title: '实时动态',
      subtitle: '聚焦今天需要关注的重点事项。',
      actionText: '打开报表',
      onAction: () => {
        AppStorage.setOrCreate('main_current_index', 2);
      },
      content: this.buildActivityContent
    })
  }

  @Builder
  private buildActivityContent() {
    if (this.recentActivities.length > 0) {
      Column() {
        ForEach(this.recentActivities, (item: ActivityItem, index: number) => {
          Row() {
            Column() {
              Text(item.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))

              Text(item.content)
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .lineHeight(20)
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(item.time)
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'))
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          .padding({ top: 4, bottom: 4 })

          if (index < this.recentActivities.length - 1) {
            Divider()
              .color($r('app.color.divider'))
              .margin({ top: 10, bottom: 10 })
          }
        })
      }
      .width('100%')
    } else {
      EmptyState({
        type: EmptyType.DEFAULT,
        customTitle: '暂无实时动态',
        customDescription: '完成真实环境联调后，这里会展示更多运营信号。'
      })
    }
  }
}

