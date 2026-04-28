/**
 * SmartGuardian - Abnormal Alert Form Card UI
 */

let abnormalAlertCardStorage = new LocalStorage();

@Entry(abnormalAlertCardStorage)
@Component
struct AbnormalAlertCard {
  @LocalStorageProp('studentName') studentName: string = '张小明';
  @LocalStorageProp('abnormalType') abnormalType: string = '未签到';
  @LocalStorageProp('triggerTime') triggerTime: string = '15:35';
  @LocalStorageProp('riskLevel') riskLevel: string = '高';
  @LocalStorageProp('riskColor') riskColor: string = '#D92D20';
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
        .fontColor('#101828')

      Text(this.studentName)
        .fontSize(12)
        .fontColor('#667085')
        .margin({ top: 4 })

      Blank().height(8)

      Text(`${this.triggerTime} 触发`)
        .fontSize(10)
        .fontColor('#98A2B3')
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor('#FFF0F1')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  MediumAlertCard() {
    Column() {
      Row() {
        Text('异常提醒')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#D92D20')

        Blank()

        Text(this.updateTime)
          .fontSize(10)
          .fontColor('#98A2B3')
      }
      .width('100%')
      .padding({ bottom: 8 })

      Divider().color('#FFE3E6')

      Blank().height(8)

      Row() {
        Column() {
          Text(this.studentName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#101828')

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
            .fontColor('#98A2B3')
            .margin({ top: 2 })
        }
        .padding(8)
        .backgroundColor(Color.White)
        .borderRadius(8)
      }
      .width('100%')

      Blank().height(8)

      Row() {
        Text('建议')
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .fontColor('#D92D20')

        Text(this.suggestion)
          .fontSize(11)
          .fontColor('#667085')
          .layoutWeight(1)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding(8)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor('#FFF8F8')
    .borderRadius(16)
  }
}
