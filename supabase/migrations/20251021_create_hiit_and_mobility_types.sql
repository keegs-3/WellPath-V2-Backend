-- =====================================================
-- Create HIIT Types and Mobility Types
-- =====================================================
-- Creates new def_ref_hiit_types and def_ref_mobility_types tables
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Mobility Types Table
-- =====================================================

CREATE TABLE IF NOT EXISTS def_ref_mobility_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mobility_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  icon TEXT,

  -- Characteristics
  focus_area TEXT, -- 'full_body', 'upper_body', 'lower_body', 'core', 'specific_joint'
  improves_balance BOOLEAN DEFAULT false,
  improves_flexibility BOOLEAN DEFAULT true,
  reduces_stress BOOLEAN DEFAULT false,

  -- Standard columns
  is_active BOOLEAN DEFAULT true,
  display_order INTEGER,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE def_ref_mobility_types IS 'Reference data for mobility and flexibility work types';
COMMENT ON COLUMN def_ref_mobility_types.mobility_type_key IS 'Unique identifier for mobility type';


-- =====================================================
-- PART 2: Seed Mobility Types
-- =====================================================

INSERT INTO def_ref_mobility_types (
  mobility_type_key,
  display_name,
  description,
  focus_area,
  improves_balance,
  improves_flexibility,
  reduces_stress,
  display_order
) VALUES
(
  'static_stretching',
  'Static Stretching',
  'Holding stretches in a stationary position to improve flexibility',
  'full_body',
  false,
  true,
  false,
  1
),
(
  'dynamic_stretching',
  'Dynamic Stretching',
  'Active movements that take joints through their full range of motion',
  'full_body',
  false,
  true,
  false,
  2
),
(
  'yoga',
  'Yoga',
  'Mind-body practice combining postures, breathing, and meditation',
  'full_body',
  true,
  true,
  true,
  3
),
(
  'pilates',
  'Pilates',
  'Low-impact exercise focusing on core strength and flexibility',
  'core',
  true,
  true,
  false,
  4
),
(
  'foam_rolling',
  'Foam Rolling',
  'Self-myofascial release using foam roller for muscle recovery',
  'full_body',
  false,
  true,
  false,
  5
),
(
  'mobility_drills',
  'Mobility Drills',
  'Specific exercises to improve joint range of motion and movement quality',
  'full_body',
  false,
  true,
  false,
  6
),
(
  'tai_chi',
  'Tai Chi',
  'Gentle martial art emphasizing slow, flowing movements and balance',
  'full_body',
  true,
  true,
  true,
  7
),
(
  'pnf_stretching',
  'PNF Stretching',
  'Proprioceptive Neuromuscular Facilitation - advanced stretching technique',
  'full_body',
  false,
  true,
  false,
  8
),
(
  'active_isolated',
  'Active Isolated Stretching',
  'Hold stretches for 2 seconds, repeat 8-10 times',
  'full_body',
  false,
  true,
  false,
  9
),
(
  'resistance_band',
  'Resistance Band Stretching',
  'Using resistance bands to assist and deepen stretches',
  'full_body',
  false,
  true,
  false,
  10
)
ON CONFLICT (mobility_type_key) DO NOTHING;


-- =====================================================
-- PART 3: Create HIIT Types Table
-- =====================================================

CREATE TABLE IF NOT EXISTS def_ref_hiit_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hiit_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  icon TEXT,

  -- Typical characteristics
  typical_duration_minutes NUMERIC,
  typical_work_interval_seconds NUMERIC,
  typical_rest_interval_seconds NUMERIC,
  intensity_level TEXT CHECK (intensity_level IN ('moderate', 'high', 'very_high')),

  -- Standard columns
  is_active BOOLEAN DEFAULT true,
  display_order INTEGER,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE def_ref_hiit_types IS 'Reference data for High-Intensity Interval Training workout types';
COMMENT ON COLUMN def_ref_hiit_types.hiit_type_key IS 'Unique identifier for HIIT type (e.g., tabata, emom, amrap)';
COMMENT ON COLUMN def_ref_hiit_types.typical_work_interval_seconds IS 'Typical work period duration in seconds';
COMMENT ON COLUMN def_ref_hiit_types.typical_rest_interval_seconds IS 'Typical rest period duration in seconds';


-- =====================================================
-- PART 4: Seed HIIT Types
-- =====================================================

INSERT INTO def_ref_hiit_types (
  hiit_type_key,
  display_name,
  description,
  typical_duration_minutes,
  typical_work_interval_seconds,
  typical_rest_interval_seconds,
  intensity_level,
  display_order
) VALUES
(
  'tabata',
  'Tabata',
  '20 seconds max effort, 10 seconds rest, 8 rounds (4 minutes total)',
  4,
  20,
  10,
  'very_high',
  1
),
(
  'emom',
  'EMOM (Every Minute On the Minute)',
  'Perform set reps at start of each minute, rest remainder of minute',
  10,
  30,
  30,
  'high',
  2
),
(
  'amrap',
  'AMRAP (As Many Rounds As Possible)',
  'Complete as many rounds of a circuit as possible in set time',
  15,
  NULL,
  NULL,
  'very_high',
  3
),
(
  'sprint_intervals',
  'Sprint Intervals',
  'All-out sprints with recovery periods',
  20,
  30,
  90,
  'very_high',
  4
),
(
  'circuit_training',
  'Circuit Training',
  'Move through stations of different exercises with minimal rest',
  20,
  45,
  15,
  'high',
  5
),
(
  'pyramid',
  'Pyramid Intervals',
  'Work intervals that increase then decrease in duration',
  20,
  NULL,
  NULL,
  'high',
  6
),
(
  'fartlek',
  'Fartlek Training',
  'Swedish speed play - vary intensity based on feel throughout workout',
  30,
  NULL,
  NULL,
  'moderate',
  7
),
(
  'burpee_challenge',
  'Burpee Challenge',
  'High-rep burpee sets with short recovery',
  10,
  60,
  30,
  'very_high',
  8
),
(
  'battle_ropes',
  'Battle Ropes',
  'Intense rope training intervals',
  15,
  30,
  30,
  'very_high',
  9
),
(
  'jump_rope_intervals',
  'Jump Rope Intervals',
  'High-intensity jump rope with rest periods',
  15,
  60,
  30,
  'high',
  10
),
(
  'bodyweight_hiit',
  'Bodyweight HIIT',
  'No-equipment high-intensity bodyweight exercises',
  20,
  40,
  20,
  'high',
  11
),
(
  'kettlebell_hiit',
  'Kettlebell HIIT',
  'High-intensity kettlebell exercises',
  15,
  45,
  15,
  'very_high',
  12
),
(
  'boxing_intervals',
  'Boxing Intervals',
  'Heavy bag or shadow boxing intervals',
  15,
  180,
  60,
  'high',
  13
),
(
  'spin_hiit',
  'Spin/Cycling HIIT',
  'High-intensity cycling intervals',
  20,
  60,
  60,
  'very_high',
  14
),
(
  'custom_hiit',
  'Custom HIIT',
  'User-defined high-intensity interval training',
  NULL,
  NULL,
  NULL,
  'high',
  99
)
ON CONFLICT (hiit_type_key) DO NOTHING;


-- =====================================================
-- PART 5: Create data_entry_fields for HIIT and Mobility
-- =====================================================

-- HIIT fields
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  reference_table,
  is_active,
  healthkit_mapping_id,
  supports_healthkit_sync
) VALUES
(
  'DEF_HIIT_TYPE',
  'hiit_type',
  'HIIT Type',
  'Type of high-intensity interval training',
  'reference',
  'uuid',
  NULL,
  'def_ref_hiit_types',
  true,
  NULL,
  false
)
ON CONFLICT (field_id) DO UPDATE SET
  reference_table = 'def_ref_hiit_types',
  is_active = true;

-- Mobility fields
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  reference_table,
  is_active,
  healthkit_mapping_id,
  supports_healthkit_sync
) VALUES
(
  'DEF_MOBILITY_TYPE',
  'mobility_type',
  'Mobility Type',
  'Type of mobility/flexibility work',
  'reference',
  'uuid',
  NULL,
  'def_ref_mobility_types',
  true,
  NULL,
  false
),
(
  'DEF_MOBILITY_START',
  'mobility_start_time',
  'Mobility Start Time',
  'Start time of mobility/flexibility session',
  'timestamp',
  'datetime',
  NULL,
  NULL,
  true,
  NULL,
  false
),
(
  'DEF_MOBILITY_END',
  'mobility_end_time',
  'Mobility End Time',
  'End time of mobility/flexibility session',
  'timestamp',
  'datetime',
  NULL,
  NULL,
  true,
  NULL,
  false
),
(
  'DEF_MOBILITY_INTENSITY',
  'mobility_intensity',
  'Mobility Intensity',
  'Intensity rating for mobility session (1-5)',
  'rating',
  'integer',
  NULL,
  NULL,
  true,
  NULL,
  false
)
ON CONFLICT (field_id) DO NOTHING;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  hiit_count INTEGER;
  mobility_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO hiit_count FROM def_ref_hiit_types WHERE is_active = true;
  SELECT COUNT(*) INTO mobility_count FROM def_ref_mobility_types WHERE is_active = true;

  RAISE NOTICE '=========================================';
  RAISE NOTICE 'HIIT and Mobility Types Created';
  RAISE NOTICE '=========================================';
  RAISE NOTICE 'HIIT types created: %', hiit_count;
  RAISE NOTICE 'Mobility types created: %', mobility_count;
  RAISE NOTICE '';
  RAISE NOTICE 'HIIT types include:';
  RAISE NOTICE '  - Tabata (20s work, 10s rest)';
  RAISE NOTICE '  - EMOM (Every Minute On the Minute)';
  RAISE NOTICE '  - AMRAP (As Many Rounds As Possible)';
  RAISE NOTICE '  - Sprint Intervals';
  RAISE NOTICE '  - Circuit Training';
  RAISE NOTICE '  - And 10 more types...';
  RAISE NOTICE '';
  RAISE NOTICE 'Mobility types include:';
  RAISE NOTICE '  - Static Stretching';
  RAISE NOTICE '  - Dynamic Stretching';
  RAISE NOTICE '  - Yoga, Pilates, Tai Chi';
  RAISE NOTICE '  - Foam Rolling, Mobility Drills';
  RAISE NOTICE '  - And 3 more types...';
  RAISE NOTICE '';
  RAISE NOTICE 'data_entry_fields created:';
  RAISE NOTICE '  - DEF_HIIT_TYPE -> def_ref_hiit_types';
  RAISE NOTICE '  - DEF_MOBILITY_TYPE -> def_ref_mobility_types';
  RAISE NOTICE '  - DEF_MOBILITY_START, DEF_MOBILITY_END, DEF_MOBILITY_INTENSITY';
END $$;

COMMIT;
