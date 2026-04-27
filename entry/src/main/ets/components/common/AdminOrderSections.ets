import { HarmonyColor, HarmonyRadius, HarmonyReport, HarmonySpace } from '../../common/HarmonyDesign';
import { Order } from '../../models/service';
import { Card, StatCard } from './Card';
import { SectionHeader } from './SectionHeader';
import { TabBar } from './TabBar';

@Component
export struct AdminOrdersOverviewCard {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop accent: string = '';
  @Prop totalAmountText: string = '¥0';
  @Prop pendingCount: number = 0;
  @Prop approvedCount: number = 0;
  @Prop visibleCount: number = 0;
  @Prop averageAmount: string = '¥0';

  build() {
    Column() {
      Card({
        title: this.title,
        subtitle: this.subtitle,
        customPadding: HarmonySpace.card,
        content: () => { this.buildHeroContent() }
      })

      Row() {
        StatCard({
          value: this.visibleCount,
          label: '当前列表',
          icon: $r('app.media.ic_order'),
          iconColor: HarmonyColor.brandBlue
        })
        .layoutWeight(1)

        StatCard({
          value: this.pendingCount,
          label: '待审核',
          icon: $r('app.media.ic_warning'),
          iconColor: HarmonyReport.caution
        })
        .layoutWeight(1)
        .margin({ left: HarmonySpace.section })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row() {
        StatCard({
          value: this.approvedCount,
          label: '已审核',
          icon: $r('app.media.ic_success'),
          iconColor: HarmonyReport.positive
        })
        .layoutWeight(1)

        StatCard({
          value: this.averageAmount,
          label: '平均金额',
          icon: $r('app.media.ic_money'),
          iconColor: HarmonyColor.brandBlue
        })
        .layoutWeight(1)
        .margin({ left: HarmonySpace.section })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ top: HarmonySpace.section })
    }
    .width('100%')
  }

  @Builder
  private buildHeroContent() {
    Row() {
      Column() {
        Text(this.accent)
          .fontSize($r('app.float.text_tiny_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary'))
          .padding({ left: HarmonySpace.section, right: HarmonySpace.section, top: HarmonySpace.compact / 2, bottom: HarmonySpace.compact / 2 })
          .backgroundColor(HarmonyReport.cautionSurface)
          .borderRadius(HarmonyRadius.pill)

        Text(this.totalAmountText)
          .fontSize($r('app.float.page_title_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: HarmonySpace.section })

        Text('当前筛选范围内的订单金额总量')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: HarmonySpace.compact })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column() {
        AdminOrdersMetricTile({
          label: '待处理',
          value: `${this.pendingCount}`,
          valueColor: HarmonyReport.caution
        })
        AdminOrdersMetricTile({
          label: '已完成',
          value: `${this.approvedCount}`,
          valueColor: HarmonyReport.positive
        })
      }
      .width($r('app.float.feedback_input_height'))
    }
    .width('100%')
  }
}

@Component
export struct AdminOrdersControlCard {
  @Prop tabs: string[] = [];
  @Prop currentTab: number = 0;
  @Prop title: string = '';
  onTabChange?: (index: number) => void;

  build() {
    Column() {
      SectionHeader({
        title: '审核控制台',
        subtitle: '先锁定审核范围，再进入订单流逐条处理。'
      })

      Card({
        customPadding: HarmonySpace.section,
        content: () => { this.buildContent() }
      })
    }
  }

  @Builder
  private buildContent() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize($r('app.float.card_title_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Blank().layoutWeight(1)

        Text('实时同步')
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor(HarmonyReport.positive)
          .padding({ left: HarmonySpace.section, right: HarmonySpace.section, top: HarmonySpace.compact / 2, bottom: HarmonySpace.compact / 2 })
          .backgroundColor($r('app.color.surface_success'))
          .borderRadius(HarmonyRadius.pill)
      }
      .width('100%')
      .margin({ bottom: HarmonySpace.section })

      TabBar({
        tabs: this.tabs,
        currentIndex: this.currentTab,
        onTabChange: (index: number) => {
          if (this.onTabChange) {
            this.onTabChange(index);
          }
        }
      })
    }
  }
}

@Component
export struct AdminOrdersSummaryCard {
  @Prop modeLabel: string = '';
  @Prop orderCount: number = 0;
  @Prop totalAmountText: string = '¥0';

  build() {
    Card({
      customPadding: HarmonySpace.section,
      customBgColor: HarmonyColor.surfaceSubtle,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Row() {
      AdminOrdersMetricTile({
        label: '模式',
        value: this.modeLabel,
        valueColor: HarmonyColor.brandBlue
      })
      Blank().width(HarmonySpace.compact)
      AdminOrdersMetricTile({
        label: '订单量',
        value: `${this.orderCount}`,
        valueColor: HarmonyColor.textPrimary
      })
      Blank().width(HarmonySpace.compact)
      AdminOrdersMetricTile({
        label: '总金额',
        value: this.totalAmountText,
        valueColor: HarmonyReport.positive
      })
    }
    .width('100%')
  }
}

@Component
export struct AdminOrderAuditSheet {
  @Prop selectedOrder: Order | null = null;
  @Prop auditRemark: string = '';
  onRemarkChange?: (value: string) => void;
  onCancel?: () => void;
  onConfirmReject?: () => void;

  build() {
    Column() {
      Text('拒绝订单')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: HarmonySpace.compact, bottom: HarmonySpace.page })

      if (this.selectedOrder) {
        Column() {
          Text(`订单号：${this.selectedOrder.orderNo}`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .width('100%')

          Text(`学生：${this.selectedOrder.studentName ? this.selectedOrder.studentName : '-'}`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .margin({ top: HarmonySpace.compact })
        }
        .width('100%')
      }

      TextArea({
        placeholder: '请输入拒绝原因',
        text: this.auditRemark
      })
        .width('100%')
        .height($r('app.float.feedback_input_height'))
        .fontSize($r('app.float.text_primary_size'))
        .backgroundColor(HarmonyColor.surfaceSubtle)
        .borderRadius($r('app.float.button_radius'))
        .margin({ top: HarmonySpace.page })
        .onChange((value: string) => {
          if (this.onRemarkChange) {
            this.onRemarkChange(value);
          }
        })

      Row() {
        Button('取消')
          .layoutWeight(1)
          .height($r('app.float.input_height'))
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_primary'))
          .backgroundColor(HarmonyColor.surfaceMuted)
          .borderRadius(HarmonyRadius.pill)
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel();
            }
          })

        Button('确认拒绝')
          .layoutWeight(1)
          .height($r('app.float.input_height'))
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(HarmonyColor.textInverse)
          .backgroundColor(HarmonyReport.danger)
          .borderRadius(HarmonyRadius.pill)
          .margin({ left: HarmonySpace.section })
          .enabled(this.auditRemark.trim().length > 0)
          .onClick(() => {
            if (this.onConfirmReject) {
              this.onConfirmReject();
            }
          })
      }
      .width('100%')
      .margin({ top: HarmonySpace.card })
    }
    .width('100%')
    .padding(HarmonySpace.card)
  }
}

@Component
struct AdminOrdersMetricTile {
  @Prop label: string = '';
  @Prop value: string = '';
  @Prop valueColor: string = HarmonyColor.textPrimary;

  build() {
    Column() {
      Text(this.label)
        .fontSize($r('app.float.text_tiny_size'))
        .fontColor($r('app.color.text_secondary'))

      Text(this.value)
        .fontSize($r('app.float.text_secondary_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(this.valueColor)
        .margin({ top: HarmonySpace.compact })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .padding(HarmonySpace.section)
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(HarmonyRadius.control)
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: HarmonySpace.compact })
  }
}
