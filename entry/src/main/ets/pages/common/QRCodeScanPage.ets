/**
 * SmartGuardian - QR Code Scan Page
 * Scan QR code for sign in/sign out
 */

import { common } from '@kit.AbilityKit';
import { scanCore, scanBarcode } from '@kit.ScanKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { PermissionUtil } from '../../utils/PermissionUtil';
import { LogUtil } from '../../utils/LogUtil';
import { AttendanceService } from '../../services/api/attendance';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';
import { ErrorMessages } from '../../constants/ErrorMessages';

class ScanData {
  type: string = '';
  studentId: number = 0;
  sessionId: number = 0;
  action: string = '';
}

@Entry
@Component
struct QRCodeScanPage {
  @State isScanning: boolean = false;
  @State scanResult: string = '';
  @State hasCameraPermission: boolean = false;
  @State showPermissionDialog: boolean = false;
  @State errorMessage: string = '';

  async aboutToAppear(): Promise<void> {
    await this.checkAndRequestPermission();
  }

  async checkAndRequestPermission(): Promise<void> {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const hasPermission: boolean = await PermissionUtil.checkCameraPermission(context);

    if (hasPermission) {
      this.hasCameraPermission = true;
      await this.startScanning();
    } else {
      this.showPermissionDialog = true;
    }
  }

  async requestPermission(): Promise<void> {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const granted: boolean = await PermissionUtil.requestCameraPermission(context);

    if (granted) {
      this.hasCameraPermission = true;
      this.showPermissionDialog = false;
      await this.startScanning();
    } else {
      this.errorMessage = $r('app.string.scan_permission_denied').toString();
      ErrorHandlerUtil.showErrorToast($r('app.string.scan_permission_grant_hint').toString());
      LogUtil.warn('QRCodeScanPage', 'Camera permission denied');
    }
  }

  async startScanning(): Promise<void> {
    if (this.isScanning) {
      return;
    }

    try {
      this.isScanning = true;
      this.errorMessage = '';
      this.scanResult = '';

      const options: scanBarcode.ScanOptions = {
        scanTypes: [scanCore.ScanType.ALL],
        enableMultiMode: false,
        enableAlbum: true
      };

      const hostContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const result: scanBarcode.ScanResult = await scanBarcode.startScanForResult(hostContext, options);
      this.isScanning = false;

      hilog.info(0x0001, '[QRCodeScanPage]', `Succeeded in getting scanResult, result is ${JSON.stringify(result)}`);
      await this.handleScanResult(result);
    } catch (error) {
      this.isScanning = false;
      const businessError: BusinessError = error as BusinessError;
      if (this.isScanCancelled(businessError)) {
        this.errorMessage = $r('app.string.scan_cancelled').toString();
        ErrorHandlerUtil.showErrorToast($r('app.string.scan_cancelled_retry').toString());
        LogUtil.info('QRCodeScanPage', 'User cancelled scan');
        return;
      }

      this.errorMessage = $r('app.string.scan_failed_retry').toString();
      ErrorHandlerUtil.showErrorToast(this.errorMessage);
      LogUtil.error('QRCodeScanPage', `Start scan failed: ${businessError.code}, ${businessError.message}`);
      hilog.error(0x0001, '[QRCodeScanPage]', `Failed to get scanResult. Code: ${businessError.code}, message: ${businessError.message}`);
    }
  }

  async handleScanResult(result: scanBarcode.ScanResult): Promise<void> {
    this.scanResult = JSON.stringify(result);
    LogUtil.info('QRCodeScanPage', `Scan result: ${this.scanResult}`);

    try {
      const rawValue: string = this.extractScanValue(result);
      if (rawValue.length === 0) {
        this.errorMessage = $r('app.string.scan_no_content').toString();
        ErrorHandlerUtil.showErrorToast(this.errorMessage);
        return;
      }

      const scanData: ScanData = JSON.parse(rawValue) as ScanData;

      if (scanData.type === 'ATTENDANCE' && scanData.studentId > 0 && scanData.sessionId > 0) {
        await this.handleAttendance(scanData);
      } else if (scanData.type === 'STUDENT' && scanData.studentId > 0) {
        this.getUIContext().getRouter().pushUrl({
          url: 'pages/teacher/TeacherStudentDetailPage',
          params: { studentId: scanData.studentId }
        });
      } else {
        this.errorMessage = $r('app.string.scan_unknown_type').toString();
        ErrorHandlerUtil.showErrorToast(this.errorMessage);
        LogUtil.warn('QRCodeScanPage', `Unknown QR code type: ${scanData.type}`);
      }
    } catch (error) {
      this.errorMessage = $r('app.string.scan_parse_failed').toString();
      ErrorHandlerUtil.showErrorToast(this.errorMessage);
      LogUtil.error('QRCodeScanPage', `Parse scan result failed: ${JSON.stringify(error)}`);
    }
  }

  async handleAttendance(scanData: ScanData): Promise<void> {
    try {
      if (scanData.action === 'SIGN_OUT') {
        const resp = await AttendanceService.signOut({
          studentId: scanData.studentId,
          sessionId: scanData.sessionId,
          signMethod: 'QR_CODE'
        });

        if (resp.code === 0) {
          ErrorHandlerUtil.showSuccessToast($r('app.string.attendance_sign_out_success').toString());
          LogUtil.info('QRCodeScanPage', 'Sign out successful');
          this.getUIContext().getRouter().back();
        } else {
          this.errorMessage = resp.message ? resp.message : $r('app.string.attendance_sign_out_failed').toString();
          ErrorHandlerUtil.showErrorToast(this.errorMessage);
          LogUtil.error('QRCodeScanPage', `Sign out failed: ${this.errorMessage}`);
        }
      } else {
        const resp = await AttendanceService.signIn({
          studentId: scanData.studentId,
          sessionId: scanData.sessionId,
          signMethod: 'QR_CODE'
        });

        if (resp.code === 0) {
          ErrorHandlerUtil.showSuccessToast($r('app.string.attendance_sign_in_success').toString());
          LogUtil.info('QRCodeScanPage', 'Sign in successful');
          this.getUIContext().getRouter().back();
        } else {
          this.errorMessage = resp.message ? resp.message : $r('app.string.attendance_sign_in_failed').toString();
          ErrorHandlerUtil.showErrorToast(this.errorMessage);
          LogUtil.error('QRCodeScanPage', `Sign in failed: ${this.errorMessage}`);
        }
      }
    } catch (error) {
      this.errorMessage = $r('app.string.attendance_process_failed').toString();
      ErrorHandlerUtil.showErrorToast(this.errorMessage);
      LogUtil.error('QRCodeScanPage', `Handle attendance failed: ${JSON.stringify(error)}`);
    }
  }

  private extractScanValue(result: scanBarcode.ScanResult): string {
    if (result.originalValue && result.originalValue.length > 0) {
      return result.originalValue;
    }

    return '';
  }

  private isScanCancelled(error: BusinessError): boolean {
    const errorMessage: string = error.message ? error.message : '';
    return errorMessage.indexOf('cancel') >= 0 || errorMessage.indexOf('Cancel') >= 0 || errorMessage.indexOf('取消') >= 0;
  }

  build() {
    Column() {
      this.buildHeader()

      if (this.showPermissionDialog) {
        this.buildPermissionDialog()
      } else if (this.hasCameraPermission) {
        this.buildScanner()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.scan_page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width($r('app.float.icon_large_size'))
        .height($r('app.float.icon_large_size'))
        .fillColor($r('app.color.scan_text_light'))
        .onClick(() => this.getUIContext().getRouter().back())

      Text($r('app.string.scan_sign_in_title'))
        .fontSize($r('app.float.page_title_size'))
        .fontColor($r('app.color.scan_text_light'))
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank().width($r('app.float.icon_large_size'))
    }
    .width('100%')
    .padding({
      left: $r('app.float.scan_header_horizontal_padding'),
      right: $r('app.float.scan_header_horizontal_padding'),
      top: $r('app.float.scan_header_vertical_padding'),
      bottom: $r('app.float.scan_header_vertical_padding')
    })
    .backgroundColor(Color.Transparent)
  }

  @Builder
  buildPermissionDialog() {
    Column() {
      Image($r('app.media.ic_qrcode'))
        .width($r('app.float.scan_permission_icon_size'))
        .height($r('app.float.scan_permission_icon_size'))
        .fillColor($r('app.color.primary'))
        .margin({ bottom: $r('app.float.scan_section_gap_medium') })

      Text($r('app.string.scan_permission_required'))
        .fontSize($r('app.float.page_title_size'))
        .fontColor($r('app.color.scan_text_light'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('app.float.scan_section_gap_xsmall') })

      Text($r('app.string.scan_permission_desc'))
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.scan_text_secondary'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: $r('app.float.scan_section_gap_large') })

      Button($r('app.string.scan_permission_button'))
        .width('100%')
        .constraintSize({ maxWidth: $r('app.float.layout_button_max_width_medium') })
        .height($r('app.float.scan_button_height'))
        .fontSize($r('app.float.button_text_size'))
        .fontColor($r('app.color.scan_text_light'))
        .backgroundColor($r('app.color.primary'))
        .borderRadius($r('app.float.scan_button_radius_large'))
        .onClick(() => this.requestPermission())
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({
      left: $r('app.float.layout_content_side_padding_regular'),
      right: $r('app.float.layout_content_side_padding_regular')
    })
  }

  @Builder
  buildScanner() {
    Column() {
      Image($r('app.media.ic_qrcode'))
        .width($r('app.float.scan_qrcode_icon_size'))
        .height($r('app.float.scan_qrcode_icon_size'))
        .fillColor($r('app.color.scan_text_light'))
        .margin({ bottom: $r('app.float.scan_section_gap_small') })

      Text($r('app.string.scan_page_intro'))
        .fontSize($r('app.float.scan_intro_title_size'))
        .fontColor($r('app.color.scan_text_light'))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .margin({ bottom: $r('app.float.scan_section_gap_xsmall') })

      Text($r('app.string.scan_page_desc'))
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.scan_text_secondary'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: $r('app.float.scan_section_gap_large') })

      Button(this.isScanning ? $r('app.string.scan_starting_button') : $r('app.string.scan_start_button'))
        .width('100%')
        .constraintSize({ maxWidth: $r('app.float.layout_button_max_width_medium') })
        .height($r('app.float.scan_button_height'))
        .fontSize($r('app.float.button_text_size'))
        .fontColor($r('app.color.scan_text_light'))
        .backgroundColor($r('app.color.primary'))
        .borderRadius($r('app.float.scan_button_radius_large'))
        .enabled(!this.isScanning)
        .onClick(() => this.startScanning())

      if (this.errorMessage.length > 0) {
        Text(this.errorMessage)
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.scan_error_text'))
          .textAlign(TextAlign.Center)
          .margin({ top: $r('app.float.scan_error_top_margin') })
      }
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({
      left: $r('app.float.layout_content_side_padding_regular'),
      right: $r('app.float.layout_content_side_padding_regular')
    })
  }
}
