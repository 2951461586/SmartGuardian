/**
 * SmartGuardian - App Entry
 */

import { UserStore } from '../stores/userStore';
import { getToken } from '../utils/request';

@Entry
@Component
struct Index {
  @State isRedirecting: boolean = true;
  @State message: string = '正在进入应用...';

  aboutToAppear() {
    this.redirect();
  }

  redirect(): void {
    const token = getToken();
    const isLoggedIn = UserStore.isLoggedIn();
    const target = token && isLoggedIn ? 'pages/MainPage' : 'pages/LoginPage';

    try {
      this.getUIContext().getRouter().replaceUrl({ url: target });
    } catch (error) {
      this.isRedirecting = false;
      this.message = '页面跳转失败';
      console.error('Index redirect failed:', String(error));
    }
  }

  build() {
    Column() {
      LoadingProgress()
        .width(32)
        .height(32)
        .color($r('app.color.primary'))

      Text(this.message)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.page_background'))
  }
}
