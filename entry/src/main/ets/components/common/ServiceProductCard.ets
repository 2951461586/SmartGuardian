import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { ServiceProduct } from '../../models/service';

@Component
export struct ServiceProductCard {
  @Prop service: ServiceProduct | null = null;
  @Prop showActions: boolean = true;
  @Prop primaryActionText: string = '立即预约';
  @Prop secondaryActionText: string = '查看详情';
  onPrimaryAction?: () => void;
  onSecondaryAction?: () => void;

  private getServiceName(): string {
    if (this.service === null) {
      return '';
    }
    return this.service.serviceName;
  }

  private getDescription(): string {
    if (this.service === null || !this.service.description) {
      return '暂无服务说明';
    }
    return this.service.description;
  }

  private getPriceText(): string {
    if (this.service === null) {
      return '0';
    }
    return `${Number(this.service.price).toFixed(0)}`;
  }

  private getServiceType(): string {
    if (this.service === null) {
      return 'ALL';
    }
    return this.service.serviceType;
  }

  private getStatus(): string {
    if (this.service === null) {
      return 'INACTIVE';
    }
    return this.service.status;
  }

  private getServiceTypeText(): string {
    const serviceType = this.getServiceType();
    if (serviceType === 'ALL') {
      return '全部';
    }
    if (serviceType === 'AFTER_SCHOOL' || serviceType === 'AFTER_SCHOOL_CARE') {
      return '课后托管';
    }
    if (serviceType === 'HOLIDAY') {
      return '假期托管';
    }
    if (serviceType === 'FULL_DAY') {
      return '全天托管';
    }
    if (serviceType === 'WEEKEND') {
      return '周末托管';
    }
    if (serviceType === 'NOON_CARE') {
      return '午间托管';
    }
    if (serviceType === 'PICKUP') {
      return '接送服务';
    }
    return serviceType;
  }

  private getStatusText(): string {
    const status = this.getStatus();
    if (status === 'ACTIVE') {
      return '启用中';
    }
    if (status === 'INACTIVE') {
      return '已停用';
    }
    if (status === 'FULL') {
      return '已满员';
    }
    return status;
  }

  private getStatusColor(): string {
    const status = this.getStatus();
    if (status === 'ACTIVE') {
      return HarmonyReport.positive;
    }
    if (status === 'INACTIVE') {
      return HarmonyColor.textTertiary;
    }
    if (status === 'FULL') {
      return HarmonyReport.caution;
    }
    return HarmonyReport.accent;
  }

  private getRemainCapacity(): number {
    if (this.service === null) {
      return 0;
    }
    const total = this.service.maxStudents || this.service.capacity || 0;
    const current = this.service.currentStudents || 0;
    return total - current;
  }

  private getTimeRangeText(): string {
    if (this.service === null) {
      return '-- - --';
    }
    const start = this.service.signInStartTime ? this.service.signInStartTime : '--';
    const end = this.service.signOutEndTime ? this.service.signOutEndTime : '--';
    return `${start} - ${end}`;
  }

  private getRemainCapacityColor(): ResourceColor {
    if (this.getRemainCapacity() > 0) {
      return HarmonyReport.positive;
    }
    return HarmonyReport.danger;
  }

  build() {
    Column() {
      if (this.service !== null) {
        this.buildCardContent();
      } else {
        Blank();
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(HarmonyColor.surface)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  private buildCardContent() {
    Column() {
      Row() {
        Column() {
          Text(this.getServiceName())
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(this.getDescription())
            .fontSize(13)
            .lineHeight(20)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.getStatusText())
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getStatusColor())
      }
      .width('100%')

      Row() {
        Column() {
          Text('价格')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))

          Text(`￥${this.getPriceText()}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text('服务类型')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))

          Text(this.getServiceTypeText())
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ top: 14 })

      Row() {
        Column() {
          Text('服务时段')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))

          Text(this.getTimeRangeText())
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text('剩余名额')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))

          Text(`${this.getRemainCapacity()}`)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getRemainCapacityColor())
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .margin({ top: 12 })

      if (this.showActions) {
        Row() {
          Button(this.primaryActionText)
            .fontSize(14)
            .fontColor(HarmonyColor.textInverse)
            .backgroundColor($r('app.color.primary'))
            .borderRadius($r('app.float.button_radius'))
            .layoutWeight(1)
            .onClick(() => {
              if (this.onPrimaryAction) {
                this.onPrimaryAction();
              }
            })

          Button(this.secondaryActionText)
            .fontSize(14)
            .fontColor($r('app.color.primary'))
            .backgroundColor($r('app.color.primary_light'))
            .borderRadius($r('app.float.button_radius'))
            .margin({ left: 12 })
            .layoutWeight(1)
            .onClick(() => {
              if (this.onSecondaryAction) {
                this.onSecondaryAction();
              }
            })
        }
        .width('100%')
        .margin({ top: 16 })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
