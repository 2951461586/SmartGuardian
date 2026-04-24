/**
 * SmartGuardian - Parent About Page
 * 关于我们页面
 */

@Entry
@Component
struct ParentAboutPage {
  @State version: string = '1.0.0';

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.text_primary'))
          .onClick(() => this.getUIContext().getRouter().back())

        Text('关于我们')
          .fontSize($r('app.float.page_title_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('').width(24)
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
      .backgroundColor(Color.White)

      Column() {
        Image($r('app.media.ic_logo'))
          .width(100)
          .height(100)
          .margin({ top: 60 })

        Text('智慧学生托管系统')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary'))
          .margin({ top: 16 })

        Text(`版本 ${this.version}`)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })

        Column() {
          Text('智慧学生托管系统是一款专业的托管服务管理应用，致力于为家长提供便捷、高效、安心的托管服务体验。')
            .fontSize($r('app.float.text_primary_size'))
            .fontColor($r('app.color.text_primary'))
            .lineHeight(24)
            .textAlign(TextAlign.Center)
            .margin({ top: 32 })
        }
        .padding(16)

        Column() {
          this.buildFeatureItem('实时考勤', '随时掌握孩子签到签退情况')
          this.buildFeatureItem('作业管理', '及时了解作业完成进度')
          this.buildFeatureItem('安全接送', '通过接送码核验保障接送安全')
          this.buildFeatureItem('消息通知', '重要信息实时推送提醒')
        }
        .width('100%')
        .padding(16)
        .margin({ top: 24 })

        Column() {
          Text('© 2026 智慧学生托管系统团队')
            .fontSize($r('app.float.text_tiny_size'))
            .fontColor($r('app.color.text_tertiary'))

          Text('保留所有权利')
            .fontSize($r('app.float.text_tiny_size'))
            .fontColor($r('app.color.text_tertiary'))
            .margin({ top: 4 })
        }
        .margin({ top: 40 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder
  buildFeatureItem(title: string, description: string) {
    Row() {
      Column() {
        Text(title)
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .width('100%')

        Text(description)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }
}

