package com.smartguardian.backend.service;

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
public class AlertService {

  private final NamedParameterJdbcTemplate jdbcTemplate;

  public AlertService(NamedParameterJdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public PageResponse<Map<String, Object>> getAlerts(Long studentId, String status, int pageNum, int pageSize) {
    MapSqlParameterSource params = new MapSqlParameterSource().addValue("studentId", studentId).addValue("status", status);
    String where = " where (:studentId is null or ar.student_id = :studentId) and (:status is null or ar.status = :status) ";
    String dataSql = "select ar.id, ar.student_id as studentId, s.name as studentName, ar.alert_type as alertType, ar.severity, ar.title, ar.description, ar.suggested_action as suggestedAction, ar.status, ar.acknowledged_by as acknowledgedBy, ar.acknowledged_at as acknowledgedAt, ar.resolved_by as resolvedBy, ar.resolved_at as resolvedAt, ar.resolution, ar.created_at as createdAt, ar.updated_at as updatedAt from alert_record ar left join student s on s.id = ar.student_id " + where + " order by ar.id desc limit :limit offset :offset";
    String countSql = "select count(*) from alert_record ar " + where;
    return JdbcPageHelper.page(jdbcTemplate, dataSql, countSql, params, pageNum, pageSize);
  }

  public Map<String, Object> getAlertDetail(Long alertId) {
    List<Map<String, Object>> rows = jdbcTemplate.queryForList("select ar.id, ar.student_id as studentId, s.name as studentName, ar.alert_type as alertType, ar.severity, ar.title, ar.description, ar.suggested_action as suggestedAction, ar.status, ar.acknowledged_by as acknowledgedBy, ar.acknowledged_at as acknowledgedAt, ar.resolved_by as resolvedBy, ar.resolved_at as resolvedAt, ar.resolution, ar.created_at as createdAt, ar.updated_at as updatedAt from alert_record ar left join student s on s.id = ar.student_id where ar.id = :alertId", new MapSqlParameterSource("alertId", alertId));
    if (rows.isEmpty()) {
      throw new com.smartguardian.backend.common.BizException(404, "告警不存在");
    }
    return new LinkedHashMap<>(rows.getFirst());
  }

  public void acknowledge(Long alertId) {
    jdbcTemplate.update("update alert_record set status = 'ACKNOWLEDGED', acknowledged_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP where id = :alertId", new MapSqlParameterSource("alertId", alertId));
  }

  public void resolve(Long alertId, Map<String, Object> request) {
    jdbcTemplate.update("update alert_record set status = 'RESOLVED', resolution = :resolution, resolved_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP where id = :alertId", new MapSqlParameterSource().addValue("resolution", RequestUtils.requireString(request, "resolution")).addValue("alertId", alertId));
  }

  public void dismiss(Long alertId) {
    jdbcTemplate.update("update alert_record set status = 'DISMISSED', updated_at = CURRENT_TIMESTAMP where id = :alertId", new MapSqlParameterSource("alertId", alertId));
  }

  public Map<String, Object> getActiveCount() {
    Long count = jdbcTemplate.queryForObject("select count(*) from alert_record where status = 'ACTIVE'", new MapSqlParameterSource(), Long.class);
    return Map.of("count", count == null ? 0 : count);
  }

  public Map<String, Object> getStatistics() {
    Long total = jdbcTemplate.queryForObject("select count(*) from alert_record", new MapSqlParameterSource(), Long.class);
    Long active = jdbcTemplate.queryForObject("select count(*) from alert_record where status = 'ACTIVE'", new MapSqlParameterSource(), Long.class);
    Long acknowledged = jdbcTemplate.queryForObject("select count(*) from alert_record where status = 'ACKNOWLEDGED'", new MapSqlParameterSource(), Long.class);
    Long resolved = jdbcTemplate.queryForObject("select count(*) from alert_record where status = 'RESOLVED'", new MapSqlParameterSource(), Long.class);
    return Map.of("total", total == null ? 0 : total, "active", active == null ? 0 : active, "acknowledged", acknowledged == null ? 0 : acknowledged, "resolved", resolved == null ? 0 : resolved, "byType", Map.of(), "bySeverity", Map.of());
  }
}
