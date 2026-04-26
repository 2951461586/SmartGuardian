import {
  FormPageTemplate,
  FormActionBar,
  FormSecureField,
  FormSegmentSelector,
  FormTextField,
} from '../components/common';
import { PrivacyDialog, isPrivacyAgreed } from '../components/PrivacyDialog';
import { getRolePalette, RolePalette } from '../common/RoleTheme';
import { RouteUrls, StorageKeys } from '../constants/app.constants';
import { UserRole } from '../models/common';

@Entry
@Component
struct RegisterPage {
  @State mobile: string = '';
  @State verifyCode: string = '';
  @State realName: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State selectedPortal: string = 'PARENT';
  @State isPrivacyChecked: boolean = false;
  @State errorMessage: string = '';

  private privacyDialogController: CustomDialogController = new CustomDialogController({
    builder: PrivacyDialog({
      onAgree: () => {
        this.isPrivacyChecked = true;
      },
      onDisagree: () => {
        this.isPrivacyChecked = false;
        this.errorMessage = 'Please agree to the privacy policy before continuing.';
      }
    }),
    autoCancel: false,
    customStyle: true,
    alignment: DialogAlignment.Center
  });

  aboutToAppear() {
    this.isPrivacyChecked = isPrivacyAgreed();
  }

  private goBack(): void {
    try {
      this.getUIContext().getRouter().back();
    } catch (error) {
      try {
        this.getUIContext().getRouter().replaceUrl({ url: RouteUrls.LOGIN });
      } catch (innerError) {
        console.error('RegisterPage goBack failed:', JSON.stringify(innerError));
      }
    }
  }

  private showTempMessage(message: string): void {
    this.errorMessage = message;
    setTimeout(() => {
      this.errorMessage = '';
    }, 2200);
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
    return getRolePalette(this.getPortalRole(this.selectedPortal));
  }

  private requestVerifyCode(): void {
    if (!this.mobile.trim()) {
      this.errorMessage = 'Please enter a mobile number first.';
      return;
    }
    this.showTempMessage('Verification code delivery is not connected yet. Please ask the administrator to activate the account.');
  }

  private handleRegister(): void {
    if (!this.mobile.trim() || !this.verifyCode.trim() || !this.realName.trim() || !this.password.trim() || !this.confirmPassword.trim()) {
      this.errorMessage = 'Please complete the registration form.';
      return;
    }

    if (!/^\d{11}$/.test(this.mobile.trim())) {
      this.errorMessage = 'Please enter a valid 11-digit mobile number.';
      return;
    }

    if (this.password.length < 6) {
      this.errorMessage = 'Password must be at least 6 characters.';
      return;
    }

    if (this.password !== this.confirmPassword) {
      this.errorMessage = 'The passwords do not match.';
      return;
    }

    if (!this.isPrivacyChecked && !isPrivacyAgreed()) {
      this.privacyDialogController.open();
      return;
    }

    this.showTempMessage('Self-service registration is not connected in the current version. Please contact the administrator.');
  }

  build() {
    Column() {
      FormPageTemplate({
        title: 'Create Account',
        subtitle: 'Complete the registration profile for the portal you need to use.',
        illustration: $r('app.media.sg_illustration_auth_hall'),
        maxWidth: 640,
        content: this.buildFormContent
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildFormContent() {
    Column() {
      FormSegmentSelector({
        options: ['PARENT', 'TEACHER', 'ADMIN'],
        labels: ['Parent', 'Teacher', 'Admin'],
        selectedValue: this.selectedPortal,
        onSelect: (value: string) => {
          this.selectedPortal = value;
        }
      })

      FormTextField({
        icon: $r('app.media.ic_user'),
        label: 'Mobile',
        placeholder: '11-digit mobile number',
        text: this.mobile,
        onChange: (value: string) => {
          this.mobile = value;
        }
      })
        .margin({ top: 14 })

      FormTextField({
        icon: $r('app.media.ic_message'),
        label: 'Verification Code',
        placeholder: 'Enter verification code',
        text: this.verifyCode,
        onChange: (value: string) => {
          this.verifyCode = value;
        }
      })
        .margin({ top: 14 })

      Button('Get Code')
        .width('100%')
        .height(44)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getSelectedPalette().primary)
        .backgroundColor(this.getSelectedPalette().light)
        .borderRadius(16)
        .margin({ top: 10 })
        .onClick(() => {
          this.requestVerifyCode();
        })

      FormTextField({
        icon: $r('app.media.ic_user'),
        label: 'Real Name',
        placeholder: 'Enter your real name',
        text: this.realName,
        onChange: (value: string) => {
          this.realName = value;
        }
      })
        .margin({ top: 14 })

      FormSecureField({
        icon: $r('app.media.ic_lock'),
        label: 'Password',
        placeholder: 'Set a login password',
        text: this.password,
        onChange: (value: string) => {
          this.password = value;
        }
      })
        .margin({ top: 14 })

      FormSecureField({
        icon: $r('app.media.ic_lock'),
        label: 'Confirm Password',
        placeholder: 'Enter the password again',
        text: this.confirmPassword,
        onChange: (value: string) => {
          this.confirmPassword = value;
        }
      })
        .margin({ top: 14 })

      Row() {
        Checkbox()
          .select(this.isPrivacyChecked)
          .selectedColor(this.getSelectedPalette().primary)
          .width(18)
          .height(18)
          .onChange((checked: boolean) => {
            this.isPrivacyChecked = checked;
            if (checked) {
              AppStorage.setOrCreate(StorageKeys.PRIVACY_AGREED, true);
            }
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
        primaryText: 'Register',
        secondaryText: 'Back to Login',
        helperText: 'The current build still uses administrator-assisted account activation.',
        errorText: this.errorMessage,
        onPrimary: () => {
          this.handleRegister();
        },
        onSecondary: () => {
          this.goBack();
        }
      })
        .margin({ top: 18 })
    }
    .width('100%')
  }
}
