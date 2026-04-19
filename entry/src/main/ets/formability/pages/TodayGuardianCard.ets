/**
 * SmartGuardian - 今日托管卡片UI
 * 支持 2x2, 2x4, 4x4 三种尺寸
 */

@Entry
@Component
struct TodayGuardianCard {
  @LocalStorageProp('studentName') studentName: string = '张小明';
  @LocalStorageProp('className') className: string = '三年级1班';
  @LocalStorageProp('sessionTime') sessionTime: string = '15:30-18:00';
  @LocalStorageProp('status') status: string = '已签到';
  @LocalStorageProp('statusColor') statusColor: string = '#4CAF50';
  @LocalStorageProp('statusIcon') statusIcon: string = '✅';
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
        .fontColor('#333333')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Blank().height(8)

      Row() {
        Text(this.statusIcon)
          .fontSize(20)

        Text(this.status)
          .fontSize(12)
          .fontColor(this.statusColor)
          .margin({ left: 4 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Blank().height(8)

      Text(`更新 ${this.updateTime}`)
        .fontSize(10)
        .fontColor('#999999')
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
          .fontColor('#333333')

        Blank()

        Text(this.updateTime)
          .fontSize(10)
          .fontColor('#999999')
      }
      .width('100%')
      .padding({ bottom: 8 })

      Divider().color('#F0F0F0')

      Blank().height(8)

      Row() {
        Column() {
          Text(this.studentName)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text(this.className)
            .fontSize(11)
            .fontColor('#999999')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column() {
          Text(this.statusIcon)
            .fontSize(24)

          Text(this.status)
            .fontSize(11)
            .fontColor(this.statusColor)
            .margin({ top: 2 })
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
          .fontColor('#333333')

        Blank()

        Text('刷新')
          .fontSize(12)
          .fontColor('#2196F3')
      }
      .width('100%')
      .padding({ bottom: 12 })

      Divider().color('#F0F0F0')

      Blank().height(12)

      Row() {
        Column() {
          Text(this.studentName)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text(this.className)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column() {
          Text(this.statusIcon)
            .fontSize(32)

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
          this.DetailInfoItem('📅 托管时段', this.sessionTime)
          this.DetailInfoItem('⏰ 签到时间', this.signInTime)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Blank().height(8)

        Row() {
          this.DetailInfoItem('📝 作业进度', this.homeworkProgress)
          this.DetailInfoItem('💬 教师反馈', this.teacherFeedback)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F8F9FA')
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }

  @Builder
  InfoItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(10)
        .fontColor('#999999')

      Text(value)
        .fontSize(12)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 2 })
    }
  }

  @Builder
  DetailInfoItem(label: string, value: string) {
    Column() {
      Text(label)
        .fontSize(11)
        .fontColor('#666666')

      Text(value)
        .fontSize(13)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
  }
}