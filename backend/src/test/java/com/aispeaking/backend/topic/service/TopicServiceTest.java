
package com.aispeaking.backend.topic.service;

import com.aispeaking.backend.topic.domain.*;
import com.aispeaking.backend.topic.dto.response.TopicResponse;
import com.aispeaking.backend.topic.repository.*;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TopicServiceTest {

    @Mock
    private PracticeModeRepository practiceModeRepository;

    @Mock
    private TopicRepository topicRepository;

    @Mock
    private TopicPromptRepository topicPromptRepository;

    @Mock
    private VocabularySuggestionRepository vocabularyRepository;

    @InjectMocks
    private TopicService topicService;

    @Test
    void shouldReturnRandomTopicWithPromptsAndVocabulary() {
        // Arrange
        UUID topicId = UUID.randomUUID();

        PracticeMode mode = mock(PracticeMode.class);
        Topic topic = mock(Topic.class);
        TopicPrompt prompt = mock(TopicPrompt.class);
        VocabularySuggestion vocabulary =
                mock(VocabularySuggestion.class);

        when(practiceModeRepository.findByCodeAndActiveTrue(
                "IELTS_PART2"
        )).thenReturn(Optional.of(mode));

        when(topicRepository.findRandomActiveTopic(
                "IELTS_PART2"
        )).thenReturn(Optional.of(topic));

        when(topic.getId()).thenReturn(topicId);
        when(topic.getSlug()).thenReturn("memorable-journey");
        when(topic.getTitle()).thenReturn(
                "Describe a memorable journey"
        );
        when(topic.getCategory()).thenReturn("Travel");
        when(topic.getPracticeMode()).thenReturn(mode);

        when(mode.getCode()).thenReturn("IELTS_PART2");
        when(mode.getPreparationSeconds()).thenReturn(60);
        when(mode.getSpeakingSeconds()).thenReturn(120);

        when(topicPromptRepository
                .findByTopic_IdOrderByDisplayOrderAsc(topicId))
                .thenReturn(List.of(prompt));

        when(prompt.getPromptKind()).thenReturn(
                TopicPrompt.PromptKind.MAIN
        );
        when(prompt.getPromptText()).thenReturn(
                "Describe a journey you remember well."
        );
        when(prompt.getDisplayOrder()).thenReturn(1);

        when(vocabularyRepository
                .findByTopic_IdOrderByDisplayOrderAsc(topicId))
                .thenReturn(List.of(vocabulary));

        when(vocabulary.getExpression()).thenReturn(
                "breathtaking scenery"
        );
        when(vocabulary.getKind()).thenReturn(
                VocabularySuggestion.VocabularyKind.COLLOCATION
        );
        when(vocabulary.getMeaningVi()).thenReturn(
                "Phong cảnh đẹp đến ngỡ ngàng"
        );
        when(vocabulary.getExampleSentence()).thenReturn(
                "We enjoyed the breathtaking scenery."
        );

        // Act
        TopicResponse result =
                topicService.getRandomTopic("IELTS_PART2");

        // Assert
        assertNotNull(result);
        assertEquals(topicId, result.id());
        assertEquals("memorable-journey", result.slug());
        assertEquals("Travel", result.category());

        assertEquals(
                60,
                result.practiceMode().preparationSeconds()
        );
        assertEquals(
                120,
                result.practiceMode().speakingSeconds()
        );

        assertEquals(1, result.prompts().size());
        assertEquals("MAIN", result.prompts().get(0).kind());

        assertEquals(1, result.vocabularySuggestions().size());
        assertEquals(
                "breathtaking scenery",
                result.vocabularySuggestions()
                        .get(0).expression()
        );

        verify(topicRepository, times(1))
                .findRandomActiveTopic("IELTS_PART2");
    }

    @Test
    void shouldRejectBlankPracticeMode() {
        // Act & Assert
        assertThrows(
                IllegalArgumentException.class,
                () -> topicService.getRandomTopic(" ")
        );

        // Invalid input must not trigger database queries
        verifyNoInteractions(
                practiceModeRepository,
                topicRepository,
                topicPromptRepository,
                vocabularyRepository
        );
    }

    @Test
    void shouldThrowWhenPracticeModeNotFound() {
        // Arrange
        when(practiceModeRepository.findByCodeAndActiveTrue(
                "INVALID_MODE"
        )).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(
                NoSuchElementException.class,
                () -> topicService.getRandomTopic("INVALID_MODE")
        );

        verifyNoInteractions(topicRepository);
    }

    @Test
    void shouldRejectInactiveTopic() {
        // Arrange
        UUID topicId = UUID.randomUUID();
        Topic topic = mock(Topic.class);

        when(topicRepository.findById(topicId))
                .thenReturn(Optional.of(topic));

        when(topic.isActive()).thenReturn(false);

        // Act & Assert
        assertThrows(
                NoSuchElementException.class,
                () -> topicService.getTopicById(topicId)
        );

        verifyNoInteractions(
                topicPromptRepository,
                vocabularyRepository
        );
    }
}
