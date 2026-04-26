import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';

export interface StudentGuardianViewModel {
  id: number;
  relationLabel: string;
  roleLabel: string;
  pickupLabel: string;
  pickupCode: string;
}

export interface StudentAttendanceMetricViewModel {
  label: string;
  value: string;
}

@Component
export struct StudentAttendanceMetricsCard {
  @Prop metrics: StudentAttendanceMetricViewModel[] = [];

  build() {
    Row() {
      ForEach(this.metrics, (metric: StudentAttendanceMetricViewModel) => {
        Column() {
          Text(metric.value)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(metric.label)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }, (metric: StudentAttendanceMetricViewModel) => metric.label)
    }
    .width('100%')
  }
}

@Component
export struct StudentGuardianItemCard {
  @Prop item: StudentGuardianViewModel = {
    id: 0,
    relationLabel: '',
    roleLabel: '',
    pickupLabel: '',
    pickupCode: '--'
  };

  build() {
    Row() {
      Column() {
        Text(this.item.relationLabel)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(this.item.roleLabel)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text(this.item.pickupLabel)
          .fontSize(12)
          .fontColor(this.resolvePickupLabelColor())

        Text(this.item.pickupCode)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
  }

  private resolvePickupLabelColor(): string {
    return this.item.pickupLabel === '宸叉巿鏉冩帴閫?' ? HarmonyReport.positive : HarmonyColor.warning;
  }
}

@Component
export struct StudentAttendanceStatusChip {
  @Prop text: string = '';
  @Prop color: string = HarmonyColor.textSecondary;

  build() {
    Text(this.text)
      .fontSize(12)
      .fontColor(this.color)
  }
}
