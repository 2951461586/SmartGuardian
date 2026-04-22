/**
 * SmartGuardian - Admin Home Page
 * Admin dashboard with unified common components
 */

import { UserStore } from '../../stores/userStore';
import { StudentService } from '../../services/api/auth';
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
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';

interface DashboardStats {
  totalStudents: number;
  activeStudents: number;
  todayAttendance: number;
  pendingOrders: number;
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
    activeStudents: 0,
    todayAttendance: 0,
    pendingOrders: 0
  };

  private readonly recentActivities: ActivityItem[] = [
    { title: '新学生注册', content: '张三 已完成注册', time: '10分钟前' },
    { title: '订单支付', content: '订单 #1234 支付成功', time: '30分钟前' },
    { title: '请假申请', content: '李四 申请请假', time: '1小时前' }
  ];

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
      const studentsResp = await StudentService.getStudents({ pageNum: 1, pageSize: 1 });
      const totalStudents = studentsResp.code === 0 && studentsResp.data ? studentsResp.data.total : 0;

      this.stats = {
        totalStudents,
        activeStudents: Math.floor(totalStudents * 0.9),
        todayAttendance: Math.floor(totalStudents * 0.85),
        pendingOrders: 5
      };
    } catch (error) {
      this.stats = {
        totalStudents: 0,
        activeStudents: 0,
        todayAttendance: 0,
        pendingOrders: 0
      };
      this.errorMessage = ErrorMessages.DATA_LOAD_FAILED;
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      GreetingHeader({
        userName: this.userName,
        greeting: '聚焦学生规模、订单处理与机构运营状态',
        theme: HeaderTheme.WHITE,
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
    Column() {
      Image($r('app.media.ic_notification'))
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)
    }
    .width(40)
    .height(40)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F1F5FB')
    .borderRadius(20)
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
      .padding({ left: 16, right: 16, top: 12, bottom: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildOverviewPanel() {
    Row() {
      this.buildOverviewMetric('学生总量', `${this.stats.totalStudents}`, '#4F7CFF', '#EAF2FF')
      Blank().width(10)
      this.buildOverviewMetric('待处理订单', `${this.stats.pendingOrders}`, '#F2994A', '#FFF4E8')
      Blank().width(10)
      this.buildOverviewMetric('出勤概览', `${this.stats.todayAttendance}`, '#2F9B52', '#EAF7EC')
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
        .margin({ top: 6 })
    }
    .layoutWeight(1)
    .padding({ left: 14, right: 14, top: 16, bottom: 16 })
    .backgroundColor(bgColor)
    .borderRadius(18)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildQuickActions() {
    Column() {
      Row() {
        Text('快捷入口')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .margin({ bottom: 10 })

      Row() {
        ActionButton({
          label: '学生管理',
          icon: $r('app.media.ic_user'),
          bgColor: '#F4EEFF',
          iconColor: '#8E5CF6',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminStudentsPage' });
          }
        })

        ActionButton({
          label: '消息管理',
          icon: $r('app.media.ic_message'),
          bgColor: '#EAF2FF',
          iconColor: '#4F7CFF',
          onButtonClick: () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminMessagesPage' });
          }
        })

        ActionButton({
          label: '订单审核',
          icon: $r('app.media.ic_order'),
          bgColor: '#FFF4E8',
          iconColor: '#F2994A',
          onButtonClick: () => {
            AppStorage.setOrCreate('main_current_index', 1);
          }
        })

        ActionButton({
          label: '数据统计',
          icon: $r('app.media.ic_report'),
          bgColor: '#EAF7EC',
          iconColor: '#2F9B52',
          onButtonClick: () => {
            AppStorage.setOrCreate('main_current_index', 2);
          }
        })
      }
      .width('100%')
      .padding({ top: 10, bottom: 10 })
      .backgroundColor(Color.White)
      .borderRadius(20)
    }
    .width('100%')
    .margin({ bottom: 14 })
  }

  @Builder
  buildStatsSection() {
    Card({
      title: '运营概览',
      subtitle: this.errorMessage ? this.errorMessage : '聚焦机构当前最重要的四项运营指标',
      content: this.buildStatsContent
    })
  }

  @Builder
  buildStatsContent() {
    Column() {
      Row() {
        StatCard({
          value: this.stats.totalStudents,
          label: '学生总数',
          icon: $r('app.media.ic_user'),
          iconColor: '#8E5CF6'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.stats.activeStudents,
          label: '活跃学生',
          icon: $r('app.media.ic_home'),
          iconColor: '#2F9B52'
        })
        .layoutWeight(1)
      }
      .width('100%')

      Row() {
        StatCard({
          value: this.stats.todayAttendance,
          label: '今日出勤',
          icon: $r('app.media.ic_attendance'),
          iconColor: '#4F7CFF'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.stats.pendingOrders,
          label: '待处理订单',
          icon: $r('app.media.ic_order'),
          iconColor: '#F2994A'
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
      title: '最近活动',
      subtitle: '帮助管理员快速了解学生、订单与请假变动',
      actionText: '查看报表',
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
                .fontSize($r('app.float.text_primary_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))

              Text(item.content)
                .fontSize($r('app.float.text_secondary_size'))
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(item.time)
              .fontSize($r('app.float.text_tiny_size'))
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
        customTitle: '暂无最近活动',
        customDescription: '后续将展示学生、订单和消息的动态记录'
      })
    }
  }

  private showFeatureInDevelopment(): void {
    ErrorHandlerUtil.showErrorToast(ErrorMessages.FEATURE_IN_DEVELOPMENT);
  }
}
