/**
 * SmartGuardian - 服务产品列表页
 * 家长浏览托管服务产品并发起预约
 */

import { ServiceProductService } from '../../services/api/service';
import { HarmonyColor } from '../../common/HarmonyDesign';
import { RouteUrls } from '../../constants/app.constants';
import { ServiceProduct } from '../../models/service';
import { ServiceProductCard } from '../../components/common';

@Entry
@Component
struct ParentServicesPage {
  build() {
    Stack() {
      ParentServicesPageContent()
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct ParentServicesPageContent {
  @State serviceList: ServiceProduct[] = [];
  @State isLoading: boolean = false;
  @State selectedCategory: string = 'ALL';
  @State searchKeyword: string = '';

  private categories: string[] = ['ALL', 'AFTER_SCHOOL', 'HOLIDAY', 'FULL_DAY', 'WEEKEND'];

  aboutToAppear() {
    this.loadServiceList();
  }

  async loadServiceList() {
    this.isLoading = true;
    try {
      const resp = await ServiceProductService.getProducts({
        serviceType: this.selectedCategory === 'ALL' ? undefined : this.selectedCategory,
        pageNum: 1,
        pageSize: 20
      });

      if (resp.code === 0 && resp.data) {
        this.serviceList = resp.data;
      } else {
        this.serviceList = [];
      }
    } catch (error) {
      console.error('Load service products failed:', String(error));
      this.serviceList = [];
    } finally {
      this.isLoading = false;
    }
  }

  private getFilteredServiceList(): ServiceProduct[] {
    const keyword = this.searchKeyword.trim().toLowerCase();
    return this.serviceList.filter((service: ServiceProduct) => {
      if (this.selectedCategory !== 'ALL' && service.serviceType !== this.selectedCategory) {
        return false;
      }

      if (keyword.length === 0) {
        return true;
      }

      const name = (service.serviceName || '').toLowerCase();
      const description = (service.description || '').toLowerCase();
      const serviceType = (service.serviceType || '').toLowerCase();
      return name.indexOf(keyword) >= 0 || description.indexOf(keyword) >= 0 || serviceType.indexOf(keyword) >= 0;
    });
  }

  private getCategoryName(category: string): string {
    if (category === 'ALL') {
      return '全部';
    }
    if (category === 'AFTER_SCHOOL') {
      return '课后托管';
    }
    if (category === 'HOLIDAY') {
      return '假期托管';
    }
    if (category === 'FULL_DAY') {
      return '全天托管';
    }
    if (category === 'WEEKEND') {
      return '周末托管';
    }
    return category;
  }

  build() {
    Column() {
      this.buildSearchBar()
      this.buildCategoryTabs()
      this.buildServiceList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildSearchBar() {
    Row() {
      Image($r('app.media.ic_search'))
        .width(20)
        .height(20)
        .fillColor($r('app.color.text_tertiary'))

      TextInput({
        placeholder: '搜索托管服务',
        text: this.searchKeyword
      })
        .fontSize($r('app.float.text_primary_size'))
        .backgroundColor(HarmonyColor.clear)
        .flexGrow(1)
        .margin({ left: 8, right: 8 })
        .onChange((value: string) => {
          this.searchKeyword = value;
        })
        .onSubmit(() => {
          this.searchKeyword = this.searchKeyword.trim();
        })

      if (this.searchKeyword) {
        Image($r('app.media.ic_close'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.text_tertiary'))
          .onClick(() => {
            this.searchKeyword = '';
            this.loadServiceList();
          })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(HarmonyColor.surface)
  }

  @Builder
  buildCategoryTabs() {
    Scroll() {
      Row() {
        ForEach(this.categories, (category: string) => {
          Text(this.getCategoryName(category))
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor(this.selectedCategory === category ? $r('app.color.primary') : $r('app.color.text_secondary'))
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.selectedCategory === category ? $r('app.color.primary_light') : HarmonyColor.clear)
            .borderRadius(16)
            .onClick(() => {
              this.selectedCategory = category;
              this.loadServiceList();
            })
        })
      }
    }
    .width('100%')
    .scrollBar(BarState.Off)
    .padding({ left: 12, right: 12 })
    .backgroundColor(HarmonyColor.surface)
  }

  @Builder
  buildServiceList() {
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .color($r('app.color.primary'))
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.getFilteredServiceList().length === 0) {
      Column() {
        Image($r('app.media.ic_empty'))
          .width(120)
          .height(120)
          .objectFit(ImageFit.Contain)
          .opacity(0.5)

        Text('暂无服务产品')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: $r('app.float.card_margin') })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: 12 }) {
        ForEach(this.getFilteredServiceList(), (service: ServiceProduct) => {
          ListItem() {
            ServiceProductCard({
              service: service,
              showActions: true,
              primaryActionText: '立即预约',
              secondaryActionText: '查看详情',
              onPrimaryAction: (): void => {
                this.getUIContext().getRouter().pushUrl({
                  url: RouteUrls.PARENT_ORDER_CREATE,
                  params: { serviceId: service.id, serviceName: service.serviceName, price: service.price }
                });
              },
              onSecondaryAction: (): void => {
                this.getUIContext().getRouter().pushUrl({
                  url: RouteUrls.PARENT_SERVICE_DETAIL,
                  params: { serviceId: service.id }
                });
              }
            })
          }
        }, (service: ServiceProduct) => `${service.id}`)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 12, right: 12, top: 12, bottom: 16 })
      .divider({ strokeWidth: 0 })
      .scrollBar(BarState.Off)
      .cachedCount(6)
    }
  }
}

