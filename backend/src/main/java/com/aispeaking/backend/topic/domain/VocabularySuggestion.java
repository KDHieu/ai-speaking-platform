
package com.aispeaking.backend.topic.domain;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "vocabulary_suggestions")
public class VocabularySuggestion {

    public enum VocabularyKind {
        WORD,
        COLLOCATION,
        IDIOM,
        PHRASE
    }

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "topic_id", nullable = false)
    private Topic topic;

    @Column(nullable = false, length = 200)
    private String expression;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private VocabularyKind kind;

    @Column(name = "meaning_vi", columnDefinition = "text")
    private String meaningVi;

    @Column(name = "example_sentence", columnDefinition = "text")
    private String exampleSentence;

    @Column(name = "display_order", nullable = false)
    private int displayOrder;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    protected VocabularySuggestion() {}

    public UUID getId() { return id; }
    public Topic getTopic() { return topic; }
    public String getExpression() {
        return expression;
    }
    public VocabularyKind getKind() {
        return kind;
    }
    public String getMeaningVi() {
        return meaningVi;
    }
    public String getExampleSentence() {
        return exampleSentence;
    }
    public int getDisplayOrder() {
        return displayOrder;
    }
}
