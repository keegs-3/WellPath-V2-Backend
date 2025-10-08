-- =====================================================
-- CREATE PILLAR_SCORES TABLE (compatible with existing pillars table)
-- =====================================================

-- Create pillar_scores table
CREATE TABLE IF NOT EXISTS pillar_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL,
    pillar_id TEXT NOT NULL REFERENCES pillars(record_id) ON DELETE CASCADE,
    score NUMERIC(5,2) NOT NULL CHECK (score >= 0 AND score <= 100),
    max_score NUMERIC(5,2) DEFAULT 100,
    percentage NUMERIC(5,2),
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Foreign key to patient_details
    CONSTRAINT fk_pillar_scores_patient FOREIGN KEY (patient_id) REFERENCES patient_details(id) ON DELETE CASCADE
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_pillar_scores_patient ON pillar_scores(patient_id);
CREATE INDEX IF NOT EXISTS idx_pillar_scores_pillar ON pillar_scores(pillar_id);
CREATE INDEX IF NOT EXISTS idx_pillar_scores_recorded_at ON pillar_scores(recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_pillar_scores_patient_pillar ON pillar_scores(patient_id, pillar_id, recorded_at DESC);

-- Verify
SELECT '✅ pillar_scores table created!' as status;
SELECT 'Existing pillars count:' as info, COUNT(*) as count FROM pillars;
