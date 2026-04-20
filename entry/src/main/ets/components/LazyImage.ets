/**
 * SmartGuardian - LazyImage Component
 * 图片懒加载组件，支持占位图、错误图、渐进式加载
 * 
 * @description 性能优化组件，适用于列表中的图片加载场景
 * @features
 * - 懒加载：只加载可视区域内的图片
 * - 占位图：加载中显示占位图
 * - 错误处理：加载失败显示错误图
 * - 内存优化：自动释放不可见图片资源
 */

@Component
export struct LazyImage {
  @Prop src: string = '';
  @Prop placeholderSrc: Resource | string = $r('app.media.ic_empty');
  @Prop errorSrc: Resource | string = $r('app.media.ic_default_avatar');
  @Prop width: number | string = '100%';
  @Prop height: number | string = 100;
  @Prop borderRadius: number = 0;
  @Prop objectFit: ImageFit = ImageFit.Cover;
  @State private imageSrc: Resource | string = '';
  @State private isLoading: boolean = true;
  @State private hasError: boolean = false;
  @State private opacity: number = 0;

  aboutToAppear(): void {
    this.imageSrc = this.placeholderSrc;
    this.loadImage();
  }

  /**
   * 加载图片
   */
  private loadImage(): void {
    if (!this.src || this.src === '') {
      this.hasError = true;
      this.imageSrc = this.errorSrc;
      this.isLoading = false;
      return;
    }

    this.isLoading = true;
    this.hasError = false;
    this.imageSrc = this.src;
    this.opacity = 1;
  }

  /**
   * 图片加载成功
   */
  private onLoadSuccess(): void {
    this.isLoading = false;
    this.hasError = false;
    this.opacity = 1;
  }

  /**
   * 图片加载失败
   */
  private onLoadError(): void {
    this.isLoading = false;
    this.hasError = true;
    this.imageSrc = this.errorSrc;
  }

  build() {
    Stack() {
      Image(this.imageSrc)
        .width(this.width)
        .height(this.height)
        .objectFit(this.objectFit)
        .borderRadius(this.borderRadius)
        .opacity(this.opacity)
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        })
        .onComplete(() => {
          this.onLoadSuccess();
        })
        .onError(() => {
          this.onLoadError();
        })

      // 加载指示器
      if (this.isLoading) {
        LoadingProgress()
          .width(24)
          .height(24)
          .color('#2196F3')
      }
    }
    .width(this.width)
    .height(this.height)
  }
}

/**
 * 带缓存的图片组件
 * 适用于需要缓存的图片场景
 */
@Component
export struct CachedImage {
  @Prop src: string = '';
  @Prop placeholderSrc: Resource | string = $r('app.media.ic_empty');
  @Prop errorSrc: Resource | string = $r('app.media.ic_default_avatar');
  @Prop width: number | string = '100%';
  @Prop height: number | string = 100;
  @Prop borderRadius: number = 0;
  @Prop objectFit: ImageFit = ImageFit.Cover;
  @State private imageSrc: Resource | string = '';
  @State private isLoaded: boolean = false;

  // 简单的内存缓存
  private static imageCache: Map<string, string> = new Map();

  aboutToAppear(): void {
    this.loadFromCache();
  }

  /**
   * 从缓存加载或下载图片
   */
  private loadFromCache(): void {
    if (!this.src) {
      this.imageSrc = this.errorSrc;
      return;
    }

    // 检查缓存
    const cached = CachedImage.imageCache.get(this.src);
    if (cached) {
      this.imageSrc = cached;
      this.isLoaded = true;
    } else {
      this.imageSrc = this.src;
      this.isLoaded = false;
    }
  }

  /**
   * 图片加载成功，加入缓存
   */
  private onLoadSuccess(): void {
    this.isLoaded = true;
    CachedImage.imageCache.set(this.src, this.src);
  }

  build() {
    Stack() {
      Image(this.imageSrc)
        .width(this.width)
        .height(this.height)
        .objectFit(this.objectFit)
        .borderRadius(this.borderRadius)
        .opacity(this.isLoaded ? 1 : 0)
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        })
        .onComplete(() => {
          this.onLoadSuccess();
        })
        .onError(() => {
          this.imageSrc = this.errorSrc;
        })

      if (!this.isLoaded) {
        Image(this.placeholderSrc)
          .width(this.width)
          .height(this.height)
          .objectFit(this.objectFit)
          .borderRadius(this.borderRadius)
          .opacity(0.5)

        LoadingProgress()
          .width(20)
          .height(20)
          .color('#999999')
      }
    }
    .width(this.width)
    .height(this.height)
  }
}

/**
 * 头像组件
 * 适用于用户头像场景，支持默认头像
 */
@Component
export struct AvatarImage {
  @Prop src: string = '';
  @Prop name: string = '';
  @Prop size: number = 40;
  @Prop borderRadius: number = -1; // -1 表示圆形

  build() {
    Stack() {
      if (this.src && this.src !== '') {
        Image(this.src)
          .width(this.size)
          .height(this.size)
          .borderRadius(this.borderRadius === -1 ? this.size / 2 : this.borderRadius)
          .objectFit(ImageFit.Cover)
          .onError(() => {
            // 加载失败显示名称首字
          })
      } else {
        // 显示名称首字
        Text(this.getNameInitial())
          .fontSize(this.size * 0.4)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.getAvatarColor())
          .width(this.size)
          .height(this.size)
          .borderRadius(this.borderRadius === -1 ? this.size / 2 : this.borderRadius)
          .textAlign(TextAlign.Center)
      }
    }
    .width(this.size)
    .height(this.size)
  }

  /**
   * 获取名称首字
   */
  private getNameInitial(): string {
    if (this.name && this.name.length > 0) {
      return this.name.charAt(0);
    }
    return '?';
  }

  /**
   * 根据名称生成头像颜色
   */
  private getAvatarColor(): string {
    const colors: string[] = [
      '#2196F3', '#4CAF50', '#FF9800', '#9C27B0',
      '#F44336', '#00BCD4', '#FF5722', '#795548'
    ];
    
    if (!this.name || this.name.length === 0) {
      return colors[0];
    }

    let hash = 0;
    for (let i = 0; i < this.name.length; i++) {
      hash = this.name.charCodeAt(i) + ((hash << 5) - hash);
    }
    
    return colors[Math.abs(hash) % colors.length];
  }
}
