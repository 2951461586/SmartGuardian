import { AuthService } from '../../services/api/auth';
import { UserStore } from '../../stores/userStore';

interface TeacherProfileAction {
  title: string;
  subtitle: string;
  icon: Resource;
  bgColor: string;
  iconColor: string;
  route?: string;
  tabIndex?: number;
}

interface TeacherProfileMetric {
  label: string;
  value: string;
}

@Component
export struct TeacherProfilePage {
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
    AppStorage.setOrCreate('main_auth_locked', true);
    try {
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/LoginPage' });
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
    Scroll() {
      Column() {
        this.buildProfileHeader()
        this.buildWorkData()
        this.buildFunctionGrid()
        this.buildServiceSection()
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
          .border({ width: 3, color: '#DDEBDD', radius: 38, style: BorderStyle.Solid })

        Column() {
          Row() {
            Text(this.userName || '教师用户')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text('教师')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#5D8267')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor('#EEF6F0')
              .borderRadius(999)
              .margin({ left: 8 })
          }

          Text(this.mobile || '未绑定手机号')
            .fontSize(14)
            .fontColor('#52637A')
            .margin({ top: 8 })

          Row() {
            Text('教龄 5 年')
              .fontSize(12)
              .fontColor('#5D8267')
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .backgroundColor('#FFFFFFCC')
              .borderRadius(999)
            Text('三年级（2）班主任')
              .fontSize(12)
              .fontColor('#5D8267')
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .backgroundColor('#FFFFFFCC')
              .borderRadius(999)
              .margin({ left: 8 })
          }
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

      Image($r('app.media.sg_illustration_teaching'))
        .width(148)
        .height(88)
        .objectFit(ImageFit.Contain)
        .opacity(0.26)
        .alignSelf(ItemAlign.End)
        .margin({ top: -34, right: 2, bottom: -8 })
    }
    .width('100%')
    .padding({ left: 20, right: 18, top: 18, bottom: 10 })
    .linearGradient({ angle: 135, colors: [['#FFFFFF', 0], ['#EFF8F2', 1]] })
    .borderRadius(28)
    .border({ width: 1, color: '#D7E6DA', radius: 28, style: BorderStyle.Solid })
    .shadow({ radius: 16, color: '#5D826710', offsetX: 0, offsetY: 8 })
  }

  @Builder
  private buildRoundTool(icon: Resource) {
    Column() {
      Image(icon)
        .width(20)
        .height(20)
        .objectFit(ImageFit.Contain)
        .fillColor('#5D8267')
    }
    .width(42)
    .height(42)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .border({ width: 1, color: '#E6ECF5', radius: 16, style: BorderStyle.Solid })
  }

  @Builder
  private buildWorkData() {
    Column() {
      this.buildSectionHeader('工作数据', '查看详情')
      Row() {
        ForEach(this.getMetrics(), (metric: TeacherProfileMetric) => {
          this.buildMetric(metric)
        })
      }
      .width('100%')
      .margin({ top: 16 })
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
  private buildMetric(metric: TeacherProfileMetric) {
    Column() {
      Text(metric.value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2F9E77')

      Text(metric.label)
        .fontSize(12)
        .fontColor('#667085')
        .margin({ top: 7 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildFunctionGrid() {
    Column() {
      this.buildSectionHeader('常用功能', '')
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
  private buildActionRow(actions: TeacherProfileAction[]) {
    Row() {
      ForEach(actions, (action: TeacherProfileAction) => {
        this.buildActionItem(action)
      })
    }
    .width('100%')
    .margin({ top: 14 })
  }

  @Builder
  private buildActionItem(action: TeacherProfileAction) {
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
  private buildServiceSection() {
    Column() {
      this.buildSectionHeader('设置与服务', '')
      this.buildListRow('账号与安全', '手机号、密码和登录设备管理', $r('app.media.ic_lock'))
      this.buildListRow('通知设置', '班次变更、家校消息和异常提醒', $r('app.media.ic_notification'))
      this.buildListRow('帮助中心', '教学端使用说明和问题反馈', $r('app.media.ic_help'))
      this.buildListRow('关于我们', '版本 1.0.0', $r('app.media.ic_about'))

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

  private getMetrics(): TeacherProfileMetric[] {
    return [
      { label: '本月签到次数', value: '25天' },
      { label: '本月批改作业', value: '18份' },
      { label: '本月沟通记录', value: '32条' },
      { label: '课堂点名', value: '8次' },
      { label: '整体完成率', value: '98%' }
    ];
  }

  private getActions(): TeacherProfileAction[] {
    return [
      { title: '我的班级', subtitle: '学生名单与状态', icon: $r('app.media.ic_child'), bgColor: '#EEF6F0', iconColor: '#5D8267', tabIndex: 1 },
      { title: '课程表', subtitle: '今日排班安排', icon: $r('app.media.ic_calendar'), bgColor: '#EEF4FA', iconColor: '#526F95', route: 'pages/teacher/TeacherSchedulePage' },
      { title: '作业批改', subtitle: '作业反馈记录', icon: $r('app.media.ic_homework'), bgColor: '#F6F0E9', iconColor: '#A9794E', tabIndex: 3 },
      { title: '通知管理', subtitle: '家校消息通知', icon: $r('app.media.ic_message'), bgColor: '#F2F0F7', iconColor: '#7B6D96', tabIndex: 2 },
      { title: '点名记录', subtitle: '扫码与考勤明细', icon: $r('app.media.ic_attendance'), bgColor: '#EEF6F0', iconColor: '#5D8267', tabIndex: 1 },
      { title: '更多功能', subtitle: '教学资源与评价', icon: $r('app.media.ic_service'), bgColor: '#EEF4FA', iconColor: '#526F95' }
    ];
  }
}
