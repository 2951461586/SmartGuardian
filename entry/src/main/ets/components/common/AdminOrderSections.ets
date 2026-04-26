import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
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
        customPadding: 18,
        content: this.buildHeroContent
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
        .margin({ left: 12 })
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
        .margin({ left: 12 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ top: 12 })
    }
    .width('100%')
  }

  @Builder
  private buildHeroContent() {
    Row() {
      Column() {
        Text(this.accent)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary'))
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(HarmonyReport.cautionSurface)
          .borderRadius(999)

        Text(this.totalAmountText)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 14 })

        Text('当前筛选范围内的订单金额总量')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
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
      .width(112)
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
        customPadding: 12,
        content: this.buildContent
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
          .fontSize(11)
          .fontColor(HarmonyReport.positive)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor($r('app.color.surface_success'))
          .borderRadius(999)
      }
      .width('100%')
      .margin({ bottom: 12 })

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
      customPadding: 14,
      customBgColor: HarmonyColor.surfaceSubtle,
      content: this.buildContent
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
      Blank().width(10)
      AdminOrdersMetricTile({
        label: '订单量',
        value: `${this.orderCount}`,
        valueColor: HarmonyColor.textPrimary
      })
      Blank().width(10)
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
        .margin({ top: 8, bottom: 16 })

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
            .margin({ top: 8 })
        }
        .width('100%')
      }

      TextArea({
        placeholder: '请输入拒绝原因',
        text: this.auditRemark
      })
        .width('100%')
        .height(120)
        .fontSize($r('app.float.text_primary_size'))
        .backgroundColor(HarmonyColor.surfaceSubtle)
        .borderRadius($r('app.float.button_radius'))
        .margin({ top: 16 })
        .onChange((value: string) => {
          if (this.onRemarkChange) {
            this.onRemarkChange(value);
          }
        })

      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_primary'))
          .backgroundColor(HarmonyColor.surfaceMuted)
          .borderRadius(22)
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel();
            }
          })

        Button('确认拒绝')
          .layoutWeight(1)
          .height(44)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(HarmonyColor.textInverse)
          .backgroundColor(HarmonyReport.danger)
          .borderRadius(22)
          .margin({ left: 12 })
          .enabled(this.auditRemark.trim().length > 0)
          .onClick(() => {
            if (this.onConfirmReject) {
              this.onConfirmReject();
            }
          })
      }
      .width('100%')
      .margin({ top: 20 })
    }
    .width('100%')
    .padding(20)
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
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))

      Text(this.value)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.valueColor)
        .margin({ top: 6 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 10 })
  }
}
