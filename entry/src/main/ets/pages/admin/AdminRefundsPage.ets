/**
 * SmartGuardian - Admin Refunds Page
 * Admin refund monitoring workspace
 */

import {
  Card,
  EmptyState,
  EmptyType,
  HeaderTheme,
  LoadingSize,
  LoadingState,
  PageHeader,
  SectionHeader,
  StatCard,
  TabBar
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
      const refundsPromise = RefundService.getRefunds(this.buildQueryParams());
      const statisticsPromise = RefundService.getStatistics();
      const refundsResponse = await refundsPromise;
      const statisticsResponse = await statisticsPromise;

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
      return '#D97706';
    }
    if (status === 'PROCESSING') {
      return '#1F5EFF';
    }
    if (status === 'COMPLETED') {
      return '#15803D';
    }
    if (status === 'REJECTED' || status === 'CANCELLED') {
      return '#DC2626';
    }
    return '#7A879A';
  }

  build() {
    Column() {
      PageHeader({
        title: '退款管理',
        subtitle: '查看退款流转、金额规模与当前待处理申请。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY
      })

      if (this.isLoading) {
        LoadingState({
          loadingSize: LoadingSize.DEFAULT,
          message: '正在加载退款记录...'
        })
      } else {
        Scroll() {
          Column() {
            this.buildOverviewPanel()
            this.buildFilterPanel()
            this.buildRefundList()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 24 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildOverviewPanel() {
    Column() {
      SectionHeader({
        title: '退款概览',
        subtitle: '看待处理量、处理中规模和累计退款金额。'
      })

      Row() {
        StatCard({
          value: this.statistics ? this.statistics.pending : 0,
          label: '待处理',
          icon: $r('app.media.ic_refund'),
          iconColor: '#D97706'
        })
        .layoutWeight(1)

        StatCard({
          value: this.statistics ? this.statistics.processing : 0,
          label: '退款中',
          icon: $r('app.media.ic_refresh'),
          iconColor: '#1F5EFF'
        })
        .layoutWeight(1)
        .margin({ left: 12, right: 12 })

        StatCard({
          value: this.statistics ? `¥${Number(this.statistics.totalAmount).toFixed(0)}` : '¥0',
          label: '累计退款额',
          icon: $r('app.media.ic_money'),
          iconColor: '#15803D'
        })
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  private buildFilterPanel() {
    Card({
      title: '状态筛选',
      subtitle: '按流转状态查看退款积压，优先处理待办。',
      content: this.buildFilterContent
    })
  }

  @Builder
  private buildFilterContent() {
    TabBar({
      tabs: this.tabs,
      currentIndex: this.currentTab,
      onTabChange: (index: number) => {
        this.currentTab = index;
        this.loadData();
      }
    })
  }

  @Builder
  private buildRefundList() {
    Column() {
      SectionHeader({
        title: '退款列表',
        subtitle: this.errorMessage ? this.errorMessage : `当前共 ${this.refunds.length} 条退款记录`
      })

      if (this.refunds.length === 0) {
        EmptyState({
          type: EmptyType.DEFAULT,
          customTitle: '暂无退款记录',
          customDescription: this.errorMessage ? this.errorMessage : '当前筛选条件下没有退款申请。',
          actionText: '刷新',
          onAction: () => {
            this.loadData();
          }
        })
      } else {
        Column() {
          ForEach(this.refunds, (refund: RefundRecord) => {
            this.buildRefundItem(refund);
          })
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  private buildRefundItem(refund: RefundRecord) {
    Column() {
      Row() {
        Column() {
          Text(`${refund.studentName} · ${refund.serviceName}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(`订单 ${refund.orderNo}`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.getStatusText(refund.status))
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getStatusColor(refund.status))
      }
      .width('100%')

      Row() {
        this.buildMetricColumn('退款金额', `¥${Number(refund.refundAmount).toFixed(2)}`)
        this.buildMetricColumn('申请时间', refund.appliedAt.substring(0, 10))
      }
      .width('100%')
      .margin({ top: 14 })

      Text(`原因：${refund.reason}`)
        .width('100%')
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 12 })

      if (refund.description) {
        Text(`补充说明：${refund.description}`)
          .width('100%')
          .fontSize(12)
          .lineHeight(20)
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 8 })
      }

      Row() {
        if (refund.status === 'PENDING') {
          Text('撤销申请')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#DC2626')
            .onClick(() => {
              this.cancelRefund(refund);
            })
        } else if (refund.reviewRemark) {
          Text(refund.reviewRemark)
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
        } else {
          Text('已记录流转状态')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
        }
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .border({
      width: 1,
      color: '#EEF3F8',
      radius: 20,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 10,
      color: '#10172F12',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 12 })
  }

  @Builder
  private buildMetricColumn(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Text(label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
}
