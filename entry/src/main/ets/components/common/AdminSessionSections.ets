import { HarmonyColor, HarmonyReport, harmonyShadowColor } from '../../common/HarmonyDesign';
import { SessionSchedule, SessionStudent, SessionWithStudents } from '../../models/service';
import { Card, StatCard } from './Card';
import { EmptyState, EmptyType } from './EmptyState';
import { SectionHeader } from './SectionHeader';
import { TabBar } from './TabBar';

@Component
export struct AdminSessionsOverviewCard {
  @Prop totalCount: number = 0;
  @Prop todayCount: number = 0;
  @Prop fullCount: number = 0;

  build() {
    Column() {
      SectionHeader({
        title: '班次概览',
        subtitle: '集中看清今日排班、满载情况和当前班次规模。'
      })

      Row() {
        StatCard({
          value: this.totalCount,
          label: '当前班次数',
          icon: $r('app.media.ic_session'),
          iconColor: HarmonyReport.accent
        })
        .layoutWeight(1)

        StatCard({
          value: this.todayCount,
          label: '今日班次',
          icon: $r('app.media.ic_clock'),
          iconColor: HarmonyReport.positive
        })
        .layoutWeight(1)
        .margin({ left: 12, right: 12 })

        StatCard({
          value: this.fullCount,
          label: '满载班次',
          icon: $r('app.media.ic_alert_center'),
          iconColor: HarmonyReport.caution
        })
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
  }
}

@Component
export struct AdminSessionsFilterCard {
  @Prop tabs: string[] = [];
  @Prop currentTab: number = 0;
  onAutoSchedule?: () => void;
  onTabChange?: (index: number) => void;

  build() {
    Card({
      title: '班次筛选',
      subtitle: '可按今日、满载和已结束状态快速查看排期压力。',
      actionText: '自动排班',
      onAction: this.onAutoSchedule,
      content: () => { this.buildContent() }
    })
  }

  @Builder
  private buildContent() {
    TabBar({
      tabs: this.tabs,
      currentIndex: this.currentTab,
      onTabChange: (index: number) => {
        if (this.onTabChange) {
          this.onTabChange(index);
        }
      }
    })
  }
}

@Component
export struct AdminSessionListItemCard {
  @Prop session: SessionSchedule = {} as SessionSchedule;
  @Prop statusText: string = '';
  @Prop statusColor: string = HarmonyReport.accent;
  onOpenStudents?: (sessionId: number) => void;

  build() {
    Column() {
      Row() {
        Column() {
          Text(`${this.session.serviceProductName ? this.session.serviceProductName : '托管班次'} · ${this.session.sessionNo ? this.session.sessionNo : this.session.id}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(`${this.session.sessionDate} ${this.session.startTime} - ${this.session.endTime}`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.statusText)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.statusColor)
      }
      .width('100%')

      Row() {
        AdminSessionMetricColumn({
          label: '当前人数',
          value: `${Number(this.session.currentCount ? this.session.currentCount : 0)}`
        })
        AdminSessionMetricColumn({
          label: '最大容量',
          value: `${Number(this.session.maxCapacity ? this.session.maxCapacity : this.session.capacity ? this.session.capacity : 0)}`
        })
        AdminSessionMetricColumn({
          label: '教师',
          value: this.session.teacherName ? this.session.teacherName : '--'
        })
      }
      .width('100%')
      .margin({ top: 14 })

      Text(`地点：${this.session.location ? this.session.location : '--'}`)
        .width('100%')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 12 })

      Text('查看学生名单')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary'))
        .margin({ top: 12 })
        .onClick(() => {
          if (this.onOpenStudents) {
            this.onOpenStudents(this.session.id);
          }
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(HarmonyColor.surface)
    .borderRadius(20)
    .border({
      width: 1,
      color: HarmonyColor.line,
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: 4
    })
  }
}

@Component
export struct AdminSessionStudentsSheet {
  @Prop sessionDetail: SessionWithStudents | null = null;
  @Prop studentItems: SessionStudent[] = [];

  build() {
    Column() {
      if (this.sessionDetail) {
        Text(this.sessionDetail.serviceProductName ? this.sessionDetail.serviceProductName : '班次学生名单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ top: 8, bottom: 8 })

        Text(`${this.sessionDetail.sessionDate} · ${this.sessionDetail.startTime} - ${this.sessionDetail.endTime}`)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ bottom: 16 })

        if (this.studentItems.length === 0) {
          EmptyState({
            type: EmptyType.DEFAULT,
            customTitle: '暂无学生名单',
            customDescription: '当前班次还没有学生报名或签到记录。'
          })
        } else {
          List() {
            ForEach(this.studentItems, (student: SessionStudent) => {
              ListItem() {
                Row() {
                  Column() {
                    Text(student.studentName)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.text_primary'))

                    Text(`学号：${student.studentNo}`)
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Text(student.attendanceStatus)
                    .fontSize(12)
                    .fontColor($r('app.color.primary'))
                }
                .width('100%')
                .padding({ top: 10, bottom: 10 })
              }
            }, (student: SessionStudent) => `${student.studentId}`)
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 0 })
          .scrollBar(BarState.Off)
        }
      } else {
        Text('暂无班次详情')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}

@Component
struct AdminSessionMetricColumn {
  @Prop label: string = '';
  @Prop value: string = '';

  build() {
    Column() {
      Text(this.value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Text(this.label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
}
