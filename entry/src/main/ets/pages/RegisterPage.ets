/**
 * SmartGuardian - Register Page
 * Styled registration shell aligned with the new login experience
 */

import { PrivacyDialog, isPrivacyAgreed } from '../components/PrivacyDialog';

@Entry
@Component
struct RegisterPage {
  @State mobile: string = '';
  @State verifyCode: string = '';
  @State realName: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State selectedPortal: string = 'PARENT';
  @State showPassword: boolean = false;
  @State showConfirmPassword: boolean = false;
  @State isPrivacyChecked: boolean = false;
  @State errorMessage: string = '';

  private privacyDialogController: CustomDialogController = new CustomDialogController({
    builder: PrivacyDialog({
      onAgree: () => {
        this.isPrivacyChecked = true;
      },
      onDisagree: () => {
        this.isPrivacyChecked = false;
        this.errorMessage = '请先同意隐私政策后再继续注册。';
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
        this.getUIContext().getRouter().replaceUrl({ url: 'pages/LoginPage' });
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

  private requestVerifyCode(): void {
    if (!this.mobile.trim()) {
      this.errorMessage = '请先输入手机号。';
      return;
    }
    this.showTempMessage('验证码发送能力暂未接入，本地演示请联系管理员开通账号。');
  }

  private handleRegister(): void {
    if (!this.mobile.trim() || !this.verifyCode.trim() || !this.realName.trim() || !this.password.trim() || !this.confirmPassword.trim()) {
      this.errorMessage = '请完整填写注册信息。';
      return;
    }

    if (!/^\d{11}$/.test(this.mobile.trim())) {
      this.errorMessage = '请输入正确的 11 位手机号。';
      return;
    }

    if (this.password.length < 6) {
      this.errorMessage = '密码长度至少为 6 位。';
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

    this.showTempMessage('当前版本暂未接入自助注册接口，请联系管理员开通账号。');
  }

  build() {
    Scroll() {
      Column() {
        this.buildHeroSection()
        this.buildRegisterCard()
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
          Column() {
            Image($r('app.media.ic_arrow_left'))
              .width(20)
              .height(20)
              .fillColor($r('app.color.text_primary'))
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .border({
            width: 1,
            color: '#E4ECFA',
            radius: 16,
            style: BorderStyle.Solid
          })
          .onClick(() => this.goBack())

          Text('用户注册')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 26 })

          Text('创建账号，开启智慧托管之旅')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 10 })

          Row() {
            Image($r('app.media.ic_success'))
              .width(16)
              .height(16)
              .fillColor($r('app.color.primary'))

            Text('信息安全保护中，请放心注册')
              .fontSize(13)
              .fontColor('#6D91D8')
              .margin({ left: 8 })
          }
          .margin({ top: 18 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Image($r('app.media.startIcon'))
          .width(110)
          .height(110)
          .objectFit(ImageFit.Contain)
          .opacity(0.24)
          .margin({ left: 12, top: 34 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding({ left: 22, right: 22, top: 72, bottom: 20 })
  }

  @Builder
  private buildRegisterCard() {
    Column() {
      this.buildInputRow($r('app.media.ic_user'), '请输入手机号', this.mobile, false, false)
      this.buildCodeRow()

      Row() {
        this.buildPortalCard('家长', 'PARENT')
        Blank().width(10)
        this.buildPortalCard('教师', 'TEACHER')
        Blank().width(10)
        this.buildPortalCard('管理', 'ADMIN')
      }
      .width('100%')
      .margin({ top: 16 })

      this.buildInputRow($r('app.media.ic_user'), '请输入真实姓名', this.realName, false, false)
      this.buildInputRow($r('app.media.ic_lock'), '请设置登录密码', this.password, true, false)
      this.buildInputRow($r('app.media.ic_lock'), '请确认登录密码', this.confirmPassword, true, true)

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
          .margin({ left: 4 })
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
        .backgroundColor('#FFECEF')
        .borderRadius(14)
        .margin({ top: 18 })
      }

      Button('注册')
        .width('100%')
        .height(54)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(20)
        .margin({ top: 22 })
        .onClick(() => this.handleRegister())

      Row() {
        Text('已有账号？')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))

        Text('立即登录')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary'))
          .margin({ left: 6 })
          .onClick(() => this.goBack())
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
  private buildCodeRow() {
    Row() {
      Column() {
        Image($r('app.media.ic_message'))
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
        placeholder: '请输入验证码',
        text: this.verifyCode
      })
        .fontSize(16)
        .backgroundColor(Color.Transparent)
        .flexGrow(1)
        .margin({ left: 12 })
        .onChange((value: string) => {
          this.verifyCode = value;
        })

      Text('获取验证码')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary'))
        .onClick(() => this.requestVerifyCode())
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
  private buildPortalCard(title: string, value: string) {
    Text(title)
      .fontSize(14)
      .fontWeight(this.selectedPortal === value ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.selectedPortal === value ? $r('app.color.primary') : $r('app.color.text_secondary'))
      .layoutWeight(1)
      .height(52)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.selectedPortal === value ? '#EAF2FF' : '#F8FAFF')
      .borderRadius(16)
      .border({
        width: 1,
        color: this.selectedPortal === value ? '#CFE0FF' : '#E8EEF9',
        radius: 16,
        style: BorderStyle.Solid
      })
      .onClick(() => {
        this.selectedPortal = value;
      })
  }

  @Builder
  private buildInputRow(icon: Resource, placeholder: string, value: string, isPassword: boolean, isConfirm: boolean) {
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
        .type(isPassword && !(isConfirm ? this.showConfirmPassword : this.showPassword) ? InputType.Password : InputType.Normal)
        .onChange((inputValue: string) => {
          if (!isPassword) {
            if (placeholder.indexOf('手机') > -1) {
              this.mobile = inputValue;
            } else {
              this.realName = inputValue;
            }
            return;
          }

          if (isConfirm) {
            this.confirmPassword = inputValue;
          } else {
            this.password = inputValue;
          }
        })

      if (isPassword) {
        Image((isConfirm ? this.showConfirmPassword : this.showPassword) ? $r('app.media.ic_eye_open') : $r('app.media.ic_eye_close'))
          .width(20)
          .height(20)
          .objectFit(ImageFit.Contain)
          .fillColor($r('app.color.text_tertiary'))
          .onClick(() => {
            if (isConfirm) {
              this.showConfirmPassword = !this.showConfirmPassword;
            } else {
              this.showPassword = !this.showPassword;
            }
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
}
