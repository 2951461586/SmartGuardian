package com.smartguardian.backend.service;

import com.smartguardian.backend.common.JdbcPageHelper;
import com.smartguardian.backend.common.PageResponse;
import com.smartguardian.backend.common.RequestUtils;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class HomeworkService {

  private final NamedParameterJdbcTemplate jdbcTemplate;

  public HomeworkService(NamedParameterJdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public PageResponse<Map<String, Object>> getTasks(Long studentId, String status, String taskDate, int pageNum, int pageSize) {
    MapSqlParameterSource params = new MapSqlParameterSource().addValue("studentId", studentId).addValue("status", status).addValue("taskDate", taskDate);
    String where = " where (:studentId is null or ht.student_id = :studentId) and (:status is null or ht.status = :status) and (:taskDate is null or cast(ht.task_date as varchar) = :taskDate) ";
    String dataSql = "select ht.id, ht.student_id as studentId, ht.task_date as taskDate, ht.subject, ht.title, ht.content, ht.source_type as sourceType, ht.status, s.name as studentName, ht.created_at as createdAt, ht.updated_at as updatedAt from homework_task ht left join student s on s.id = ht.student_id " + where + " order by ht.id desc limit :limit offset :offset";
    String countSql = "select count(*) from homework_task ht " + where;
    return JdbcPageHelper.page(jdbcTemplate, dataSql, countSql, params, pageNum, pageSize);
  }

  public Map<String, Object> getTaskDetail(Long taskId) {
    List<Map<String, Object>> rows = jdbcTemplate.queryForList("select ht.id, ht.student_id as studentId, ht.task_date as taskDate, ht.subject, ht.title, ht.content, ht.source_type as sourceType, ht.status, s.name as studentName, ht.created_at as createdAt, ht.updated_at as updatedAt from homework_task ht left join student s on s.id = ht.student_id where ht.id = :taskId", new MapSqlParameterSource("taskId", taskId));
    if (rows.isEmpty()) {
      throw new com.smartguardian.backend.common.BizException(404, "作业任务不存在");
    }
    return rows.getFirst();
  }

  public Map<String, Object> createTask(Map<String, Object> request) {
    jdbcTemplate.update("insert into homework_task (student_id, subject, title, content, source_type, task_date, due_time, status, is_deleted, created_by, updated_by, created_at, updated_at) values (:studentId, :subject, :title, :content, :sourceType, :taskDate, CURRENT_TIMESTAMP, 'PENDING', 0, 2, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)",
      new MapSqlParameterSource().addValue("studentId", RequestUtils.requireLong(request, "studentId")).addValue("subject", RequestUtils.requireString(request, "subject")).addValue("title", RequestUtils.requireString(request, "title")).addValue("content", RequestUtils.optionalString(request, "content")).addValue("sourceType", RequestUtils.optionalString(request, "sourceType") == null ? "TEACHER" : RequestUtils.optionalString(request, "sourceType")).addValue("taskDate", RequestUtils.requireString(request, "taskDate")));
    Long id = jdbcTemplate.queryForObject("select max(id) from homework_task", new MapSqlParameterSource(), Long.class);
    return getTaskDetail(id);
  }

  public Map<String, Object> updateTaskStatus(Long taskId, Map<String, Object> request) {
    jdbcTemplate.update("update homework_task set status = :status, updated_at = CURRENT_TIMESTAMP where id = :taskId", new MapSqlParameterSource().addValue("status", RequestUtils.requireString(request, "status")).addValue("taskId", taskId));
    return getTaskDetail(taskId);
  }

  public Map<String, Object> submitFeedback(Map<String, Object> request) {
    Long taskId = RequestUtils.requireLong(request, "taskId");
    Long studentId = jdbcTemplate.queryForObject("select student_id from homework_task where id = :taskId", new MapSqlParameterSource("taskId", taskId), Long.class);
    jdbcTemplate.update("insert into homework_feedback (homework_task_id, student_id, teacher_user_id, progress_rate, feedback_text, performance_tags, attachment_urls, parent_confirm_status, is_deleted, created_by, updated_by, created_at, updated_at) values (:taskId, :studentId, 2, 100, :feedbackContent, :performance, null, 'UNCONFIRMED', 0, 2, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)",
      new MapSqlParameterSource().addValue("taskId", taskId).addValue("studentId", studentId).addValue("feedbackContent", RequestUtils.requireString(request, "feedbackContent")).addValue("performance", RequestUtils.optionalString(request, "performance")));
    Long id = jdbcTemplate.queryForObject("select max(id) from homework_feedback", new MapSqlParameterSource(), Long.class);
    return getFeedbackDetail(id);
  }

  public List<Map<String, Object>> getFeedbacks(Long taskId) {
    return jdbcTemplate.queryForList("select hf.id, hf.homework_task_id as taskId, hf.teacher_user_id as teacherId, u.real_name as teacherName, hf.student_id as studentId, hf.feedback_text as feedbackContent, hf.performance_tags as performance, case when hf.parent_confirm_status = 'CONFIRMED' then 'CONFIRMED' else 'IN_PROGRESS' end as status, hf.created_at as createdAt, hf.updated_at as updatedAt from homework_feedback hf left join user u on u.id = hf.teacher_user_id where hf.homework_task_id = :taskId order by hf.id desc", new MapSqlParameterSource("taskId", taskId));
  }

  public Map<String, Object> confirmFeedback(Long feedbackId, Map<String, Object> request) {
    jdbcTemplate.update("update homework_feedback set parent_confirm_status = :confirmStatus, updated_at = CURRENT_TIMESTAMP where id = :feedbackId", new MapSqlParameterSource().addValue("confirmStatus", RequestUtils.requireString(request, "confirmStatus")).addValue("feedbackId", feedbackId));
    return getFeedbackDetail(feedbackId);
  }

  private Map<String, Object> getFeedbackDetail(Long feedbackId) {
    List<Map<String, Object>> rows = jdbcTemplate.queryForList("select hf.id, hf.homework_task_id as taskId, hf.teacher_user_id as teacherId, u.real_name as teacherName, hf.student_id as studentId, hf.feedback_text as feedbackContent, hf.performance_tags as performance, case when hf.parent_confirm_status = 'CONFIRMED' then 'CONFIRMED' else 'IN_PROGRESS' end as status, hf.created_at as createdAt, hf.updated_at as updatedAt from homework_feedback hf left join user u on u.id = hf.teacher_user_id where hf.id = :feedbackId", new MapSqlParameterSource("feedbackId", feedbackId));
    if (rows.isEmpty()) {
      throw new com.smartguardian.backend.common.BizException(404, "作业反馈不存在");
    }
    return rows.getFirst();
  }
}
