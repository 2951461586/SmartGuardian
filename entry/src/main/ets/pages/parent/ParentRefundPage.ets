import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import {
  FormActionBar,
  HeaderTheme,
  InfoCard,
  InfoItem,
  PageHeader,
  PageScaffold,
  RefundAmountSummaryCard,
  RefundHistorySection,
  RefundReasonSection,
  SectionHeader,
  ViewState
} from '../../components/common';
import { CreateRefundParams, RefundReasonType, RefundRecord } from '../../models/refund';
import { RefundService } from '../../services/api/refund';

interface RouterParams {
  orderId?: number;
  orderNo?: string;
  serviceName?: string;
  amount?: number;
}

@Entry
@Component
struct ParentRefundPage {
  @State orderId: number = 0;
  @State orderNo: string = '';
  @State serviceName: string = '';
  @State orderAmount: number = 0;
  @State refundAmount: number = 0;
  @State deduction: number = 0;
  @State selectedReasonType: string = RefundReasonType.PERSONAL_REASON;
  @State reason: string = '';
  @State description: string = '';
  @State isSubmitting: boolean = false;
  @State refundRecords: RefundRecord[] = [];
  @State historyLoaded: boolean = false;

  aboutToAppear() {
    const params = this.getUIContext().getRouter().getParams() as RouterParams;
    if (params) {
      this.orderId = params.orderId || 0;
      this.orderNo = params.orderNo || '';
      this.serviceName = params.serviceName || '';
      this.orderAmount = params.amount || 0;
      this.calculateRefund();
    }
    this.loadRefundRecords();
  }

  async calculateRefund() {
    try {
      const resp = await RefundService.calculateRefundAmount(this.orderId);
      if (resp.code === 0 && resp.data) {
        this.refundAmount = resp.data.refundAmount;
        this.deduction = resp.data.deduction;
      } else {
        this.applyFallbackRefundAmount();
      }
    } catch (error) {
      console.error('Failed to calculate refund:', String(error));
      this.applyFallbackRefundAmount();
    }
  }

  private applyFallbackRefundAmount(): void {
    this.refundAmount = this.orderAmount * 0.9;
    this.deduction = this.orderAmount * 0.1;
  }

  async loadRefundRecords() {
    this.historyLoaded = false;
    try {
      const resp = await RefundService.getRefunds({ orderId: this.orderId });
      if (resp.code === 0 && resp.data && resp.data.list) {
        this.refundRecords = resp.data.list;
      } else {
        this.refundRecords = [];
      }
    } catch (error) {
      console.error('Failed to load refund records:', String(error));
      this.refundRecords = [];
    } finally {
      this.historyLoaded = true;
    }
  }

  async submitRefund() {
    if (!this.reason.trim()) {
      return;
    }

    this.isSubmitting = true;
    try {
      const params: CreateRefundParams = {
        orderId: this.orderId,
        refundAmount: this.refundAmount,
        reasonType: this.selectedReasonType,
        reason: this.reason.trim(),
        description: this.description.trim()
      };

      const resp = await RefundService.createRefund(params);
      if (resp.code === 0) {
        this.getUIContext().getRouter().back();
      }
    } catch (error) {
      console.error('Failed to submit refund:', String(error));
    } finally {
      this.isSubmitting = false;
    }
  }

  private getOrderInfoItems(): InfoItem[] {
    return [
      { label: '订单编号', value: this.orderNo || '--' },
      { label: '服务名称', value: this.serviceName || '--' },
      { label: '订单金额', value: `¥${this.orderAmount.toFixed(2)}` },
      { label: '退款方式', value: '原路退回' }
    ];
  }

  private getRefundLabel(type: string): string {
    if (type === RefundReasonType.STUDENT_TRANSFER) {
      return '学生转学';
    }
    if (type === RefundReasonType.SERVICE_QUALITY) {
      return '服务质量问题';
    }
    if (type === RefundReasonType.SCHEDULE_CHANGE) {
      return '时间安排变更';
    }
    if (type === RefundReasonType.PERSONAL_REASON) {
      return '个人原因';
    }
    return '其他原因';
  }

  private getStatusText(status: string): string {
    if (status === 'PENDING') {
      return '待审核';
    }
    if (status === 'APPROVED') {
      return '已批准';
    }
    if (status === 'REJECTED') {
      return '已拒绝';
    }
    if (status === 'PROCESSING') {
      return '退款中';
    }
    if (status === 'COMPLETED') {
      return '已完成';
    }
    if (status === 'CANCELLED') {
      return '已取消';
    }
    return '未知状态';
  }

  private getStatusColor(status: string): string {
    if (status === 'COMPLETED' || status === 'APPROVED') {
      return HarmonyReport.positive;
    }
    if (status === 'PENDING' || status === 'PROCESSING') {
      return HarmonyReport.caution;
    }
    if (status === 'REJECTED' || status === 'CANCELLED') {
      return HarmonyReport.danger;
    }
    return HarmonyColor.textSecondary;
  }

  private getHistoryViewState(): ViewState {
    if (!this.historyLoaded) {
      return ViewState.LOADING;
    }
    if (this.refundRecords.length === 0) {
      return ViewState.EMPTY;
    }
    return ViewState.CONTENT;
  }

  private getReasonTypes(): string[] {
    return [
      RefundReasonType.STUDENT_TRANSFER,
      RefundReasonType.SERVICE_QUALITY,
      RefundReasonType.SCHEDULE_CHANGE,
      RefundReasonType.PERSONAL_REASON,
      RefundReasonType.OTHER
    ];
  }

  build() {
    Column() {
      PageScaffold({
        scrollable: false,
        enableWideContent: true,
        header: this.buildHeader,
        content: this.buildPageBody,
        footer: this.buildFooter,
        showFooterDivider: true
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildHeader() {
    PageHeader({
      title: '申请退款',
      subtitle: '填写退款原因并查看可退金额与历史记录。',
      showBack: true,
      onBackClick: () => this.getUIContext().getRouter().back(),
      theme: HeaderTheme.WHITE
    })
  }

  @Builder
  private buildPageBody() {
    Scroll() {
      Column() {
        this.buildOrderInfo()
        this.buildAmountInfo()

        RefundReasonSection({
          reasonTypes: this.getReasonTypes(),
          selectedReasonType: this.selectedReasonType,
          reason: this.reason,
          description: this.description,
          labelResolver: (type: string): string => this.getRefundLabel(type),
          onTypeSelect: (type: string): void => {
            this.selectedReasonType = type;
          },
          onReasonChange: (value: string): void => {
            this.reason = value;
          },
          onDescriptionChange: (value: string): void => {
            this.description = value;
          }
        })

        RefundHistorySection({
          viewState: this.getHistoryViewState(),
          records: this.refundRecords,
          statusTextResolver: (status: string): string => this.getStatusText(status),
          statusColorResolver: (status: string): string => this.getStatusColor(status)
        })
      }
      .width('100%')
      .padding({ top: 16, bottom: 20 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  private buildOrderInfo() {
    Column() {
      SectionHeader({
        title: '订单概览',
        subtitle: '提交退款前先核对当前订单和服务信息。'
      })

      InfoCard({
        items: this.getOrderInfoItems(),
        columns: 2
      })
    }
    .width('100%')
  }

  @Builder
  private buildAmountInfo() {
    Column() {
      SectionHeader({
        title: '退款测算',
        subtitle: '系统会根据当前规则自动计算预计退款金额。'
      })

      RefundAmountSummaryCard({
        orderAmount: this.orderAmount,
        deduction: this.deduction,
        refundAmount: this.refundAmount
      })
    }
    .width('100%')
  }

  @Builder
  private buildFooter() {
    FormActionBar({
      primaryText: this.isSubmitting ? '提交中...' : '提交退款申请',
      helperText: '审核通过后，预计 1-5 个工作日内完成退款。',
      primaryEnabled: this.reason.trim().length > 0 && !this.isSubmitting,
      loading: this.isSubmitting,
      onPrimary: () => {
        this.submitRefund();
      }
    })
      .padding({ left: 16, right: 16, top: 12, bottom: 18 })
      .backgroundColor(HarmonyColor.surface)
  }
}
