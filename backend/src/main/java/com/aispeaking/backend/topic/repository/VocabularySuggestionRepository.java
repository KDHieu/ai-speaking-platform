
package com.aispeaking.backend.topic.repository;

import com.aispeaking.backend.topic.domain.VocabularySuggestion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface VocabularySuggestionRepository
        extends JpaRepository<VocabularySuggestion, UUID> {

    List<VocabularySuggestion> findByTopic_IdOrderByDisplayOrderAsc(
            UUID topicId
    );
}
