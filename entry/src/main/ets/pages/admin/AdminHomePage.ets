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
      const [studentsResp, attendanceResp, ordersResp, messagesResp, financeResp] = await Promise.all([
        StudentService.getStudents({ pageNum: 1, pageSize: 1 }),
        ReportsService.getAttendanceReport(),
        OrderService.getOrders({ pageNum: 1, pageSize: 200, orderStatus: 'PENDING' }),
        MessageService.getUnreadCount(),
        ReportsService.getFinanceReport()
      ]);

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
        { title: 'Student scale', content: `The system currently tracks ${totalStudents} students.`, time: 'Live' },
        { title: 'Pending orders', content: `${pendingOrders} orders still need review or follow-up.`, time: 'Live' },
        { title: 'Message alerts', content: `${unreadMessages} notifications remain unread in the console.`, time: 'Live' }
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
        greeting: 'Track students, order flow, and operating indicators from one management cockpit.',
        theme: HeaderTheme.WHITE,
        badgeText: 'Admin cockpit',
        metaText: `Attendance rate today: ${this.stats.attendanceRate}%`,
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
        this.buildOverviewMetric('Students', `${this.stats.totalStudents}`, '#1F5EFF', '#EDF4FF')
        Blank().width(10)
        this.buildOverviewMetric('Present today', `${this.stats.presentStudents}`, '#16A34A', '#ECFDF5')
      }
      .width('100%')

      Row() {
        this.buildOverviewMetric('Pending orders', `${this.stats.pendingOrders}`, '#F59E0B', '#FFF7E8')
        Blank().width(10)
        this.buildOverviewMetric('Unread alerts', `${this.stats.unreadMessages}`, '#8B5CF6', '#F5F0FF')
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
      Text('Quick entries')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 10 })

      Row() {
        ActionButton({
          label: 'Students',
          icon: $r('app.media.ic_user'),
          bgColor: '#F5F0FF',
          iconColor: '#8B5CF6',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminStudentsPage' });
          }
        })

        Blank().width(10)

        ActionButton({
          label: 'Messages',
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
          label: 'Order review',
          icon: $r('app.media.ic_order'),
          bgColor: '#FFF7E8',
          iconColor: '#F59E0B',
          onButtonClick: () => {
            AppStorage.setOrCreate('main_current_index', 1);
          }
        })

        Blank().width(10)

        ActionButton({
          label: 'Reports',
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
      title: 'Operating snapshot',
      subtitle: this.errorMessage ? this.errorMessage : 'Combine student scale, attendance, order flow, and revenue into one summary view.',
      content: this.buildStatsContent
    })
  }

  @Builder
  buildStatsContent() {
    Column() {
      Row() {
        StatCard({
          value: this.stats.totalStudents,
          label: 'Students',
          icon: $r('app.media.ic_user'),
          iconColor: '#8B5CF6'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.stats.presentStudents,
          label: 'Present',
          icon: $r('app.media.ic_attendance'),
          iconColor: '#16A34A'
        })
        .layoutWeight(1)
      }
      .width('100%')

      Row() {
        StatCard({
          value: `${this.stats.attendanceRate}%`,
          label: 'Attendance rate',
          icon: $r('app.media.ic_home'),
          iconColor: '#1F5EFF'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: `¥${this.stats.netIncome.toFixed(0)}`,
          label: 'Net income',
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
      title: 'Live updates',
      subtitle: 'Highlight the items that need management attention today.',
      actionText: 'Open reports',
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
        customTitle: 'No live updates',
        customDescription: 'More operating signals will appear here after full real-environment validation.'
      })
    }
  }
}
