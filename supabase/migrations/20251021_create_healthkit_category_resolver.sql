-- =====================================================
-- Create HealthKit Category Resolver View
-- =====================================================
-- Helper view for sync logic to determine which categories
-- are available for each HealthKit workout identifier
--
-- Used to decide if user prompt is needed during sync
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create View for Category Lookup
-- =====================================================

CREATE OR REPLACE VIEW healthkit_workout_category_options AS
WITH all_mappings AS (
  -- Cardio types
  SELECT
    healthkit_identifier,
    'cardio' as category,
    cardio_name as type_key,
    display_name as type_display_name
  FROM def_ref_cardio_types
  WHERE healthkit_identifier IS NOT NULL

  UNION ALL

  -- Strength types
  SELECT
    healthkit_identifier,
    'strength' as category,
    strength_type_key as type_key,
    display_name as type_display_name
  FROM def_ref_strength_types
  WHERE healthkit_identifier IS NOT NULL

  UNION ALL

  -- HIIT types
  SELECT
    healthkit_identifier,
    'hiit' as category,
    hiit_type_key as type_key,
    display_name as type_display_name
  FROM def_ref_hiit_types
  WHERE healthkit_identifier IS NOT NULL

  UNION ALL

  -- Mobility types
  SELECT
    healthkit_identifier,
    'mobility' as category,
    mobility_type_key as type_key,
    display_name as type_display_name
  FROM def_ref_mobility_types
  WHERE healthkit_identifier IS NOT NULL
)
SELECT
  healthkit_identifier,
  category,
  type_key,
  type_display_name,
  COUNT(*) OVER (PARTITION BY healthkit_identifier) as category_count,
  ARRAY_AGG(category) OVER (PARTITION BY healthkit_identifier) as available_categories
FROM all_mappings
ORDER BY healthkit_identifier, category;


-- =====================================================
-- PART 2: Create Function to Get Category Options
-- =====================================================

CREATE OR REPLACE FUNCTION get_healthkit_workout_categories(hk_identifier TEXT)
RETURNS TABLE(
  category TEXT,
  type_key TEXT,
  type_display_name TEXT,
  requires_user_selection BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    v.category,
    v.type_key,
    v.type_display_name,
    (v.category_count > 1) as requires_user_selection
  FROM healthkit_workout_category_options v
  WHERE v.healthkit_identifier = hk_identifier;
END;
$$ LANGUAGE plpgsql;


-- =====================================================
-- PART 3: Create Summary View of Ambiguous Identifiers
-- =====================================================

CREATE OR REPLACE VIEW healthkit_ambiguous_workout_types AS
SELECT
  healthkit_identifier,
  COUNT(DISTINCT category) as category_count,
  ARRAY_AGG(DISTINCT category ORDER BY category) as categories,
  STRING_AGG(DISTINCT type_display_name, ', ' ORDER BY type_display_name) as type_options
FROM healthkit_workout_category_options
GROUP BY healthkit_identifier
HAVING COUNT(DISTINCT category) > 1
ORDER BY category_count DESC, healthkit_identifier;


-- =====================================================
-- PART 4: Add Comments
-- =====================================================

COMMENT ON VIEW healthkit_workout_category_options IS
'Complete mapping of HealthKit workout identifiers to WellPath categories and types. Use for sync logic to determine if user prompt is needed (category_count > 1).';

COMMENT ON FUNCTION get_healthkit_workout_categories IS
'Returns all available categories for a given HealthKit identifier. If requires_user_selection = true, prompt user to choose category.

Example usage:
SELECT * FROM get_healthkit_workout_categories(''HKWorkoutActivityTypeJumpRope'');

Returns:
category | type_key             | type_display_name  | requires_user_selection
---------|----------------------|--------------------|-----------------------
cardio   | jump_rope            | Jump Rope          | true
hiit     | jump_rope_intervals  | Jump Rope Intervals| true
';

COMMENT ON VIEW healthkit_ambiguous_workout_types IS
'Lists all HealthKit workout types that exist in multiple categories and require user selection during sync. Use this to identify workouts that need user prompts.';

COMMIT;
