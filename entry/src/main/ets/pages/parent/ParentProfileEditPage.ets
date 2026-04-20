/**
 * SmartGuardian - Parent Profile Edit Page
 * 个人信息编辑页面
 */

import router from '@ohos.router';
import { UserStore } from '../../stores/userStore';
import { AuthService } from '../../services/api/auth';

@Entry
@Component
struct ParentProfileEditPage {
  @State userName: string = '';
  @State mobile: string = '';
  @State avatar: string = '';
  @State isSaving: boolean = false;

  aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
      this.mobile = userInfo.mobile;
      this.avatar = userInfo.avatar || '';
    }
  }

  async selectAvatar() {
    try {
      // TODO: 实现图片选择功能
      // 临时设置一个默认头像
      this.avatar = 'mock_avatar_path';
      console.log('Avatar selected');
    } catch (error) {
      console.error('Select avatar failed:', error);
    }
  }

  async saveProfile() {
    this.isSaving = true;
    try {
      // TODO: 调用API更新用户信息
      const userInfo = UserStore.getUserInfo();
      if (userInfo) {
        userInfo.realName = this.userName;
        userInfo.avatar = this.avatar;
        UserStore.setUserInfo(userInfo);
      }
      router.back();
    } catch (error) {
      console.error('Save profile failed:', error);
    } finally {
      this.isSaving = false;
    }
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.ic_arrow_left'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.text_primary'))
          .onClick(() => router.back())

        Text('编辑资料')
          .fontSize($r('app.float.page_title_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('保存')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.primary'))
          .enabled(!this.isSaving)
          .onClick(() => this.saveProfile())
      }
      .width('100%')
      .padding($r('app.float.page_padding'))
      .backgroundColor(Color.White)

      Scroll() {
        Column() {
          // Avatar
          Column() {
            if (this.avatar) {
              Image(this.avatar)
                .width(100)
                .height(100)
                .borderRadius(50)
                .objectFit(ImageFit.Cover)
            } else {
              Image($r('app.media.ic_default_avatar'))
                .width(100)
                .height(100)
                .borderRadius(50)
            }

            Button('更换头像')
              .fontSize(14)
              .fontColor($r('app.color.primary'))
              .backgroundColor('#F0F4FF')
              .borderRadius(20)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .margin({ top: 12 })
              .onClick(() => this.selectAvatar())
          }
          .margin({ top: 32, bottom: 24 })

          // Form
          Column() {
            // Name
            Row() {
              Text('姓名')
                .fontSize($r('app.float.text_primary_size'))
                .fontColor($r('app.color.text_primary'))
                .width(80)

              TextInput({ text: this.userName })
                .width('100%')
                .height(48)
                .backgroundColor(Color.Transparent)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.userName = value;
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })

            Divider()

            // Mobile
            Row() {
              Text('手机号')
                .fontSize($r('app.float.text_primary_size'))
                .fontColor($r('app.color.text_primary'))
                .width(80)

              Text(this.mobile)
                .fontSize($r('app.float.text_primary_size'))
                .fontColor($r('app.color.text_secondary'))
                .layoutWeight(1)
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
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
}