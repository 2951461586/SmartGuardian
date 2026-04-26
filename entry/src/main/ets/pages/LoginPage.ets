import {
  EnvironmentSelectorCard,
  FormPageTemplate,
  FormActionBar,
  FormSecureField,
  FormTextField,
  PortalOption,
  PortalSelectorCard
} from '../components/common';
import { PrivacyDialog, isPrivacyAgreed } from '../components/PrivacyDialog';
import { ApiConfig, ApiEnvironment } from '../config/api.config';
import { RouteUrls } from '../constants/app.constants';
import { UserRole } from '../models/common';
import { LoginRequest } from '../models/user';
import { AuthService } from '../services/api/auth';
import { AgcRuntimeService } from '../services/agc/AgcRuntimeService';
import { NotificationLaunchService } from '../services/NotificationLaunchService';
import { NotificationEndpointRegistrationService } from '../services/NotificationEndpointRegistrationService';
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
  @State currentEnv: string = ApiConfig.getCurrentEnv();
  @State apiBaseUrl: string = ApiConfig.getConfiguredBaseUrl();
  @State selectedPortal: string = 'PARENT';

  private readonly portalOptions: PortalOption[] = [
    { value: 'PARENT', label: 'Parent', description: 'Track your child, check attendance, and follow growth records.' },
    { value: 'TEACHER', label: 'Teacher', description: 'Manage attendance, homework, and classroom communication.' },
    { value: 'ADMIN', label: 'Admin', description: 'Operate services, orders, reports, and organization data.' }
  ];

  private privacyDialogController: CustomDialogController = new CustomDialogController({
    builder: PrivacyDialog({
      onAgree: () => {
        this.isPrivacyChecked = true;
        this.errorMessage = '';
      },
      onDisagree: () => {
        this.isPrivacyChecked = false;
        this.errorMessage = 'Please accept the privacy policy before login.';
      }
    }),
    autoCancel: false,
    customStyle: true,
    alignment: DialogAlignment.Center
  });

  aboutToAppear(): void {
    this.isPrivacyChecked = isPrivacyAgreed();
    this.currentEnv = ApiConfig.getCurrentEnv();
    this.apiBaseUrl = ApiConfig.getConfiguredBaseUrl();
    this.syncMockDemoAccount(this.selectedPortal);

    if (!this.isPrivacyChecked) {
      this.privacyDialogController.open();
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

  private getDemoUsername(portal: string): string {
    if (portal === 'TEACHER') {
      return 'teacher_wang';
    }
    if (portal === 'ADMIN') {
      return 'admin_li';
    }
    return 'parent_zhang';
  }

  private isDemoUsername(value: string): boolean {
    const trimmed = value.trim();
    return trimmed === '' || trimmed === 'parent_zhang' || trimmed === 'teacher_wang' || trimmed === 'admin_li';
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

  private handlePortalChange(portal: string): void {
    this.selectedPortal = portal;
    this.errorMessage = '';
    this.syncMockDemoAccount(portal);
  }

  private handleEnvChange(env: string): void {
    this.currentEnv = env;
    this.errorMessage = '';

    if (env === ApiEnvironment.DEV_MOCK) {
      this.apiBaseUrl = '';
      this.syncMockDemoAccount(this.selectedPortal);
      return;
    }

    this.apiBaseUrl = ApiConfig.getConfiguredBaseUrl();
  }

  private persistApiConfig(): boolean {
    if (this.currentEnv === ApiEnvironment.DEV_MOCK) {
      ApiConfig.applyRuntimeConfig(ApiEnvironment.DEV_MOCK);
      return true;
    }

    if (this.currentEnv === ApiEnvironment.AGC_SERVERLESS && !AgcRuntimeService.isClientConfigReady()) {
      const runtimeError = AgcRuntimeService.getRuntimeError();
      this.errorMessage = runtimeError.length > 0
        ? runtimeError
        : 'AGC client config is not ready. Replace rawfile/agconnect-services.json with the real AppGallery Connect file first.';
      return false;
    }

    const normalizedUrl: string = this.apiBaseUrl.trim();
    if (!normalizedUrl) {
      this.errorMessage = 'Enter AGC gateway URL before login.';
      return false;
    }

    ApiConfig.applyRuntimeConfig(this.currentEnv, normalizedUrl);
    return true;
  }

  async handleLogin(): Promise<void> {
    if (!this.username.trim() || !this.password.trim()) {
      this.errorMessage = 'Please enter username and password.';
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

      this.errorMessage = resp.message || 'Login failed. Please check your account or service status.';
    } catch (error) {
      if (this.currentEnv === ApiEnvironment.AGC_SERVERLESS) {
        this.errorMessage = 'AGC request failed. Check gateway URL and deployment.';
      } else {
        this.errorMessage = 'Network request failed. Please try again later.';
      }
      LogUtil.error('LoginPage', `Login error: ${String(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  private getPortalHint(): string {
    if (this.selectedPortal === 'TEACHER') {
      return 'Manage attendance, homework, and parent communication.';
    }
    if (this.selectedPortal === 'ADMIN') {
      return 'Manage service products, orders, reports, and operations.';
    }
    return 'Track your child, check-in status, and growth records.';
  }

  private getAccountPlaceholder(): string {
    return this.selectedPortal === 'PARENT' ? 'Phone number / parent account' : 'Account';
  }

  private getEnvironmentHelperText(): string {
    if (this.currentEnv === ApiEnvironment.DEV_MOCK) {
      return 'Mock mode uses built-in demo data and does not require a backend URL.';
    }
    if (this.currentEnv === ApiEnvironment.AGC_SERVERLESS) {
      if (!AgcRuntimeService.isClientConfigReady()) {
        return 'AGC mode is blocked until rawfile/agconnect-services.json is replaced with a real AppGallery Connect client config.';
      }
      return 'Use the AGC gateway URL that fronts the current cloud function deployment.';
    }
    return 'AGC Serverless is the only real backend path for this app.';
  }

  private getEnvironmentPlaceholder(): string {
    return 'AGC gateway URL';
  }

  build() {
    Column() {
      FormPageTemplate({
        title: 'SmartGuardian',
        subtitle: 'Unified HarmonyOS ArkTS login entry for parents, teachers, and administrators.',
        illustration: $r('app.media.sg_illustration_auth_hall'),
        maxWidth: 620,
        content: this.buildFormContent
      })
    }
    .width('100%')
    .height('100%')
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
        label: 'Account',
        placeholder: this.getAccountPlaceholder(),
        text: this.username,
        onChange: (value: string) => {
          this.username = value;
        }
      })
        .margin({ top: 14 })

      FormSecureField({
        icon: $r('app.media.ic_lock'),
        label: 'Password',
        placeholder: 'Password',
        text: this.password,
        onChange: (value: string) => {
          this.password = value;
        }
      })
        .margin({ top: 14 })

      EnvironmentSelectorCard({
        currentEnv: this.currentEnv,
        mockEnvValue: ApiEnvironment.DEV_MOCK,
        agcEnvValue: ApiEnvironment.AGC_SERVERLESS,
        apiBaseUrl: this.apiBaseUrl,
        showUrlInput: this.currentEnv !== ApiEnvironment.DEV_MOCK,
        urlPlaceholder: this.getEnvironmentPlaceholder(),
        helperText: this.getEnvironmentHelperText(),
        onEnvChange: (env: string) => {
          this.handleEnvChange(env);
        },
        onUrlChange: (value: string) => {
          this.apiBaseUrl = value;
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
            this.isPrivacyChecked = checked;
          })

        Text('I have read and agree to the privacy policy')
          .layoutWeight(1)
          .fontSize(12)
          .lineHeight(18)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 8 })
          .onClick(() => {
            this.privacyDialogController.open();
          })
      }
      .width('100%')
      .margin({ top: 18 })

      FormActionBar({
        primaryText: 'Login',
        helperText: `Current environment: ${ApiConfig.getEnvironmentLabel()}`,
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
