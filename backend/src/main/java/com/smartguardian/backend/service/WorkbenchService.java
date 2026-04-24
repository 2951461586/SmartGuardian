package com.smartguardian.backend.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public class WorkbenchService {

  public Map<String, Object> getManifest(String roleType) {
    String normalizedRole = normalizeRole(roleType);
    Map<String, Object> result = new LinkedHashMap<>();
    result.put("roleType", normalizedRole);
    result.put("version", "2026.04.fullstack-r1");
    result.put("visual", buildVisual(normalizedRole));
    result.put("summary", buildSummary(normalizedRole));
    result.put("primaryFlows", buildPrimaryFlows(normalizedRole));
    result.put("modules", buildModules(normalizedRole));
    result.put("integration", buildIntegration());
    return result;
  }

  private String normalizeRole(String roleType) {
    if ("TEACHER".equals(roleType)) {
      return "TEACHER";
    }
    if ("ADMIN".equals(roleType) ||
      "ORG_ADMIN".equals(roleType) ||
      "SCHOOL_ADMIN".equals(roleType) ||
      "PLATFORM_ADMIN".equals(roleType)) {
      return "ORG_ADMIN";
    }
    return "PARENT";
  }

  private Map<String, Object> buildVisual(String roleType) {
    Map<String, Object> visual = new LinkedHashMap<>();
    visual.put("surface", "浅灰蓝页面底 + 白色信息卡片");
    visual.put("componentTone", "登录页同源圆角、柔和边框、轻阴影");
    if ("TEACHER".equals(roleType)) {
      visual.put("primary", "#5D8267");
      visual.put("light", "#EEF6F0");
      visual.put("slogan", "教书育人，助力成长");
    } else if ("ORG_ADMIN".equals(roleType)) {
      visual.put("primary", "#7B6D96");
      visual.put("light", "#F2F0F7");
      visual.put("slogan", "专业托管，安全无忧");
    } else {
      visual.put("primary", "#526F95");
      visual.put("light", "#EEF4FA");
      visual.put("slogan", "陪伴孩子成长，关注每一步");
    }
    return visual;
  }

  private Map<String, Object> buildSummary(String roleType) {
    if ("TEACHER".equals(roleType)) {
      return summary("教师工作台", "放学高峰签到、作业辅导、异常处置和家校反馈集中处理。", "今日班次", "待签到", "待反馈");
    }
    if ("ORG_ADMIN".equals(roleType)) {
      return summary("机构工作台", "服务产品、订单审核、班次资源、退款告警和经营报表统一治理。", "待审核订单", "班次负载", "活跃告警");
    }
    return summary("家长工作台", "学生今日托管状态、预约订单、接送码、作业反馈和消息提醒聚合呈现。", "今日状态", "待确认反馈", "未读消息");
  }

  private Map<String, Object> summary(String title, String description, String metricA, String metricB, String metricC) {
    Map<String, Object> summary = new LinkedHashMap<>();
    summary.put("title", title);
    summary.put("description", description);
    summary.put("metrics", List.of(metricA, metricB, metricC));
    return summary;
  }

  private List<Map<String, Object>> buildPrimaryFlows(String roleType) {
    List<Map<String, Object>> flows = new ArrayList<>();
    if ("TEACHER".equals(roleType)) {
      flows.add(flow("attendance_peak", "高峰签到", "班次名单、扫码签到、异常复核和家长通知形成闭环"));
      flows.add(flow("homework_feedback", "作业辅导", "记录进度、表现标签、反馈提交和家长确认"));
      flows.add(flow("parent_message", "家校沟通", "围绕学生动态和异常事件发起会话"));
      return flows;
    }
    if ("ORG_ADMIN".equals(roleType)) {
      flows.add(flow("order_audit", "订单审核", "预约、支付、审核、排班和退款状态统一追踪"));
      flows.add(flow("session_capacity", "班次资源", "教师、教室、容量和学生名单调度"));
      flows.add(flow("operation_report", "经营分析", "考勤、财务、绩效和告警数据看板"));
      return flows;
    }
    flows.add(flow("today_guardian", "今日托管", "签到、辅导、待接回和异常提醒一屏掌握"));
    flows.add(flow("booking_payment", "预约支付", "服务浏览、订单创建、支付与退款申请"));
    flows.add(flow("growth_timeline", "成长时间线", "作业反馈、老师评价和重要动态沉淀"));
    return flows;
  }

  private Map<String, Object> flow(String code, String name, String description) {
    Map<String, Object> flow = new LinkedHashMap<>();
    flow.put("code", code);
    flow.put("name", name);
    flow.put("description", description);
    return flow;
  }

  private List<Map<String, Object>> buildModules(String roleType) {
    if ("TEACHER".equals(roleType)) {
      return List.of(
        module("home", "工作台", "/teacher/home", true),
        module("scan", "扫码签到", "/teacher/scan", true),
        module("attendance", "考勤签到", "/teacher/attendance", true),
        module("homework", "作业反馈", "/teacher/homework", true),
        module("schedule", "班次日程", "/teacher/schedule", true),
        module("messages", "家校消息", "/teacher/messages", true),
        module("profile", "我的", "/teacher/profile", true)
      );
    }
    if ("ORG_ADMIN".equals(roleType)) {
      return List.of(
        module("home", "运营总览", "/admin/home", true),
        module("messages", "消息中心", "/admin/messages", true),
        module("orders", "订单审核", "/admin/orders", true),
        module("sessions", "班次排课", "/admin/sessions", true),
        module("students", "学生档案", "/admin/students", true),
        module("reports", "统计报表", "/admin/reports", true),
        module("alerts", "告警中心", "/admin/alerts", true),
        module("refunds", "退款管理", "/admin/refunds", true),
        module("profile", "我的", "/admin/profile", true)
      );
    }
    return List.of(
      module("home", "今日托管", "/parent/home", true),
      module("services", "托管服务", "/parent/services", true),
      module("orders", "我的订单", "/parent/orders", true),
      module("homework", "作业反馈", "/parent/homework", true),
      module("sessions", "在校安排", "/parent/sessions", true),
      module("timeline", "成长动态", "/parent/timeline", true),
      module("messages", "家校消息", "/parent/messages", true),
      module("alerts", "安全守护", "/parent/alerts", true),
      module("profile", "家庭与设置", "/parent/profile", true)
    );
  }

  private Map<String, Object> module(String code, String name, String route, boolean enabled) {
    Map<String, Object> module = new LinkedHashMap<>();
    module.put("code", code);
    module.put("name", name);
    module.put("route", route);
    module.put("enabled", enabled);
    return module;
  }

  private Map<String, Object> buildIntegration() {
    Map<String, Object> integration = new LinkedHashMap<>();
    integration.put("apiBase", "/api/v1");
    integration.put("auth", "Bearer JWT");
    integration.put("mockDefault", true);
    integration.put("acceptance", List.of("Mock 演示可跑通", "本地 Spring Boot + MySQL 可联调", "OpenAPI 与前端模型保持一致"));
    return integration;
  }
}
