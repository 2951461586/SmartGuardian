/**
 * SmartGuardian - Admin Refunds Page
 * Admin refund monitoring workspace on the shared workbench template.
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import {
  AdminOverviewMetric,
  AdminOverviewMetricSection,
  AdminRefundListSection,
  AdminStatusFilterCard,
  HeaderTheme,
  PageHeader,
  StatefulContainer,
  ViewState,
  WorkbenchListPageTemplate
} from '../../components/common';
import { RefundQueryParams, RefundRecord, RefundStatistics } from '../../models/refund';
import { RefundService } from '../../services/api/refund';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';
import { LogUtil } from '../../utils/LogUtil';

@Entry
@Component
struct AdminRefundsPage {
  @State refunds: RefundRecord[] = [];
  @State statistics: RefundStatistics | null = null;
  @State isLoading: boolean = false;
  @State currentTab: number = 0;
  @State errorMessage: string = '';

  private readonly tabs: string[] = ['待处理', '退款中', '已完成', '全部'];

  aboutToAppear() {
    ErrorHandlerUtil.setUIContext(this.getUIContext());
    this.loadData();
  }

  private buildQueryParams(): RefundQueryParams {
    const params: RefundQueryParams = {
      pageNum: 1,
      pageSize: 100
    };
    if (this.currentTab === 0) {
      params.status = 'PENDING';
    } else if (this.currentTab === 1) {
      params.status = 'PROCESSING';
    } else if (this.currentTab === 2) {
      params.status = 'COMPLETED';
    }
    return params;
  }

  async loadData() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const refundsResponse = await RefundService.getRefunds(this.buildQueryParams());
      const statisticsResponse = await RefundService.getStatistics();

      if (refundsResponse.code === 0 && refundsResponse.data) {
        this.refunds = refundsResponse.data.list ? refundsResponse.data.list : [];
      } else {
        this.refunds = [];
        this.errorMessage = refundsResponse.message ? refundsResponse.message : '退款记录加载失败';
      }

      if (statisticsResponse.code === 0 && statisticsResponse.data) {
        this.statistics = statisticsResponse.data;
      } else {
        this.statistics = null;
      }
    } catch (error) {
      this.refunds = [];
      this.statistics = null;
      this.errorMessage = '退款记录加载失败，请稍后重试';
      LogUtil.error(`AdminRefundsPage loadData failed: ${String(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  async cancelRefund(refund: RefundRecord) {
    try {
      const response = await RefundService.cancelRefund({
        refundId: refund.id,
        reason: '管理员撤销测试退款申请'
      });
      if (response.code === 0) {
        ErrorHandlerUtil.showSuccessToast('退款申请已撤销');
        await this.loadData();
      } else {
        ErrorHandlerUtil.showErrorToast(response.message ? response.message : '撤销退款失败');
      }
    } catch (error) {
      LogUtil.error(`AdminRefundsPage cancelRefund failed: ${String(error)}`);
      ErrorHandlerUtil.showErrorToast('撤销退款失败');
    }
  }

  private getStatusText(status: string): string {
    if (status === 'PENDING') {
      return '待处理';
    }
    if (status === 'APPROVED') {
      return '已批准';
    }
    if (status === 'REJECTED') {
      return '已驳回';
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
    return status;
  }

  private getStatusColor(status: string): string {
    if (status === 'PENDING') {
      return HarmonyReport.caution;
    }
    if (status === 'PROCESSING') {
      return HarmonyColor.info;
    }
    if (status === 'COMPLETED') {
      return HarmonyReport.positive;
    }
    if (status === 'REJECTED' || status === 'CANCELLED') {
      return HarmonyReport.danger;
    }
    return HarmonyColor.textTertiary;
  }

  private getViewState(): ViewState {
    if (this.isLoading) {
      return ViewState.LOADING;
    }
    if (this.refunds.length === 0) {
      return ViewState.EMPTY;
    }
    return ViewState.CONTENT;
  }

  private getOverviewMetrics(): AdminOverviewMetric[] {
    return [
      {
        value: this.statistics ? this.statistics.pending : 0,
        label: '待处理',
        icon: $r('app.media.ic_refund'),
        iconColor: HarmonyReport.caution
      },
      {
        value: this.statistics ? this.statistics.processing : 0,
        label: '退款中',
        icon: $r('app.media.ic_refresh'),
        iconColor: HarmonyColor.info
      },
      {
        value: this.statistics ? `¥${Number(this.statistics.totalAmount).toFixed(0)}` : '¥0',
        label: '累计退款额',
        icon: $r('app.media.ic_money'),
        iconColor: HarmonyReport.positive
      }
    ];
  }

  build() {
    Column() {
      WorkbenchListPageTemplate({
        scrollable: false,
        enableWideContent: true,
        header: this.buildHeader,
        overview: this.buildOverviewSection,
        controls: this.buildFilterSection,
        content: this.buildRefundContent
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildHeader() {
    PageHeader({
      title: '退款管理',
      subtitle: '查看退款流转、金额规模与当前待处理申请。',
      showBack: true,
      onBackClick: () => this.getUIContext().getRouter().back(),
      theme: HeaderTheme.WHITE
    })
  }

  @Builder
  private buildOverviewSection() {
    AdminOverviewMetricSection({
      title: '退款概览',
      subtitle: '看待处理量、处理中规模和累计退款金额。',
      metrics: this.getOverviewMetrics()
    })
  }

  @Builder
  private buildFilterSection() {
    AdminStatusFilterCard({
      subtitle: '按流转状态查看退款积压，优先处理待办。',
      tabs: this.tabs,
      currentIndex: this.currentTab,
      onTabChange: (index: number) => {
        this.currentTab = index;
        this.loadData();
      }
    })
  }

  @Builder
  private buildRefundContent() {
    StatefulContainer({
      state: this.getViewState(),
      loadingMessage: '正在加载退款记录...',
      emptyTitle: '暂无退款记录',
      emptyDescription: this.errorMessage ? this.errorMessage : '当前筛选条件下没有退款申请。',
      emptyActionText: '刷新',
      onEmptyAction: () => {
        this.loadData();
      },
      content: this.buildRefundListSection
    })
      .layoutWeight(1)
  }

  @Builder
  private buildRefundListSection() {
    AdminRefundListSection({
      refunds: this.refunds,
      subtitle: this.errorMessage ? this.errorMessage : `当前共 ${this.refunds.length} 条退款记录`,
      statusTextResolver: (status: string): string => this.getStatusText(status),
      statusColorResolver: (status: string): string => this.getStatusColor(status),
      onCancel: (refund: RefundRecord) => {
        this.cancelRefund(refund);
      },
      onEmptyAction: () => {
        this.loadData();
      }
    })
  }
}
