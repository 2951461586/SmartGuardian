package com.smartguardian.backend.common;

import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

public final class JdbcPageHelper {

  private JdbcPageHelper() {
  }

  public static PageResponse<Map<String, Object>> page(
    NamedParameterJdbcTemplate jdbcTemplate,
    String dataSql,
    String countSql,
    MapSqlParameterSource params,
    int pageNum,
    int pageSize
  ) {
    int safePageNum = Math.max(pageNum, 1);
    int safePageSize = Math.max(pageSize, 1);
    params.addValue("offset", (safePageNum - 1) * safePageSize);
    params.addValue("limit", safePageSize);
    Long total = jdbcTemplate.queryForObject(countSql, params, Long.class);
    List<Map<String, Object>> list = jdbcTemplate.queryForList(dataSql, params);
    return new PageResponse<>(list, total == null ? 0 : total, safePageNum, safePageSize);
  }
}
