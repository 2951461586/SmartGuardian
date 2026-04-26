import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { Card } from './Card';
import { TabBar } from './TabBar';

@Component
export struct ReportControlDeck {
  @Prop rangeOptions: string[] = [];
  @Prop selectedRange: string = '';
  @Prop tabs: string[] = [];
  @Prop currentIndex: number = 0;
  onRangeChange?: (range: string) => void;
  onTabChange?: (index: number) => void;

  build() {
    Card({
      title: '报告控制台',
      subtitle: '统一控制统计周期和分析维度，再进入数据明细',
      customPadding: 12,
      content: this.buildContent
    })
  }

  @Builder
  private buildContent() {
    Column() {
      Row() {
        ForEach(this.rangeOptions, (range: string, index: number) => {
          Text(range)
            .fontSize(13)
            .fontWeight(this.selectedRange === range ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.selectedRange === range ? $r('app.color.primary') : $r('app.color.text_secondary'))
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.selectedRange === range ? HarmonyReport.cautionSurface : HarmonyColor.surfaceSubtle)
            .borderRadius(16)
            .margin({ right: index === this.rangeOptions.length - 1 ? 0 : 10 })
            .onClick(() => {
              if (this.onRangeChange) {
                this.onRangeChange(range);
              }
            })
        })
      }
      .width('100%')

      TabBar({
        tabs: this.tabs,
        currentIndex: this.currentIndex,
        onTabChange: (index: number) => {
          if (this.onTabChange) {
            this.onTabChange(index);
          }
        }
      })
      .margin({ top: 14 })
    }
  }
}
