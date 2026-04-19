/**
 * SmartGuardian - Login Page
 * User login with account and password
 * Features: Privacy agreement, password encryption, secure transmission
 */

import { router } from '@kit.ArkUI';
import { AuthService } from '../services/api/auth';
import { UserStore } from '../stores/userStore';
import { UserRole } from '../models/common';
import { LoginRequest } from '../models/user';
import { setToken } from '../utils/request';
import { PrivacyDialog, isPrivacyAgreed } from '../components/PrivacyDialog';
import { CryptoUtil } from '../utils/CryptoUtil';
import { LogUtil } from '../utils/LogUtil';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State showPassword: boolean = false;
  @State isPrivacyChecked: boolean = false;

  privacyDialogController: CustomDialogController = new CustomDialogController({
    builder: PrivacyDialog({
      onAgree: () => {
        // 用户同意隐私协议
        this.isPrivacyChecked = true;
        LogUtil.info('LoginPage', 'User agreed to privacy policy');
      },
      onDisagree: () => {
        // 用户拒绝隐私协议
        this.isPrivacyChecked = false;
        LogUtil.info('LoginPage', 'User disagreed to privacy policy');
        // 无法登录，显示提示
        this.errorMessage = '需要同意隐私协议才能使用本应用';
      }
    }),
    autoCancel: false,
    customStyle: true,
    alignment: DialogAlignment.Center
  });

  aboutToAppear() {
    // 检查是否已经同意过隐私协议
    const agreed = isPrivacyAgreed();
    this.isPrivacyChecked = agreed;
    
    if (!agreed) {
      // 未同意过，显示隐私协议弹窗
      this.privacyDialogController.open();
    }
  }

  /**
   * Handle login
   */
  async handleLogin() {
    // 验证输入
    if (!this.username || !this.password) {
      this.errorMessage = '请输入账号和密码';
      return;
    }

    // 检查隐私协议
    if (!this.isPrivacyChecked && !isPrivacyAgreed()) {
      this.privacyDialogController.open();
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      // 使用加密工具哈希密码（增强安全性）
      const hashedPassword = await CryptoUtil.hashPassword(this.password);
      
      const request: LoginRequest = {
        username: this.username,
        password: hashedPassword // 传输哈希后的密码
      };

      LogUtil.info('LoginPage', `Attempting login for user: ${CryptoUtil.encryptSimple(this.username)}`);

      const resp = await AuthService.login(request);

      if (resp.code === 0 && resp.data) {
        // Save token and user info
        setToken(resp.data.token);
        UserStore.setUserInfo(resp.data.userInfo);
        
        LogUtil.info('LoginPage', `Login successful for role: ${resp.data.userInfo.roleType}`);
        
        // Navigate to main page
        router.replaceUrl({ url: 'pages/MainPage' });
      } else {
        this.errorMessage = resp.message || '登录失败，请检查账号密码';
        LogUtil.warn('LoginPage', `Login failed: ${resp.message}`);
      }
    } catch (error) {
      this.errorMessage = '网络错误，请检查网络连接后重试';
      LogUtil.error('LoginPage', `Login error: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Handle privacy agreement click
   */
  handlePrivacyLink() {
    this.privacyDialogController.open();
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
              text: this.username
            })
              .fontSize($r('app.float.text_primary_size'))
              .backgroundColor(Color.Transparent)
              .flexGrow(1)
              .margin({ left: 12 })
              .onChange((value: string) => {
                this.username = value;
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
        .margin({ bottom: 16 })

        // Privacy agreement checkbox
        Row() {
          Checkbox()
            .select(this.isPrivacyChecked)
            .selectedColor($r('app.color.primary'))
            .shape(CheckBoxShape.CIRCLE)
            .width(16)
            .height(16)
            .onChange((isChecked: boolean) => {
              this.isPrivacyChecked = isChecked;
              if (isChecked) {
                // 如果勾选，存储同意状态
                AppStorage.setOrCreate('privacy_agreed', true);
              }
            })
          
          Text('我已阅读并同意')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ left: 8 })
          
          Text('《用户隐私协议》')
            .fontSize(12)
            .fontColor($r('app.color.primary'))
            .onClick(() => this.handlePrivacyLink())
        }
        .width('100%')
        .margin({ bottom: 16 })

        // Error message
        if (this.errorMessage) {
          Row() {
            Image($r('app.media.ic_warning'))
              .width(16)
              .height(16)
              .fillColor($r('app.color.error'))
              .margin({ right: 8 })
            
            Text(this.errorMessage)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.error'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
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
          .opacity(this.isLoading ? 0.6 : 1)
          .onClick(() => {
            this.handleLogin();
          })

        if (this.isLoading) {
          Row() {
            LoadingProgress()
              .color(Color.White)
              .width(20)
              .height(20)
            
            Text('登录中...')
              .fontSize(14)
              .fontColor(Color.White)
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .position({ x: 0, y: 14 })
        }

        // Bottom links
        Row() {
          Text('忘记密码?')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .onClick(() => {
              // TODO: Navigate to reset password
              this.showError('功能开发中');
            })

          Blank()

          Text('注册账号')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.primary'))
            .onClick(() => {
              // TODO: Navigate to register
              this.showError('功能开发中');
            })
        }
        .width('100%')
        .margin({ top: 24 })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      // Demo login hint
      Column() {
        Row() {
          Image($r('app.media.ic_info'))
            .width(14)
            .height(14)
            .fillColor($r('app.color.text_tertiary'))
          
          Text(' 演示账号: 13800000000 / 密码: 123456')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
        }
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

  private showError(message: string) {
    this.errorMessage = message;
    setTimeout(() => {
      this.errorMessage = '';
    }, 2000);
  }
}
