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
public class MessageService {

  private final NamedParameterJdbcTemplate jdbcTemplate;

  public MessageService(NamedParameterJdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public PageResponse<Map<String, Object>> getMessages(Long userId, String msgType, Boolean readStatus, int pageNum, int pageSize) {
    MapSqlParameterSource params = new MapSqlParameterSource()
      .addValue("userId", userId)
      .addValue("msgType", msgType)
      .addValue("readStatus", readStatus == null ? null : (readStatus ? "READ" : "UNREAD"));
    String where = " where receiver_user_id = :userId and is_deleted = 0 and (:msgType is null or msg_type = :msgType) and (:readStatus is null or read_status = :readStatus) ";
    String dataSql = "select id, receiver_user_id as userId, msg_type as msgType, biz_type as bizType, content, case when read_status = 'READ' then true else false end as readStatus, created_at as createdAt, updated_at as updatedAt from message_record " + where + " order by id desc limit :limit offset :offset";
    String countSql = "select count(*) from message_record " + where;
    return JdbcPageHelper.page(jdbcTemplate, dataSql, countSql, params, pageNum, pageSize);
  }

  public Map<String, Object> getMessageDetail(Long messageId) {
    List<Map<String, Object>> rows = jdbcTemplate.queryForList("select id, receiver_user_id as userId, msg_type as msgType, biz_type as bizType, content, case when read_status = 'READ' then true else false end as readStatus, created_at as createdAt, updated_at as updatedAt from message_record where id = :messageId", new MapSqlParameterSource("messageId", messageId));
    if (rows.isEmpty()) {
      throw new com.smartguardian.backend.common.BizException(404, "消息不存在");
    }
    return new LinkedHashMap<>(rows.getFirst());
  }

  public void markAsRead(Long messageId) {
    getMessageDetail(messageId);
    jdbcTemplate.update("update message_record set read_status = 'READ', updated_at = CURRENT_TIMESTAMP where id = :messageId", new MapSqlParameterSource("messageId", messageId));
  }

  public void batchMarkAsRead(List<Long> messageIds) {
    jdbcTemplate.update("update message_record set read_status = 'READ', updated_at = CURRENT_TIMESTAMP where id in (:messageIds)", new MapSqlParameterSource("messageIds", messageIds));
  }

  public void markAllAsRead(Long userId) {
    jdbcTemplate.update("update message_record set read_status = 'READ', updated_at = CURRENT_TIMESTAMP where receiver_user_id = :userId", new MapSqlParameterSource("userId", userId));
  }

  public void deleteMessage(Long messageId) {
    jdbcTemplate.update("update message_record set is_deleted = 1, updated_at = CURRENT_TIMESTAMP where id = :messageId", new MapSqlParameterSource("messageId", messageId));
  }

  public Map<String, Object> getUnreadCount(Long userId) {
    Long count = jdbcTemplate.queryForObject("select count(*) from message_record where receiver_user_id = :userId and read_status = 'UNREAD' and is_deleted = 0", new MapSqlParameterSource("userId", userId), Long.class);
    return Map.of("count", count == null ? 0 : count);
  }

  public Map<String, Object> getStatistics(Long userId) {
    Long total = jdbcTemplate.queryForObject("select count(*) from message_record where receiver_user_id = :userId and is_deleted = 0", new MapSqlParameterSource("userId", userId), Long.class);
    Long unread = jdbcTemplate.queryForObject("select count(*) from message_record where receiver_user_id = :userId and read_status = 'UNREAD' and is_deleted = 0", new MapSqlParameterSource("userId", userId), Long.class);
    List<Map<String, Object>> byTypeRows = jdbcTemplate.queryForList("select msg_type, count(*) as total from message_record where receiver_user_id = :userId and is_deleted = 0 group by msg_type", new MapSqlParameterSource("userId", userId));
    Map<String, Object> byType = new LinkedHashMap<>();
    for (Map<String, Object> row : byTypeRows) {
      byType.put(String.valueOf(row.get("MSG_TYPE")), row.get("TOTAL"));
    }
    return Map.of("total", total == null ? 0 : total, "unread", unread == null ? 0 : unread, "byType", byType);
  }

  public Map<String, Object> sendMessage(Map<String, Object> request, Long senderUserId) {
    Long userId = RequestUtils.requireLong(request, "userId");
    String msgType = RequestUtils.requireString(request, "msgType");
    String content = RequestUtils.requireString(request, "content");
    jdbcTemplate.update("insert into message_record (sender_user_id, receiver_user_id, conversation_id, msg_type, content, biz_type, read_status, sent_at, is_deleted, created_by, updated_by, created_at, updated_at) values (:senderUserId, :userId, null, :msgType, :content, :bizType, 'UNREAD', CURRENT_TIMESTAMP, 0, :senderUserId, :senderUserId, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)",
      new MapSqlParameterSource().addValue("senderUserId", senderUserId).addValue("userId", userId).addValue("msgType", msgType).addValue("content", content).addValue("bizType", RequestUtils.optionalString(request, "bizType")));
    Long id = jdbcTemplate.queryForObject("select max(id) from message_record", new MapSqlParameterSource(), Long.class);
    return getMessageDetail(id);
  }
}
