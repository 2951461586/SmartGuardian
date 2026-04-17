/**
 * SmartGuardian - Login Page
 * User login with account and password
 */

import { router } from '@kit.ArkUI';
import { AuthService } from '../services/api/auth';
import { UserStore } from '../stores/userStore';
import { UserRole } from '../models/common';
import { LoginRequest } from '../models/user';

@Entry
@Component
struct LoginPage {
  @State accountNo: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State showPassword: boolean = false;

  async handleLogin() {
    if (!this.accountNo || !this.password) {
      this.errorMessage = '请输入账号和密码';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const request: LoginRequest = {
        accountNo: this.accountNo,
        password: this.password
      };

      const resp = await AuthService.login(request);

      if (resp.code === 0 && resp.data) {
        // Save token and user info
        UserStore.setUserInfo(resp.data.userInfo);
        // Note: Token should also be saved using setToken()

        // Navigate to main page
        router.replaceUrl({ url: 'pages/MainPage' });
      } else {
        this.errorMessage = resp.message || '登录失败';
      }
    } catch (error) {
      this.errorMessage = '网络错误，请稍后重试';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // Logo and title area
      Column() {
        Image($r('app.media.ic_logo'))
          .width(80)
          .height(80)
          .objectFit(ImageFit.Contain)
          .margin({ bottom: 24 })

        Text('智慧托管')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary'))

        Text('让托管更智能，让家长更安心')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      }
      .width('100%')
      .padding({ top: 80, bottom: 60 })

      // Login form
      Column() {
        // Account input
        Column() {
          Row() {
            Image($r('app.media.ic_user'))
              .width(20)
              .height(20)
              .objectFit(ImageFit.Contain)
              .fillColor($r('app.color.text_tertiary'))

            TextInput({
              placeholder: '请输入账号',
              text: this.accountNo
            })
              .fontSize($r('app.float.text_primary_size'))
              .backgroundColor(Color.Transparent)
              .flexGrow(1)
              .margin({ left: 12 })
              .onChange((value: string) => {
                this.accountNo = value;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius($r('app.float.card_border_radius'))
        .margin({ bottom: 16 })

        // Password input
        Column() {
          Row() {
            Image($r('app.media.ic_lock'))
              .width(20)
              .height(20)
              .objectFit(ImageFit.Contain)
              .fillColor($r('app.color.text_tertiary'))

            if (this.showPassword) {
              TextInput({
                placeholder: '请输入密码',
                text: this.password
              })
                .fontSize($r('app.float.text_primary_size'))
                .backgroundColor(Color.Transparent)
                .flexGrow(1)
                .margin({ left: 12 })
                .onChange((value: string) => {
                  this.password = value;
                })
            } else {
              TextInput({
                placeholder: '请输入密码',
                text: this.password
              })
                .fontSize($r('app.float.text_primary_size'))
                .backgroundColor(Color.Transparent)
                .flexGrow(1)
                .margin({ left: 12 })
                .type(InputType.Password)
                .onChange((value: string) => {
                  this.password = value;
                })
            }

            Image(this.showPassword ? $r('app.media.ic_eye_open') : $r('app.media.ic_eye_close'))
              .width(20)
              .height(20)
              .objectFit(ImageFit.Contain)
              .fillColor($r('app.color.text_tertiary'))
              .onClick(() => {
                this.showPassword = !this.showPassword;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius($r('app.float.card_border_radius'))
        .margin({ bottom: 24 })

        // Error message
        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.error'))
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 16 })
        }

        // Login button
        Button('登录')
          .width('100%')
          .height(48)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary'))
          .borderRadius($r('app.float.button_radius'))
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleLogin();
          })

        if (this.isLoading) {
          LoadingProgress()
            .color(Color.White)
            .width(24)
            .height(24)
            .position({ x: '50%', y: '50%' })
        }

        // Bottom links
        Row() {
          Text('忘记密码?')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.primary'))
            .onClick(() => {
              // TODO: Navigate to reset password
            })

          Blank()

          Text('注册账号')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.primary'))
            .onClick(() => {
              // TODO: Navigate to register
            })
        }
        .width('100%')
        .margin({ top: 24 })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      // Demo login hint
      Column() {
        Text('演示账号: 13800000000 / 123456')
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor($r('app.color.text_tertiary'))
          .margin({ bottom: 8 })

        Text('点击登录直接进入演示模式')
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor($r('app.color.text_tertiary'))
      }
      .width('100%')
      .padding({ bottom: 40 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}