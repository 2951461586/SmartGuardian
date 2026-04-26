/**
 * SmartGuardian - Parent Order Create Page
 * Create order with student, date and amount summary
 */

import {
  DatePickerSheet,
  HeaderTheme,
  OrderAmountSummarySection,
  OrderCreateBottomBar,
  OrderCreateDateSection,
  OrderCreateNotesCard,
  OrderCreateServiceSummaryCard,
  OrderCreateStudentPickerSheet,
  OrderCreateStudentSection,
  PageHeader
} from '../../components/common';
import { RouteUrls } from '../../constants/app.constants';
import { Student } from '../../models/user';
import { OrderService } from '../../services/api/service';
import { UserStore } from '../../stores/userStore';
import { HarmonyColor } from '../../common/HarmonyDesign';

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
          url: RouteUrls.PARENT_ORDER_DETAIL,
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
          OrderCreateServiceSummaryCard({
            serviceName: this.serviceName,
            servicePrice: this.servicePrice
          })

          OrderCreateStudentSection({
            selectedStudentName: this.selectedStudentName,
            onSelect: (): void => {
              this.showStudentPicker = true;
            }
          })

          OrderCreateDateSection({
            startDate: this.startDate,
            endDate: this.endDate,
            onSelectStart: (): void => {
              this.showStartDatePicker = true;
            },
            onSelectEnd: (): void => {
              this.showEndDatePicker = true;
            }
          })

          OrderAmountSummarySection({
            totalDays: this.totalDays,
            totalAmount: this.totalAmount,
            discountAmount: this.discountAmount,
            actualAmount: this.actualAmount
          })

          OrderCreateNotesCard()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 120 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      OrderCreateBottomBar({
        actualAmount: this.actualAmount,
        isSubmitting: this.isSubmitting,
        canSubmit: this.selectedStudentId > 0,
        onSubmit: (): void => {
          this.handleSubmit();
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .bindSheet($$this.showStudentPicker, this.buildStudentPicker(), {
      height: 420,
      backgroundColor: HarmonyColor.surface,
      dragBar: true
    })
    .bindSheet($$this.showStartDatePicker, this.buildStartDatePicker(), {
      height: 430,
      backgroundColor: HarmonyColor.surface,
      dragBar: true
    })
    .bindSheet($$this.showEndDatePicker, this.buildEndDatePicker(), {
      height: 430,
      backgroundColor: HarmonyColor.surface,
      dragBar: true
    })
  }

  @Builder
  private buildStudentPicker() {
    OrderCreateStudentPickerSheet({
      selectedStudentName: this.selectedStudentName,
      students: this.students,
      onSelectStudent: (student: Student): void => {
        this.handleStudentChange(student);
      }
    })
  }

  @Builder
  private buildStartDatePicker() {
    DatePickerSheet({
      title: '选择开始日期',
      selectedDate: this.startDateValue,
      onDateChange: (value: Date): void => this.applyStartDate(value),
      onConfirm: (): void => {
        this.showStartDatePicker = false;
      }
    })
  }

  @Builder
  private buildEndDatePicker() {
    DatePickerSheet({
      title: '选择结束日期',
      selectedDate: this.endDateValue,
      onDateChange: (value: Date): void => this.applyEndDate(value),
      onConfirm: (): void => {
        this.showEndDatePicker = false;
      }
    })
  }

}

