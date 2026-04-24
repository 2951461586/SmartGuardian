package com.smartguardian.backend.service;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

  private final JdbcTemplate jdbcTemplate;
  private final PasswordEncoder passwordEncoder;

  public DataInitializer(JdbcTemplate jdbcTemplate, PasswordEncoder passwordEncoder) {
    this.jdbcTemplate = jdbcTemplate;
    this.passwordEncoder = passwordEncoder;
  }

  @Override
  public void run(String... args) {
    Long userCount = jdbcTemplate.queryForObject("select count(*) from user", Long.class);
    if (userCount != null && userCount > 0) {
      return;
    }

    String encodedPassword = passwordEncoder.encode("123456");
    jdbcTemplate.update("insert into user (id, account_no, username, password_hash, real_name, mobile, role_type, status, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, "P001", "parent_zhang", encodedPassword, "张家长", "13800138001", "PARENT", "ENABLED", 0,
      Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));
    jdbcTemplate.update("insert into user (id, account_no, username, password_hash, real_name, mobile, role_type, status, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      2L, "T001", "teacher_wang", encodedPassword, "王老师", "13800138002", "TEACHER", "ENABLED", 0,
      Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));
    jdbcTemplate.update("insert into user (id, account_no, username, password_hash, real_name, mobile, role_type, status, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      3L, "A001", "admin_li", encodedPassword, "李管理员", "13800138003", "ORG_ADMIN", "ENABLED", 0,
      Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));

    jdbcTemplate.update("insert into student (id, student_no, name, gender, birthday, school_id, class_id, grade, guardian_user_id, health_notes, status, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, "ST2024001", "张小明", "MALE", Date.valueOf("2016-05-12"), 101L, 1L, "一年级", 1L, "花生过敏", "ACTIVE", 0,
      Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));
    jdbcTemplate.update("insert into student (id, student_no, name, gender, birthday, school_id, class_id, grade, guardian_user_id, health_notes, status, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      2L, "ST2024002", "张小雨", "FEMALE", Date.valueOf("2017-03-09"), 101L, 2L, "幼小衔接", 1L, null, "ACTIVE", 0,
      Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));

    jdbcTemplate.update("insert into guardian_relation (id, student_id, user_id, relation_type, is_primary, pickup_auth_level, status, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, 1L, 1L, "FATHER", 1, "FULL", "ACTIVE", 0, Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));
    jdbcTemplate.update("insert into guardian_relation (id, student_id, user_id, relation_type, is_primary, pickup_auth_level, status, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      2L, 2L, 1L, "FATHER", 1, "FULL", "ACTIVE", 0, Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));

    jdbcTemplate.update("insert into service_product (id, service_name, service_type, org_id, school_scope, grade_scope, start_time, end_time, capacity, price, refund_rule, status, sort_no, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, "课后托管基础班", "AFTER_SCHOOL", 1L, "101", "一年级-三年级", "16:30:00", "18:30:00", 30, new BigDecimal("980.00"), "开课前一天可全额退款", "ENABLED", 1, 0,
      Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));
    jdbcTemplate.update("insert into service_product (id, service_name, service_type, org_id, school_scope, grade_scope, start_time, end_time, capacity, price, refund_rule, status, sort_no, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      2L, "晚托提升班", "EVENING", 1L, "101", "一年级-六年级", "18:30:00", "20:00:00", 20, new BigDecimal("1280.00"), "开课前一天可全额退款", "ENABLED", 2, 0,
      Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));

    jdbcTemplate.update("insert into order_info (id, order_no, student_id, guardian_user_id, service_product_id, order_status, amount, paid_amount, pay_status, audit_status, start_date, end_date, remark, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, "ORD20260421001", 1L, 1L, 1L, "APPROVED", new BigDecimal("980.00"), new BigDecimal("980.00"), "PAID", "APPROVED", Date.valueOf("2026-04-01"), Date.valueOf("2026-04-30"), "测试订单", 0,
      Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));
    jdbcTemplate.update("insert into order_info (id, order_no, student_id, guardian_user_id, service_product_id, order_status, amount, paid_amount, pay_status, audit_status, start_date, end_date, remark, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      2L, "ORD20260421002", 2L, 1L, 2L, "PENDING", new BigDecimal("1280.00"), BigDecimal.ZERO, "UNPAID", "PENDING", Date.valueOf("2026-04-01"), Date.valueOf("2026-04-30"), "待审核订单", 0,
      Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));

    jdbcTemplate.update("insert into session_schedule (id, org_id, service_product_id, teacher_user_id, classroom_id, session_date, start_time, end_time, capacity, current_count, status, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, 1L, 1L, 2L, 10101L, Date.valueOf(LocalDate.now()), "16:30:00", "18:30:00", 30, 18, "ONGOING", 0,
      Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));
    jdbcTemplate.update("insert into session_schedule (id, org_id, service_product_id, teacher_user_id, classroom_id, session_date, start_time, end_time, capacity, current_count, status, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      2L, 1L, 2L, 2L, 10102L, Date.valueOf(LocalDate.now()), "18:30:00", "20:00:00", 20, 6, "PLANNED", 0,
      Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));

    jdbcTemplate.update("insert into attendance_record (id, student_id, order_id, attendance_date, session_id, sign_in_time, sign_in_type, sign_in_location, sign_out_time, sign_out_type, sign_out_guardian_id, status, abnormal_flag, abnormal_type, operator_user_id, is_deleted, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, 1L, 1L, Date.valueOf(LocalDate.now()), 1L, Timestamp.valueOf(LocalDateTime.now().minusHours(1)), "NORMAL", "校门口", null, null, null, "SIGNED_IN", 0, null, 2L, 0,
      Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));

    jdbcTemplate.update("insert into message_record (id, sender_user_id, receiver_user_id, conversation_id, msg_type, content, biz_type, read_status, sent_at, is_deleted, created_by, updated_by, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, 2L, 1L, null, "NOTICE", "张小明已完成签到", "ATTENDANCE", "UNREAD", Timestamp.valueOf(LocalDateTime.now()), 0, 2L, 2L, Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));
    jdbcTemplate.update("insert into message_record (id, sender_user_id, receiver_user_id, conversation_id, msg_type, content, biz_type, read_status, sent_at, is_deleted, created_by, updated_by, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      2L, 3L, 1L, null, "SYSTEM", "本周账单已生成，请及时查看", "ORDER", "READ", Timestamp.valueOf(LocalDateTime.now()), 0, 3L, 3L, Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));

    jdbcTemplate.update("insert into homework_task (id, student_id, subject, title, content, source_type, task_date, due_time, status, is_deleted, created_by, updated_by, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, 1L, "数学", "完成口算练习", "完成口算100题", "TEACHER", Date.valueOf(LocalDate.now()), Timestamp.valueOf(LocalDateTime.now().plusHours(3)), "IN_PROGRESS", 0, 2L, 2L, Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));

    jdbcTemplate.update("insert into homework_feedback (id, homework_task_id, student_id, teacher_user_id, progress_rate, feedback_text, performance_tags, attachment_urls, parent_confirm_status, is_deleted, created_by, updated_by, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, 1L, 1L, 2L, 70, "今天状态不错", "认真,积极", null, "UNCONFIRMED", 0, 2L, 2L, Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));

    jdbcTemplate.update("insert into payment_record (id, order_id, payment_no, pay_channel, pay_amount, pay_status, refund_amount, refund_status, transaction_time, callback_time, is_deleted, created_by, updated_by, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, 1L, "PAY20260421001", "ALIPAY", new BigDecimal("980.00"), "SUCCESS", BigDecimal.ZERO, "NONE", Timestamp.valueOf(LocalDateTime.now().minusDays(1)), Timestamp.valueOf(LocalDateTime.now().minusDays(1)), 0, 1L, 1L, Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));

    jdbcTemplate.update("insert into refund_record (id, refund_no, order_id, student_id, service_product_id, refund_amount, reason, reason_type, description, status, applied_at, reviewed_by, reviewed_at, review_remark, processed_at, completed_at, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, "RF20260421001", 2L, 2L, 2L, new BigDecimal("300.00"), "课程调整", "SCHEDULE_CHANGE", "测试退款", "PENDING", Timestamp.valueOf(LocalDateTime.now().minusHours(2)), null, null, null, null, null, Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));

    jdbcTemplate.update("insert into alert_record (id, student_id, alert_type, severity, title, description, suggested_action, status, acknowledged_by, acknowledged_at, resolved_by, resolved_at, resolution, created_at, updated_at) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      1L, 1L, "ATTENDANCE_ANOMALY", "MEDIUM", "签到延迟提醒", "学生签到较平时延后", "请确认到校情况", "ACTIVE", null, null, null, null, null, Timestamp.valueOf(LocalDateTime.now()), Timestamp.valueOf(LocalDateTime.now()));
  }
}
