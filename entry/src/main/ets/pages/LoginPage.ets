/**
 * SmartGuardian - Login Page
 * HarmonyOS-inspired unified login entrance for parent, teacher and organization.
 */

import { HarmonyColor, HarmonyRadius, harmonyShadowColor } from '../common/HarmonyDesign';
import { getRolePalette, RolePalette } from '../common/RoleTheme';
import { ApiConfig, ApiEnvironment } from '../config/api.config';
import { PrivacyDialog, isPrivacyAgreed } from '../components/PrivacyDialog';
import { UserRole } from '../models/common';
import { LoginRequest } from '../models/user';
import { AuthService } from '../services/api/auth';
import { UserStore } from '../stores/userStore';
import { CryptoUtil } from '../utils/CryptoUtil';
import { LogUtil } from '../utils/LogUtil';
import { setToken } from '../utils/request';

interface PortalOption {
  title: string;
  value: string;
  subtitle: string;
}

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
    this.syncMockDemoAccount(this.selectedPortal);

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

  private handlePortalChange(portal: string): void {
    this.selectedPortal = portal;
    this.syncMockDemoAccount(portal);
    this.errorMessage = '';
  }

  private getDemoUsername(portal: string): string {
    if (portal === 'TEACHER') {
      return 'teacher_wang';
    }
    if (portal === 'ADMIN') {
      return 'admin_li';
    }
    return 'parent_zhang';
  }

  private isDemoUsername(username: string): boolean {
    const value = username.trim();
    return value === '' ||
      value === 'parent_zhang' ||
      value === 'teacher_wang' ||
      value === 'admin_li';
  }

  private syncMockDemoAccount(portal: string): void {
    if (this.currentEnv !== ApiEnvironment.DEV_MOCK) {
      return;
    }
    if (this.isDemoUsername(this.username)) {
      this.username = this.getDemoUsername(portal);
    }
    if (this.password === '' || this.password === '123456') {
      this.password = '123456';
    }
  }

  private getSelectedPortalRole(): UserRole {
    if (this.selectedPortal === 'TEACHER') {
      return UserRole.TEACHER;
    }
    if (this.selectedPortal === 'ADMIN') {
      return UserRole.ORG_ADMIN;
    }
    return UserRole.PARENT;
  }

  private getPortalRole(portal: string): UserRole {
    if (portal === 'TEACHER') {
      return UserRole.TEACHER;
    }
    if (portal === 'ADMIN') {
      return UserRole.ORG_ADMIN;
    }
    return UserRole.PARENT;
  }

  private getSelectedPalette(): RolePalette {
    return getRolePalette(this.getSelectedPortalRole());
  }

  private getPortalPalette(portal: string): RolePalette {
    return getRolePalette(this.getPortalRole(portal));
  }

  private getPortalIcon(portal: string): Resource {
    if (portal === 'TEACHER') {
      return $r('app.media.ic_homework');
    }
    if (portal === 'ADMIN') {
      return $r('app.media.ic_service');
    }
    return $r('app.media.ic_child');
  }

  private getPortalIllustration(portal: string): Resource {
    if (portal === 'TEACHER') {
      return $r('app.media.sg_illustration_teaching');
    }
    if (portal === 'ADMIN') {
      return $r('app.media.sg_illustration_education');
    }
    return $r('app.media.sg_illustration_children');
  }

  async handleLogin(): Promise<void> {
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
      if (this.currentEnv === ApiEnvironment.DEV_MOCK) {
        request.roleType = this.getSelectedPortalRole();
      }

      LogUtil.info('LoginPage', `Attempting login for user: ${CryptoUtil.encryptSimple(this.username)}`);
      const resp = await AuthService.login(request);

      if (resp.code === 0 && resp.data) {
        setToken(resp.data.token);
        UserStore.setUserInfo(resp.data.userInfo);
        this.getUIContext().getRouter().replaceUrl({ url: 'pages/MainPage' });
      } else {
        this.errorMessage = resp.message || '登录失败，请检查账号密码或服务状态。';
      }
    } catch (error) {
      this.errorMessage = this.currentEnv === ApiEnvironment.TEST_REAL
        ? '本地后端请求失败，请检查 Spring Boot 服务和联调地址。'
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

  private getPortalLoginTitle(): string {
    if (this.selectedPortal === 'TEACHER') {
      return '教师端登录';
    }
    if (this.selectedPortal === 'ADMIN') {
      return '机构端登录';
    }
    return '家长端登录';
  }

  private getPortalHint(): string {
    if (this.selectedPortal === 'TEACHER') {
      return '管理学生考勤、作业反馈和家校沟通。';
    }
    if (this.selectedPortal === 'ADMIN') {
      return '统筹机构运营、订单审核和服务质量。';
    }
    return '关注孩子托管、签到动态和成长记录。';
  }

  private getAccountPlaceholder(): string {
    return this.selectedPortal === 'PARENT' ? '请输入手机号 / 家长账号' : '请输入账号';
  }

  build() {
    Scroll() {
      Column() {
        this.buildHeroSection()
        this.buildLoginCard()
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 18, bottom: 28 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(HarmonyColor.page)
  }

  @Builder
  private buildHeroSection() {
    Column() {
      Text('智慧学生托管系统')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor(HarmonyColor.textPrimary)
        .textAlign(TextAlign.Center)

      Text('基于 HarmonyOS + ArkTS 的三端统一工作台')
        .fontSize(14)
        .fontColor(HarmonyColor.textSecondary)
        .margin({ top: 8 })

      Row() {
        this.buildTrustChip('纯净蓝白', $r('app.media.ic_success'), '#EAF2FF', '#0A59F7')
        this.buildTrustChip('卡片共享', $r('app.media.ic_home'), '#F0EEFF', '#6D5DD3')
        this.buildTrustChip('多端适配', $r('app.media.ic_distributed'), '#EAF8F1', '#1A8C5F')
      }
      .justifyContent(FlexAlign.Center)
      .margin({ top: 16 })
    }
    .width('100%')
    .padding({ top: Number($r('app.float.status_bar_height')) + 10, bottom: 18 })
  }

  @Builder
  private buildTrustChip(label: string, icon: Resource, bgColor: string, iconColor: string) {
    Row() {
      Image(icon)
        .width(14)
        .height(14)
        .objectFit(ImageFit.Contain)
        .fillColor(iconColor)

      Text(label)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor(HarmonyColor.textSecondary)
        .margin({ left: 5 })
    }
    .padding({ left: 10, right: 10, top: 7, bottom: 7 })
    .backgroundColor(bgColor)
    .borderRadius(HarmonyRadius.pill)
    .margin({ right: 8 })
  }

  @Builder
  private buildLoginCard() {
    Column() {
      this.buildPortalVisual()
      this.buildPortalSwitcher()
      this.buildInputRow($r('app.media.ic_user'), this.getAccountPlaceholder(), this.username, false)
      this.buildInputRow($r('app.media.ic_lock'), '请输入密码', this.password, true)
      this.buildFormOptions()

      if (this.errorMessage) {
        this.buildErrorBanner()
      }

      Button(this.isLoading ? '登录中...' : '登录')
        .width('100%')
        .height(52)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor(this.isLoading ? '#A9C5FF' : this.getSelectedPalette().primary)
        .borderRadius(20)
        .margin({ top: 18 })
        .enabled(!this.isLoading)
        .onClick(() => this.handleLogin())

      this.buildHarmonyLogin()
      this.buildAgreementRow()
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 20, bottom: 22 })
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(32)
    .border({ width: 1, color: HarmonyColor.line, radius: 32, style: BorderStyle.Solid })
    .shadow({ radius: 24, color: harmonyShadowColor(), offsetX: 0, offsetY: 12 })
  }

  @Builder
  private buildPortalVisual() {
    Row() {
      Column() {
        Row() {
          Column() {
            Image(this.getPortalIcon(this.selectedPortal))
              .width(24)
              .height(24)
              .objectFit(ImageFit.Contain)
              .fillColor(Color.White)
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.getSelectedPalette().primary)
          .borderRadius(18)

          Column() {
            Text(this.getPortalLoginTitle())
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(HarmonyColor.textPrimary)
            Text(this.getPortalHint())
              .fontSize(13)
              .fontColor(HarmonyColor.textSecondary)
              .lineHeight(19)
              .margin({ top: 5 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 12 })
        }
        .width('100%')

        Text('账号登录')
          .fontSize(12)
          .fontColor(this.getSelectedPalette().primary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.getSelectedPalette().light)
          .borderRadius(HarmonyRadius.pill)
          .margin({ top: 16 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Image(this.getPortalIllustration(this.selectedPortal))
        .width(118)
        .height(96)
        .objectFit(ImageFit.Contain)
        .opacity(0.92)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .linearGradient({
      angle: 135,
      colors: [['#FFFFFF', 0], [this.getSelectedPalette().light, 1]]
    })
    .borderRadius(26)
    .border({ width: 1, color: this.getSelectedPalette().border, radius: 26, style: BorderStyle.Solid })
  }

  @Builder
  private buildPortalSwitcher() {
    Row() {
      ForEach(this.getPortals(), (portal: PortalOption) => {
        this.buildPortalCard(portal)
      })
    }
    .width('100%')
    .padding(4)
    .backgroundColor('#F2F5FA')
    .borderRadius(22)
    .margin({ top: 18, bottom: 2 })
  }

  @Builder
  private buildPortalCard(portal: PortalOption) {
    Column() {
      Text(portal.title)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedPortal === portal.value ? this.getPortalPalette(portal.value).primary : HarmonyColor.textSecondary)

      Text(portal.subtitle)
        .fontSize(11)
        .fontColor(this.selectedPortal === portal.value ? this.getPortalPalette(portal.value).primaryDark : HarmonyColor.textTertiary)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .height(56)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.selectedPortal === portal.value ? '#FFFFFF' : Color.Transparent)
    .borderRadius(18)
    .shadow({
      radius: this.selectedPortal === portal.value ? 10 : 0,
      color: this.selectedPortal === portal.value ? harmonyShadowColor() : Color.Transparent,
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => this.handlePortalChange(portal.value))
  }

  @Builder
  private buildInputRow(icon: Resource, placeholder: string, value: string, isPassword: boolean) {
    Row() {
      Image(icon)
        .width(20)
        .height(20)
        .objectFit(ImageFit.Contain)
        .fillColor(this.getSelectedPalette().primary)

      TextInput({ placeholder, text: value })
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
          .fillColor(HarmonyColor.textTertiary)
          .onClick(() => {
            this.showPassword = !this.showPassword;
          })
      }
    }
    .width('100%')
    .height(58)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#F8FAFD')
    .borderRadius(20)
    .border({ width: 1, color: HarmonyColor.line, radius: 20, style: BorderStyle.Solid })
    .margin({ top: 14 })
  }

  @Builder
  private buildFormOptions() {
    Row() {
      Row() {
        Checkbox()
          .select(this.rememberPassword)
          .selectedColor(this.getSelectedPalette().primary)
          .width(18)
          .height(18)
          .onChange((isChecked: boolean) => {
            this.rememberPassword = isChecked;
          })

        Text('记住密码')
          .fontSize(12)
          .fontColor(HarmonyColor.textSecondary)
          .margin({ left: 8 })
      }

      Blank()

      Text('忘记密码？')
        .fontSize(13)
        .fontColor(this.getSelectedPalette().primary)
        .onClick(() => this.showTempMessage('当前版本暂未接入密码重置流程。'))
    }
    .width('100%')
    .margin({ top: 16 })
  }

  @Builder
  private buildErrorBanner() {
    Row() {
      Image($r('app.media.ic_warning'))
        .width(18)
        .height(18)
        .objectFit(ImageFit.Contain)
        .fillColor(HarmonyColor.danger)
      Text(this.errorMessage)
        .fontSize(13)
        .fontColor(HarmonyColor.danger)
        .lineHeight(18)
        .layoutWeight(1)
        .margin({ left: 8 })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('#FFF1F0')
    .borderRadius(16)
    .margin({ top: 14 })
  }

  @Builder
  private buildHarmonyLogin() {
    Row() {
      Divider()
        .layoutWeight(1)
        .color(HarmonyColor.line)
      Text('其他登录方式')
        .fontSize(12)
        .fontColor(HarmonyColor.textTertiary)
        .margin({ left: 12, right: 12 })
      Divider()
        .layoutWeight(1)
        .color(HarmonyColor.line)
    }
    .width('100%')
    .margin({ top: 22 })

    Row() {
      Image($r('app.media.ic_user'))
        .width(20)
        .height(20)
        .objectFit(ImageFit.Contain)
        .fillColor('#C7000B')
      Text('华为账号登录')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(HarmonyColor.textPrimary)
        .margin({ left: 8 })
    }
    .height(46)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F8FAFD')
    .borderRadius(18)
    .border({ width: 1, color: HarmonyColor.line, radius: 18, style: BorderStyle.Solid })
    .margin({ top: 14 })
    .onClick(() => this.showTempMessage('华为账号登录将在后续版本接入。'))
  }

  @Builder
  private buildAgreementRow() {
    Row() {
      Checkbox()
        .select(this.isPrivacyChecked)
        .selectedColor(this.getSelectedPalette().primary)
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
        .fontColor(HarmonyColor.textSecondary)
        .margin({ left: 8 })

      Text('《隐私政策》')
        .fontSize(12)
        .fontColor(this.getSelectedPalette().primary)
        .onClick(() => this.privacyDialogController.open())
    }
    .width('100%')
    .margin({ top: 18 })
  }

  private getPortals(): PortalOption[] {
    return [
      { title: '家长', value: 'PARENT', subtitle: '预约与动态' },
      { title: '教师', value: 'TEACHER', subtitle: '考勤与作业' },
      { title: '机构', value: 'ADMIN', subtitle: '服务与审核' }
    ];
  }
}
