/**
 * SmartGuardian - Admin Services Page
 * Admin service product management workspace
 */

import { HarmonyColor, HarmonyReport } from '../../common/HarmonyDesign';
import {
  Card,
  EmptyState,
  EmptyType,
  HeaderTheme,
  IconActionButton,
  LoadingSize,
  LoadingState,
  PageHeader,
  SectionHeader,
  StatCard,
  TabBar,
  ServiceProductCard
} from '../../components/common';
import { ServiceProduct, ServiceProductCreateRequest } from '../../models/service';
import { ServiceProductService } from '../../services/api/service';
import { ErrorHandlerUtil } from '../../utils/ErrorHandlerUtil';
import { LogUtil } from '../../utils/LogUtil';

@Entry
@Component
struct AdminServicesPage {
  @State products: ServiceProduct[] = [];
  @State isLoading: boolean = false;
  @State isCreating: boolean = false;
  @State currentTab: number = 0;
  @State errorMessage: string = '';

  private readonly tabs: string[] = ['全部服务', '启用中', '已停用', '满员'];

  aboutToAppear() {
    ErrorHandlerUtil.setUIContext(this.getUIContext());
    this.loadProducts();
  }

  private getQueryStatus(): string | undefined {
    if (this.currentTab === 1) {
      return 'ACTIVE';
    }
    if (this.currentTab === 2) {
      return 'INACTIVE';
    }
    if (this.currentTab === 3) {
      return 'FULL';
    }
    return undefined;
  }

  async loadProducts() {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const response = await ServiceProductService.getProducts({
        pageNum: 1,
        pageSize: 100,
        status: this.getQueryStatus()
      });

      if (response.code === 0 && response.data) {
        this.products = response.data;
      } else {
        this.products = [];
        this.errorMessage = response.message ? response.message : '服务产品加载失败';
      }
    } catch (error) {
      this.products = [];
      this.errorMessage = '服务产品加载失败，请稍后重试';
      LogUtil.error(`AdminServicesPage loadProducts failed: ${String(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  async createQuickProduct() {
    if (this.isCreating) {
      return;
    }

    this.isCreating = true;
    try {
      const suffix = Date.now().toString().slice(-4);
      const payload: ServiceProductCreateRequest = {
        serviceName: `课后托管模板 ${suffix}`,
        serviceType: 'AFTER_SCHOOL_CARE',
        description: '用于管理员快速补齐服务产品台账的模板服务。',
        price: 998,
        unit: '月',
        gradeRange: '1-6年级',
        maxStudents: 30,
        capacity: 30,
        serviceStartDate: '2026-05-01',
        serviceEndDate: '2026-07-31',
        signInStartTime: '16:20',
        signInEndTime: '16:40',
        signOutStartTime: '18:00',
        signOutEndTime: '18:30'
      };

      const response = await ServiceProductService.createProduct(payload);
      if (response.code === 0) {
        ErrorHandlerUtil.showSuccessToast('已创建服务模板');
        this.currentTab = 0;
        await this.loadProducts();
      } else {
        ErrorHandlerUtil.showErrorToast(response.message ? response.message : '创建服务模板失败');
      }
    } catch (error) {
      LogUtil.error(`AdminServicesPage createQuickProduct failed: ${String(error)}`);
      ErrorHandlerUtil.showErrorToast('创建服务模板失败，请稍后重试');
    } finally {
      this.isCreating = false;
    }
  }

  private getTotalCapacity(): number {
    let total = 0;
    for (let i = 0; i < this.products.length; i++) {
      total += Number(this.products[i].capacity ?? this.products[i].maxStudents ?? 0);
    }
    return total;
  }

  private getCurrentStudents(): number {
    let total = 0;
    for (let i = 0; i < this.products.length; i++) {
      total += Number(this.products[i].currentStudents ?? 0);
    }
    return total;
  }

  private countByStatus(status: string): number {
    let count = 0;
    for (let i = 0; i < this.products.length; i++) {
      if (this.products[i].status === status) {
        count++;
      }
    }
    return count;
  }

  private getUtilizationText(): string {
    const totalCapacity = this.getTotalCapacity();
    if (totalCapacity <= 0) {
      return '0%';
    }
    const ratio = Math.round((this.getCurrentStudents() / totalCapacity) * 100);
    return `${ratio}%`;
  }

  build() {
    Column() {
      PageHeader({
        title: '服务产品管理',
        subtitle: '查看服务台账、容量使用情况，并可快速新建模板服务。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY,
        rightContent: this.buildHeaderAction
      })

      if (this.isLoading) {
        LoadingState({
          loadingSize: LoadingSize.DEFAULT,
          message: '正在加载服务产品...'
        })
      } else {
        this.buildOverviewPanel()
        this.buildFilterPanel()
        this.buildProductList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildHeaderAction() {
    IconActionButton({
      icon: $r('app.media.ic_add'),
      iconColor: HarmonyColor.textInverse,
      boxBgColor: HarmonyColor.overlayInverseSoft,
      boxBorderColor: HarmonyColor.overlayInverseBorder,
      boxSize: 42,
      iconSize: 22,
      onButtonClick: () => {
        this.createQuickProduct();
      }
    })
  }

  @Builder
  private buildOverviewPanel() {
    Column() {
      SectionHeader({
        title: '服务概览',
        subtitle: '聚焦服务数量、启用状态和容量使用率。'
      })

      Row() {
        StatCard({
          value: this.products.length,
          label: '当前服务数',
          icon: $r('app.media.ic_service'),
          iconColor: HarmonyReport.accent
        })
        .layoutWeight(1)

        StatCard({
          value: this.countByStatus('ACTIVE'),
          label: '启用中',
          icon: $r('app.media.ic_success'),
          iconColor: HarmonyReport.positive
        })
        .layoutWeight(1)
        .margin({ left: 12, right: 12 })

        StatCard({
          value: this.getUtilizationText(),
          label: '容量使用率',
          icon: $r('app.media.ic_report'),
          iconColor: HarmonyReport.caution
        })
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
  }

  @Builder
  private buildFilterPanel() {
    Card({
      title: '状态筛选',
      subtitle: '按服务状态切换当前产品池，快速定位启用、停用和满员服务。',
      content: this.buildFilterContent
    })
    .margin({ left: 16, right: 16, top: 14 })
  }

  @Builder
  private buildFilterContent() {
    TabBar({
      tabs: this.tabs,
      currentIndex: this.currentTab,
      onTabChange: (index: number) => {
        this.currentTab = index;
        this.loadProducts();
      }
    })
  }

  @Builder
  private buildProductList() {
    Column() {
      SectionHeader({
        title: '服务列表',
        subtitle: this.errorMessage ? this.errorMessage : `当前共 ${this.products.length} 个服务产品`
      })

      if (this.products.length === 0) {
        EmptyState({
          type: EmptyType.DEFAULT,
          customTitle: '暂无服务产品',
          customDescription: this.errorMessage ? this.errorMessage : '可以先创建一个模板服务，把服务台账补齐起来。',
          actionText: '快速创建',
          onAction: () => {
            this.createQuickProduct();
          }
        })
      } else {
        List({ space: 12 }) {
          ForEach(this.products, (product: ServiceProduct) => {
            ListItem() {
              ServiceProductCard({
                service: product,
                showActions: false
              })
            }
          }, (product: ServiceProduct) => `${product.id}`)
        }
        .width('100%')
        .divider({ strokeWidth: 0 })
        .scrollBar(BarState.Off)
        .cachedCount(6)
        .padding({ left: 16, right: 16, bottom: 24, top: 12 })
      }
    }
    .width('100%')
    .layoutWeight(1)
  }
}
