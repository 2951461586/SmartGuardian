/**
 * SmartGuardian - Main Entry Page
 * Main shell with bottom navigation for different roles
 */

import { ApiConfig } from '../config/api.config';
import { HarmonyColor, harmonyShadowColor } from '../common/HarmonyDesign';
import { getRolePalette } from '../common/RoleTheme';
import {
  WorkbenchNavItem,
  getWorkbenchNavItems,
  getWorkbenchScope,
  normalizeWorkbenchNavCode
} from '../common/WorkbenchRegistry';
import { RoleWorkbenchHost } from '../components/common/RoleWorkbenchHost';
import { RouteUrls, StorageKeys } from '../constants/app.constants';
import { UserRole } from '../models/common';
import { WorkbenchManifest } from '../models/workbench';
import { AppLaunchCoordinatorService } from '../services/AppLaunchCoordinatorService';
import { SessionBootstrapService } from '../services/SessionBootstrapService';
import { WorkbenchService } from '../services/api/workbench';
import { UserStore } from '../stores/userStore';

@Entry
@Component
struct MainPage {
  @StorageLink('main_current_index') currentIndex: number = 0;
  @StorageLink('main_auth_locked') authLocked: boolean = false;
  @State currentRole: UserRole = UserRole.PARENT;
  @State isInitializing: boolean = true;
  @State workbenchManifest: WorkbenchManifest | null = null;

  aboutToAppear() {
    this.initAuthState();
  }

  async initAuthState(): Promise<void> {
    const bootstrap = await SessionBootstrapService.bootstrapCurrentSession();
    if (!bootstrap.success || !bootstrap.userInfo) {
      this.authLocked = true;
      this.isInitializing = false;
      this.navigateToLogin();
      return;
    }

    this.currentRole = bootstrap.role;
    this.authLocked = false;
    AppLaunchCoordinatorService.markAuthUnlocked();
    await this.loadWorkbenchManifest();
    this.syncStoredNavigationScope();
    this.isInitializing = false;
  }

  private async loadWorkbenchManifest(): Promise<void> {
    try {
      const resp = await WorkbenchService.getManifest();
      if (resp.code === 0 && resp.data) {
        this.workbenchManifest = resp.data;
        AppStorage.setOrCreate(StorageKeys.WORKBENCH_MANIFEST, resp.data);
        return;
      }
    } catch (error) {
      console.warn('MainPage load workbench manifest failed:', String(error));
    }

    this.workbenchManifest = null;
    AppStorage.delete(StorageKeys.WORKBENCH_MANIFEST);
  }

  private navigateToLogin(): void {
    try {
      AppLaunchCoordinatorService.markAuthLocked();
      this.getUIContext().getRouter().replaceUrl({ url: RouteUrls.LOGIN });
    } catch (error) {
      this.authLocked = true;
      this.isInitializing = false;
      this.currentIndex = 0;
      console.error('MainPage navigate to login failed:', String(error));
    }
  }

  private syncStoredNavigationScope(): void {
    const userInfo = UserStore.getUserInfo();
    const manifestVersion = this.workbenchManifest?.version ?? 'fallback';
    const currentScope = getWorkbenchScope(this.currentRole, userInfo?.id ?? 0, manifestVersion);
    const storedScope = AppStorage.get<string>(StorageKeys.MAIN_NAVIGATION_SCOPE) ?? '';

    if (storedScope !== currentScope) {
      this.currentIndex = 0;
      AppStorage.setOrCreate(StorageKeys.MAIN_NAVIGATION_SCOPE, currentScope);
      return;
    }

    this.ensureValidCurrentIndex();
  }

  private ensureValidCurrentIndex(): void {
    const maxIndex = this.getNavItems().length - 1;
    if (maxIndex < 0 || this.currentIndex > maxIndex) {
      this.currentIndex = 0;
    }
  }

  private getRolePrimary(): string {
    return getRolePalette(this.currentRole).primary;
  }

  private getRoleLight(): string {
    return getRolePalette(this.currentRole).light;
  }

  private getRoleBorder(): string {
    return getRolePalette(this.currentRole).border;
  }

  private getRoleShadow(): string {
    return getRolePalette(this.currentRole).shadow;
  }

  private getNavItems(): WorkbenchNavItem[] {
    return getWorkbenchNavItems(this.currentRole, this.workbenchManifest);
  }

  private getCurrentNavCode(): string {
    return normalizeWorkbenchNavCode(
      this.currentRole,
      this.getNavItems()[this.currentIndex]?.code ?? 'home',
      this.workbenchManifest
    );
  }

  build() {
    Column() {
      if (this.isInitializing) {
        this.buildInitializingState()
      } else if (this.authLocked) {
        this.buildAuthLockedState()
      } else {
        this.buildContent()
        this.buildBottomNav()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildInitializingState() {
    Column() {
      Column() {
        LoadingProgress()
          .color(HarmonyColor.textInverse)
          .width(36)
          .height(36)
      }
      .width(82)
      .height(82)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.getRolePrimary())
      .borderRadius(30)
      .shadow({
        radius: 22,
        color: this.getRoleShadow(),
        offsetX: 0,
        offsetY: 10
      })

      Text('正在准备工作台')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 22 })

      Text(`当前模式：${ApiConfig.getEnvironmentLabel()}`)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })

      Text('正在同步导航、模块入口和后端能力清单')
        .fontSize(12)
        .fontColor($r('app.color.text_tertiary'))
        .margin({ top: 6 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildAuthLockedState() {
    Column() {
      Column() {
        Text('登录状态已失效')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Text('请重新登录后继续使用 SmartGuardian 工作台。')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .lineHeight(21)
          .margin({ top: 10 })

        Button('返回登录')
          .width('100%')
          .height(48)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(HarmonyColor.textInverse)
          .backgroundColor(this.getRolePrimary())
          .borderRadius(18)
          .margin({ top: 22 })
          .onClick(() => {
            this.navigateToLogin();
          })
      }
      .width('100%')
      .padding(24)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(28)
      .border({
        width: 1,
        color: HarmonyColor.line,
        radius: 28,
        style: BorderStyle.Solid
      })
      .shadow({
        radius: 22,
        color: this.getRoleShadow(),
        offsetX: 0,
        offsetY: 8
      })
      .margin({ left: 24, right: 24 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildContent() {
    RoleWorkbenchHost({
      role: this.currentRole,
      navCode: this.getCurrentNavCode()
    })
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  private buildBottomNav() {
    Column() {
      Divider()
        .color(HarmonyColor.line)

      Row() {
        ForEach(this.getNavItems(), (item: WorkbenchNavItem, index: number) => {
          this.buildNavItem(index, item.label, item.icon)
        })
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 12 })
    }
    .width('100%')
    .backgroundColor($r('app.color.bottom_nav_background'))
    .shadow({
      radius: 16,
      color: harmonyShadowColor(),
      offsetX: 0,
      offsetY: -2
    })
  }

  @Builder
  private buildNavItem(index: number, label: ResourceStr, icon: Resource) {
    Column() {
      Image(icon)
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)
        .fillColor(this.currentIndex === index ? this.getRolePrimary() : $r('app.color.nav_icon_inactive'))

      Text(label)
        .fontSize(11)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? this.getRolePrimary() : $r('app.color.nav_icon_inactive'))
        .margin({ top: 6 })
    }
    .layoutWeight(1)
    .height(58)
    .padding({ top: 6, bottom: 6 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.currentIndex === index ? this.getRoleLight() : $r('app.color.bottom_nav_background'))
    .borderRadius(18)
    .border({
      width: this.currentIndex === index ? 1 : 0,
      color: this.currentIndex === index ? this.getRoleBorder() : $r('app.color.bottom_nav_background'),
      radius: 18,
      style: BorderStyle.Solid
    })
    .opacity(this.currentIndex === index ? 1 : 0.96)
    .onClick(() => {
      this.currentIndex = index;
    })
  }
}
