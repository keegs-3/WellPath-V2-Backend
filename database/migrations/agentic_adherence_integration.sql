-- WellPath Agentic Adherence System - Integration with Existing Tables
-- This migration extends existing tables and creates new agent-specific tables
-- that integrate with the current WellPath infrastructure

-- ============================================
-- EXTEND EXISTING RECOMMENDATIONS_BASE
-- ============================================

-- Add agent-friendly fields to existing recommendations_base table
ALTER TABLE recommendations_base ADD COLUMN IF NOT EXISTS agent_goal TEXT;
ALTER TABLE recommendations_base ADD COLUMN IF NOT EXISTS agent_context JSONB DEFAULT '{}';
ALTER TABLE recommendations_base ADD COLUMN IF NOT EXISTS agent_enabled BOOLEAN DEFAULT true;

COMMENT ON COLUMN recommendations_base.agent_goal IS 'Natural language goal for agent interpretation (e.g., "Get 10,000 steps daily")';
COMMENT ON COLUMN recommendations_base.agent_context IS 'Optional hints for edge cases that agent should consider';
COMMENT ON COLUMN recommendations_base.agent_enabled IS 'Whether this recommendation uses agent-based adherence tracking';

-- ============================================
-- EXTEND PATIENT_RECOMMENDATIONS
-- ============================================

-- Add personalization fields for agent use
ALTER TABLE patient_recommendations ADD COLUMN IF NOT EXISTS personal_target JSONB;
ALTER TABLE patient_recommendations ADD COLUMN IF NOT EXISTS agent_notes TEXT;
ALTER TABLE patient_recommendations ADD COLUMN IF NOT EXISTS last_agent_evaluation TIMESTAMPTZ;

COMMENT ON COLUMN patient_recommendations.personal_target IS 'User-specific goal adjustments for the agent';
COMMENT ON COLUMN patient_recommendations.agent_notes IS 'Agent observations about this users progress';
COMMENT ON COLUMN patient_recommendations.last_agent_evaluation IS 'Last time agent evaluated this recommendation';

-- ============================================
-- NEW: DAILY ADHERENCE SCORES (HIERARCHICAL)
-- ============================================

-- Individual recommendation adherence scores
CREATE TABLE IF NOT EXISTS agent_adherence_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    patient_recommendation_id UUID NOT NULL REFERENCES patient_recommendations(id) ON DELETE CASCADE,
    recommendation_id UUID NOT NULL REFERENCES recommendations_base(id) ON DELETE CASCADE,
    score_date DATE NOT NULL,

    -- Adherence scoring
    adherence_percentage FLOAT NOT NULL CHECK (adherence_percentage >= 0 AND adherence_percentage <= 100),
    score_quality TEXT CHECK (score_quality IN ('measured', 'estimated', 'partial_data', 'no_data')),
    data_sources_used TEXT[], -- ['healthkit', 'manual_entry', 'survey', etc.]

    -- Agent reasoning
    calculation_reasoning TEXT,
    adjustments_applied JSONB,
    confidence_score FLOAT CHECK (confidence_score >= 0 AND confidence_score <= 100),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(patient_id, patient_recommendation_id, score_date)
);

CREATE INDEX idx_agent_adherence_patient_date ON agent_adherence_scores(patient_id, score_date);
CREATE INDEX idx_agent_adherence_rec ON agent_adherence_scores(recommendation_id, score_date);

-- Pillar-level aggregated scores
CREATE TABLE IF NOT EXISTS agent_pillar_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    pillar_id UUID NOT NULL REFERENCES pillars_base(id) ON DELETE CASCADE,
    score_date DATE NOT NULL,

    -- Pillar-level aggregation
    adherence_percentage FLOAT NOT NULL CHECK (adherence_percentage >= 0 AND adherence_percentage <= 100),
    active_recommendations INTEGER DEFAULT 0,
    recommendations_scored INTEGER DEFAULT 0,

    -- Component scores for transparency
    component_scores JSONB, -- Individual rec scores

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(patient_id, pillar_id, score_date)
);

CREATE INDEX idx_agent_pillar_patient_date ON agent_pillar_scores(patient_id, score_date);

-- Overall daily adherence score
CREATE TABLE IF NOT EXISTS agent_overall_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    score_date DATE NOT NULL,

    -- Overall score
    adherence_percentage FLOAT NOT NULL CHECK (adherence_percentage >= 0 AND adherence_percentage <= 100),
    active_recommendations INTEGER DEFAULT 0,
    recommendations_scored INTEGER DEFAULT 0,

    -- Breakdown by pillar
    pillar_scores JSONB,

    -- User context that affected scoring
    active_mode TEXT,
    mode_adjustments JSONB,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(patient_id, score_date)
);

CREATE INDEX idx_agent_overall_patient_date ON agent_overall_scores(patient_id, score_date);

-- ============================================
-- NEW: USER MODES FOR CONTEXTUAL ADJUSTMENTS
-- ============================================

CREATE TABLE IF NOT EXISTS patient_modes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    mode_type TEXT NOT NULL CHECK (mode_type IN ('travel', 'injury', 'illness', 'high_stress', 'recovery', 'custom')),

    -- Mode configuration
    start_date DATE NOT NULL,
    end_date DATE, -- NULL if ongoing

    -- Mode-specific adjustments
    mode_config JSONB,
    /* Examples:
    Travel: {"reduce_exercise_targets": 0.5, "ignore_meal_timing": true}
    Injury: {"affected_body_part": "knee", "restrict_activities": ["running"]}
    Illness: {"severity": "moderate", "pause_pillars": ["movement"]}
    */

    -- User notes
    notes TEXT,
    is_active BOOLEAN GENERATED ALWAYS AS (end_date IS NULL OR end_date >= CURRENT_DATE) STORED,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_patient_modes_patient_active ON patient_modes(patient_id, is_active) WHERE is_active = true;
CREATE INDEX idx_patient_modes_patient_dates ON patient_modes(patient_id, start_date, end_date);

-- ============================================
-- NEW: AGENT-GENERATED NUDGES
-- ============================================

CREATE TABLE IF NOT EXISTS agent_nudges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    recommendation_id UUID REFERENCES recommendations_base(id) ON DELETE CASCADE,

    -- Nudge content
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    tone TEXT CHECK (tone IN ('encouraging', 'educational', 'celebratory', 'supportive', 'motivational', 'reminder')),
    nudge_type TEXT CHECK (nudge_type IN ('adherence_support', 'milestone', 'insight', 'reminder', 'celebration', 'challenge')),

    -- Agent decision making
    trigger_reason JSONB,
    personalization_factors JSONB,
    generation_reasoning TEXT,

    -- Delivery and response
    scheduled_for TIMESTAMPTZ NOT NULL,
    delivered_at TIMESTAMPTZ,
    user_response TEXT CHECK (user_response IN ('helpful', 'not_helpful', 'dismissed', NULL)),
    response_timestamp TIMESTAMPTZ,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_agent_nudges_patient_scheduled ON agent_nudges(patient_id, scheduled_for);
CREATE INDEX idx_agent_nudges_pending ON agent_nudges(patient_id) WHERE delivered_at IS NULL;
CREATE INDEX idx_agent_nudges_recommendation ON agent_nudges(recommendation_id) WHERE recommendation_id IS NOT NULL;

-- ============================================
-- NEW: AGENT-GENERATED CHALLENGES
-- ============================================

CREATE TABLE IF NOT EXISTS agent_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    recommendation_id UUID REFERENCES recommendations_base(id) ON DELETE CASCADE,

    -- Challenge content
    challenge_title TEXT NOT NULL,
    challenge_description TEXT NOT NULL,
    challenge_goal TEXT NOT NULL, -- Natural language goal

    -- Challenge parameters
    difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level BETWEEN 1 AND 3),
    duration_days INTEGER DEFAULT 7,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    -- Agent context
    trigger_reason JSONB, -- Why agent created this challenge
    context_factors JSONB, -- Travel, injury, motivation dip, etc.
    generation_reasoning TEXT,

    -- Status tracking
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'abandoned', 'expired')),
    completion_percentage FLOAT CHECK (completion_percentage >= 0 AND completion_percentage <= 100),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_agent_challenges_patient_status ON agent_challenges(patient_id, status);
CREATE INDEX idx_agent_challenges_patient_dates ON agent_challenges(patient_id, start_date, end_date);
CREATE INDEX idx_agent_challenges_recommendation ON agent_challenges(recommendation_id) WHERE recommendation_id IS NOT NULL;

-- ============================================
-- NEW: AGENT USER CONTEXT
-- ============================================

CREATE TABLE IF NOT EXISTS agent_user_context (
    patient_id UUID PRIMARY KEY REFERENCES patients(patient_id) ON DELETE CASCADE,

    -- Current state
    active_recommendations UUID[], -- References to patient_recommendations
    current_health_focus TEXT[], -- User's stated priorities
    recent_life_events JSONB,

    -- Behavioral patterns (learned by agent)
    best_engagement_times JSONB, -- When user typically engages
    message_preferences JSONB, -- Tone, frequency preferences
    historical_adherence_patterns JSONB,

    -- Capacity assessment
    current_capacity_score FLOAT CHECK (current_capacity_score >= 0 AND current_capacity_score <= 100),
    capacity_factors JSONB, -- What's affecting their capacity

    -- Last agent analysis
    last_analyzed_at TIMESTAMPTZ,
    agent_notes TEXT,

    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- NEW: RESEARCH KNOWLEDGE BASE
-- ============================================

CREATE TABLE IF NOT EXISTS agent_research_knowledge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Source information
    source_type TEXT NOT NULL CHECK (source_type IN ('pubmed', 'clinical_trial', 'meta_analysis', 'review', 'guideline', 'other')),
    source_id TEXT,
    title TEXT NOT NULL,
    authors TEXT[],
    publication_date DATE,
    journal TEXT,
    url TEXT,

    -- Content
    abstract TEXT,
    full_text TEXT,
    key_findings JSONB,

    -- Relevance mapping (integrates with existing biomarkers/biometrics)
    relevant_biomarkers TEXT[], -- From biomarkers_base.marker_id
    relevant_biometrics TEXT[], -- From biometrics_base.metric_id
    relevant_interventions TEXT[],
    population_characteristics JSONB,

    -- Quality scoring
    evidence_level TEXT CHECK (evidence_level IN ('high', 'moderate', 'low')),
    study_design TEXT,
    sample_size INTEGER,
    confidence_score FLOAT CHECK (confidence_score >= 0 AND confidence_score <= 100),

    -- For future vector search integration
    embedding_model TEXT, -- Track which model was used
    embedding_dimension INTEGER,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_agent_research_source ON agent_research_knowledge(source_type, source_id);
CREATE INDEX idx_agent_research_biomarkers ON agent_research_knowledge USING gin(relevant_biomarkers);
CREATE INDEX idx_agent_research_biometrics ON agent_research_knowledge USING gin(relevant_biometrics);

-- ============================================
-- NEW: RECOMMENDATION OUTCOME LEARNING
-- ============================================

CREATE TABLE IF NOT EXISTS agent_recommendation_outcomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    recommendation_id UUID NOT NULL REFERENCES recommendations_base(id) ON DELETE CASCADE,

    -- Adherence period
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    average_adherence FLOAT NOT NULL CHECK (average_adherence >= 0 AND average_adherence <= 100),

    -- Measured outcomes (from patient_biomarker_readings and patient_biometric_readings)
    biomarker_changes JSONB,
    /* Example:
    {
      "LDL": {"before": 150, "after": 130, "change": -20, "unit": "mg/dL"},
      "HbA1c": {"before": 6.2, "after": 5.8, "change": -0.4, "unit": "%"}
    }
    */

    biometric_changes JSONB,
    /* Example:
    {
      "BMI": {"before": 28.5, "after": 27.2, "change": -1.3},
      "Blood Pressure (Systolic)": {"before": 135, "after": 125, "change": -10}
    }
    */

    -- Context
    confounding_factors JSONB, -- Other active recommendations, life events
    confidence_in_attribution FLOAT CHECK (confidence_in_attribution >= 0 AND confidence_in_attribution <= 100),

    -- Agent analysis
    agent_analysis TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_agent_outcomes_patient ON agent_recommendation_outcomes(patient_id, start_date, end_date);
CREATE INDEX idx_agent_outcomes_rec ON agent_recommendation_outcomes(recommendation_id);

-- ============================================
-- NEW: AGENT EXECUTION LOG
-- ============================================

CREATE TABLE IF NOT EXISTS agent_execution_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES patients(patient_id) ON DELETE CASCADE,
    agent_type TEXT NOT NULL CHECK (agent_type IN ('adherence_evaluator', 'nudge_generator', 'challenge_creator', 'context_analyzer', 'outcome_learner')),

    -- Execution details
    execution_date TIMESTAMPTZ DEFAULT NOW(),
    duration_ms INTEGER,
    status TEXT CHECK (status IN ('success', 'partial_success', 'failure')),

    -- Context
    input_data JSONB,
    output_data JSONB,
    error_message TEXT,

    -- Token usage (for cost tracking)
    tokens_used INTEGER,
    model_version TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_agent_log_patient ON agent_execution_log(patient_id, execution_date);
CREATE INDEX idx_agent_log_type ON agent_execution_log(agent_type, execution_date);
CREATE INDEX idx_agent_log_status ON agent_execution_log(status) WHERE status = 'failure';

-- ============================================
-- UPDATED_AT TRIGGERS
-- ============================================

CREATE TRIGGER update_agent_adherence_scores_updated_at BEFORE UPDATE ON agent_adherence_scores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agent_pillar_scores_updated_at BEFORE UPDATE ON agent_pillar_scores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agent_overall_scores_updated_at BEFORE UPDATE ON agent_overall_scores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_patient_modes_updated_at BEFORE UPDATE ON patient_modes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agent_challenges_updated_at BEFORE UPDATE ON agent_challenges
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agent_user_context_updated_at BEFORE UPDATE ON agent_user_context
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agent_research_knowledge_updated_at BEFORE UPDATE ON agent_research_knowledge
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- HELPER FUNCTION: GET ACTIVE USER MODE
-- ============================================

CREATE OR REPLACE FUNCTION get_active_patient_mode(p_patient_id UUID, p_date DATE DEFAULT CURRENT_DATE)
RETURNS TABLE (
    mode_id UUID,
    mode_type TEXT,
    mode_config JSONB,
    notes TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        pm.id,
        pm.mode_type,
        pm.mode_config,
        pm.notes
    FROM patient_modes pm
    WHERE pm.patient_id = p_patient_id
      AND pm.start_date <= p_date
      AND (pm.end_date IS NULL OR pm.end_date >= p_date)
      AND pm.is_active = true
    ORDER BY pm.start_date DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================

COMMENT ON TABLE agent_adherence_scores IS 'Daily adherence scores per recommendation calculated by AI agent';
COMMENT ON TABLE agent_pillar_scores IS 'Aggregated pillar-level adherence scores';
COMMENT ON TABLE agent_overall_scores IS 'Overall daily adherence score combining all pillars';
COMMENT ON TABLE patient_modes IS 'User modes (travel, injury, illness) that adjust agent behavior and scoring';
COMMENT ON TABLE agent_nudges IS 'AI-generated personalized nudges and reminders';
COMMENT ON TABLE agent_challenges IS 'AI-generated bite-sized challenges for specific situations';
COMMENT ON TABLE agent_user_context IS 'Aggregated user context for personalized agent decision-making';
COMMENT ON TABLE agent_research_knowledge IS 'Evidence-based research knowledge base';
COMMENT ON TABLE agent_recommendation_outcomes IS 'Learning system tracking recommendation impact on biomarkers and biometrics';
COMMENT ON TABLE agent_execution_log IS 'Audit log of all agent executions for debugging and cost tracking';
