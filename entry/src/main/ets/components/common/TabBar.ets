/**
 * SmartGuardian - Tab Bar Component
 * Unified tab bar for page navigation
 * 
 * @description 统一TabBar组件，用于页面内标签切换
 * @features
 * - 支持动态标签
 * - 支持徽章显示
 * - 支持自定义样式
 * - 支持等宽/自适应宽度
 */

/**
 * Tab Item Interface
 */
export interface TabItem {
  /** 标签ID */
  id: string | number;
  /** 标签文本 */
  text: string;
  /** 徽章数量（可选） */
  badge?: number;
  /** 是否禁用 */
  disabled?: boolean;
}

/**
 * Tab Bar Style
 */
export enum TabBarStyle {
  /** 等宽样式 */
  EQUAL_WIDTH = 'EQUAL_WIDTH',
  /** 自适应宽度 */
  AUTO_WIDTH = 'AUTO_WIDTH',
  /** 可滚动 */
  SCROLLABLE = 'SCROLLABLE'
}

/**
 * Tab Bar Component
 * @description TabBar组件
 * @example
 * ```typescript
 * @State currentTab: number = 0;
 * 
 * TabBar({
 *   tabs: ['全部', '待审核', '已完成'],
 *   currentIndex: $currentTab,
 *   onTabChange: (index) => this.loadData(index)
 * })
 * ```
 */
@Component
export struct TabBar {
  /** 标签列表（字符串数组） */
  @Prop tabs: string[] = [];
  /** 标签项列表（对象数组，支持徽章） */
  @Prop tabItems?: TabItem[];
  /** 当前选中索引 */
  @Link currentIndex: number;
  /** TabBar样式 */
  @Prop style: TabBarStyle = TabBarStyle.EQUAL_WIDTH;
  /** 是否显示底部指示器 */
  @Prop showIndicator: boolean = true;
  /** 指示器宽度 */
  @Prop indicatorWidth: number = 20;
  /** Tab切换回调 */
  onTabChange?: (index: number) => void;
  /** 自定义背景色 */
  @Prop tabBgColor: ResourceColor = Color.White;

  build() {
    if (this.style === TabBarStyle.SCROLLABLE) {
      this.buildScrollableTabBar()
    } else {
      this.buildFixedTabBar()
    }
  }

  @Builder
  buildFixedTabBar() {
    Row() {
      ForEach(this.getDisplayTabs(), (tab: TabItem, index: number) => {
        this.buildTabItem(tab, index)
      })
    }
    .width('100%')
    .backgroundColor(this.tabBgColor)
  }

  @Builder
  buildScrollableTabBar() {
    Scroll() {
      Row() {
        ForEach(this.getDisplayTabs(), (tab: TabItem, index: number) => {
          this.buildTabItem(tab, index)
        })
      }
    }
    .width('100%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .backgroundColor(this.tabBgColor)
  }

  @Builder
  buildTabItem(tab: TabItem, index: number) {
    Column() {
      // 标签文本和徽章
      Row() {
        Text(tab.text)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(this.isSelected(index) ? $r('app.color.primary') : $r('app.color.text_secondary'))
          .fontWeight(this.isSelected(index) ? FontWeight.Medium : FontWeight.Normal)

        // 徽章
        if (tab.badge && tab.badge > 0) {
          this.buildBadge(tab.badge)
        }
      }

      // 底部指示器
      if (this.showIndicator && this.isSelected(index)) {
        Row()
          .width(this.indicatorWidth)
          .height(2)
          .backgroundColor($r('app.color.primary'))
          .borderRadius(1)
          .margin({ top: 4 })
      } else if (this.showIndicator) {
        // 占位，保持高度一致
        Row()
          .width(this.indicatorWidth)
          .height(2)
          .visibility(Visibility.None)
          .margin({ top: 4 })
      }
    }
    .width(this.getItemWidth())
    .height(44)
    .justifyContent(FlexAlign.Center)
    .opacity(tab.disabled ? 0.5 : 1)
    .onClick(() => {
      if (!tab.disabled) {
        this.handleTabClick(index);
      }
    })
  }

  @Builder
  buildBadge(count: number) {
    Text(count > 99 ? '99+' : `${count}`)
      .fontSize(10)
      .fontColor(Color.White)
      .backgroundColor($r('app.color.error'))
      .borderRadius(10)
      .padding({ left: 4, right: 4, top: 1, bottom: 1 })
      .constraintSize({ minWidth: 16 })
      .margin({ left: 4 })
  }

  /**
   * Get display tabs
   */
  private getDisplayTabs(): TabItem[] {
    if (this.tabItems && this.tabItems.length > 0) {
      return this.tabItems;
    }

    // 将字符串数组转换为TabItem数组
    const result: TabItem[] = [];
    this.tabs.forEach((text: string, index: number) => {
      result.push({ id: index, text: text });
    });
    return result;
  }

  /**
   * Check if tab is selected
   */
  private isSelected(index: number): boolean {
    return this.currentIndex === index;
  }

  /**
   * Get item width
   */
  private getItemWidth(): string | number {
    if (this.style === TabBarStyle.AUTO_WIDTH) {
      return 'auto';
    }
    
    const tabCount = this.getDisplayTabs().length;
    if (tabCount === 0) return '100%';
    
    return `${100 / tabCount}%`;
  }

  /**
   * Handle tab click
   */
  private handleTabClick(index: number): void {
    this.currentIndex = index;
    if (this.onTabChange) {
      this.onTabChange(index);
    }
  }
}

/**
 * Simple Tab Bar
 * @description 简化版TabBar（仅文本切换）
 */
@Component
export struct SimpleTabBar {
  @Prop tabs: string[] = [];
  @Link currentIndex: number;
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
          this.currentIndex = index;
          if (this.onTabChange) {
            this.onTabChange(index);
          }
        })
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
  }
}

/**
 * Segment Tab Bar
 * @description 分段式TabBar（胶囊样式）
 */
@Component
export struct SegmentTabBar {
  @Prop tabs: string[] = [];
  @Link currentIndex: number;
  onTabChange?: (index: number) => void;
  @Prop segmentBgColor: ResourceColor = '#F5F5F5';
  @Prop activeBgColor: ResourceColor = Color.White;

  build() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Text(tab)
          .fontSize($r('app.float.text_primary_size'))
          .fontColor(this.currentIndex === index ? $r('app.color.primary') : $r('app.color.text_secondary'))
          .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
          .backgroundColor(this.currentIndex === index ? this.activeBgColor : Color.Transparent)
          .borderRadius(8)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.currentIndex = index;
            if (this.onTabChange) {
              this.onTabChange(index);
            }
          })
      })
    }
    .width('100%')
    .backgroundColor(this.segmentBgColor)
    .borderRadius(12)
    .padding(4)
  }
}

/**
 * Underline Tab Bar
 * @description 下划线样式TabBar
 */
@Component
export struct UnderlineTabBar {
  @Prop tabs: string[] = [];
  @Link currentIndex: number;
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
            this.currentIndex = index;
            if (this.onTabChange) {
              this.onTabChange(index);
            }
          })
        })
      }
      .width('100%')
      .backgroundColor(Color.White)

      // 下划线指示器
      Row() {
        Row()
          .width(`${100 / this.tabs.length}%`)
          .height(2)
          .backgroundColor($r('app.color.primary'))
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
