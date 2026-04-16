/**
 * SmartGuardian - 请假申请页
 * 家长提交请假申请
 */

import { router } from '@kit.ArkUI';
import { AttendanceService, LeaveRequest } from '../../services/api/attendance';
import { DateUtils } from '../../utils/dateUtils';

@Component
struct ParentLeavePage {
  @State isLoading: boolean = false;
  @State leaveDate: Date = new Date();
  @State leaveType: string = 'SICK';  // SICK: 病假, PERSONAL: 事假
  @State reason: string = '';
  @State attachments: string[] = [];
  @State selectedStudentId: string = '';
  @State availableStudents: Array<{ id: string; name: string }> = [];

  aboutToAppear() {
    // Load available students
    this.availableStudents = [
      { id: '1', name: '张三' },
      { id: '2', name: '李四' }
    ];
    if (this.availableStudents.length > 0) {
      this.selectedStudentId = this.availableStudents[0].id;
    }
  }

  async submitLeave() {
    if (!this.selectedStudentId) {
      // Show error: 请选择学生
      return;
    }
    if (!this.reason.trim()) {
      // Show error: 请填写请假原因
      return;
    }

    this.isLoading = true;
    try {
      const request: LeaveRequest = {
        studentId: this.selectedStudentId,
        leaveDate: DateUtils.formatDate(this.leaveDate),
        leaveType: this.leaveType,
        reason: this.reason,
        attachments: this.attachments
      };

      const resp = await AttendanceService.submitLeave(request);
      if (resp.code === 0) {
        // Show success and navigate back
        router.back();
      }
    } catch (error) {
      // Handle error
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Content
      Scroll() {
        Column() {
          // Student selection
          this.buildStudentSelection()

          // Leave date
          this.buildDatePicker()

          // Leave type
          this.buildLeaveType()

          // Reason input
          this.buildReasonInput()

          // Attachments
          this.buildAttachments()

          // Submit button
          Button('提交申请')
            .width('100%')
            .height(48)
            .fontSize($r('app.float.text_primary_size'))
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary'))
            .borderRadius($r('app.float.button_radius'))
            .margin({ top: 24 })
            .enabled(!this.isLoading)
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
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .fillColor($r('app.color.text_primary'))
        .onClick(() => {
          router.back();
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
  buildStudentSelection() {
    Column() {
      Text('选择学生')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      Row() {
        ForEach(this.availableStudents, (student: { id: string; name: string }) => {
          Text(student.name)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.selectedStudentId === student.id ? Color.White : $r('app.color.text_primary'))
            .padding({ left: 20, right: 20, top: 10, bottom: 10 })
            .backgroundColor(this.selectedStudentId === student.id ? $r('app.color.primary') : $r('app.color.page_background'))
            .borderRadius($r('app.float.button_radius'))
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
  buildDatePicker() {
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
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  @Builder
  buildLeaveType() {
    Column() {
      Text('请假类型')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      Row() {
        Column() {
          Text('病假')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.leaveType === 'SICK' ? $r('app.color.primary') : $r('app.color.text_secondary'))
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor(this.leaveType === 'SICK' ? $r('app.color.primary_light') : $r('app.color.page_background'))
        .borderRadius($r('app.float.button_radius'))
        .onClick(() => {
          this.leaveType = 'SICK';
        })

        Column() {
          Text('事假')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.leaveType === 'PERSONAL' ? $r('app.color.primary') : $r('app.color.text_secondary'))
        }
        .layoutWeight(1)
        .padding(12)
        .margin({ left: 12 })
        .backgroundColor(this.leaveType === 'PERSONAL' ? $r('app.color.primary_light') : $r('app.color.page_background'))
        .borderRadius($r('app.float.button_radius'))
        .onClick(() => {
          this.leaveType = 'PERSONAL';
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
  buildReasonInput() {
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
  buildAttachments() {
    Column() {
      Text('上传附件（可选）')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      Row() {
        Column() {
          Image($r('app.media.ic_add'))
            .width(32)
            .height(32)
            .fillColor($r('app.color.text_tertiary'))

          Text('添加图片')
            .fontSize($r('app.float.text_tiny_size'))
            .fontColor($r('app.color.text_tertiary'))
        }
        .width(80)
        .height(80)
        .backgroundColor($r('app.color.page_background'))
        .borderRadius($r('app.float.button_radius'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          // TODO: Open photo picker
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
  }
}