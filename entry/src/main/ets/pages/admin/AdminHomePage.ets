/**
 * SmartGuardian - Admin Home Page
 * Admin dashboard backed by real report and order APIs
 */

import {
  GreetingHeader,
  HeaderTheme,
  LoadingState,
  LoadingSize,
  Card,
  ActionButton,
  StatCard,
  SectionHeader,
  EmptyState,
  EmptyType
} from '../../components/common';
import { ErrorMessages } from '../../constants/ErrorMessages';
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

  aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
    }
    this.loadDashboard();
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
        { title: '消息提醒', content: `当前工作台还有 ${unreadMessages} 条未读通知。`, time: '实时' }
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
        greeting: '集中查看学生、订单流转和经营指标。',
        theme: HeaderTheme.WHITE,
        badgeText: '管理驾驶舱',
        metaText: `今日出勤率：${this.stats.attendanceRate}%`,
        onRightIconClick: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminMessagesPage' });
        }
      }) {
        this.buildMessageEntry()
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
  buildMessageEntry() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Image($r('app.media.ic_notification'))
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
          .fillColor('#12305F')
      }
      .width(46)
      .height(46)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')
      .borderRadius(18)
      .border({
        width: 1,
        color: '#E5EEF9',
        radius: 18,
        style: BorderStyle.Solid
      })

      if (this.stats.unreadMessages > 0) {
        Text(this.stats.unreadMessages > 99 ? '99+' : `${this.stats.unreadMessages}`)
          .fontSize(10)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.error'))
          .borderRadius(9)
          .padding({ left: 5, right: 5, top: 1, bottom: 1 })
      }
    }
    .onClick(() => {
      this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminMessagesPage' });
    })
  }

  @Builder
  buildContent() {
    Scroll() {
      Column() {
        this.buildOverviewPanel()
        this.buildQuickActions()
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
  buildOverviewPanel() {
    Column() {
      Row() {
        StatCard({
          value: `${this.stats.totalStudents}`,
          label: '学生总数',
          icon: $r('app.media.ic_user'),
          iconColor: '#1F5EFF'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: `${this.stats.presentStudents}`,
          label: '今日到校',
          icon: $r('app.media.ic_attendance'),
          iconColor: '#16A34A'
        })
        .layoutWeight(1)
      }
      .width('100%')

      Row() {
        StatCard({
          value: `${this.stats.pendingOrders}`,
          label: '待处理订单',
          icon: $r('app.media.ic_order'),
          iconColor: '#F59E0B'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: `${this.stats.unreadMessages}`,
          label: '未读提醒',
          icon: $r('app.media.ic_message'),
          iconColor: '#8B5CF6'
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
  buildOverviewMetric(title: string, value: string, valueColor: string, bgColor: string) {
    Column() {
      Text(title)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))

      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(valueColor)
        .margin({ top: 8 })
    }
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(bgColor)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildQuickActions() {
    Column() {
      SectionHeader({
        title: '快捷入口',
        subtitle: '把核心运营操作收拢到一个工作台'
      })

      Row() {
        ActionButton({
          label: '学生档案',
          icon: $r('app.media.ic_user'),
          bgColor: '#F5F0FF',
          iconColor: '#8B5CF6',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminStudentsPage' });
          }
        })

        Blank().width(10)

        ActionButton({
          label: '消息中心',
          icon: $r('app.media.ic_message'),
          bgColor: '#EDF4FF',
          iconColor: '#1F5EFF',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminMessagesPage' });
          }
        })
      }
      .width('100%')

      Row() {
        ActionButton({
          label: '订单审核',
          icon: $r('app.media.ic_order'),
          bgColor: '#FFF7E8',
          iconColor: '#F59E0B',
          onButtonClick: () => {
            AppStorage.setOrCreate('main_current_index', 1);
          }
        })

        Blank().width(10)

        ActionButton({
          label: '统计报表',
          icon: $r('app.media.ic_report'),
          bgColor: '#ECFDF5',
          iconColor: '#16A34A',
          onButtonClick: () => {
            AppStorage.setOrCreate('main_current_index', 2);
          }
        })
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .margin({ bottom: 14 })
  }

  @Builder
  buildStatsSection() {
    Card({
      title: '运营概览',
      subtitle: this.errorMessage ? this.errorMessage : '集中查看学生规模、考勤、订单流转和营收情况。',
      content: this.buildStatsContent
    })
  }

  @Builder
  buildStatsContent() {
    Column() {
      Row() {
        StatCard({
          value: this.stats.totalStudents,
          label: '学生',
          icon: $r('app.media.ic_user'),
          iconColor: '#8B5CF6'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.stats.presentStudents,
          label: '到校',
          icon: $r('app.media.ic_attendance'),
          iconColor: '#16A34A'
        })
        .layoutWeight(1)
      }
      .width('100%')

      Row() {
        StatCard({
          value: `${this.stats.attendanceRate}%`,
          label: '出勤率',
          icon: $r('app.media.ic_home'),
          iconColor: '#1F5EFF'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: `¥${this.stats.netIncome.toFixed(0)}`,
          label: '净收入',
          icon: $r('app.media.ic_money'),
          iconColor: '#F59E0B'
        })
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
  }

  @Builder
  buildActivityCard() {
    Card({
      title: '实时动态',
      subtitle: '聚焦今天需要管理关注的重点事项。',
      actionText: '打开报表',
      onAction: () => {
        AppStorage.setOrCreate('main_current_index', 2);
      },
      content: this.buildActivityContent
    })
  }

  @Builder
  buildActivityContent() {
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
            Divider().color('#EEF2F7').margin({ top: 10, bottom: 10 })
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
