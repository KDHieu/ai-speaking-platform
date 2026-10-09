
-- ============================================
-- V1: Content Management Schema
-- AI Speaking Practice Platform
-- ============================================

-- 1. Practice Modes
CREATE TABLE practice_modes (
                                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                code VARCHAR(50) NOT NULL UNIQUE,
                                name VARCHAR(120) NOT NULL,
                                preparation_seconds INTEGER NOT NULL DEFAULT 0,
                                speaking_seconds INTEGER,
                                is_active BOOLEAN NOT NULL DEFAULT TRUE,
                                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                                CONSTRAINT chk_mode_preparation
                                    CHECK (preparation_seconds >= 0),

                                CONSTRAINT chk_mode_speaking
                                    CHECK (
                                        speaking_seconds IS NULL
                                            OR speaking_seconds > 0
                                        )
);

-- 2. Topics
CREATE TABLE topics (
                        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                        practice_mode_id UUID NOT NULL,
                        slug VARCHAR(150) NOT NULL UNIQUE,
                        title VARCHAR(255) NOT NULL,
                        category VARCHAR(100) NOT NULL,
                        is_active BOOLEAN NOT NULL DEFAULT TRUE,
                        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                        CONSTRAINT fk_topics_practice_mode
                            FOREIGN KEY (practice_mode_id)
                                REFERENCES practice_modes(id)
                                ON DELETE RESTRICT
);

-- 3. Topic Prompts
CREATE TABLE topic_prompts (
                               id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                               topic_id UUID NOT NULL,
                               prompt_kind VARCHAR(20) NOT NULL,
                               prompt_text TEXT NOT NULL,
                               display_order INTEGER NOT NULL,
                               created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                               CONSTRAINT fk_prompts_topic
                                   FOREIGN KEY (topic_id)
                                       REFERENCES topics(id)
                                       ON DELETE CASCADE,

                               CONSTRAINT chk_prompt_kind
                                   CHECK (
                                       prompt_kind IN (
                                                       'MAIN',
                                                       'CUE',
                                                       'FOLLOW_UP'
                                           )
                                       ),

                               CONSTRAINT chk_prompt_order
                                   CHECK (display_order > 0),

                               CONSTRAINT uq_topic_prompt_order
                                   UNIQUE (topic_id, display_order)
);

-- 4. Vocabulary Suggestions
CREATE TABLE vocabulary_suggestions (
                                        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                        topic_id UUID NOT NULL,
                                        expression VARCHAR(200) NOT NULL,
                                        kind VARCHAR(20) NOT NULL,
                                        meaning_vi TEXT,
                                        example_sentence TEXT,
                                        display_order INTEGER NOT NULL,
                                        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                                        CONSTRAINT fk_vocabulary_topic
                                            FOREIGN KEY (topic_id)
                                                REFERENCES topics(id)
                                                ON DELETE CASCADE,

                                        CONSTRAINT chk_vocabulary_kind
                                            CHECK (
                                                kind IN (
                                                         'WORD',
                                                         'COLLOCATION',
                                                         'IDIOM',
                                                         'PHRASE'
                                                    )
                                                ),

                                        CONSTRAINT chk_vocabulary_order
                                            CHECK (display_order > 0),

                                        CONSTRAINT uq_vocabulary_display_order
                                            UNIQUE (topic_id, display_order)
);

-- Index for searching active topics by mode/category
CREATE INDEX idx_topics_mode_category_active
    ON topics (practice_mode_id, category)
    WHERE is_active = TRUE;
