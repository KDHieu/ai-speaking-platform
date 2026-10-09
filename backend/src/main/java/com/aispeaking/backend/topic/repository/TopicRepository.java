
package com.aispeaking.backend.topic.repository;

import com.aispeaking.backend.topic.domain.Topic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface TopicRepository
        extends JpaRepository<Topic, UUID> {

    Optional<Topic> findBySlug(String slug);

    long countByPracticeMode_CodeAndActiveTrue(
            String modeCode
    );

    @Query(value = """
        SELECT t.*
        FROM topics t
        JOIN practice_modes pm
            ON t.practice_mode_id = pm.id
        WHERE pm.code = :modeCode
          AND pm.is_active = TRUE
          AND t.is_active = TRUE
        ORDER BY RANDOM()
        LIMIT 1
        """, nativeQuery = true)
    Optional<Topic> findRandomActiveTopic(
            @Param("modeCode") String modeCode
    );
}
