/**
 * SmartGuardian - Parent Profile Page
 * Parent can view and edit profile, manage children, and logout
 */

import { UserStore } from '../../stores/userStore';
import { AuthService } from '../../services/api/auth';
import { router } from '@kit.ArkUI';

@Component
export struct ParentProfilePage {
  @State userName: string = '';
  @State mobile: string = '';
  @State avatar: string = '';

  aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
      this.mobile = userInfo.mobile;
      this.avatar = userInfo.avatar || '';
    }
  }

  async handleLogout() {
    try {
      await AuthService.logout();
    } catch (error) {
      // Continue with local logout
    }
    UserStore.clearUserInfo();
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  build() {
    Column() {
      // Header
      this.buildHeader()

      // Profile info
      this.buildProfileInfo()

      // Menu items
      this.buildMenuItems()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Text('个人中心')
        .fontSize($r('app.float.page_title_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: Number($r('app.float.status_bar_height')) + 20, bottom: 20 })
    .backgroundColor($r('app.color.primary'))
  }

  @Builder
  buildProfileInfo() {
    Row() {
      // Avatar
      if (this.avatar) {
        Image(this.avatar)
          .width(60)
          .height(60)
          .borderRadius(30)
          .objectFit(ImageFit.Cover)
      } else {
        Image($r('app.media.ic_default_avatar'))
          .width(60)
          .height(60)
          .borderRadius(30)
          .objectFit(ImageFit.Cover)
      }

      Column() {
        Text(this.userName || '家长')
          .fontSize($r('app.float.text_primary_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Text(this.mobile || '')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: $r('app.float.card_content_margin') })

      Image($r('app.media.ic_arrow_right'))
        .width(20)
        .height(20)
        .objectFit(ImageFit.Contain)
        .fillColor($r('app.color.text_tertiary'))
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .margin({ top: $r('app.float.card_margin') })
  }

  @Builder
  buildMenuItems() {
    Column() {
      this.buildMenuItem('我的孩子', $r('app.media.ic_child'), () => {
        // TODO: Navigate to children management
      })
      this.buildMenuItem('账户设置', $r('app.media.ic_settings'), () => {
        // TODO: Navigate to settings
      })
      this.buildMenuItem('帮助与反馈', $r('app.media.ic_help'), () => {
        // TODO: Navigate to help
      })
      this.buildMenuItem('关于我们', $r('app.media.ic_about'), () => {
        // TODO: Navigate to about
      })

      Divider()
        .color($r('app.color.divider'))
        .margin({ top: $r('app.float.card_margin'), bottom: $r('app.float.card_margin') })

      Text('退出登录')
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.error'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: $r('app.float.card_padding'), bottom: $r('app.float.card_padding') })
        .onClick(() => {
          this.handleLogout();
        })
    }
    .width('100%')
    .padding($r('app.float.card_padding'))
    .backgroundColor(Color.White)
    .margin({ top: $r('app.float.card_margin') })
  }

  @Builder
  buildMenuItem(title: string, icon: Resource, action: () => void) {
    Row() {
      Image(icon)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        .fillColor($r('app.color.text_primary'))

      Text(title)
        .fontSize($r('app.float.text_primary_size'))
        .fontColor($r('app.color.text_primary'))
        .margin({ left: $r('app.float.card_content_margin') })

      Blank()

      Image($r('app.media.ic_arrow_right'))
        .width(16)
        .height(16)
        .objectFit(ImageFit.Contain)
        .fillColor($r('app.color.text_tertiary'))
    }
    .width('100%')
    .padding({ top: $r('app.float.card_padding'), bottom: $r('app.float.card_padding') })
    .onClick(action)
  }
}