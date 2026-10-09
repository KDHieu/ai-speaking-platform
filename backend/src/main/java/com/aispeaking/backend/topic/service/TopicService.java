
package com.aispeaking.backend.topic.service;

import com.aispeaking.backend.topic.domain.PracticeMode;
import com.aispeaking.backend.topic.domain.Topic;
import com.aispeaking.backend.topic.dto.response.*;
import com.aispeaking.backend.topic.repository.*;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class TopicService {

    private final PracticeModeRepository practiceModeRepository;
    private final TopicRepository topicRepository;
    private final TopicPromptRepository topicPromptRepository;
    private final VocabularySuggestionRepository vocabularyRepository;

    public TopicService(
            PracticeModeRepository practiceModeRepository,
            TopicRepository topicRepository,
            TopicPromptRepository topicPromptRepository,
            VocabularySuggestionRepository vocabularyRepository
    ) {
        this.practiceModeRepository = practiceModeRepository;
        this.topicRepository = topicRepository;
        this.topicPromptRepository = topicPromptRepository;
        this.vocabularyRepository = vocabularyRepository;
    }

    // Random an active topic for a practice mode.
    public TopicResponse getRandomTopic(String modeCode) {

        if (modeCode == null || modeCode.isBlank()) {
            throw new IllegalArgumentException(
                    "Practice mode code must not be blank"
            );
        }

        practiceModeRepository
                .findByCodeAndActiveTrue(modeCode)
                .orElseThrow(() -> new NoSuchElementException(
                        "Practice mode not found: " + modeCode
                ));

        Topic topic = topicRepository
                .findRandomActiveTopic(modeCode)
                .orElseThrow(() -> new NoSuchElementException(
                        "No active topics found for mode: " + modeCode
                ));

        return mapToResponse(topic);
    }

    // Retrieve an active topic by its UUID.
    public TopicResponse getTopicById(UUID topicId) {

        Topic topic = topicRepository.findById(topicId)
                .orElseThrow(() -> new NoSuchElementException(
                        "Topic not found: " + topicId
                ));

        if (!topic.isActive()
                || !topic.getPracticeMode().isActive()) {
            throw new NoSuchElementException(
                    "Topic not available: " + topicId
            );
        }

        return mapToResponse(topic);
    }

    // Map a JPA Topic entity to an API Response DTO.
    private TopicResponse mapToResponse(Topic topic) {

        PracticeMode mode = topic.getPracticeMode();

        PracticeModeResponse modeResponse =
                new PracticeModeResponse(
                        mode.getCode(),
                        mode.getPreparationSeconds(),
                        mode.getSpeakingSeconds()
                );

        List<TopicPromptResponse> prompts =
                topicPromptRepository
                        .findByTopic_IdOrderByDisplayOrderAsc(
                                topic.getId()
                        )
                        .stream()
                        .map(prompt -> new TopicPromptResponse(
                                prompt.getPromptKind().name(),
                                prompt.getPromptText(),
                                prompt.getDisplayOrder()
                        ))
                        .toList();

        List<VocabularyResponse> vocabulary =
                vocabularyRepository
                        .findByTopic_IdOrderByDisplayOrderAsc(
                                topic.getId()
                        )
                        .stream()
                        .map(item -> new VocabularyResponse(
                                item.getExpression(),
                                item.getKind().name(),
                                item.getMeaningVi(),
                                item.getExampleSentence()
                        ))
                        .toList();

        return new TopicResponse(
                topic.getId(),
                topic.getSlug(),
                topic.getTitle(),
                topic.getCategory(),
                modeResponse,
                prompts,
                vocabulary
        );
    }
}
