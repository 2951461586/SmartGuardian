package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.common.PageResponse;
import com.smartguardian.backend.common.SecurityUtils;
import com.smartguardian.backend.domain.CurrentUser;
import com.smartguardian.backend.service.MessageService;
import java.util.List;
import java.util.Map;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/messages")
public class MessageController {

  private final MessageService messageService;

  public MessageController(MessageService messageService) {
    this.messageService = messageService;
  }

  @GetMapping
  public ApiResponse<PageResponse<Map<String, Object>>> list(Authentication authentication,
                                                             @RequestParam(required = false) String msgType,
                                                             @RequestParam(required = false) Boolean readStatus,
                                                             @RequestParam(defaultValue = "1") int pageNum,
                                                             @RequestParam(defaultValue = "20") int pageSize) {
    CurrentUser currentUser = SecurityUtils.currentUser(authentication);
    return ApiResponse.success(messageService.getMessages(currentUser.userId(), msgType, readStatus, pageNum, pageSize));
  }

  @GetMapping("/{messageId}")
  public ApiResponse<Map<String, Object>> detail(Authentication authentication, @PathVariable Long messageId) {
    CurrentUser currentUser = SecurityUtils.currentUser(authentication);
    Map<String, Object> detail = messageService.getMessageDetail(messageId);
    Object owner = detail.get("USERID");
    if (owner != null && !currentUser.userId().equals(Long.valueOf(String.valueOf(owner))) && !"ADMIN".equals(currentUser.roleType())) {
      throw new com.smartguardian.backend.common.BizException(403, "无权限访问");
    }
    return ApiResponse.success(detail);
  }

  @PostMapping("/{messageId}/read")
  public ApiResponse<?> read(@PathVariable Long messageId) {
    messageService.markAsRead(messageId);
    return ApiResponse.success();
  }

  @PostMapping("/batch-read")
  public ApiResponse<?> batchRead(@RequestBody Map<String, List<Long>> request) {
    messageService.batchMarkAsRead(request.get("messageIds"));
    return ApiResponse.success();
  }

  @PostMapping("/read-all")
  public ApiResponse<?> readAll(Authentication authentication) {
    CurrentUser currentUser = SecurityUtils.currentUser(authentication);
    messageService.markAllAsRead(currentUser.userId());
    return ApiResponse.success();
  }

  @PostMapping("/{messageId}/delete")
  public ApiResponse<?> delete(@PathVariable Long messageId) {
    messageService.deleteMessage(messageId);
    return ApiResponse.success();
  }

  @GetMapping("/unread-count")
  public ApiResponse<Map<String, Object>> unreadCount(Authentication authentication) {
    CurrentUser currentUser = SecurityUtils.currentUser(authentication);
    return ApiResponse.success(messageService.getUnreadCount(currentUser.userId()));
  }

  @GetMapping("/statistics")
  public ApiResponse<Map<String, Object>> statistics(Authentication authentication) {
    CurrentUser currentUser = SecurityUtils.currentUser(authentication);
    return ApiResponse.success(messageService.getStatistics(currentUser.userId()));
  }

  @PostMapping
  public ApiResponse<Map<String, Object>> send(Authentication authentication, @RequestBody Map<String, Object> request) {
    CurrentUser currentUser = SecurityUtils.currentUser(authentication);
    return ApiResponse.success(messageService.sendMessage(request, currentUser.userId()));
  }
}
