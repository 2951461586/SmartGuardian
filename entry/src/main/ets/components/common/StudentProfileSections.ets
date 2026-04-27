import { HarmonyColor, HarmonyReport, HarmonySpace } from '../../common/HarmonyDesign';

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
            .fontSize($r('app.float.card_title_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(metric.label)
            .fontSize($r('app.float.text_tiny_size'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: HarmonySpace.compact / 2 })
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
          .fontSize($r('app.float.text_secondary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(this.item.roleLabel)
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: HarmonySpace.compact / 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text(this.item.pickupLabel)
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor(this.resolvePickupLabelColor())

        Text(this.item.pickupCode)
          .fontSize($r('app.float.text_tiny_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: HarmonySpace.compact / 2 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
  }

  private resolvePickupLabelColor(): string {
    return this.item.pickupLabel.indexOf('已') >= 0 || this.item.pickupLabel.indexOf('宸') >= 0 ?
    HarmonyReport.positive : HarmonyColor.warning;
  }
}

@Component
export struct StudentAttendanceStatusChip {
  @Prop text: string = '';
  @Prop color: string = HarmonyColor.textSecondary;

  build() {
    Text(this.text)
      .fontSize($r('app.float.text_tiny_size'))
      .fontColor(this.color)
  }
}
