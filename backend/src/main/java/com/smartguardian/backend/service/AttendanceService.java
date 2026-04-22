package com.smartguardian.backend.service;

import com.smartguardian.backend.common.BizException;
import com.smartguardian.backend.common.JdbcPageHelper;
import com.smartguardian.backend.common.PageResponse;
import com.smartguardian.backend.common.RequestUtils;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class AttendanceService {

  private final NamedParameterJdbcTemplate jdbcTemplate;

  public AttendanceService(NamedParameterJdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public PageResponse<Map<String, Object>> getAttendance(Long studentId, Long sessionId, String attendanceDate, int pageNum, int pageSize) {
    MapSqlParameterSource params = new MapSqlParameterSource()
      .addValue("studentId", studentId)
      .addValue("sessionId", sessionId)
      .addValue("attendanceDate", attendanceDate);
    String where = " where a.is_deleted = 0 and (:studentId is null or a.student_id = :studentId) and (:sessionId is null or a.session_id = :sessionId) and (:attendanceDate is null or cast(a.attendance_date as varchar) = :attendanceDate) ";
    String dataSql = "select a.id, a.student_id as studentId, a.session_id as sessionId, a.sign_in_time as signInTime, a.sign_out_time as signOutTime, a.sign_in_type as signInMethod, a.sign_out_type as signOutMethod, a.sign_in_location as signInLocation, a.status, a.abnormal_flag as abnormalFlag, a.abnormal_type as abnormalType, a.attendance_date as attendanceDate, s.name as studentName, s.student_no as studentNo, a.order_id as orderId from attendance_record a left join student s on s.id = a.student_id " + where + " order by a.id desc limit :limit offset :offset";
    String countSql = "select count(*) from attendance_record a " + where;
    return JdbcPageHelper.page(jdbcTemplate, dataSql, countSql, params, pageNum, pageSize);
  }

  public Map<String, Object> signIn(Map<String, Object> request) {
    Long studentId = RequestUtils.requireLong(request, "studentId");
    Long sessionId = RequestUtils.requireLong(request, "sessionId");
    Long orderId = jdbcTemplate.queryForObject("select id from order_info where student_id = :studentId order by id desc limit 1", new MapSqlParameterSource("studentId", studentId), Long.class);
    if (orderId == null) {
      throw new BizException(400, "未找到有效订单");
    }
    Integer existing = jdbcTemplate.queryForObject("select count(*) from attendance_record where student_id = :studentId and session_id = :sessionId and attendance_date = CURRENT_DATE", new MapSqlParameterSource().addValue("studentId", studentId).addValue("sessionId", sessionId), Integer.class);
    if (existing != null && existing > 0) {
      jdbcTemplate.update("update attendance_record set sign_in_time = CURRENT_TIMESTAMP, sign_in_type = :signInType, sign_in_location = :location, status = 'SIGNED_IN', updated_at = CURRENT_TIMESTAMP where student_id = :studentId and session_id = :sessionId and attendance_date = CURRENT_DATE",
        new MapSqlParameterSource().addValue("studentId", studentId).addValue("sessionId", sessionId).addValue("signInType", RequestUtils.optionalString(request, "signInType")).addValue("location", RequestUtils.optionalString(request, "location")));
    } else {
      jdbcTemplate.update("insert into attendance_record (student_id, order_id, attendance_date, session_id, sign_in_time, sign_in_type, sign_in_location, sign_out_time, sign_out_type, sign_out_guardian_id, status, abnormal_flag, abnormal_type, operator_user_id, is_deleted, created_by, updated_by, created_at, updated_at) values (:studentId, :orderId, CURRENT_DATE, :sessionId, CURRENT_TIMESTAMP, :signInType, :location, null, null, null, 'SIGNED_IN', 0, null, 2, 0, 2, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)",
        new MapSqlParameterSource().addValue("studentId", studentId).addValue("orderId", orderId).addValue("sessionId", sessionId).addValue("signInType", RequestUtils.optionalString(request, "signInType")).addValue("location", RequestUtils.optionalString(request, "location")));
    }
    return getLatestAttendance(studentId, sessionId);
  }

  public void signOut(Map<String, Object> request) {
    Long studentId = RequestUtils.requireLong(request, "studentId");
    Long sessionId = RequestUtils.requireLong(request, "sessionId");
    jdbcTemplate.update("update attendance_record set sign_out_time = CURRENT_TIMESTAMP, sign_out_type = :signOutType, sign_out_guardian_id = :guardianId, status = 'SIGNED_OUT', updated_at = CURRENT_TIMESTAMP where student_id = :studentId and session_id = :sessionId and attendance_date = CURRENT_DATE",
      new MapSqlParameterSource().addValue("signOutType", RequestUtils.optionalString(request, "signOutType")).addValue("guardianId", RequestUtils.optionalLong(request, "guardianId")).addValue("studentId", studentId).addValue("sessionId", sessionId));
  }

  public PageResponse<Map<String, Object>> getAbnormalEvents(String status, int pageNum, int pageSize) {
    MapSqlParameterSource params = new MapSqlParameterSource().addValue("status", status);
    String where = " where abnormal_flag = 1 and (:status is null or status = :status) ";
    String dataSql = "select id, student_id as studentId, session_id as sessionId, abnormal_type as abnormalType, status, attendance_date as eventDate from attendance_record " + where + " order by id desc limit :limit offset :offset";
    String countSql = "select count(*) from attendance_record " + where;
    return JdbcPageHelper.page(jdbcTemplate, dataSql, countSql, params, pageNum, pageSize);
  }

  public void submitLeave(Map<String, Object> request) {
    Long studentId = RequestUtils.requireLong(request, "studentId");
    String leaveDate = RequestUtils.requireString(request, "leaveDate");
    jdbcTemplate.update("insert into student_timeline (student_id, biz_date, event_type, event_title, event_detail, related_biz_id, visibility_scope, is_deleted, created_at, updated_at) values (:studentId, :leaveDate, 'LEAVE', '请假申请', :reason, null, 'PARENT', 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)",
      new MapSqlParameterSource().addValue("studentId", studentId).addValue("leaveDate", leaveDate).addValue("reason", RequestUtils.requireString(request, "reason")));
  }

  private Map<String, Object> getLatestAttendance(Long studentId, Long sessionId) {
    List<Map<String, Object>> rows = jdbcTemplate.queryForList("select id, student_id as studentId, session_id as sessionId, sign_in_time as signInTime, sign_out_time as signOutTime, sign_in_type as signInMethod, sign_out_type as signOutMethod, sign_in_location as signInLocation, status, abnormal_flag as abnormalFlag, abnormal_type as abnormalType, attendance_date as attendanceDate from attendance_record where student_id = :studentId and session_id = :sessionId and attendance_date = CURRENT_DATE", new MapSqlParameterSource().addValue("studentId", studentId).addValue("sessionId", sessionId));
    if (rows.isEmpty()) {
      throw new BizException(404, "考勤记录不存在");
    }
    return new LinkedHashMap<>(rows.get(0));
  }
}
