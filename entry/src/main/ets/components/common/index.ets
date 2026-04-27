/**
 * SmartGuardian - Common Components Index
 * Central export point for all common components
 */

// Page Header
export {
  PageHeader,
  SimplePageHeader,
  GreetingHeader,
  HeaderTheme
} from './PageHeader';

// Empty State
export {
  EmptyState,
  SimpleEmptyState,
  EmptyType
} from './EmptyState';

// Loading State
export {
  LoadingState,
  LoadingSpinner,
  SkeletonLoading,
  CardSkeleton,
  LoadingSize
} from './LoadingState';

// Error State
export {
  ErrorState,
  InlineError,
  ErrorBanner,
  ErrorStateType
} from './ErrorState';

// Tab Bar
export {
  TabBar,
  SimpleTabBar,
  SegmentTabBar,
  UnderlineTabBar,
  TabBarStyle,
  TabItem
} from './TabBar';

export {
  StatusBadge,
  SimpleStatusBadge,
  AttendanceBadge,
  OrderBadge,
  HomeworkBadge,
  SessionBadge,
  BadgeSize
} from '../StatusBadge';

// Card
export {
  Card,
  SimpleCard,
  StatCard,
  InfoCard,
  ActionCard,
  CardVariant,
  CardSize,
  InfoItem
} from './Card';

// Section Header
export { SectionHeader } from './SectionHeader';

// Action Button
export { ActionButton } from './ActionButton';
export { IconActionButton } from './IconActionButton';

// Order List Item
export { OrderListItem, OrderItemMode } from './OrderListItem';

// Message List Item
export { MessageListItem } from './MessageListItem';

// Attendance Card
export { AttendanceCard, AttendanceStatus } from './AttendanceCard';

// Homework Card
export { HomeworkCard, HomeworkCardMode } from './HomeworkCard';

// Workbench
export { WorkbenchActionGrid } from './WorkbenchActionGrid';
export { StatCardRow, StatRowItem } from './StatCardRow';
export { SelectionSheet } from './SelectionSheet';
export { DatePickerSheet } from './DatePickerSheet';
export { ParentStudentHeroCard } from './ParentStudentHeroCard';
export { TeacherSessionHeroCard } from './TeacherSessionHeroCard';
export { AdminSummaryHeroCard } from './AdminSummaryHeroCard';
export { ExecutiveSummaryCard } from './ExecutiveSummaryCard';
export { ServiceProductCard } from './ServiceProductCard';
export { ParentNoticeCard } from './ParentNoticeCard';
export { ParentScheduleCard, ParentScheduleNode } from './ParentScheduleCard';
export { ParentHomeworkPreviewCard } from './ParentHomeworkPreviewCard';
export { ParentHomeWorkspaceSection } from './ParentHomeSections';
export {
  AdminHomeWorkbenchSection,
  AdminHomeOperationsSection
} from './AdminHomeSections';
export {
  TeacherHomeWorkbenchSection,
  TeacherHomeSessionSection
} from './TeacherHomeSections';
export { ReportControlDeck } from './ReportControlDeck';
export { ReportTrendCard, ReportMetricChip, ReportTrendRow } from './ReportTrendCard';
export { TeacherPerformanceCard } from './TeacherPerformanceCard';
export {
  AdminReportsOverviewSection,
  AdminAttendanceReportList,
  AdminFinanceReportList,
  AdminTeacherPerformanceList
} from './AdminReportSections';
export {
  TeacherSessionStatsCard,
  TeacherSessionsPreviewCard,
  TeacherSessionSummaryData,
  TeacherSessionListItemData
} from './TeacherSessionCards';
export {
  AdminOperationsOverviewCard,
  ActivityFeedCard,
  ActivityFeedItem
} from './AdminDashboardCards';
export {
  AdminOverviewMetricSection,
  AdminStatusFilterCard,
  AdminAlertListSection,
  AdminRefundListSection,
  AdminOverviewMetric
} from './AdminOperationSections';
export {
  AdminStudentsExecutiveCard,
  AdminStudentsOverviewRow,
  AdminStudentsControlCard,
  AdminStudentsSummaryCard,
  AdminStudentListItemCard,
  AdminStudentsPaginationCard,
  StudentWithGuardian
} from './AdminStudentSections';
export {
  AdminOrdersOverviewCard,
  AdminOrdersControlCard,
  AdminOrdersSummaryCard,
  AdminOrderAuditSheet
} from './AdminOrderSections';
export {
  AdminSessionsOverviewCard,
  AdminSessionsFilterCard,
  AdminSessionListItemCard,
  AdminSessionStudentsSheet
} from './AdminSessionSections';
export {
  TimelineStudentSelectorCard,
  TimelineEventListCard,
  TimelineEventViewModel
} from './TimelineComponents';
export {
  OrderCreateServiceSummaryCard,
  OrderCreateStudentSection,
  OrderCreateDateSection,
  OrderAmountSummarySection,
  OrderCreateNotesCard,
  OrderCreateBottomBar,
  OrderCreateStudentPickerSheet
} from './ParentOrderCreateSections';
export {
  LeaveStudentSelectorCard,
  LeaveDateSummaryCard,
  LeaveTypeSelectorCard,
  RefundAmountSummaryCard,
  LeaveStudentOption,
  LeaveTypeValue
} from './ParentRequestSections';
export {
  RefundReasonSection,
  RefundHistorySection
} from './ParentRefundSections';
export {
  ParentAlertResponseCard,
  ParentAlertListItemCard,
  ParentAlertDetailSheetCard
} from './ParentAlertSections';
export {
  StudentAttendanceMetricsCard,
  StudentGuardianItemCard,
  StudentAttendanceStatusChip,
  StudentAttendanceMetricViewModel,
  StudentGuardianViewModel
} from './StudentProfileSections';
export {
  ProfileHeroCard,
  ProfileUtilityButton,
  ProfileHighlightBanner,
  ProfileMetricStrip,
  ProfileActionGrid,
  ProfileSettingsList,
  ProfileActionItem,
  ProfileMetricItem
} from './ProfileCenterSections';
export {
  PortalSelectorCard,
  PortalOption
} from './AuthPortalSections';
export {
  PageScaffold,
  ResponsiveSplitPanel
} from './PageScaffold';
export {
  ViewState,
  StatefulContainer
} from './StatefulContainer';
export {
  FormSurface,
  FormTextField,
  FormSecureField,
  FormNoticeStrip,
  FormSegmentSelector,
  FormActionBar
} from './FormFields';
export {
  FormPageTemplate,
  DashboardPageTemplate,
  WorkbenchListPageTemplate,
  ProfileWorkspaceTemplate
} from './SceneTemplates';
