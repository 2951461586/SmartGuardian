/**
 * SmartGuardian - 请假申请页
 * 家长提交请假申请
 */

import { AttendanceService } from '../../services/api/attendance';
import { LeaveRequest } from '../../models/attendance';
import { DateUtils } from '../../utils/dateUtils';

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
  @State showTimePicker: boolean = false;
  @State selectedTime: string = '08:00';

  aboutToAppear() {
    // Load available students
    const students: StudentItem[] = [];
    students.push({ id: 1, name: '张三' });
    students.push({ id: 2, name: '李四' });
    this.availableStudents = students;
    if (this.availableStudents.length > 0) {
      this.selectedStudentId = this.availableStudents[0].id;
    }
  }

  async submitLeave() {
    if (!this.selectedStudentId) {
      return;
    }
    if (!this.reason.trim()) {
      return;
    }

    this.isLoading = true;
    try {
      const leaveTypeValue: 'SICK' | 'PERSONAL' | 'FAMILY' | 'OTHER' =
        this.leaveType === 'SICK' ? 'SICK' :
        this.leaveType === 'PERSONAL' ? 'PERSONAL' :
        this.leaveType === 'FAMILY' ? 'FAMILY' : 'OTHER';
      const request: LeaveRequest = {
        studentId: this.selectedStudentId,
        leaveDate: DateUtils.formatDate(this.leaveDate),
        leaveType: leaveTypeValue,
        reason: this.reason
      };

      const resp = await AttendanceService.submitLeave(request);
      if (resp.code === 0) {
        this.getUIContext().getRouter().back();
      }
    } catch (error) {
      console.error('Submit leave failed:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 选择图片
  async selectImage() {
    try {
      // TODO: 实现图片选择功能
      // 临时添加一个占位图片
      this.attachments.push('mock_image_' + this.attachments.length.toString());
    } catch (error) {
      console.error('Select image failed:', error);
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
    .bindSheet($$this.showDatePicker, this.buildDatePickerSheet(), {
      height: 420,
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
  buildStudentSelection() {
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
  buildDatePickerSheet() {
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
        // 已选择的图片列表
        ForEach(this.attachments, (uri: string, index: number) => {
          Stack({ alignContent: Alignment.TopEnd }) {
            Image(uri)
              .width(80)
              .height(80)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)

            // 删除按钮
            Image($r('app.media.ic_close'))
              .width(20)
              .height(20)
              .margin({ top: -8, right: -8 })
              .onClick(() => {
                this.attachments.splice(index, 1);
              })
          }
          .margin({ right: 8 })
        })

        // 添加图片按钮
        if (this.attachments.length < 3) {
          Column() {
            Image($r('app.media.ic_add'))
              .width(32)
              .height(32)
              .fillColor($r('app.color.text_tertiary'))

            Text('添加图片')
              .fontSize($r('app.float.text_tiny_size'))
              .fontColor($r('app.color.text_tertiary'))
              .margin({ top: 4 })
          }
          .width(80)
          .height(80)
          .backgroundColor($r('app.color.page_background'))
          .borderRadius($r('app.float.button_radius'))
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.selectImage();
          })
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
  }
}