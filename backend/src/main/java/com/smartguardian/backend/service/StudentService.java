package com.smartguardian.backend.service;

import com.smartguardian.backend.common.BizException;
import com.smartguardian.backend.common.JdbcPageHelper;
import com.smartguardian.backend.common.PageResponse;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class StudentService {

  private final NamedParameterJdbcTemplate jdbcTemplate;

  public StudentService(NamedParameterJdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public PageResponse<Map<String, Object>> getStudents(String keyword, Long classId, int pageNum, int pageSize) {
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("keyword", keyword == null ? null : "%" + keyword.trim() + "%");
    params.addValue("classId", classId);
    String where = " where s.is_deleted = 0 and (:keyword is null or s.name like :keyword or s.student_no like :keyword) and (:classId is null or s.class_id = :classId) ";
    String dataSql = "select s.id, s.student_no as studentNo, s.name, s.school_id as schoolId, s.class_id as classId, s.grade, s.gender, s.birthday as birthDate, " +
      "s.guardian_user_id as guardianUserId, s.health_notes as healthNotes, s.status, s.created_at as createdAt, s.updated_at as updatedAt, " +
      "u.real_name as guardianName, u.mobile as guardianMobile " +
      "from student s left join user u on u.id = s.guardian_user_id " + where +
      " order by s.id desc limit :limit offset :offset";
    String countSql = "select count(*) from student s " + where;
    return JdbcPageHelper.page(jdbcTemplate, dataSql, countSql, params, pageNum, pageSize);
  }

  public Map<String, Object> getStudentDetail(Long studentId) {
    List<Map<String, Object>> rows = jdbcTemplate.queryForList(
      "select s.id, s.student_no as studentNo, s.name, s.school_id as schoolId, s.class_id as classId, s.grade, s.gender, s.birthday as birthDate, " +
        "s.guardian_user_id as guardianUserId, s.health_notes as healthNotes, s.status, s.created_at as createdAt, s.updated_at as updatedAt, " +
        "u.real_name as guardianName, u.mobile as guardianMobile from student s left join user u on u.id = s.guardian_user_id where s.id = :studentId and s.is_deleted = 0",
      new MapSqlParameterSource("studentId", studentId)
    );
    if (rows.isEmpty()) {
      throw new BizException(404, "学生不存在");
    }
    return new LinkedHashMap<>(rows.getFirst());
  }
}
