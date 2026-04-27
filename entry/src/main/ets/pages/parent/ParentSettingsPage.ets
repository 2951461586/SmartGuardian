/**
 * SmartGuardian - Parent Settings Page
 * 账户设置页面
 */

import { AttendanceStore } from '../../stores/attendanceStore';
import { MessageStore } from '../../stores/messageStore';
import { OrderStore } from '../../stores/orderStore';
import { StudentStore } from '../../stores/studentStore';
import { UserStore } from '../../stores/userStore';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';
import { HarmonyCapabilityService } from '../../services/HarmonyCapabilityService';
import { HarmonyColor, HarmonyRadius, HarmonySpace } from '../../common/HarmonyDesign';

@Entry
@Component
struct ParentSettingsPage {
  @State notificationEnabled: boolean = true;
  @State autoSignReminder: boolean = true;
  @State language: string = '简体中文';
  private readonly languageOptions: string[] = ['简体中文'];

  aboutToAppear() {
    this.loadPreferences();
  }

  private loadPreferences(): void {
    const preferences = UserStore.getUserPreferences();
    this.notificationEnabled = preferences.enableNotifications !== false;
    this.autoSignReminder = preferences.enableAttendanceReminder !== false;
    this.language = '简体中文';
  }

  private async updateNotificationPreference(enabled: boolean): Promise<void> {
    this.notificationEnabled = enabled;
    UserStore.updateUserPreferences({ enableNotifications: enabled });
    if (!enabled) {
      await HarmonyCapabilityService.disableNotifications();
      return;
    }
    await HarmonyCapabilityService.syncMessageBadge(MessageStore.getUnreadCount());
  }

  private updateAttendanceReminder(enabled: boolean): void {
    this.autoSignReminder = enabled;
    UserStore.updateUserPreferences({ enableAttendanceReminder: enabled });
  }

  private switchLanguage(): void {
    const currentIndex = this.languageOptions.indexOf(this.language);
    const nextIndex = currentIndex >= 0 ? (currentIndex + 1) % this.languageOptions.length : 0;
    const nextLanguage = this.languageOptions[nextIndex];

    this.language = nextLanguage;
    UserStore.updateUserPreferences({
      language: 'zh_CN'
    });
    ErrorHandlerUtil.showSuccessToast(`语言已切换为${nextLanguage}`);
  }

  private clearLocalCache(): void {
    StudentStore.clearStudentList();
    OrderStore.clearOrderList();
    MessageStore.clearMessages();
    AttendanceStore.clearTodayAttendance();
    AttendanceStore.clearCurrentSession();
    ErrorHandlerUtil.showSuccessToast('缓存已清除');
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width($r('app.float.icon_large_size'))
          .height($r('app.float.icon_large_size'))
          .fillColor($r('app.color.text_primary'))
          .onClick(() => this.getUIContext().getRouter().back())

        Text('账户设置')
          .fontSize($r('app.float.page_title_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('').width($r('app.float.icon_large_size'))
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
      .backgroundColor(HarmonyColor.surface)

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
                  .margin({ top: HarmonySpace.compact / 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.notificationEnabled })
                .onChange((isOn: boolean) => {
                  this.updateNotificationPreference(isOn);
                })
            }
            .width('100%')
            .padding(HarmonySpace.page)
          }
          .width('100%')
          .backgroundColor(HarmonyColor.surface)
          .borderRadius(HarmonyRadius.control)
          .margin({ bottom: HarmonySpace.section })

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
                  .margin({ top: HarmonySpace.compact / 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.autoSignReminder })
                .onChange((isOn: boolean) => {
                  this.updateAttendanceReminder(isOn);
                })
            }
            .width('100%')
            .padding(HarmonySpace.page)
          }
          .width('100%')
          .backgroundColor(HarmonyColor.surface)
          .borderRadius(HarmonyRadius.control)
          .margin({ bottom: HarmonySpace.section })

          // 语言设置
          Row() {
            Text('语言')
              .fontSize($r('app.float.text_primary_size'))
              .fontColor($r('app.color.text_primary'))

            Blank()

            Text(this.language)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .margin({ right: HarmonySpace.compact })

            Image($r('app.media.ic_arrow_right'))
              .width($r('app.float.icon_small_size'))
              .height($r('app.float.icon_small_size'))
              .fillColor($r('app.color.text_tertiary'))
          }
          .width('100%')
          .padding(HarmonySpace.page)
          .backgroundColor(HarmonyColor.surface)
          .borderRadius(HarmonyRadius.control)
          .onClick(() => {
            this.switchLanguage();
          })

          // 清除缓存
          Row() {
            Text('清除缓存')
              .fontSize($r('app.float.text_primary_size'))
              .fontColor($r('app.color.text_primary'))

            Blank()

            Image($r('app.media.ic_arrow_right'))
              .width($r('app.float.icon_small_size'))
              .height($r('app.float.icon_small_size'))
              .fillColor($r('app.color.text_tertiary'))
          }
          .width('100%')
          .padding(HarmonySpace.page)
          .backgroundColor(HarmonyColor.surface)
          .borderRadius(HarmonyRadius.control)
          .margin({ top: HarmonySpace.section })
          .onClick(() => {
            this.clearLocalCache();
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

