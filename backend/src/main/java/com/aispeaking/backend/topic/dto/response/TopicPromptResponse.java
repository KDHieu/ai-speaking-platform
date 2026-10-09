
package com.aispeaking.backend.topic.dto.response;

public record TopicPromptResponse(
        String kind,
        String text,
        int displayOrder
) {}
