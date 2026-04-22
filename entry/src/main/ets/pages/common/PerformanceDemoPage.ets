/**
 * SmartGuardian - 性能优化示例页面
 * 展示性能监控、列表优化等功能
 */

import { PerformanceMonitor, MetricType, PerformanceMetric } from '../../utils/performance/PerformanceMonitor';
import { OptimizationManager, MemoryWarningLevel } from '../../utils/performance/OptimizationManager';
import { ListOptimizer } from '../../utils/performance/ListOptimizer';
import { LogUtil } from '../../utils/LogUtil';

/**
 * 学生项接口
 */
interface StudentItem {
  id: string;
  name: string;
  className: string;
  status: string;
}

/**
 * 性能信息接口
 */
interface PerformanceInfo {
  totalMetrics: number;
  averageDuration: string;
  slowOperations: number;
}

/**
 * 图片缓存信息接口
 */
interface ImageCacheInfo {
  count: number;
  memoryUsage: string;
  hitRate: string;
}

/**
 * 性能报告接口
 */
interface PerformanceReport {
  timestamp: number;
  performance: PerformanceInfo;
  imageCache: ImageCacheInfo;
}

@Entry
@Component
struct PerformanceDemoPage {
  @State memoryUsed: number = 0;
  @State memoryTotal: number = 100;
  @State memoryWarning: MemoryWarningLevel = MemoryWarningLevel.NORMAL;
  @State slowOperations: PerformanceMetric[] = [];
  @State visibleItems: StudentItem[] = [];
  @State allStudents: StudentItem[] = [];
  @State totalItems: number = 0;
  @State isLoading: boolean = false;
  @State performanceInfo: PerformanceInfo | null = null;
  @State imageCacheInfo: ImageCacheInfo | null = null;

  private listOptimizer: ListOptimizer = new ListOptimizer({
    itemCount: 0,
    itemHeight: 80,
    visibleItemCount: 10,
    bufferItemCount: 5
  });
  private monitor: PerformanceMonitor = PerformanceMonitor.getInstance();
  private optimizationManager: OptimizationManager = OptimizationManager.getInstance();

  aboutToAppear(): void {
    LogUtil.info('PerformanceDemoPage appeared');

    // 加载初始数据
    this.loadInitialData();

    // 更新性能报告
    this.updatePerformanceReport();

    // 定时更新（模拟实时监控）
    setInterval(() => {
      this.updatePerformanceReport();
    }, 2000);
  }

  aboutToDisappear(): void {
    LogUtil.info('PerformanceDemoPage disappeared');
  }

  /**
   * 加载初始数据
   */
  async loadInitialData(): Promise<void> {
    this.isLoading = true;

    const startTime = Date.now();

    // 模拟加载大量数据
    const students = await this.loadMoreStudents();
    this.allStudents = students;
    
    // 设置列表优化器数据
    this.listOptimizer.setData(students);
    this.visibleItems = this.listOptimizer.getVisibleData() as StudentItem[];
    this.totalItems = students.length;

    // 记录加载性能
    this.optimizationManager.trackPageLoad('PerformanceDemo', startTime);

    this.isLoading = false;
  }

  /**
   * 模拟加载学生数据
   */
  async loadMoreStudents(): Promise<StudentItem[]> {
    return await this.monitor.measureAsync(
      'load_students',
      MetricType.DATA_PROCESSING,
      async () => {
        // 模拟网络延迟
        await new Promise<void>(resolve => setTimeout(resolve, 300));

        const students: StudentItem[] = [];

        for (let i = 0; i < 100; i++) {
          students.push({
            id: 'student_' + i,
            name: '学生' + i,
            className: Math.floor(i / 30) + 1 + '年级' + (i % 3 + 1) + '班',
            status: i % 3 === 0 ? '已签到' : i % 3 === 1 ? '待签到' : '迟到'
          });
        }

        return students;
      }
    );
  }

  /**
   * 更新性能报告
   */
  updatePerformanceReport(): void {
    const report: PerformanceReport = this.optimizationManager.getPerformanceReport() as PerformanceReport;
    
    // 获取性能信息
    this.performanceInfo = report.performance;
    
    // 获取缓存信息
    this.imageCacheInfo = report.imageCache;
    
    // 模拟内存数据
    this.memoryUsed = Math.random() * 50 + 20;
    this.memoryWarning = MemoryWarningLevel.NORMAL;

    this.slowOperations = this.monitor.getSlowOperations(5);
  }

  /**
   * 触发垃圾回收
   */
  handleGC(): void {
    this.optimizationManager.triggerGC();
    this.updatePerformanceReport();
  }

  /**
   * 清理缓存
   */
  handleClearCache(): void {
    this.optimizationManager.clearCache();
    this.updatePerformanceReport();
  }

  /**
   * 刷新列表
   */
  async handleRefresh(): Promise<void> {
    this.isLoading = true;
    await this.loadInitialData();
    this.isLoading = false;
  }

  build() {
    Column() {
      // 标题栏
      this.TitleBar()

      // 性能监控面板
      this.PerformancePanel()

      // 慢操作列表
      if (this.slowOperations.length > 0) {
        this.SlowOperationsList()
      }

      // 优化列表示例
      this.OptimizedList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  TitleBar() {
    Row() {
      Text('性能优化示例')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  PerformancePanel() {
    Column() {
      // 内存使用
      Row() {
        Column() {
          Text('内存使用')
            .fontSize(12)
            .fontColor('#999999')

          Text(this.memoryUsed.toFixed(1) + ' MB')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getMemoryColor())
            .margin({ top: 4 })

          Text('/ ' + this.memoryTotal.toFixed(0) + ' MB')
            .fontSize(10)
            .fontColor('#CCCCCC')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 内存进度条
        Stack() {
          Progress({
            value: this.memoryUsed,
            total: this.memoryTotal > 0 ? this.memoryTotal : 100,
            type: ProgressType.Ring
          })
            .width(60)
            .height(60)
            .color(this.getMemoryColor())

          Text(this.memoryTotal > 0 ? ((this.memoryUsed / this.memoryTotal) * 100).toFixed(0) + '%' : '0%')
            .fontSize(12)
            .fontColor('#666666')
        }

        // 操作按钮
        Column() {
          Button('回收')
            .fontSize(12)
            .height(28)
            .width(60)
            .backgroundColor('#2196F3')
            .margin({ bottom: 8 })
            .onClick(() => this.handleGC())

          Button('清理')
            .fontSize(12)
            .height(28)
            .width(60)
            .backgroundColor('#FF9800')
            .onClick(() => this.handleClearCache())
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .margin({ top: 12, left: 16, right: 16 })

      // 性能指标
      Row() {
        this.MetricItem('性能监控', this.getTotalMetricsValue(), '#4CAF50')
        this.MetricItem('慢操作', this.getSlowOperationsValue(), '#FF5722')
        this.MetricItem('图片缓存', this.getCacheValue(), '#9C27B0')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .margin({ top: 8, left: 16, right: 16 })
    }
  }

  @Builder
  MetricItem(label: string, value: string, color: string) {
    Column() {
      Text(label)
        .fontSize(11)
        .fontColor('#999999')

      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .margin({ top: 4 })
    }
  }

  @Builder
  SlowOperationsList() {
    Column() {
      Text('慢操作记录')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .padding({ left: 16, top: 16 })

      List() {
        ForEach(this.slowOperations, (item: PerformanceMetric) => {
          ListItem() {
            Row() {
              Column() {
                Text(item.name)
                  .fontSize(13)
                  .fontColor('#333333')

                Text(item.duration + 'ms')
                  .fontSize(12)
                  .fontColor('#FF5722')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text(new Date(item.timestamp).toLocaleTimeString())
                .fontSize(10)
                .fontColor('#999999')
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Color.White)
            .borderRadius(6)
          }
          .margin({ top: 8, left: 16, right: 16 })
        })
      }
      .width('100%')
      .height(120)
    }
  }

  @Builder
  OptimizedList() {
    Column() {
      Row() {
        Text('优化列表示例')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('共 ' + this.totalItems + ' 条')
          .fontSize(12)
          .fontColor('#999999')

        if (this.isLoading) {
          LoadingProgress()
            .width(16)
            .height(16)
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })

      List() {
        ForEach(this.visibleItems, (item: StudentItem) => {
          ListItem() {
            Row() {
              Column() {
                Text(item.name)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')

                Text(item.className)
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text(item.status)
                .fontSize(12)
                .fontColor(item.status === '已签到' ? '#4CAF50' : '#FF9800')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(item.status === '已签到' ? '#E8F5E9' : '#FFF3E0')
                .borderRadius(4)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Color.White)
            .borderRadius(8)
          }
          .margin({ top: 8, left: 16, right: 16 })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 8 })
      .edgeEffect(EdgeEffect.Spring)
    }
    .layoutWeight(1)
  }

  private getMemoryColor(): string {
    switch (this.memoryWarning) {
      case MemoryWarningLevel.NORMAL:
        return '#4CAF50';
      case MemoryWarningLevel.WARNING:
        return '#FF9800';
      case MemoryWarningLevel.CRITICAL:
        return '#F44336';
      default:
        return '#4CAF50';
    }
  }

  private getTotalMetricsValue(): string {
    if (this.performanceInfo !== null) {
      return String(this.performanceInfo.totalMetrics);
    }
    return '0';
  }

  private getSlowOperationsValue(): string {
    if (this.performanceInfo !== null) {
      return String(this.performanceInfo.slowOperations);
    }
    return '0';
  }

  private getCacheValue(): string {
    if (this.imageCacheInfo !== null) {
      return String(this.imageCacheInfo.count);
    }
    return '0';
  }
}
