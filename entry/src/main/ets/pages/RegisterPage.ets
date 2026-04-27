import {
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
        this.errorMessage = '请先阅读并同意隐私政策。';
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
      this.errorMessage = '请先输入手机号。';
      return;
    }
    this.showTempMessage('验证码发送暂未接入，请联系管理员开通账号。');
  }

  private handleRegister(): void {
    if (!this.mobile.trim() || !this.verifyCode.trim() || !this.realName.trim() || !this.password.trim() || !this.confirmPassword.trim()) {
      this.errorMessage = '请完整填写注册信息。';
      return;
    }

    if (!/^\d{11}$/.test(this.mobile.trim())) {
      this.errorMessage = '请输入有效的 11 位手机号。';
      return;
    }

    if (this.password.length < 6) {
      this.errorMessage = '密码长度不能少于 6 位。';
      return;
    }

    if (this.password !== this.confirmPassword) {
      this.errorMessage = '两次输入的密码不一致。';
      return;
    }

    if (!this.isPrivacyChecked && !isPrivacyAgreed()) {
      this.privacyDialogController.open();
      return;
    }

    this.showTempMessage('当前版本暂未开放自助注册，请联系管理员开通账号。');
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Image($r('app.media.sg_illustration_auth_hall'))
            .width('100%')
            .height(150)
            .objectFit(ImageFit.Cover)
            .borderRadius(20)

          Text('创建账号')
            .width('100%')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 18 })

          Text('请选择入口并完善注册资料。')
            .width('100%')
            .fontSize(14)
            .lineHeight(22)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 8, bottom: 18 })

          this.buildFormContent()
        }
        .width('100%')
        .constraintSize({ maxWidth: 640 })
        .padding(24)
        .backgroundColor($r('app.color.card_background'))
        .borderRadius(24)
        .border({
          width: 1,
          color: $r('app.color.divider'),
          radius: 24,
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
      FormSegmentSelector({
        options: ['PARENT', 'TEACHER', 'ADMIN'],
        labels: ['家长', '教师', '机构'],
        selectedValue: this.selectedPortal,
        onSelect: (value: string) => {
          this.selectedPortal = value;
        }
      })

      FormTextField({
        icon: $r('app.media.ic_user'),
        label: '手机号',
        placeholder: '请输入 11 位手机号',
        text: this.mobile,
        onChange: (value: string) => {
          this.mobile = value;
        }
      })
        .margin({ top: 14 })

      FormTextField({
        icon: $r('app.media.ic_message'),
        label: '验证码',
        placeholder: '请输入验证码',
        text: this.verifyCode,
        onChange: (value: string) => {
          this.verifyCode = value;
        }
      })
        .margin({ top: 14 })

      Button('获取验证码')
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
        label: '真实姓名',
        placeholder: '请输入真实姓名',
        text: this.realName,
        onChange: (value: string) => {
          this.realName = value;
        }
      })
        .margin({ top: 14 })

      FormSecureField({
        icon: $r('app.media.ic_lock'),
        label: '密码',
        placeholder: '请设置登录密码',
        text: this.password,
        onChange: (value: string) => {
          this.password = value;
        }
      })
        .margin({ top: 14 })

      FormSecureField({
        icon: $r('app.media.ic_lock'),
        label: '确认密码',
        placeholder: '请再次输入密码',
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

        Text('我已阅读并同意隐私政策')
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
        primaryText: '注册',
        secondaryText: '返回登录',
        helperText: '当前版本仍由管理员辅助开通账号。',
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
