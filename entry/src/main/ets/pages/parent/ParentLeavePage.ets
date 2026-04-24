/**
 * SmartGuardian - Parent Leave Page
 * Parent leave request page
 */

import { LeaveRequest } from '../../models/attendance';
import { Student } from '../../models/user';
import { AttendanceService } from '../../services/api/attendance';
import { StudentStore } from '../../stores/studentStore';
import { DateUtils } from '../../utils/dateUtils';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';
import { LogUtil } from '../../utils/LogUtil';

interface StudentItem {
  id: number;
  name: string;
}

@Entry
@Component
struct ParentLeavePage {
  @State isLoading: boolean = false;
  @State leaveDate: Date = new Date();
  @State leaveType: 'SICK' | 'PERSONAL' | 'FAMILY' | 'OTHER' = 'SICK';
  @State reason: string = '';
  @State attachments: string[] = [];
  @State selectedStudentId: number = 0;
  @State availableStudents: StudentItem[] = [];
  @State showDatePicker: boolean = false;

  aboutToAppear() {
    ErrorHandlerUtil.setUIContext(this.getUIContext());
    this.loadAvailableStudents();
  }

  private loadAvailableStudents(): void {
    const storedStudents = StudentStore.getStudentList();
    const mappedStudents: StudentItem[] = [];
    storedStudents.forEach((student: Student) => {
      const item: StudentItem = {
        id: student.id,
        name: student.name
      };
      mappedStudents.push(item);
    });

    if (mappedStudents.length > 0) {
      this.availableStudents = mappedStudents;
    } else {
      const fallbackStudents: StudentItem[] = [];
      const firstStudent: StudentItem = { id: 1, name: '王小明' };
      const secondStudent: StudentItem = { id: 2, name: '李小雨' };
      fallbackStudents.push(firstStudent);
      fallbackStudents.push(secondStudent);
      this.availableStudents = fallbackStudents;
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
    ErrorHandlerUtil.showSuccessToast('已添加附件占位，后续可接入系统图片选择器');
  }

  private removeAttachment(index: number): void {
    const nextAttachments = [...this.attachments];
    nextAttachments.splice(index, 1);
    this.attachments = nextAttachments;
  }

  build() {
    Column() {
      this.buildHeader()

      Scroll() {
        Column() {
          this.buildStudentSelection()
          this.buildDatePicker()
          this.buildLeaveType()
          this.buildReasonInput()
          this.buildAttachments()

          Button(this.isLoading ? '提交中...' : '提交申请')
            .width('100%')
            .height(48)
            .fontSize($r('app.float.text_primary_size'))
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary'))
            .borderRadius($r('app.float.button_radius'))
            .margin({ top: 24 })
            .enabled(!this.isLoading)
            .opacity(this.isLoading ? 0.7 : 1)
            .onClick(() => {
              this.submitLeave();
            })
        }
        .width('100%')
        .padding($r('app.float.page_padding'))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .bindSheet($$this.showDatePicker, this.buildDatePickerSheet(), {
      height: 420,
      backgroundColor: Color.White,
      dragBar: true
    })
  }

  @Builder
  private buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .fillColor($r('app.color.text_primary'))
        .onClick(() => {
          this.getUIContext().getRouter().back();
        })

      Text('请假申请')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('')
        .width(24)
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor(Color.White)
  }

  @Builder
  private buildStudentSelection() {
    Column() {
      Text('选择学生')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      Row() {
        ForEach(this.availableStudents, (student: StudentItem) => {
          Text(student.name)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.selectedStudentId === student.id ? Color.White : $r('app.color.text_primary'))
            .padding({ left: 20, right: 20, top: 10, bottom: 10 })
            .backgroundColor(this.selectedStudentId === student.id ? $r('app.color.primary') : $r('app.color.page_background'))
            .borderRadius($r('app.float.button_radius'))
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.selectedStudentId = student.id;
            })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  private buildDatePicker() {
    Column() {
      Text('请假日期')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      Row() {
        Text(DateUtils.formatDateCN(this.leaveDate))
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_primary'))

        Blank()

        Image($r('app.media.ic_arrow_right'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.text_tertiary'))
      }
      .width('100%')
      .padding(12)
      .backgroundColor($r('app.color.page_background'))
      .borderRadius($r('app.float.button_radius'))
      .onClick(() => {
        this.showDatePicker = true;
      })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  private buildDatePickerSheet() {
    Column() {
      Text('选择日期')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16, bottom: 16 })

      DatePicker({
        start: new Date(),
        end: new Date(2030, 11, 31),
        selected: this.leaveDate
      })
        .width('100%')
        .onDateChange((value: Date) => {
          this.leaveDate = value;
        })

      Button('确定')
        .width('90%')
        .height(44)
        .margin({ top: 20 })
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(22)
        .onClick(() => {
          this.showDatePicker = false;
        })
    }
    .width('100%')
    .padding(20)
  }

  @Builder
  private buildLeaveType() {
    Column() {
      Text('请假类型')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      Column() {
        Row() {
          this.buildLeaveTypeChip('病假', 'SICK')
          this.buildLeaveTypeChip('事假', 'PERSONAL')
        }
        .width('100%')

        Row() {
          this.buildLeaveTypeChip('家庭事务', 'FAMILY')
          this.buildLeaveTypeChip('其他', 'OTHER')
        }
        .width('100%')
        .margin({ top: 12 })
      }
      .width('100%')
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  private buildLeaveTypeChip(label: string, value: 'SICK' | 'PERSONAL' | 'FAMILY' | 'OTHER') {
    Column() {
      Text(label)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(this.leaveType === value ? $r('app.color.primary') : $r('app.color.text_secondary'))
    }
    .layoutWeight(1)
    .padding(12)
    .margin({ right: value === 'SICK' || value === 'FAMILY' ? 12 : 0 })
    .backgroundColor(this.leaveType === value ? $r('app.color.primary_light') : $r('app.color.page_background'))
    .borderRadius($r('app.float.button_radius'))
    .onClick(() => {
      this.leaveType = value;
    })
  }

  @Builder
  private buildReasonInput() {
    Column() {
      Text('请假原因')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

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
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  private buildAttachments() {
    Column() {
      Text('上传附件（可选）')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      if (this.attachments.length === 0) {
        Text('当前未添加附件，可上传请假证明、病假单等材料。')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
      } else {
        Column() {
          ForEach(this.attachments, (fileName: string, index: number) => {
            Row() {
              Text(fileName)
                .fontSize($r('app.float.text_secondary_size'))
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)

              Text('删除')
                .fontSize($r('app.float.text_tiny_size'))
                .fontColor('#DC2626')
                .onClick(() => {
                  this.removeAttachment(index);
                })
            }
            .width('100%')
            .padding(12)
            .margin({ bottom: 8 })
            .backgroundColor('#F7FAFD')
            .borderRadius(12)
          })
        }
        .width('100%')
      }

      Button(this.attachments.length >= 3 ? '已达上限' : '添加附件')
        .width('100%')
        .height(42)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(this.attachments.length >= 3 ? $r('app.color.text_tertiary') : $r('app.color.primary'))
        .backgroundColor('#F3F7FB')
        .borderRadius($r('app.float.button_radius'))
        .margin({ top: 12 })
        .enabled(this.attachments.length < 3)
        .onClick(() => {
          this.selectAttachment();
        })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
  }
}

