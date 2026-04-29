import { common } from '@kit.AbilityKit';
import {
  FormActionBar,
  FormSecureField,
  FormTextField,
  PortalOption,
  PortalSelectorCard
} from '../components/common';
import { PrivacyDialog, isPrivacyAgreed } from '../components/PrivacyDialog';
import { ApiConfig, ApiEnvironment } from '../config/api.config';
import { RouteUrls } from '../constants/app.constants';
import { LoginRequest } from '../models/user';
import { AuthService } from '../services/api/auth';
import { AgcRuntimeService } from '../services/agc/AgcRuntimeService';
import { NotificationEndpointRegistrationService } from '../services/NotificationEndpointRegistrationService';
import { NotificationLaunchService } from '../services/NotificationLaunchService';
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
  @State isPrivacyChecked: boolean = false;
  @State selectedPortal: string = 'PARENT';

  private readonly portalOptions: PortalOption[] = [
    { value: 'PARENT', label: '家长', description: '查看孩子签到、作业反馈和成长记录。' },
    { value: 'TEACHER', label: '教师', description: '管理考勤、作业和家校沟通。' },
    { value: 'ADMIN', label: '机构', description: '管理服务、订单、报表和机构数据。' }
  ];

  private privacyDialogController: CustomDialogController = new CustomDialogController({
    builder: PrivacyDialog({
      onAgree: () => {
        this.isPrivacyChecked = true;
        this.errorMessage = '';
      },
      onDisagree: () => {
        this.isPrivacyChecked = false;
        this.errorMessage = '请先阅读并同意隐私政策后再登录。';
      }
    }),
    autoCancel: false,
    customStyle: true,
    alignment: DialogAlignment.Center
  });

  aboutToAppear(): void {
    ApiConfig.applyRuntimeConfig(ApiEnvironment.AGC_SERVERLESS, ApiConfig.getConfiguredBaseUrl());
    this.isPrivacyChecked = isPrivacyAgreed();
  }

  private requestPrivacyAgreement(): void {
    this.privacyDialogController.open();
  }

  private handlePortalChange(portal: string): void {
    this.selectedPortal = portal;
    this.errorMessage = '';
  }

  private async ensureServiceReady(): Promise<boolean> {
    if (!AgcRuntimeService.isClientConfigReady()) {
      await this.refreshAgcRuntimeStatus();
      if (!AgcRuntimeService.isClientConfigReady()) {
        const runtimeError = AgcRuntimeService.getRuntimeError();
        LogUtil.warn('LoginPage', `AGC client config is not ready, stop AGC function login. ${runtimeError}`);
        this.errorMessage = 'AGC 初始化失败，请在真机/模拟器运行并检查 agconnect-services.json 与 AGC 云函数配置。';
        return false;
      }
    }
    return true;
  }

  private async refreshAgcRuntimeStatus(): Promise<void> {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await AgcRuntimeService.initialize(context);
    } catch (error) {
      LogUtil.warn('LoginPage', `Refresh AGC runtime status failed: ${String(error)}`);
    }
  }

  async handleLogin(): Promise<void> {
    if (!this.username.trim() || !this.password.trim()) {
      this.errorMessage = '请输入账号和密码。';
      return;
    }

    if (!this.isPrivacyChecked && !isPrivacyAgreed()) {
      this.requestPrivacyAgreement();
      return;
    }

    ApiConfig.applyRuntimeConfig(ApiEnvironment.AGC_SERVERLESS, ApiConfig.getConfiguredBaseUrl());
    if (!(await this.ensureServiceReady())) {
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
        await NotificationEndpointRegistrationService.syncCurrentSession();
        const pendingLaunch = NotificationLaunchService.consumePendingLaunch();
        if (pendingLaunch) {
          this.getUIContext().getRouter().replaceUrl({
            url: pendingLaunch.route,
            params: NotificationLaunchService.parseParams(pendingLaunch.paramsJson)
          });
        } else {
          this.getUIContext().getRouter().replaceUrl({ url: RouteUrls.MAIN });
        }
        return;
      }

      this.errorMessage = resp.message || '登录失败，请检查账号或云服务状态。';
    } catch (error) {
      this.errorMessage = '登录失败，请稍后再试。';
      LogUtil.error('LoginPage', `Login error: ${String(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  private getPortalHint(): string {
    if (this.selectedPortal === 'TEACHER') {
      return '管理考勤、作业和家校沟通。';
    }
    if (this.selectedPortal === 'ADMIN') {
      return '管理服务产品、订单、报表和运营数据。';
    }
    return '查看孩子状态、签到信息和成长记录。';
  }

  private getAccountPlaceholder(): string {
    return this.selectedPortal === 'PARENT' ? '手机号 / 家长账号' : '账号';
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Image($r('app.media.sg_illustration_auth_hall_v2'))
            .width('100%')
            .height(166)
            .objectFit(ImageFit.Cover)
            .borderRadius(24)

          Text('智慧托管')
            .width('100%')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 18 })

          Text('面向家长、教师和托管机构的统一登录入口。')
            .width('100%')
            .fontSize(14)
            .lineHeight(22)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 8, bottom: 18 })

          this.buildFormContent()
        }
        .width('100%')
        .constraintSize({ maxWidth: 620 })
        .padding(24)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(28)
        .border({
          width: 1,
          color: $r('app.color.divider'),
          radius: 28,
          style: BorderStyle.Solid
        })
        .alignSelf(ItemAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 24, bottom: 24 })
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildFormContent() {
    Column() {
      PortalSelectorCard({
        options: this.portalOptions,
        selectedValue: this.selectedPortal,
        hintText: this.getPortalHint(),
        onSelect: (portal: string) => {
          this.handlePortalChange(portal);
        }
      })

      FormTextField({
        icon: $r('app.media.ic_user'),
        label: '账号',
        placeholder: this.getAccountPlaceholder(),
        text: this.username,
        onChange: (value: string) => {
          this.username = value;
        }
      })
        .margin({ top: 14 })

      FormSecureField({
        icon: $r('app.media.ic_lock'),
        label: '密码',
        placeholder: '请输入密码',
        text: this.password,
        onChange: (value: string) => {
          this.password = value;
        }
      })
        .margin({ top: 14 })

      Row() {
        Checkbox()
          .select(this.isPrivacyChecked)
          .selectedColor($r('app.color.primary'))
          .width(18)
          .height(18)
          .onChange((checked: boolean) => {
            if (!checked) {
              this.isPrivacyChecked = false;
              return;
            }

            if (isPrivacyAgreed()) {
              this.isPrivacyChecked = true;
              return;
            }

            this.isPrivacyChecked = false;
            this.requestPrivacyAgreement();
          })

        Text('我已阅读并同意隐私政策')
          .layoutWeight(1)
          .fontSize(12)
          .lineHeight(18)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 8 })
          .onClick(() => {
            this.requestPrivacyAgreement();
          })
      }
      .width('100%')
      .margin({ top: 18 })

      FormActionBar({
        primaryText: '登录',
        helperText: '登录后将进入对应工作台',
        errorText: this.errorMessage,
        primaryEnabled: !this.isLoading,
        loading: this.isLoading,
        onPrimary: () => {
          this.handleLogin();
        }
      })
        .margin({ top: 18 })
    }
    .width('100%')
  }
}
