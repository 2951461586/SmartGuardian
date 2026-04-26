/**
 * SmartGuardian - Parent Timeline Page
 * View student activity timeline including attendance, homework, messages
 */

import { Student } from '../../models/user';
import { TimelineItem } from '../../models/timeline';
import { TimelineService } from '../../services/api/timeline';
import { StudentService } from '../../services/api/auth';
import { StudentStore } from '../../stores/studentStore';
import {
  EmptyState,
  EmptyType,
  HeaderTheme,
  LoadingSize,
  LoadingState,
  PageHeader,
  SelectionSheet,
  TimelineEventListCard,
  TimelineEventViewModel,
  TimelineStudentSelectorCard
} from '../../components/common';
import { HarmonyColor } from '../../common/HarmonyDesign';

@Entry
@Component
struct ParentTimelinePage {
  build() {
    Stack() {
      ParentTimelinePageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct ParentTimelinePageContent {
  @State students: Student[] = [];
  @State selectedStudentId: number = 0;
  @State selectedStudentName: string = '';
  @State timelineEvents: TimelineEventViewModel[] = [];
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
        this.timelineEvents = this.convertToTimelineEvents(resp.data);
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

  convertToTimelineEvents(items: TimelineItem[]): TimelineEventViewModel[] {
    const events: TimelineEventViewModel[] = [];
    items.forEach((item: TimelineItem) => {
      const event: TimelineEventViewModel = {
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
      PageHeader({
        title: '学生动态',
        subtitle: '查看孩子的考勤、作业、通知和订单时间线。',
        showBack: true,
        onBackClick: (): void => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      if (this.isLoading) {
        LoadingState({
          loadingSize: LoadingSize.DEFAULT,
          fullscreen: false,
          message: '加载中...'
        })
      } else {
        Scroll() {
          Column() {
            TimelineStudentSelectorCard({
              selectedStudentName: this.selectedStudentName,
              onSelect: (): void => {
                this.showStudentPicker = true;
              }
            })
              .margin({ bottom: 12 })
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
      backgroundColor: HarmonyColor.surface,
      dragBar: true
    })
  }

  @Builder
  buildTimeline() {
    TimelineEventListCard({
      events: this.timelineEvents,
      emptyTitle: '暂无动态记录',
      emptyDescription: '当前学生还没有新的时间线内容。'
    })
  }

  @Builder
  buildStudentPicker() {
    SelectionSheet({
      title: '选择学生',
      selectedValue: this.selectedStudentName,
      options: this.students.map((student: Student) => student.name),
      onSelect: (value: string): void => {
        const selected = this.students.find((student: Student) => student.name === value);
        if (selected) {
          this.handleStudentChange(selected);
        }
      }
    })
  }
}

