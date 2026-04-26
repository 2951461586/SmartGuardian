/**
 * SmartGuardian - 异常提醒卡片UI
 * 用于显示学生异常情况的快速提醒
 */

let abnormalAlertCardStorage = new LocalStorage();

@Entry(abnormalAlertCardStorage)
@Component
struct AbnormalAlertCard {
  @LocalStorageProp('studentName') studentName: string = '张小明';
  @LocalStorageProp('abnormalType') abnormalType: string = '未签到';
  @LocalStorageProp('triggerTime') triggerTime: string = '15:35';
  @LocalStorageProp('riskLevel') riskLevel: string = '高';
  @LocalStorageProp('riskColor') riskColor: string = '#F44336';
  @LocalStorageProp('suggestion') suggestion: string = '请及时联系老师确认';
  @LocalStorageProp('teacherName') teacherName: string = '李老师';
  @LocalStorageProp('updateTime') updateTime: string = '15:40';
  @LocalStorageProp('formId') formId: number = 2;

  build() {
    Column() {
      if (this.formId === 1) {
        this.SmallAlertCard()
      } else {
        this.MediumAlertCard()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SmallAlertCard() {
    Column() {
      Row() {
        Circle()
          .width(8)
          .height(8)
          .fill(this.riskColor)

        Text(`${this.riskLevel}风险`)
          .fontSize(10)
          .fontColor(this.riskColor)
          .margin({ left: 4 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Blank().height(8)

      Text(this.abnormalType)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      Text(this.studentName)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })

      Blank().height(8)

      Text(`${this.triggerTime} 触发`)
        .fontSize(10)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor('#FFF5F5')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  MediumAlertCard() {
    Column() {
      Row() {
        Text('⚠️ 异常提醒')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#D32F2F')

        Blank()

        Text(this.updateTime)
          .fontSize(10)
          .fontColor('#999999')
      }
      .width('100%')
      .padding({ bottom: 8 })

      Divider().color('#FFEBEE')

      Blank().height(8)

      Row() {
        Column() {
          Text(this.studentName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text(this.abnormalType)
            .fontSize(12)
            .fontColor(this.riskColor)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column() {
          Text(this.riskLevel)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.riskColor)

          Text('风险等级')
            .fontSize(10)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .padding(8)
        .backgroundColor(Color.White)
        .borderRadius(8)
      }
      .width('100%')

      Blank().height(8)

      Row() {
        Text('💡')
          .fontSize(14)

        Text(this.suggestion)
          .fontSize(11)
          .fontColor('#666666')
          .layoutWeight(1)
          .margin({ left: 6 })
      }
      .width('100%')
      .padding(8)
      .backgroundColor('#FFFFFF')
      .borderRadius(6)
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor('#FFF8F8')
    .borderRadius(16)
  }
}
