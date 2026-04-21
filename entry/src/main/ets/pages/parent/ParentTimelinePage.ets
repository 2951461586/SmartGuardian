/**
 * SmartGuardian - Parent Timeline Page
 * View student activity timeline including attendance, homework, messages
 */

import { Student } from '../../models/user';
import { TimelineItem } from '../../models/timeline';
import { TimelineService } from '../../services/api/timeline';
import { UserStore } from '../../stores/userStore';

interface TimelineEvent {
  id: number;
  studentId: number;
  eventType: 'ATTENDANCE' | 'HOMEWORK' | 'MESSAGE' | 'ORDER' | 'NOTE';
  eventTime: string;
  title: string;
  content: string;
  icon?: Resource;
}

@Entry
@Component
struct ParentTimelinePage {
  @State students: Student[] = [];
  @State selectedStudentId: number = 0;
  @State selectedStudentName: string = '';
  @State timelineEvents: TimelineEvent[] = [];
  @State isLoading: boolean = true;
  @State showStudentPicker: boolean = false;

  aboutToAppear() {
    this.loadStudents();
  }

  loadStudents() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.students = [
        { id: 1, studentNo: 'S001', name: '张小明', schoolId: 1, schoolName: '第一小学',
          classId: 1, className: '三年级1班', grade: '三年级', guardianUserId: userInfo.id, status: 'ACTIVE', createdAt: '', updatedAt: '' }
      ];
      if (this.students.length > 0) {
        this.selectedStudentId = this.students[0].id;
        this.selectedStudentName = this.students[0].name;
        this.loadTimeline();
      }
    }
  }

  async loadTimeline() {
    if (!this.selectedStudentId) return;

    this.isLoading = true;
    try {
      const resp = await TimelineService.getStudentTimeline(this.selectedStudentId);
      if (resp.code === 0 && resp.data) {
        // Handle both PageResponse and array
        if (Array.isArray(resp.data)) {
          this.timelineEvents = this.convertToTimelineEvents(resp.data as TimelineItem[]);
        } else {
          // Use mock data for demo
          this.timelineEvents = this.getMockTimeline();
        }
      } else {
        // Use mock data for demo
        this.timelineEvents = this.getMockTimeline();
      }
    } catch (error) {
      console.error('Failed to load timeline:', error);
      this.timelineEvents = this.getMockTimeline();
    } finally {
      this.isLoading = false;
    }
  }

  convertToTimelineEvents(items: TimelineItem[]): TimelineEvent[] {
    const events: TimelineEvent[] = [];
    items.forEach((item: TimelineItem) => {
      events.push({
        id: item.id,
        studentId: item.studentId,
        eventType: item.timelineType || 'MESSAGE',
        eventTime: item.timestamp || '',
        title: item.title,
        content: item.content,
        icon: this.getEventIcon(item.timelineType || 'MESSAGE')
      });
    });
    return events;
  }

  getEventIcon(eventType: string): Resource | undefined {
    switch (eventType) {
      case 'ATTENDANCE':
        return $r('app.media.ic_attendance');
      case 'HOMEWORK':
        return $r('app.media.ic_homework');
      case 'ORDER':
        return $r('app.media.ic_order');
      case 'NOTE':
      case 'MESSAGE':
      default:
        return $r('app.media.ic_message');
    }
  }

  getMockTimeline(): TimelineEvent[] {
    return [
      { id: 1, studentId: this.selectedStudentId, eventType: 'ATTENDANCE', eventTime: '2026-04-16 16:30:00', title: '已签退', content: '您的孩子已于16:30签退，由张女士接回', icon: $r('app.media.ic_attendance') },
      { id: 2, studentId: this.selectedStudentId, eventType: 'HOMEWORK', eventTime: '2026-04-16 15:30:00', title: '作业反馈', content: '数学作业已完成，正确率90%，需加强乘法运算', icon: $r('app.media.ic_homework') },
      { id: 3, studentId: this.selectedStudentId, eventType: 'ATTENDANCE', eventTime: '2026-04-16 14:00:00', title: '已签到', content: '您的孩子已于14:00签到，开始课后托管', icon: $r('app.media.ic_attendance') },
      { id: 4, studentId: this.selectedStudentId, eventType: 'ORDER', eventTime: '2026-04-15 10:00:00', title: '报名成功', content: '成功报名晚间托管服务，服务周期：2026-04-16 至 2026-05-15', icon: $r('app.media.ic_order') },
      { id: 5, studentId: this.selectedStudentId, eventType: 'HOMEWORK', eventTime: '2026-04-15 16:00:00', title: '作业反馈', content: '语文作业全部完成，书写工整，继续保持', icon: $r('app.media.ic_homework') }
    ];
  }

  handleStudentChange(student: Student) {
    this.selectedStudentId = student.id;
    this.selectedStudentName = student.name;
    this.showStudentPicker = false;
    this.loadTimeline();
  }

  build() {
    Column() {
      this.buildHeader()

      if (this.isLoading) {
        this.buildLoading()
      } else {
        Scroll() {
          Column() {
            this.buildStudentSelector()
            this.buildTimeline()
          }
          .width('100%')
          .padding($r('app.float.page_padding'))
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .bindSheet($$this.showStudentPicker, this.buildStudentPicker(), {
      height: 400,
      backgroundColor: Color.White,
      dragBar: true
    })
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .onClick(() => this.getUIContext().getRouter().back())

      Text('学生动态')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank()
        .width(24)
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor($r('app.color.primary'))
    .padding({ top: Number($r('app.float.status_bar_height')) + 10 })
  }

  @Builder
  buildLoading() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color($r('app.color.primary'))
      Text('加载中...')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildStudentSelector() {
    Row() {
      Text('当前学生：')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_secondary'))

      Text(this.selectedStudentName)
        .fontSize($r('app.float.text_primary_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary'))

      Image($r('app.media.ic_arrow_right'))
        .width($r('app.float.icon_small_size'))
        .height($r('app.float.icon_small_size'))
        .margin({ left: 4 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: 12 })
    .onClick(() => this.showStudentPicker = true)
  }

  @Builder
  buildTimeline() {
    Column() {
      ForEach(this.timelineEvents, (event: TimelineEvent, index: number) => {
        Row() {
          // Timeline line
          Column() {
            Circle()
              .width(12)
              .height(12)
              .fill($r('app.color.primary'))

            if (index < this.timelineEvents.length - 1) {
              Divider()
                .vertical(true)
                .height(60)
                .width(2)
                .color('#E0E0E0')
            }
          }
          .width(20)
          .alignItems(HorizontalAlign.Center)

          // Event card
          Column() {
            Row() {
              if (event.icon) {
                Image(event.icon)
                  .width($r('app.float.icon_small_size'))
                  .height($r('app.float.icon_small_size'))
              }

              Text(event.title)
                .fontSize($r('app.float.text_primary_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .margin({ left: 8 })
            }
            .width('100%')

            Text(event.content)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 8 })

            Text(this.formatTime(event.eventTime))
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 8 })
          }
          .layoutWeight(1)
          .padding($r('app.float.card_padding'))
          .backgroundColor(Color.White)
          .borderRadius($r('app.float.card_border_radius'))
          .margin({ left: 12 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .margin({ top: index === 0 ? 0 : 16 })
      })
    }
    .width('100%')
  }

  @Builder
  buildStudentPicker() {
    Column() {
      Text('选择学生')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .padding({ top: 16, bottom: 16 })

      ForEach(this.students, (student: Student) => {
        Row() {
          Column() {
            Text(student.name)
              .fontSize($r('app.float.text_primary_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))

            Text(`${student.schoolName || ''} ${student.className || ''}`)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          if (this.selectedStudentId === student.id) {
            Image($r('app.media.ic_home'))
              .width($r('app.float.icon_small_size'))
              .height($r('app.float.icon_small_size'))
          }
        }
        .width('100%')
        .padding($r('app.float.card_padding'))
        .onClick(() => this.handleStudentChange(student))
      })
    }
  }

  formatTime(time: string): string {
    return time.replace('T', ' ');
  }
}
