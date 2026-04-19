/**
 * SmartGuardian - App Entry
 */

import { router } from '@kit.ArkUI';
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
    router.replaceUrl({ url: target });
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
