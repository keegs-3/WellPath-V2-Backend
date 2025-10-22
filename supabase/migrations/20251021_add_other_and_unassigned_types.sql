-- =====================================================
-- Add "Other" and "Unassigned" Types to All Exercise Tables
-- =====================================================
-- Catch-all types for user flexibility and unprocessed HealthKit syncs
--
-- "Unassigned": HealthKit workout synced but user hasn't categorized yet
-- "Other": User manually selected for activities not in predefined list
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Add to Cardio Types
-- =====================================================

INSERT INTO def_ref_cardio_types (
  cardio_name,
  display_name,
  description,
  healthkit_identifier,
  met_score,
  typical_intensity,
  tracks_distance,
  tracks_elevation,
  typical_indoor,
  supports_distance,
  supports_intensity
) VALUES
(
  'unassigned',
  'Unassigned',
  'HealthKit workout not yet categorized by user',
  NULL, -- Can match any identifier
  5.0,
  'moderate',
  false,
  false,
  NULL,
  false,
  false
),
(
  'other',
  'Other',
  'User-selected catch-all for activities not in predefined list',
  'HKWorkoutActivityTypeOther', -- Maps to HK "Other" type
  5.0,
  'moderate',
  false,
  false,
  NULL,
  false,
  true
)
ON CONFLICT (cardio_name) DO NOTHING;


-- =====================================================
-- PART 2: Add to Strength Types
-- =====================================================

INSERT INTO def_ref_strength_types (
  strength_type_key,
  display_name,
  description,
  category,
  equipment_needed,
  healthkit_identifier,
  met_score,
  typical_intensity,
  display_order
) VALUES
(
  'unassigned',
  'Unassigned',
  'HealthKit workout not yet categorized by user',
  'other',
  'mixed',
  NULL,
  5.0,
  'moderate',
  98
),
(
  'other',
  'Other',
  'User-selected catch-all for strength activities not in predefined list',
  'other',
  'mixed',
  NULL,
  5.0,
  'moderate',
  99
)
ON CONFLICT (strength_type_key) DO NOTHING;


-- =====================================================
-- PART 3: Add to HIIT Types
-- =====================================================

INSERT INTO def_ref_hiit_types (
  hiit_type_key,
  display_name,
  description,
  typical_duration_minutes,
  intensity_level,
  is_active,
  display_order,
  healthkit_identifier
) VALUES
(
  'unassigned',
  'Unassigned',
  'HealthKit HIIT workout not yet categorized by user',
  20,
  'high',
  true,
  98,
  NULL
),
(
  'other',
  'Other HIIT',
  'User-selected catch-all for HIIT activities not in predefined list',
  20,
  'high',
  true,
  99,
  'HKWorkoutActivityTypeHighIntensityIntervalTraining'
)
ON CONFLICT (hiit_type_key) DO NOTHING;


-- =====================================================
-- PART 4: Add to Mobility Types
-- =====================================================

INSERT INTO def_ref_mobility_types (
  mobility_type_key,
  display_name,
  description,
  focus_area,
  improves_balance,
  improves_flexibility,
  reduces_stress,
  is_active,
  display_order,
  healthkit_identifier
) VALUES
(
  'unassigned',
  'Unassigned',
  'HealthKit flexibility workout not yet categorized by user',
  'full_body',
  false,
  false,
  false,
  true,
  98,
  NULL
),
(
  'other',
  'Other',
  'User-selected catch-all for mobility activities not in predefined list',
  'full_body',
  false,
  true,
  false,
  true,
  99,
  NULL
)
ON CONFLICT (mobility_type_key) DO NOTHING;


-- =====================================================
-- PART 5: Update Sync Strategy Documentation
-- =====================================================

/*
ENHANCED HEALTHKIT SYNC STRATEGY WITH SMART RECOMMENDATIONS:

FLOW 1: Ambiguous Identifier with HR-Based Suggestion
-------------------------------------------------------
Example: Cycling workout detected

1. HealthKit syncs: HKWorkoutActivityTypeCycling (20 min, 240 kcal)
2. Check HR patterns: High variability detected → Suggest HIIT
3. Create notification:

   "New Cycling workout detected"
   "Based on your heart rate during this workout, we recommend
    adding this as a HIIT workout"

   [Confirm]  [Change Type]

4a. User taps "Confirm":
    → Save to HIIT table with spin_hiit type
    → Done

4b. User taps "Change Type":
    → Open wheel showing cardio options (only shows: cycling, other)
    → User selects "Cardio - Cycling"
    → Save to Cardio table with cycling type
    → Done

4c. User dismisses notification:
    → Save to Cardio table (default category for cycling) with "unassigned" type
    → User can recategorize later from workout history


FLOW 2: Generic HIIT Workout (No Specific Type)
------------------------------------------------
Example: User logs "HIIT" in Apple Watch

1. HealthKit syncs: HKWorkoutActivityTypeHighIntensityIntervalTraining
2. System knows this is HIIT category but needs specific protocol
3. Create notification:

   "HIIT Workout detected (20 min)"
   "Select workout type"

   [Select Type]

4a. User taps "Select Type":
    → Open wheel showing HIIT types (Tabata, EMOM, Sprint Intervals, etc.)
    → User selects "Tabata"
    → Save to HIIT table with tabata type
    → Done

4b. User dismisses notification:
    → Save to HIIT table with "unassigned" type
    → User can specify type later from workout history


FLOW 3: Unambiguous Identifier (Auto-Assign)
---------------------------------------------
Example: Swimming workout

1. HealthKit syncs: HKWorkoutActivityTypeSwimming
2. System checks: Only exists in Cardio table
3. Auto-assign:
   → Save to Cardio table with swimming type
   → No notification needed
   → Done


IMPLEMENTATION QUERIES:

-- Check if workout needs user input
SELECT * FROM get_healthkit_workout_categories('HKWorkoutActivityTypeCycling');
-- Returns: requires_user_selection = true

-- Get HR-based recommendation (pseudo-code)
IF hr_variability > threshold THEN
  recommended_category = 'hiit'
ELSE
  recommended_category = 'cardio'
END IF

-- If user dismisses, save as unassigned
INSERT INTO patient_data_entries (...) VALUES (
  field_id = 'DEF_CARDIO_TYPE', -- or DEF_HIIT_TYPE
  value_reference = 'unassigned',
  ...
)
*/

COMMIT;
