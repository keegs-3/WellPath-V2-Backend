-- =====================================================
-- Fix HIIT HealthKit Mappings to Use Specific Types
-- =====================================================
-- Maps HIIT variants to their specific HealthKit workout types
-- when they exist, rather than generic HIIT identifier
--
-- Strategy:
-- - Jump rope HIIT → HKWorkoutActivityTypeJumpRope
-- - Boxing intervals → HKWorkoutActivityTypeBoxing
-- - Spin HIIT → HKWorkoutActivityTypeCycling
-- - Sprint intervals → HKWorkoutActivityTypeRunning
-- - Generic HIIT protocols → Keep as HKWorkoutActivityTypeHighIntensityIntervalTraining
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Update HIIT Types with Specific HK Identifiers
-- =====================================================

-- Jump Rope Intervals → Specific Jump Rope type
UPDATE def_ref_hiit_types
SET healthkit_identifier = 'HKWorkoutActivityTypeJumpRope'
WHERE hiit_type_key = 'jump_rope_intervals';

-- Spin/Cycling HIIT → Specific Cycling type
UPDATE def_ref_hiit_types
SET healthkit_identifier = 'HKWorkoutActivityTypeCycling'
WHERE hiit_type_key = 'spin_hiit';

-- Sprint Intervals → Specific Running type
UPDATE def_ref_hiit_types
SET healthkit_identifier = 'HKWorkoutActivityTypeRunning'
WHERE hiit_type_key = 'sprint_intervals';

-- Boxing Intervals → Specific Boxing type (consistency with boxing_hiit)
UPDATE def_ref_hiit_types
SET healthkit_identifier = 'HKWorkoutActivityTypeBoxing'
WHERE hiit_type_key = 'boxing_intervals';

-- Fartlek (Swedish speed play) → Running type
UPDATE def_ref_hiit_types
SET healthkit_identifier = 'HKWorkoutActivityTypeRunning'
WHERE hiit_type_key = 'fartlek';


-- =====================================================
-- PART 2: Verify Generic HIIT Mappings Remain
-- =====================================================

-- These should keep HKWorkoutActivityTypeHighIntensityIntervalTraining:
-- - tabata (classic HIIT protocol)
-- - emom (Every Minute On the Minute)
-- - amrap (As Many Rounds As Possible)
-- - circuit_training (general circuits)
-- - bodyweight_hiit (no specific HK type)
-- - burpee_challenge (bodyweight focused)
-- - pyramid (interval structure)
-- - battle_ropes (no specific HK type)
-- - kettlebell_hiit (no specific HK type)
-- - custom_hiit (catch-all)

-- Already correct - no changes needed for these


-- =====================================================
-- PART 3: Add Comments
-- =====================================================

COMMENT ON TABLE def_ref_hiit_types IS
'HIIT protocol types with specific HealthKit mappings where available. Activity-specific HIIT (jump rope, cycling, running, combat) maps to that activity type. Generic HIIT protocols (Tabata, EMOM, circuits) use HKWorkoutActivityTypeHighIntensityIntervalTraining.';

COMMENT ON COLUMN def_ref_hiit_types.healthkit_identifier IS
'HealthKit workout type. Uses specific types (JumpRope, Cycling, Boxing, etc.) when HIIT variant is activity-specific. Uses generic HIIT type for protocol-based workouts (Tabata, EMOM, etc.).';


-- =====================================================
-- PART 4: Sync Strategy Documentation
-- =====================================================

/*
HEALTHKIT SYNC STRATEGY FOR DUPLICATE IDENTIFIERS:

When a HealthKit workout has an identifier that exists in MULTIPLE tables
(e.g., HKWorkoutActivityTypeJumpRope exists in both cardio and HIIT),
the sync logic should:

1. **Prompt user to select category:**
   "New workout detected: Jump Rope (20 min)
    How did you use this workout?
    [ ] Cardio (steady state)
    [ ] HIIT (interval training)
    [ ] Strength Training
    [ ] Mobility"

2. **Optional: Use heart rate as default suggestion:**
   - High HR variability (intervals) → Suggest HIIT
   - Steady HR → Suggest Cardio
   - But always let user override

3. **Examples of duplicate identifiers:**
   - HKWorkoutActivityTypeJumpRope → Cardio OR HIIT
   - HKWorkoutActivityTypeCycling → Cardio OR HIIT
   - HKWorkoutActivityTypeRunning → Cardio OR HIIT
   - HKWorkoutActivityTypeBoxing → Cardio OR HIIT OR Strength
   - HKWorkoutActivityTypeKickboxing → Cardio OR HIIT
   - HKWorkoutActivityTypeMartialArts → Cardio OR HIIT

4. **No ambiguity (auto-assign):**
   - HKWorkoutActivityTypeHighIntensityIntervalTraining → HIIT
   - HKWorkoutActivityTypeTraditionalStrengthTraining → Strength
   - HKWorkoutActivityTypeYoga → Mobility
   - HKWorkoutActivityTypeSwimming → Cardio (only option)

IMPLEMENTATION NOTE:
Query all tables for matching healthkit_identifier.
If count > 1, prompt user. If count = 1, auto-assign.
*/

COMMIT;

