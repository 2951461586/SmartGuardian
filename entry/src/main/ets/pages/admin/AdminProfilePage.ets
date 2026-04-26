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
struct AdminProfilePage {
  build() {
    Stack() {
      AdminProfilePageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct AdminProfilePageContent {
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
      console.warn('AdminProfilePage logout api failed:', String(error));
    }
    UserStore.clearUserInfo();
    AppStorage.setOrCreate(StorageKeys.MAIN_AUTH_LOCKED, true);
    try {
      this.getUIContext().getRouter().replaceUrl({ url: RouteUrls.LOGIN });
    } catch (error) {
      console.error('AdminProfilePage logout redirect failed:', String(error));
    }
  }

  private openRoute(url: string): void {
    try {
      this.getUIContext().getRouter().pushUrl({ url });
    } catch (error) {
      console.error('AdminProfilePage open route failed:', String(error));
    }
  }

  build() {
    Column() {
      ProfileWorkspaceTemplate({
        hero: this.buildHeroSection,
        summary: this.buildSummarySection,
        actions: this.buildActionSection,
        support: this.buildSupportSection
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildHeroSection() {
    Column() {
      ProfileHeroCard({
        userName: this.userName || '机构管理员',
        roleLabel: '机构端',
        mobile: this.mobile || '未绑定手机号',
        avatar: this.avatar,
        primaryMeta: '学生、订单、班次和经营数据统一收口',
        secondaryMeta: '阳光托管中心 · AGC Serverless',
        metaChips: ['学生档案', '订单审核', '经营报表'],
        illustration: $r('app.media.sg_illustration_education'),
        actionContent: this.buildHeroActions
      })

      ProfileHighlightBanner({
        title: '机构驾驶舱',
        subtitle: '围绕班次负载、消息提醒和经营指标统一查看。',
        actionText: '打开报表',
        onAction: () => {
          this.openRoute(RouteUrls.ADMIN_REPORTS);
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
          this.openRoute(RouteUrls.ADMIN_MESSAGES);
        }
      })

      Blank().height(10)

      ProfileUtilityButton({
        icon: $r('app.media.ic_report'),
        onClickAction: () => {
          this.openRoute(RouteUrls.ADMIN_REPORTS);
        }
      })
    }
  }

  @Builder
  private buildSummarySection() {
    Card({
      title: '经营指标',
      subtitle: '聚焦收入、待处理订单、班次负载和风险提醒。',
      actionText: '查看报表',
      onAction: () => {
        this.openRoute(RouteUrls.ADMIN_REPORTS);
      },
      content: this.buildSummaryContent
    })
  }

  @Builder
  private buildSummaryContent() {
    ProfileMetricStrip({
      metrics: this.getOperationMetrics()
    })
  }

  @Builder
  private buildActionSection() {
    Card({
      title: '管理入口',
      subtitle: '学生、服务、订单和告警都进入统一治理入口。',
      content: this.buildActionContent
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
      title: '运营支持',
      subtitle: '消息、退款和服务配置等配套能力统一放在这里。',
      content: this.buildSupportContent
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

  private getOperationMetrics(): ProfileMetricItem[] {
    return [
      { label: '今日收入', value: '¥12.6k', icon: $r('app.media.ic_money'), color: HarmonyReport.caution },
      { label: '待处理订单', value: '12', icon: $r('app.media.ic_order'), color: HarmonyColor.brandBlue },
      { label: '班次负载', value: '82%', icon: $r('app.media.ic_calendar'), color: HarmonyReport.positive },
      { label: '机构消息', value: '28', icon: $r('app.media.ic_message'), color: HarmonyColor.brandBlue },
      { label: '风险告警', value: '3', icon: $r('app.media.ic_notification'), color: HarmonyReport.danger }
    ];
  }

  private getPrimaryActionRows(): ProfileActionItem[][] {
    return [
      [
        { title: '学生档案', subtitle: '维护学生和监护关系', icon: $r('app.media.ic_child'), bgColor: '', iconColor: HarmonyColor.brandBlue, route: RouteUrls.ADMIN_STUDENTS },
        { title: '服务产品', subtitle: '管理托管产品和价格', icon: $r('app.media.ic_service'), bgColor: '', iconColor: HarmonyReport.caution, route: RouteUrls.ADMIN_SERVICES }
      ],
      [
        { title: '班次排期', subtitle: '协调教室、教师和容量', icon: $r('app.media.ic_calendar'), bgColor: '', iconColor: HarmonyReport.positive, route: RouteUrls.ADMIN_SESSIONS },
        { title: '订单管理', subtitle: '处理支付、审核和状态流转', icon: $r('app.media.ic_order'), bgColor: '', iconColor: HarmonyColor.brandBlue, route: RouteUrls.ADMIN_ORDERS }
      ],
      [
        { title: '数据报表', subtitle: '查看经营指标和趋势变化', icon: $r('app.media.ic_report'), bgColor: '', iconColor: HarmonyColor.brandBlue, route: RouteUrls.ADMIN_REPORTS },
        { title: '告警中心', subtitle: '统一处理异常和风险事项', icon: $r('app.media.ic_notification'), bgColor: '', iconColor: HarmonyReport.danger, route: RouteUrls.ADMIN_ALERTS }
      ]
    ];
  }

  private getSupportActions(): ProfileActionItem[] {
    return [
      { title: '机构消息', subtitle: '查看系统通知和运营消息', icon: $r('app.media.ic_message'), bgColor: '', iconColor: HarmonyColor.textSecondary, route: RouteUrls.ADMIN_MESSAGES },
      { title: '退款处理', subtitle: '收口退款审核和售后跟进', icon: $r('app.media.ic_refund'), bgColor: '', iconColor: HarmonyColor.textSecondary, route: RouteUrls.ADMIN_REFUNDS },
      { title: '服务配置', subtitle: '维护服务产品和运营参数', icon: $r('app.media.ic_service'), bgColor: '', iconColor: HarmonyColor.textSecondary, route: RouteUrls.ADMIN_SERVICES }
    ];
  }
}
