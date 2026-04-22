# 2026-04-22 Integration Supplement

## Scope

This note records the next round of front/back integration work on top of the enterprise UI refresh.

## Completed

- `OrderService.getOrders()` now matches the backend `PageResponse` contract.
- `AdminHomePage`, `AdminOrdersPage`, and `ParentOrdersPage` now read order data from `data.list`.
- `ParentChildrenPage` now persists the loaded student list and the current student in `StudentStore`.
- `ParentTimelinePage` now prefers real students from `StudentStore` and real timeline data from the backend instead of only mock content.
- `ParentHomePage` now clears stale summary data on load failure.
- `ParentMessagesPage` now reads paged message data from the backend and clears to an empty state on failure.
- `ParentAlertsPage` now reads paged alert data from the backend and clears to an empty state on failure.
- `ParentServicesPage` now clears to an empty state on failure instead of showing mock products.
- `AdminStudentsPage` now uses backend student data plus local grade filtering and pagination.
- `TeacherSchedulePage` now reads backend session data instead of simulated mock items.
- `TeacherMessagesPage` now clears stale data when message loading fails.

## Backend Contract Summary

- Orders: `/api/v1/orders` returns `PageResponse<Map<String, Object>>`.
- Students: `/api/v1/students` returns `PageResponse<Map<String, Object>>`.
- Timeline: `/api/v1/timeline/students/{studentId}` returns `PageResponse<Map<String, Object>>`.
- Messages: `/api/v1/messages` returns `PageResponse<Map<String, Object>>`.
- Alerts: `/api/v1/alerts` returns `PageResponse<Map<String, Object>>`.
- Service products: `/api/v1/service-products` returns `List<Map<String, Object>>`.
- Teacher sessions: `/api/v1/sessions` returns `List<Map<String, Object>>`.

## Current Notes

- The parent timeline is now backend-driven and no longer depends on the old demo branch.
- Message, alert, and service pages still preserve empty-state handling for resilience, but they no longer surface mock records on API failure.
- The admin student page now filters the cached/backend result set locally so the grade tabs stay meaningful even though the backend only exposes keyword and classId filters.
- The teacher schedule page now maps real session list data into the existing timetable cards.
- The parent children page currently uses the generic student list endpoint because the backend has not yet exposed a guardian-scoped child list.
- If we add guardian-scoped student lookup later, `ParentChildrenPage` and `ParentTimelinePage` can be narrowed without changing the display logic.

## Suggested Verification

1. Sign in as each role and confirm the dashboard loads without mock-only dependencies.
2. Open the parent children page, select a student, then open the parent timeline page.
3. Open the admin orders page and confirm it renders the paged backend order list.
