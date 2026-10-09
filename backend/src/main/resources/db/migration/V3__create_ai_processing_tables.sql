
-- =================================================
-- V3: AI Processing, Evaluations and Usage Tracking
-- AI Speaking Practice Platform
-- =================================================

-- Allow composite foreign keys to guarantee that
-- recordings and transcripts belong to the
-- referenced practice session / recording.

ALTER TABLE recordings
    ADD CONSTRAINT uq_recordings_session_id
        UNIQUE (practice_session_id, id);

ALTER TABLE transcripts
    ADD CONSTRAINT uq_transcripts_recording_id_id
        UNIQUE (recording_id, id);


-- =================================================
-- 1. PROCESSING JOBS
-- =================================================

CREATE TABLE processing_jobs (
                                 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                                 practice_session_id UUID NOT NULL,
                                 recording_id UUID NOT NULL,

                                 job_type VARCHAR(30) NOT NULL
                                                     DEFAULT 'FULL_ANALYSIS',

                                 status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
                                 stage VARCHAR(20) NOT NULL DEFAULT 'QUEUED',

    -- Retry management
                                 attempt_count INTEGER NOT NULL DEFAULT 0,
                                 max_attempts INTEGER NOT NULL DEFAULT 3,
                                 next_run_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Worker leasing / crash recovery
                                 locked_by VARCHAR(120),
                                 lease_expires_at TIMESTAMPTZ,

    -- Error tracking
                                 last_error_code VARCHAR(100),
                                 last_error_message VARCHAR(1000),

    -- Lifecycle
                                 started_at TIMESTAMPTZ,
                                 finished_at TIMESTAMPTZ,
                                 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                                 CONSTRAINT fk_processing_job_session
                                     FOREIGN KEY (practice_session_id)
                                         REFERENCES practice_sessions(id)
                                         ON DELETE CASCADE,

                                 CONSTRAINT fk_processing_job_recording
                                     FOREIGN KEY (practice_session_id, recording_id)
                                         REFERENCES recordings(practice_session_id, id)
                                         ON DELETE CASCADE,

                                 CONSTRAINT chk_job_type
                                     CHECK (job_type IN (
                                                         'FULL_ANALYSIS',
                                                         'RE_EVALUATION'
                                         )),

                                 CONSTRAINT chk_job_status
                                     CHECK (status IN (
                                                       'PENDING',
                                                       'RUNNING',
                                                       'COMPLETED',
                                                       'FAILED',
                                                       'CANCELLED'
                                         )),

                                 CONSTRAINT chk_job_stage
                                     CHECK (stage IN (
                                                      'QUEUED',
                                                      'TRANSCRIPTION',
                                                      'EVALUATION',
                                                      'FINISHED'
                                         )),

                                 CONSTRAINT chk_job_attempts
                                     CHECK (
                                         attempt_count >= 0
                                             AND max_attempts > 0
                                             AND attempt_count <= max_attempts
                                         ),

                                 CONSTRAINT chk_job_finished_at
                                     CHECK (
                                         finished_at IS NULL
                                             OR started_at IS NULL
                                             OR finished_at >= started_at
                                         )
);

-- Fast lookup of jobs ready for processing
CREATE INDEX idx_processing_jobs_ready
    ON processing_jobs(next_run_at, created_at)
    WHERE status = 'PENDING';

-- Support recovery of expired worker leases
CREATE INDEX idx_processing_jobs_expired_lease
    ON processing_jobs(lease_expires_at)
    WHERE status = 'RUNNING';

-- Prevent two active analysis jobs
-- for the same practice session
CREATE UNIQUE INDEX uq_active_job_per_session
    ON processing_jobs(practice_session_id)
    WHERE status IN ('PENDING', 'RUNNING');

CREATE INDEX idx_processing_jobs_session
    ON processing_jobs(practice_session_id);


-- =================================================
-- 2. EVALUATIONS
-- =================================================

CREATE TABLE evaluations (
                             id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                             practice_session_id UUID NOT NULL,
                             recording_id UUID NOT NULL,
                             transcript_id UUID NOT NULL,

                             processing_job_id UUID,

                             evaluation_version INTEGER NOT NULL DEFAULT 1,

    -- Specifies which evidence was used
                             analysis_scope VARCHAR(30) NOT NULL
                                 DEFAULT 'TRANSCRIPT_ONLY',

                             rubric_version VARCHAR(50) NOT NULL DEFAULT 'ielts-v1',

                             llm_provider VARCHAR(80) NOT NULL,
                             llm_model VARCHAR(120) NOT NULL,

    -- IELTS criteria: nullable when not assessable
                             lexical_resource_band NUMERIC(3,1),
                             grammatical_range_band NUMERIC(3,1),
                             fluency_coherence_band NUMERIC(3,1),
                             pronunciation_band NUMERIC(3,1),
                             overall_band NUMERIC(3,1),

    -- Structured AI feedback
                             feedback_json JSONB NOT NULL,

                             created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                             CONSTRAINT fk_evaluation_recording
                                 FOREIGN KEY (practice_session_id, recording_id)
                                     REFERENCES recordings(practice_session_id, id)
                                     ON DELETE CASCADE,

                             CONSTRAINT fk_evaluation_transcript
                                 FOREIGN KEY (recording_id, transcript_id)
                                     REFERENCES transcripts(recording_id, id)
                                     ON DELETE CASCADE,

                             CONSTRAINT fk_evaluation_job
                                 FOREIGN KEY (processing_job_id)
                                     REFERENCES processing_jobs(id)
                                     ON DELETE SET NULL,

                             CONSTRAINT uq_session_evaluation_version
                                 UNIQUE (practice_session_id, evaluation_version),

                             CONSTRAINT chk_evaluation_version
                                 CHECK (evaluation_version > 0),

                             CONSTRAINT chk_analysis_scope
                                 CHECK (analysis_scope IN (
                                                           'TRANSCRIPT_ONLY',
                                                           'AUDIO_SUPPORTED'
                                     )),

                             CONSTRAINT chk_feedback_json
                                 CHECK (JSONB_TYPEOF(feedback_json) = 'object'),

    -- Scores must be between 0 and 9
    -- and use 0.5 band increments
                             CONSTRAINT chk_evaluation_bands
                                 CHECK (
                                     (
                                         lexical_resource_band IS NULL OR
                                         (
                                             lexical_resource_band BETWEEN 0 AND 9
                                                 AND lexical_resource_band * 2 =
                                                     TRUNC(lexical_resource_band * 2)
                                             )
                                         )
                                         AND
                                     (
                                         grammatical_range_band IS NULL OR
                                         (
                                             grammatical_range_band BETWEEN 0 AND 9
                                                 AND grammatical_range_band * 2 =
                                                     TRUNC(grammatical_range_band * 2)
                                             )
                                         )
                                         AND
                                     (
                                         fluency_coherence_band IS NULL OR
                                         (
                                             fluency_coherence_band BETWEEN 0 AND 9
                                                 AND fluency_coherence_band * 2 =
                                                     TRUNC(fluency_coherence_band * 2)
                                             )
                                         )
                                         AND
                                     (
                                         pronunciation_band IS NULL OR
                                         (
                                             pronunciation_band BETWEEN 0 AND 9
                                                 AND pronunciation_band * 2 =
                                                     TRUNC(pronunciation_band * 2)
                                             )
                                         )
                                         AND
                                     (
                                         overall_band IS NULL OR
                                         (
                                             overall_band BETWEEN 0 AND 9
                                                 AND overall_band * 2 =
                                                     TRUNC(overall_band * 2)
                                             )
                                         )
                                     ),

    -- A transcript-only analysis cannot provide
    -- an audio-based fluency/pronunciation score
    -- or a complete IELTS overall band.
                             CONSTRAINT chk_transcript_only_scores
                                 CHECK (
                                     analysis_scope <> 'TRANSCRIPT_ONLY'
                                         OR (
                                         fluency_coherence_band IS NULL
                                             AND pronunciation_band IS NULL
                                             AND overall_band IS NULL
                                         )
                                     )
);

CREATE INDEX idx_evaluations_session_created
    ON evaluations(practice_session_id, created_at DESC);

CREATE INDEX idx_evaluations_job
    ON evaluations(processing_job_id)
    WHERE processing_job_id IS NOT NULL;


-- =================================================
-- 3. AI USAGE RECORDS
-- =================================================

CREATE TABLE ai_usage_records (
                                  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Nullable to retain non-content cost records
    -- when a session or job is deleted
                                  practice_session_id UUID,
                                  processing_job_id UUID,

    -- Unique local ID for each provider call attempt
                                  request_key UUID NOT NULL DEFAULT gen_random_uuid(),

                                  provider_request_id VARCHAR(200),

                                  operation VARCHAR(30) NOT NULL,
                                  provider VARCHAR(80) NOT NULL,
                                  model VARCHAR(120) NOT NULL,

                                  request_status VARCHAR(20) NOT NULL DEFAULT 'STARTED',

    -- LLM token consumption
                                  input_tokens INTEGER,
                                  output_tokens INTEGER,

    -- STT audio consumption
                                  audio_duration_ms BIGINT,

    -- Provider call latency
                                  latency_ms BIGINT,

    -- USD estimate, not a confirmed provider invoice
                                  estimated_cost_usd NUMERIC(14,6)
                                      NOT NULL DEFAULT 0,

                                  error_code VARCHAR(100),

                                  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                  completed_at TIMESTAMPTZ,

                                  CONSTRAINT fk_ai_usage_session
                                      FOREIGN KEY (practice_session_id)
                                          REFERENCES practice_sessions(id)
                                          ON DELETE SET NULL,

                                  CONSTRAINT fk_ai_usage_job
                                      FOREIGN KEY (processing_job_id)
                                          REFERENCES processing_jobs(id)
                                          ON DELETE SET NULL,

                                  CONSTRAINT uq_ai_usage_request_key
                                      UNIQUE (request_key),

                                  CONSTRAINT uq_provider_request
                                      UNIQUE (provider, provider_request_id),

                                  CONSTRAINT chk_ai_operation
                                      CHECK (operation IN (
                                                           'TRANSCRIPTION',
                                                           'EVALUATION'
                                          )),

                                  CONSTRAINT chk_ai_request_status
                                      CHECK (request_status IN (
                                                                'STARTED',
                                                                'SUCCESS',
                                                                'FAILED',
                                                                'UNKNOWN'
                                          )),

                                  CONSTRAINT chk_ai_input_tokens
                                      CHECK (
                                          input_tokens IS NULL
                                              OR input_tokens >= 0
                                          ),

                                  CONSTRAINT chk_ai_output_tokens
                                      CHECK (
                                          output_tokens IS NULL
                                              OR output_tokens >= 0
                                          ),

                                  CONSTRAINT chk_ai_audio_duration
                                      CHECK (
                                          audio_duration_ms IS NULL
                                              OR audio_duration_ms >= 0
                                          ),

                                  CONSTRAINT chk_ai_latency
                                      CHECK (
                                          latency_ms IS NULL
                                              OR latency_ms >= 0
                                          ),

                                  CONSTRAINT chk_ai_cost
                                      CHECK (estimated_cost_usd >= 0),

                                  CONSTRAINT chk_ai_completed_at
                                      CHECK (
                                          completed_at IS NULL
                                              OR completed_at >= created_at
                                          )
);

CREATE INDEX idx_ai_usage_session_created
    ON ai_usage_records(practice_session_id, created_at DESC);

CREATE INDEX idx_ai_usage_job
    ON ai_usage_records(processing_job_id)
    WHERE processing_job_id IS NOT NULL;

CREATE INDEX idx_ai_usage_created_at
    ON ai_usage_records(created_at DESC);
