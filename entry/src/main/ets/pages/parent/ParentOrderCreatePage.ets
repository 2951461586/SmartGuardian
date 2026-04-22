/**
 * SmartGuardian - Parent Order Create Page
 * Create order with student, date and amount summary
 */

import { Card, HeaderTheme, PageHeader, SectionHeader } from '../../components/common';
import { Student } from '../../models/user';
import { OrderService } from '../../services/api/service';
import { UserStore } from '../../stores/userStore';

interface RouterParams {
  serviceId?: number;
  serviceName?: string;
  price?: number;
}

@Entry
@Component
struct ParentOrderCreatePage {
  @State serviceId: number = 0;
  @State serviceName: string = '';
  @State servicePrice: number = 0;
  @State students: Student[] = [];
  @State selectedStudentId: number = 0;
  @State selectedStudentName: string = '';
  @State startDate: string = '';
  @State endDate: string = '';
  @State totalDays: number = 0;
  @State totalAmount: number = 0;
  @State discountAmount: number = 0;
  @State actualAmount: number = 0;
  @State isSubmitting: boolean = false;
  @State showStudentPicker: boolean = false;
  @State showStartDatePicker: boolean = false;
  @State showEndDatePicker: boolean = false;
  @State startDateValue: Date = new Date();
  @State endDateValue: Date = new Date();

  aboutToAppear() {
    const params = this.getUIContext().getRouter().getParams() as RouterParams;
    if (params) {
      this.serviceId = params.serviceId || 0;
      this.serviceName = params.serviceName || '';
      this.servicePrice = params.price || 0;
    }

    this.loadStudents();
    this.initDefaultDates();
    this.calculateAmount();
  }

  private loadStudents() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.students = [
        {
          id: 1,
          studentNo: 'S001',
          name: '张小明',
          schoolId: 1,
          schoolName: '第一小学',
          classId: 1,
          className: '三年级一班',
          grade: '三年级',
          guardianUserId: userInfo.id,
          status: 'ACTIVE',
          createdAt: '',
          updatedAt: ''
        }
      ];
    }
  }

  private initDefaultDates(): void {
    const today = new Date();
    const nextMonth = new Date();
    nextMonth.setMonth(nextMonth.getMonth() + 1);

    this.startDateValue = today;
    this.endDateValue = nextMonth;
    this.startDate = this.formatDate(today);
    this.endDate = this.formatDate(nextMonth);
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private calculateDays(): number {
    if (!this.startDate || !this.endDate) {
      return 0;
    }

    const start = new Date(this.startDate);
    const end = new Date(this.endDate);
    const diff = end.getTime() - start.getTime();
    const days = Math.ceil(diff / (1000 * 60 * 60 * 24)) + 1;
    return Math.max(0, days);
  }

  private calculateAmount(): void {
    this.totalDays = this.calculateDays();
    this.totalAmount = this.totalDays * this.servicePrice;
    this.discountAmount = this.totalDays >= 10 ? this.totalAmount * 0.1 : 0;
    this.actualAmount = this.totalAmount - this.discountAmount;
  }

  private handleStudentChange(student: Student): void {
    this.selectedStudentId = student.id;
    this.selectedStudentName = student.name;
    this.showStudentPicker = false;
  }

  private applyStartDate(date: Date): void {
    this.startDateValue = date;
    this.startDate = this.formatDate(date);
    if (new Date(this.endDate).getTime() < date.getTime()) {
      this.endDateValue = date;
      this.endDate = this.formatDate(date);
    }
    this.calculateAmount();
  }

  private applyEndDate(date: Date): void {
    const start = new Date(this.startDate);
    if (date.getTime() < start.getTime()) {
      this.endDateValue = start;
      this.endDate = this.formatDate(start);
    } else {
      this.endDateValue = date;
      this.endDate = this.formatDate(date);
    }
    this.calculateAmount();
  }

  async handleSubmit() {
    if (!this.selectedStudentId || !this.startDate || !this.endDate) {
      return;
    }

    this.isSubmitting = true;
    try {
      const resp = await OrderService.createOrder({
        studentId: this.selectedStudentId,
        serviceProductId: this.serviceId,
        startDate: this.startDate,
        endDate: this.endDate,
        totalAmount: this.totalAmount,
        discountAmount: this.discountAmount
      });

      if (resp.code === 0 && resp.data) {
        this.getUIContext().getRouter().replaceUrl({
          url: 'pages/parent/ParentOrderDetailPage',
          params: {
            orderId: resp.data.id,
            orderNo: resp.data.orderNo
          }
        });
      }
    } catch (error) {
      console.error('Failed to create order:', String(error));
    } finally {
      this.isSubmitting = false;
    }
  }

  build() {
    Column() {
      PageHeader({
        title: '创建订单',
        subtitle: '选择学生、服务周期并确认费用后提交审核。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      Scroll() {
        Column() {
          this.buildServiceCard()
          this.buildStudentSection()
          this.buildDateSection()
          this.buildAmountSection()
          this.buildNote()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 120 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      this.buildBottomBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .bindSheet($$this.showStudentPicker, this.buildStudentPicker(), {
      height: 420,
      backgroundColor: Color.White,
      dragBar: true
    })
    .bindSheet($$this.showStartDatePicker, this.buildStartDatePicker(), {
      height: 430,
      backgroundColor: Color.White,
      dragBar: true
    })
    .bindSheet($$this.showEndDatePicker, this.buildEndDatePicker(), {
      height: 430,
      backgroundColor: Color.White,
      dragBar: true
    })
  }

  @Builder
  private buildServiceCard() {
    Card({
      title: '服务信息',
      subtitle: '确认当前报名服务和单价。',
      content: this.buildServiceCardContent
    })
  }

  @Builder
  private buildServiceCardContent() {
    Row() {
      Column() {
        Text(this.serviceName || '未命名服务')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Text(`按天计费 · ¥${this.servicePrice.toFixed(2)} / 天`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
  }

  @Builder
  private buildStudentSection() {
    Column() {
      SectionHeader({
        title: '选择学生',
        subtitle: '将订单绑定到具体学生档案。'
      })

      Card({
        title: '学生信息',
        actionText: '选择学生',
        onAction: () => {
          this.showStudentPicker = true;
        },
        content: this.buildStudentSectionContent
      })
    }
    .width('100%')
  }

  @Builder
  private buildStudentSectionContent() {
    Text(this.selectedStudentName || '请先选择学生')
      .width('100%')
      .fontSize(16)
      .fontColor(this.selectedStudentName ? $r('app.color.text_primary') : $r('app.color.text_secondary'))
  }

  @Builder
  private buildDateSection() {
    Column() {
      SectionHeader({
        title: '服务周期',
        subtitle: '使用弹窗选择开始日期和结束日期。'
      })

      Card({
        title: '日期选择',
        content: this.buildDateSectionContent
      })
    }
    .width('100%')
  }

  @Builder
  private buildDateSectionContent() {
    Row() {
      this.buildDateCell('开始日期', this.startDate, () => {
        this.showStartDatePicker = true;
      })

      Divider()
        .vertical(true)
        .height(36)
        .color('#E0E8F2')
        .margin({ left: 12, right: 12 })

      this.buildDateCell('结束日期', this.endDate, () => {
        this.showEndDatePicker = true;
      })
    }
    .width('100%')
  }

  @Builder
  private buildDateCell(title: string, value: string, action: () => void) {
    Column() {
      Text(title)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))

      Text(value || '请选择')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 6 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .onClick(action)
  }

  @Builder
  private buildAmountSection() {
    Column() {
      SectionHeader({
        title: '费用明细',
        subtitle: '自动计算服务天数、优惠和最终应付金额。'
      })

      Card({
        title: '结算信息',
        content: this.buildAmountSectionContent
      })
    }
    .width('100%')
  }

  @Builder
  private buildAmountSectionContent() {
    Column() {
      this.buildAmountRow('服务天数', `${this.totalDays} 天`, false)
      this.buildAmountRow('服务费用', `¥${this.totalAmount.toFixed(2)}`, false)

      if (this.discountAmount > 0) {
        this.buildAmountRow('优惠金额', `-¥${this.discountAmount.toFixed(2)}`, true)
      }

      Divider()
        .color('#E0E8F2')
        .margin({ top: 12, bottom: 12 })

      Row() {
        Text('应付金额')
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Text(`¥${this.actualAmount.toFixed(2)}`)
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E5484D')
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  private buildAmountRow(label: string, value: string, highlight: boolean) {
    Row() {
      Text(label)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_secondary'))

      Blank()

      Text(value)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor(highlight ? '#D97706' : $r('app.color.text_primary'))
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  private buildNote() {
    Card({
      title: '温馨提示',
      subtitle: '下单前请留意优惠规则和审核时效。',
      content: this.buildNoteContent
    })
  }

  @Builder
  private buildNoteContent() {
    Column() {
      Text('1. 连续报名 10 天及以上可享 9 折优惠。')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
      Text('2. 订单提交后需等待机构审核。')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ top: 6 })
      Text('3. 审核通过后请尽快完成支付。')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .width('100%')
        .margin({ top: 6 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildStudentPicker() {
    Column() {
      Text('选择学生')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 8, bottom: 16 })

      ForEach(this.students, (student: Student) => {
        Row() {
          Column() {
            Text(student.name)
              .fontSize($r('app.float.text_primary_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))

            Text(`${student.schoolName || '--'} ${student.className || '--'}`)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          if (this.selectedStudentId === student.id) {
            Image($r('app.media.ic_success'))
              .width(18)
              .height(18)
          }
        }
        .width('100%')
        .padding({ top: 14, bottom: 14 })
        .onClick(() => this.handleStudentChange(student))

        Divider()
          .color('#E0E8F2')
      })
    }
    .width('100%')
    .padding(20)
  }

  @Builder
  private buildStartDatePicker() {
    Column() {
      Text('选择开始日期')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 8, bottom: 16 })

      DatePicker({
        start: new Date(2020, 0, 1),
        end: new Date(2035, 11, 31),
        selected: this.startDateValue
      })
        .width('100%')
        .onDateChange((value: Date) => {
          this.applyStartDate(value);
        })

      Button('确定')
        .width('100%')
        .height(44)
        .margin({ top: 20 })
        .fontSize($r('app.float.text_primary_size'))
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(18)
        .onClick(() => {
          this.showStartDatePicker = false;
        })
    }
    .width('100%')
    .padding(20)
  }

  @Builder
  private buildEndDatePicker() {
    Column() {
      Text('选择结束日期')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 8, bottom: 16 })

      DatePicker({
        start: new Date(2020, 0, 1),
        end: new Date(2035, 11, 31),
        selected: this.endDateValue
      })
        .width('100%')
        .onDateChange((value: Date) => {
          this.applyEndDate(value);
        })

      Button('确定')
        .width('100%')
        .height(44)
        .margin({ top: 20 })
        .fontSize($r('app.float.text_primary_size'))
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(18)
        .onClick(() => {
          this.showEndDatePicker = false;
        })
    }
    .width('100%')
    .padding(20)
  }

  @Builder
  private buildBottomBar() {
    Row() {
      Column() {
        Text('应付金额')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))

        Text(`¥${this.actualAmount.toFixed(2)}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E5484D')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button(this.isSubmitting ? '提交中...' : '提交订单')
        .width(160)
        .height(46)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(18)
        .enabled(this.selectedStudentId > 0 && !this.isSubmitting)
        .opacity(this.selectedStudentId > 0 && !this.isSubmitting ? 1 : 0.6)
        .onClick(() => {
          this.handleSubmit();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 18 })
    .backgroundColor(Color.White)
    .shadow({
      radius: 10,
      color: '#10172F14',
      offsetX: 0,
      offsetY: -4
    })
  }
}
