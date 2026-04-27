import { HarmonyColor, HarmonyReport, harmonyShadowColor } from '../../common/HarmonyDesign';
import { Student } from '../../models/user';
import { Card } from './Card';
import { SectionHeader } from './SectionHeader';
import { SelectionSheet } from './SelectionSheet';

@Component
export struct OrderCreateServiceSummaryCard {
  @Prop serviceName: string = '';
  @Prop servicePrice: number = 0;

  build() {
    Card({
      title: '服务信息',
      subtitle: '确认当前报名服务和单价。',
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Row() {
      Column() {
        Text(this.serviceName.length > 0 ? this.serviceName : '未命名服务')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Text(`按天计费 · ￥${this.servicePrice.toFixed(2)} / 天`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
  }
}

@Component
export struct OrderCreateStudentSection {
  @Prop selectedStudentName: string = '';
  onSelect?: () => void;

  build() {
    Column() {
      SectionHeader({
        title: '选择学生',
        subtitle: '将订单绑定到具体学生档案。'
      })

      Card({
        title: '学生信息',
        actionText: '选择学生',
        onAction: this.onSelect,
        content: () => { this.buildContent() }
      })
    }
    .width('100%')
  }

  @Builder
  private buildContent() {
    Text(this.selectedStudentName.length > 0 ? this.selectedStudentName : '请先选择学生')
      .width('100%')
      .fontSize(16)
      .fontColor(this.selectedStudentName.length > 0 ? $r('app.color.text_primary') : $r('app.color.text_secondary'))
  }
}

@Component
export struct OrderCreateDateSection {
  @Prop startDate: string = '';
  @Prop endDate: string = '';
  onSelectStart?: () => void;
  onSelectEnd?: () => void;

  build() {
    Column() {
      SectionHeader({
        title: '服务周期',
        subtitle: '使用弹窗选择开始日期和结束日期。'
      })

      Card({
        title: '日期选择',
        content: () => { this.buildContent() }
      })
    }
    .width('100%')
  }

  @Builder
  private buildContent() {
    Row() {
      this.buildDateCell('开始日期', this.startDate, this.onSelectStart)

      Divider()
        .vertical(true)
        .height(36)
        .color(HarmonyColor.line)
        .margin({ left: 12, right: 12 })

      this.buildDateCell('结束日期', this.endDate, this.onSelectEnd)
    }
    .width('100%')
  }

  @Builder
  private buildDateCell(title: string, value: string, action?: () => void) {
    Column() {
      Text(title)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))

      Text(value.length > 0 ? value : '请选择')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 6 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      if (action) {
        action();
      }
    })
  }
}

@Component
export struct OrderAmountSummarySection {
  @Prop totalDays: number = 0;
  @Prop totalAmount: number = 0;
  @Prop discountAmount: number = 0;
  @Prop actualAmount: number = 0;

  build() {
    Column() {
      SectionHeader({
        title: '费用明细',
        subtitle: '自动计算服务天数、优惠和最终应付金额。'
      })

      Card({
        title: '结算信息',
        content: () => { this.buildContent() }
      })
    }
    .width('100%')
  }

  @Builder
  private buildContent() {
    Column() {
      this.buildAmountRow('服务天数', `${this.totalDays} 天`, false)
      this.buildAmountRow('服务费用', `￥${this.totalAmount.toFixed(2)}`, false)

      if (this.discountAmount > 0) {
        this.buildAmountRow('优惠金额', `-￥${this.discountAmount.toFixed(2)}`, true)
      }

      Divider()
        .color(HarmonyColor.line)
        .margin({ top: 12, bottom: 12 })

      Row() {
        Text('应付金额')
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Text(`￥${this.actualAmount.toFixed(2)}`)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(HarmonyReport.danger)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  private buildAmountRow(label: string, value: string, highlight: boolean) {
    Row() {
      Text(label)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_secondary'))

      Blank()

      Text(value)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor(highlight ? HarmonyReport.caution : $r('app.color.text_primary'))
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }
}

@Component
export struct OrderCreateNotesCard {
  build() {
    Card({
      title: '温馨提示',
      subtitle: '下单前请留意优惠规则和审核时效。',
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Column() {
      Text('1. 连续报名 10 天及以上可享 9 折优惠。')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')

      Text('2. 订单提交后需等待机构审核。')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ top: 6 })

      Text('3. 审核通过后请尽快完成支付。')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ top: 6 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct OrderCreateBottomBar {
  @Prop actualAmount: number = 0;
  @Prop isSubmitting: boolean = false;
  @Prop canSubmit: boolean = false;
  onSubmit?: () => void;

  build() {
    Row() {
      Column() {
        Text('应付金额')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))

        Text(`￥${this.actualAmount.toFixed(2)}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(HarmonyReport.danger)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button(this.isSubmitting ? '提交中...' : '提交订单')
        .width(160)
        .height(46)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(HarmonyColor.textInverse)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(18)
        .enabled(this.canSubmit && !this.isSubmitting)
        .opacity(this.canSubmit && !this.isSubmitting ? 1 : 0.6)
        .onClick(() => {
          if (this.onSubmit) {
            this.onSubmit();
          }
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 18 })
    .backgroundColor(HarmonyColor.surface)
    .shadow({
      radius: 10,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: -4
    })
  }
}

@Component
export struct OrderCreateStudentPickerSheet {
  @Prop title: string = '选择学生';
  @Prop selectedStudentName: string = '';
  @Prop students: Student[] = [];
  onSelectStudent?: (student: Student) => void;

  build() {
    SelectionSheet({
      title: this.title,
      selectedValue: this.selectedStudentName,
      options: this.students.map((student: Student) => student.name),
      onSelect: (value: string): void => {
        const selected = this.students.find((student: Student) => student.name === value);
        if (selected && this.onSelectStudent) {
          this.onSelectStudent(selected);
        }
      }
    })
  }
}
