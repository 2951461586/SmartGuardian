/**
 * SmartGuardian - Parent Settings Page
 * 账户设置页面
 */

import router from '@ohos.router';
import { UserStore } from '../../stores/userStore';

@Entry
@Component
struct ParentSettingsPage {
  @State notificationEnabled: boolean = true;
  @State autoSignReminder: boolean = true;
  @State language: string = '简体中文';

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.text_primary'))
          .onClick(() => router.back())

        Text('账户设置')
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

      // Settings List
      Scroll() {
        Column() {
          // 通知设置
          Column() {
            Row() {
              Column() {
                Text('消息通知')
                  .fontSize($r('app.float.text_primary_size'))
                  .fontColor($r('app.color.text_primary'))
                
                Text('接收消息推送提醒')
                  .fontSize($r('app.float.text_secondary_size'))
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.notificationEnabled })
                .onChange((isOn: boolean) => {
                  this.notificationEnabled = isOn;
                })
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 签到提醒
          Column() {
            Row() {
              Column() {
                Text('签到提醒')
                  .fontSize($r('app.float.text_primary_size'))
                  .fontColor($r('app.color.text_primary'))
                
                Text('自动提醒孩子签到/签退')
                  .fontSize($r('app.float.text_secondary_size'))
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.autoSignReminder })
                .onChange((isOn: boolean) => {
                  this.autoSignReminder = isOn;
                })
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ bottom: 12 })

          // 语言设置
          Row() {
            Text('语言')
              .fontSize($r('app.float.text_primary_size'))
              .fontColor($r('app.color.text_primary'))

            Blank()

            Text(this.language)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .margin({ right: 8 })

            Image($r('app.media.ic_arrow_right'))
              .width(16)
              .height(16)
              .fillColor($r('app.color.text_tertiary'))
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            // TODO: 显示语言选择对话框
          })

          // 清除缓存
          Row() {
            Text('清除缓存')
              .fontSize($r('app.float.text_primary_size'))
              .fontColor($r('app.color.text_primary'))

            Blank()

            Image($r('app.media.ic_arrow_right'))
              .width(16)
              .height(16)
              .fillColor($r('app.color.text_tertiary'))
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 12 })
          .onClick(() => {
            // TODO: 清除缓存
          })
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
}