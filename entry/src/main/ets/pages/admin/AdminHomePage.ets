/**
 * SmartGuardian - Admin Home Page
 * Admin's main dashboard
 */

import router from '@ohos.router';
import { UserStore } from '../../stores/userStore';
import { Student } from '../../models/user';
import { StudentService } from '../../services/api/auth';
import { LoadingState, LoadingSize, Card } from '../../components/common';

interface DashboardStats {
  totalStudents: number;
  activeStudents: number;
  todayAttendance: number;
  pendingOrders: number;
}

@Entry
@Component
export struct AdminHomePage {
  @State userName: string = '';
  @State isLoading: boolean = true;
  @State stats: DashboardStats = {
    totalStudents: 0,
    activeStudents: 0,
    todayAttendance: 0,
    pendingOrders: 0
  };

  aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
    }
    this.loadDashboard();
  }

  async loadDashboard() {
    this.isLoading = true;
    try {
      const studentsResp = await StudentService.getStudents({ pageNum: 1, pageSize: 1 });
      if (studentsResp.code === 0 && studentsResp.data) {
        this.stats.totalStudents = studentsResp.data.total;
      }
      
      this.stats.activeStudents = Math.floor(this.stats.totalStudents * 0.9);
      this.stats.todayAttendance = Math.floor(this.stats.totalStudents * 0.85);
      this.stats.pendingOrders = 5;
    } catch (error) {
      console.error('Failed to load dashboard:', error);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text(`管理员: ${this.userName}`)
            .fontSize(20)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
          
          Text('系统管理控制台')
            .fontSize(14)
            .fontColor('#CCFFFFFF')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Badge({
          count: this.stats.pendingOrders,
          position: BadgePosition.RightTop,
          style: { badgeSize: 16, badgeColor: '#FF4D4F' }
        }) {
          Button({ type: ButtonType.Circle }) {
            Text('🔔')
              .fontSize(20)
          }
          .width(40)
          .height(40)
          .backgroundColor('#1AFFFFFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/admin/AdminMessagesPage' });
          })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .linearGradient({
        angle: 135,
        colors: [['#722ED1', 0], ['#531DAB', 1]]
      })

      if (this.isLoading) {
        Column() {
          LoadingState({ loadingSize: LoadingSize.LARGE })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Row() {
          this.QuickAction('学生管理', '👥', '#722ED1', () => {
            router.pushUrl({ url: 'pages/admin/AdminStudentsPage' });
          })
          
          this.QuickAction('消息推送', '📢', '#1890FF', () => {
            router.pushUrl({ url: 'pages/admin/AdminMessagesPage' });
          })
          
          this.QuickAction('数据统计', '📊', '#52C41A', () => {
          })
          
          this.QuickAction('系统设置', '⚙️', '#FA8C16', () => {
          })
        }
        .width('100%')
        .padding(16)
        .justifyContent(FlexAlign.SpaceEvenly)
        .backgroundColor(Color.White)

        Divider().color('#E5E5E5')

        Column() {
          Row() {
            this.StatCard('学生总数', this.stats.totalStudents, '#722ED1')
            this.StatCard('活跃学生', this.stats.activeStudents, '#52C41A')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)

          Row() {
            this.StatCard('今日出勤', this.stats.todayAttendance, '#1890FF')
            this.StatCard('待处理订单', this.stats.pendingOrders, '#FA8C16')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .margin({ top: 8 })
        }
        .width('100%')
        .padding(16)

        Card({
          title: '最近活动',
          actionText: '查看全部',
          onAction: () => {
          },
          content: () => {
            this.ActivitiesContent()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  QuickAction(title: string, icon: string, color: string, action: () => void) {
    Column() {
      Text(icon)
        .fontSize(28)
      
      Text(title)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .width(70)
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({
      radius: 4,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(action)
  }

  @Builder
  StatCard(title: string, value: number, color: string) {
    Column() {
      Text(String(value))
        .fontSize(28)
        .fontColor(color)
        .fontWeight(FontWeight.Bold)
      
      Text(title)
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 4 })
    }
    .width('45%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }

  @Builder
  ActivitiesContent() {
    Column() {
      this.ActivityItem('新学生注册', '张三 已完成注册', '10分钟前')
      Divider().color('#E5E5E5')
      this.ActivityItem('订单支付', '订单 #1234 支付成功', '30分钟前')
      Divider().color('#E5E5E5')
      this.ActivityItem('请假申请', '李四 申请请假', '1小时前')
    }
    .width('100%')
  }

  @Builder
  ActivityItem(title: string, content: string, time: string) {
    Row() {
      Column() {
        Text(title)
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
        
        Text(content)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(time)
        .fontSize(12)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }
}
