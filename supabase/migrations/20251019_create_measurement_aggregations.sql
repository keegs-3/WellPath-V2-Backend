-- =====================================================
-- Phase 1: Measurement Field Aggregations
-- =====================================================
-- Creates aggregation_metrics for 14 standalone measurement fields
-- Pattern 1: Direct aggregation (most_recent, 7d_avg, 30d_avg, max, min)
--
-- Created: 2025-10-19
-- =====================================================

BEGIN;

-- =====================================================
-- Body Composition Measurements
-- =====================================================

-- Body Fat
INSERT INTO aggregation_metrics (
  agg_id, metric_name, description, is_active
) VALUES (
  'AGG_BODY_FAT',
  'Body Fat Percentage',
  'Body fat percentage measurements',
  true
) ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BODY_FAT', 'DEF_113', 'data_field'
) ON CONFLICT (agg_metric_id, data_entry_field_id) DO NOTHING;

-- Lean Body Mass
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'lean_body_mass',
  'Lean Body Mass',
  'Lean body mass measurements',
  'body_composition'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_099', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'lean_body_mass'
ON CONFLICT DO NOTHING;

-- Visceral Fat
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'visceral_fat',
  'Visceral Fat',
  'Visceral fat measurements',
  'body_composition'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_100', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'visceral_fat'
ON CONFLICT DO NOTHING;

-- Skeletal Muscle Mass
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'skeletal_muscle_mass',
  'Skeletal Muscle Mass',
  'Skeletal muscle mass measurements',
  'body_composition'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_209', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'skeletal_muscle_mass'
ON CONFLICT DO NOTHING;

-- =====================================================
-- Cardiovascular Measurements
-- =====================================================

-- Resting Heart Rate
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'resting_heart_rate',
  'Resting Heart Rate',
  'Resting heart rate measurements',
  'cardiovascular'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_107', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'resting_heart_rate'
ON CONFLICT DO NOTHING;

-- HRV (Heart Rate Variability)
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'hrv',
  'Heart Rate Variability',
  'HRV measurements',
  'cardiovascular'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_111', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'hrv'
ON CONFLICT DO NOTHING;

-- Systolic Blood Pressure
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'systolic_bp',
  'Systolic Blood Pressure',
  'Systolic blood pressure measurements',
  'cardiovascular'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_208', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'systolic_bp'
ON CONFLICT DO NOTHING;

-- Diastolic Blood Pressure
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'diastolic_bp',
  'Diastolic Blood Pressure',
  'Diastolic blood pressure measurements',
  'cardiovascular'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_207', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'diastolic_bp'
ON CONFLICT DO NOTHING;

-- =====================================================
-- Fitness Measurements
-- =====================================================

-- VO2 Max
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'vo2_max',
  'VO2 Max',
  'VO2 max measurements',
  'fitness'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_112', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'vo2_max'
ON CONFLICT DO NOTHING;

-- Grip Strength
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'grip_strength',
  'Grip Strength',
  'Grip strength measurements',
  'fitness'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_106', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'grip_strength'
ON CONFLICT DO NOTHING;

-- =====================================================
-- Body Measurements
-- =====================================================

-- Height
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'height',
  'Height',
  'Height measurements',
  'body_measurements'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_108', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'height'
ON CONFLICT DO NOTHING;

-- Waist Measurement
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'waist_circumference',
  'Waist Circumference',
  'Waist circumference measurements',
  'body_measurements'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_206', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'waist_circumference'
ON CONFLICT DO NOTHING;

-- Hip Measurement
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'hip_circumference',
  'Hip Circumference',
  'Hip circumference measurements',
  'body_measurements'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_205', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'hip_circumference'
ON CONFLICT DO NOTHING;

-- =====================================================
-- Activity Measurements
-- =====================================================

-- Steps
INSERT INTO aggregation_metrics (
  id, metric_key, metric_name, metric_description, aggregation_category
) VALUES (
  gen_random_uuid(),
  'steps',
  'Steps',
  'Daily step count',
  'activity'
) ON CONFLICT (metric_key) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
)
SELECT id, 'DEF_036', 'data_field'
FROM aggregation_metrics WHERE metric_key = 'steps'
ON CONFLICT DO NOTHING;

COMMIT;
