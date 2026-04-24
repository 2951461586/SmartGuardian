import { AuthService } from '../../services/api/auth';
import { UserStore } from '../../stores/userStore';

interface AdminProfileAction {
  title: string;
  subtitle: string;
  icon: Resource;
  bgColor: string;
  iconColor: string;
  route?: string;
  tabIndex?: number;
}

interface AdminProfileMetric {
  label: string;
  value: string;
  bgColor: string;
  valueColor: string;
}

@Component
export struct AdminProfilePage {
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
    AppStorage.setOrCreate('main_auth_locked', true);
    try {
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/LoginPage' });
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
    Scroll() {
      Column() {
        this.buildProfileHeader()
        this.buildOperationStats()
        this.buildManagementGrid()
        this.buildSecuritySection()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildProfileHeader() {
    Column() {
      Row() {
        Image(this.avatar || $r('app.media.ic_default_avatar'))
          .width(76)
          .height(76)
          .borderRadius(38)
          .objectFit(ImageFit.Cover)
          .border({ width: 3, color: '#E3DDED', radius: 38, style: BorderStyle.Solid })

        Column() {
          Row() {
            Text(this.userName || '机构管理员')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text('机构')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#7B6D96')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor('#F2F0F7')
              .borderRadius(999)
              .margin({ left: 8 })
          }

          Text(this.mobile || '未绑定手机号')
            .fontSize(14)
            .fontColor('#52637A')
            .margin({ top: 8 })

          Text('阳光托管中心 · 高级机构')
            .fontSize(12)
            .fontColor('#7B6D96')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor('#FFFFFFCC')
            .borderRadius(999)
            .margin({ top: 10 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 14 })

        Column() {
          this.buildRoundTool($r('app.media.ic_settings'))
          Blank().height(10)
          this.buildRoundTool($r('app.media.ic_message'))
        }
      }
      .width('100%')

      Image($r('app.media.sg_illustration_education'))
        .width(148)
        .height(88)
        .objectFit(ImageFit.Contain)
        .opacity(0.26)
        .alignSelf(ItemAlign.End)
        .margin({ top: -34, right: 2, bottom: -8 })
    }
    .width('100%')
    .padding({ left: 20, right: 18, top: 18, bottom: 10 })
    .linearGradient({ angle: 135, colors: [['#FFFFFF', 0], ['#F7F4FB', 1]] })
    .borderRadius(28)
    .border({ width: 1, color: '#DED8EA', radius: 28, style: BorderStyle.Solid })
    .shadow({ radius: 16, color: '#7B6D9610', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildRoundTool(icon: Resource) {
    Column() {
      Image(icon)
        .width(20)
        .height(20)
        .objectFit(ImageFit.Contain)
        .fillColor('#7B6D96')
    }
    .width(42)
    .height(42)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .border({ width: 1, color: '#E6ECF5', radius: 16, style: BorderStyle.Solid })
  }

  @Builder
  private buildOperationStats() {
    Column() {
      this.buildSectionHeader('经营概况', '查看详情')
      Row() {
        ForEach(this.getMetrics(), (metric: AdminProfileMetric) => {
          this.buildMetric(metric)
        })
      }
      .width('100%')
      .margin({ top: 14 })
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#E6ECF5', radius: 24, style: BorderStyle.Solid })
    .shadow({ radius: 12, color: '#526F950D', offsetX: 0, offsetY: 6 })
    .margin({ top: 14 })
  }

  @Builder
  private buildMetric(metric: AdminProfileMetric) {
    Column() {
      Text(metric.value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(metric.valueColor)
      Text(metric.label)
        .fontSize(12)
        .fontColor('#667085')
        .margin({ top: 8 })
    }
    .layoutWeight(1)
    .height(88)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(metric.bgColor)
    .borderRadius(20)
    .margin({ right: 8 })
  }

  @Builder
  private buildManagementGrid() {
    Column() {
      this.buildSectionHeader('管理入口', '')
      this.buildActionRow(this.getActions().slice(0, 2))
      this.buildActionRow(this.getActions().slice(2, 4))
      this.buildActionRow(this.getActions().slice(4, 6))
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#E6ECF5', radius: 24, style: BorderStyle.Solid })
    .shadow({ radius: 12, color: '#526F950D', offsetX: 0, offsetY: 6 })
    .margin({ top: 14 })
  }

  @Builder
  private buildActionRow(actions: AdminProfileAction[]) {
    Row() {
      ForEach(actions, (action: AdminProfileAction) => {
        this.buildActionItem(action)
      })
    }
    .width('100%')
    .margin({ top: 14 })
  }

  @Builder
  private buildActionItem(action: AdminProfileAction) {
    Row() {
      Column() {
        Image(action.icon)
          .width(21)
          .height(21)
          .objectFit(ImageFit.Contain)
          .fillColor(action.iconColor)
      }
      .width(46)
      .height(46)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(action.bgColor)
      .borderRadius(16)

      Column() {
        Text(action.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#0F172A')
        Text(action.subtitle)
          .fontSize(12)
          .fontColor('#667085')
          .margin({ top: 5 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 10 })
    }
    .layoutWeight(1)
    .height(78)
    .padding({ left: 10, right: 10 })
    .onClick(() => {
      if (action.tabIndex !== undefined) {
        AppStorage.setOrCreate('main_current_index', action.tabIndex);
      } else if (action.route) {
        this.openRoute(action.route);
      }
    })
  }

  @Builder
  private buildSecuritySection() {
    Column() {
      this.buildSectionHeader('账号安全', '')
      this.buildListRow('权限管理', '角色、审批人和菜单权限', $r('app.media.ic_lock'))
      this.buildListRow('机构资料', '基础信息、联系方式和服务范围', $r('app.media.ic_info'))
      this.buildListRow('通知设置', '运营提醒、订单和异常通知', $r('app.media.ic_notification'))
      this.buildListRow('关于平台', '版本 1.0.0', $r('app.media.ic_about'))

      Button('退出登录')
        .width('100%')
        .height(48)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#A75A61')
        .backgroundColor('#F8EEEE')
        .borderRadius(18)
        .margin({ top: 14 })
        .onClick(() => this.handleLogout())
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: '#E6ECF5', radius: 24, style: BorderStyle.Solid })
    .shadow({ radius: 12, color: '#526F950D', offsetX: 0, offsetY: 6 })
    .margin({ top: 14 })
  }

  @Builder
  private buildListRow(title: string, subtitle: string, icon: Resource) {
    Row() {
      Image(icon)
        .width(21)
        .height(21)
        .objectFit(ImageFit.Contain)
        .fillColor('#66738A')
      Column() {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#0F172A')
        Text(subtitle)
          .fontSize(12)
          .fontColor('#667085')
          .margin({ top: 5 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      Image($r('app.media.ic_arrow_right'))
        .width(18)
        .height(18)
        .objectFit(ImageFit.Contain)
        .fillColor('#98A2B3')
    }
    .width('100%')
    .height(64)
  }

  @Builder
  private buildSectionHeader(title: string, actionText: string) {
    Row() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0F172A')
      Blank()
      if (actionText) {
        Text(actionText)
          .fontSize(13)
          .fontColor('#667085')
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  private getMetrics(): AdminProfileMetric[] {
    return [
      { label: '今日收入', value: '￥8.6k', bgColor: '#F6F0E9', valueColor: '#A9794E' },
      { label: '班次负载', value: '82%', bgColor: '#F2F0F7', valueColor: '#7B6D96' },
      { label: '待处理', value: '12', bgColor: '#EEF4FA', valueColor: '#526F95' }
    ];
  }

  private getActions(): AdminProfileAction[] {
    return [
      { title: '学生档案', subtitle: '维护学生与监护人', icon: $r('app.media.ic_child'), bgColor: '#EEF4FA', iconColor: '#526F95', tabIndex: 1 },
      { title: '服务产品', subtitle: '托管项目与价格', icon: $r('app.media.ic_service'), bgColor: '#F6F0E9', iconColor: '#A9794E', route: 'pages/admin/AdminServicesPage' },
      { title: '班次排课', subtitle: '教室与教师容量', icon: $r('app.media.ic_session'), bgColor: '#EEF6F0', iconColor: '#5D8267', route: 'pages/admin/AdminSessionsPage' },
      { title: '订单管理', subtitle: '审批、支付与退款', icon: $r('app.media.ic_order'), bgColor: '#F2F0F7', iconColor: '#7B6D96', tabIndex: 2 },
      { title: '告警中心', subtitle: '异常与风险处理', icon: $r('app.media.ic_alert_center'), bgColor: '#F8EEEE', iconColor: '#A75A61', route: 'pages/admin/AdminAlertsPage' },
      { title: '数据统计', subtitle: '经营报表分析', icon: $r('app.media.ic_report'), bgColor: '#EEF4FA', iconColor: '#526F95', tabIndex: 3 }
    ];
  }
}
