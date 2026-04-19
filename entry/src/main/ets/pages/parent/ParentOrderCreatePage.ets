/**
 * SmartGuardian - Parent Order Create Page
 * Create order with student, service, and date selection
 */

import router from '@ohos.router';
import { Student } from '../../models/user';
import { ServiceProduct, Order } from '../../models/service';
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

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params) {
      this.serviceId = params.serviceId || 0;
      this.serviceName = params.serviceName || '';
      this.servicePrice = params.price || 0;
    }
    
    this.loadStudents();
    this.initDefaultDates();
  }

  loadStudents() {
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
          className: '三年级1班',
          grade: '三年级',
          guardianUserId: userInfo.id,
          status: 'ACTIVE',
          createdAt: '',
          updatedAt: ''
        }
      ];
    }
  }

  initDefaultDates() {
    const today = new Date();
    const nextMonth = new Date();
    nextMonth.setMonth(nextMonth.getMonth() + 1);
    
    this.startDate = this.formatDate(today);
    this.endDate = this.formatDate(nextMonth);
  }

  formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  calculateDays(): number {
    if (!this.startDate || !this.endDate) {
      return 0;
    }
    
    const start = new Date(this.startDate);
    const end = new Date(this.endDate);
    const diff = end.getTime() - start.getTime();
    const days = Math.ceil(diff / (1000 * 60 * 60 * 24)) + 1;
    return Math.max(0, days);
  }

  calculateAmount() {
    this.totalDays = this.calculateDays();
    this.totalAmount = this.totalDays * this.servicePrice;
    this.discountAmount = this.totalDays >= 10 ? this.totalAmount * 0.1 : 0;
    this.actualAmount = this.totalAmount - this.discountAmount;
  }

  handleStudentChange(student: Student) {
    this.selectedStudentId = student.id;
    this.selectedStudentName = student.name;
    this.showStudentPicker = false;
  }

  async handleSubmit() {
    if (!this.selectedStudentId) {
      return;
    }

    if (!this.startDate || !this.endDate) {
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
        router.replaceUrl({
          url: 'pages/parent/ParentOrderDetailPage',
          params: {
            orderId: resp.data.id,
            orderNo: resp.data.orderNo
          }
        });
      }
    } catch (error) {
      console.error('Failed to create order:', error);
    } finally {
      this.isSubmitting = false;
    }
  }

  build() {
    Column() {
      this.buildHeader()

      Scroll() {
        Column() {
          this.buildServiceCard()
          this.buildStudentSection()
          this.buildDateSection()
          this.buildAmountSection()
          this.buildNote()
        }
        .width('100%')
        .padding($r('app.float.page_padding'))
        .padding({ bottom: 100 })
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
      height: 400,
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
        .onClick(() => router.back())

      Text('创建订单')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank()
        .width(24)
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor($r('app.color.primary'))
    .padding({ top: Number($r('app.float.status_bar_height')) + 10 })
  }

  @Builder
  buildServiceCard() {
    Column() {
      Row() {
        Column() {
          Text(this.serviceName)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Row() {
            Text('¥')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor('#FF5722')

            Text(this.servicePrice.toString())
              .fontSize(20)
              .fontColor('#FF5722')
              .fontWeight(FontWeight.Bold)

            Text('/次')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 4 })
          }
          .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
  }

  @Builder
  buildStudentSection() {
    Column() {
      Text('选择学生')
        .fontSize($r('app.float.card_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 12 })

      Row() {
        Column() {
          if (this.selectedStudentName) {
            Text(this.selectedStudentName)
              .fontSize($r('app.float.text_primary_size'))
              .fontColor($r('app.color.text_primary'))
          } else {
            Text('请选择学生')
              .fontSize($r('app.float.text_primary_size'))
              .fontColor($r('app.color.text_secondary'))
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Image($r('app.media.ic_arrow_right'))
          .width($r('app.float.icon_small_size'))
          .height($r('app.float.icon_small_size'))
      }
      .width('100%')
      .padding($r('app.float.card_padding'))
      .backgroundColor('#F8F8F8')
      .borderRadius($r('app.float.card_border_radius'))
      .onClick(() => this.showStudentPicker = true)
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ top: 12 })
  }

  @Builder
  buildDateSection() {
    Column() {
      Text('选择日期').fontSize($r('app.float.card_title_size')).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')).margin({ bottom: 12 })
      Row() {
        Column() {
          Text('开始日期').fontSize($r('app.float.text_secondary_size')).fontColor($r('app.color.text_secondary'))
          Text(this.startDate || '请选择').fontSize($r('app.float.text_primary_size')).fontColor($r('app.color.text_primary')).fontWeight(FontWeight.Medium).margin({ top: 4 })
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        Divider().vertical(true).height(30).color('#E0E0E0').margin({ left: 16, right: 16 })
        Column() {
          Text('结束日期').fontSize($r('app.float.text_secondary_size')).fontColor($r('app.color.text_secondary'))
          Text(this.endDate || '请选择').fontSize($r('app.float.text_primary_size')).fontColor($r('app.color.text_primary')).fontWeight(FontWeight.Medium).margin({ top: 4 })
        }.alignItems(HorizontalAlign.End).layoutWeight(1)
      }.width('100%')
    }.width('100%').padding($r('app.float.card_padding')).backgroundColor(Color.White).borderRadius($r('app.float.card_border_radius')).margin({ top: 12 })
  }

  @Builder
  buildAmountSection() {
    Column() {
      Text('费用明细').fontSize($r('app.float.card_title_size')).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')).margin({ bottom: 12 })
      Row() { Text('服务天数').fontSize($r('app.float.text_primary_size')).fontColor($r('app.color.text_secondary')); Text(`${this.totalDays}天`).fontSize($r('app.float.text_primary_size')).fontColor($r('app.color.text_primary')) }.width('100%').margin({ top: 8, bottom: 8 })
      Row() { Text('服务费用').fontSize($r('app.float.text_primary_size')).fontColor($r('app.color.text_secondary')); Text(`¥${this.totalAmount.toFixed(2)}`).fontSize($r('app.float.text_primary_size')).fontColor($r('app.color.text_primary')) }.width('100%').margin({ top: 8, bottom: 8 })
      if (this.discountAmount > 0) {
        Row() { Text('优惠金额').fontSize($r('app.float.text_primary_size')).fontColor($r('app.color.text_secondary')); Text(`-¥${this.discountAmount.toFixed(2)}`).fontSize($r('app.float.text_primary_size')).fontColor('#FF5722') }.width('100%').margin({ top: 8, bottom: 8 })
      }
      Divider().color('#E0E0E0').margin({ top: 12, bottom: 12 })
      Row() {
        Text('应付金额').fontSize($r('app.float.text_primary_size')).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        Row() { Text('¥').fontSize($r('app.float.text_primary_size')).fontColor('#FF5722').fontWeight(FontWeight.Bold); Text(this.actualAmount.toFixed(2)).fontSize(24).fontColor('#FF5722').fontWeight(FontWeight.Bold) }
      }.width('100%')
    }.width('100%').padding($r('app.float.card_padding')).backgroundColor(Color.White).borderRadius($r('app.float.card_border_radius')).margin({ top: 12 })
  }

  @Builder
  buildNote() {
    Column() {
      Text('温馨提示').fontSize($r('app.float.text_secondary_size')).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_secondary')).margin({ bottom: 8 })
      Text('1. 报名10天及以上可享9折优惠').fontSize(12).fontColor('#999999').margin({ top: 4 })
      Text('2. 订单提交后需等待机构审核').fontSize(12).fontColor('#999999').margin({ top: 4 })
      Text('3. 审核通过后请在24小时内完成支付').fontSize(12).fontColor('#999999').margin({ top: 4 })
    }.width('100%').padding($r('app.float.card_padding')).backgroundColor('#FFF3E0').borderRadius($r('app.float.card_border_radius')).margin({ top: 12 })
  }

  @Builder
  buildStudentPicker() {
    Column() {
      Text('选择学生').fontSize($r('app.float.card_title_size')).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).padding({ top: 16, bottom: 16 })
      ForEach(this.students, (student: Student) => {
        Row() {
          Column() {
            Text(student.name).fontSize($r('app.float.text_primary_size')).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
            Text(`${student.schoolName || ''} ${student.className || ''}`).fontSize($r('app.float.text_secondary_size')).fontColor($r('app.color.text_secondary')).margin({ top: 4 })
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          if (this.selectedStudentId === student.id) {
            Image($r('app.media.ic_home')).width($r('app.float.icon_small_size')).height($r('app.float.icon_small_size'))
          }
        }.width('100%').padding($r('app.float.card_padding')).onClick(() => this.handleStudentChange(student))
      })
    }
  }

  @Builder
  buildBottomBar() {
    Row() {
      Column() {
        Text('应付金额').fontSize($r('app.float.text_secondary_size')).fontColor($r('app.color.text_secondary'))
        Row() { Text('¥').fontSize($r('app.float.text_primary_size')).fontColor('#FF5722'); Text(this.actualAmount.toFixed(2)).fontSize(24).fontColor('#FF5722').fontWeight(FontWeight.Bold) }
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
      Button('提交订单').width(160).height(44).fontSize(16).fontColor(Color.White).backgroundColor($r('app.color.primary')).borderRadius(22)
        .enabled(this.selectedStudentId > 0 && !this.isSubmitting).onClick(() => this.handleSubmit())
    }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor(Color.White).shadow({ radius: 10, color: '#1A000000', offsetY: -2 })
  }
}
