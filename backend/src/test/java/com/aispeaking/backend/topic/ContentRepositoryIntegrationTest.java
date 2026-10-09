
package com.aispeaking.backend.topic;

import com.aispeaking.backend.topic.domain.TopicPrompt;
import com.aispeaking.backend.topic.repository.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.NONE
)
class ContentRepositoryIntegrationTest {

    @Autowired
    private PracticeModeRepository practiceModeRepository;

    @Autowired
    private TopicRepository topicRepository;

    @Autowired
    private TopicPromptRepository topicPromptRepository;

    @Autowired
    private VocabularySuggestionRepository vocabularyRepository;

    @Test
    void shouldLoadIeltsPart2PracticeMode() {
        var mode = practiceModeRepository
                .findByCodeAndActiveTrue("IELTS_PART2")
                .orElseThrow();

        assertEquals(60, mode.getPreparationSeconds());
        assertEquals(120, mode.getSpeakingSeconds());
    }

    @Test
    void shouldFindRandomActiveTopic() {
        for (int i = 0; i < 5; i++) {
            var topic = topicRepository
                    .findRandomActiveTopic("IELTS_PART2")
                    .orElseThrow();

            assertNotNull(topic.getId());
            assertNotNull(topic.getTitle());
            assertTrue(topic.isActive());
        }

        assertEquals(
                10,
                topicRepository.countByPracticeMode_CodeAndActiveTrue(
                        "IELTS_PART2"
                )
        );
    }

    @Test
    void shouldLoadOrderedPromptsAndVocabulary() {
        var topic = topicRepository
                .findBySlug("memorable-journey")
                .orElseThrow();

        var prompts = topicPromptRepository
                .findByTopic_IdOrderByDisplayOrderAsc(topic.getId());

        var vocabulary = vocabularyRepository
                .findByTopic_IdOrderByDisplayOrderAsc(topic.getId());

        assertEquals(5, prompts.size());
        assertEquals(3, vocabulary.size());

        assertEquals(
                TopicPrompt.PromptKind.MAIN,
                prompts.get(0).getPromptKind()
        );

        assertEquals(
                List.of(1, 2, 3, 4, 5),
                prompts.stream()
                        .map(TopicPrompt::getDisplayOrder)
                        .toList()
        );

        assertEquals(
                List.of(1, 2, 3),
                vocabulary.stream()
                        .map(v -> v.getDisplayOrder())
                        .toList()
        );

        assertEquals(
                "breathtaking scenery",
                vocabulary.get(0).getExpression()
        );
    }
}
