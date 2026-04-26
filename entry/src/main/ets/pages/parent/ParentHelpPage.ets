/**
 * SmartGuardian - Parent Help Page
 * Help center and feedback page
 */

import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';
import { LogUtil } from '../../utils/LogUtil';
import { UserStore } from '../../stores/userStore';
import { HarmonyColor } from '../../common/HarmonyDesign';

@Entry
@Component
struct ParentHelpPage {
  @State feedbackContent: string = '';
  @State contactInfo: string = '';
  @State isSubmitting: boolean = false;

  aboutToAppear() {
    ErrorHandlerUtil.setUIContext(this.getUIContext());
    const userInfo = UserStore.getUserInfo();
    if (userInfo && !this.contactInfo) {
      this.contactInfo = userInfo.mobile;
    }
  }

  private async submitFeedback(): Promise<void> {
    if (this.isSubmitting) {
      return;
    }
    if (!ErrorHandlerUtil.validateRequired(this.feedbackContent, '反馈内容')) {
      return;
    }

    this.isSubmitting = true;
    try {
      LogUtil.info('ParentHelpPage', `Feedback submitted: ${JSON.stringify({
        feedbackContent: this.feedbackContent.trim(),
        contactInfo: this.contactInfo.trim()
      })}`);
      ErrorHandlerUtil.showSuccessToast('反馈已提交，我们会尽快联系您');
      this.feedbackContent = '';
      this.contactInfo = UserStore.getUserInfo()?.mobile ?? '';
    } catch (error) {
      LogUtil.error('ParentHelpPage', `Submit feedback failed: ${String(error)}`);
      ErrorHandlerUtil.showErrorToast('反馈提交失败，请稍后重试');
    } finally {
      this.isSubmitting = false;
    }
  }

  build() {
    Column() {
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

        Text('')
          .width(24)
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
      .backgroundColor(HarmonyColor.surface)

      Scroll() {
        Column() {
          Column() {
            Text('常见问题')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 12 })

            this.buildQuestionItem('如何查看孩子的考勤记录？', '在首页点击“今日托管”卡片即可查看详细考勤信息。')
            this.buildQuestionItem('如何申请请假？', '在首页点击“请假”入口，填写请假信息后提交即可。')
            this.buildQuestionItem('如何进行接送签到？', '在首页点击“接送码”，到托管中心出示二维码完成验证。')
            this.buildQuestionItem('如何查看作业情况？', '在首页下方“最近作业”区域可查看老师布置与反馈情况。')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(HarmonyColor.surface)
          .borderRadius(12)
          .margin({ bottom: 16 })

          Column() {
            Text('联系客服')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 12 })

            this.buildContactRow('服务时间', '工作日 09:00 - 18:00')
            this.buildContactRow('热线电话', '400-800-1234')
            this.buildContactRow('处理承诺', '一般问题 1 个工作日内反馈')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(HarmonyColor.surface)
          .borderRadius(12)
          .margin({ bottom: 16 })

          Column() {
            Text('意见反馈')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 12 })

            TextArea({
              placeholder: '请输入您的意见、建议或遇到的问题',
              text: this.feedbackContent
            })
              .width('100%')
              .height(120)
              .backgroundColor($r('app.color.page_background'))
              .borderRadius(8)
              .padding({ left: 12, right: 12, top: 12, bottom: 12 })
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
              .padding({ left: 12, right: 12 })
              .margin({ top: 12 })
              .onChange((value: string) => {
                this.contactInfo = value;
              })

            Button(this.isSubmitting ? '提交中...' : '提交反馈')
              .width('100%')
              .height(44)
              .fontSize(16)
              .fontColor(HarmonyColor.textInverse)
              .backgroundColor($r('app.color.primary'))
              .borderRadius(22)
              .margin({ top: 16 })
              .enabled(!this.isSubmitting)
              .opacity(this.isSubmitting ? 0.7 : 1)
              .onClick(() => {
                this.submitFeedback();
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(HarmonyColor.surface)
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
  private buildQuestionItem(question: string, answer: string) {
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

  @Builder
  private buildContactRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))

      Blank()

      Text(value)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }
}

