/**
 * SmartGuardian - Privacy Agreement Dialog Component
 * Display privacy agreement on first app launch
 */

import { StorageKeys } from '../constants/app.constants';

/**
 * Privacy dialog component
 */
@CustomDialog
export struct PrivacyDialog {
  controller: CustomDialogController;
  onAgree: () => void = () => {};
  onDisagree: () => void = () => {};
  
  @State scrollHeight: number = 300;

  /**
   * Handle user agreement
   */
  handleAgree() {
    // Save agreement status
    AppStorage.setOrCreate(StorageKeys.PRIVACY_AGREED, true);
    this.onAgree();
    this.controller.close();
  }

  /**
   * Handle user disagreement
   */
  handleDisagree() {
    this.onDisagree();
    this.controller.close();
  }

  build() {
    Column() {
      // Title
      Text('用户隐私协议')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 20, bottom: 16 })

      // Privacy content
      Scroll() {
        Column() {
          Text('智慧托管平台用户隐私协议')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ bottom: 12 })

          Text(this.getPrivacyContent())
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .lineHeight(24)
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .width('100%')
      .height(this.scrollHeight)
      .scrollBar(BarState.Auto)

      // Action buttons
      Row() {
        Button('不同意')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor('#F5F5F5')
          .borderRadius(24)
          .layoutWeight(1)
          .onClick(() => this.handleDisagree())

        Button('同意并继续')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(24)
          .layoutWeight(1)
          .margin({ left: 12 })
          .onClick(() => this.handleAgree())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 20 })
    }
    .width('100%')
    .constraintSize({ maxWidth: $r('app.float.layout_dialog_max_width_xlarge') })
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  /**
   * Get privacy agreement content
   */
  private getPrivacyContent(): string {
    return `尊敬的用户：

感谢您选择智慧托管平台。为了更好地保护您的个人信息安全，我们根据《中华人民共和国民法典》《中华人民共和国个人信息保护法》等法律法规，制定本隐私协议。

一、信息收集
我们会收集以下信息：
1. 用户账号信息：姓名、手机号（用于登录和身份验证）
2. 学生信息：学生姓名、学号、年级（用于托管服务）
3. 托管服务信息：订单、考勤、作业等（用于服务提供）

二、信息使用
我们将收集的信息用于：
1. 提供、维护、改进我们的服务
2. 保障账户和交易安全
3. 向您发送服务通知和提醒
4. 遵守法律法规和监管要求

三、信息保护
1. 我们采用业界领先的技术保护措施，包括数据加密、访问控制等
2. 我们承诺不会向第三方出售、出租您的个人信息
3. 未经您同意，我们不会将您的信息用于本协议未载明的其他目的

四、未成年人保护
本平台服务于未成年人托管，我们承诺：
1. 最小化采集未成年人信息
2. 严格保护未成年人隐私
3. 仅用于托管服务目的

五、您的权利
您对您的个人信息享有知情权、查阅权、更正权、删除权等权利。

如您对本隐私协议有任何疑问，请通过以下方式联系我们：
客服电话：400-XXX-XXXX
邮箱：privacy@smartguardian.com

点击"同意并继续"即表示您认可并接受本协议全部内容。`;
  }
}

/**
 * Check if privacy agreement is accepted
 */
export function isPrivacyAgreed(): boolean {
  return AppStorage.get<boolean>(StorageKeys.PRIVACY_AGREED) ?? false;
}

/**
 * Show privacy dialog if not agreed
 */
export function showPrivacyDialogIfNeeded(onAgree: () => void, onDisagree: () => void): boolean {
  if (isPrivacyAgreed()) {
    return false;
  }
  
  // Dialog controller should be created by parent component
  // This function just returns true if dialog should be shown
  return true;
}
