
package com.aispeaking.backend.topic.dto.response;

import java.util.List;
import java.util.UUID;

public record TopicResponse(
        UUID id,
        String slug,
        String title,
        String category,
        PracticeModeResponse practiceMode,
        List<TopicPromptResponse> prompts,
        List<VocabularyResponse> vocabularySuggestions
) {}
