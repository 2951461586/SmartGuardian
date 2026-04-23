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
  @State rememberPassword: boolean = true;
  @State currentEnv: string = ApiConfig.getCurrentEnv();
  @State apiBaseUrl: string = ApiConfig.getConfiguredBaseUrl();
  @State selectedPortal: string = 'PARENT';

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
        this.errorMessage = '本地后端模式下请输入服务地址。';
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
    } else {
      this.apiBaseUrl = ApiConfig.getConfiguredBaseUrl();
    }
  }

  private handlePortalChange(portal: string): void {
    this.selectedPortal = portal;
    this.errorMessage = '';
  }

  private fillDemoAccount(portal: string): void {
    this.selectedPortal = portal;
    if (portal === 'PARENT') {
      this.username = 'parent_zhang';
    } else if (portal === 'TEACHER') {
      this.username = 'teacher_wang';
    } else {
      this.username = 'admin_li';
    }
    this.password = '123456';
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
        ? '本地后端请求失败，请检查 Spring Boot 服务、MySQL 和联调地址。'
        : '网络请求失败，请稍后重试。';
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

  private getPortalLabel(): string {
    if (this.selectedPortal === 'TEACHER') {
      return '教师端';
    }
    if (this.selectedPortal === 'ADMIN') {
      return '管理端';
    }
    return '家长端';
  }

  private getPortalHint(): string {
    if (this.selectedPortal === 'TEACHER') {
      return '班次、考勤和作业协同统一在一个入口完成。';
    }
    if (this.selectedPortal === 'ADMIN') {
      return '聚焦学生、订单、报表和运营看板的统一控制台。';
    }
    return '托管预约、签到动态和家校沟通统一进入家长工作台。';
  }

  private getAccountPlaceholder(): string {
    if (this.selectedPortal === 'PARENT') {
      return '请输入账号 / 手机号';
    }
    return '请输入用户名 / 工号';
  }

  build() {
    Scroll() {
      Column() {
        this.buildHeroSection()
        this.buildLoginCard()
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
      Row() {
        Column() {
          Row() {
            Image($r('app.media.ic_logo'))
              .width(74)
              .height(74)
              .objectFit(ImageFit.Contain)
              .backgroundColor('#FFFFFF')
              .borderRadius(24)

            Blank()
          }
          .width('100%')

          Text('智慧学生管理系统')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2451A6')
            .margin({ top: 18 })

          Text('科技赋能教育 · 智慧成就未来')
            .fontSize(16)
            .fontColor('#7B93C4')
            .margin({ top: 10 })

          Row() {
            this.buildHeroChip('统一登录')
            this.buildHeroChip('三端分流')
            this.buildHeroChip(this.currentEnv === ApiEnvironment.TEST_REAL ? '本地后端' : '模拟演示')
          }
          .width('100%')
          .margin({ top: 18 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Image($r('app.media.startIcon'))
          .width(116)
          .height(116)
          .objectFit(ImageFit.Contain)
          .opacity(0.28)
          .margin({ left: 12, top: 36 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding({ left: 22, right: 22, top: 72, bottom: 26 })
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildHeroChip(label: string) {
    Text(label)
      .fontSize(11)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.primary'))
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor('#EAF2FF')
      .borderRadius(999)
      .margin({ right: 8 })
  }

  @Builder
  private buildLoginCard() {
    Column() {
      Text('欢迎回来')
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')

      Text(`当前入口：${this.getPortalLabel()} · ${this.getPortalHint()}`)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .lineHeight(21)
        .width('100%')
        .margin({ top: 8 })

      Row() {
        this.buildPortalCard('家长', 'PARENT', '预约与动态')
        Blank().width(10)
        this.buildPortalCard('教师', 'TEACHER', '考勤与作业')
        Blank().width(10)
        this.buildPortalCard('管理', 'ADMIN', '运营与审核')
      }
      .width('100%')
      .margin({ top: 18 })

      this.buildInputRow($r('app.media.ic_user'), this.getAccountPlaceholder(), this.username, false)
      this.buildInputRow($r('app.media.ic_lock'), '请输入密码', this.password, true)

      Row() {
        Row() {
          Checkbox()
            .select(this.rememberPassword)
            .selectedColor($r('app.color.primary'))
            .width(18)
            .height(18)
            .onChange((isChecked: boolean) => {
              this.rememberPassword = isChecked;
            })

          Text('记住密码')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ left: 8 })
        }

        Blank()

        Text('忘记密码？')
          .fontSize(13)
          .fontColor($r('app.color.primary'))
          .onClick(() => this.showTempMessage('当前版本暂未接入密码重置流程。'))
      }
      .width('100%')
      .margin({ top: 18 })

      Row() {
        Checkbox()
          .select(this.isPrivacyChecked)
          .selectedColor($r('app.color.primary'))
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
      .margin({ top: 16 })

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
        .backgroundColor('#FFECEF')
        .borderRadius(14)
        .margin({ top: 18 })
      }

      Button(this.isLoading ? '登录中...' : '登录')
        .width('100%')
        .height(54)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(20)
        .enabled(!this.isLoading)
        .opacity(this.isLoading ? 0.72 : 1)
        .margin({ top: 22 })
        .onClick(() => {
          this.handleLogin();
        })

      Row() {
        Divider()
          .color($r('app.color.divider'))
          .layoutWeight(1)

        Text('其他登录方式')
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
          .margin({ left: 12, right: 12 })

        Divider()
          .color($r('app.color.divider'))
          .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 26 })

      Row() {
        this.buildSecondaryAction($r('app.media.ic_qrcode'), '扫码登录', '#EAF2FF', '#3F7DFF', () => {
          this.showTempMessage('扫码登录将在后续版本接入。');
        })

        Blank().width(22)

        this.buildSecondaryAction($r('app.media.ic_message'), '短信验证', '#EAF9EF', '#34C759', () => {
          this.showTempMessage('短信验证码登录将在后续版本接入。');
        })
      }
      .margin({ top: 22 })

      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))

        Text('立即注册')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary'))
          .margin({ left: 6 })
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/RegisterPage' });
          })
      }
      .margin({ top: 24 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 24, bottom: 24 })
    .backgroundColor('#FFFFFF')
    .borderRadius(32)
    .border({
      width: 1,
      color: '#E4ECFA',
      radius: 32,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 24,
      color: '#2F6BDE12',
      offsetX: 0,
      offsetY: 12
    })
    .margin({ left: 20, right: 20 })
  }

  @Builder
  private buildPortalCard(title: string, value: string, subtitle: string) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.selectedPortal === value ? $r('app.color.primary') : $r('app.color.text_primary'))

      Text(subtitle)
        .fontSize(11)
        .fontColor(this.selectedPortal === value ? '#6D91D8' : $r('app.color.text_tertiary'))
        .margin({ top: 6 })
    }
    .layoutWeight(1)
    .height(72)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.selectedPortal === value ? '#EAF2FF' : '#F8FAFF')
    .borderRadius(20)
    .border({
      width: 1,
      color: this.selectedPortal === value ? '#CFE0FF' : '#E8EEF9',
      radius: 20,
      style: BorderStyle.Solid
    })
    .onClick(() => this.handlePortalChange(value))
  }

  @Builder
  private buildInputRow(icon: Resource, placeholder: string, value: string, isPassword: boolean) {
    Row() {
      Column() {
        Image(icon)
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
          .fillColor($r('app.color.primary'))
      }
      .width(36)
      .height(36)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F2F7FF')
      .borderRadius(14)

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
    .height(58)
    .padding({ left: 14, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .border({
      width: 1,
      color: '#E4ECFA',
      radius: 20,
      style: BorderStyle.Solid
    })
    .margin({ top: 16 })
  }

  @Builder
  private buildSecondaryAction(icon: Resource, label: string, bgColor: string, iconColor: string, onClick: () => void) {
    Column() {
      Column() {
        Image(icon)
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
          .fillColor(iconColor)
      }
      .width(58)
      .height(58)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(bgColor)
      .borderRadius(29)

      Text(label)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 10 })
    }
    .width(96)
    .onClick(() => onClick())
  }

  @Builder
  private buildEnvironmentPanel() {
    Column() {
      Row() {
        Column() {
          Text('联调设置')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text('本地后端与模拟演示可随时切换，方便你继续联调和验收。')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .lineHeight(19)
            .margin({ top: 6 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(this.currentEnv === ApiEnvironment.TEST_REAL ? 'LOCAL' : 'MOCK')
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary'))
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('#EAF2FF')
          .borderRadius(999)
      }
      .width('100%')

      Row() {
        this.buildEnvChip('模拟演示', ApiEnvironment.DEV_MOCK)
        this.buildEnvChip('本地后端', ApiEnvironment.TEST_REAL)
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
            .backgroundColor('#F8FAFF')
            .borderRadius(18)
            .height(52)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.apiBaseUrl = value;
            })

          Button('保存服务地址')
            .width('100%')
            .height(44)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary'))
            .backgroundColor('#EAF2FF')
            .borderRadius(16)
            .margin({ top: 12 })
            .onClick(() => {
              if (this.persistApiConfig()) {
                this.showTempMessage('本地联调配置已保存。');
              }
            })
        }
        .width('100%')
        .margin({ top: 16 })
      }

      Text('演示账号')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ top: 16 })

      this.buildDemoAccount('家长端', 'parent_zhang', '123456', 'PARENT')
      this.buildDemoAccount('教师端', 'teacher_wang', '123456', 'TEACHER')
      this.buildDemoAccount('管理端', 'admin_li', '123456', 'ADMIN')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(28)
    .border({
      width: 1,
      color: '#E4ECFA',
      radius: 28,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 18,
      color: '#2F6BDE10',
      offsetX: 0,
      offsetY: 8
    })
    .margin({ left: 20, right: 20, top: 16 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildDemoAccount(role: string, username: string, password: string, portal: string) {
    Row() {
      Column() {
        Text(role)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(username)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(password)
        .fontSize(12)
        .fontColor($r('app.color.primary'))
        .backgroundColor('#EAF2FF')
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .borderRadius(999)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor('#F8FAFF')
    .borderRadius(18)
    .margin({ top: 12 })
    .onClick(() => this.fillDemoAccount(portal))
  }

  @Builder
  private buildEnvChip(label: string, env: string) {
    Text(label)
      .fontSize(13)
      .fontWeight(this.currentEnv === env ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.currentEnv === env ? $r('app.color.primary') : $r('app.color.text_secondary'))
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(this.currentEnv === env ? '#EAF2FF' : '#F8FAFF')
      .borderRadius(16)
      .border({
        width: 1,
        color: this.currentEnv === env ? '#CFE0FF' : '#E8EEF9',
        radius: 16,
        style: BorderStyle.Solid
      })
      .margin({ right: 10 })
      .onClick(() => {
        this.handleEnvChange(env);
      })
  }
}
