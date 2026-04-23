/**
 * SmartGuardian - Teacher Student Detail Page
 * Student overview for teacher flow
 */

import {
  Card,
  EmptyState,
  EmptyType,
  HeaderTheme,
  InfoCard,
  InfoItem,
  LoadingSize,
  LoadingState,
  PageHeader,
  SectionHeader
} from '../../components/common';
import { AttendanceRecord } from '../../models/attendance';
import { HomeworkTask } from '../../models/homework';
import { Student } from '../../models/user';
import { AttendanceService } from '../../services/api/attendance';
import { StudentService } from '../../services/api/auth';
import { HomeworkService } from '../../services/api/homework';
import { LogUtil } from '../../utils/LogUtil';

interface TeacherStudentDetailParams {
  studentId?: number | string;
}

@Entry
@Component
struct TeacherStudentDetailPage {
  @State studentId: number = 0;
  @State studentDetail: Student | null = null;
  @State recentAttendance: AttendanceRecord[] = [];
  @State homeworkTasks: HomeworkTask[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';

  async aboutToAppear() {
    const params = this.getUIContext().getRouter().getParams() as TeacherStudentDetailParams;
    const rawStudentId = params.studentId;
    this.studentId = rawStudentId ? Number(rawStudentId) : 0;
    await this.loadStudentContext();
  }

  private async loadStudentContext(): Promise<void> {
    if (this.studentId <= 0) {
      this.errorMessage = '未获取到学生编号';
      this.isLoading = false;
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const detailPromise = StudentService.getStudentDetail(this.studentId);
      const attendancePromise = AttendanceService.getAttendanceList({
        studentId: this.studentId,
        pageNum: 1,
        pageSize: 8
      });
      const homeworkPromise = HomeworkService.getTasks({
        studentId: this.studentId,
        pageNum: 1,
        pageSize: 20
      });

      const detailResp = await detailPromise;
      const attendanceResp = await attendancePromise;
      const homeworkResp = await homeworkPromise;

      if (detailResp.code !== 0 || !detailResp.data) {
        this.studentDetail = null;
        this.recentAttendance = [];
        this.homeworkTasks = [];
        this.errorMessage = detailResp.message ? detailResp.message : '学生详情加载失败';
        return;
      }

      this.studentDetail = detailResp.data;
      this.recentAttendance = attendanceResp.code === 0 && attendanceResp.data
        ? attendanceResp.data.list ?? []
        : [];
      this.homeworkTasks = homeworkResp.code === 0 && homeworkResp.data
        ? homeworkResp.data.list ?? []
        : [];
    } catch (error) {
      LogUtil.error('TeacherStudentDetailPage', `Load student context failed: ${String(error)}`);
      this.studentDetail = null;
      this.recentAttendance = [];
      this.homeworkTasks = [];
      this.errorMessage = '学生详情加载失败，请稍后重试';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      PageHeader({
        title: this.studentDetail ? `${this.studentDetail.name} · 学生详情` : '学生详情',
        subtitle: this.studentDetail
          ? `${this.studentDetail.className ? this.studentDetail.className : '未配置班级'} · 扫码后快速查看学生状态`
          : '教师可在这里查看学生信息、考勤表现和联系入口。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      if (this.isLoading) {
        LoadingState({
          loadingSize: LoadingSize.DEFAULT,
          message: '正在整理学生上下文...'
        })
      } else if (!this.studentDetail) {
        EmptyState({
          type: EmptyType.DEFAULT,
          customTitle: '学生详情暂不可用',
          customDescription: this.errorMessage ? this.errorMessage : '请返回后重新扫码进入。'
        })
      } else {
        Scroll() {
          Column() {
            SectionHeader({
              title: '学生概览',
              subtitle: '把扫码结果、近期考勤和作业跟进统一收敛到一个视图。'
            })

            InfoCard({
              items: this.getBasicItems(),
              columns: 2
            })

            Card({
              title: '近期考勤',
              subtitle: '便于老师快速判断学生当前托管状态',
              content: this.buildAttendanceContent
            })

            Card({
              title: '作业跟进',
              subtitle: `当前累计 ${this.homeworkTasks.length} 条任务`,
              content: this.buildHomeworkContent
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 24 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  private getBasicItems(): InfoItem[] {
    const student = this.studentDetail;
    if (!student) {
      return [];
    }

    const latestAttendance = this.getLatestAttendance();
    return [
      { label: '学生编号', value: student.studentNo },
      { label: '入口来源', value: '教师端扫码' },
      { label: '班级', value: student.className ? student.className : '--' },
      { label: '监护人', value: student.guardianName ? student.guardianName : '--' },
      { label: '联系电话', value: student.guardianMobile ? student.guardianMobile : '--' },
      { label: '最近状态', value: latestAttendance ? this.getAttendanceStatusText(latestAttendance.status, latestAttendance.abnormalFlag) : '暂无考勤' },
      { label: '健康备注', value: student.healthNotes ? student.healthNotes : '无' },
      { label: '完成作业', value: `${this.getCompletedHomeworkCount()}/${this.homeworkTasks.length}` }
    ];
  }

  @Builder
  private buildAttendanceContent() {
    if (this.recentAttendance.length === 0) {
      Text('暂无近期考勤记录。')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
    } else {
      Column() {
        Row() {
          this.buildMetric('已到场', `${this.getAttendanceCount('SIGNED_IN', 'SIGNED_OUT')}`)
          this.buildMetric('已签退', `${this.getAttendanceCount('SIGNED_OUT')}`)
          this.buildMetric('异常', `${this.getAbnormalCount()}`)
        }
        .width('100%')
        .margin({ bottom: 14 })

        ForEach(this.recentAttendance.slice(0, 4), (record: AttendanceRecord, index: number) => {
          this.buildAttendanceItem(record)
          if (index < Math.min(this.recentAttendance.length, 4) - 1) {
            Divider()
              .color($r('app.color.divider'))
              .margin({ top: 12, bottom: 12 })
          }
        })
      }
      .width('100%')
    }
  }

  @Builder
  private buildHomeworkContent() {
    if (this.homeworkTasks.length === 0) {
      Text('当前暂无作业任务，可从教师作业页继续跟进。')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
    } else {
      Column() {
        Row() {
          this.buildMetric('待处理', `${this.getPendingHomeworkCount()}`)
          this.buildMetric('已完成', `${this.getCompletedHomeworkCount()}`)
          this.buildMetric('已确认', `${this.getConfirmedHomeworkCount()}`)
        }
        .width('100%')
        .margin({ bottom: 14 })

        ForEach(this.homeworkTasks.slice(0, 3), (task: HomeworkTask, index: number) => {
          this.buildHomeworkItem(task)
          if (index < Math.min(this.homeworkTasks.length, 3) - 1) {
            Divider()
              .color($r('app.color.divider'))
              .margin({ top: 12, bottom: 12 })
          }
        })
      }
      .width('100%')
    }
  }

  @Builder
  private buildMetric(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildAttendanceItem(record: AttendanceRecord) {
    Row() {
      Column() {
        Text(record.attendanceDate ? record.attendanceDate : this.formatDateTime(record.createdAt))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(`签到 ${this.formatTime(record.signInTime)} · 签退 ${this.formatTime(record.signOutTime)}`)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.getAttendanceStatusText(record.status, record.abnormalFlag))
        .fontSize(12)
        .fontColor(this.getAttendanceStatusColor(record.status, record.abnormalFlag))
    }
    .width('100%')
  }

  @Builder
  private buildHomeworkItem(task: HomeworkTask) {
    Row() {
      Column() {
        Text(task.subject ? `${task.subject} · ${task.content}` : task.content)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(2)

        Text(task.taskDate ? task.taskDate : this.formatDateTime(task.createdAt))
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.getHomeworkStatusText(task.status))
        .fontSize(12)
        .fontColor(this.getHomeworkStatusColor(task.status))
    }
    .width('100%')
  }

  private getLatestAttendance(): AttendanceRecord | null {
    if (this.recentAttendance.length === 0) {
      return null;
    }
    return this.recentAttendance[0];
  }

  private getAttendanceCount(...statuses: string[]): number {
    return this.recentAttendance.filter((record: AttendanceRecord) => statuses.indexOf(record.status) > -1).length;
  }

  private getAbnormalCount(): number {
    return this.recentAttendance.filter((record: AttendanceRecord) => record.abnormalFlag).length;
  }

  private getPendingHomeworkCount(): number {
    return this.homeworkTasks.filter((task: HomeworkTask) => task.status === 'PENDING' || task.status === 'IN_PROGRESS').length;
  }

  private getCompletedHomeworkCount(): number {
    return this.homeworkTasks.filter((task: HomeworkTask) => task.status === 'COMPLETED' || task.status === 'CONFIRMED').length;
  }

  private getConfirmedHomeworkCount(): number {
    return this.homeworkTasks.filter((task: HomeworkTask) => task.status === 'CONFIRMED').length;
  }

  private getAttendanceStatusText(status: string, abnormalFlag?: boolean): string {
    if (abnormalFlag) {
      return '异常关注';
    }
    if (status === 'SIGNED_OUT') {
      return '已签退';
    }
    if (status === 'SIGNED_IN') {
      return '已签到';
    }
    if (status === 'ABSENT') {
      return '缺勤';
    }
    return '未签到';
  }

  private getAttendanceStatusColor(status: string, abnormalFlag?: boolean): string {
    if (abnormalFlag) {
      return '#D97706';
    }
    if (status === 'SIGNED_OUT' || status === 'SIGNED_IN') {
      return '#15803D';
    }
    if (status === 'ABSENT') {
      return '#DC2626';
    }
    return '#7A879A';
  }

  private getHomeworkStatusText(status: string): string {
    if (status === 'COMPLETED') {
      return '已完成';
    }
    if (status === 'CONFIRMED') {
      return '已确认';
    }
    if (status === 'IN_PROGRESS') {
      return '辅导中';
    }
    return '待处理';
  }

  private getHomeworkStatusColor(status: string): string {
    if (status === 'COMPLETED' || status === 'CONFIRMED') {
      return '#15803D';
    }
    if (status === 'IN_PROGRESS') {
      return '#1F5EFF';
    }
    return '#D97706';
  }

  private formatTime(value?: string): string {
    if (!value) {
      return '--';
    }
    if (value.indexOf('T') > -1) {
      return value.substring(11, 16);
    }
    if (value.length >= 5) {
      return value.substring(0, 5);
    }
    return value;
  }

  private formatDateTime(value?: string): string {
    if (!value) {
      return '--';
    }
    if (value.indexOf('T') > -1) {
      return value.substring(0, 16).replace('T', ' ');
    }
    return value;
  }
}
