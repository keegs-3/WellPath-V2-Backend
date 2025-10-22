-- Create table to store detailed WellPath score breakdowns
CREATE TABLE IF NOT EXISTS wellpath_score_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Overall score
    overall_score DECIMAL(5,4) NOT NULL,  -- 0.0000 to 1.0000

    -- Pillar scores (JSONB for flexibility)
    pillar_scores JSONB NOT NULL,

    -- Individual item scores (biomarkers, biometrics, questions, functions)
    scored_items JSONB NOT NULL,

    -- Metadata
    calculated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    calculation_version TEXT DEFAULT '1.0',

    -- Indexes
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_score_details_user_id ON wellpath_score_details(user_id);
CREATE INDEX idx_score_details_calculated_at ON wellpath_score_details(calculated_at DESC);
CREATE INDEX idx_score_details_user_latest ON wellpath_score_details(user_id, calculated_at DESC);

-- GIN index for JSONB querying
CREATE INDEX idx_score_details_pillar_scores ON wellpath_score_details USING GIN (pillar_scores);
CREATE INDEX idx_score_details_scored_items ON wellpath_score_details USING GIN (scored_items);

-- Function to get latest score details for a user
CREATE OR REPLACE FUNCTION get_latest_score_details(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'overall_score', overall_score,
        'pillar_scores', pillar_scores,
        'scored_items', scored_items,
        'calculated_at', calculated_at
    )
    INTO result
    FROM wellpath_score_details
    WHERE user_id = p_user_id
    ORDER BY calculated_at DESC
    LIMIT 1;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to get pillar breakdown for a user
CREATE OR REPLACE FUNCTION get_pillar_breakdown(p_user_id UUID, p_pillar_name TEXT)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT pillar_scores -> p_pillar_name
    INTO result
    FROM wellpath_score_details
    WHERE user_id = p_user_id
    ORDER BY calculated_at DESC
    LIMIT 1;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to get all scored items for a specific category (biomarkers, biometrics, questions, functions)
CREATE OR REPLACE FUNCTION get_scored_items_by_type(
    p_user_id UUID,
    p_item_type TEXT  -- 'biomarker', 'biometric', 'survey_question', 'survey_function'
)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_agg(item)
    INTO result
    FROM (
        SELECT jsonb_array_elements(scored_items) as item
        FROM wellpath_score_details
        WHERE user_id = p_user_id
        ORDER BY calculated_at DESC
        LIMIT 1
    ) items
    WHERE item->>'item_type' = p_item_type;

    RETURN COALESCE(result, '[]'::jsonb);
END;
$$ LANGUAGE plpgsql;

-- Function to get scored items for a specific pillar
CREATE OR REPLACE FUNCTION get_pillar_items(
    p_user_id UUID,
    p_pillar_name TEXT
)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_agg(item)
    INTO result
    FROM (
        SELECT jsonb_array_elements(scored_items) as item
        FROM wellpath_score_details
        WHERE user_id = p_user_id
        ORDER BY calculated_at DESC
        LIMIT 1
    ) items
    WHERE item->'pillar_contributions'->0->>'pillar_name' = p_pillar_name;

    RETURN COALESCE(result, '[]'::jsonb);
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE wellpath_score_details IS 'Stores detailed WellPath score breakdowns for each patient calculation';
COMMENT ON COLUMN wellpath_score_details.pillar_scores IS 'JSONB structure: { "Pillar Name": { "final_score": 0.xx, "markers_score": x, "markers_max": y, ... } }';
COMMENT ON COLUMN wellpath_score_details.scored_items IS 'JSONB array of all scored items with their normalized scores and pillar contributions';
