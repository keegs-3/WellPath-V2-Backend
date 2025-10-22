-- =====================================================
-- Add Combat Sports to Both Cardio and HIIT
-- =====================================================
-- Combat sports can be used as steady cardio OR interval training
-- Allow users to select category based on how they trained
--
-- Added to:
-- - Cardio: For steady training (shadowboxing, technique work, rounds)
-- - HIIT: For interval-based training (heavy bag intervals, sparring)
-- - Strength: Already in via cross-training category
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Add Combat Sports to Cardio Types
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
-- Combat Sports as Cardio
('boxing_cardio', 'Boxing (Cardio)', 'Steady boxing for cardio - shadowboxing, bag work, technique', 'HKWorkoutActivityTypeBoxing', 9.0, 'high', false, false, true, false, true),
('kickboxing_cardio', 'Kickboxing (Cardio)', 'Steady kickboxing training', 'HKWorkoutActivityTypeKickboxing', 9.0, 'high', false, false, true, false, true),
('martial_arts_cardio', 'Martial Arts (Cardio)', 'Continuous martial arts training', 'HKWorkoutActivityTypeMartialArts', 8.0, 'high', false, false, true, false, true),
('wrestling', 'Wrestling', 'Wrestling training or competition', 'HKWorkoutActivityTypeWrestling', 10.0, 'very_high', false, false, true, false, true),
('fencing', 'Fencing', 'Fencing', 'HKWorkoutActivityTypeFencing', 6.0, 'moderate', false, false, true, false, true)
ON CONFLICT (cardio_name) DO NOTHING;


-- =====================================================
-- PART 2: Add Combat Sports to HIIT Types
-- =====================================================

INSERT INTO def_ref_hiit_types (
  hiit_type_key,
  display_name,
  description,
  typical_duration_minutes,
  typical_work_interval_seconds,
  typical_rest_interval_seconds,
  intensity_level,
  is_active,
  display_order,
  healthkit_identifier
) VALUES
-- Combat Sports as HIIT (all use generic HIIT identifier)
(
  'boxing_hiit',
  'Boxing HIIT',
  'High-intensity boxing rounds with rest (heavy bag, mitts, sparring)',
  20,
  180, -- 3-minute rounds
  60,  -- 1-minute rest
  'very_high',
  true,
  15,
  'HKWorkoutActivityTypeHighIntensityIntervalTraining'
),
(
  'kickboxing_hiit',
  'Kickboxing HIIT',
  'Kickboxing rounds with intervals',
  20,
  180,
  60,
  'very_high',
  true,
  16,
  'HKWorkoutActivityTypeHighIntensityIntervalTraining'
),
(
  'martial_arts_hiit',
  'Martial Arts HIIT',
  'Martial arts drills with high-intensity intervals',
  15,
  60,
  30,
  'very_high',
  true,
  17,
  'HKWorkoutActivityTypeHighIntensityIntervalTraining'
)
ON CONFLICT (hiit_type_key) DO NOTHING;


-- =====================================================
-- PART 3: Add Comments
-- =====================================================

COMMENT ON TABLE def_ref_cardio_types IS
'Complete cardio workout types including combat sports as steady cardio option. Combat sports available in both cardio (steady training) and HIIT (interval rounds) based on usage.';

COMMENT ON TABLE def_ref_hiit_types IS
'HIIT protocol types including combat sports as interval training. Same combat sports available in cardio for steady training.';

COMMIT;
