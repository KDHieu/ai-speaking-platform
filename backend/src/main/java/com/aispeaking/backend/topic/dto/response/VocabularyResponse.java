
package com.aispeaking.backend.topic.dto.response;

public record VocabularyResponse(
        String expression,
        String kind,
        String meaningVi,
        String exampleSentence
) {}
