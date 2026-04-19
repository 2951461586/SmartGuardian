/**
 * SmartGuardian - Parent Service Detail Page
 * Service product detail view with booking functionality
 */

import router from '@ohos.router';
import { ServiceProduct } from '../../models/service';
import { ServiceProductService } from '../../services/api/service';
import { UserStore } from '../../stores/userStore';

interface RouterParams {
  serviceId: number;
}

@Entry
@Component
struct ParentServiceDetailPage {
  @State serviceId: number = 0;
  @State serviceDetail: ServiceProduct | null = null;
  @State isLoading: boolean = true;
  @State selectedTab: number = 0;

  aboutToAppear() {
    const params = router.getParams() as RouterParams;
    if (params && params.serviceId) {
      this.serviceId = params.serviceId;
      this.loadServiceDetail();
    }
  }

  async loadServiceDetail() {
    this.isLoading = true;
    try {
      const resp = await ServiceProductService.getProductDetail(this.serviceId);
      if (resp.code === 0 && resp.data) {
        this.serviceDetail = resp.data;
      }
    } catch (error) {
      console.error('Failed to load service detail:', error);
    } finally {
      this.isLoading = false;
    }
  }

  handleBookNow() {
    if (!this.serviceDetail) {
      return;
    }
    
    router.pushUrl({
      url: 'pages/parent/ParentOrderCreatePage',
      params: {
        serviceId: this.serviceDetail.id,
        serviceName: this.serviceDetail.serviceName,
        price: this.serviceDetail.price
      }
    });
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      if (this.isLoading) {
        this.buildLoading()
      } else if (this.serviceDetail) {
        // Content
        Scroll() {
          Column() {
            this.buildServiceHeader()
            this.buildTabBar()
            if (this.selectedTab === 0) {
              this.buildServiceInfo()
            } else {
              this.buildScheduleInfo()
            }
          }
          .width('100%')
          .padding({ bottom: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        // Bottom action bar
        this.buildBottomBar()
      } else {
        this.buildEmpty()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.ic_arrow_left'))
        .width($r('app.float.icon_large_size'))
        .height($r('app.float.icon_large_size'))
        .onClick(() => router.back())

      Text('服务详情')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank()
        .width($r('app.float.icon_large_size'))
    }
    .width('100%')
    .padding($r('app.float.page_padding'))
    .backgroundColor($r('app.color.primary'))
    .padding({ top: Number($r('app.float.status_bar_height')) + 10 })
  }

  @Builder
  buildLoading() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color($r('app.color.primary'))
      
      Text('加载中...')
        .fontSize($r('app.float.text_secondary_size'))
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmpty() {
    Column() {
      Text('服务不存在或已下架')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildServiceHeader() {
    Column() {
      // Service image placeholder
      Column() {
        Image($r('app.media.ic_logo'))
          .width(120)
          .height(120)
          .objectFit(ImageFit.Contain)
      }
      .width('100%')
      .height(200)
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.Center)

      // Service basic info
      Column() {
        Text(this.serviceDetail?.serviceName || '')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text('¥')
            .fontSize($r('app.float.text_primary_size'))
            .fontColor('#F44336')
            .fontWeight(FontWeight.Bold)

          Text(this.serviceDetail?.price?.toString() || '0')
            .fontSize(28)
            .fontColor('#F44336')
            .fontWeight(FontWeight.Bold)

          Text(`/${this.serviceDetail?.unit || '次'}`)
            .fontSize($r('app.float.text_secondary_size'))
            .fontColor($r('app.color.text_secondary'))
            .margin({ left: 4 })
        }
        .margin({ top: 12 })

        Row() {
          Text(this.serviceDetail?.serviceType || '')
            .fontSize($r('app.float.badge_text_size'))
            .fontColor($r('app.color.primary'))
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#E3F2FD')
            .borderRadius(4)

          if (this.serviceDetail?.gradeRange) {
            Text(this.serviceDetail.gradeRange)
              .fontSize($r('app.float.badge_text_size'))
              .fontColor('#666666')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#F5F5F5')
              .borderRadius(4)
              .margin({ left: 8 })
          }
        }
        .margin({ top: 12 })
      }
      .width('100%')
      .padding($r('app.float.card_padding'))
      .backgroundColor(Color.White)
    }
    .width('100%')
  }

  @Builder
  buildTabBar() {
    Row() {
      ForEach(['服务详情', '时间安排'], (item: string, index: number) => {
        Column() {
          Text(item)
            .fontSize($r('app.float.text_primary_size'))
            .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.selectedTab === index ? $r('app.color.primary') : $r('app.color.text_secondary'))

          if (this.selectedTab === index) {
            Divider()
              .width(40)
              .height(3)
              .color($r('app.color.primary'))
              .margin({ top: 8 })
          }
        }
        .layoutWeight(1)
        .padding({ top: 16, bottom: 16 })
        .onClick(() => this.selectedTab = index)
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .margin({ top: 8 })
  }

  @Builder
  buildServiceInfo() {
    Column() {
      // Description
      this.buildInfoItem('服务描述', this.serviceDetail?.description || '暂无描述')

      // Location
      this.buildInfoItem('服务地点', this.serviceDetail?.orgName || '待定')

      // Capacity
      if (this.serviceDetail?.maxStudents) {
        this.buildInfoItem(
          '服务容量',
          `${this.serviceDetail.currentStudents || 0}/${this.serviceDetail.maxStudents}人`
        )
      }

      // Grade range
      if (this.serviceDetail?.gradeRange) {
        this.buildInfoItem('适用年级', this.serviceDetail.gradeRange)
      }

      // Sign in time
      if (this.serviceDetail?.signInStartTime && this.serviceDetail?.signInEndTime) {
        this.buildInfoItem(
          '签到时间',
          `${this.serviceDetail.signInStartTime} - ${this.serviceDetail.signInEndTime}`
        )
      }

      // Sign out time
      if (this.serviceDetail?.signOutStartTime && this.serviceDetail?.signOutEndTime) {
        this.buildInfoItem(
          '签退时间',
          `${this.serviceDetail.signOutStartTime} - ${this.serviceDetail.signOutEndTime}`
        )
      }
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .margin({ top: 8 })
  }

  @Builder
  buildInfoItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_secondary'))
        .width(80)

      Text(value)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ top: 12, bottom: 12 })
  }

  @Builder
  buildScheduleInfo() {
    Column() {
      if (this.serviceDetail?.serviceStartDate && this.serviceDetail?.serviceEndDate) {
        Row() {
          Column() {
            Text('开始日期')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))

            Text(this.serviceDetail.serviceStartDate)
              .fontSize($r('app.float.text_primary_size'))
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Medium)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Column() {
            Text('结束日期')
              .fontSize($r('app.float.text_secondary_size'))
              .fontColor($r('app.color.text_secondary'))

            Text(this.serviceDetail.serviceEndDate)
              .fontSize($r('app.float.text_primary_size'))
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Medium)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.End)
          .layoutWeight(1)
        }
        .width('100%')
        .padding($r('app.float.card_padding'))
      } else {
        Text('暂无时间安排信息')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .padding($r('app.float.card_padding'))
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .margin({ top: 8 })
    .borderRadius($r('app.float.card_border_radius'))
  }

  @Builder
  buildBottomBar() {
    Row() {
      // Price
      Column() {
        Text('价格')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))

        Row() {
          Text('¥')
            .fontSize($r('app.float.text_primary_size'))
            .fontColor('#F44336')

          Text(this.serviceDetail?.price?.toString() || '0')
            .fontSize(24)
            .fontColor('#F44336')
            .fontWeight(FontWeight.Bold)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // Book button
      Button('立即预约')
        .width(160)
        .height(44)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(22)
        .onClick(() => this.handleBookNow())
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .shadow({
      radius: 10,
      color: '#1A000000',
      offsetY: -2
    })
  }
}
