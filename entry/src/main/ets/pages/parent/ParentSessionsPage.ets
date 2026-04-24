/**
 * SmartGuardian - Parent Sessions Page
 * View student's class sessions
 */

import { SessionSchedule } from '../../models/service';
import { SessionService } from '../../services/api/service';
import { LoadingState, LoadingSize, EmptyState, EmptyType } from '../../components/common';
import { formatDate, formatTime } from '../../utils/date';

@Entry
@Component
export struct ParentSessionsPage {
  @State sessions: SessionSchedule[] = [];
  @State isLoading: boolean = true;
  @State selectedDate: string = '';

  async aboutToAppear() {
    this.selectedDate = formatDate(new Date());
    await this.loadSessions();
  }

  async loadSessions() {
    this.isLoading = true;
    try {
      const response = await SessionService.getSessions({
        sessionDate: this.selectedDate
      });
      if (response.code === 0 && response.data) {
        this.sessions = response.data;
      }
    } catch (error) {
      console.error('Failed to load sessions:', error);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('←')
            .fontSize(20)
            .fontColor(Color.White)
        }
        .width(36)
        .height(36)
        .backgroundColor('#1AFFFFFF')
        .onClick(() => this.getUIContext().getRouter().back())

        Text('班次安排')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(36)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .linearGradient({
        angle: 135,
        colors: [['#4F7CFF', 0], ['#7B68EE', 1]]
      })

      Row() {
        Text('日期: ')
          .fontSize(14)
          .fontColor('#666666')
        
        Text(this.selectedDate)
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F5F5F5')

      if (this.isLoading) {
        Column() {
          LoadingState({ loadingSize: LoadingSize.LARGE })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.sessions.length === 0) {
        Column() {
          EmptyState({ type: EmptyType.DEFAULT, customTitle: '暂无班次安排' })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.sessions, (session: SessionSchedule) => {
            ListItem() {
              this.SessionCard(session)
            }
            .margin({ top: 8 })
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  SessionCard(session: SessionSchedule) {
    Column() {
      Row() {
        Text(session.serviceProductName ?? '托管班次')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        Text(`${session.currentCount ?? 0}名学生`)
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')

      Row() {
        Text(`${formatTime(session.startTime)} - ${formatTime(session.endTime)}`)
          .fontSize(14)
          .fontColor('#666666')
        
        Blank()

        if (session.status === 'ONGOING') {
          Text('进行中')
            .fontSize(12)
            .fontColor('#52C41A')
            .backgroundColor('#F6FFED')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        } else if (session.status === 'ENDED') {
          Text('已结束')
            .fontSize(12)
            .fontColor('#999999')
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        } else {
          Text('未开始')
            .fontSize(12)
            .fontColor('#4F7CFF')
            .backgroundColor('#E6F0FF')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        }
      }
      .width('100%')
      .margin({ top: 8 })

      if (session.teacherName) {
        Row() {
          Text(`教师: ${session.teacherName}`)
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .margin({ top: 4 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }
}

