import { AuthService } from '../../services/api/auth';
import { UserStore } from '../../stores/userStore';

interface ProfileAction {
  title: string;
  subtitle: string;
  icon: Resource;
  bgColor: string;
  iconColor: string;
  route: string;
}

interface ProfileMetric {
  label: string;
  value: string;
  icon: Resource;
  color: string;
}

@Component
export struct ParentProfilePage {
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
    AppStorage.setOrCreate('main_auth_locked', true);
    try {
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/LoginPage' });
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
    Scroll() {
      Column() {
        this.buildProfileHeader()
        this.buildMemberPanel()
        this.buildOrderSection()
        this.buildFunctionGrid()
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
          .border({ width: 3, color: '#DCE8F6', radius: 38, style: BorderStyle.Solid })

        Column() {
          Row() {
            Text(this.userName || '家长用户')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text('家长')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#526F95')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor('#EEF4FA')
              .borderRadius(999)
              .margin({ left: 8 })
          }

          Text(this.mobile || '未绑定手机号')
            .fontSize(14)
            .fontColor('#52637A')
            .margin({ top: 8 })

          Text('孩子：张小明（三年级2班）')
            .fontSize(12)
            .fontColor('#526F95')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor('#FFFFFFCC')
            .borderRadius(999)
            .margin({ top: 10 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 14 })

        Column() {
          this.buildRoundTool($r('app.media.ic_settings'), 'pages/parent/ParentSettingsPage')
          Blank().height(10)
          this.buildRoundTool($r('app.media.ic_message'), 'pages/parent/ParentMessagesPage')
        }
      }
      .width('100%')

      Image($r('app.media.sg_illustration_children'))
        .width(140)
        .height(86)
        .objectFit(ImageFit.Contain)
        .opacity(0.28)
        .alignSelf(ItemAlign.End)
        .margin({ top: -32, right: 4, bottom: -8 })
    }
    .width('100%')
    .padding({ left: 20, right: 18, top: 18, bottom: 10 })
    .linearGradient({ angle: 135, colors: [['#FFFFFF', 0], ['#F1F6FC', 1]] })
    .borderRadius(28)
    .border({ width: 1, color: '#D7E2EC', radius: 28, style: BorderStyle.Solid })
    .shadow({ radius: 16, color: '#526F9510', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildRoundTool(icon: Resource, route: string) {
    Column() {
      Image(icon)
        .width(20)
        .height(20)
        .objectFit(ImageFit.Contain)
        .fillColor('#526F95')
    }
    .width(42)
    .height(42)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .border({ width: 1, color: '#E6ECF5', radius: 16, style: BorderStyle.Solid })
    .onClick(() => this.openRoute(route))
  }

  @Builder
  private buildMemberPanel() {
    Row() {
      Column() {
        Text('会员中心')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFE4BC')

        Text('托管提醒、成长记录和安全守护已开启')
          .fontSize(12)
          .fontColor('#FFFFFFB8')
          .margin({ top: 5 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('查看权益')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2E3B59')
        .padding({ left: 14, right: 14, top: 8, bottom: 8 })
        .backgroundColor('#FFE1B7')
        .borderRadius(999)
    }
    .width('100%')
    .padding({ left: 18, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#2F3F63')
    .borderRadius(22)
    .margin({ top: 14 })
  }

  @Builder
  private buildOrderSection() {
    Column() {
      this.buildSectionHeader('我的订单', '全部订单', () => this.openRoute('pages/parent/ParentOrdersPage'))

      Row() {
        ForEach(this.getOrderMetrics(), (metric: ProfileMetric) => {
          this.buildMetricItem(metric)
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
  private buildMetricItem(metric: ProfileMetric) {
    Column() {
      Image(metric.icon)
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)
        .fillColor(metric.color)

      Text(metric.label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#0F172A')
        .margin({ top: 8 })

      Text(metric.value)
        .fontSize(14)
        .fontColor('#667085')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildFunctionGrid() {
    Column() {
      this.buildSectionHeader('常用功能', '', undefined)
      this.buildActionRow(this.getPrimaryActions().slice(0, 2))
      this.buildActionRow(this.getPrimaryActions().slice(2, 4))
      this.buildActionRow(this.getPrimaryActions().slice(4, 6))
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
  private buildActionRow(actions: ProfileAction[]) {
    Row() {
      ForEach(actions, (action: ProfileAction) => {
        this.buildActionItem(action)
      })
    }
    .width('100%')
    .margin({ top: 14 })
  }

  @Builder
  private buildActionItem(action: ProfileAction) {
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
    .onClick(() => this.openRoute(action.route))
  }

  @Builder
  private buildSecuritySection() {
    Column() {
      this.buildSectionHeader('安全与设置', '', undefined)
      this.buildListRow('账号与安全', '手机号、登录密码和设备管理', $r('app.media.ic_lock'), 'pages/parent/ParentSettingsPage')
      this.buildListRow('帮助中心', '常见问题与服务说明', $r('app.media.ic_help'), 'pages/parent/ParentHelpPage')
      this.buildListRow('关于我们', '版本信息与平台介绍', $r('app.media.ic_about'), 'pages/parent/ParentAboutPage')

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
  private buildListRow(title: string, subtitle: string, icon: Resource, route: string) {
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
    .border({ width: { bottom: 1 }, color: '#EEF2F7', style: BorderStyle.Solid })
    .onClick(() => this.openRoute(route))
  }

  @Builder
  private buildSectionHeader(title: string, actionText: string, action?: () => void) {
    Row() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#0F172A')
      Blank()
      if (actionText) {
        Row() {
          Text(actionText)
            .fontSize(13)
            .fontColor('#667085')
          Image($r('app.media.ic_arrow_right'))
            .width(15)
            .height(15)
            .objectFit(ImageFit.Contain)
            .fillColor('#98A2B3')
            .margin({ left: 3 })
        }
        .onClick(() => {
          if (action) {
            action();
          }
        })
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  private getOrderMetrics(): ProfileMetric[] {
    return [
      { label: '待支付', value: '0', icon: $r('app.media.ic_order'), color: '#526F95' },
      { label: '待审核', value: '1', icon: $r('app.media.ic_calendar'), color: '#A9794E' },
      { label: '进行中', value: '2', icon: $r('app.media.ic_attendance'), color: '#5D8267' },
      { label: '已完成', value: '12', icon: $r('app.media.ic_success'), color: '#7B6D96' },
      { label: '已取消', value: '3', icon: $r('app.media.ic_refund'), color: '#A75A61' }
    ];
  }

  private getPrimaryActions(): ProfileAction[] {
    return [
      { title: '我的孩子', subtitle: '学生档案与绑定', icon: $r('app.media.ic_child'), bgColor: '#EEF4FA', iconColor: '#526F95', route: 'pages/parent/ParentChildrenPage' },
      { title: '托管记录', subtitle: '预约和签到记录', icon: $r('app.media.ic_attendance'), bgColor: '#EEF6F0', iconColor: '#5D8267', route: 'pages/parent/ParentTimelinePage' },
      { title: '费用缴纳', subtitle: '账单与支付记录', icon: $r('app.media.ic_money'), bgColor: '#F6F0E9', iconColor: '#A9794E', route: 'pages/parent/ParentOrdersPage' },
      { title: '地址管理', subtitle: '接送与联系地址', icon: $r('app.media.ic_location'), bgColor: '#EEF4FA', iconColor: '#526F95', route: 'pages/parent/ParentProfileEditPage' },
      { title: '意见反馈', subtitle: '问题和服务建议', icon: $r('app.media.ic_message'), bgColor: '#F2F0F7', iconColor: '#7B6D96', route: 'pages/parent/ParentHelpPage' },
      { title: '联系客服', subtitle: '托管服务支持', icon: $r('app.media.ic_help'), bgColor: '#F8EEEE', iconColor: '#A75A61', route: 'pages/parent/ParentHelpPage' }
    ];
  }
}
