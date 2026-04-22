/**
 * SmartGuardian - Parent Profile Edit Page
 * Parent profile edit page with unified card layout
 */

import { Card, HeaderTheme, InfoCard, InfoItem, PageHeader, SectionHeader } from '../../components/common';
import { UserStore } from '../../stores/userStore';

@Entry
@Component
struct ParentProfileEditPage {
  @State userName: string = '';
  @State mobile: string = '';
  @State avatar: string = '';
  @State isSaving: boolean = false;

  aboutToAppear() {
    const userInfo = UserStore.getUserInfo();
    if (userInfo) {
      this.userName = userInfo.realName;
      this.mobile = userInfo.mobile;
      this.avatar = userInfo.avatar || '';
    }
  }

  async selectAvatar() {
    try {
      this.avatar = 'mock_avatar_path';
      console.log('Avatar selected');
    } catch (error) {
      console.error('Select avatar failed:', String(error));
    }
  }

  async saveProfile() {
    this.isSaving = true;
    try {
      const userInfo = UserStore.getUserInfo();
      if (userInfo) {
        userInfo.realName = this.userName;
        userInfo.avatar = this.avatar;
        UserStore.setUserInfo(userInfo);
      }
      this.getUIContext().getRouter().back();
    } catch (error) {
      console.error('Save profile failed:', String(error));
    } finally {
      this.isSaving = false;
    }
  }

  build() {
    Column() {
      PageHeader({
        title: '编辑资料',
        subtitle: '维护头像、姓名和基础账户信息。',
        showBack: true,
        onBackClick: () => this.getUIContext().getRouter().back(),
        theme: HeaderTheme.PRIMARY,
        rightContent: this.buildSaveAction
      })

      Scroll() {
        Column() {
          this.buildAvatarPanel()
          this.buildProfileForm()
          this.buildAccountInfo()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  private buildSaveAction() {
    Text(this.isSaving ? '保存中' : '保存')
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.White)
      .opacity(this.isSaving ? 0.7 : 1)
      .onClick(() => {
        if (!this.isSaving) {
          this.saveProfile();
        }
      })
  }

  @Builder
  private buildAvatarPanel() {
    Card({
      title: '头像设置',
      subtitle: '可替换头像，后续会同步到家长端工作台。',
      actionText: '更换头像',
      onAction: (): void => {
        this.selectAvatar();
      },
      content: this.buildAvatarPanelContent
    })
  }

  @Builder
  private buildAvatarPanelContent() {
    Row() {
      if (this.avatar) {
        Image(this.avatar)
          .width(88)
          .height(88)
          .borderRadius(44)
          .objectFit(ImageFit.Cover)
      } else {
        Image($r('app.media.ic_default_avatar'))
          .width(88)
          .height(88)
          .borderRadius(44)
      }

      Column() {
        Text(this.userName || '家长用户')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Text(this.mobile || '未绑定手机号')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 6 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private buildProfileForm() {
    Column() {
      SectionHeader({
        title: '资料编辑',
        subtitle: '当前仅开放昵称编辑，手机号为只读信息。'
      })

      Card({
        title: '基础信息',
        content: this.buildProfileFormContent
      })
    }
    .width('100%')
  }

  @Builder
  private buildProfileFormContent() {
    Column() {
      Text('姓名')
        .width('100%')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_secondary'))

      TextInput({
        text: this.userName,
        placeholder: '请输入姓名'
      })
        .width('100%')
        .height(52)
        .fontSize(15)
        .backgroundColor('#F7FAFD')
        .borderRadius(16)
        .margin({ top: 8 })
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          this.userName = value;
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildAccountInfo() {
    Column() {
      SectionHeader({
        title: '账户信息',
        subtitle: '这些字段由登录账号统一维护。'
      })

      InfoCard({
        items: this.getAccountItems(),
        columns: 2
      })
    }
    .width('100%')
  }

  private getAccountItems(): InfoItem[] {
    return [
      { label: '手机号', value: this.mobile || '--' },
      { label: '角色类型', value: '家长端' },
      { label: '资料状态', value: this.userName ? '已完善' : '待完善' },
      { label: '同步方式', value: '本地登录态' }
    ];
  }
}
