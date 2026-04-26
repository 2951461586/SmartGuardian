/**
 * SmartGuardian - Parent Leave Page
 * Parent leave request page
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import {
  Card,
  DatePickerSheet,
  HeaderTheme,
  LeaveDateSummaryCard,
  LeaveStudentOption,
  LeaveStudentSelectorCard,
  LeaveTypeSelectorCard,
  PageHeader,
  SectionHeader
} from '../../components/common';
import { LeaveRequest } from '../../models/attendance';
import { Student } from '../../models/user';
import { AttendanceService } from '../../services/api/attendance';
import { StudentStore } from '../../stores/studentStore';
import { LazyArrayDataSource } from '../../utils/LazyArrayDataSource';
import { DateUtils } from '../../utils/dateUtils';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';
import { LogUtil } from '../../utils/LogUtil';

@Entry
@Component
struct ParentLeavePage {
  @State isLoading: boolean = false;
  @State leaveDate: Date = new Date();
  @State leaveType: 'SICK' | 'PERSONAL' | 'FAMILY' | 'OTHER' = 'SICK';
  @State reason: string = '';
  @State attachments: string[] = [];
  @State selectedStudentId: number = 0;
  @State availableStudents: LeaveStudentOption[] = [];
  @State showDatePicker: boolean = false;

  private attachmentDataSource: LazyArrayDataSource<string> = new LazyArrayDataSource<string>();

  aboutToAppear() {
    ErrorHandlerUtil.setUIContext(this.getUIContext());
    this.loadAvailableStudents();
    this.attachmentDataSource.setItems(this.attachments);
  }

  private loadAvailableStudents(): void {
    const storedStudents = StudentStore.getStudentList();
    const mappedStudents: LeaveStudentOption[] = [];
    storedStudents.forEach((student: Student) => {
      const item: LeaveStudentOption = {
        id: student.id,
        name: student.name
      };
      mappedStudents.push(item);
    });

    if (mappedStudents.length > 0) {
      this.availableStudents = mappedStudents;
    } else {
      this.availableStudents = [
        { id: 1, name: '王小明' },
        { id: 2, name: '李小雪' }
      ];
    }

    if (this.availableStudents.length > 0 && this.selectedStudentId === 0) {
      this.selectedStudentId = this.availableStudents[0].id;
    }
  }

  async submitLeave() {
    if (this.isLoading) {
      return;
    }
    if (!this.selectedStudentId) {
      ErrorHandlerUtil.showErrorToast('请选择学生');
      return;
    }
    if (!ErrorHandlerUtil.validateRequired(this.reason, '请假原因')) {
      return;
    }

    this.isLoading = true;
    try {
      const request: LeaveRequest = {
        studentId: this.selectedStudentId,
        leaveDate: DateUtils.formatDate(this.leaveDate),
        leaveType: this.leaveType,
        reason: this.reason.trim(),
        attachments: this.attachments.length > 0 ? [...this.attachments] : undefined
      };

      const response = await AttendanceService.submitLeave(request);
      if (response.code === 0) {
        ErrorHandlerUtil.showSuccessToast('请假申请已提交');
        this.getUIContext().getRouter().back();
        return;
      }

      ErrorHandlerUtil.showErrorToast(response.message ? response.message : '请假申请提交失败');
    } catch (error) {
      LogUtil.error('ParentLeavePage', `Submit leave failed: ${String(error)}`);
      ErrorHandlerUtil.showErrorToast('请假申请提交失败，请稍后重试');
    } finally {
      this.isLoading = false;
    }
  }

  private selectAttachment(): void {
    if (this.attachments.length >= 3) {
      ErrorHandlerUtil.showErrorToast('最多上传 3 个附件');
      return;
    }

    const attachmentName = `请假证明_${this.attachments.length + 1}_${Date.now().toString().slice(-4)}.jpg`;
    this.attachments = [...this.attachments, attachmentName];
    this.attachmentDataSource.setItems(this.attachments);
    ErrorHandlerUtil.showSuccessToast('已添加附件占位，后续可接入系统图片选择器');
  }

  private removeAttachment(index: number): void {
    if (index < 0) {
      return;
    }
    const nextAttachments = [...this.attachments];
    nextAttachments.splice(index, 1);
    this.attachments = nextAttachments;
    this.attachmentDataSource.setItems(this.attachments);
  }

  build() {
    Column() {
      PageHeader({
        title: '请假申请',
        subtitle: '提交请假日期、原因和附件材料，机构会尽快处理。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      this.buildPageList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .bindSheet($$this.showDatePicker, this.buildDatePickerSheet(), {
      height: 420,
      backgroundColor: HarmonyColor.surface,
      dragBar: true
    })
  }

  @Builder
  private buildPageList() {
    List() {
      ListItem() {
        SectionHeader({
          title: '申请表单',
          subtitle: '先选择学生与日期，再补充原因和附件。'
        })
      }

      ListItem() {
        LeaveStudentSelectorCard({
          students: this.availableStudents,
          selectedStudentId: this.selectedStudentId,
          onSelect: (studentId: number) => {
            this.selectedStudentId = studentId;
          }
        })
      }

      ListItem() {
        LeaveDateSummaryCard({
          dateText: DateUtils.formatDateCN(this.leaveDate),
          onDateClick: () => {
            this.showDatePicker = true;
          }
        })
      }

      ListItem() {
        LeaveTypeSelectorCard({
          selectedValue: this.leaveType,
          onSelect: (value: 'SICK' | 'PERSONAL' | 'FAMILY' | 'OTHER') => {
            this.leaveType = value;
          }
        })
      }

      ListItem() {
        this.buildReasonInputCard()
      }

      ListItem() {
        this.buildAttachmentCard()
      }

      ListItem() {
        this.buildSubmitCard()
      }
    }
    .width('100%')
    .layoutWeight(1)
    .divider({ strokeWidth: 0 })
    .padding($r('app.float.page_padding'))
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .cachedCount(8)
  }

  @Builder
  private buildDatePickerSheet() {
    DatePickerSheet({
      title: '选择日期',
      selectedDate: this.leaveDate,
      onDateChange: (value: Date) => {
        this.leaveDate = value;
      },
      onConfirm: () => {
        this.showDatePicker = false;
      }
    })
  }

  @Builder
  private buildReasonInputCard() {
    Card({
      title: '请假原因',
      subtitle: '请尽量说明清楚请假的背景与时间安排。',
      content: this.buildReasonInputContent
    })
  }

  @Builder
  private buildReasonInputContent() {
    TextArea({
      placeholder: '请输入请假原因',
      text: this.reason
    })
      .width('100%')
      .height(120)
      .fontSize($r('app.float.text_primary_size'))
      .backgroundColor($r('app.color.page_background'))
      .borderRadius($r('app.float.button_radius'))
      .padding({ left: 12, right: 12, top: 12, bottom: 12 })
      .onChange((value: string) => {
        this.reason = value;
      })
  }

  @Builder
  private buildAttachmentCard() {
    Card({
      title: '上传附件（可选）',
      subtitle: '可补充请假证明、病假单等材料，最多 3 个。',
      content: this.buildAttachmentContent
    })
  }

  @Builder
  private buildAttachmentContent() {
    if (this.attachments.length === 0) {
      Text('当前未添加附件，可上传请假证明、病假单等材料。')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
    } else {
      List() {
        LazyForEach(this.attachmentDataSource, (fileName: string) => {
          ListItem() {
            Row() {
              Text(fileName)
                .fontSize($r('app.float.text_secondary_size'))
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)

              Text('删除')
                .fontSize($r('app.float.text_tiny_size'))
                .fontColor(HarmonyReport.danger)
                .onClick(() => {
                  this.removeAttachment(this.findAttachmentIndex(fileName));
                })
            }
            .width('100%')
            .padding(12)
            .backgroundColor(HarmonyColor.surfaceSubtle)
            .borderRadius(12)
          }
        }, (fileName: string) => fileName)
      }
      .width('100%')
      .height(this.getAttachmentListHeight())
      .divider({ strokeWidth: 0 })
      .scrollBar(BarState.Off)
    }

    Button(this.attachments.length >= 3 ? '已达上限' : '添加附件')
      .width('100%')
      .height(42)
      .fontSize($r('app.float.text_secondary_size'))
      .fontColor(this.attachments.length >= 3 ? $r('app.color.text_tertiary') : $r('app.color.primary'))
      .backgroundColor(HarmonyColor.surfaceSubtle)
      .borderRadius($r('app.float.button_radius'))
      .margin({ top: 12 })
      .enabled(this.attachments.length < 3)
      .onClick(() => {
        this.selectAttachment();
      })
  }

  @Builder
  private buildSubmitCard() {
    Button(this.isLoading ? '提交中...' : '提交申请')
      .width('100%')
      .height(48)
      .fontSize($r('app.float.text_primary_size'))
      .fontColor(HarmonyColor.textInverse)
      .backgroundColor($r('app.color.primary'))
      .borderRadius($r('app.float.button_radius'))
      .enabled(!this.isLoading)
      .opacity(this.isLoading ? 0.7 : 1)
      .onClick(() => {
        this.submitLeave();
      })
  }

  private getAttachmentListHeight(): number {
    return this.attachments.length * 56;
  }

  private findAttachmentIndex(fileName: string): number {
    for (let i = 0; i < this.attachments.length; i++) {
      if (this.attachments[i] === fileName) {
        return i;
      }
    }
    return -1;
  }
}
