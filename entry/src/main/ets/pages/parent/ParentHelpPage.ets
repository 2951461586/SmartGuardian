/**
 * SmartGuardian - Parent Help Page
 * 帮助与反馈页面
 */


@Entry
@Component
struct ParentHelpPage {
  @State feedbackContent: string = '';
  @State contactInfo: string = '';

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.text_primary'))
          .onClick(() => this.getUIContext().getRouter().back())

        Text('帮助与反馈')
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

      Scroll() {
        Column() {
          // 常见问题
          Column() {
            Text('常见问题')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 12 })

            this.buildQuestionItem('如何查看孩子的考勤记录？', '在首页点击"今日托管"卡片即可查看详细考勤信息。')
            this.buildQuestionItem('如何申请请假？', '在首页点击"请假"按钮，填写请假信息并提交。')
            this.buildQuestionItem('如何进行接送签到？', '在首页点击"接送码"，在托管中心出示二维码即可。')
            this.buildQuestionItem('如何查看作业情况？', '在首页下方"最近作业"区域可以查看作业完成情况。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 意见反馈
          Column() {
            Text('意见反馈')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 12 })

            TextArea({
              placeholder: '请输入您的意见和建议',
              text: this.feedbackContent
            })
              .width('100%')
              .height(120)
              .backgroundColor($r('app.color.page_background'))
              .borderRadius(8)
              .onChange((value: string) => {
                this.feedbackContent = value;
              })

            TextInput({
              placeholder: '联系方式（选填）',
              text: this.contactInfo
            })
              .width('100%')
              .height(44)
              .backgroundColor($r('app.color.page_background'))
              .borderRadius(8)
              .margin({ top: 12 })
              .onChange((value: string) => {
                this.contactInfo = value;
              })

            Button('提交反馈')
              .width('100%')
              .height(44)
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.primary'))
              .borderRadius(22)
              .margin({ top: 16 })
              .onClick(() => {
                // TODO: 提交反馈
                this.feedbackContent = '';
                this.contactInfo = '';
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
        }
        .width('100%')
        .padding($r('app.float.page_padding'))
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildQuestionItem(question: string, answer: string) {
    Column() {
      Text(question)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .width('100%')

      Text(answer)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })
        .width('100%')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({ width: { bottom: 1 }, color: $r('app.color.divider') })
  }
}