/**
 * SmartGuardian - Parent Profile Page
 * Parent can view and edit profile, manage children, and logout
 */

import { UserStore } from '../../stores/userStore';
import { AuthService } from '../../services/api/auth';
import { ActionCard, Card, GreetingHeader, InfoCard, InfoItem, SectionHeader } from '../../components/common';

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
      GreetingHeader({
        userName: this.userName || '家长',
        badgeText: '家长工作台',
        greeting: '统一查看家庭档案、孩子资料和服务设置。',
        metaText: this.mobile || '请完善联系方式'
      })

      Scroll() {
        Column() {
          this.buildProfileHero()
          this.buildAccountSummary()
          this.buildQuickActions()
          this.buildSecuritySection()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 28 })
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
  buildProfileHero() {
    Card({
      title: '账户信息',
      subtitle: '可进入详情页完善头像、昵称和联系方式。',
      actionText: '编辑资料',
      onAction: () => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentProfileEditPage' });
      },
      content: this.buildProfileHeroContent
    })
  }

  @Builder
  buildProfileHeroContent() {
    Row() {
      if (this.avatar) {
        Image(this.avatar)
          .width(64)
          .height(64)
          .borderRadius(32)
          .objectFit(ImageFit.Cover)
      } else {
        Image($r('app.media.ic_default_avatar'))
          .width(64)
          .height(64)
          .borderRadius(32)
          .objectFit(ImageFit.Cover)
      }

      Column() {
        Text(this.userName || '家长用户')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Text(this.mobile || '暂未绑定手机号')
          .fontSize($r('app.float.text_secondary_size'))
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 6 })

        Row() {
          Text('家庭身份')
            .fontSize(12)
            .fontColor('#2152CC')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor('#EAF1FF')
            .borderRadius(999)

          Text('消息通知已开启')
            .fontSize(12)
            .fontColor('#0F766E')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor('#E8FFFA')
            .borderRadius(999)
            .margin({ left: 8 })
        }
        .margin({ top: 12 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 14 })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildAccountSummary() {
    Column() {
      SectionHeader({
        title: '账户摘要',
        subtitle: '把身份、资料完整度和服务状态集中展示。'
      })

      InfoCard({
        items: this.getSummaryItems(),
        columns: 2
      })
    }
    .width('100%')
  }

  @Builder
  buildQuickActions() {
    Column() {
      SectionHeader({
        title: '常用服务',
        subtitle: '家长端最常用的资料、设置和帮助入口。'
      })

      ActionCard({
        icon: $r('app.media.ic_child'),
        cardTitle: '我的孩子',
        description: '查看绑定学生、托管安排和在校动态。',
        buttonText: '进入孩子档案',
        iconBgColor: '#EAF1FF',
        iconColor: '#1F5EFF',
        onAction: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentChildrenPage' });
        }
      })

      ActionCard({
        icon: $r('app.media.ic_settings'),
        cardTitle: '账户设置',
        description: '管理通知方式、隐私偏好和账号安全设置。',
        buttonText: '打开设置',
        iconBgColor: '#FFF3E8',
        iconColor: '#D97706',
        onAction: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentSettingsPage' });
        }
      })

      ActionCard({
        icon: $r('app.media.ic_help'),
        cardTitle: '帮助与反馈',
        description: '集中提交问题、查看使用说明和服务回复。',
        buttonText: '前往反馈',
        iconBgColor: '#ECFDF3',
        iconColor: '#15803D',
        onAction: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentHelpPage' });
        }
      })

      ActionCard({
        icon: $r('app.media.ic_about'),
        cardTitle: '关于我们',
        description: '查看平台介绍、版本信息和服务说明。',
        buttonText: '查看平台信息',
        iconBgColor: '#F5F3FF',
        iconColor: '#7C3AED',
        onAction: () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/parent/ParentAboutPage' });
        }
      })
    }
    .width('100%')
  }

  @Builder
  buildSecuritySection() {
    Column() {
      SectionHeader({
        title: '安全操作',
        subtitle: '退出当前账号前会保留本地配置，重新登录后可继续使用。'
      })

      Card({
        title: '退出当前账号',
        subtitle: '用于切换家长账号或重新验证登录状态。',
        actionText: '立即退出',
        onAction: () => {
          this.handleLogout();
        }
      })
    }
    .width('100%')
  }

  private getSummaryItems(): InfoItem[] {
    return [
      { label: '账户角色', value: '家长端' },
      { label: '手机号', value: this.mobile || '未绑定' },
      { label: '资料状态', value: this.userName ? '已完善' : '待完善', valueColor: this.userName ? '#15803D' : '#D97706' },
      { label: '登录状态', value: '当前在线', valueColor: '#1F5EFF' }
    ];
  }
}
