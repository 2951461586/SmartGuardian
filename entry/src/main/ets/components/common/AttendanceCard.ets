/**
 * SmartGuardian - AttendanceCard Component
 * 可复用的考勤卡片组件
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';

export enum AttendanceStatus {
  NOT_SIGNED = 'NOT_SIGNED',
  SIGNED_IN = 'SIGNED_IN',
  SIGNED_OUT = 'SIGNED_OUT'
}

@Component
export struct AttendanceCard {
  @Prop studentId: number = 0;
  @Prop studentName: string = '';
  @Prop studentNo: string = '';
  @Prop status: AttendanceStatus = AttendanceStatus.NOT_SIGNED;
  @Prop signInTime: string = '';
  @Prop signOutTime: string = '';
  onSignIn?: () => void;
  onSignOut?: () => void;

  build() {
    Row() {
      Column() {
        Text(this.studentName)
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(this.studentNo)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.status === AttendanceStatus.NOT_SIGNED) {
        this.buildNotSignedContent()
      } else if (this.status === AttendanceStatus.SIGNED_IN) {
        this.buildSignedInContent()
      } else {
        this.buildSignedOutContent()
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(HarmonyColor.surface)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_content_margin') })
  }

  @Builder
  buildNotSignedContent() {
    Column() {
      Text(this.signInTime.length > 0 ? this.signInTime : '未签到')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))

      Button('签到')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(HarmonyColor.textInverse)
        .backgroundColor($r('app.color.primary'))
        .borderRadius($r('app.float.button_radius'))
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .margin({ top: 4 })
        .onClick(() => {
          if (this.onSignIn) {
            this.onSignIn();
          }
        })
    }
  }

  @Builder
  buildSignedInContent() {
    Column() {
      Text(`签到: ${this.signInTime.length > 0 ? this.signInTime : '--'}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(HarmonyReport.positive)

      Button('签退')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(HarmonyColor.textInverse)
        .backgroundColor(HarmonyReport.accent)
        .borderRadius($r('app.float.button_radius'))
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .margin({ top: 4 })
        .onClick(() => {
          if (this.onSignOut) {
            this.onSignOut();
          }
        })
    }
  }

  @Builder
  buildSignedOutContent() {
    Column() {
      Text(`签退: ${this.signOutTime.length > 0 ? this.signOutTime : '--'}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(HarmonyColor.textTertiary)
    }
  }
}
