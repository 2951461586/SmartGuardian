/**
 * SmartGuardian - Admin Student Detail Page
 * Student profile detail page for admin flow
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
import { GuardianRelation, Student } from '../../models/user';
import { AttendanceService } from '../../services/api/attendance';
import { StudentService } from '../../services/api/auth';
import { LogUtil } from '../../utils/LogUtil';

interface StudentDetailParams {
  studentId?: number | string;
}

@Entry
@Component
struct AdminStudentDetailPage {
  @State studentId: number = 0;
  @State studentDetail: Student | null = null;
  @State guardians: GuardianRelation[] = [];
  @State recentAttendance: AttendanceRecord[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';

  async aboutToAppear() {
    const params = this.getUIContext().getRouter().getParams() as StudentDetailParams;
    const rawStudentId = params.studentId;
    this.studentId = rawStudentId ? Number(rawStudentId) : 0;
    await this.loadStudentProfile();
  }

  private async loadStudentProfile(): Promise<void> {
    if (this.studentId <= 0) {
      this.errorMessage = '未获取到学生编号';
      this.isLoading = false;
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const detailPromise = StudentService.getStudentDetail(this.studentId);
      const guardianPromise = StudentService.getGuardians(this.studentId);
      const attendancePromise = AttendanceService.getAttendanceList({
        studentId: this.studentId,
        pageNum: 1,
        pageSize: 10
      });

      const detailResp = await detailPromise;
      const guardianResp = await guardianPromise;
      const attendanceResp = await attendancePromise;

      if (detailResp.code !== 0 || !detailResp.data) {
        this.studentDetail = null;
        this.guardians = [];
        this.recentAttendance = [];
        this.errorMessage = detailResp.message ? detailResp.message : '学生详情加载失败';
        return;
      }

      this.studentDetail = detailResp.data;
      this.guardians = guardianResp.code === 0 && guardianResp.data ? guardianResp.data : [];
      this.recentAttendance = attendanceResp.code === 0 && attendanceResp.data
        ? attendanceResp.data.list ?? []
        : [];
    } catch (error) {
      LogUtil.error('AdminStudentDetailPage', `Load student profile failed: ${String(error)}`);
      this.studentDetail = null;
      this.guardians = [];
      this.recentAttendance = [];
      this.errorMessage = '学生详情加载失败，请稍后重试';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      PageHeader({
        title: this.studentDetail ? `${this.studentDetail.name} · 学生档案` : '学生档案详情',
        subtitle: this.studentDetail
          ? `${this.studentDetail.grade ? this.studentDetail.grade : '未配置年级'} · ${this.studentDetail.className ? this.studentDetail.className : '未配置班级'}`
          : '查看学生基础资料、监护关系与近期考勤信息。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY,
        rightContent: this.buildEditAction
      })

      if (this.isLoading) {
        LoadingState({
          loadingSize: LoadingSize.DEFAULT,
          message: '正在加载学生档案...'
        })
      } else if (!this.studentDetail) {
        EmptyState({
          type: EmptyType.DEFAULT,
          customTitle: '学生详情暂不可用',
          customDescription: this.errorMessage ? this.errorMessage : '请返回列表后重试。'
        })
      } else {
        Scroll() {
          Column() {
            SectionHeader({
              title: '档案概览',
              subtitle: '统一查看学生基础信息、监护关系与近期考勤。'
            })

            InfoCard({
              items: this.getBasicItems(),
              columns: 2
            })

            Card({
              title: '监护关系',
              subtitle: `当前已绑定 ${this.guardians.length} 位监护人`,
              content: this.buildGuardianContent
            })

            Card({
              title: '近期考勤',
              subtitle: `近 ${this.recentAttendance.length} 条记录摘要`,
              content: this.buildAttendanceContent
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

  @Builder
  private buildEditAction() {
    Text('编辑')
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.White)
      .onClick(() => {
        if (this.studentId > 0) {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/admin/AdminStudentEditPage',
            params: { studentId: this.studentId }
          });
        }
      })
  }

  private getBasicItems(): InfoItem[] {
    const student = this.studentDetail;
    if (!student) {
      return [];
    }

    return [
      { label: '学生编号', value: student.studentNo },
      { label: '学生状态', value: this.getStudentStatusText(student.status) },
      { label: '学校', value: student.schoolName ? student.schoolName : `学校ID ${student.schoolId}` },
      { label: '年级班级', value: `${student.grade ? student.grade : '--'} / ${student.className ? student.className : '--'}` },
      { label: '监护人', value: student.guardianName ? student.guardianName : '--' },
      { label: '联系电话', value: student.guardianMobile ? student.guardianMobile : '--' },
      { label: '健康备注', value: student.healthNotes ? student.healthNotes : '无' },
      { label: '最近更新', value: this.formatDateTime(student.updatedAt) }
    ];
  }

  @Builder
  private buildGuardianContent() {
    if (this.guardians.length === 0) {
      Text('当前暂无监护关系数据，可在学生维护页继续补充。')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
    } else {
      Column() {
        ForEach(this.guardians, (guardian: GuardianRelation, index: number) => {
          this.buildGuardianItem(guardian)
          if (index < this.guardians.length - 1) {
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
  private buildAttendanceContent() {
    if (this.recentAttendance.length === 0) {
      Text('暂无近期考勤记录。')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
    } else {
      Column() {
        Row() {
          this.buildAttendanceMetric('已签到', `${this.getAttendanceCount('SIGNED_IN', 'SIGNED_OUT')}`)
          this.buildAttendanceMetric('已签退', `${this.getAttendanceCount('SIGNED_OUT')}`)
          this.buildAttendanceMetric('异常', `${this.getAbnormalCount()}`)
        }
        .width('100%')
        .margin({ bottom: 14 })

        ForEach(this.recentAttendance.slice(0, 5), (record: AttendanceRecord, index: number) => {
          this.buildAttendanceItem(record)
          if (index < Math.min(this.recentAttendance.length, 5) - 1) {
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
  private buildGuardianItem(guardian: GuardianRelation) {
    Row() {
      Column() {
        Text(this.getGuardianRelationText(guardian.relation))
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(guardian.isPrimary ? '主监护人' : '辅助监护人')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text(guardian.authorizedPickup ? '已授权接送' : '未授权接送')
          .fontSize(12)
          .fontColor(guardian.authorizedPickup ? '#15803D' : '#D97706')

        Text(guardian.pickupCode ? guardian.pickupCode : '--')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
  }

  @Builder
  private buildAttendanceMetric(label: string, value: string) {
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

  private getStudentStatusText(status: string): string {
    if (status === 'ACTIVE') {
      return '在读';
    }
    if (status === 'GRADUATED') {
      return '已毕业';
    }
    if (status === 'INACTIVE') {
      return '已停用';
    }
    return status;
  }

  private getGuardianRelationText(relation: string): string {
    if (relation === 'FATHER') {
      return '父亲';
    }
    if (relation === 'MOTHER') {
      return '母亲';
    }
    if (relation === 'GRANDPA') {
      return '祖父';
    }
    if (relation === 'GRANDMA') {
      return '祖母';
    }
    return '其他监护人';
  }

  private getAttendanceCount(...statuses: string[]): number {
    return this.recentAttendance.filter((record: AttendanceRecord) => statuses.indexOf(record.status) > -1).length;
  }

  private getAbnormalCount(): number {
    return this.recentAttendance.filter((record: AttendanceRecord) => record.abnormalFlag).length;
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
