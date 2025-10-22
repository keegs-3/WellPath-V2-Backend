-- =====================================================
-- Grant Permissions on Normalized Views
-- =====================================================
-- Edge Functions need explicit permissions to read views
-- even when using service_role key
--
-- Created: 2025-10-17
-- =====================================================

BEGIN;

-- Grant SELECT on all normalized views to service_role
GRANT SELECT ON wellpath_scoring_pillar_component_weights_with_sum TO service_role;
GRANT SELECT ON wellpath_scoring_marker_pillar_weights_normalized TO service_role;
GRANT SELECT ON wellpath_scoring_question_pillar_weights_normalized TO service_role;

-- Also grant to authenticated users (for potential direct queries from app)
GRANT SELECT ON wellpath_scoring_pillar_component_weights_with_sum TO authenticated;
GRANT SELECT ON wellpath_scoring_marker_pillar_weights_normalized TO authenticated;
GRANT SELECT ON wellpath_scoring_question_pillar_weights_normalized TO authenticated;

-- Grant to anon (public read access - these are reference tables)
GRANT SELECT ON wellpath_scoring_pillar_component_weights_with_sum TO anon;
GRANT SELECT ON wellpath_scoring_marker_pillar_weights_normalized TO anon;
GRANT SELECT ON wellpath_scoring_question_pillar_weights_normalized TO anon;

COMMIT;

-- Verification
DO $$
BEGIN
    RAISE NOTICE '✅ Granted SELECT permissions on normalized views';
    RAISE NOTICE 'Views accessible by: service_role, authenticated, anon';
END $$;
