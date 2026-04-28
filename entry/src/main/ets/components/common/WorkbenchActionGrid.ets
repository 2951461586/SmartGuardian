/**
 * SmartGuardian - Workbench Action Grid
 * Shared quick action grid used by parent, teacher and admin dashboards.
 */

import { HarmonyColor, HarmonyRadius, HarmonySpace } from '../../common/HarmonyDesign';
import { WorkbenchModule } from '../../models/workbench';

@Component
export struct WorkbenchActionGrid {
  @Prop modules: WorkbenchModule[] = [];
  @Prop titleFontSize: Resource = $r('app.float.text_secondary_size');
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
        .margin({ top: HarmonySpace.section })
      }
    }
    .width('100%')
  }

  @Builder
  private buildFeatureItem(module: WorkbenchModule) {
    Column() {
      Column() {
        Image(this.iconResolver(module.code))
          .width($r('app.float.icon_small_size'))
          .height($r('app.float.icon_small_size'))
          .objectFit(ImageFit.Contain)
          .fillColor(this.iconColorResolver(module.code))
      }
      .width($r('app.float.list_item_height'))
      .height($r('app.float.list_item_height'))
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.bgColorResolver(module.code))
      .borderRadius(HarmonyRadius.control)
      .border({
        width: 1,
        color: HarmonyColor.line,
        radius: HarmonyRadius.control,
        style: BorderStyle.Solid
      })

      Text(module.name)
        .fontSize(this.titleFontSize)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: HarmonySpace.compact })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(this.subtitleResolver(module.code))
        .fontSize($r('app.float.text_tiny_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: HarmonySpace.compact / 2 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
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
