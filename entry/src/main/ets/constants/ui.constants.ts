/**
 * SmartGuardian - UI Constants
 * UI-related constants
 */

/**
 * Colors
 */
export class AppColors {
  // Primary colors
  static readonly PRIMARY = '#3B82F6';
  static readonly PRIMARY_LIGHT = '#60A5FA';
  static readonly PRIMARY_DARK = '#2563EB';

  // Secondary colors
  static readonly SECONDARY = '#10B981';
  static readonly SECONDARY_LIGHT = '#34D399';
  static readonly SECONDARY_DARK = '#059669';

  // Status colors
  static readonly SUCCESS = '#10B981';
  static readonly WARNING = '#F59E0B';
  static readonly ERROR = '#EF4444';
  static readonly INFO = '#3B82F6';

  // Neutral colors
  static readonly WHITE = '#FFFFFF';
  static readonly BLACK = '#000000';
  static readonly GRAY_50 = '#F9FAFB';
  static readonly GRAY_100 = '#F3F4F6';
  static readonly GRAY_200 = '#E5E7EB';
  static readonly GRAY_300 = '#D1D5DB';
  static readonly GRAY_400 = '#9CA3AF';
  static readonly GRAY_500 = '#6B7280';
  static readonly GRAY_600 = '#4B5563';
  static readonly GRAY_700 = '#374151';
  static readonly GRAY_800 = '#1F2937';
  static readonly GRAY_900 = '#111827';

  // Background colors
  static readonly BG_PRIMARY = '#FFFFFF';
  static readonly BG_SECONDARY = '#F9FAFB';
  static readonly BG_TERTIARY = '#F3F4F6';

  // Text colors
  static readonly TEXT_PRIMARY = '#111827';
  static readonly TEXT_SECONDARY = '#6B7280';
  static readonly TEXT_TERTIARY = '#9CA3AF';
  static readonly TEXT_PLACEHOLDER = '#D1D5DB';
}

/**
 * Font Sizes
 */
export class FontSize {
  static readonly XS = 10;
  static readonly SM = 12;
  static readonly BASE = 14;
  static readonly MD = 16;
  static readonly LG = 18;
  static readonly XL = 20;
  static readonly XXL = 24;
  static readonly XXXL = 30;
  static readonly HEADING = 36;
}

/**
 * Spacing
 */
export class Spacing {
  static readonly XS = 4;
  static readonly SM = 8;
  static readonly BASE = 12;
  static readonly MD = 16;
  static readonly LG = 20;
  static readonly XL = 24;
  static readonly XXL = 32;
  static readonly XXXL = 48;
}

/**
 * Border Radius
 */
export class BorderRadius {
  static readonly NONE = 0;
  static readonly SM = 4;
  static readonly BASE = 8;
  static readonly MD = 12;
  static readonly LG = 16;
  static readonly XL = 20;
  static readonly XXL = 24;
  static readonly FULL = 999;
}

/**
 * Icon Sizes
 */
export class IconSize {
  static readonly XS = 12;
  static readonly SM = 16;
  static readonly BASE = 20;
  static readonly MD = 24;
  static readonly LG = 32;
  static readonly XL = 40;
  static readonly XXL = 48;
  static readonly XXXL = 64;
}

/**
 * Breakpoints
 */
export class Breakpoints {
  static readonly SM = 320;
  static readonly MD = 600;
  static readonly LG = 840;
  static readonly XL = 1024;
  static readonly XXL = 1280;
}

/**
 * Animation Duration
 */
export class Duration {
  static readonly FAST = 150;
  static readonly BASE = 300;
  static readonly SLOW = 500;
  static readonly VERY_SLOW = 1000;
}

/**
 * Z-Index
 */
export class ZIndex {
  static readonly BASE = 0;
  static readonly DROPDOWN = 1000;
  static readonly STICKY = 1020;
  static readonly FIXED = 1030;
  static readonly MODAL_BACKDROP = 1040;
  static readonly MODAL = 1050;
  static readonly POPOVER = 1060;
  static readonly TOOLTIP = 1070;
}
