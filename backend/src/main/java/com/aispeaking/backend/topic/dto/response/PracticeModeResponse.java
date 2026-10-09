
package com.aispeaking.backend.topic.dto.response;

public record PracticeModeResponse(
        String code,
        int preparationSeconds,
        Integer speakingSeconds
) {}
