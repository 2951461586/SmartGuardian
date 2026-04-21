package com.smartguardian.backend.service;

import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class DirectoryService {

  private final NamedParameterJdbcTemplate jdbcTemplate;

  public DirectoryService(NamedParameterJdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public List<Map<String, Object>> getServiceProducts(String serviceType, String status) {
    return jdbcTemplate.queryForList(
      "select id, service_name as serviceName, service_type as serviceType, price, capacity, status, grade_scope as gradeRange, org_id as orgId, start_time as startTime, end_time as endTime, created_at as createdAt, updated_at as updatedAt from service_product where is_deleted = 0 and (:serviceType is null or service_type = :serviceType) and (:status is null or status = :status) order by sort_no asc, id desc",
      new MapSqlParameterSource().addValue("serviceType", serviceType).addValue("status", status)
    );
  }

  public List<Map<String, Object>> getSessions(String sessionDate, Long teacherUserId) {
    return jdbcTemplate.queryForList(
      "select ss.id, ss.session_date as sessionDate, ss.start_time as startTime, ss.end_time as endTime, ss.teacher_user_id as teacherUserId, ss.capacity, ss.current_count as currentCount, ss.service_product_id as serviceProductId, ss.status, sp.service_name as serviceName, u.real_name as teacherName from session_schedule ss left join service_product sp on sp.id = ss.service_product_id left join user u on u.id = ss.teacher_user_id where ss.is_deleted = 0 and (:sessionDate is null or ss.session_date = :sessionDate) and (:teacherUserId is null or ss.teacher_user_id = :teacherUserId) order by ss.session_date asc, ss.start_time asc",
      new MapSqlParameterSource().addValue("sessionDate", sessionDate).addValue("teacherUserId", teacherUserId)
    );
  }
}
