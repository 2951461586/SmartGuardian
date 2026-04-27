import {
  Card,
  ProfileActionGrid,
  ProfileActionItem,
  ProfileHeroCard,
  ProfileHighlightBanner,
  ProfileMetricItem,
  ProfileMetricStrip,
  ProfileSettingsList,
  ProfileUtilityButton,
  ProfileWorkspaceTemplate
} from '../../components/common';
import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { RouteUrls, StorageKeys } from '../../constants/app.constants';
import { AuthService } from '../../services/api/auth';
import { UserStore } from '../../stores/userStore';

@Entry
@Component
struct TeacherProfilePage {
  build() {
    Stack() {
      TeacherProfilePageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct TeacherProfilePageContent {
  @State userName: string = '';
  @State mobile: string = '';
  @State avatar: string = '';

  aboutToAppear(): void {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
      this.mobile = userInfo.mobile;
      this.avatar = userInfo.avatar || '';
    }
  }

  async handleLogout(): Promise<void> {
    try {
      await AuthService.logout();
    } catch (error) {
      console.warn('TeacherProfilePage logout api failed:', String(error));
    }
    UserStore.clearUserInfo();
    AppStorage.setOrCreate(StorageKeys.MAIN_AUTH_LOCKED, true);
    try {
      this.getUIContext().getRouter().replaceUrl({ url: RouteUrls.LOGIN });
    } catch (error) {
      console.error('TeacherProfilePage logout redirect failed:', String(error));
    }
  }

  private openRoute(url: string): void {
    try {
      this.getUIContext().getRouter().pushUrl({ url });
    } catch (error) {
      console.error('TeacherProfilePage open route failed:', String(error));
    }
  }

  build() {
    Column() {
      ProfileWorkspaceTemplate({
        hero: () => { this.buildHeroSection() },
        summary: () => { this.buildSummarySection() },
        actions: () => { this.buildActionSection() },
        support: () => { this.buildSupportSection() }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildHeroSection() {
    Column() {
      ProfileHeroCard({
        userName: this.userName || '教师用户',
        roleLabel: '教师端',
        mobile: this.mobile || '未绑定手机号',
        avatar: this.avatar,
        primaryMeta: '课堂签到、作业反馈和家校消息统一收口',
        secondaryMeta: '本周值守 5 班次 · 三年级 2 班',
        metaChips: ['课堂点名', '班次排班', '消息协同'],
        illustration: $r('app.media.sg_illustration_teaching'),
        actionContent: this.buildHeroActions
      })

      ProfileHighlightBanner({
        title: '教师工作台',
        subtitle: '今日班次、课堂点名和家校沟通都可以从这里进入。',
        actionText: '查看课表',
        onAction: () => {
          this.openRoute(RouteUrls.TEACHER_SCHEDULE);
        }
      })
        .margin({ top: 14 })
    }
    .width('100%')
  }

  @Builder
  private buildHeroActions() {
    Column() {
      ProfileUtilityButton({
        icon: $r('app.media.ic_message'),
        onClickAction: () => {
          this.openRoute(RouteUrls.TEACHER_MESSAGES);
        }
      })

      Blank().height(10)

      ProfileUtilityButton({
        icon: $r('app.media.ic_calendar'),
        onClickAction: () => {
          this.openRoute(RouteUrls.TEACHER_SCHEDULE);
        }
      })
    }
  }

  @Builder
  private buildSummarySection() {
    Card({
      title: '教学指标',
      subtitle: '聚焦班次、点名、作业和家校沟通的关键工作量。',
      actionText: '打开课表',
      onAction: () => {
        this.openRoute(RouteUrls.TEACHER_SCHEDULE);
      },
      content: () => { this.buildSummaryContent() }
    })
  }

  @Builder
  private buildSummaryContent() {
    ProfileMetricStrip({
      metrics: this.getWorkMetrics()
    })
  }

  @Builder
  private buildActionSection() {
    Card({
      title: '教学入口',
      subtitle: '常用课堂、考勤和沟通能力集中在这一组入口。',
      content: () => { this.buildActionContent() }
    })
  }

  @Builder
  private buildActionContent() {
    ProfileActionGrid({
      rows: this.getPrimaryActionRows(),
      onSelect: (route: string) => {
        this.openRoute(route);
      }
    })
  }

  @Builder
  private buildSupportSection() {
    Card({
      title: '工作支持',
      subtitle: '消息、排班和考勤操作统一归档，减少页面跳转成本。',
      content: () => { this.buildSupportContent() }
    })
  }

  @Builder
  private buildSupportContent() {
    Column() {
      ProfileSettingsList({
        items: this.getSupportActions(),
        onSelect: (route: string) => {
          this.openRoute(route);
        }
      })

      Button('退出登录')
        .width('100%')
        .height(48)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(HarmonyReport.danger)
        .backgroundColor(HarmonyReport.dangerSurface)
        .borderRadius(18)
        .margin({ top: 14 })
        .onClick(() => this.handleLogout())
    }
    .width('100%')
  }

  private getWorkMetrics(): ProfileMetricItem[] {
    return [
      { label: '今日班次', value: '3', icon: $r('app.media.ic_calendar'), color: HarmonyReport.positive },
      { label: '点名记录', value: '28', icon: $r('app.media.ic_attendance'), color: HarmonyColor.brandBlue },
      { label: '作业反馈', value: '18', icon: $r('app.media.ic_homework'), color: HarmonyReport.caution },
      { label: '家校消息', value: '32', icon: $r('app.media.ic_message'), color: HarmonyColor.brandBlue },
      { label: '到课率', value: '98%', icon: $r('app.media.ic_report'), color: HarmonyReport.positive }
    ];
  }

  private getPrimaryActionRows(): ProfileActionItem[][] {
    return [
      [
        { title: '课堂点名', subtitle: '扫码签到和到课核验', icon: $r('app.media.ic_qrcode'), bgColor: '', iconColor: HarmonyReport.positive, route: RouteUrls.TEACHER_SCAN },
        { title: '班级考勤', subtitle: '缺勤、迟到与离校管理', icon: $r('app.media.ic_attendance'), bgColor: '', iconColor: HarmonyColor.brandBlue, route: RouteUrls.TEACHER_ATTENDANCE }
      ],
      [
        { title: '作业管理', subtitle: '布置作业和回收反馈', icon: $r('app.media.ic_homework'), bgColor: '', iconColor: HarmonyReport.caution, route: RouteUrls.TEACHER_HOMEWORK },
        { title: '课表安排', subtitle: '查看今日排班和值守计划', icon: $r('app.media.ic_calendar'), bgColor: '', iconColor: HarmonyReport.positive, route: RouteUrls.TEACHER_SCHEDULE }
      ],
      [
        { title: '消息中心', subtitle: '统一查看家校消息和通知', icon: $r('app.media.ic_message'), bgColor: '', iconColor: HarmonyColor.brandBlue, route: RouteUrls.TEACHER_MESSAGES },
        { title: '学生档案', subtitle: '查看学生详情和课堂备注', icon: $r('app.media.ic_child'), bgColor: '', iconColor: HarmonyColor.brandBlue, route: RouteUrls.TEACHER_STUDENT_DETAIL }
      ]
    ];
  }

  private getSupportActions(): ProfileActionItem[] {
    return [
      { title: '消息通知', subtitle: '收拢家校沟通和系统提醒', icon: $r('app.media.ic_message'), bgColor: '', iconColor: HarmonyColor.textSecondary, route: RouteUrls.TEACHER_MESSAGES },
      { title: '班次排班', subtitle: '查看今日班次和临时调整', icon: $r('app.media.ic_calendar'), bgColor: '', iconColor: HarmonyColor.textSecondary, route: RouteUrls.TEACHER_SCHEDULE },
      { title: '点名与考勤', subtitle: '快速进入课堂点名和考勤记录', icon: $r('app.media.ic_attendance'), bgColor: '', iconColor: HarmonyColor.textSecondary, route: RouteUrls.TEACHER_ATTENDANCE }
    ];
  }
}
