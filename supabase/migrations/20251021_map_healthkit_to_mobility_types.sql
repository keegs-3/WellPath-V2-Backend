-- =====================================================
-- Map HealthKit Identifiers to Mobility Types
-- =====================================================
-- Adds healthkit_identifier column with 1-to-1 mappings
-- Maps 7 HealthKit flexibility/mobility types to specific protocols
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Add HealthKit Identifier Column
-- =====================================================

ALTER TABLE def_ref_mobility_types
ADD COLUMN IF NOT EXISTS healthkit_identifier TEXT REFERENCES healthkit_mapping(healthkit_identifier);

-- Create index
CREATE INDEX IF NOT EXISTS idx_mobility_types_hk_identifier
  ON def_ref_mobility_types(healthkit_identifier);


-- =====================================================
-- PART 2: Establish 1-to-1 HealthKit Mappings
-- =====================================================

-- Yoga → HKWorkoutActivityTypeYoga
UPDATE def_ref_mobility_types
SET healthkit_identifier = 'HKWorkoutActivityTypeYoga'
WHERE mobility_type_key = 'yoga';

-- Pilates → HKWorkoutActivityTypePilates
UPDATE def_ref_mobility_types
SET healthkit_identifier = 'HKWorkoutActivityTypePilates'
WHERE mobility_type_key = 'pilates';

-- Tai Chi → HKWorkoutActivityTypeTaiChi
UPDATE def_ref_mobility_types
SET healthkit_identifier = 'HKWorkoutActivityTypeTaiChi'
WHERE mobility_type_key = 'tai_chi';

-- Static Stretching → HKWorkoutActivityTypeFlexibility (primary mapping)
UPDATE def_ref_mobility_types
SET healthkit_identifier = 'HKWorkoutActivityTypeFlexibility'
WHERE mobility_type_key = 'static_stretching';

-- Cooldown/Recovery sessions → HKWorkoutActivityTypeCooldown
-- Note: Mapping to foam_rolling as it's most common cooldown activity
UPDATE def_ref_mobility_types
SET healthkit_identifier = 'HKWorkoutActivityTypeCooldown'
WHERE mobility_type_key = 'foam_rolling';

-- Mobility Drills → HKWorkoutActivityTypePreparationAndRecovery
UPDATE def_ref_mobility_types
SET healthkit_identifier = 'HKWorkoutActivityTypePreparationAndRecovery'
WHERE mobility_type_key = 'mobility_drills';

-- MindAndBody → Map to dynamic stretching as general catch-all
-- (Since MindAndBody could be yoga/pilates/tai chi, use for general movement prep)
UPDATE def_ref_mobility_types
SET healthkit_identifier = 'HKWorkoutActivityTypeMindAndBody'
WHERE mobility_type_key = 'dynamic_stretching';


-- =====================================================
-- PART 3: Add Comments
-- =====================================================

COMMENT ON COLUMN def_ref_mobility_types.healthkit_identifier IS
'1-to-1 mapping to HealthKit flexibility/mobility workout types. Each HK type maps to one primary protocol.';

COMMENT ON TABLE def_ref_mobility_types IS
'Mobility and flexibility protocol types with HealthKit integration. Includes stretching, yoga, Pilates, foam rolling, etc.';

COMMIT;
