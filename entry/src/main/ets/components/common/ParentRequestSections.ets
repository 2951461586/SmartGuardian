import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { Card } from './Card';

export interface LeaveStudentOption {
  id: number;
  name: string;
}

export type LeaveTypeValue = 'SICK' | 'PERSONAL' | 'FAMILY' | 'OTHER';

@Component
export struct LeaveStudentSelectorCard {
  @Prop students: LeaveStudentOption[] = [];
  @Prop selectedStudentId: number = 0;
  onSelect?: (studentId: number) => void;

  build() {
    Card({
      title: '选择学生',
      subtitle: '先确定本次请假对应的学生，再继续填写申请内容。',
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Scroll() {
      Row() {
        ForEach(this.students, (student: LeaveStudentOption) => {
          Text(student.name)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.selectedStudentId === student.id ? HarmonyColor.textInverse : $r('app.color.text_primary'))
            .padding({ left: 20, right: 20, top: 10, bottom: 10 })
            .backgroundColor(this.selectedStudentId === student.id ? $r('app.color.primary') : $r('app.color.page_background'))
            .borderRadius($r('app.float.button_radius'))
            .margin({ right: 8 })
            .onClick(() => {
              if (this.onSelect) {
                this.onSelect(student.id);
              }
            })
        }, (student: LeaveStudentOption) => `${student.id}`)
      }
    }
    .width('100%')
    .scrollBar(BarState.Off)
  }
}

@Component
export struct LeaveDateSummaryCard {
  @Prop dateText: string = '';
  onDateClick?: () => void;

  build() {
    Card({
      title: '请假日期',
      subtitle: '支持从今天开始选择请假日期。',
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Row() {
      Text(this.dateText)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))

      Blank()

      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
        .fillColor($r('app.color.text_tertiary'))
    }
    .width('100%')
    .padding(12)
    .backgroundColor($r('app.color.page_background'))
    .borderRadius($r('app.float.button_radius'))
    .onClick(() => {
      if (this.onDateClick) {
        this.onDateClick();
      }
    })
  }
}

@Component
export struct LeaveTypeSelectorCard {
  @Prop selectedValue: LeaveTypeValue = 'SICK';
  onSelect?: (value: LeaveTypeValue) => void;

  build() {
    Card({
      title: '请假类型',
      subtitle: '按场景选择本次请假的主要原因。',
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Column() {
      Row() {
        this.buildChip('病假', 'SICK', true)
        this.buildChip('事假', 'PERSONAL', false)
      }
      .width('100%')

      Row() {
        this.buildChip('家庭事务', 'FAMILY', true)
        this.buildChip('其他', 'OTHER', false)
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
  }

  @Builder
  private buildChip(label: string, value: LeaveTypeValue, hasRightGap: boolean) {
    Column() {
      Text(label)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(this.selectedValue === value ? $r('app.color.primary') : $r('app.color.text_secondary'))
    }
    .layoutWeight(1)
    .padding(12)
    .margin({ right: hasRightGap ? 12 : 0 })
    .backgroundColor(this.selectedValue === value ? $r('app.color.primary_light') : $r('app.color.page_background'))
    .borderRadius($r('app.float.button_radius'))
    .onClick(() => {
      if (this.onSelect) {
        this.onSelect(value);
      }
    })
  }
}

@Component
export struct RefundAmountSummaryCard {
  @Prop orderAmount: number = 0;
  @Prop deduction: number = 0;
  @Prop refundAmount: number = 0;

  build() {
    Card({
      title: '金额说明',
      subtitle: '系统会根据当前规则自动计算可退金额。',
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    Column() {
      this.buildAmountRow('订单金额', `￥${this.orderAmount.toFixed(2)}`, false)
      this.buildAmountRow('手续费', `-￥${this.deduction.toFixed(2)}`, true)

      Divider()
        .color(HarmonyColor.line)
        .margin({ top: 12, bottom: 12 })

      Row() {
        Text('可退金额')
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Text(`￥${this.refundAmount.toFixed(2)}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(HarmonyReport.danger)
      }
      .width('100%')

      Text('提交申请后需等待机构审核，审核通过后将按原路退回。')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .lineHeight(18)
        .margin({ top: 10 })
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
