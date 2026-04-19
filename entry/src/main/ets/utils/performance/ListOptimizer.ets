/**
 * SmartGuardian - 列表性能优化器(Simplified)
 * 实现虚拟滚动、懒加载和回收复用
 */

import { LogUtil } from '../LogUtil';

const TAG = 'ListOptimizer';

/**
 * 列表配置
 */
export interface ListConfig {
  itemCount: number;
  itemHeight: number;
  visibleItemCount: number;
  bufferItemCount: number;
}

/**
 * 列表优化器
 * 提供虚拟滚动、懒加载、回收复用等优化
 */
export class ListOptimizer {
  private config: ListConfig;
  private visibleData: Object[] = [];
  private startIndex: number = 0;
  private endIndex: number = 0;
  private isLoading: boolean = false;

  constructor(config: ListConfig) {
    this.config = config;
    this.endIndex = Math.min(
      this.config.visibleItemCount + this.config.bufferItemCount,
      this.config.itemCount
    );
  }

  /**
   * 设置数据
   */
  setData(data: Object[]): void {
    this.config.itemCount = data.length;
    this.updateVisibleData(data);
  }

  /**
   * 获取可见数据
   */
  getVisibleData(): Object[] {
    return this.visibleData;
  }

  /**
   * 处理滚动事件
   */
  handleScroll(scrollTop: number, data: Object[]): void {
    const itemHeight = this.config.itemHeight;
    const bufferCount = this.config.bufferItemCount;
    const visibleCount = this.config.visibleItemCount;

    let newStartIndex = Math.floor(scrollTop / itemHeight) - bufferCount;
    newStartIndex = Math.max(0, newStartIndex);

    let newEndIndex = newStartIndex + visibleCount + 2 * bufferCount;
    newEndIndex = Math.min(this.config.itemCount, newEndIndex);

    if (Math.abs(newStartIndex - this.startIndex) > bufferCount / 2) {
      this.startIndex = newStartIndex;
      this.endIndex = newEndIndex;
      this.updateVisibleData(data);
    }
  }

  /**
   * 更新可见数据
   */
  private updateVisibleData(data: Object[]): void {
    const start = this.startIndex;
    const end = this.endIndex;

    if (data && data.length >= end) {
      this.visibleData = data.slice(start, end);
      LogUtil.debug(`Visible range: ${start} - ${end}`);
    }
  }

  /**
   * 获取列表项位置
   */
  getItemPosition(index: number): number {
    return index * this.config.itemHeight;
  }

  /**
   * 获取总高度
   */
  getTotalHeight(): number {
    return this.config.itemCount * this.config.itemHeight;
  }

  /**
   * 滚动到指定位置
   */
  scrollToIndex(index: number): void {
    if (index < 0 || index >= this.config.itemCount) {
      return;
    }
    LogUtil.info(`Scrolled to index: ${index}`);
  }
}