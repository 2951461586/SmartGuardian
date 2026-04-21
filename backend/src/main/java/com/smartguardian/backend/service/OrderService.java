package com.smartguardian.backend.service;

import com.smartguardian.backend.common.BizException;
import com.smartguardian.backend.common.JdbcPageHelper;
import com.smartguardian.backend.common.PageResponse;
import com.smartguardian.backend.common.RequestUtils;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class OrderService {

  private final NamedParameterJdbcTemplate jdbcTemplate;

  public OrderService(NamedParameterJdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public PageResponse<Map<String, Object>> getOrders(Long studentId, String orderStatus, int pageNum, int pageSize) {
    MapSqlParameterSource params = new MapSqlParameterSource()
      .addValue("studentId", studentId)
      .addValue("orderStatus", orderStatus);
    String where = " where o.is_deleted = 0 and (:studentId is null or o.student_id = :studentId) and (:orderStatus is null or o.order_status = :orderStatus) ";
    String dataSql = "select o.id, o.order_no as orderNo, o.student_id as studentId, o.service_product_id as serviceProductId, o.order_status as orderStatus, o.amount, o.paid_amount as paidAmount, o.pay_status as payStatus, o.audit_status as auditStatus, o.start_date as startDate, o.end_date as endDate, o.created_at as createdAt, o.updated_at as updatedAt, s.name as studentName, u.real_name as guardianName, sp.service_name as serviceProductName from order_info o left join student s on s.id = o.student_id left join user u on u.id = o.guardian_user_id left join service_product sp on sp.id = o.service_product_id " + where + " order by o.id desc limit :limit offset :offset";
    String countSql = "select count(*) from order_info o " + where;
    return JdbcPageHelper.page(jdbcTemplate, dataSql, countSql, params, pageNum, pageSize);
  }

  public Map<String, Object> createOrder(Map<String, Object> request) {
    Long studentId = RequestUtils.requireLong(request, "studentId");
    Long serviceProductId = RequestUtils.requireLong(request, "serviceProductId");
    String startDate = RequestUtils.requireString(request, "startDate");
    String endDate = RequestUtils.requireString(request, "endDate");
    Long guardianUserId = jdbcTemplate.queryForObject("select guardian_user_id from student where id = :studentId", new MapSqlParameterSource("studentId", studentId), Long.class);
    BigDecimal amount = jdbcTemplate.queryForObject("select price from service_product where id = :serviceProductId", new MapSqlParameterSource("serviceProductId", serviceProductId), BigDecimal.class);
    if (guardianUserId == null || amount == null) {
      throw new BizException(400, "学生或服务不存在");
    }
    String orderNo = "ORD" + System.currentTimeMillis();
    jdbcTemplate.update("insert into order_info (order_no, student_id, guardian_user_id, service_product_id, order_status, amount, paid_amount, pay_status, audit_status, start_date, end_date, remark, is_deleted, created_at, updated_at) values (:orderNo, :studentId, :guardianUserId, :serviceProductId, 'PENDING', :amount, 0, 'UNPAID', 'PENDING', :startDate, :endDate, null, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)",
      new MapSqlParameterSource().addValue("orderNo", orderNo).addValue("studentId", studentId).addValue("guardianUserId", guardianUserId).addValue("serviceProductId", serviceProductId).addValue("amount", amount).addValue("startDate", startDate).addValue("endDate", endDate));
    return getOrderDetailByOrderNo(orderNo);
  }

  public Map<String, Object> getOrderDetail(Long orderId) {
    List<Map<String, Object>> rows = jdbcTemplate.queryForList("select o.id, o.order_no as orderNo, o.student_id as studentId, o.service_product_id as serviceProductId, o.order_status as orderStatus, o.amount, o.paid_amount as paidAmount, o.pay_status as payStatus, o.audit_status as auditStatus, o.start_date as startDate, o.end_date as endDate, o.created_at as createdAt, o.updated_at as updatedAt, s.name as studentName, u.real_name as guardianName, sp.service_name as serviceProductName from order_info o left join student s on s.id = o.student_id left join user u on u.id = o.guardian_user_id left join service_product sp on sp.id = o.service_product_id where o.id = :orderId and o.is_deleted = 0", new MapSqlParameterSource("orderId", orderId));
    if (rows.isEmpty()) {
      throw new BizException(404, "订单不存在");
    }
    return new LinkedHashMap<>(rows.getFirst());
  }

  public void auditOrder(Long orderId, Map<String, Object> request) {
    String auditStatus = RequestUtils.requireString(request, "auditStatus");
    jdbcTemplate.update("update order_info set audit_status = :auditStatus, order_status = case when :auditStatus = 'APPROVED' then 'APPROVED' else 'REJECTED' end, updated_at = CURRENT_TIMESTAMP where id = :orderId", new MapSqlParameterSource().addValue("auditStatus", auditStatus).addValue("orderId", orderId));
  }

  public void refundOrder(Long orderId, Map<String, Object> request) {
    String reason = RequestUtils.optionalString(request, "reason");
    jdbcTemplate.update("insert into refund_record (refund_no, order_id, student_id, service_product_id, refund_amount, reason, reason_type, description, status, applied_at, created_at, updated_at) select :refundNo, o.id, o.student_id, o.service_product_id, o.amount, :reason, 'OTHER', :reason, 'PENDING', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP from order_info o where o.id = :orderId", new MapSqlParameterSource().addValue("refundNo", "RF" + System.currentTimeMillis()).addValue("reason", reason == null ? "订单退款" : reason).addValue("orderId", orderId));
  }

  private Map<String, Object> getOrderDetailByOrderNo(String orderNo) {
    List<Map<String, Object>> rows = jdbcTemplate.queryForList("select o.id, o.order_no as orderNo, o.student_id as studentId, o.service_product_id as serviceProductId, o.order_status as orderStatus, o.amount, o.paid_amount as paidAmount, o.pay_status as payStatus, o.audit_status as auditStatus, o.start_date as startDate, o.end_date as endDate, o.created_at as createdAt, o.updated_at as updatedAt from order_info o where o.order_no = :orderNo", new MapSqlParameterSource("orderNo", orderNo));
    return new LinkedHashMap<>(rows.getFirst());
  }
}
