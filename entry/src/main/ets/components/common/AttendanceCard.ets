/**
 * SmartGuardian - AttendanceCard Component
 * 可复用的考勤卡片组件
 * 
 * @description 显示学生考勤状态，支持签到/签退操作
 * @example
 * AttendanceCard({
 *   studentId: 1,
 *   studentName: '张三',
 *   studentNo: 'S001',
 *   status: AttendanceStatus.NOT_SIGNED,
 *   signInTime: '',
 *   onSignIn: () => { ... },
 *   onSignOut: () => { ... }
 * })
 */

/** 考勤状态枚举 */
export enum AttendanceStatus {
  /** 未签到 */
  NOT_SIGNED = 'NOT_SIGNED',
  /** 已签到 */
  SIGNED_IN = 'SIGNED_IN',
  /** 已签退 */
  SIGNED_OUT = 'SIGNED_OUT'
}

@Component
export struct AttendanceCard {
  /** 学生ID */
  @Prop studentId: number = 0;
  
  /** 学生姓名 */
  @Prop studentName: string = '';
  
  /** 学号 */
  @Prop studentNo: string = '';
  
  /** 考勤状态 */
  @Prop status: AttendanceStatus = AttendanceStatus.NOT_SIGNED;
  
  /** 签到时间 */
  @Prop signInTime: string = '';
  
  /** 签退时间 */
  @Prop signOutTime: string = '';
  
  /** 签到回调 */
  onSignIn?: () => void;
  
  /** 签退回调 */
  onSignOut?: () => void;

  build() {
    Row() {
      // 学生信息
      Column() {
        Text(this.studentName)
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(this.studentNo)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 根据状态显示不同内容
      if (this.status === AttendanceStatus.NOT_SIGNED) {
        this.buildNotSignedContent()
      } else if (this.status === AttendanceStatus.SIGNED_IN) {
        this.buildSignedInContent()
      } else {
        this.buildSignedOutContent()
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_content_margin') })
  }

  /** 未签到状态 */
  @Builder
  buildNotSignedContent() {
    Column() {
      Text(this.signInTime || '未签到')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))

      Button('签到')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius($r('app.float.button_radius'))
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .margin({ top: 4 })
        .onClick(() => {
          if (this.onSignIn) {
            this.onSignIn();
          }
        })
    }
  }

  /** 已签到状态 */
  @Builder
  buildSignedInContent() {
    Column() {
      Text(`签到: ${this.signInTime || ''}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor('#4CAF50')

      Button('签退')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor(Color.White)
        .backgroundColor('#2196F3')
        .borderRadius($r('app.float.button_radius'))
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .margin({ top: 4 })
        .onClick(() => {
          if (this.onSignOut) {
            this.onSignOut();
          }
        })
    }
  }

  /** 已签退状态 */
  @Builder
  buildSignedOutContent() {
    Column() {
      Text(`签退: ${this.signOutTime || ''}`)
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor('#9E9E9E')
    }
  }
}
