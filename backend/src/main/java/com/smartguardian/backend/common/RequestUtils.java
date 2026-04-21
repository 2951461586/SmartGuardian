package com.smartguardian.backend.common;

import java.math.BigDecimal;
import java.util.Map;

public final class RequestUtils {

  private RequestUtils() {
  }

  public static String requireString(Map<String, Object> source, String key) {
    Object value = source.get(key);
    if (value == null || value.toString().isBlank()) {
      throw new BizException(400, key + " 不能为空");
    }
    return value.toString().trim();
  }

  public static String optionalString(Map<String, Object> source, String key) {
    Object value = source.get(key);
    return value == null ? null : value.toString().trim();
  }

  public static Long requireLong(Map<String, Object> source, String key) {
    Object value = source.get(key);
    if (value == null) {
      throw new BizException(400, key + " 不能为空");
    }
    return Long.parseLong(value.toString());
  }

  public static Long optionalLong(Map<String, Object> source, String key) {
    Object value = source.get(key);
    return value == null || value.toString().isBlank() ? null : Long.parseLong(value.toString());
  }

  public static Integer optionalInt(Map<String, Object> source, String key) {
    Object value = source.get(key);
    return value == null || value.toString().isBlank() ? null : Integer.parseInt(value.toString());
  }

  public static BigDecimal optionalDecimal(Map<String, Object> source, String key) {
    Object value = source.get(key);
    return value == null || value.toString().isBlank() ? null : new BigDecimal(value.toString());
  }

  public static Boolean optionalBoolean(Map<String, Object> source, String key) {
    Object value = source.get(key);
    return value == null ? null : Boolean.parseBoolean(value.toString());
  }
}
