/**
 * SmartGuardian - Status Badge Component
 * Unified status badge for displaying status with consistent styling
 * 
 * @description 统一状态徽章组件，用于显示各种状态标签
 */

import { StatusType, StatusMappingHelper } from '../constants/StatusMapping';

/**
 * Status Badge Size
 */
export enum BadgeSize {
  /** 小尺寸 */
  SMALL = 'SMALL',
  /** 默认尺寸 */
  DEFAULT = 'DEFAULT',
  /** 大尺寸 */
  LARGE = 'LARGE'
}

/**
 * Badge Size Configuration
 */
interface BadgeSizeConfig {
  fontSize: number;
  paddingH: number;
  paddingV: number;
  borderRadius: number;
}

const BADGE_SIZE_CONFIG: Record<BadgeSize, BadgeSizeConfig> = {
  [BadgeSize.SMALL]: {
    fontSize: 10,
    paddingH: 6,
    paddingV: 2,
    borderRadius: 4
  },
  [BadgeSize.DEFAULT]: {
    fontSize: 12,
    paddingH: 8,
    paddingV: 4,
    borderRadius: 6
  },
  [BadgeSize.LARGE]: {
    fontSize: 14,
    paddingH: 12,
    paddingV: 6,
    borderRadius: 8
  }
};

/**
 * Status Badge Component
 */
@Component
export struct StatusBadge {
  /** 状态类型 */
  @Prop type: StatusType = StatusType.ATTENDANCE;
  /** 状态值 */
  @Prop value: string = '';
  /** 徽章尺寸 */
  @Prop badgeSize: BadgeSize = BadgeSize.DEFAULT;
  /** 是否显示 */
  @Prop visible: boolean = true;
  /** 自定义文本 */
  @Prop customText?: string;
  /** 自定义文字颜色 */
  @Prop customTextColor?: string;
  /** 自定义背景颜色 */
  @Prop customBgColor?: string;

  build() {
    if (!this.visible || !this.value) {
      // 不渲染
    } else {
      this.buildBadge()
    }
  }

  @Builder
  buildBadge() {
    Text(this.getDisplayText())
      .fontSize(this.getSizeConfig().fontSize)
      .fontColor(this.getTextColor())
      .padding({
        left: this.getSizeConfig().paddingH,
        right: this.getSizeConfig().paddingH,
        top: this.getSizeConfig().paddingV,
        bottom: this.getSizeConfig().paddingV
      })
      .backgroundColor(this.getBgColor())
      .borderRadius(this.getSizeConfig().borderRadius)
  }

  private getDisplayText(): string {
    if (this.customText) {
      return this.customText;
    }
    return StatusMappingHelper.getStatusText(this.type, this.value);
  }

  private getTextColor(): string {
    if (this.customTextColor) {
      return this.customTextColor;
    }
    return StatusMappingHelper.getStatusColor(this.type, this.value);
  }

  private getBgColor(): string {
    if (this.customBgColor) {
      return this.customBgColor;
    }
    return StatusMappingHelper.getStatusBgColor(this.type, this.value);
  }

  private getSizeConfig(): BadgeSizeConfig {
    return BADGE_SIZE_CONFIG[this.badgeSize];
  }
}

/**
 * Simple Status Badge
 */
@Component
export struct SimpleStatusBadge {
  @Prop text: string = '';
  @Prop textColor: string = '#666666';
  @Prop bgColor: string = '#F5F5F5';
  @Prop badgeSize: BadgeSize = BadgeSize.DEFAULT;

  build() {
    if (!this.text) {
      // 不渲染
    } else {
      Text(this.text)
        .fontSize(this.getSizeConfig().fontSize)
        .fontColor(this.textColor)
        .padding({
          left: this.getSizeConfig().paddingH,
          right: this.getSizeConfig().paddingH,
          top: this.getSizeConfig().paddingV,
          bottom: this.getSizeConfig().paddingV
        })
        .backgroundColor(this.bgColor)
        .borderRadius(this.getSizeConfig().borderRadius)
    }
  }

  private getSizeConfig(): BadgeSizeConfig {
    return BADGE_SIZE_CONFIG[this.badgeSize];
  }
}

/**
 * Attendance Status Badge
 */
@Component
export struct AttendanceBadge {
  @Prop status: string = '';
  @Prop badgeSize: BadgeSize = BadgeSize.DEFAULT;

  build() {
    StatusBadge({
      type: StatusType.ATTENDANCE,
      value: this.status,
      badgeSize: this.badgeSize
    })
  }
}

/**
 * Order Status Badge
 */
@Component
export struct OrderBadge {
  @Prop status: string = '';
  @Prop badgeSize: BadgeSize = BadgeSize.DEFAULT;

  build() {
    StatusBadge({
      type: StatusType.ORDER,
      value: this.status,
      badgeSize: this.badgeSize
    })
  }
}

/**
 * Homework Status Badge
 */
@Component
export struct HomeworkBadge {
  @Prop status: string = '';
  @Prop badgeSize: BadgeSize = BadgeSize.DEFAULT;

  build() {
    StatusBadge({
      type: StatusType.HOMEWORK,
      value: this.status,
      badgeSize: this.badgeSize
    })
  }
}

/**
 * Session Status Badge
 */
@Component
export struct SessionBadge {
  @Prop status: string = '';
  @Prop badgeSize: BadgeSize = BadgeSize.DEFAULT;

  build() {
    StatusBadge({
      type: StatusType.SESSION,
      value: this.status,
      badgeSize: this.badgeSize
    })
  }
}
