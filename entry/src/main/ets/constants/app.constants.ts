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
  static readonly MAIN_CURRENT_INDEX = 'main_current_index';
  static readonly MAIN_AUTH_LOCKED = 'main_auth_locked';
  static readonly MAIN_NAVIGATION_SCOPE = 'main_navigation_scope';
  static readonly WORKBENCH_MANIFEST = 'workbench_manifest';
  static readonly API_ENV = 'smart_guardian_api_env';
  static readonly API_BASE_URL = 'smart_guardian_api_base_url';
  static readonly API_CONFIG_VERSION = 'smart_guardian_api_config_version';
  static readonly AGC_FUNCTION_TRIGGER_URL_PREFIX = 'smart_guardian_agc_function_trigger_url_';
  static readonly AGC_RUNTIME_READY = 'smart_guardian_agc_runtime_ready';
  static readonly AGC_CONFIG_READY = 'smart_guardian_agc_config_ready';
  static readonly AGC_AAID = 'smart_guardian_agc_aaid';
  static readonly AGC_APP_ID = 'smart_guardian_agc_app_id';
  static readonly AGC_CLIENT_ID = 'smart_guardian_agc_client_id';
  static readonly AGC_GATEWAY_TOKEN = 'smart_guardian_agc_gateway_token';
  static readonly AGC_GATEWAY_TOKEN_EXPIRE_AT = 'smart_guardian_agc_gateway_token_expire_at';
  static readonly AGC_AUTH_USER_UID = 'smart_guardian_agc_auth_user_uid';
  static readonly AGC_AUTH_USER_PHONE = 'smart_guardian_agc_auth_user_phone';
  static readonly AGC_RUNTIME_ERROR = 'smart_guardian_agc_runtime_error';
  static readonly NOTIFICATION_TARGET_ROUTE = 'smart_guardian_notification_target_route';
  static readonly NOTIFICATION_TARGET_PARAMS = 'smart_guardian_notification_target_params';

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

  // Parent pages
  static readonly PARENT_HOME = 'pages/parent/ParentHomePage';
  static readonly PARENT_ORDERS = 'pages/parent/ParentOrdersPage';
  static readonly PARENT_SERVICES = 'pages/parent/ParentServicesPage';
  static readonly PARENT_MESSAGES = 'pages/parent/ParentMessagesPage';
  static readonly PARENT_PROFILE = 'pages/parent/ParentProfilePage';
  static readonly PARENT_TIMELINE = 'pages/parent/ParentTimelinePage';
  static readonly PARENT_QRCODE = 'pages/parent/ParentQRCodePage';
  static readonly PARENT_HOMEWORK = 'pages/parent/ParentHomeworkPage';
  static readonly PARENT_SESSIONS = 'pages/parent/ParentSessionsPage';
  static readonly PARENT_SERVICE_DETAIL = 'pages/parent/ParentServiceDetailPage';
  static readonly PARENT_ORDER_CREATE = 'pages/parent/ParentOrderCreatePage';
  static readonly PARENT_ORDER_DETAIL = 'pages/parent/ParentOrderDetailPage';
  static readonly PARENT_PAYMENT = 'pages/parent/ParentPaymentPage';
  static readonly PARENT_LEAVE = 'pages/parent/ParentLeavePage';
  static readonly PARENT_ALERTS = 'pages/parent/ParentAlertsPage';
  static readonly PARENT_REFUND = 'pages/parent/ParentRefundPage';
  static readonly PARENT_MESSAGE_DETAIL = 'pages/parent/ParentMessageDetailPage';
  static readonly PARENT_PROFILE_EDIT = 'pages/parent/ParentProfileEditPage';
  static readonly PARENT_CHILDREN = 'pages/parent/ParentChildrenPage';
  static readonly PARENT_SETTINGS = 'pages/parent/ParentSettingsPage';
  static readonly PARENT_HELP = 'pages/parent/ParentHelpPage';
  static readonly PARENT_ABOUT = 'pages/parent/ParentAboutPage';

  // Teacher pages
  static readonly TEACHER_HOME = 'pages/teacher/TeacherHomePage';
  static readonly TEACHER_ATTENDANCE = 'pages/teacher/TeacherAttendancePage';
  static readonly TEACHER_HOMEWORK = 'pages/teacher/TeacherHomeworkPage';
  static readonly TEACHER_SCHEDULE = 'pages/teacher/TeacherSchedulePage';
  static readonly TEACHER_SCAN = 'pages/teacher/TeacherScanPage';
  static readonly TEACHER_MESSAGES = 'pages/teacher/TeacherMessagesPage';
  static readonly TEACHER_PROFILE = 'pages/teacher/TeacherProfilePage';
  static readonly TEACHER_STUDENT_DETAIL = 'pages/teacher/TeacherStudentDetailPage';

  // Common pages
  static readonly COMMON_QRCODE_SCAN = 'pages/common/QRCodeScanPage';

  // Admin pages
  static readonly ADMIN_HOME = 'pages/admin/AdminHomePage';
  static readonly ADMIN_STUDENTS = 'pages/admin/AdminStudentsPage';
  static readonly ADMIN_ORDERS = 'pages/admin/AdminOrdersPage';
  static readonly ADMIN_REPORTS = 'pages/admin/AdminReportsPage';
  static readonly ADMIN_MESSAGES = 'pages/admin/AdminMessagesPage';
  static readonly ADMIN_SERVICES = 'pages/admin/AdminServicesPage';
  static readonly ADMIN_SESSIONS = 'pages/admin/AdminSessionsPage';
  static readonly ADMIN_ALERTS = 'pages/admin/AdminAlertsPage';
  static readonly ADMIN_REFUNDS = 'pages/admin/AdminRefundsPage';
  static readonly ADMIN_STUDENT_EDIT = 'pages/admin/AdminStudentEditPage';
  static readonly ADMIN_STUDENT_DETAIL = 'pages/admin/AdminStudentDetailPage';
  static readonly ADMIN_PROFILE = 'pages/admin/AdminProfilePage';
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
    'ADMIN': RouteUrls.ADMIN_HOME,
    'ORG_ADMIN': RouteUrls.ADMIN_HOME,
    'SCHOOL_ADMIN': RouteUrls.ADMIN_HOME,
    'PLATFORM_ADMIN': RouteUrls.ADMIN_HOME
  };

  static getDefaultRoute(role: string): string {
    return this.DEFAULT_ROUTE[role] ?? RouteUrls.LOGIN;
  }
}
