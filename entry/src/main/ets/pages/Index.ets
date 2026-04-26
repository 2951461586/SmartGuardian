/**
 * SmartGuardian - Bootstrap Shell
 */

import { RouteUrls } from '../constants/app.constants';

@Entry
@Component
struct Index {
  private openRoute(route: string): void {
    try {
      this.getUIContext().getRouter().replaceUrl({ url: route });
    } catch (error) {
      console.error('Bootstrap route failed:', String(error));
    }
  }

  build() {
    Column() {
      Text('SmartGuardian')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)

      Text('Bootstrap page loaded. Choose an entry below.')
        .fontSize(14)
        .margin({ top: 12, bottom: 28 })

      Button('Enter Login')
        .width('72%')
        .height(48)
        .onClick((): void => {
          this.openRoute(RouteUrls.LOGIN);
        })

      Button('Enter Workbench')
        .width('72%')
        .height(48)
        .margin({ top: 12 })
        .onClick((): void => {
          this.openRoute(RouteUrls.MAIN);
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
