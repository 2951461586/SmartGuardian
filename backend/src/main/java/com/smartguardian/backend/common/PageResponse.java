package com.smartguardian.backend.common;

import java.util.List;

public record PageResponse<T>(List<T> list, long total, int pageNum, int pageSize) {
}
