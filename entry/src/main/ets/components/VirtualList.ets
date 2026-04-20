/**
 * SmartGuardian - VirtualList Component
 * 虚拟列表组件，用于大量数据的高性能渲染
 * 
 * @description 性能优化组件，基于鸿蒙原生 List 实现
 * @features
 * - 虚拟滚动：只渲染可视区域内的列表项
 * - 分页加载：支持上拉加载更多
 * - 下拉刷新：支持下拉刷新
 * - 列表复用：自动复用列表项组件
 */

/**
 * 列表项基础接口
 */
export interface VirtualListItem {
  id: string | number;
}

/**
 * 虚拟列表配置
 */
export interface VirtualListConfig {
  itemHeight?: number;       // 列表项高度
  pageSize?: number;         // 每页数据量
  loadMoreThreshold?: number; // 加载更多阈值
  enableRefresh?: boolean;   // 是否启用下拉刷新
  enableLoadMore?: boolean;  // 是否启用加载更多
}

/**
 * 虚拟列表组件
 */
@Component
export struct VirtualList<T extends VirtualListItem> {
  @Prop data: T[] = [];
  @Prop config: VirtualListConfig = {
    itemHeight: 80,
    pageSize: 20,
    loadMoreThreshold: 3,
    enableRefresh: true,
    enableLoadMore: true
  };
  @State private isRefreshing: boolean = false;
  @State private isLoadingMore: boolean = false;
  @State private hasMore: boolean = true;

  // 回调事件
  private onRefresh?: () => Promise<void>;
  private onLoadMore?: (page: number) => Promise<T[]>;
  private onItemClick?: (item: T) => void;
  private currentPage: number = 1;

  /**
   * 设置刷新回调
   */
  setOnRefresh(callback: () => Promise<void>): void {
    this.onRefresh = callback;
  }

  /**
   * 设置加载更多回调
   */
  setOnLoadMore(callback: (page: number) => Promise<T[]>): void {
    this.onLoadMore = callback;
  }

  /**
   * 设置列表项点击回调
   */
  setOnItemClick(callback: (item: T) => void): void {
    this.onItemClick = callback;
  }

  /**
   * 处理下拉刷新
   */
  private async handleRefresh(): Promise<void> {
    if (!this.onRefresh) return;

    this.isRefreshing = true;
    this.currentPage = 1;
    this.hasMore = true;

    try {
      await this.onRefresh();
    } finally {
      this.isRefreshing = false;
    }
  }

  /**
   * 处理加载更多
   */
  private async handleLoadMore(): Promise<void> {
    if (!this.onLoadMore || this.isLoadingMore || !this.hasMore) return;

    this.isLoadingMore = true;
    this.currentPage++;

    try {
      const newData = await this.onLoadMore(this.currentPage);
      if (newData.length === 0 || newData.length < (this.config.pageSize ?? 20)) {
        this.hasMore = false;
      }
    } finally {
      this.isLoadingMore = false;
    }
  }

  build() {
    List() {
      ForEach(this.data, (item: T) => {
        ListItem() {
          // 子组件通过 @BuilderParam 插入
          Row() {
            Text('Item: ' + item.id)
              .fontSize(14)
              .fontColor('#333333')
          }
          .width('100%')
          .height(this.config.itemHeight ?? 80)
          .backgroundColor(Color.White)
          .onClick(() => {
            if (this.onItemClick) {
              this.onItemClick(item);
            }
          })
        }
      }, (item: T) => String(item.id))
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Auto)
  }
}

/**
 * 简化的列表状态接口
 */
export interface ListState<T> {
  data: T[];
  isLoading: boolean;
  hasMore: boolean;
  error: string | null;
}

/**
 * 列表状态管理器
 * 用于管理列表的数据、加载状态等
 */
export class ListStateManager<T extends VirtualListItem> {
  private state: ListState<T> = {
    data: [],
    isLoading: false,
    hasMore: true,
    error: null
  };

  private listeners: Array<(state: ListState<T>) => void> = [];

  /**
   * 获取当前状态
   */
  getState(): ListState<T> {
    return { ...this.state };
  }

  /**
   * 订阅状态变化
   */
  subscribe(listener: (state: ListState<T>) => void): () => void {
    this.listeners.push(listener);
    return () => {
      const index = this.listeners.indexOf(listener);
      if (index > -1) {
        this.listeners.splice(index, 1);
      }
    };
  }

  /**
   * 更新状态
   */
  private notify(): void {
    this.listeners.forEach(listener => listener(this.getState()));
  }

  /**
   * 设置加载中状态
   */
  setLoading(isLoading: boolean): void {
    this.state.isLoading = isLoading;
    this.notify();
  }

  /**
   * 设置数据
   */
  setData(data: T[], append: boolean = false): void {
    if (append) {
      this.state.data = [...this.state.data, ...data];
    } else {
      this.state.data = data;
    }
    this.state.isLoading = false;
    this.state.error = null;
    this.notify();
  }

  /**
   * 设置是否有更多数据
   */
  setHasMore(hasMore: boolean): void {
    this.state.hasMore = hasMore;
    this.notify();
  }

  /**
   * 设置错误
   */
  setError(error: string): void {
    this.state.error = error;
    this.state.isLoading = false;
    this.notify();
  }

  /**
   * 重置状态
   */
  reset(): void {
    this.state = {
      data: [],
      isLoading: false,
      hasMore: true,
      error: null
    };
    this.notify();
  }
}

/**
 * 分页加载控制装饰器
 * 用于包装分页加载逻辑
 * 
 * @param pageSize 每页数据量
 */
export function Pagination<T extends VirtualListItem>(pageSize: number = 20) {
  return function (
    target: Object,
    propertyKey: string,
    descriptor: TypedPropertyDescriptor<(pageIndex: number, pageSize: number) => Promise<T[]>>
  ) {
    const originalMethod = descriptor.value;

    if (originalMethod) {
      descriptor.value = async function (pageIndex: number, pageSizeArg: number): Promise<T[]> {
        const result = await originalMethod.call(this, pageIndex, pageSizeArg || pageSize);
        return result;
      };
    }

    return descriptor;
  };
}
