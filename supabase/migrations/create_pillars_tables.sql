-- =====================================================
-- CREATE PILLARS AND PILLAR_SCORES TABLES
-- =====================================================

-- 1. Create pillars table
CREATE TABLE IF NOT EXISTS pillars (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    short_name VARCHAR(50),
    description TEXT,
    color VARCHAR(50),
    icon_url VARCHAR(255),
    display_order INTEGER,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create pillar_scores table
CREATE TABLE IF NOT EXISTS pillar_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL,
    pillar_id UUID NOT NULL REFERENCES pillars(id) ON DELETE CASCADE,
    score NUMERIC(5,2) NOT NULL CHECK (score >= 0 AND score <= 100),
    max_score NUMERIC(5,2) DEFAULT 100,
    percentage NUMERIC(5,2),
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Foreign key to patient_details
    CONSTRAINT fk_pillar_scores_patient FOREIGN KEY (patient_id) REFERENCES patient_details(id) ON DELETE CASCADE,

    -- Unique constraint: one score per patient per pillar per day
    CONSTRAINT unique_patient_pillar_date UNIQUE (patient_id, pillar_id, DATE(recorded_at))
);

-- 3. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_pillar_scores_patient ON pillar_scores(patient_id);
CREATE INDEX IF NOT EXISTS idx_pillar_scores_pillar ON pillar_scores(pillar_id);
CREATE INDEX IF NOT EXISTS idx_pillar_scores_recorded_at ON pillar_scores(recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_pillar_scores_patient_pillar ON pillar_scores(patient_id, pillar_id, recorded_at DESC);

-- 4. Insert the 7 WellPath pillars
INSERT INTO pillars (name, short_name, color, display_order) VALUES
  ('Healthful Nutrition', 'Nutrition', '#FF6B6B', 1),
  ('Movement & Exercise', 'Exercise', '#4ECDC4', 2),
  ('Restorative Sleep', 'Sleep', '#95E1D3', 3),
  ('Stress Management', 'Stress', '#F38181', 4),
  ('Connection & Purpose', 'Social', '#AA96DA', 5),
  ('Cognitive Health', 'Mental', '#FCBAD3', 6),
  ('Core Care', 'Preventive', '#FFFFD2', 7)
ON CONFLICT (name) DO NOTHING;

-- 5. Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_pillars_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_pillars_updated_at ON pillars;
CREATE TRIGGER trigger_update_pillars_updated_at
    BEFORE UPDATE ON pillars
    FOR EACH ROW
    EXECUTE FUNCTION update_pillars_updated_at();

-- Verify
SELECT '✅ Pillars and pillar_scores tables created!' as status;
SELECT 'Pillars:' as info, COUNT(*) as count FROM pillars;
