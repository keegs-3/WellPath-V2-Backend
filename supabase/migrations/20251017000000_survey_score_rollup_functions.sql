-- =====================================================
-- Survey Score Rollup Functions
-- =====================================================
-- Creates functions to aggregate survey scores through
-- the hierarchy: Questions → Groups → Categories → Sections
-- =====================================================

BEGIN;

-- =====================================================
-- Function: Get Patient Survey Scores at All Levels
-- =====================================================
-- Returns survey scores aggregated at question, group,
-- category, and section levels for a patient

CREATE OR REPLACE FUNCTION get_patient_survey_rollup(p_user_id UUID)
RETURNS TABLE (
    -- Question level
    question_id UUID,
    question_number TEXT,
    question_text TEXT,
    patient_response JSONB,
    question_score NUMERIC,

    -- Group level
    group_id TEXT,
    group_name TEXT,
    group_score NUMERIC,
    group_question_count INTEGER,

    -- Category level
    category_id TEXT,
    category_name TEXT,
    category_score NUMERIC,
    category_group_count INTEGER,

    -- Section level (= Pillar)
    section_id TEXT,
    section_name TEXT,
    section_score NUMERIC,
    section_category_count INTEGER,

    -- Pillar mapping
    pillar_id TEXT,
    pillar_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH
    -- Step 1: Get all question scores for this patient
    question_scores AS (
        SELECT
            sqb.id as q_id,
            sqb.question_number as q_number,
            sqb.question_text as q_text,
            psr.response_value as p_response,
            sqb.group_id as q_group_id,
            -- For now, return NULL for score - will implement scoring logic later
            NULL::NUMERIC as q_score
        FROM patient_survey_responses psr
        JOIN survey_questions_base sqb ON psr.question_id = sqb.id
        WHERE psr.user_id = p_user_id
    ),

    -- Step 2: Aggregate to group level
    group_scores AS (
        SELECT
            qs.q_group_id as g_id,
            AVG(qs.q_score) as g_score,
            COUNT(*) as g_question_count
        FROM question_scores qs
        WHERE qs.q_score IS NOT NULL
        GROUP BY qs.q_group_id
    ),

    -- Step 3: Aggregate to category level
    category_scores AS (
        SELECT
            sg.category_id as c_id,
            AVG(gs.g_score) as c_score,
            COUNT(DISTINCT gs.g_id) as c_group_count
        FROM group_scores gs
        JOIN survey_groups sg ON gs.g_id = sg.group_id
        GROUP BY sg.category_id
    ),

    -- Step 4: Aggregate to section level
    section_scores AS (
        SELECT
            sc.section_id as s_id,
            AVG(cs.c_score) as s_score,
            COUNT(DISTINCT cs.c_id) as s_category_count
        FROM category_scores cs
        JOIN survey_categories sc ON cs.c_id = sc.category_id
        GROUP BY sc.section_id
    )

    -- Final query: Join all levels together
    SELECT
        -- Question level
        qs.q_id,
        qs.q_number,
        qs.q_text,
        qs.p_response,
        qs.q_score,

        -- Group level
        sg.group_id,
        sg.display_name as group_name,
        gs.g_score,
        gs.g_question_count::INTEGER,

        -- Category level
        sc.category_id,
        sc.display_name as category_name,
        cs.c_score,
        cs.c_group_count::INTEGER,

        -- Section level
        ss.section_id,
        ss.display_name as section_name,
        ses.s_score,
        ses.s_category_count::INTEGER,

        -- Pillar mapping
        pb.pillar_id,
        pb.pillar_name

    FROM question_scores qs
    LEFT JOIN survey_questions_base sqb ON qs.q_id = sqb.id
    LEFT JOIN survey_groups sg ON qs.q_group_id = sg.group_id
    LEFT JOIN group_scores gs ON sg.group_id = gs.g_id
    LEFT JOIN survey_categories sc ON sg.category_id = sc.category_id
    LEFT JOIN category_scores cs ON sc.category_id = cs.c_id
    LEFT JOIN survey_sections ss ON sc.section_id = ss.section_id
    LEFT JOIN section_scores ses ON ss.section_id = ses.s_id
    LEFT JOIN pillars_base pb ON ss.pillar = pb.pillar_name
    ORDER BY sqb.question_number;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_patient_survey_rollup IS
'Returns survey responses and scores at all hierarchy levels (question, group, category, section/pillar) for a given patient. Currently returns NULL for scores - scoring logic to be implemented.';


-- =====================================================
-- Function: Get Section Hierarchy for Patient
-- =====================================================
-- Returns the complete section → category → group hierarchy
-- with aggregated scores for a patient

CREATE OR REPLACE FUNCTION get_section_hierarchy(
    p_user_id UUID,
    p_section_id TEXT DEFAULT NULL
)
RETURNS TABLE (
    section_key TEXT,
    display_name TEXT,
    icon TEXT,
    description TEXT,
    section_score NUMERIC,
    hierarchy_level INTEGER,
    parent_key TEXT,
    category_count INTEGER,
    group_count INTEGER,
    question_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    -- Top level: Sections
    SELECT
        ss.section_id as section_key,
        ss.display_name,
        pb.icon,
        ss.description,
        NULL::NUMERIC as section_score, -- To be calculated
        1 as hierarchy_level,
        NULL::TEXT as parent_key,
        COUNT(DISTINCT sc.category_id)::INTEGER as category_count,
        COUNT(DISTINCT sg.group_id)::INTEGER as group_count,
        COUNT(DISTINCT sqb.id)::INTEGER as question_count
    FROM survey_sections ss
    LEFT JOIN pillars_base pb ON ss.pillar = pb.pillar_name
    LEFT JOIN survey_categories sc ON ss.section_id = sc.section_id
    LEFT JOIN survey_groups sg ON sc.category_id = sg.category_id
    LEFT JOIN survey_questions_base sqb ON sg.group_id = sqb.group_id
    WHERE (p_section_id IS NULL OR ss.section_id = p_section_id)
        AND ss.pillar IS NOT NULL -- Exclude non-scored sections like 'introduction'
    GROUP BY ss.section_id, ss.display_name, pb.icon, ss.description

    UNION ALL

    -- Second level: Categories
    SELECT
        sc.category_id as section_key,
        sc.display_name,
        NULL::TEXT as icon,
        sc.description,
        NULL::NUMERIC as section_score,
        2 as hierarchy_level,
        sc.section_id as parent_key,
        0::INTEGER as category_count,
        COUNT(DISTINCT sg.group_id)::INTEGER as group_count,
        COUNT(DISTINCT sqb.id)::INTEGER as question_count
    FROM survey_categories sc
    LEFT JOIN survey_groups sg ON sc.category_id = sg.category_id
    LEFT JOIN survey_questions_base sqb ON sg.group_id = sqb.group_id
    JOIN survey_sections ss ON sc.section_id = ss.section_id
    WHERE (p_section_id IS NULL OR sc.section_id = p_section_id)
        AND ss.pillar IS NOT NULL
    GROUP BY sc.category_id, sc.display_name, sc.description, sc.section_id

    UNION ALL

    -- Third level: Groups
    SELECT
        sg.group_id as section_key,
        sg.display_name,
        NULL::TEXT as icon,
        sg.description,
        NULL::NUMERIC as section_score,
        3 as hierarchy_level,
        sg.category_id as parent_key,
        0::INTEGER as category_count,
        0::INTEGER as group_count,
        COUNT(DISTINCT sqb.id)::INTEGER as question_count
    FROM survey_groups sg
    LEFT JOIN survey_questions_base sqb ON sg.group_id = sqb.group_id
    JOIN survey_categories sc ON sg.category_id = sc.category_id
    JOIN survey_sections ss ON sc.section_id = ss.section_id
    WHERE (p_section_id IS NULL OR sc.section_id = p_section_id)
        AND ss.pillar IS NOT NULL
    GROUP BY sg.group_id, sg.display_name, sg.description, sg.category_id

    ORDER BY hierarchy_level, section_key;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_section_hierarchy IS
'Returns the complete 3-level hierarchy (sections → categories → groups) with counts for a patient. Optionally filter by section_id. Excludes non-scored sections like introduction.';


-- =====================================================
-- Test Queries (Commented Out)
-- =====================================================

-- Test get_patient_survey_rollup for one patient
-- SELECT * FROM get_patient_survey_rollup('1758fa60-a306-440e-8ae6-9e68fd502bc2')
-- LIMIT 20;

-- Test get_section_hierarchy for top-level sections
-- SELECT
--     section_key,
--     display_name,
--     icon,
--     LEFT(description, 50) as description_preview,
--     category_count,
--     group_count,
--     question_count
-- FROM get_section_hierarchy('1758fa60-a306-440e-8ae6-9e68fd502bc2', NULL)
-- WHERE hierarchy_level = 1;

-- Test get_section_hierarchy drill-down for nutrition
-- SELECT
--     section_key,
--     display_name,
--     hierarchy_level,
--     parent_key,
--     question_count
-- FROM get_section_hierarchy('1758fa60-a306-440e-8ae6-9e68fd502bc2', 'healthful_nutrition')
-- ORDER BY hierarchy_level, section_key;

COMMIT;

-- =====================================================
-- Verification
-- =====================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_proc
        WHERE proname = 'get_patient_survey_rollup'
    ) THEN
        RAISE NOTICE '✅ Function get_patient_survey_rollup created successfully';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_proc
        WHERE proname = 'get_section_hierarchy'
    ) THEN
        RAISE NOTICE '✅ Function get_section_hierarchy created successfully';
    END IF;
END $$;
