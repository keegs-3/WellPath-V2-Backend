-- =====================================================
-- WellPath Score UI Architecture
-- Mirrors the tracking system pattern: display_sections → display_items → patient_data
-- =====================================================

-- =====================================================
-- 1. DISPLAY SECTIONS (like display_screens)
-- Defines the UI hierarchy and organization
-- =====================================================
CREATE TABLE wellpath_score_display_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Hierarchy
    section_key TEXT UNIQUE NOT NULL,
    parent_section_key TEXT REFERENCES wellpath_score_display_sections(section_key) ON DELETE CASCADE,
    display_order INTEGER NOT NULL,
    depth_level INTEGER NOT NULL,  -- 0=top level, 1=sub-section, 2=sub-sub-section

    -- Display info
    display_name TEXT NOT NULL,
    icon TEXT,
    description TEXT,

    -- Section type
    section_type TEXT NOT NULL CHECK (section_type IN (
        'pillar',           -- One of the 7 pillars
        'category',         -- Category within a pillar (e.g., Biomarkers, Screenings)
        'function_group',   -- Group of related functions (e.g., Substances)
        'individual_item'   -- Single item (e.g., Alcohol)
    )),

    -- Aggregation logic (how to calculate this section's score)
    aggregation_type TEXT CHECK (aggregation_type IN (
        'pillar_component',  -- Sum all items from a pillar component
        'function_rollup',   -- Roll up multiple functions
        'weighted_average',  -- Weighted average of subsections
        'sum',               -- Simple sum
        'custom'             -- Custom calculation
    )),
    aggregation_source JSONB,

    -- Content
    quick_tips JSONB,
    longevity_impact TEXT,
    learn_more_url TEXT,

    -- Metadata
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_display_sections_parent ON wellpath_score_display_sections(parent_section_key);
CREATE INDEX idx_display_sections_order ON wellpath_score_display_sections(display_order);
CREATE INDEX idx_display_sections_active ON wellpath_score_display_sections(is_active) WHERE is_active = TRUE;

-- =====================================================
-- 2. DISPLAY ITEMS (like display_metrics)
-- Defines individual items within sections
-- =====================================================
CREATE TABLE wellpath_score_display_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Parent section
    section_key TEXT NOT NULL REFERENCES wellpath_score_display_sections(section_key) ON DELETE CASCADE,
    display_order INTEGER NOT NULL,

    -- What item is this?
    item_type TEXT NOT NULL CHECK (item_type IN (
        'biomarker',
        'biometric',
        'survey_question',
        'survey_function'
    )),
    item_id TEXT NOT NULL,  -- biomarker name, question number, or function name

    -- Display info
    display_name TEXT NOT NULL,
    subtitle TEXT,
    icon TEXT,

    -- Content
    description TEXT,
    longevity_impact TEXT,
    quick_tips JSONB,
    learn_more_url TEXT,

    -- Link to detailed chart (for biomarkers/biometrics)
    has_chart BOOLEAN DEFAULT FALSE,
    chart_screen_key TEXT,

    -- Show alternative scores? (for survey questions)
    show_alternative_responses BOOLEAN DEFAULT FALSE,

    -- Metadata
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(section_key, item_id)
);

CREATE INDEX idx_display_items_section ON wellpath_score_display_items(section_key);
CREATE INDEX idx_display_items_type ON wellpath_score_display_items(item_type);
CREATE INDEX idx_display_items_order ON wellpath_score_display_items(section_key, display_order);

-- =====================================================
-- 3. QUESTION CONTENT
-- Additional content for survey questions
-- =====================================================
CREATE TABLE wellpath_score_question_content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_number TEXT NOT NULL UNIQUE,

    -- General question content
    explanation TEXT,
    why_it_matters TEXT,
    longevity_impact TEXT,

    -- Response-specific content (maps response text to content)
    response_content JSONB,
    /* Example structure:
    {
      "Never": {
        "score": 1.0,
        "longevity_impact": "Avoiding alcohol completely can add 2-3 years to your lifespan",
        "tips": ["Keep up the great work!", "Consider being a designated driver"],
        "severity": "optimal"
      },
      "Heavy (15+ drinks per week)": {
        "score": 0.0,
        "longevity_impact": "Heavy drinking can reduce lifespan by 5-10 years",
        "tips": ["Consider speaking with a healthcare provider", "Join a support group"],
        "severity": "critical",
        "resources": ["https://www.samhsa.gov/find-help/national-helpline"]
      }
    }
    */

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_question_content_number ON wellpath_score_question_content(question_number);

-- =====================================================
-- 4. PATIENT SCORE DISPLAY DATA
-- The main table the app queries - combines scoring + config
-- =====================================================
CREATE TABLE patient_wellpath_score_display (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Overall score (denormalized for quick access)
    overall_score DECIMAL(5,4) NOT NULL,
    calculated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Section scores (calculated based on display_sections config)
    section_scores JSONB NOT NULL DEFAULT '{}'::jsonb,
    /* Example structure:
    {
      "behaviors": {
        "score": 45.2,
        "max": 100.0,
        "percentage": 45.2,
        "items_count": 25,
        "subsections": ["behaviors_substances", "behaviors_movement"]
      },
      "behaviors_substances": {
        "score": 18.5,
        "max": 40.0,
        "percentage": 46.25,
        "items_count": 6,
        "subsections": ["behaviors_substances_alcohol", "behaviors_substances_tobacco"]
      }
    }
    */

    -- Individual item scores with patient's actual data
    item_scores JSONB NOT NULL DEFAULT '[]'::jsonb,
    /* Example structure:
    [
      {
        "section_key": "behaviors_substances_alcohol",
        "item_type": "survey_function",
        "item_id": "substance_alcohol_score",
        "display_name": "Alcohol",
        "patient_score": 0.6,
        "max_score": 1.0,
        "weight": 8,
        "weighted_score": 4.8,
        "patient_data": {
          "questions": [
            {"q": "8.05", "answer": "1-2 drinks per week", "score": 0.8}
          ]
        },
        "content": {
          "tips": ["Limit to 1-2 drinks per day", "Have alcohol-free days"],
          "longevity_impact": "Light drinking has minimal impact on longevity"
        }
      }
    ]
    */

    -- Metadata
    calculation_version TEXT DEFAULT '1.0',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_patient_score_display_user ON patient_wellpath_score_display(user_id, calculated_at DESC);
CREATE INDEX idx_patient_score_display_calculated ON patient_wellpath_score_display(calculated_at DESC);

-- GIN indexes for JSONB querying
CREATE INDEX idx_patient_score_display_sections ON patient_wellpath_score_display USING GIN (section_scores);
CREATE INDEX idx_patient_score_display_items ON patient_wellpath_score_display USING GIN (item_scores);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Get latest score display for a user
CREATE OR REPLACE FUNCTION get_latest_score_display(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'overall_score', overall_score,
        'section_scores', section_scores,
        'item_scores', item_scores,
        'calculated_at', calculated_at
    )
    INTO result
    FROM patient_wellpath_score_display
    WHERE user_id = p_user_id
    ORDER BY calculated_at DESC
    LIMIT 1;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Get section hierarchy (all sections under a parent, with scores)
CREATE OR REPLACE FUNCTION get_section_hierarchy(
    p_user_id UUID,
    p_parent_section_key TEXT DEFAULT NULL
)
RETURNS TABLE (
    section_key TEXT,
    display_name TEXT,
    icon TEXT,
    description TEXT,
    display_order INTEGER,
    score JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.section_key,
        s.display_name,
        s.icon,
        s.description,
        s.display_order,
        p.section_scores -> s.section_key as score
    FROM wellpath_score_display_sections s
    LEFT JOIN (
        SELECT section_scores
        FROM patient_wellpath_score_display
        WHERE user_id = p_user_id
        ORDER BY calculated_at DESC
        LIMIT 1
    ) p ON TRUE
    WHERE s.parent_section_key IS NOT DISTINCT FROM p_parent_section_key
      AND s.is_active = TRUE
    ORDER BY s.display_order;
END;
$$ LANGUAGE plpgsql;

-- Get items for a section (with patient scores)
CREATE OR REPLACE FUNCTION get_section_items(
    p_user_id UUID,
    p_section_key TEXT
)
RETURNS TABLE (
    item_id TEXT,
    item_type TEXT,
    display_name TEXT,
    description TEXT,
    patient_score JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        di.item_id,
        di.item_type,
        di.display_name,
        di.description,
        item_data.item_score
    FROM wellpath_score_display_items di
    LEFT JOIN (
        SELECT jsonb_array_elements(item_scores) as item_score
        FROM patient_wellpath_score_display
        WHERE user_id = p_user_id
        ORDER BY calculated_at DESC
        LIMIT 1
    ) item_data ON item_data.item_score->>'item_id' = di.item_id
    WHERE di.section_key = p_section_key
      AND di.is_active = TRUE
    ORDER BY di.display_order;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- GRANTS
-- =====================================================
GRANT SELECT ON wellpath_score_display_sections TO authenticated, anon;
GRANT SELECT ON wellpath_score_display_items TO authenticated, anon;
GRANT SELECT ON wellpath_score_question_content TO authenticated, anon;
GRANT SELECT ON patient_wellpath_score_display TO authenticated, service_role;

-- =====================================================
-- COMMENTS
-- =====================================================
COMMENT ON TABLE wellpath_score_display_sections IS 'Defines the UI hierarchy and organization for WellPath scores (like display_screens for tracking)';
COMMENT ON TABLE wellpath_score_display_items IS 'Defines individual items within sections (like display_metrics for tracking)';
COMMENT ON TABLE wellpath_score_question_content IS 'Content and tips for survey questions, including alternative response information';
COMMENT ON TABLE patient_wellpath_score_display IS 'Main table for app queries - combines calculated scores with UI config and content for each patient';
