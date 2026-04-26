/**
 * SmartGuardian - Workbench Action Grid
 * Shared quick action grid used by parent, teacher and admin dashboards
 */

import { HarmonyColor } from '../../common/HarmonyDesign';
import { WorkbenchModule } from '../../models/workbench';

@Component
export struct WorkbenchActionGrid {
  @Prop modules: WorkbenchModule[] = [];
  @Prop titleFontSize: number = 14;
  subtitleResolver: (code: string) => string = (_: string): string => '进入模块';
  iconResolver: (code: string) => Resource = (_: string): Resource => $r('app.media.ic_home');
  bgColorResolver: (code: string) => string = (_: string): string => HarmonyColor.surfaceSubtle;
  iconColorResolver: (code: string) => string = (_: string): string => HarmonyColor.textSecondary;
  onModuleClick: (module: WorkbenchModule) => void = (_: WorkbenchModule): void => {};

  build() {
    Column() {
      Row() {
        ForEach(this.getFirstRowModules(), (module: WorkbenchModule) => {
          this.buildFeatureItem(module)
        })
      }
      .width('100%')

      if (this.getSecondRowModules().length > 0) {
        Row() {
          ForEach(this.getSecondRowModules(), (module: WorkbenchModule) => {
            this.buildFeatureItem(module)
          })
        }
        .width('100%')
        .margin({ top: 14 })
      }
    }
    .width('100%')
  }

  @Builder
  private buildFeatureItem(module: WorkbenchModule) {
    Column() {
      Column() {
        Image(this.iconResolver(module.code))
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
          .fillColor(this.iconColorResolver(module.code))
      }
      .width(52)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.bgColorResolver(module.code))
      .borderRadius(18)

      Text(module.name)
        .fontSize(this.titleFontSize)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 10 })

      Text(this.subtitleResolver(module.code))
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.onModuleClick(module);
    })
  }

  private getFirstRowModules(): WorkbenchModule[] {
    return this.modules.slice(0, 5);
  }

  private getSecondRowModules(): WorkbenchModule[] {
    return this.modules.slice(5, 10);
  }
}
