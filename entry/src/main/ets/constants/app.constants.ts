/**
 * SmartGuardian - Application Constants
 * Global constants and configuration
 */

/**
 * Application Info
 */
export class AppConstants {
  /**
   * App name
   */
  static readonly APP_NAME: string = '智慧托管';

  /**
   * App version
   */
  static readonly APP_VERSION: string = '1.0.0';

  /**
   * App build number
   */
  static readonly BUILD_NUMBER: string = '1';

  /**
   * App description
   */
  static readonly APP_DESCRIPTION: string = '学生智慧托管系统';
}

/**
 * Storage Keys
 */
export class StorageKeys {
  // Auth
  static readonly TOKEN = 'smart_guardian_token';
  static readonly USER_INFO = 'user_info';
  static readonly IS_LOGGED_IN = 'is_logged_in';
  static readonly PRIVACY_AGREED = 'privacy_agreed';

  // User preferences
  static readonly THEME = 'app_theme';
  static readonly LANGUAGE = 'app_language';
  static readonly NOTIFICATION_ENABLED = 'notification_enabled';

  // Cache
  static readonly CACHE_PREFIX = 'cache_';
  static readonly LAST_UPDATE_TIME = 'last_update_time';

  // Session
  static readonly CART_DATA = 'cart_data';
  static readonly SEARCH_HISTORY = 'search_history';
}

/**
 * Route URLs
 */
export class RouteUrls {
  // Common
  static readonly LOGIN = 'pages/LoginPage';
  static readonly MAIN = 'pages/MainPage';
  static readonly INDEX = 'pages/Index';

  // Parent pages
  static readonly PARENT_HOME = 'pages/parent/ParentHomePage';
  static readonly PARENT_ORDERS = 'pages/parent/ParentOrdersPage';
  static readonly PARENT_SERVICES = 'pages/parent/ParentServicesPage';
  static readonly PARENT_MESSAGES = 'pages/parent/ParentMessagesPage';
  static readonly PARENT_PROFILE = 'pages/parent/ParentProfilePage';
  static readonly PARENT_TIMELINE = 'pages/parent/ParentTimelinePage';

  // Teacher pages
  static readonly TEACHER_HOME = 'pages/teacher/TeacherHomePage';
  static readonly TEACHER_ATTENDANCE = 'pages/teacher/TeacherAttendancePage';
  static readonly TEACHER_HOMEWORK = 'pages/teacher/TeacherHomeworkPage';
  static readonly TEACHER_SCHEDULE = 'pages/teacher/TeacherSchedulePage';
  static readonly TEACHER_SCAN = 'pages/teacher/TeacherScanPage';

  // Common pages
  static readonly COMMON_QRCODE_SCAN = 'pages/common/QRCodeScanPage';

  // Admin pages
  static readonly ADMIN_HOME = 'pages/admin/AdminHomePage';
  static readonly ADMIN_STUDENTS = 'pages/admin/AdminStudentsPage';
  static readonly ADMIN_ORDERS = 'pages/admin/AdminOrdersPage';
  static readonly ADMIN_REPORTS = 'pages/admin/AdminReportsPage';
}

/**
 * Event Names
 */
export class EventNames {
  static readonly USER_LOGIN = 'user_login';
  static readonly USER_LOGOUT = 'user_logout';
  static readonly USER_INFO_UPDATE = 'user_info_update';
  static readonly CART_UPDATE = 'cart_update';
  static readonly MESSAGE_RECEIVE = 'message_receive';
  static readonly THEME_CHANGE = 'theme_change';
  static readonly LANGUAGE_CHANGE = 'language_change';
}

/**
 * Date Format
 */
export class DateFormat {
  static readonly DATE = 'YYYY-MM-DD';
  static readonly TIME = 'HH:mm:ss';
  static readonly DATETIME = 'YYYY-MM-DD HH:mm:ss';
  static readonly DATETIME_SHORT = 'MM-DD HH:mm';
  static readonly DATE_CN = 'YYYY年MM月DD日';
}

/**
 * User Role Routes Mapping
 */
export class RoleRoutes {
  static readonly DEFAULT_ROUTE: Record<string, string> = {
    'PARENT': RouteUrls.PARENT_HOME,
    'TEACHER': RouteUrls.TEACHER_HOME,
    'ORG_ADMIN': RouteUrls.ADMIN_HOME,
    'SCHOOL_ADMIN': RouteUrls.ADMIN_HOME,
    'PLATFORM_ADMIN': RouteUrls.ADMIN_HOME
  };

  static getDefaultRoute(role: string): string {
    return this.DEFAULT_ROUTE[role] ?? RouteUrls.LOGIN;
  }
}
