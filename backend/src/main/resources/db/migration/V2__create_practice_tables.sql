
-- ================================================
-- V2: Practice Sessions, Recordings, Transcripts
-- AI Speaking Practice Platform
-- ================================================

-- 1. Practice Sessions

-- Enables a composite foreign key to ensure
-- the selected topic belongs to the practice mode.
ALTER TABLE topics
    ADD CONSTRAINT uq_topics_id_practice_mode
        UNIQUE (id, practice_mode_id);

CREATE TABLE practice_sessions (
                                   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                                   practice_mode_id UUID NOT NULL,
                                   topic_id UUID,

                                   status VARCHAR(32) NOT NULL DEFAULT 'CREATED',

    -- Snapshot of practice mode configuration
                                   preparation_seconds INTEGER NOT NULL,
                                   speaking_seconds INTEGER,

    -- Lifecycle timestamps
                                   preparation_started_at TIMESTAMPTZ,
                                   preparation_ends_at TIMESTAMPTZ,

                                   recording_started_at TIMESTAMPTZ,
                                   recording_ended_at TIMESTAMPTZ,

                                   submitted_at TIMESTAMPTZ,
                                   completed_at TIMESTAMPTZ,

                                   created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                   updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                                   CONSTRAINT fk_session_mode
                                       FOREIGN KEY (practice_mode_id)
                                           REFERENCES practice_modes(id)
                                           ON DELETE RESTRICT,

                                   CONSTRAINT fk_session_topic_mode
                                       FOREIGN KEY (topic_id, practice_mode_id)
                                           REFERENCES topics(id, practice_mode_id)
                                           ON DELETE RESTRICT,

                                   CONSTRAINT chk_session_status
                                       CHECK (status IN (
                                                         'CREATED',
                                                         'PREPARING',
                                                         'READY_TO_RECORD',
                                                         'RECORDING',
                                                         'UPLOADED',
                                                         'PROCESSING',
                                                         'COMPLETED',
                                                         'FAILED',
                                                         'CANCELLED'
                                           )),

                                   CONSTRAINT chk_session_preparation
                                       CHECK (preparation_seconds >= 0),

                                   CONSTRAINT chk_session_speaking
                                       CHECK (
                                           speaking_seconds IS NULL
                                               OR speaking_seconds > 0
                                           ),

                                   CONSTRAINT chk_session_preparation_time
                                       CHECK (
                                           preparation_ends_at IS NULL
                                               OR (
                                               preparation_started_at IS NOT NULL
                                                   AND preparation_ends_at >= preparation_started_at
                                               )
                                           ),

                                   CONSTRAINT chk_session_recording_time
                                       CHECK (
                                           recording_ended_at IS NULL
                                               OR (
                                               recording_started_at IS NOT NULL
                                                   AND recording_ended_at >= recording_started_at
                                               )
                                           )
);

CREATE INDEX idx_sessions_status_created
    ON practice_sessions(status, created_at DESC);

CREATE INDEX idx_sessions_topic
    ON practice_sessions(topic_id);


-- 2. Recordings

CREATE TABLE recordings (
                            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                            practice_session_id UUID NOT NULL,

                            attempt_number INTEGER NOT NULL DEFAULT 1,
                            is_submitted BOOLEAN NOT NULL DEFAULT FALSE,

    -- Audio file metadata
                            storage_provider VARCHAR(16) NOT NULL DEFAULT 'LOCAL',
                            storage_key VARCHAR(512) NOT NULL UNIQUE,
                            content_type VARCHAR(100) NOT NULL,

                            size_bytes BIGINT NOT NULL,
                            duration_ms BIGINT NOT NULL,

                            uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                            CONSTRAINT fk_recording_session
                                FOREIGN KEY (practice_session_id)
                                    REFERENCES practice_sessions(id)
                                    ON DELETE CASCADE,

                            CONSTRAINT chk_recording_attempt
                                CHECK (attempt_number > 0),

                            CONSTRAINT chk_recording_storage
                                CHECK (storage_provider IN ('LOCAL', 'S3')),

                            CONSTRAINT chk_recording_size
                                CHECK (size_bytes > 0),

                            CONSTRAINT chk_recording_duration
                                CHECK (duration_ms > 0),

                            CONSTRAINT uq_recording_attempt
                                UNIQUE (practice_session_id, attempt_number)
);

-- Only one recording can be officially submitted
-- for each practice session.
CREATE UNIQUE INDEX uq_submitted_recording_per_session
    ON recordings(practice_session_id)
    WHERE is_submitted = TRUE;


-- 3. Transcripts

CREATE TABLE transcripts (
                             id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                             recording_id UUID NOT NULL UNIQUE,

                             content TEXT NOT NULL,

                             language_code VARCHAR(12) NOT NULL DEFAULT 'en',

                             stt_provider VARCHAR(80) NOT NULL,
                             stt_model VARCHAR(100),

    -- Optional word/segment timestamps
                             segments JSONB,

                             created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                             CONSTRAINT fk_transcript_recording
                                 FOREIGN KEY (recording_id)
                                     REFERENCES recordings(id)
                                     ON DELETE CASCADE,

                             CONSTRAINT chk_transcript_content
                                 CHECK (LENGTH(BTRIM(content)) > 0),

                             CONSTRAINT chk_transcript_segments
                                 CHECK (
                                     segments IS NULL
                                         OR JSONB_TYPEOF(segments) = 'array'
                                     )
);
