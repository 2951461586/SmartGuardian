import { HarmonyColor, HarmonyReport, harmonyShadowColor } from '../../common/HarmonyDesign';
import { TeacherPerformance } from '../../services/api/reports';

@Component
export struct TeacherPerformanceCard {
  @Prop teacher: TeacherPerformance | null = null;

  build() {
    if (this.teacher === null) {
      Blank()
    } else {
      Column() {
        Row() {
          Column() {
            Text(this.teacher.teacherName)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))

            Text(`平均评分 ${this.teacher.avgRating}`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Text(`${this.teacher.avgAttendanceRate}%`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(HarmonyReport.positive)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Row() {
          this.buildCompactMetric('班次数', `${this.teacher.totalSessions}`, HarmonyReport.accent)
          Blank().width(10)
          this.buildCompactMetric('学生数', `${this.teacher.totalStudents}`, $r('app.color.primary'))
          Blank().width(10)
          this.buildCompactMetric('作业完成', `${this.teacher.homeworkCompletedCount}`, HarmonyReport.caution)
        }
        .width('100%')
        .margin({ top: 14 })
      }
      .width('100%')
      .padding(18)
      .backgroundColor(HarmonyColor.surface)
      .borderRadius(20)
      .shadow({ radius: 12, color: harmonyShadowColor(), offsetX: 0, offsetY: 4 })
    }
  }

  @Builder
  private buildCompactMetric(label: string, value: string, color: ResourceColor) {
    Column() {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(HarmonyColor.surfaceSubtle)
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }
}
