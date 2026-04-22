package com.smartguardian.backend.service;

import com.smartguardian.backend.common.RequestUtils;
import java.math.BigDecimal;
import java.util.Map;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class PaymentService {

  private final NamedParameterJdbcTemplate jdbcTemplate;

  public PaymentService(NamedParameterJdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public Map<String, Object> createPayment(Map<String, Object> request) {
    Long orderId = RequestUtils.requireLong(request, "orderId");
    BigDecimal payAmount = RequestUtils.optionalDecimal(request, "payAmount");
    jdbcTemplate.update("insert into payment_record (order_id, payment_no, pay_channel, pay_amount, pay_status, refund_amount, refund_status, transaction_time, callback_time, is_deleted, created_by, updated_by, created_at, updated_at) values (:orderId, :paymentNo, :payChannel, :payAmount, 'CREATED', 0, 'NONE', null, null, 0, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)",
      new MapSqlParameterSource().addValue("orderId", orderId).addValue("paymentNo", "PAY" + System.currentTimeMillis()).addValue("payChannel", RequestUtils.requireString(request, "payChannel")).addValue("payAmount", payAmount == null ? BigDecimal.ZERO : payAmount));
    Long id = jdbcTemplate.queryForObject("select max(id) from payment_record", new MapSqlParameterSource(), Long.class);
    Map<String, Object> row = jdbcTemplate.queryForList("select id, order_id as orderId, payment_no as paymentNo, pay_channel as payChannel, pay_amount as payAmount, case when pay_status = 'SUCCESS' then 'SUCCESS' else 'CREATED' end as payStatus, transaction_time as payTime from payment_record where id = :id", new MapSqlParameterSource("id", id)).get(0);
    row.put("payUrl", "https://pay.smartguardian.local/" + row.get("PAYMENTNO"));
    row.put("qrCode", "QR-" + row.get("PAYMENTNO"));
    return row;
  }

  public void callback(Map<String, Object> request) {
    jdbcTemplate.update("update payment_record set pay_status = case when :tradeStatus = 'SUCCESS' then 'SUCCESS' when :tradeStatus = 'FAILED' then 'FAILED' when :tradeStatus = 'REFUNDED' then 'REFUNDED' else 'CLOSED' end, transaction_time = CURRENT_TIMESTAMP, callback_time = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP where payment_no = :paymentNo",
      new MapSqlParameterSource().addValue("tradeStatus", RequestUtils.requireString(request, "tradeStatus")).addValue("paymentNo", RequestUtils.requireString(request, "paymentNo")));
  }
}
