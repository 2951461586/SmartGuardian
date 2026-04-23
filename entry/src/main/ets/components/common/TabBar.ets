/**
 * SmartGuardian - Tab Bar Component
 * Unified tab bar with a bright segmented style
 */

export interface TabItem {
  id: string | number;
  text: string;
  badge?: number;
  disabled?: boolean;
}

export enum TabBarStyle {
  EQUAL_WIDTH = 'EQUAL_WIDTH',
  AUTO_WIDTH = 'AUTO_WIDTH',
  SCROLLABLE = 'SCROLLABLE'
}

@Component
export struct TabBar {
  @Prop tabs: string[] = [];
  @Prop tabItems: TabItem[] = [];
  @Prop currentIndex: number = 0;
  @Prop style: TabBarStyle = TabBarStyle.EQUAL_WIDTH;
  @Prop showIndicator: boolean = true;
  @Prop indicatorWidth: number = 20;
  onTabChange?: (index: number) => void;
  @Prop tabBgColor: ResourceColor = '#EEF4FF';

  build() {
    if (this.style === TabBarStyle.SCROLLABLE) {
      this.buildScrollableTabBar()
    } else {
      this.buildFixedTabBar()
    }
  }

  @Builder
  private buildFixedTabBar() {
    Row() {
      ForEach(this.getDisplayTabs(), (tab: TabItem, index: number) => {
        this.buildTabItem(tab, index)
      })
    }
    .width('100%')
    .padding(4)
    .backgroundColor(this.tabBgColor)
    .borderRadius(20)
    .border({
      width: 1,
      color: '#DCE6FA',
      radius: 20,
      style: BorderStyle.Solid
    })
  }

  @Builder
  private buildScrollableTabBar() {
    Scroll() {
      Row() {
        ForEach(this.getDisplayTabs(), (tab: TabItem, index: number) => {
          this.buildTabItem(tab, index)
        })
      }
      .padding(4)
    }
    .width('100%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .backgroundColor(this.tabBgColor)
    .borderRadius(20)
    .border({
      width: 1,
      color: '#DCE6FA',
      radius: 20,
      style: BorderStyle.Solid
    })
  }

  @Builder
  private buildTabItem(tab: TabItem, index: number) {
    Column() {
      Row() {
        Text(tab.text)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(this.isSelected(index) ? $r('app.color.primary') : $r('app.color.text_secondary'))
          .fontWeight(this.isSelected(index) ? FontWeight.Medium : FontWeight.Normal)

        if (tab.badge && tab.badge > 0) {
          this.buildBadge(tab.badge)
        }
      }

      if (this.showIndicator && this.isSelected(index)) {
        Row()
          .width(this.indicatorWidth)
          .height(3)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(999)
          .margin({ top: 5 })
      } else if (this.showIndicator) {
        Row()
          .width(this.indicatorWidth)
          .height(3)
          .visibility(Visibility.Hidden)
          .margin({ top: 5 })
      }
    }
    .width(this.getItemWidth())
    .height(50)
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.isSelected(index) ? '#FFFFFF' : Color.Transparent)
    .borderRadius(16)
    .border({
      width: this.isSelected(index) ? 1 : 0,
      color: this.isSelected(index) ? '#E4ECFA' : Color.Transparent,
      radius: 16,
      style: BorderStyle.Solid
    })
    .shadow({
      radius: this.isSelected(index) ? 8 : 0,
      color: this.isSelected(index) ? '#2F6BDE0A' : Color.Transparent,
      offsetX: 0,
      offsetY: this.isSelected(index) ? 3 : 0
    })
    .margin({ right: this.style === TabBarStyle.SCROLLABLE ? 8 : 0 })
    .opacity(tab.disabled ? 0.5 : 1)
    .onClick(() => {
      if (!tab.disabled) {
        this.handleTabClick(index);
      }
    })
  }

  @Builder
  private buildBadge(count: number) {
    Text(count > 99 ? '99+' : `${count}`)
      .fontSize(10)
      .fontColor(Color.White)
      .backgroundColor($r('app.color.error'))
      .borderRadius(10)
      .padding({ left: 4, right: 4, top: 1, bottom: 1 })
      .constraintSize({ minWidth: 16 })
      .margin({ left: 4 })
  }

  private getDisplayTabs(): TabItem[] {
    if (this.tabItems.length > 0) {
      return this.tabItems;
    }

    const result: TabItem[] = [];
    this.tabs.forEach((text: string, index: number) => {
      result.push({ id: index, text: text });
    });
    return result;
  }

  private isSelected(index: number): boolean {
    return this.currentIndex === index;
  }

  private getItemWidth(): string | number {
    if (this.style === TabBarStyle.AUTO_WIDTH || this.style === TabBarStyle.SCROLLABLE) {
      return 'auto';
    }

    const tabCount = this.getDisplayTabs().length;
    if (tabCount === 0) {
      return '100%';
    }

    return `${100 / tabCount}%`;
  }

  private handleTabClick(index: number): void {
    if (this.onTabChange) {
      this.onTabChange(index);
    }
  }
}

@Component
export struct SimpleTabBar {
  @Prop tabs: string[] = [];
  @Prop currentIndex: number = 0;
  onTabChange?: (index: number) => void;

  build() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Column() {
          Text(tab)
            .fontSize($r('app.float.text_primary_size'))
            .fontColor(this.currentIndex === index ? $r('app.color.primary') : $r('app.color.text_secondary'))
            .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        }
        .layoutWeight(1)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          if (this.onTabChange) {
            this.onTabChange(index);
          }
        })
      })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }
}

@Component
export struct SegmentTabBar {
  @Prop tabs: string[] = [];
  @Prop currentIndex: number = 0;
  onTabChange?: (index: number) => void;
  @Prop segmentBgColor: ResourceColor = '#EEF4FF';
  @Prop activeBgColor: ResourceColor = '#FFFFFF';

  build() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Text(tab)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(this.currentIndex === index ? $r('app.color.primary') : $r('app.color.text_secondary'))
          .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
          .backgroundColor(this.currentIndex === index ? this.activeBgColor : Color.Transparent)
          .borderRadius(10)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (this.onTabChange) {
              this.onTabChange(index);
            }
          })
      })
    }
    .width('100%')
    .backgroundColor(this.segmentBgColor)
    .borderRadius(14)
    .padding(4)
  }
}

@Component
export struct UnderlineTabBar {
  @Prop tabs: string[] = [];
  @Prop currentIndex: number = 0;
  onTabChange?: (index: number) => void;

  build() {
    Column() {
      Row() {
        ForEach(this.tabs, (tab: string, index: number) => {
          Column() {
            Text(tab)
              .fontSize($r('app.float.text_primary_size'))
              .fontColor(this.currentIndex === index ? $r('app.color.primary') : $r('app.color.text_secondary'))
              .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
              .padding({ bottom: 8 })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            if (this.onTabChange) {
              this.onTabChange(index);
            }
          })
        })
      }
      .width('100%')
      .backgroundColor(Color.Transparent)

      Row() {
        Row()
          .width(`${100 / this.tabs.length}%`)
          .height(3)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(999)
      }
      .width('100%')
      .translate({ x: `${this.currentIndex * 100}%` })
      .animation({
        duration: 200,
        curve: Curve.EaseOut
      })
    }
  }
}
