/**
 * SmartGuardian - Parent QR Code Page
 * Display QR code for student pickup
 */

import { UserStore } from '../../stores/userStore';
import { Student } from '../../models/user';
import { StudentService } from '../../services/api/auth';
import { LoadingState, LoadingSize, EmptyState, EmptyType } from '../../components/common';

@Entry
@Component
export struct ParentQRCodePage {
  @State students: Student[] = [];
  @State selectedStudent: Student | null = null;
  @State qrCodeData: string = '';
  @State isLoading: boolean = true;
  @State remainingTime: number = 300; // 5分钟 = 300秒
  private timer: number = -1;

  async aboutToAppear() {
    await this.loadStudents();
    this.startTimer();
  }

  aboutToDisappear() {
    // 清除定时器
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
  }

  async loadStudents() {
    this.isLoading = true;
    try {
      const userInfo = UserStore.getUserInfo();
      if (userInfo?.id) {
        const response = await StudentService.getStudents({ pageNum: 1, pageSize: 100 });
        if (response.code === 0 && response.data) {
          this.students = response.data.list ?? [];
          if (this.students.length > 0) {
            this.selectedStudent = this.students[0];
            this.generateQRCode();
          }
        }
      }
    } catch (error) {
      console.error('Failed to load students:', error);
    } finally {
      this.isLoading = false;
    }
  }

  generateQRCode() {
    if (this.selectedStudent) {
      const timestamp = Date.now();
      this.qrCodeData = JSON.stringify({
        type: 'PICKUP',
        studentId: this.selectedStudent.id,
        studentName: this.selectedStudent.name,
        guardianId: UserStore.getUserInfo()?.id,
        timestamp: timestamp
      });
      this.remainingTime = 300; // 重置时间为5分钟
    }
  }

  startTimer() {
    this.timer = setInterval(() => {
      if (this.remainingTime > 0) {
        this.remainingTime--;
      } else {
        // 二维码过期，重新生成
        this.generateQRCode();
      }
    }, 1000);
  }

  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${minutes}:${secs.toString().padStart(2, '0')}`;
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('←')
            .fontSize(20)
            .fontColor(Color.White)
        }
        .width(36)
        .height(36)
        .backgroundColor('#1AFFFFFF')
        .onClick(() => this.getUIContext().getRouter().back())

        Text('接送码')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(36)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .linearGradient({
        angle: 135,
        colors: [['#4F7CFF', 0], ['#7B68EE', 1]]
      })

      if (this.isLoading) {
        Column() {
          LoadingState({ loadingSize: LoadingSize.LARGE })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.students.length === 0) {
        Column() {
          EmptyState({ type: EmptyType.DEFAULT, customTitle: '暂无学生信息' })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          if (this.students.length > 1) {
            Row() {
              ForEach(this.students, (student: Student) => {
                Button(student.name)
                  .fontSize(14)
                  .fontColor(this.selectedStudent?.id === student.id ? Color.White : '#4F7CFF')
                  .backgroundColor(this.selectedStudent?.id === student.id ? '#4F7CFF' : '#F5F5F5')
                  .borderRadius(16)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .margin({ left: 4, right: 4 })
                  .onClick(() => {
                    this.selectedStudent = student;
                    this.generateQRCode();
                  })
              })
            }
            .width('100%')
            .padding(16)
            .justifyContent(FlexAlign.Center)
          }

          Column() {
            Text('接送二维码')
              .fontSize(16)
              .fontColor('#333333')
              .margin({ bottom: 16 })

            // 二维码显示区域
            Column() {
              if (this.qrCodeData) {
                // 使用 QRCode 组件显示真实二维码
                QRCode(this.qrCodeData)
                  .width(180)
                  .height(180)
                  .color('#4F7CFF')
              }
              
              Text('请在托管中心出示此码')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 12 })
            }
            .width(220)
            .height(220)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .border({ width: 2, color: '#4F7CFF', style: BorderStyle.Solid })
            .shadow({ radius: 10, color: '#1A4F7CFF', offsetX: 0, offsetY: 4 })

            if (this.selectedStudent) {
              Column() {
                Text(this.selectedStudent.name)
                  .fontSize(18)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium)
                
                Text(`学号: ${this.selectedStudent.studentNo}`)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ top: 4 })
              }
              .margin({ top: 16 })
            }

            Row() {
              Text('二维码有效期：')
                .fontSize(12)
                .fontColor('#999999')
              
              Text(this.formatTime(this.remainingTime))
                .fontSize(14)
                .fontColor('#4F7CFF')
                .fontWeight(FontWeight.Bold)
            }
            .margin({ top: 24 })

            Button('刷新二维码')
              .fontSize(14)
              .fontColor('#4F7CFF')
              .backgroundColor('#F0F4FF')
              .borderRadius(20)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .margin({ top: 12 })
              .onClick(() => {
                this.generateQRCode();
              })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
