package com.smartguardian.backend.service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class OverviewService {

  private final NamedParameterJdbcTemplate jdbcTemplate;

  public OverviewService(NamedParameterJdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public Map<String, Object> getTodayStatus(Long studentId) {
    Long targetStudentId = studentId == null ? 1L : studentId;
    List<Map<String, Object>> rows = jdbcTemplate.queryForList(
      "select s.id as studentId, s.name as studentName, ss.id as sessionId, ss.session_date as sessionDate, ss.start_time as startTime, ss.end_time as endTime, sp.service_name as sessionName, a.status as attendanceStatus, a.sign_in_time as signInTime, a.sign_out_time as signOutTime, ht.status as homeworkStatus, 1 as homeworkCount, hf.progress_rate as homeworkProgress, hf.feedback_text as teacherFeedback from student s left join attendance_record a on a.student_id = s.id and a.attendance_date = CURRENT_DATE left join session_schedule ss on ss.id = a.session_id left join service_product sp on sp.id = ss.service_product_id left join homework_task ht on ht.student_id = s.id and ht.task_date = CURRENT_DATE left join homework_feedback hf on hf.student_id = s.id where s.id = :studentId",
      new MapSqlParameterSource("studentId", targetStudentId)
    );
    Map<String, Object> row = rows.isEmpty() ? Map.of() : rows.getFirst();
    Map<String, Object> sessionInfo = new LinkedHashMap<>();
    sessionInfo.put("sessionId", row.get("SESSIONID"));
    sessionInfo.put("sessionNo", "S" + row.get("SESSIONID"));
    sessionInfo.put("sessionDate", row.get("SESSIONDATE"));
    sessionInfo.put("startTime", row.get("STARTTIME"));
    sessionInfo.put("endTime", row.get("ENDTIME"));
    Map<String, Object> result = new LinkedHashMap<>();
    result.put("date", java.time.LocalDate.now().toString());
    result.put("studentId", row.getOrDefault("STUDENTID", targetStudentId));
    result.put("studentName", row.getOrDefault("STUDENTNAME", "未知学生"));
    result.put("sessionInfo", sessionInfo);
    result.put("attendanceStatus", row.getOrDefault("ATTENDANCESTATUS", "NOT_SIGNED"));
    result.put("signInTime", row.get("SIGNINTIME"));
    result.put("signOutTime", row.get("SIGNOUTTIME"));
    result.put("homeworkStatus", row.getOrDefault("HOMEWORKSTATUS", "PENDING"));
    result.put("homeworkCount", 1);
    result.put("completedHomework", "COMPLETED".equals(row.get("HOMEWORKSTATUS")) ? 1 : 0);
    result.put("messages", 1);
    result.put("sessionName", row.get("SESSIONNAME"));
    result.put("sessionTime", String.valueOf(row.get("STARTTIME")) + "-" + String.valueOf(row.get("ENDTIME")));
    result.put("status", row.getOrDefault("ATTENDANCESTATUS", "NOT_SIGNED"));
    result.put("latestDynamic", row.getOrDefault("TEACHERFEEDBACK", "今日状态正常"));
    result.put("homeworkProgress", row.getOrDefault("HOMEWORKPROGRESS", 0));
    result.put("teacherFeedback", row.get("TEACHERFEEDBACK"));
    return result;
  }

  public Map<String, Object> getAbnormalAlert(Long studentId) {
    Long targetStudentId = studentId == null ? 1L : studentId;
    List<Map<String, Object>> rows = jdbcTemplate.queryForList("select ar.id as alertId, ar.student_id as studentId, s.name as studentName, ar.alert_type as alertType, ar.severity, ar.title as alertTitle, ar.description as alertContent, ar.created_at as alertTime, case when ar.status = 'ACTIVE' then false else true end as isRead from alert_record ar left join student s on s.id = ar.student_id where ar.student_id = :studentId and ar.status = 'ACTIVE' order by ar.id desc", new MapSqlParameterSource("studentId", targetStudentId));
    return rows.isEmpty() ? null : rows.getFirst();
  }
}
