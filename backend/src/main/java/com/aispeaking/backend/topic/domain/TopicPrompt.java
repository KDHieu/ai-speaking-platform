
package com.aispeaking.backend.topic.domain;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "topic_prompts")
public class TopicPrompt {

    public enum PromptKind {
        MAIN,
        CUE,
        FOLLOW_UP
    }

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "topic_id", nullable = false)
    private Topic topic;

    @Enumerated(EnumType.STRING)
    @Column(name = "prompt_kind", nullable = false, length = 20)
    private PromptKind promptKind;

    @Column(name = "prompt_text", nullable = false, columnDefinition = "text")
    private String promptText;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    protected TopicPrompt() {}

    public UUID getId() { return id; }
    public Topic getTopic() { return topic; }
    public PromptKind getPromptKind() {
        return promptKind;
    }
    public String getPromptText() {
        return promptText;
    }
    public int getDisplayOrder() {
        return displayOrder;
    }
}
