
package com.aispeaking.backend.topic.repository;

import com.aispeaking.backend.topic.domain.TopicPrompt;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TopicPromptRepository
        extends JpaRepository<TopicPrompt, UUID> {

    List<TopicPrompt> findByTopic_IdOrderByDisplayOrderAsc(
            UUID topicId
    );
}
