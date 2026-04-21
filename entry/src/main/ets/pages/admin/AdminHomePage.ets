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
        greeting: '查看机构运营数据与待办事项',
        theme: HeaderTheme.PRIMARY,
        onRightIconClick: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminMessagesPage' });
        }
      })

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
  buildContent() {
    Scroll() {
      Column() {
        this.buildQuickActions()
        this.buildStatsSection()
        this.buildActivityCard()
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  buildQuickActions() {
    Row() {
      ActionButton({
        label: '学生管理',
        icon: $r('app.media.ic_user'),
        bgColor: '#F3E5F5',
        iconColor: '#8E24AA',
        onButtonClick: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminStudentsPage' });
        }
      })

      ActionButton({
        label: '消息管理',
        icon: $r('app.media.ic_message'),
        bgColor: '#E3F2FD',
        iconColor: '#2196F3',
        onButtonClick: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/admin/AdminMessagesPage' });
        }
      })

      ActionButton({
        label: '订单审核',
        icon: $r('app.media.ic_order'),
        bgColor: '#FFF3E0',
        iconColor: '#FB8C00',
        onButtonClick: () => {
          AppStorage.setOrCreate('main_current_index', 1);
        }
      })

      ActionButton({
        label: '数据统计',
        icon: $r('app.media.ic_report'),
        bgColor: '#E8F5E9',
        iconColor: '#43A047',
        onButtonClick: () => {
          AppStorage.setOrCreate('main_current_index', 2);
        }
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildStatsSection() {
    Card({
      title: '运营概览',
      subtitle: this.errorMessage ? this.errorMessage : '今日关键指标一览',
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
          iconColor: '#8E24AA'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.stats.activeStudents,
          label: '活跃学生',
          icon: $r('app.media.ic_home'),
          iconColor: '#43A047'
        })
        .layoutWeight(1)
      }
      .width('100%')

      Row() {
        StatCard({
          value: this.stats.todayAttendance,
          label: '今日出勤',
          icon: $r('app.media.ic_attendance'),
          iconColor: '#2196F3'
        })
        .layoutWeight(1)

        Blank().width(12)

        StatCard({
          value: this.stats.pendingOrders,
          label: '待处理订单',
          icon: $r('app.media.ic_order'),
          iconColor: '#FB8C00'
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

          if (index < this.recentActivities.length - 1) {
            Divider()
              .margin({ top: 10, bottom: 10 })
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
