/**
 * SmartGuardian - Login Page
 * User login with account and password
 * Features: Privacy agreement, secure transmission
 */

import { AuthService } from '../services/api/auth';
import { UserStore } from '../stores/userStore';
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
        this.isPrivacyChecked = true;
        LogUtil.info('LoginPage', 'User agreed to privacy policy');
      },
      onDisagree: () => {
        this.isPrivacyChecked = false;
        LogUtil.info('LoginPage', 'User disagreed to privacy policy');
        this.errorMessage = '需要同意隐私协议才能使用本应用';
      }
    }),
    autoCancel: false,
    customStyle: true,
    alignment: DialogAlignment.Center
  });

  aboutToAppear() {
    const agreed = isPrivacyAgreed();
    this.isPrivacyChecked = agreed;

    if (!agreed) {
      this.privacyDialogController.open();
    }
  }

  async handleLogin() {
    if (!this.username || !this.password) {
      this.errorMessage = '请输入账号和密码';
      return;
    }

    if (!this.isPrivacyChecked && !isPrivacyAgreed()) {
      this.privacyDialogController.open();
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const request: LoginRequest = {
        username: this.username,
        password: this.password
      };

      LogUtil.info('LoginPage', `Attempting login for user: ${CryptoUtil.encryptSimple(this.username)}`);

      const resp = await AuthService.login(request);

      if (resp.code === 0 && resp.data) {
        setToken(resp.data.token);
        UserStore.setUserInfo(resp.data.userInfo);
        LogUtil.info('LoginPage', `Login successful for role: ${resp.data.userInfo.roleType}`);
        this.getUIContext().getRouter().replaceUrl({ url: 'pages/MainPage' });
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

  handlePrivacyLink() {
    this.privacyDialogController.open();
  }

  build() {
    Scroll() {
      Column() {
        this.buildHeroSection()
        this.buildLoginCard()
        this.buildDemoPanel()
      }
      .width('100%')
      .padding({ bottom: 28 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeroSection() {
    Column() {
      Column() {
        Image($r('app.media.ic_logo'))
          .width(72)
          .height(72)
          .objectFit(ImageFit.Contain)
      }
      .width(96)
      .height(96)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(28)
      .shadow({
        radius: 18,
        color: '#14000000',
        offsetX: 0,
        offsetY: 8
      })

      Text('智慧托管')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 20 })

      Text('家长、教师、管理端统一协同的学生智慧托管系统')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .textAlign(TextAlign.Center)
        .margin({ top: 10, left: 8, right: 8 })

      Row() {
        this.buildRoleTag('家长端')
        this.buildRoleTag('教师端')
        this.buildRoleTag('管理端')
      }
      .margin({ top: 18 })
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 72, bottom: 28 })
    .linearGradient({
      angle: 180,
      colors: [['#F2F7FF', 0], ['#F8FAFD', 1]]
    })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildRoleTag(label: string) {
    Text(label)
      .fontSize(12)
      .fontColor($r('app.color.primary'))
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(Color.White)
      .borderRadius(14)
      .margin({ left: 4, right: 4 })
  }

  @Builder
  buildLoginCard() {
    Column() {
      Text('账号登录')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Text('请输入账号与密码，进入你的专属工作台')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8, bottom: 20 })

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
        .height(52)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .backgroundColor('#F7F9FC')
      .borderRadius(14)

      Column() {
        Row() {
          Image($r('app.media.ic_lock'))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
            .fillColor($r('app.color.text_tertiary'))

          TextInput({
            placeholder: '请输入密码',
            text: this.password
          })
            .fontSize($r('app.float.text_primary_size'))
            .backgroundColor(Color.Transparent)
            .flexGrow(1)
            .margin({ left: 12 })
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .onChange((value: string) => {
              this.password = value;
            })

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
        .height(52)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .backgroundColor('#F7F9FC')
      .borderRadius(14)
      .margin({ top: 14 })

      Row() {
        Checkbox()
          .select(this.isPrivacyChecked)
          .selectedColor($r('app.color.primary'))
          .shape(CheckBoxShape.CIRCLE)
          .width(18)
          .height(18)
          .onChange((isChecked: boolean) => {
            this.isPrivacyChecked = isChecked;
            if (isChecked) {
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
      .alignItems(VerticalAlign.Center)
      .margin({ top: 18 })

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
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 12, bottom: 12 })
        .backgroundColor('#FFF3F1')
        .borderRadius(12)
        .margin({ top: 18 })
      }

      Button(this.isLoading ? '登录中...' : '登录')
        .width('100%')
        .height(52)
        .fontSize($r('app.float.text_primary_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(16)
        .enabled(!this.isLoading)
        .opacity(this.isLoading ? 0.75 : 1)
        .margin({ top: 22 })
        .onClick(() => {
          this.handleLogin();
        })

      Row() {
        Text('忘记密码?')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .onClick(() => {
            this.showError('功能开发中');
          })

        Blank()

        Text('注册账号')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.primary'))
          .onClick(() => {
            this.showError('功能开发中');
          })
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(22)
    .margin({ left: 16, right: 16, top: 16 })
    .shadow({
      radius: 18,
      color: '#12000000',
      offsetX: 0,
      offsetY: 8
    })
  }

  @Builder
  buildDemoPanel() {
    Column() {
      Text('演示环境')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Text('账号：13800000000')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 10 })

      Text('密码：123456')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })

      Text('登录后将根据角色自动进入对应工作台')
        .fontSize(12)
        .fontColor($r('app.color.text_tertiary'))
        .margin({ top: 10 })
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#F7FAFF')
    .borderRadius(18)
    .margin({ left: 16, right: 16, top: 14 })
    .alignItems(HorizontalAlign.Start)
  }

  private showError(message: string) {
    this.errorMessage = message;
    setTimeout(() => {
      this.errorMessage = '';
    }, 2000);
  }
}
