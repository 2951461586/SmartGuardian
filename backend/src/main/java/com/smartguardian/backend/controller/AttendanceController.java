package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.common.PageResponse;
import com.smartguardian.backend.service.AttendanceService;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/attendance")
public class AttendanceController {

  private final AttendanceService attendanceService;

  public AttendanceController(AttendanceService attendanceService) {
    this.attendanceService = attendanceService;
  }

  @GetMapping
  public ApiResponse<PageResponse<Map<String, Object>>> list(@RequestParam(required = false) Long studentId,
                                                             @RequestParam(required = false) Long sessionId,
                                                             @RequestParam(required = false) String attendanceDate,
                                                             @RequestParam(defaultValue = "1") int pageNum,
                                                             @RequestParam(defaultValue = "20") int pageSize) {
    return ApiResponse.success(attendanceService.getAttendance(studentId, sessionId, attendanceDate, pageNum, pageSize));
  }

  @PostMapping("/sign-in")
  public ApiResponse<Map<String, Object>> signIn(@RequestBody Map<String, Object> request) {
    return ApiResponse.success(attendanceService.signIn(request));
  }

  @PostMapping("/sign-out")
  public ApiResponse<?> signOut(@RequestBody Map<String, Object> request) {
    attendanceService.signOut(request);
    return ApiResponse.success();
  }

  @GetMapping("/abnormal-events")
  public ApiResponse<PageResponse<Map<String, Object>>> abnormal(@RequestParam(required = false) String status,
                                                                 @RequestParam(defaultValue = "1") int pageNum,
                                                                 @RequestParam(defaultValue = "20") int pageSize) {
    return ApiResponse.success(attendanceService.getAbnormalEvents(status, pageNum, pageSize));
  }

  @PostMapping("/leave")
  public ApiResponse<?> leave(@RequestBody Map<String, Object> request) {
    attendanceService.submitLeave(request);
    return ApiResponse.success();
  }
}
