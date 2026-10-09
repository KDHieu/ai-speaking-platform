
package com.aispeaking.backend.topic.repository;

import com.aispeaking.backend.topic.domain.PracticeMode;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface PracticeModeRepository
        extends JpaRepository<PracticeMode, UUID> {

    Optional<PracticeMode> findByCodeAndActiveTrue(
            String code
    );
}
