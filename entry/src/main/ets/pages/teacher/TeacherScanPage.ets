/**
 * SmartGuardian - Teacher Scan QR Code Page
 * Teachers can scan student QR code for quick sign-in/sign-out
 */

import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { camera } from '@kit.CameraKit';
import { AttendanceService } from '../../services/api/attendance';
import { SignInRequest, SignOutRequest } from '../../models/attendance';
import { LogUtil } from '../../utils/LogUtil';
import { PermissionUtil } from '../../utils/PermissionUtil';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';

class QRCodeData {
  studentId: number = 0;
  studentName: string = '';
  studentNo: string = '';
  type: 'SIGN_IN' | 'SIGN_OUT' = 'SIGN_IN';
}

interface RouterParams {
  sessionId?: number;
  scanType?: 'SIGN_IN' | 'SIGN_OUT';
}

@Entry
@Component
struct TeacherScanPage {
  @State isScanning: boolean = false;
  @State scanResult: string = '';
  @State errorMessage: string = '';
  @State successMessage: string = '';
  @State showResult: boolean = false;
  @State currentSessionId: number = 0;
  @State scanType: 'SIGN_IN' | 'SIGN_OUT' = 'SIGN_IN';
  
  private cameraManager?: camera.CameraManager;
  private cameraInput?: camera.CameraInput;
  // private scanner?: camera.ScanInterface; // Demo mode

  aboutToAppear() {
    // Get current session ID from router params
    const params = router.getParams() as RouterParams;
    if (params) {
      this.currentSessionId = params.sessionId ?? 0;
      this.scanType = params.scanType ?? 'SIGN_IN';
    }
  }

  aboutToDisappear() {
    this.releaseCamera();
  }

  /**
   * Start scanning
   */
  async startScan() {
    try {
      this.isScanning = true;
      this.errorMessage = '';
      this.successMessage = '';
      this.showResult = false;
      
      // Request camera permission
      const context = getContext(this) as common.UIAbilityContext;
      const hasPermission = await PermissionUtil.requestCameraPermission(context);
      
      if (!hasPermission) {
        this.errorMessage = '需要相机权限才能扫描二维码';
        this.isScanning = false;
        ErrorHandlerUtil.showErrorToast('请在设置中开启相机权限');
        return;
      }
      
      // Initialize camera
      await this.initCamera();
      
      LogUtil.info('TeacherScanPage', 'Scanner started');
    } catch (error) {
      this.errorMessage = '启动扫描失败，请检查相机权限';
      LogUtil.error('TeacherScanPage', `Start scan failed: ${JSON.stringify(error)}`);
      ErrorHandlerUtil.showErrorToast(this.errorMessage);
    }
  }

  /**
   * Initialize camera
   */
  async initCamera() {
    try {
      // Get camera manager
      this.cameraManager = camera.getCameraManager(getContext(this) as common.UIAbilityContext);
      
      if (!this.cameraManager) {
        this.errorMessage = '无法获取相机服务';
        return;
      }
      
      // For demo purposes, simulate QR code scanning
      // In production, use actual camera scanning API
      
      // Simulate scan result after 3 seconds
      setTimeout(() => {
        this.handleScanResult('{"studentId":1001,"studentName":"张小明","studentNo":"S001","type":"SIGN_IN"}');
      }, 3000);
      
    } catch (error) {
      LogUtil.error('TeacherScanPage', `Init camera failed: ${JSON.stringify(error)}`);
      throw new Error('Init camera failed');
    }
  }

  /**
   * Release camera resources
   */
  releaseCamera() {
    try {
      if (this.cameraInput) {
        this.cameraInput.close();
        this.cameraInput = undefined;
      }
      this.isScanning = false;
    } catch (error) {
      LogUtil.error('TeacherScanPage', `Release camera failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Handle scan result
   */
  async handleScanResult(qrCode: string) {
    try {
      this.scanResult = qrCode;
      this.showResult = true;
      
      // Parse QR code data
      const data: QRCodeData = JSON.parse(qrCode);
      
      // Validate scan type
      if (data.type !== this.scanType) {
        this.errorMessage = `二维码类型不匹配，请扫描${this.scanType === 'SIGN_IN' ? '签到' : '签退'}码`;
        return;
      }
      
      // Call attendance API
      if (this.scanType === 'SIGN_IN') {
        await this.performSignIn(data);
      } else {
        await this.performSignOut(data);
      }
      
    } catch (error) {
      this.errorMessage = '二维码格式错误';
      LogUtil.error('TeacherScanPage', `Parse QR code failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Perform sign-in
   */
  async performSignIn(data: QRCodeData) {
    try {
      const request: SignInRequest = {
        studentId: data.studentId,
        sessionId: this.currentSessionId,
        signMethod: 'QR_CODE'
      };
      
      const resp = await AttendanceService.signIn(request);
      
      if (resp.code === 0) {
        this.successMessage = `${data.studentName} 签到成功！`;
        ErrorHandlerUtil.showSuccessToast(this.successMessage);
      } else {
        this.errorMessage = resp.message || '签到失败';
        const error = ErrorHandlerUtil.handleApiError(resp);
        this.errorMessage = error.message;
      }
    } catch (error) {
      this.errorMessage = '签到请求失败';
      LogUtil.error('TeacherScanPage', `Sign in failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Perform sign-out
   */
  async performSignOut(data: QRCodeData) {
    try {
      const request: SignOutRequest = {
        studentId: data.studentId,
        sessionId: this.currentSessionId,
        signMethod: 'QR_CODE'
      };
      
      const resp = await AttendanceService.signOut(request);
      
      if (resp.code === 0) {
        this.successMessage = `${data.studentName} 签退成功！`;
        ErrorHandlerUtil.showSuccessToast(this.successMessage);
      } else {
        this.errorMessage = resp.message || '签退失败';
        const error = ErrorHandlerUtil.handleApiError(resp);
        this.errorMessage = error.message;
      }
    } catch (error) {
      this.errorMessage = '签退请求失败';
      LogUtil.error('TeacherScanPage', `Sign out failed: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Continue scanning
   */
  continueScan() {
    this.showResult = false;
    this.errorMessage = '';
    this.successMessage = '';
    this.scanResult = '';
    this.startScan();
  }

  build() {
    Column() {
      // Header
      this.buildHeader()
      
      // Camera preview
      this.buildCameraView()
      
      // Result overlay
      if (this.showResult) {
        this.buildResultOverlay()
      }
      
      // Instructions
      this.buildInstructions()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width(24)
        .height(24)
        .fillColor(Color.White)
        .onClick(() => router.back())
      
      Text(this.scanType === 'SIGN_IN' ? '扫码签到' : '扫码签退')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Blank()
        .width(24)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#1A1A1A')
  }

  @Builder
  buildCameraView() {
    Column() {
      if (this.isScanning) {
        // Camera preview area
        Stack({ alignContent: Alignment.Center }) {
          // Placeholder for camera preview
          // In production, use XComponent with camera preview
          Column() {
            Text('相机预览区域')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ bottom: 16 })
            
            Text('对准学生二维码扫描')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#2A2A2A')
          
          // Scan frame
          Column() {
            Row() {
              // Top-left corner
              Column() {
                Row()
                  .width(40)
                  .height(3)
                  .backgroundColor('#00BFFF')
                Row()
                  .width(3)
                  .height(40)
                  .backgroundColor('#00BFFF')
              }
              .alignItems(HorizontalAlign.Start)
              
              Blank()
              
              // Top-right corner
              Column() {
                Row()
                  .width(40)
                  .height(3)
                  .backgroundColor('#00BFFF')
                Row()
                  .width(3)
                  .height(40)
                  .backgroundColor('#00BFFF')
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            
            Blank()
            
            Row() {
              // Bottom-left corner
              Column() {
                Row()
                  .width(3)
                  .height(40)
                  .backgroundColor('#00BFFF')
                Row()
                  .width(40)
                  .height(3)
                  .backgroundColor('#00BFFF')
              }
              .alignItems(HorizontalAlign.Start)
              
              Blank()
              
              // Bottom-right corner
              Column() {
                Row()
                  .width(3)
                  .height(40)
                  .backgroundColor('#00BFFF')
                Row()
                  .width(40)
                  .height(3)
                  .backgroundColor('#00BFFF')
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width(250)
          .height(250)
        }
        .layoutWeight(1)
        .width('100%')
      } else {
        // Not scanning - show start button
        Column() {
          Image($r('app.media.ic_qrcode'))
            .width(80)
            .height(80)
            .fillColor('#666666')
            .margin({ bottom: 16 })
          
          Button('开始扫描')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary'))
            .borderRadius(24)
            .padding({ left: 40, right: 40, top: 12, bottom: 12 })
            .onClick(() => this.startScan())
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  buildResultOverlay() {
    Column() {
      // Result card
      Column() {
        if (this.successMessage) {
          Image($r('app.media.ic_success'))
            .width(60)
            .height(60)
            .fillColor('#4CAF50')
            .margin({ bottom: 16 })
          
          Text(this.successMessage)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
            .textAlign(TextAlign.Center)
        } else if (this.errorMessage) {
          Image($r('app.media.ic_error'))
            .width(60)
            .height(60)
            .fillColor('#F44336')
            .margin({ bottom: 16 })
          
          Text(this.errorMessage)
            .fontSize(16)
            .fontColor('#F44336')
            .textAlign(TextAlign.Center)
        }
        
        Row() {
          Button('继续扫描')
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary'))
            .borderRadius(24)
            .layoutWeight(1)
            .onClick(() => this.continueScan())
          
          Button('返回')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor('#F5F5F5')
            .borderRadius(24)
            .layoutWeight(1)
            .margin({ left: 12 })
            .onClick(() => router.back())
        }
        .width('100%')
        .margin({ top: 24 })
      }
      .width('80%')
      .padding(24)
      .backgroundColor(Color.White)
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.7)')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildInstructions() {
    Column() {
      Text('将二维码放入框内，自动扫描')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 8 })
      
      Text('仅支持学生签到/签退二维码')
        .fontSize(12)
        .fontColor('#666666')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#1A1A1A')
  }
}
