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
  SectionHeader,
  StudentAttendanceMetricViewModel,
  StudentAttendanceMetricsCard,
  StudentAttendanceStatusChip,
  StudentGuardianItemCard,
  StudentGuardianViewModel
} from '../../components/common';
import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import { RouteUrls } from '../../constants/app.constants';
import { AttendanceRecord } from '../../models/attendance';
import { GuardianRelation, Student } from '../../models/user';
import { AttendanceService } from '../../services/api/attendance';
import { StudentService } from '../../services/api/auth';
import { LazyArrayDataSource } from '../../utils/LazyArrayDataSource';
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

  private guardianDataSource: LazyArrayDataSource<GuardianRelation> = new LazyArrayDataSource<GuardianRelation>();
  private attendanceDataSource: LazyArrayDataSource<AttendanceRecord> = new LazyArrayDataSource<AttendanceRecord>();

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
        this.guardianDataSource.clear();
        this.attendanceDataSource.clear();
        this.errorMessage = detailResp.message ? detailResp.message : '学生详情加载失败';
        return;
      }

      this.studentDetail = detailResp.data;
      this.guardians = guardianResp.code === 0 && guardianResp.data ? guardianResp.data : [];
      this.recentAttendance = attendanceResp.code === 0 && attendanceResp.data
        ? attendanceResp.data.list ?? []
        : [];
      this.guardianDataSource.setItems(this.guardians);
      this.attendanceDataSource.setItems(this.recentAttendance.slice(0, 5));
    } catch (error) {
      LogUtil.error('AdminStudentDetailPage', `Load student profile failed: ${String(error)}`);
      this.studentDetail = null;
      this.guardians = [];
      this.recentAttendance = [];
      this.guardianDataSource.clear();
      this.attendanceDataSource.clear();
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
        this.buildPageList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildPageList() {
    List() {
      ListItem() {
        SectionHeader({
          title: '档案概览',
          subtitle: '统一查看学生基础信息、监护关系与近期考勤。'
        })
      }

      ListItem() {
        InfoCard({
          items: this.getBasicItems(),
          columns: 2
        })
      }

      ListItem() {
        this.buildGuardianCard()
      }

      ListItem() {
        this.buildAttendanceCard()
      }
    }
    .width('100%')
    .layoutWeight(1)
    .divider({ strokeWidth: 0 })
    .padding({ left: 16, right: 16, top: 16, bottom: 24 })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .cachedCount(8)
  }

  @Builder
  private buildEditAction() {
    Text('编辑')
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(HarmonyColor.textInverse)
      .onClick(() => {
        if (this.studentId > 0) {
          this.getUIContext().getRouter().pushUrl({
            url: RouteUrls.ADMIN_STUDENT_EDIT,
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

  private getGuardianItem(guardian: GuardianRelation): StudentGuardianViewModel {
    return {
      id: guardian.id,
      relationLabel: this.getGuardianRelationText(guardian.relation),
      roleLabel: guardian.isPrimary ? '主监护人' : '辅助监护人',
      pickupLabel: guardian.authorizedPickup ? '已授权接送' : '未授权接送',
      pickupCode: guardian.pickupCode ? guardian.pickupCode : '--'
    };
  }

  private getAttendanceMetrics(): StudentAttendanceMetricViewModel[] {
    return [
      { label: '已签到', value: `${this.getAttendanceCount('SIGNED_IN', 'SIGNED_OUT')}` },
      { label: '已签退', value: `${this.getAttendanceCount('SIGNED_OUT')}` },
      { label: '异常', value: `${this.getAbnormalCount()}` }
    ];
  }

  @Builder
  private buildGuardianCard() {
    Card({
      title: '监护关系',
      subtitle: `当前已绑定 ${this.guardians.length} 位监护人`,
      content: this.buildGuardianContent
    })
  }

  @Builder
  private buildGuardianContent() {
    if (this.guardians.length === 0) {
      Text('当前暂无监护关系数据，可在学生维护页继续补充。')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
    } else {
      List() {
        LazyForEach(this.guardianDataSource, (guardian: GuardianRelation, index?: number) => {
          ListItem() {
            Column() {
              StudentGuardianItemCard({
                item: this.getGuardianItem(guardian)
              })

              if (index !== undefined && index < this.guardians.length - 1) {
                Divider()
                  .color($r('app.color.divider'))
                  .margin({ top: 12, bottom: 12 })
              }
            }
            .width('100%')
          }
        }, (guardian: GuardianRelation) => `${guardian.id}`)
      }
      .width('100%')
      .height(this.getGuardianListHeight())
      .divider({ strokeWidth: 0 })
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  private buildAttendanceCard() {
    Card({
      title: '近期考勤',
      subtitle: `近 ${this.recentAttendance.length} 条记录摘要`,
      content: this.buildAttendanceContent
    })
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
        StudentAttendanceMetricsCard({
          metrics: this.getAttendanceMetrics()
        })

        List() {
          LazyForEach(this.attendanceDataSource, (record: AttendanceRecord, index?: number) => {
            ListItem() {
              Column() {
                this.buildAttendanceItem(record)
                if (index !== undefined && index < Math.min(this.recentAttendance.length, 5) - 1) {
                  Divider()
                    .color($r('app.color.divider'))
                    .margin({ top: 12, bottom: 12 })
                }
              }
              .width('100%')
            }
          }, (record: AttendanceRecord) => `${record.id}`)
        }
        .width('100%')
        .height(this.getAttendanceListHeight())
        .divider({ strokeWidth: 0 })
        .scrollBar(BarState.Off)
        .margin({ top: 14 })
      }
      .width('100%')
    }
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

      StudentAttendanceStatusChip({
        text: this.getAttendanceStatusText(record.status, record.abnormalFlag),
        color: this.getAttendanceStatusColor(record.status, record.abnormalFlag)
      })
    }
    .width('100%')
  }

  private getGuardianListHeight(): number {
    return this.guardians.length * 64 + Math.max(0, this.guardians.length - 1) * 24;
  }

  private getAttendanceListHeight(): number {
    const visibleCount = Math.min(this.recentAttendance.length, 5);
    return visibleCount * 48 + Math.max(0, visibleCount - 1) * 24;
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
      return HarmonyReport.caution;
    }
    if (status === 'SIGNED_OUT' || status === 'SIGNED_IN') {
      return HarmonyReport.positive;
    }
    if (status === 'ABSENT') {
      return HarmonyReport.danger;
    }
    return HarmonyColor.textTertiary;
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
