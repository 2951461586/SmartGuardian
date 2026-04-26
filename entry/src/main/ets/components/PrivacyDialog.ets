/**
 * SmartGuardian - Privacy Agreement Dialog Component
 */

import { StorageKeys } from '../constants/app.constants';

@CustomDialog
export struct PrivacyDialog {
  controller: CustomDialogController;
  onAgree: () => void = () => {};
  onDisagree: () => void = () => {};

  handleAgree(): void {
    AppStorage.setOrCreate(StorageKeys.PRIVACY_AGREED, true);
    this.onAgree();
    this.controller.close();
  }

  handleDisagree(): void {
    this.onDisagree();
    this.controller.close();
  }

  build() {
    Column() {
      Text('Privacy Policy')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 20, bottom: 16 })

      Scroll() {
        Column() {
          Text('SmartGuardian privacy agreement')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ bottom: 12 })

          Text(this.getPrivacyContent())
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .lineHeight(24)
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .width('100%')
      .height(300)
      .scrollBar(BarState.Auto)

      Row() {
        Button('Decline')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor('#EEF3FA')
          .borderRadius(22)
          .onClick(() => {
            this.handleDisagree();
          })

        Button('Agree')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(22)
          .margin({ left: 12 })
          .onClick(() => {
            this.handleAgree();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 20 })
    }
    .width('100%')
    .constraintSize({ maxWidth: 420 })
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }

  private getPrivacyContent(): string {
    return 'This dialog explains how SmartGuardian collects, stores, and uses account, student, attendance, homework, order, and message data. The app will not continue until you agree.';
  }
}

export function isPrivacyAgreed(): boolean {
  return AppStorage.get<boolean>(StorageKeys.PRIVACY_AGREED) ?? false;
}

export function showPrivacyDialogIfNeeded(onAgree: () => void, onDisagree: () => void): boolean {
  if (isPrivacyAgreed()) {
    return false;
  }
  return true;
}
