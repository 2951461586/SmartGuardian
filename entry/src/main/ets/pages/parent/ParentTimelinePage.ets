/**
 * SmartGuardian - Parent Timeline Page
 * View student activity timeline including attendance, homework, messages
 */

import { Student } from '../../models/user';
import { TimelineItem } from '../../models/timeline';
import { TimelineService } from '../../services/api/timeline';
import { StudentService } from '../../services/api/auth';
import { StudentStore } from '../../stores/studentStore';

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
export struct ParentTimelinePage {
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
    const cachedStudents = StudentStore.getStudentList();
    if (cachedStudents.length > 0) {
      this.applyStudents(cachedStudents);
      this.loadTimeline();
      return;
    }

    this.isLoading = true;
    StudentService.getStudents({ pageNum: 1, pageSize: 100 })
      .then((response) => {
        if (response.code === 0 && response.data) {
          const students = response.data.list ?? [];
          StudentStore.setStudentList(students);
          if (students.length > 0) {
            this.applyStudents(students);
            this.loadTimeline();
            return;
          }
        }

        this.students = [];
        this.timelineEvents = [];
        this.isLoading = false;
      })
      .catch(() => {
        console.error('Load students failed');
        this.students = [];
        this.timelineEvents = [];
        this.isLoading = false;
      });
  }

  private applyStudents(students: Student[]) {
    this.students = students;
    const currentStudent = StudentStore.getCurrentStudent();
    if (currentStudent && students.some((student: Student) => student.id === currentStudent.id)) {
      this.selectedStudentId = currentStudent.id;
      this.selectedStudentName = currentStudent.name;
    } else {
      this.selectedStudentId = students[0].id;
      this.selectedStudentName = students[0].name;
      StudentStore.setCurrentStudent(students[0]);
    }
  }

  async loadTimeline() {
    if (!this.selectedStudentId) {
      this.timelineEvents = [];
      this.isLoading = false;
      return;
    }

    this.isLoading = true;
    try {
      const resp = await TimelineService.getStudentTimeline(this.selectedStudentId);
      if (resp.code === 0 && resp.data) {
        const timelineItems = Array.isArray(resp.data) ? resp.data : (resp.data.list ?? []);
        this.timelineEvents = this.convertToTimelineEvents(timelineItems as TimelineItem[]);
      } else {
        this.timelineEvents = [];
      }
    } catch (error) {
      console.error('Failed to load timeline:', String(error));
      this.timelineEvents = [];
    } finally {
      this.isLoading = false;
    }
  }

  convertToTimelineEvents(items: TimelineItem[]): TimelineEvent[] {
    const events: TimelineEvent[] = [];
    items.forEach((item: TimelineItem) => {
      const event: TimelineEvent = {
        id: item.id,
        studentId: item.studentId,
        eventType: item.timelineType || 'MESSAGE',
        eventTime: item.timestamp || '',
        title: item.title,
        content: item.content,
        icon: this.getEventIcon(item.timelineType || 'MESSAGE')
      };
      events.push(event);
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

  handleStudentChange(student: Student) {
    this.selectedStudentId = student.id;
    this.selectedStudentName = student.name;
    this.showStudentPicker = false;
    StudentStore.setCurrentStudent(student);
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
    if (this.timelineEvents.length === 0) {
      Column() {
        Image($r('app.media.ic_empty'))
          .width(120)
          .height(120)
          .opacity(0.5)

        Text('暂无动态记录')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 16 })
      }
      .width('100%')
      .padding({ top: 40, bottom: 40 })
      .alignItems(HorizontalAlign.Center)
    } else {
      Column() {
        ForEach(this.timelineEvents, (event: TimelineEvent, index: number) => {
          Row() {
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
    if (!time) {
      return '';
    }
    return time.replace('T', ' ');
  }
}

