package com.smartguardian.backend.service;

import com.smartguardian.backend.common.JdbcPageHelper;
import com.smartguardian.backend.common.PageResponse;
import java.util.Map;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class TimelineService {

  private final NamedParameterJdbcTemplate jdbcTemplate;

  public TimelineService(NamedParameterJdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public PageResponse<Map<String, Object>> getStudentTimeline(Long studentId, String bizDate, int pageNum, int pageSize) {
    MapSqlParameterSource params = new MapSqlParameterSource().addValue("studentId", studentId).addValue("bizDate", bizDate);
    String where = " where st.student_id = :studentId and (:bizDate is null or cast(st.biz_date as varchar) = :bizDate) and st.is_deleted = 0 ";
    String dataSql = "select st.id, st.student_id as studentId, st.event_type as timelineType, st.related_biz_id as bizId, st.event_title as title, st.event_detail as content, st.biz_date as bizDate, st.created_at as timestamp, st.created_by as operatorUserId, u.real_name as operatorName from student_timeline st left join user u on u.id = st.created_by " + where + " order by st.id desc limit :limit offset :offset";
    String countSql = "select count(*) from student_timeline st " + where;
    return JdbcPageHelper.page(jdbcTemplate, dataSql, countSql, params, pageNum, pageSize);
  }
}
