/**
 * SmartGuardian - QR Code Scan Page
 * Scan QR code for sign in/sign out
 */

import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { PermissionUtil } from '../../utils/PermissionUtil';
import { LogUtil } from '../../utils/LogUtil';
import { AttendanceService } from '../../services/api/attendance';

interface ScanData {
  type: string;
  studentId?: number;
  sessionId?: number;
  action?: string;
}

@Entry
@Component
struct QRCodeScanPage {
  @State isScanning: boolean = false;
  @State scanResult: string = '';
  @State hasCameraPermission: boolean = false;
  @State showPermissionDialog: boolean = false;
  @State showManualInput: boolean = false;
  @State manualCode: string = '';

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  async aboutToAppear() {
    await this.checkAndRequestPermission();
  }

  async checkAndRequestPermission() {
    const hasPermission = await PermissionUtil.checkCameraPermission(this.context);
    
    if (hasPermission) {
      this.hasCameraPermission = true;
      this.startScanning();
    } else {
      this.showPermissionDialog = true;
    }
  }

  async requestPermission() {
    const granted = await PermissionUtil.requestCameraPermission(this.context);
    
    if (granted) {
      this.hasCameraPermission = true;
      this.showPermissionDialog = false;
      this.startScanning();
    } else {
      LogUtil.warn('QRCodeScanPage', 'Camera permission denied');
    }
  }

  startScanning() {
    this.isScanning = true;
    LogUtil.info('QRCodeScanPage', 'Started scanning');
  }

  stopScanning() {
    this.isScanning = false;
    LogUtil.info('QRCodeScanPage', 'Stopped scanning');
  }

  async handleScanResult(result: string) {
    this.scanResult = result;
    this.isScanning = false;
    
    LogUtil.info('QRCodeScanPage', `Scan result: ${result}`);
    
    try {
      // 解析二维码内容
      const scanData: ScanData = JSON.parse(result);
      
      if (scanData.type === 'ATTENDANCE' && scanData.studentId && scanData.sessionId) {
        // 处理签到签退
        await this.handleAttendance(scanData);
      } else if (scanData.type === 'STUDENT' && scanData.studentId) {
        // 查看学生信息
        router.pushUrl({
          url: 'pages/teacher/TeacherStudentDetailPage',
          params: { studentId: scanData.studentId }
        });
      } else {
        LogUtil.warn('QRCodeScanPage', `Unknown QR code type: ${scanData.type}`);
      }
    } catch (error) {
      const err = error as Error;
      LogUtil.error('QRCodeScanPage', `Parse scan result failed: ${err.message}`);
    }
  }

  async handleAttendance(scanData: ScanData) {
    if (!scanData.studentId || !scanData.sessionId) {
      LogUtil.error('QRCodeScanPage', 'Invalid scan data: missing studentId or sessionId');
      return;
    }

    try {
      if (scanData.action === 'SIGN_OUT') {
        // 签退
        const resp = await AttendanceService.signOut({
          studentId: scanData.studentId,
          sessionId: scanData.sessionId,
          signMethod: 'QRCODE'
        });

        if (resp.code === 0) {
          LogUtil.info('QRCodeScanPage', 'Sign out successful');
          router.back();
        } else {
          LogUtil.error('QRCodeScanPage', `Sign out failed: ${resp.message}`);
        }
      } else {
        // 签到
        const resp = await AttendanceService.signIn({
          studentId: scanData.studentId,
          sessionId: scanData.sessionId,
          signMethod: 'QRCODE'
        });

        if (resp.code === 0) {
          LogUtil.info('QRCodeScanPage', 'Sign in successful');
          router.back();
        } else {
          LogUtil.error('QRCodeScanPage', `Sign in failed: ${resp.message}`);
        }
      }
    } catch (error) {
      const err = error as Error;
      LogUtil.error('QRCodeScanPage', `Handle attendance failed: ${err.message}`);
    }
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Content
      if (this.showPermissionDialog) {
        this.buildPermissionDialog()
      } else if (this.hasCameraPermission) {
        this.buildScanner()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width($r('app.float.icon_large_size'))
        .height($r('app.float.icon_large_size'))
        .fillColor(Color.White)
        .onClick(() => router.back())

      Text('扫码签到')
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank().width($r('app.float.icon_large_size'))
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.Transparent)
  }

  @Builder
  buildPermissionDialog() {
    Column() {
      Image($r('app.media.ic_qrcode'))
        .width(80)
        .height(80)
        .fillColor($r('app.color.primary'))
        .margin({ bottom: 24 })

      Text('需要相机权限')
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })

      Text('为了扫描二维码进行签到签退，请授权使用相机')
        .fontSize(14)
        .fontColor('#CCCCCC')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 32 })

      Button('授权使用相机')
        .width('60%')
        .height(44)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(22)
        .onClick(() => this.requestPermission())
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 32, right: 32 })
  }

  @Builder
  buildScanner() {
    Stack() {
      // 模拟相机预览区域
      Column() {
        Text('将二维码放入框内')
          .fontSize(16)
          .fontColor(Color.White)
          .margin({ top: 120 })

        // 扫描框
        Column() {
          // 扫描线动画
          if (this.isScanning) {
            Column()
              .width('100%')
              .height(2)
              .backgroundColor($r('app.color.primary'))
              .shadow({ radius: 10, color: $r('app.color.primary'), offsetX: 0, offsetY: 0 })
          }
        }
        .width(250)
        .height(250)
        .borderWidth(2)
        .borderColor(Color.White)
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 32 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)

      // Bottom actions
      Column() {
        Row() {
          // 手动输入
          Column() {
            Image($r('app.media.ic_edit'))
              .width(24)
              .height(24)
              .fillColor(Color.White)

            Text('手动输入')
              .fontSize(12)
              .fontColor(Color.White)
              .margin({ top: 8 })
          }
          .onClick(() => {
            this.showManualInput = true;
          })

          Blank().width(60)

          // 相册选择
          Column() {
            Image($r('app.media.ic_default_avatar'))
              .width(24)
              .height(24)
              .fillColor(Color.White)

            Text('相册')
              .fontSize(12)
              .fontColor(Color.White)
              .margin({ top: 8 })
          }
        }
        .width('100%')
        .padding({ left: 80, right: 80, bottom: 40 })
      }
      .width('100%')
    }
    .width('100%')
    .layoutWeight(1)
  }
}
