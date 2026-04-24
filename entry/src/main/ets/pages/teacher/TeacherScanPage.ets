/**
 * SmartGuardian - Teacher Scan QR Code Page
 * Teachers can scan student QR code for quick sign-in/sign-out
 */

import { scanCore, scanBarcode } from '@kit.ScanKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
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

class RouterParams {
  sessionId: number = 0;
  scanType: 'SIGN_IN' | 'SIGN_OUT' = 'SIGN_IN';
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

  aboutToAppear(): void {
    const rawParams: Object | undefined = this.getUIContext().getRouter().getParams();
    if (rawParams) {
      const params: RouterParams = rawParams as RouterParams;
      this.currentSessionId = params.sessionId;
      this.scanType = params.scanType;
    }
  }

  async startScan(): Promise<void> {
    try {
      this.isScanning = true;
      this.errorMessage = '';
      this.successMessage = '';
      this.showResult = false;
      this.scanResult = '';

      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const hasPermission: boolean = await PermissionUtil.requestCameraPermission(context);
      if (!hasPermission) {
        this.isScanning = false;
        this.errorMessage = $r('app.string.teacher_scan_camera_required').toString();
        ErrorHandlerUtil.showErrorToast($r('app.string.teacher_scan_open_settings').toString());
        return;
      }

      const options: scanBarcode.ScanOptions = {
        scanTypes: [scanCore.ScanType.ALL],
        enableMultiMode: false,
        enableAlbum: true
      };

      const hostContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const result: scanBarcode.ScanResult = await scanBarcode.startScanForResult(hostContext, options);
      hilog.info(0x0001, '[TeacherScanPage]', `Succeeded in getting scanResult, result is ${JSON.stringify(result)}`);

      this.isScanning = false;
      await this.handleScanResult(JSON.stringify(result));
    } catch (error) {
      this.isScanning = false;
      const businessError: BusinessError = error as BusinessError;
      if (this.isScanCancelled(businessError)) {
        this.errorMessage = $r('app.string.scan_cancelled').toString();
        ErrorHandlerUtil.showErrorToast($r('app.string.scan_cancelled_retry').toString());
        LogUtil.info('TeacherScanPage', 'User cancelled scan');
        return;
      }
      this.errorMessage = $r('app.string.scan_start_failed_retry').toString();
      LogUtil.error('TeacherScanPage', `Start scan failed: ${businessError.code}, ${businessError.message}`);
      hilog.error(0x0001, '[TeacherScanPage]', `Failed to start scan. Code: ${businessError.code}, message: ${businessError.message}`);
      ErrorHandlerUtil.showErrorToast(this.errorMessage);
    }
  }

  async handleScanResult(resultText: string): Promise<void> {
    try {
      this.scanResult = resultText;
      this.showResult = true;

      const scanResult: scanBarcode.ScanResult = JSON.parse(resultText) as scanBarcode.ScanResult;
      const originalValue: string = this.extractScanValue(scanResult);
      if (originalValue.length === 0) {
        this.errorMessage = $r('app.string.scan_no_content').toString();
        return;
      }

      const data: QRCodeData = JSON.parse(originalValue) as QRCodeData;

      if (data.type !== this.scanType) {
        this.errorMessage = this.scanType === 'SIGN_IN'
          ? $r('app.string.teacher_scan_type_mismatch_sign_in').toString()
          : $r('app.string.teacher_scan_type_mismatch_sign_out').toString();
        return;
      }

      if (this.scanType === 'SIGN_IN') {
        await this.performSignIn(data);
      } else {
        await this.performSignOut(data);
      }
    } catch (error) {
      this.errorMessage = $r('app.string.scan_format_error').toString();
      LogUtil.error('TeacherScanPage', `Parse QR code failed: ${JSON.stringify(error)}`);
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

  async performSignIn(data: QRCodeData): Promise<void> {
    try {
      const request: SignInRequest = {
        studentId: data.studentId,
        sessionId: this.currentSessionId,
        signMethod: 'QR_CODE'
      };

      const resp = await AttendanceService.signIn(request);

      if (resp.code === 0) {
        this.successMessage = `${data.studentName}${$r('app.string.teacher_scan_sign_in_success_suffix').toString()}`;
        ErrorHandlerUtil.showSuccessToast(this.successMessage);
      } else {
        this.errorMessage = resp.message ? resp.message : $r('app.string.attendance_sign_in_failed').toString();
        const handledError = ErrorHandlerUtil.handleApiError(resp);
        this.errorMessage = handledError.message;
      }
    } catch (error) {
      this.errorMessage = $r('app.string.teacher_scan_sign_in_request_failed').toString();
      LogUtil.error('TeacherScanPage', `Sign in failed: ${JSON.stringify(error)}`);
    }
  }

  async performSignOut(data: QRCodeData): Promise<void> {
    try {
      const request: SignOutRequest = {
        studentId: data.studentId,
        sessionId: this.currentSessionId,
        signMethod: 'QR_CODE'
      };

      const resp = await AttendanceService.signOut(request);

      if (resp.code === 0) {
        this.successMessage = `${data.studentName}${$r('app.string.teacher_scan_sign_out_success_suffix').toString()}`;
        ErrorHandlerUtil.showSuccessToast(this.successMessage);
      } else {
        this.errorMessage = resp.message ? resp.message : $r('app.string.attendance_sign_out_failed').toString();
        const handledError = ErrorHandlerUtil.handleApiError(resp);
        this.errorMessage = handledError.message;
      }
    } catch (error) {
      this.errorMessage = $r('app.string.teacher_scan_sign_out_request_failed').toString();
      LogUtil.error('TeacherScanPage', `Sign out failed: ${JSON.stringify(error)}`);
    }
  }

  continueScan(): void {
    this.showResult = false;
    this.errorMessage = '';
    this.successMessage = '';
    this.scanResult = '';
    this.startScan();
  }

  build() {
    Column() {
      this.buildHeader()
      this.buildScanIntro()

      if (this.showResult) {
        this.buildResultOverlay()
      }

      this.buildInstructions()
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

      Text(this.scanType === 'SIGN_IN' ? $r('app.string.scan_sign_in_title') : $r('app.string.scan_sign_out_title'))
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.scan_text_light'))
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank()
        .width($r('app.float.icon_large_size'))
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor($r('app.color.scan_header_background'))
  }

  @Builder
  buildScanIntro() {
    Column() {
      Image($r('app.media.ic_qrcode'))
        .width($r('app.float.scan_qrcode_icon_size'))
        .height($r('app.float.scan_qrcode_icon_size'))
        .fillColor($r('app.color.scan_text_light'))
        .margin({ bottom: $r('app.float.scan_section_gap_small') })

      Text(this.scanType === 'SIGN_IN' ? $r('app.string.scan_teacher_sign_in_intro') : $r('app.string.scan_teacher_sign_out_intro'))
        .fontSize($r('app.float.scan_intro_title_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.scan_text_light'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: $r('app.float.scan_section_gap_xsmall') })

      Text($r('app.string.scan_album_supported'))
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.scan_text_hint'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: $r('app.float.scan_section_gap_large') })

      Button(this.isScanning ? $r('app.string.scan_starting_button') : $r('app.string.scan_start_button'))
        .fontSize($r('app.float.button_text_size'))
        .fontColor($r('app.color.scan_text_light'))
        .backgroundColor($r('app.color.primary'))
        .borderRadius($r('app.float.scan_button_radius_xlarge'))
        .padding({
          left: $r('app.float.layout_button_padding_horizontal_large'),
          right: $r('app.float.layout_button_padding_horizontal_large'),
          top: $r('app.float.layout_button_padding_vertical_medium'),
          bottom: $r('app.float.layout_button_padding_vertical_medium')
        })
        .constraintSize({ maxWidth: $r('app.float.layout_button_max_width_medium') })
        .enabled(!this.isScanning)
        .onClick(() => this.startScan())
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({
      left: $r('app.float.layout_content_side_padding_compact'),
      right: $r('app.float.layout_content_side_padding_compact')
    })
  }

  @Builder
  buildResultOverlay() {
    Column() {
      Column() {
        if (this.successMessage.length > 0) {
          Image($r('app.media.ic_success'))
            .width($r('app.float.scan_result_icon_size'))
            .height($r('app.float.scan_result_icon_size'))
            .fillColor($r('app.color.status_completed'))
            .margin({ bottom: $r('app.float.page_padding') })

          Text(this.successMessage)
            .fontSize($r('app.float.card_title_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.status_completed'))
            .textAlign(TextAlign.Center)
        } else if (this.errorMessage.length > 0) {
          Image($r('app.media.ic_error'))
            .width($r('app.float.scan_result_icon_size'))
            .height($r('app.float.scan_result_icon_size'))
            .fillColor($r('app.color.error'))
            .margin({ bottom: $r('app.float.page_padding') })

          Text(this.errorMessage)
            .fontSize($r('app.float.text_primary_size'))
            .fontColor($r('app.color.error'))
            .textAlign(TextAlign.Center)
        }

        Row() {
          Button($r('app.string.scan_continue'))
            .fontSize($r('app.float.button_text_size'))
            .fontColor($r('app.color.scan_text_light'))
            .backgroundColor($r('app.color.primary'))
            .borderRadius($r('app.float.scan_button_radius_xlarge'))
            .layoutWeight(1)
            .onClick(() => this.continueScan())

          Button($r('app.string.common_back'))
            .fontSize($r('app.float.button_text_size'))
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor($r('app.color.scan_result_secondary_button_bg'))
            .borderRadius($r('app.float.scan_button_radius_xlarge'))
            .layoutWeight(1)
            .margin({ left: $r('app.float.card_margin') })
            .onClick(() => this.getUIContext().getRouter().back())
        }
        .width('100%')
        .margin({ top: $r('app.float.scan_error_top_margin') })
      }
      .width('100%')
      .constraintSize({ maxWidth: $r('app.float.layout_dialog_max_width_medium') })
      .padding($r('app.float.scan_result_dialog_padding'))
      .backgroundColor($r('app.color.card_background'))
      .borderRadius($r('app.float.scan_dialog_radius'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.scan_overlay_background'))
    .justifyContent(FlexAlign.Center)
    .padding($r('app.float.page_padding'))
  }

  @Builder
  buildInstructions() {
    Column() {
      Text($r('app.string.scan_instruction_open_official'))
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.scan_text_hint'))
        .margin({ bottom: $r('app.float.scan_instruction_gap') })

      Text($r('app.string.scan_instruction_student_only'))
        .fontSize($r('app.float.text_tiny_size'))
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor($r('app.color.scan_header_background'))
  }
}

