/**
 * SmartGuardian - Parent Profile Page
 * Parent can view and edit profile, manage children, and logout
 */

import { UserStore } from '../../stores/userStore';
import { AuthService } from '../../services/api/auth';

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
    this.userName = '';
    this.mobile = '';
    this.avatar = '';
    AppStorage.setOrCreate('main_auth_locked', true);
    try {
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/LoginPage' });
    } catch (error) {
      console.error('ParentProfilePage logout redirect failed:', String(error));
    }
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
    .onClick(() => {
      // 跳转到个人信息编辑页
      this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentProfileEditPage' });
    })
  }

  @Builder
  buildMenuItems() {
    Column() {
      this.buildMenuItem('我的孩子', $r('app.media.ic_child'), () => {
        // 跳转到孩子管理页
        this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentChildrenPage' });
      })
      
      this.buildMenuItem('账户设置', $r('app.media.ic_settings'), () => {
        // 跳转到账户设置页
        this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentSettingsPage' });
      })
      
      this.buildMenuItem('帮助与反馈', $r('app.media.ic_help'), () => {
        // 跳转到帮助与反馈页
        this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentHelpPage' });
      })
      
      this.buildMenuItem('关于我们', $r('app.media.ic_about'), () => {
        // 跳转到关于我们页
        this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentAboutPage' });
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