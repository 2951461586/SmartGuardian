package com.smartguardian.backend.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class ReportService {

  private final NamedParameterJdbcTemplate jdbcTemplate;

  public ReportService(NamedParameterJdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public Map<String, Object> getAttendanceReport() {
    MapSqlParameterSource emptyParams = new MapSqlParameterSource();
    Long total = jdbcTemplate.queryForObject("select count(*) from attendance_record", emptyParams, Long.class);
    Long signedIn = jdbcTemplate.queryForObject("select count(*) from attendance_record where status = 'SIGNED_IN'", emptyParams, Long.class);
    Long signedOut = jdbcTemplate.queryForObject("select count(*) from attendance_record where status = 'SIGNED_OUT'", emptyParams, Long.class);
    Long absent = jdbcTemplate.queryForObject("select count(*) from attendance_record where status = 'ABSENT'", emptyParams, Long.class);
    Long leave = jdbcTemplate.queryForObject("select count(*) from student_timeline where event_type = 'LEAVE'", emptyParams, Long.class);
    return Map.of("totalStudents", total == null ? 0 : total, "presentCount", signedIn == null ? 0 : signedIn, "absentCount", absent == null ? 0 : absent, "lateCount", 0, "leaveCount", leave == null ? 0 : leave, "attendanceRate", total == null || total == 0 ? 0 : ((double) ((signedIn == null ? 0 : signedIn) + (signedOut == null ? 0 : signedOut)) / total), "dailyStats", List.of());
  }

  public Map<String, Object> getFinanceReport() {
    MapSqlParameterSource emptyParams = new MapSqlParameterSource();
    BigDecimal totalIncome = jdbcTemplate.queryForObject("select coalesce(sum(pay_amount),0) from payment_record where pay_status in ('SUCCESS','REFUNDED')", emptyParams, BigDecimal.class);
    BigDecimal totalRefund = jdbcTemplate.queryForObject("select coalesce(sum(refund_amount),0) from refund_record", emptyParams, BigDecimal.class);
    Long orderCount = jdbcTemplate.queryForObject("select count(*) from order_info", emptyParams, Long.class);
    Long refundedOrderCount = jdbcTemplate.queryForObject("select count(*) from refund_record", emptyParams, Long.class);
    return Map.of("totalIncome", totalIncome == null ? BigDecimal.ZERO : totalIncome, "totalRefund", totalRefund == null ? BigDecimal.ZERO : totalRefund, "netIncome", (totalIncome == null ? BigDecimal.ZERO : totalIncome).subtract(totalRefund == null ? BigDecimal.ZERO : totalRefund), "orderCount", orderCount == null ? 0 : orderCount, "refundedOrderCount", refundedOrderCount == null ? 0 : refundedOrderCount, "dailyStats", List.of());
  }

  public List<Map<String, Object>> getTeacherPerformance() {
    return jdbcTemplate.queryForList("select u.id as teacherId, u.real_name as teacherName, count(ss.id) as totalSessions, coalesce(sum(ss.current_count),0) as totalStudents, 1.0 as avgAttendanceRate, 1 as homeworkCompletedCount, 4.8 as avgRating from user u left join session_schedule ss on ss.teacher_user_id = u.id where u.role_type = 'TEACHER' group by u.id, u.real_name order by u.id", new MapSqlParameterSource());
  }

  public List<Map<String, Object>> getDailyAttendanceStats() {
    return jdbcTemplate.queryForList("select attendance_date as date, count(*) as totalStudents, sum(case when status in ('SIGNED_IN','SIGNED_OUT') then 1 else 0 end) as presentStudents, sum(case when status = 'ABSENT' then 1 else 0 end) as absentStudents, 0 as lateStudents, 0 as leaveStudents, 1.0 as attendanceRate from attendance_record group by attendance_date order by attendance_date desc", new MapSqlParameterSource());
  }

  public List<Map<String, Object>> getStudentAttendanceSummary() {
    return jdbcTemplate.queryForList("select s.id as studentId, s.name as studentName, s.student_no as studentNo, count(a.id) as totalDays, sum(case when a.status in ('SIGNED_IN','SIGNED_OUT') then 1 else 0 end) as presentDays, sum(case when a.status = 'ABSENT' then 1 else 0 end) as absentDays, 0 as lateDays, 0 as leaveDays, 1.0 as attendanceRate from student s left join attendance_record a on a.student_id = s.id group by s.id, s.name, s.student_no order by s.id", new MapSqlParameterSource());
  }

  public List<Map<String, Object>> getDailyRevenueStats() {
    return jdbcTemplate.queryForList("select cast(created_at as date) as date, count(*) as orderCount, coalesce(sum(pay_amount),0) as totalAmount, coalesce(sum(case when pay_status = 'SUCCESS' then pay_amount else 0 end),0) as paidAmount, 0 as refundedAmount from payment_record group by cast(created_at as date) order by cast(created_at as date) desc", new MapSqlParameterSource());
  }

  public List<Map<String, Object>> getServiceProductRevenue() {
    return jdbcTemplate.queryForList("select sp.id as serviceProductId, sp.service_name as serviceName, count(o.id) as orderCount, coalesce(sum(o.amount),0) as totalAmount, 100 as percentage from service_product sp left join order_info o on o.service_product_id = sp.id group by sp.id, sp.service_name order by sp.id", new MapSqlParameterSource());
  }
}
