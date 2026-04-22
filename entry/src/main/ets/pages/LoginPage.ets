/**
 * SmartGuardian - Login Page
 * Unified login entrance for parent, teacher and admin roles
 */

import { ApiConfig, ApiEnvironment } from '../config/api.config';
import { PrivacyDialog, isPrivacyAgreed } from '../components/PrivacyDialog';
import { LoginRequest } from '../models/user';
import { AuthService } from '../services/api/auth';
import { UserStore } from '../stores/userStore';
import { CryptoUtil } from '../utils/CryptoUtil';
import { LogUtil } from '../utils/LogUtil';
import { setToken } from '../utils/request';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State showPassword: boolean = false;
  @State isPrivacyChecked: boolean = false;
  @State currentEnv: string = ApiConfig.getCurrentEnv();
  @State apiBaseUrl: string = ApiConfig.getConfiguredBaseUrl();

  private privacyDialogController: CustomDialogController = new CustomDialogController({
    builder: PrivacyDialog({
      onAgree: () => {
        this.isPrivacyChecked = true;
        LogUtil.info('LoginPage', 'User agreed to privacy policy');
      },
      onDisagree: () => {
        this.isPrivacyChecked = false;
        this.errorMessage = '请先同意隐私政策后再继续登录。';
      }
    }),
    autoCancel: false,
    customStyle: true,
    alignment: DialogAlignment.Center
  });

  aboutToAppear() {
    this.isPrivacyChecked = isPrivacyAgreed();
    this.currentEnv = ApiConfig.getCurrentEnv();
    this.apiBaseUrl = ApiConfig.getConfiguredBaseUrl();

    if (!this.isPrivacyChecked) {
      this.privacyDialogController.open();
    }
  }

  private persistApiConfig(): boolean {
    if (this.currentEnv === ApiEnvironment.TEST_REAL) {
      const normalizedUrl = this.apiBaseUrl.trim();
      if (!normalizedUrl) {
        this.errorMessage = '真实后端模式下请输入服务地址。';
        return false;
      }
      ApiConfig.applyRuntimeConfig(this.currentEnv, normalizedUrl);
    } else {
      ApiConfig.applyRuntimeConfig(ApiEnvironment.DEV_MOCK);
    }
    return true;
  }

  private handleEnvChange(env: string): void {
    this.currentEnv = env;
    this.errorMessage = '';
    if (env === ApiEnvironment.DEV_MOCK) {
      ApiConfig.applyRuntimeConfig(ApiEnvironment.DEV_MOCK);
    }
  }

  async handleLogin() {
    if (!this.username.trim() || !this.password.trim()) {
      this.errorMessage = '请输入账号和密码。';
      return;
    }

    if (!this.isPrivacyChecked && !isPrivacyAgreed()) {
      this.privacyDialogController.open();
      return;
    }

    if (!this.persistApiConfig()) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const request: LoginRequest = {
        username: this.username.trim(),
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
        this.errorMessage = resp.message || '登录失败，请检查账号密码或服务状态。';
      }
    } catch (error) {
      this.errorMessage = this.currentEnv === ApiEnvironment.TEST_REAL
        ? '真实后端请求失败，请检查服务地址、网络和账号配置。'
        : '网络请求失败，请稍后再试。';
      LogUtil.error('LoginPage', `Login error: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  private showTempMessage(message: string): void {
    this.errorMessage = message;
    setTimeout(() => {
      this.errorMessage = '';
    }, 2200);
  }

  build() {
    Scroll() {
      Column() {
        this.buildHeroSection()
        this.buildLoginPanel()
        this.buildEnvironmentPanel()
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
  private buildHeroSection() {
    Column() {
      Text('统一登录入口')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#EAF1FF')
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor('#FFFFFF1F')
        .borderRadius(999)

      Text('智慧学生托管系统')
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .width('100%')
        .margin({ top: 18 })

      Text('家长端、教师端与管理端共用同一入口，登录后自动进入对应工作台。')
        .fontSize(15)
        .lineHeight(22)
        .fontColor('#E8EEFF')
        .width('100%')
        .margin({ top: 10 })

      Row() {
        this.buildRoleTag('家长端')
        this.buildRoleTag('教师端')
        this.buildRoleTag('管理端')
      }
      .width('100%')
      .margin({ top: 18 })

      Row() {
        this.buildHeroMetric('3', '角色视图')
        this.buildHeroMetric(ApiConfig.getEnvironmentLabel(), '当前环境')
      }
      .width('100%')
      .margin({ top: 22 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 72, bottom: 32 })
    .linearGradient({
      angle: 145,
      colors: [['#2C68FF', 0], ['#1749C7', 0.62], ['#0F2359', 1]]
    })
    .borderRadius({ bottomLeft: 28, bottomRight: 28 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildRoleTag(label: string) {
    Text(label)
      .fontSize(12)
      .fontColor(Color.White)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor('#FFFFFF1A')
      .borderRadius(16)
      .margin({ right: 8 })
  }

  @Builder
  private buildHeroMetric(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text(label)
        .fontSize(12)
        .fontColor('#D9E6FF')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF14')
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
    .margin({ right: label === '角色视图' ? 10 : 0 })
  }

  @Builder
  private buildLoginPanel() {
    Column() {
      Row() {
        Column() {
          Text('账号登录')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text('输入账号信息，进入对应角色的业务工作台。')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(ApiConfig.getEnvironmentLabel())
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary'))
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#EEF4FF')
          .borderRadius(999)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      this.buildInputRow($r('app.media.ic_user'), '请输入账号', this.username, false)
      this.buildInputRow($r('app.media.ic_lock'), '请输入密码', this.password, true)

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

        Text('《隐私政策》')
          .fontSize(12)
          .fontColor($r('app.color.primary'))
          .onClick(() => this.privacyDialogController.open())
      }
      .width('100%')
      .margin({ top: 18 })

      if (this.errorMessage) {
        Row() {
          Image($r('app.media.ic_warning'))
            .width(16)
            .height(16)
            .fillColor($r('app.color.error'))
            .margin({ right: 8 })

          Text(this.errorMessage)
            .fontSize(13)
            .fontColor($r('app.color.error'))
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 12, bottom: 12 })
        .backgroundColor('#FFF4F4')
        .borderRadius(14)
        .margin({ top: 18 })
      }

      Button(this.isLoading ? '登录中...' : '进入系统')
        .width('100%')
        .height(52)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(18)
        .enabled(!this.isLoading)
        .opacity(this.isLoading ? 0.72 : 1)
        .margin({ top: 22 })
        .onClick(() => {
          this.handleLogin();
        })

      Row() {
        Text('忘记密码')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .onClick(() => this.showTempMessage('当前版本暂未接入密码重置流程。'))

        Blank()

        Text('联系管理员')
          .fontSize(13)
          .fontColor($r('app.color.primary'))
          .onClick(() => this.showTempMessage('如需账号协助，请联系平台管理员。'))
      }
      .width('100%')
      .margin({ top: 18 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(24)
    .border({
      width: 1,
      color: '#EAF0F7',
      radius: 24,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 18,
      color: '#10172F14',
      offsetX: 0,
      offsetY: 8
    })
    .margin({ left: 16, right: 16, top: 18 })
  }

  @Builder
  private buildInputRow(icon: Resource, placeholder: string, value: string, isPassword: boolean) {
    Column() {
      Row() {
        Image(icon)
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
          .fillColor($r('app.color.text_tertiary'))

        TextInput({
          placeholder,
          text: value
        })
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .flexGrow(1)
          .margin({ left: 12 })
          .type(isPassword && !this.showPassword ? InputType.Password : InputType.Normal)
          .onChange((inputValue: string) => {
            if (isPassword) {
              this.password = inputValue;
            } else {
              this.username = inputValue;
            }
          })

        if (isPassword) {
          Image(this.showPassword ? $r('app.media.ic_eye_open') : $r('app.media.ic_eye_close'))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
            .fillColor($r('app.color.text_tertiary'))
            .onClick(() => {
              this.showPassword = !this.showPassword;
            })
        }
      }
      .width('100%')
      .height(54)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .backgroundColor('#F7FAFD')
    .borderRadius(16)
    .margin({ top: 16 })
  }

  @Builder
  private buildEnvironmentPanel() {
    Column() {
      Text('联调设置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')

      Text('默认使用模拟数据；切换到真实后端后，可连接部署在 8080 端口的服务。')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .lineHeight(20)
        .width('100%')
        .margin({ top: 8 })

      Row() {
        this.buildEnvChip('模拟演示', ApiEnvironment.DEV_MOCK)
        this.buildEnvChip('真实后端', ApiEnvironment.TEST_REAL)
      }
      .width('100%')
      .margin({ top: 16 })

      if (this.currentEnv === ApiEnvironment.TEST_REAL) {
        Column() {
          TextInput({
            placeholder: '请输入后端服务地址',
            text: this.apiBaseUrl
          })
            .fontSize(15)
            .backgroundColor('#F7FAFD')
            .borderRadius(16)
            .height(52)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.apiBaseUrl = value;
            })

          Button('保存服务地址')
            .width('100%')
            .height(46)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary'))
            .backgroundColor('#EDF4FF')
            .borderRadius(16)
            .margin({ top: 12 })
            .onClick(() => {
              if (this.persistApiConfig()) {
                this.showTempMessage('联调配置已保存。');
              }
            })
        }
        .width('100%')
        .margin({ top: 16 })
      }

      Column() {
        Text('演示账号：13800000000')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))

        Text('演示密码：123456')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 14, bottom: 14 })
      .backgroundColor('#F8FBFF')
      .borderRadius(18)
      .margin({ top: 16 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(24)
    .border({
      width: 1,
      color: '#EAF0F7',
      radius: 24,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 16,
      color: '#10172F12',
      offsetX: 0,
      offsetY: 8
    })
    .margin({ left: 16, right: 16, top: 14 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildEnvChip(label: string, env: string) {
    Text(label)
      .fontSize(13)
      .fontWeight(this.currentEnv === env ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.currentEnv === env ? $r('app.color.primary') : $r('app.color.text_secondary'))
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(this.currentEnv === env ? '#EDF4FF' : '#F7FAFD')
      .borderRadius(16)
      .border({
        width: 1,
        color: this.currentEnv === env ? '#D7E5FF' : '#EAF0F7',
        radius: 16,
        style: BorderStyle.Solid
      })
      .margin({ right: 10 })
      .onClick(() => {
        this.handleEnvChange(env);
      })
  }
}
