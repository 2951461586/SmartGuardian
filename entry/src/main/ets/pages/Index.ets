/**
 * SmartGuardian - Bootstrap Shell
 */

import { RouteUrls } from '../constants/app.constants';
import { LogUtil } from '../utils/LogUtil';

@Entry
@Component
struct Index {
  @State routeError: string = '';

  private openRoute(route: string): void {
    this.routeError = '';
    LogUtil.warn(`Bootstrap navigating to ${route}`);

    try {
      this.getUIContext().getRouter().pushUrl({ url: route });
    } catch (error) {
      const message = `Bootstrap route failed: ${String(error)}`;
      this.routeError = message;
      LogUtil.error(message);
    }
  }

  build() {
    Column() {
      Text('智慧托管')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)

      Text('启动页已加载，请选择入口')
        .fontSize(14)
        .margin({ top: 12, bottom: 28 })

      Button('进入登录')
        .width('72%')
        .height(48)
        .onClick((): void => {
          this.openRoute(RouteUrls.LOGIN);
        })

      Button('进入工作台')
        .width('72%')
        .height(48)
        .margin({ top: 12 })
        .onClick((): void => {
          this.openRoute(RouteUrls.MAIN);
        })

      if (this.routeError.length > 0) {
        Text(this.routeError)
          .width('72%')
          .fontSize(12)
          .fontColor($r('app.color.error'))
          .textAlign(TextAlign.Center)
          .margin({ top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
