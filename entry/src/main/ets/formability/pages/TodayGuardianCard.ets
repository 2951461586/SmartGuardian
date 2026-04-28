/**
 * SmartGuardian - Today Guardian Form Card UI
 * Supports 2x2, 2x4 and 4x4 card sizes.
 */

let todayGuardianCardStorage = new LocalStorage();

@Entry(todayGuardianCardStorage)
@Component
struct TodayGuardianCard {
  @LocalStorageProp('studentName') studentName: string = '张小明';
  @LocalStorageProp('className') className: string = '三年级 1 班';
  @LocalStorageProp('sessionTime') sessionTime: string = '15:30-18:00';
  @LocalStorageProp('status') status: string = '已签到';
  @LocalStorageProp('statusColor') statusColor: string = '#2DBE7E';
  @LocalStorageProp('statusIcon') statusIcon: string = '已签';
  @LocalStorageProp('signInTime') signInTime: string = '15:32';
  @LocalStorageProp('homeworkProgress') homeworkProgress: string = '2/3';
  @LocalStorageProp('teacherFeedback') teacherFeedback: string = '作业完成良好';
  @LocalStorageProp('updateTime') updateTime: string = '17:00';
  @LocalStorageProp('formId') formId: number = 2;

  build() {
    Column() {
      if (this.formId === 1) {
        this.SmallCard()
      } else if (this.formId === 2) {
        this.MediumCard()
      } else {
        this.LargeCard()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SmallCard() {
    Column() {
      Text(this.studentName)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#101828')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Blank().height(8)

      Row() {
        this.StatusChip()

        Text(this.status)
          .fontSize(12)
          .fontColor(this.statusColor)
          .margin({ left: 6 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Blank().height(8)

      Text(`更新 ${this.updateTime}`)
        .fontSize(10)
        .fontColor('#98A2B3')
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  MediumCard() {
    Column() {
      Row() {
        Text('今日托管')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#101828')

        Blank()

        Text(this.updateTime)
          .fontSize(10)
          .fontColor('#98A2B3')
      }
      .width('100%')
      .padding({ bottom: 8 })

      Divider().color('#E7EEF7')

      Blank().height(8)

      Row() {
        Column() {
          Text(this.studentName)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#101828')

          Text(this.className)
            .fontSize(11)
            .fontColor('#98A2B3')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column() {
          this.StatusChip()

          Text(this.status)
            .fontSize(11)
            .fontColor(this.statusColor)
            .margin({ top: 4 })
        }
      }
      .width('100%')

      Blank().height(8)

      Row() {
        this.InfoItem('时段', this.sessionTime)
        this.InfoItem('签到', this.signInTime)
        this.InfoItem('作业', this.homeworkProgress)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  @Builder
  LargeCard() {
    Column() {
      Row() {
        Text('今日托管详情')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#101828')

        Blank()

        Text('刷新')
          .fontSize(12)
          .fontColor('#2F7DF6')
      }
      .width('100%')
      .padding({ bottom: 12 })

      Divider().color('#E7EEF7')

      Blank().height(12)

      Row() {
        Column() {
          Text(this.studentName)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#101828')

          Text(this.className)
            .fontSize(12)
            .fontColor('#98A2B3')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column() {
          this.StatusChip()

          Text(this.status)
            .fontSize(14)
            .fontColor(this.statusColor)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
        }
      }
      .width('100%')

      Blank().height(12)

      Column() {
        Row() {
          this.DetailInfoItem('托管时段', this.sessionTime)
          this.DetailInfoItem('签到时间', this.signInTime)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Blank().height(8)

        Row() {
          this.DetailInfoItem('作业进度', this.homeworkProgress)
          this.DetailInfoItem('教师反馈', this.teacherFeedback)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F6FAFF')
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }

  @Builder
  StatusChip() {
    Text(this.statusIcon)
      .fontSize(10)
      .fontColor('#FFFFFF')
      .padding({ left: 6, right: 6, top: 3, bottom: 3 })
      .backgroundColor(this.statusColor)
      .borderRadius(999)
  }

  @Builder
  InfoItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(10)
        .fontColor('#98A2B3')

      Text(value)
        .fontSize(12)
        .fontColor('#101828')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 2 })
    }
  }

  @Builder
  DetailInfoItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(11)
        .fontColor('#667085')

      Text(value)
        .fontSize(13)
        .fontColor('#101828')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
  }
}
