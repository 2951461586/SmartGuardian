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
struct ParentProfilePage {
  build() {
    Stack() {
      ParentProfilePageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct ParentProfilePageContent {
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
      console.warn('ParentProfilePage logout api failed:', String(error));
    }
    UserStore.clearUserInfo();
    AppStorage.setOrCreate(StorageKeys.MAIN_AUTH_LOCKED, true);
    try {
      this.getUIContext().getRouter().replaceUrl({ url: RouteUrls.LOGIN });
    } catch (error) {
      console.error('ParentProfilePage logout redirect failed:', String(error));
    }
  }

  private openRoute(url: string): void {
    try {
      this.getUIContext().getRouter().pushUrl({ url });
    } catch (error) {
      console.error('ParentProfilePage open route failed:', String(error));
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
        userName: this.userName || '家长用户',
        roleLabel: '家长端',
        mobile: this.mobile || '未绑定手机号',
        avatar: this.avatar,
        primaryMeta: '孩子在校状态、作业反馈和托管订单统一收口',
        secondaryMeta: '当前家庭：张小明 · 三年级 2 班',
        metaChips: ['家庭中心', '托管订单', '成长动态'],
        illustration: $r('app.media.sg_illustration_children'),
        actionContent: this.buildHeroActions
      })

      ProfileHighlightBanner({
        title: '家庭守护中心',
        subtitle: '签到提醒、成长记录和托管服务都从这一页进入。',
        actionText: '查看订单',
        onAction: () => {
          this.openRoute(RouteUrls.PARENT_ORDERS);
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
        icon: $r('app.media.ic_settings'),
        onClickAction: () => {
          this.openRoute(RouteUrls.PARENT_SETTINGS);
        }
      })

      Blank().height(10)

      ProfileUtilityButton({
        icon: $r('app.media.ic_message'),
        onClickAction: () => {
          this.openRoute(RouteUrls.PARENT_MESSAGES);
        }
      })
    }
  }

  @Builder
  private buildSummarySection() {
    Card({
      title: '订单与服务概览',
      subtitle: '围绕订单状态、托管安排和费用信息快速查看。',
      actionText: '全部订单',
      onAction: () => {
        this.openRoute(RouteUrls.PARENT_ORDERS);
      },
      content: () => { this.buildSummaryContent() }
    })
  }

  @Builder
  private buildSummaryContent() {
    ProfileMetricStrip({
      metrics: this.getOrderMetrics()
    })
  }

  @Builder
  private buildActionSection() {
    Card({
      title: '常用功能',
      subtitle: '把孩子档案、托管记录、费用和服务支持集中在一个入口。',
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
      title: '安全与设置',
      subtitle: '账号安全、帮助说明和平台信息统一归档。',
      content: () => { this.buildSupportContent() }
    })
  }

  @Builder
  private buildSupportContent() {
    Column() {
      ProfileSettingsList({
        items: this.getSecurityActions(),
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

  private getOrderMetrics(): ProfileMetricItem[] {
    return [
      { label: '待支付', value: '0', icon: $r('app.media.ic_order'), color: HarmonyColor.brandBlue },
      { label: '待审核', value: '1', icon: $r('app.media.ic_calendar'), color: HarmonyReport.caution },
      { label: '进行中', value: '2', icon: $r('app.media.ic_attendance'), color: HarmonyReport.positive },
      { label: '已完成', value: '12', icon: $r('app.media.ic_success'), color: HarmonyColor.brandBlue },
      { label: '已取消', value: '3', icon: $r('app.media.ic_refund'), color: HarmonyReport.danger }
    ];
  }

  private getPrimaryActionRows(): ProfileActionItem[][] {
    return [
      [
        { title: '我的孩子', subtitle: '学生档案与绑定信息', icon: $r('app.media.ic_child'), bgColor: '', iconColor: HarmonyColor.brandBlue, route: RouteUrls.PARENT_CHILDREN },
        { title: '托管记录', subtitle: '预约、签到与成长动态', icon: $r('app.media.ic_attendance'), bgColor: '', iconColor: HarmonyReport.positive, route: RouteUrls.PARENT_TIMELINE }
      ],
      [
        { title: '费用缴纳', subtitle: '订单与支付记录', icon: $r('app.media.ic_money'), bgColor: '', iconColor: HarmonyReport.caution, route: RouteUrls.PARENT_ORDERS },
        { title: '地址管理', subtitle: '接送地址与联系人', icon: $r('app.media.ic_location'), bgColor: '', iconColor: HarmonyColor.brandBlue, route: RouteUrls.PARENT_PROFILE_EDIT }
      ],
      [
        { title: '意见反馈', subtitle: '提交问题和服务建议', icon: $r('app.media.ic_message'), bgColor: '', iconColor: HarmonyColor.brandBlue, route: RouteUrls.PARENT_HELP },
        { title: '联系客服', subtitle: '获取托管服务支持', icon: $r('app.media.ic_help'), bgColor: '', iconColor: HarmonyReport.danger, route: RouteUrls.PARENT_HELP }
      ]
    ];
  }

  private getSecurityActions(): ProfileActionItem[] {
    return [
      { title: '账号与安全', subtitle: '管理手机号、密码和设备登录', icon: $r('app.media.ic_lock'), bgColor: '', iconColor: HarmonyColor.textSecondary, route: RouteUrls.PARENT_SETTINGS },
      { title: '帮助中心', subtitle: '查看常见问题和服务说明', icon: $r('app.media.ic_help'), bgColor: '', iconColor: HarmonyColor.textSecondary, route: RouteUrls.PARENT_HELP },
      { title: '关于我们', subtitle: '查看版本信息与平台介绍', icon: $r('app.media.ic_about'), bgColor: '', iconColor: HarmonyColor.textSecondary, route: RouteUrls.PARENT_ABOUT }
    ];
  }
}
