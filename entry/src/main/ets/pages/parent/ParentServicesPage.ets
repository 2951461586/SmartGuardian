/**
 * SmartGuardian - 服务产品列表页
 * 家长浏览托管服务产品并发起预约
 */

import { router } from '@kit.ArkUI';
import { ServiceService, ServiceProduct } from '../../services/api/service';

@Component
struct ParentServicesPage {
  @State serviceList: ServiceProduct[] = [];
  @State isLoading: boolean = false;
  @State selectedCategory: string = 'ALL';
  @State searchKeyword: string = '';

  private categories: string[] = ['ALL', 'DAY_CARE', 'HOMEWORK', 'MEAL', 'TRANSPORT'];

  aboutToAppear() {
    this.loadServiceList();
  }

  async loadServiceList() {
    this.isLoading = true;
    try {
      const resp = await ServiceService.getServiceProductList({
        category: this.selectedCategory === 'ALL' ? undefined : this.selectedCategory,
        keyword: this.searchKeyword || undefined,
        page: 1,
        pageSize: 20
      });

      if (resp.code === 0 && resp.data) {
        this.serviceList = resp.data.list || [];
      }
    } catch (error) {
      // Handle error
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // Search bar
      this.buildSearchBar()

      // Category tabs
      this.buildCategoryTabs()

      // Service list
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
        .backgroundColor(Color.Transparent)
        .flexGrow(1)
        .margin({ left: 8, right: 8 })
        .onChange((value: string) => {
          this.searchKeyword = value;
        })
        .onSubmit(() => {
          this.loadServiceList();
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
    .backgroundColor(Color.White)
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
            .backgroundColor(this.selectedCategory === category ? $r('app.color.primary_light') : Color.Transparent)
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
    .backgroundColor(Color.White)
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
    } else if (this.serviceList.length === 0) {
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
      Scroll() {
        Column() {
          ForEach(this.serviceList, (service: ServiceProduct) => {
            this.buildServiceCard(service)
          })
        }
        .width('100%')
        .padding($r('app.float.page_padding'))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  buildServiceCard(service: ServiceProduct) {
    Column() {
      // Service header
      Row() {
        Column() {
          Text(service.name)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))

          Text(service.description || '')
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(`¥${service.price}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary'))
      }
      .width('100%')
      .margin({ bottom: 12 })

      // Service details
      Row() {
        Column() {
          Row() {
            Text('服务类型：')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_tertiary'))
            Text(this.getCategoryName(service.category))
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
          }

          Row() {
            Text('服务时段：')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_tertiary'))
            Text(`${service.startTime} - ${service.endTime}`)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))
          }

          Row() {
            Text('剩余名额：')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_tertiary'))
            Text(`${service.capacity - service.enrolledCount}`)
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor(service.capacity - service.enrolledCount > 0 ? $r('app.color.success') : $r('app.color.error'))
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // Action buttons
      Row() {
        Button('立即预约')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(Color.White)
          .backgroundColor($r('app.color.primary'))
          .borderRadius($r('app.float.button_radius'))
          .layoutWeight(1)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/parent/ParentOrderCreatePage',
              params: { serviceId: service.id }
            });
          })

        Button('查看详情')
          .fontSize($r('app.float.text_primary_size'))
          .fontColor($r('app.color.primary'))
          .backgroundColor($r('app.color.primary_light'))
          .borderRadius($r('app.float.button_radius'))
          .margin({ left: 12 })
          .layoutWeight(1)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/parent/ParentServiceDetailPage',
              params: { serviceId: service.id }
            });
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.card_border_radius'))
    .margin({ bottom: $r('app.float.card_margin') })
  }

  getCategoryName(category: string): string {
    const categoryMap: Record<string, string> = {
      'ALL': '全部',
      'DAY_CARE': '日托',
      'HOMEWORK': '作业辅导',
      'MEAL': '含餐',
      'TRANSPORT': '接送'
    };
    return categoryMap[category] || category;
  }
}