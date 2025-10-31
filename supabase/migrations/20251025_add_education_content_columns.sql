-- =====================================================
-- Add Education Content Columns
-- =====================================================
-- Adds dedicated columns for about, longevity impact, and quick tips
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Add New Columns to display_screens_primary
-- =====================================================

ALTER TABLE display_screens_primary
ADD COLUMN IF NOT EXISTS about_content TEXT,
ADD COLUMN IF NOT EXISTS longevity_impact TEXT;

COMMENT ON COLUMN display_screens_primary.about_content IS 'General information about this health metric';
COMMENT ON COLUMN display_screens_primary.longevity_impact IS 'How this metric impacts longevity and healthspan';
COMMENT ON COLUMN display_screens_primary.quick_tips IS 'Array of actionable tips for improving this metric';

-- =====================================================
-- 2. Populate Protein Screen Content
-- =====================================================

UPDATE display_screens_primary
SET
  about_content = 'Protein is essential for building and repairing tissues, making enzymes and hormones, and supporting immune function. It provides the amino acids your body needs to maintain muscle mass, produce neurotransmitters, and create antibodies. Adequate protein intake is crucial for healthy aging, wound healing, and maintaining metabolic health.',

  longevity_impact = 'Higher protein intake, especially from plant sources, is associated with increased longevity and reduced mortality risk. Adequate protein helps preserve muscle mass as you age (sarcopenia prevention), supports bone density, maintains cognitive function, and promotes metabolic health. Studies show that consuming 1.2-1.6 g/kg body weight daily is optimal for healthy aging, with emphasis on leucine-rich sources for muscle protein synthesis.',

  quick_tips = jsonb_build_array(
    'Aim for 20-40g protein per meal to maximize muscle protein synthesis',
    'Spread intake evenly across meals - don''t load it all in one sitting',
    'Include protein within 2 hours post-workout for optimal recovery',
    'Prioritize lean sources: fish, poultry, legumes, low-fat dairy',
    'Plant proteins are highly effective when varied (beans + grains)',
    'Fatty fish provide bonus omega-3s for brain and heart health',
    'Morning protein improves satiety and helps maintain stable blood sugar'
  ),

  updated_at = NOW()
WHERE display_screen_id = 'SCREEN_PROTEIN';

-- =====================================================
-- 3. Migrate Existing info_sections to Structured Format
-- =====================================================

-- Keep info_sections for additional educational content
-- but now we have dedicated fields for the main content

-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  v_about_length INTEGER;
  v_longevity_length INTEGER;
  v_tips_count INTEGER;
BEGIN
  SELECT
    LENGTH(about_content),
    LENGTH(longevity_impact),
    jsonb_array_length(quick_tips)
  INTO v_about_length, v_longevity_length, v_tips_count
  FROM display_screens_primary
  WHERE display_screen_id = 'SCREEN_PROTEIN';

  RAISE NOTICE '';
  RAISE NOTICE '✅ Education Content Columns Added!';
  RAISE NOTICE '';
  RAISE NOTICE 'New Columns:';
  RAISE NOTICE '  • about_content (TEXT) - General information';
  RAISE NOTICE '  • longevity_impact (TEXT) - Impact on healthspan/lifespan';
  RAISE NOTICE '  • quick_tips (JSONB) - Array of actionable tips';
  RAISE NOTICE '';
  RAISE NOTICE 'Protein Screen Content:';
  RAISE NOTICE '  • About: % characters', v_about_length;
  RAISE NOTICE '  • Longevity Impact: % characters', v_longevity_length;
  RAISE NOTICE '  • Quick Tips: % items', v_tips_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Mobile can query these fields for accordion content';
  RAISE NOTICE '';
END $$;

COMMIT;
