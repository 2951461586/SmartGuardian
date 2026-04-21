package com.smartguardian.backend.controller;

import com.smartguardian.backend.common.ApiResponse;
import com.smartguardian.backend.common.PageResponse;
import com.smartguardian.backend.service.TimelineService;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/timeline")
public class TimelineController {

  private final TimelineService timelineService;

  public TimelineController(TimelineService timelineService) {
    this.timelineService = timelineService;
  }

  @GetMapping("/students/{studentId}")
  public ApiResponse<PageResponse<Map<String, Object>>> studentTimeline(@PathVariable Long studentId,
                                                                        @RequestParam(required = false) String bizDate,
                                                                        @RequestParam(defaultValue = "1") int pageNum,
                                                                        @RequestParam(defaultValue = "20") int pageSize) {
    return ApiResponse.success(timelineService.getStudentTimeline(studentId, bizDate, pageNum, pageSize));
  }
}
