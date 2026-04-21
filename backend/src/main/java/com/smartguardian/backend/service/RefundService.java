package com.smartguardian.backend.service;

import com.smartguardian.backend.common.JdbcPageHelper;
import com.smartguardian.backend.common.PageResponse;
import com.smartguardian.backend.common.RequestUtils;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class RefundService {

  private final NamedParameterJdbcTemplate jdbcTemplate;

  public RefundService(NamedParameterJdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public Map<String, Object> createRefund(Map<String, Object> request) {
    Long orderId = RequestUtils.requireLong(request, "orderId");
    BigDecimal refundAmount = RequestUtils.optionalDecimal(request, "refundAmount");
    String refundNo = "RF" + UUID.randomUUID().toString().replace("-", "");
    MapSqlParameterSource params = new MapSqlParameterSource()
      .addValue("refundNo", refundNo)
      .addValue("orderId", orderId)
      .addValue("refundAmount", refundAmount == null ? BigDecimal.ZERO : refundAmount)
      .addValue("reason", RequestUtils.requireString(request, "reason"))
      .addValue("reasonType", RequestUtils.requireString(request, "reasonType"))
      .addValue("description", RequestUtils.optionalString(request, "description"));
    int updated = jdbcTemplate.update("insert into refund_record (refund_no, order_id, student_id, service_product_id, refund_amount, reason, reason_type, description, status, applied_at, created_at, updated_at) select :refundNo, o.id, o.student_id, o.service_product_id, :refundAmount, :reason, :reasonType, :description, 'PENDING', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP from order_info o where o.id = :orderId and not exists (select 1 from refund_record r where r.order_id = :orderId and r.status <> 'CANCELLED')", params);
    if (updated == 0) {
      Long orderCount = jdbcTemplate.queryForObject("select count(*) from order_info where id = :orderId", new MapSqlParameterSource("orderId", orderId), Long.class);
      if (orderCount == null || orderCount == 0) {
        throw new com.smartguardian.backend.common.BizException(404, "订单不存在");
      }
      throw new com.smartguardian.backend.common.BizException(400, "该订单已有进行中的退款记录");
    }
    return getRefundDetailByRefundNo(refundNo);
  }

  public PageResponse<Map<String, Object>> getRefunds(Long orderId, Long studentId, String status, int pageNum, int pageSize) {
    MapSqlParameterSource params = new MapSqlParameterSource().addValue("orderId", orderId).addValue("studentId", studentId).addValue("status", status);
    String where = " where (:orderId is null or r.order_id = :orderId) and (:studentId is null or r.student_id = :studentId) and (:status is null or r.status = :status) ";
    String dataSql = "select r.id, r.order_id as orderId, o.order_no as orderNo, r.student_id as studentId, s.name as studentName, r.service_product_id as serviceProductId, sp.service_name as serviceName, r.refund_amount as refundAmount, r.reason, r.reason_type as reasonType, r.description, r.status, r.applied_at as appliedAt, r.reviewed_by as reviewedBy, r.reviewed_at as reviewedAt, r.review_remark as reviewRemark, r.processed_at as processedAt, r.completed_at as completedAt, r.created_at as createdAt, r.updated_at as updatedAt from refund_record r left join order_info o on o.id = r.order_id left join student s on s.id = r.student_id left join service_product sp on sp.id = r.service_product_id " + where + " order by r.id desc limit :limit offset :offset";
    String countSql = "select count(*) from refund_record r " + where;
    return JdbcPageHelper.page(jdbcTemplate, dataSql, countSql, params, pageNum, pageSize);
  }

  public Map<String, Object> getRefundDetail(Long refundId) {
    List<Map<String, Object>> rows = jdbcTemplate.queryForList("select r.id, r.order_id as orderId, o.order_no as orderNo, r.student_id as studentId, s.name as studentName, r.service_product_id as serviceProductId, sp.service_name as serviceName, r.refund_amount as refundAmount, r.reason, r.reason_type as reasonType, r.description, r.status, r.applied_at as appliedAt, r.reviewed_by as reviewedBy, r.reviewed_at as reviewedAt, r.review_remark as reviewRemark, r.processed_at as processedAt, r.completed_at as completedAt, r.created_at as createdAt, r.updated_at as updatedAt from refund_record r left join order_info o on o.id = r.order_id left join student s on s.id = r.student_id left join service_product sp on sp.id = r.service_product_id where r.id = :refundId", new MapSqlParameterSource("refundId", refundId));
    if (rows.isEmpty()) {
      throw new com.smartguardian.backend.common.BizException(404, "退款记录不存在");
    }
    return rows.getFirst();
  }

  public void cancelRefund(Long refundId) {
    getRefundDetail(refundId);
    jdbcTemplate.update("update refund_record set status = 'CANCELLED', updated_at = CURRENT_TIMESTAMP where id = :refundId", new MapSqlParameterSource("refundId", refundId));
  }

  public Map<String, Object> getStatistics() {
    MapSqlParameterSource emptyParams = new MapSqlParameterSource();
    Long total = jdbcTemplate.queryForObject("select count(*) from refund_record", emptyParams, Long.class);
    Long pending = jdbcTemplate.queryForObject("select count(*) from refund_record where status = 'PENDING'", emptyParams, Long.class);
    Long processing = jdbcTemplate.queryForObject("select count(*) from refund_record where status = 'PROCESSING'", emptyParams, Long.class);
    Long completed = jdbcTemplate.queryForObject("select count(*) from refund_record where status = 'COMPLETED'", emptyParams, Long.class);
    BigDecimal totalAmount = jdbcTemplate.queryForObject("select coalesce(sum(refund_amount),0) from refund_record", emptyParams, BigDecimal.class);
    return Map.of("total", total == null ? 0 : total, "pending", pending == null ? 0 : pending, "processing", processing == null ? 0 : processing, "completed", completed == null ? 0 : completed, "totalAmount", totalAmount == null ? BigDecimal.ZERO : totalAmount);
  }

  public Map<String, Object> calculateRefundAmount(Long orderId) {
    List<BigDecimal> amounts = jdbcTemplate.query("select amount from order_info where id = :orderId", new MapSqlParameterSource("orderId", orderId), (rs, rowNum) -> rs.getBigDecimal("amount"));
    if (amounts.isEmpty() || amounts.getFirst() == null) {
      throw new com.smartguardian.backend.common.BizException(404, "订单不存在");
    }
    BigDecimal amount = amounts.getFirst();
    return Map.of("refundable", amount.compareTo(BigDecimal.ZERO) > 0, "refundAmount", amount, "deduction", BigDecimal.ZERO, "reason", "按演示规则全额退款");
  }

  public List<Map<String, Object>> getRefundsByOrder(Long orderId) {
    return jdbcTemplate.queryForList("select id, order_id as orderId, refund_amount as refundAmount, reason, reason_type as reasonType, status, applied_at as appliedAt from refund_record where order_id = :orderId order by id desc", new MapSqlParameterSource("orderId", orderId));
  }

  private Map<String, Object> getRefundDetailByRefundNo(String refundNo) {
    List<Map<String, Object>> rows = jdbcTemplate.queryForList("select r.id, r.order_id as orderId, o.order_no as orderNo, r.student_id as studentId, s.name as studentName, r.service_product_id as serviceProductId, sp.service_name as serviceName, r.refund_amount as refundAmount, r.reason, r.reason_type as reasonType, r.description, r.status, r.applied_at as appliedAt, r.reviewed_by as reviewedBy, r.reviewed_at as reviewedAt, r.review_remark as reviewRemark, r.processed_at as processedAt, r.completed_at as completedAt, r.created_at as createdAt, r.updated_at as updatedAt from refund_record r left join order_info o on o.id = r.order_id left join student s on s.id = r.student_id left join service_product sp on sp.id = r.service_product_id where r.refund_no = :refundNo", new MapSqlParameterSource("refundNo", refundNo));
    if (rows.isEmpty()) {
      throw new com.smartguardian.backend.common.BizException(500, "退款记录创建失败");
    }
    return rows.getFirst();
  }
}
