
package com.aispeaking.backend.topic.domain;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "practice_modes")
public class PracticeMode {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true, length = 50)
    private String code;

    @Column(nullable = false, length = 120)
    private String name;

    @Column(name = "preparation_seconds", nullable = false)
    private int preparationSeconds;

    @Column(name = "speaking_seconds")
    private Integer speakingSeconds;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private Instant updatedAt;

    protected PracticeMode() {}

    public UUID getId() { return id; }
    public String getCode() { return code; }
    public String getName() { return name; }
    public int getPreparationSeconds() {
        return preparationSeconds;
    }
    public Integer getSpeakingSeconds() {
        return speakingSeconds;
    }
    public boolean isActive() { return active; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
