-- WellPath Agentic Adherence System - Database Schema
-- Migration for agentic adherence tracking system

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- CORE RECOMMENDATIONS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS recommendations (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    goal TEXT NOT NULL, -- Natural language goal like "Get 10,000 steps daily"

    -- Optional hints for edge cases (usually empty)
    agent_context JSONB DEFAULT '{}',

    -- Metadata
    pillar TEXT NOT NULL, -- 'movement', 'nutrition', 'sleep', 'stress', 'mindfulness', etc.
    difficulty_level INTEGER DEFAULT 1, -- 1=beginner, 2=intermediate, 3=advanced
    requires_equipment BOOLEAN DEFAULT false,
    requires_medical_clearance BOOLEAN DEFAULT false,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- DAILY ADHERENCE SCORES (HIERARCHICAL)
-- ============================================

-- Individual recommendation scores
CREATE TABLE IF NOT EXISTS daily_adherence_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    recommendation_id TEXT REFERENCES recommendations(id) ON DELETE CASCADE,
    score_date DATE NOT NULL,

    -- Individual recommendation score
    adherence_percentage FLOAT NOT NULL CHECK (adherence_percentage >= 0 AND adherence_percentage <= 100),
    score_quality TEXT CHECK (score_quality IN ('measured', 'estimated', 'partial_data', 'no_data')),
    data_sources_used TEXT[], -- ['healthkit', 'manual_entry', etc.]

    -- Agent reasoning
    calculation_reasoning TEXT,
    adjustments_applied JSONB,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, recommendation_id, score_date)
);

CREATE INDEX idx_daily_adherence_user_date ON daily_adherence_scores(user_id, score_date);
CREATE INDEX idx_daily_adherence_rec ON daily_adherence_scores(recommendation_id, score_date);

-- Pillar-level aggregated scores
CREATE TABLE IF NOT EXISTS daily_pillar_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    pillar TEXT NOT NULL,
    score_date DATE NOT NULL,

    -- Pillar-level aggregation
    adherence_percentage FLOAT NOT NULL CHECK (adherence_percentage >= 0 AND adherence_percentage <= 100),
    active_recommendations INTEGER DEFAULT 0,
    recommendations_scored INTEGER DEFAULT 0,

    -- Component scores for transparency
    component_scores JSONB,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, pillar, score_date)
);

CREATE INDEX idx_daily_pillar_user_pillar_date ON daily_pillar_scores(user_id, pillar, score_date);

-- Overall daily adherence score
CREATE TABLE IF NOT EXISTS daily_overall_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
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

    UNIQUE(user_id, score_date)
);

CREATE INDEX idx_daily_overall_user_date ON daily_overall_scores(user_id, score_date);

-- ============================================
-- USER MODES FOR CONTEXTUAL ADJUSTMENTS
-- ============================================

CREATE TABLE IF NOT EXISTS user_modes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    mode_type TEXT NOT NULL, -- 'travel', 'injury', 'illness', 'high_stress', etc.

    -- Mode configuration
    start_date DATE NOT NULL,
    end_date DATE, -- NULL if ongoing

    -- Mode-specific adjustments
    mode_config JSONB,

    -- User notes
    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_modes_user_active ON user_modes(user_id, start_date, end_date) WHERE end_date IS NULL;
CREATE INDEX idx_user_modes_user_date_range ON user_modes(user_id, start_date, end_date);

-- ============================================
-- USER'S ACTIVE RECOMMENDATIONS
-- ============================================

CREATE TABLE IF NOT EXISTS user_recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    recommendation_id TEXT REFERENCES recommendations(id) ON DELETE CASCADE,

    -- Status
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed', 'abandoned')),

    -- Dates
    started_at DATE NOT NULL,
    paused_at DATE,
    completed_at DATE,

    -- Personalization
    personal_target JSONB,
    personal_notes TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, recommendation_id)
);

CREATE INDEX idx_user_recs_user_status ON user_recommendations(user_id, status);
CREATE INDEX idx_user_recs_user_active ON user_recommendations(user_id) WHERE status = 'active';

-- ============================================
-- AGENT EVALUATION HISTORY
-- ============================================

CREATE TABLE IF NOT EXISTS adherence_evaluations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    recommendation_id TEXT REFERENCES recommendations(id) ON DELETE CASCADE,
    evaluation_date DATE NOT NULL,

    -- Core scoring
    adherence_score FLOAT NOT NULL CHECK (adherence_score >= 0 AND adherence_score <= 100),
    confidence_score FLOAT NOT NULL CHECK (confidence_score >= 0 AND confidence_score <= 100),

    -- Agent reasoning (for debugging and transparency)
    evaluation_reasoning TEXT,
    data_sources_used JSONB,
    context_factors JSONB,

    -- Adjustments made
    base_score FLOAT,
    adjustments_applied JSONB,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_adherence_eval_user_date ON adherence_evaluations(user_id, evaluation_date);
CREATE INDEX idx_adherence_eval_rec_date ON adherence_evaluations(recommendation_id, evaluation_date);

-- ============================================
-- INTELLIGENT NUDGES
-- ============================================

CREATE TABLE IF NOT EXISTS agent_nudges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    recommendation_id TEXT REFERENCES recommendations(id) ON DELETE CASCADE,

    -- Nudge content
    message TEXT NOT NULL,
    tone TEXT CHECK (tone IN ('encouraging', 'educational', 'celebratory', 'supportive', 'motivational')),
    nudge_type TEXT CHECK (nudge_type IN ('adherence_support', 'milestone', 'insight', 'reminder', 'celebration')),

    -- Agent decision making
    trigger_reason JSONB,
    personalization_factors JSONB,

    -- Delivery and response
    scheduled_for TIMESTAMPTZ NOT NULL,
    delivered_at TIMESTAMPTZ,
    user_response TEXT CHECK (user_response IN ('helpful', 'not_helpful', 'dismissed', NULL)),

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_agent_nudges_user_scheduled ON agent_nudges(user_id, scheduled_for);
CREATE INDEX idx_agent_nudges_pending ON agent_nudges(user_id, scheduled_for) WHERE delivered_at IS NULL;

-- ============================================
-- KNOWLEDGE BASE FOR EVIDENCE
-- ============================================

CREATE TABLE IF NOT EXISTS research_knowledge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Source information
    source_type TEXT NOT NULL CHECK (source_type IN ('pubmed', 'clinical_trial', 'meta_analysis', 'review', 'other')),
    source_id TEXT,
    title TEXT NOT NULL,
    authors TEXT[],
    publication_date DATE,
    journal TEXT,

    -- Content
    abstract TEXT,
    full_text TEXT,
    key_findings JSONB,

    -- Relevance mapping
    relevant_biomarkers TEXT[],
    relevant_interventions TEXT[],
    population_characteristics JSONB,

    -- Quality scoring
    evidence_level TEXT CHECK (evidence_level IN ('high', 'moderate', 'low')),
    study_design TEXT,
    sample_size INTEGER,
    confidence_score FLOAT CHECK (confidence_score >= 0 AND confidence_score <= 100),

    -- Vector embedding for similarity search (to be added when pgvector is enabled)
    -- embedding VECTOR(1536),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_research_knowledge_source ON research_knowledge(source_type, source_id);
CREATE INDEX idx_research_knowledge_biomarkers ON research_knowledge USING gin(relevant_biomarkers);

-- ============================================
-- RECOMMENDATION OUTCOMES LEARNING
-- ============================================

CREATE TABLE IF NOT EXISTS recommendation_outcomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recommendation_id TEXT REFERENCES recommendations(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,

    -- Adherence period
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    average_adherence FLOAT NOT NULL CHECK (average_adherence >= 0 AND average_adherence <= 100),

    -- Measured outcomes
    biomarker_changes JSONB,

    -- Context
    confounding_factors JSONB,
    confidence_in_attribution FLOAT CHECK (confidence_in_attribution >= 0 AND confidence_in_attribution <= 100),

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_rec_outcomes_rec ON recommendation_outcomes(recommendation_id);
CREATE INDEX idx_rec_outcomes_user ON recommendation_outcomes(user_id, start_date, end_date);

-- ============================================
-- RECOMMENDATION EVIDENCE LINKS
-- ============================================

CREATE TABLE IF NOT EXISTS recommendation_evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recommendation_id TEXT REFERENCES recommendations(id) ON DELETE CASCADE,
    biomarker TEXT NOT NULL,
    expected_impact TEXT,
    observed_impact FLOAT,
    confidence FLOAT CHECK (confidence >= 0 AND confidence <= 100),
    source_research_ids UUID[],

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_rec_evidence_rec ON recommendation_evidence(recommendation_id);
CREATE INDEX idx_rec_evidence_biomarker ON recommendation_evidence(biomarker);

-- ============================================
-- USER CONTEXT FOR AGENT DECISIONS
-- ============================================

CREATE TABLE IF NOT EXISTS user_context (
    user_id TEXT PRIMARY KEY,

    -- Current state
    active_recommendations TEXT[],
    current_health_focus TEXT[],
    recent_life_events JSONB,

    -- Behavioral patterns
    best_engagement_times JSONB,
    message_preferences JSONB,
    historical_adherence_patterns JSONB,

    -- Capacity assessment
    current_capacity_score FLOAT CHECK (current_capacity_score >= 0 AND current_capacity_score <= 100),
    capacity_factors JSONB,

    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- UPDATED_AT TRIGGERS
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_recommendations_updated_at BEFORE UPDATE ON recommendations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_adherence_scores_updated_at BEFORE UPDATE ON daily_adherence_scores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_pillar_scores_updated_at BEFORE UPDATE ON daily_pillar_scores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_overall_scores_updated_at BEFORE UPDATE ON daily_overall_scores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_modes_updated_at BEFORE UPDATE ON user_modes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_recommendations_updated_at BEFORE UPDATE ON user_recommendations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_research_knowledge_updated_at BEFORE UPDATE ON research_knowledge
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recommendation_evidence_updated_at BEFORE UPDATE ON recommendation_evidence
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_context_updated_at BEFORE UPDATE ON user_context
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SAMPLE DATA (OPTIONAL)
-- ============================================

-- Insert sample recommendations
INSERT INTO recommendations (id, name, description, goal, pillar, difficulty_level) VALUES
    ('steps_10k', '10,000 Steps Daily', 'Walk at least 10,000 steps each day for cardiovascular health', 'Get 10,000 steps daily', 'movement', 1),
    ('sleep_7-9h', '7-9 Hours Sleep', 'Maintain consistent sleep duration between 7-9 hours', 'Sleep 7-9 hours each night', 'sleep', 1),
    ('vegetables_5', '5 Vegetable Servings', 'Eat at least 5 servings of vegetables daily', 'Eat 5 servings of vegetables daily', 'nutrition', 1),
    ('alcohol_limit', 'Limit Alcohol', 'Reduce alcohol consumption to no more than 2 drinks per week', 'Limit alcohol to 2 drinks per week', 'nutrition', 2),
    ('meditation_10min', 'Daily Meditation', 'Practice mindfulness meditation for 10 minutes each day', 'Meditate for 10 minutes daily', 'mindfulness', 1),
    ('strength_3x', 'Strength Training', 'Complete strength training workouts 3 times per week', 'Strength training 3 times per week', 'movement', 2),
    ('water_8glass', 'Hydration Goal', 'Drink at least 8 glasses (64oz) of water daily', 'Drink 8 glasses of water daily', 'nutrition', 1)
ON CONFLICT (id) DO NOTHING;

COMMENT ON TABLE recommendations IS 'Core recommendations library with natural language goals that the agent automatically interprets';
COMMENT ON TABLE daily_adherence_scores IS 'Individual recommendation adherence scores per user per day';
COMMENT ON TABLE daily_pillar_scores IS 'Aggregated pillar-level scores (movement, nutrition, sleep, etc.) per user per day';
COMMENT ON TABLE daily_overall_scores IS 'Overall daily adherence score aggregating all pillars per user';
COMMENT ON TABLE user_modes IS 'User modes (travel, injury, illness) that adjust scoring expectations';
COMMENT ON TABLE user_recommendations IS 'Active recommendations assigned to each user with personalization';
COMMENT ON TABLE adherence_evaluations IS 'Detailed agent evaluation history with reasoning for transparency';
COMMENT ON TABLE agent_nudges IS 'AI-generated personalized nudges and reminders';
COMMENT ON TABLE research_knowledge IS 'Evidence-based research knowledge base for supporting recommendations';
COMMENT ON TABLE recommendation_outcomes IS 'Learning system tracking recommendation impact on biomarkers';
COMMENT ON TABLE recommendation_evidence IS 'Links between recommendations and evidence from research';
COMMENT ON TABLE user_context IS 'Aggregated user context for personalized agent decision-making';
