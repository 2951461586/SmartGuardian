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

  aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
    }
    this.loadData();
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
        greeting: '欢迎使用智慧学生管理系统 · 家长端',
        theme: HeaderTheme.WHITE,
        badgeText: '家长端',
        metaText: this.todaySummary?.studentName ? `当前关注：${this.todaySummary.studentName}` : '实时同步学生签到、作业与托管安排'
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
            .fontColor('#3F7DFF')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor('#F5F9FF')
            .borderRadius(999)
            .margin({ left: 10 })
        }
        .width('100%')

        Text(`学号：${this.getDisplayStudentNo()}`)
          .fontSize(14)
          .fontColor('#EAF1FF')
          .margin({ top: 10 })

        Text(`学校：${this.getDisplaySchoolName()}`)
          .fontSize(14)
          .fontColor('#EAF1FF')
          .margin({ top: 6 })

        Text(this.getSessionTitle())
          .fontSize(13)
          .fontColor('#DDE8FF')
          .margin({ top: 10 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })

      Image($r('app.media.startIcon'))
        .width(84)
        .height(84)
        .objectFit(ImageFit.Contain)
        .opacity(0.22)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .linearGradient({
      angle: 145,
      colors: [['#5A96FF', 0], ['#4B85FF', 0.55], ['#3970F5', 1]]
    })
    .borderRadius(28)
    .shadow({
      radius: 18,
      color: '#2F6BDE18',
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
      color: '#E4ECFA',
      radius: 22,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 12,
      color: '#2F6BDE0D',
      offsetX: 0,
      offsetY: 6
    })
    .margin({ bottom: 14 })
  }

  @Builder
  private buildQuickActionsCard() {
    Card({
      title: '常用功能',
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
        this.buildFeatureItem('托管预约', '在线预约', $r('app.media.ic_calendar'), '#EAF2FF', '#3F7DFF', () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentServicesPage' });
        })
        this.buildFeatureItem('我的订单', '查看订单', $r('app.media.ic_order'), '#EAF9EF', '#34C759', () => {
          AppStorage.setOrCreate('main_current_index', 1);
        })
        this.buildFeatureItem('签到记录', '出入校记录', $r('app.media.ic_attendance'), '#FFF3E5', '#FFB74D', () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentTimelinePage' });
        })
        this.buildFeatureItem('家校沟通', '联系老师', $r('app.media.ic_message'), '#F2EEFF', '#8B6CF6', () => {
          AppStorage.setOrCreate('main_current_index', 2);
        })
      }
      .width('100%')

      Row() {
        this.buildFeatureItem('作业辅导', '作业与反馈', $r('app.media.ic_homework'), '#FFF4E8', '#FF8A4D', () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentHomeworkPage' });
        })
        this.buildFeatureItem('在校动态', '查看安排', $r('app.media.ic_child'), '#EAF2FF', '#4C89FF', () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentSessionsPage' });
        })
        this.buildFeatureItem('安全守护', '风险提醒', $r('app.media.ic_warning'), '#EAF9EF', '#2DB36B', () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentAlertsPage' });
        })
        this.buildFeatureItem('费用缴纳', '缴费记录', $r('app.media.ic_money'), '#FFECEF', '#FF5D73', () => {
          AppStorage.setOrCreate('main_current_index', 1);
        })
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
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
      .backgroundColor('#F7FAFF')
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
              .backgroundColor('#EAF2FF')
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
    return this.todaySummary?.status === 'NOT_SIGNED' ? '#FF9F43' : '#34C759';
  }

  private getSignStatusBgColor(): string {
    return this.todaySummary?.status === 'NOT_SIGNED' ? '#FFF3E5' : '#EAF9EF';
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
      return '#34C759';
    }
    if (progress > 0) {
      return '#3F7DFF';
    }
    return '#9AA8C2';
  }

  private getHomeworkStatusBgColor(): string {
    const progress = this.todaySummary?.homeworkProgress ?? 0;
    if (progress >= 100) {
      return '#EAF9EF';
    }
    if (progress > 0) {
      return '#EAF2FF';
    }
    return '#F2F5FB';
  }

  private getSignOutStatusText(): string {
    return this.todaySummary?.status === 'SIGNED_OUT' ? '已完成' : '未开始';
  }

  private getSignOutStatusColor(): string {
    return this.todaySummary?.status === 'SIGNED_OUT' ? '#34C759' : '#9AA8C2';
  }

  private getSignOutStatusBgColor(): string {
    return this.todaySummary?.status === 'SIGNED_OUT' ? '#EAF9EF' : '#F2F5FB';
  }
}
