-- =====================================================
-- Create Strength Training Types Reference Table
-- =====================================================
-- Maps strength training variations to HealthKit workout types
-- Supports traditional, functional, core, and bodyweight training
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Strength Types Table
-- =====================================================

CREATE TABLE IF NOT EXISTS def_ref_strength_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  strength_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  category TEXT, -- 'traditional', 'functional', 'core', 'bodyweight', 'olympic', 'powerlifting'
  equipment_needed TEXT, -- 'barbell', 'dumbbell', 'kettlebell', 'bodyweight', 'machines', 'mixed'
  healthkit_identifier TEXT REFERENCES healthkit_mapping(healthkit_identifier),
  met_score NUMERIC DEFAULT 4.5,
  typical_intensity TEXT DEFAULT 'moderate', -- 'low', 'moderate', 'high', 'very_high'
  typical_duration_minutes INTEGER DEFAULT 45,
  supports_weight_tracking BOOLEAN DEFAULT true,
  supports_rep_tracking BOOLEAN DEFAULT true,
  is_active BOOLEAN DEFAULT true,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_strength_types_active ON def_ref_strength_types(is_active);
CREATE INDEX IF NOT EXISTS idx_strength_types_hk_identifier ON def_ref_strength_types(healthkit_identifier);
CREATE INDEX IF NOT EXISTS idx_strength_types_category ON def_ref_strength_types(category);


-- =====================================================
-- PART 2: Seed Strength Types with HealthKit Mappings
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
-- HealthKit Mapped Types (5 total)
(
  'traditional',
  'Traditional Strength Training',
  'Classic weight training with barbells, dumbbells, and machines',
  'traditional',
  'mixed',
  'HKWorkoutActivityTypeTraditionalStrengthTraining',
  5.0,
  'moderate',
  1
),
(
  'functional',
  'Functional Strength Training',
  'Movement-based training for real-world activities and sports performance',
  'functional',
  'mixed',
  'HKWorkoutActivityTypeFunctionalStrengthTraining',
  4.5,
  'moderate',
  2
),
(
  'core_training',
  'Core Training',
  'Targeted core strengthening exercises',
  'core',
  'bodyweight',
  'HKWorkoutActivityTypeCoreTraining',
  4.0,
  'moderate',
  3
),
(
  'cross_training',
  'Cross Training',
  'Mixed modality training combining multiple fitness elements',
  'functional',
  'mixed',
  'HKWorkoutActivityTypeCrossTraining',
  6.0,
  'high',
  4
),
(
  'barre',
  'Barre',
  'Ballet-inspired low-weight, high-rep strength training',
  'bodyweight',
  'bodyweight',
  'HKWorkoutActivityTypeBarre',
  3.5,
  'moderate',
  5
),

-- Additional Non-HealthKit Types (for granularity)
(
  'bodyweight',
  'Bodyweight Training',
  'Strength training using only bodyweight (push-ups, pull-ups, etc.)',
  'bodyweight',
  'bodyweight',
  NULL,
  4.0,
  'moderate',
  6
),
(
  'powerlifting',
  'Powerlifting',
  'Focus on squat, bench press, and deadlift',
  'powerlifting',
  'barbell',
  NULL,
  6.0,
  'high',
  7
),
(
  'olympic_lifting',
  'Olympic Weightlifting',
  'Clean & jerk, snatch, and related movements',
  'olympic',
  'barbell',
  NULL,
  7.0,
  'high',
  8
),
(
  'kettlebell',
  'Kettlebell Training',
  'Kettlebell-specific exercises and flows',
  'functional',
  'kettlebell',
  NULL,
  5.5,
  'moderate',
  9
),
(
  'resistance_band',
  'Resistance Band Training',
  'Strength training using resistance bands',
  'functional',
  'resistance_band',
  NULL,
  3.5,
  'low',
  10
),
(
  'calisthenics',
  'Calisthenics',
  'Advanced bodyweight strength training',
  'bodyweight',
  'bodyweight',
  NULL,
  5.0,
  'moderate',
  11
)
ON CONFLICT (strength_type_key) DO NOTHING;


-- =====================================================
-- PART 3: Link DEF_STRENGTH_TYPE Field to Table
-- =====================================================

UPDATE data_entry_fields
SET reference_table = 'def_ref_strength_types'
WHERE field_id = 'DEF_STRENGTH_TYPE';


-- =====================================================
-- PART 4: Add Comments
-- =====================================================

COMMENT ON TABLE def_ref_strength_types IS
'Reference table for strength training types. Maps to 5 HealthKit workout types plus custom options.';

COMMENT ON COLUMN def_ref_strength_types.healthkit_identifier IS
'HealthKit workout activity type for automatic sync. NULL for custom/non-synced types.';

COMMENT ON COLUMN def_ref_strength_types.equipment_needed IS
'Primary equipment used. Helps with workout planning and tracking.';

COMMIT;
