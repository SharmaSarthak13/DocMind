
package com.sarthak.documentapi.dto;

import java.time.LocalDateTime;

public record DocumentResponse(
        Long id,
        String fileName,
        String contentType,
        Long fileSize,
        LocalDateTime uploadedAt
) {
}
