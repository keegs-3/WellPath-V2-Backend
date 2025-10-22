-- =====================================================
-- Create Missing Instance Calculations - Part 1
-- =====================================================
-- Adds the instance calculation records
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- HIIT Duration
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  unit_id,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES (
  'IC_007',
  'hiit_duration',
  'HIIT Duration',
  'Duration of high-intensity interval training session',
  'time_difference',
  'end_time - start_time',
  'minute',
  true,
  true,
  '{
    "parameters": {
      "end_time": "DEF_HIIT_END",
      "start_time": "DEF_HIIT_START"
    },
    "output_unit": "minute"
  }'::jsonb
)
ON CONFLICT (calc_id) DO NOTHING;

-- Mobility Duration
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  unit_id,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES (
  'IC_003B',
  'mobility_duration',
  'Mobility Duration',
  'Duration of mobility/flexibility session',
  'time_difference',
  'end_time - start_time',
  'minute',
  true,
  true,
  '{
    "parameters": {
      "end_time": "DEF_MOBILITY_END",
      "start_time": "DEF_MOBILITY_START"
    },
    "output_unit": "minute"
  }'::jsonb
)
ON CONFLICT (calc_id) DO NOTHING;

-- Outdoor Time Duration
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  unit_id,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES (
  'IC_008',
  'outdoor_duration',
  'Outdoor Time Duration',
  'Duration spent outdoors',
  'time_difference',
  'end_time - start_time',
  'minute',
  true,
  true,
  '{
    "parameters": {
      "end_time": "DEF_OUTDOOR_END",
      "start_time": "DEF_OUTDOOR_START"
    },
    "output_unit": "minute"
  }'::jsonb
)
ON CONFLICT (calc_id) DO NOTHING;

-- Sunlight Exposure Duration
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  unit_id,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES (
  'IC_009',
  'sunlight_duration',
  'Sunlight Exposure Duration',
  'Duration of sunlight exposure',
  'time_difference',
  'end_time - start_time',
  'minute',
  true,
  true,
  '{
    "parameters": {
      "end_time": "DEF_SUNLIGHT_END",
      "start_time": "DEF_SUNLIGHT_START"
    },
    "output_unit": "minute"
  }'::jsonb
)
ON CONFLICT (calc_id) DO NOTHING;

-- Caffeine to Sleep Window
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  unit_id,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES (
  'IC_073',
  'caffeine_to_sleep_window',
  'Caffeine to Sleep Window',
  'Hours between last caffeine intake and sleep session start (CRITICAL for sleep quality)',
  'time_difference',
  'sleep_start_time - caffeine_time',
  'hours',
  true,
  true,
  '{
    "parameters": {
      "sleep_start_time": "DEF_SLEEP_SESSION_START",
      "caffeine_time": "DEF_CAFFEINE_TIME"
    },
    "output_unit": "hours",
    "aggregation": "min",
    "window": "same_day",
    "alert_threshold": 6,
    "alert_message": "Caffeine within 6 hours of sleep may impact sleep quality"
  }'::jsonb
)
ON CONFLICT (calc_id) DO NOTHING;

-- Alcohol to Sleep Window
INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  formula_definition,
  unit_id,
  is_displayed_to_user,
  is_active,
  calculation_config
) VALUES (
  'IC_072',
  'alcohol_to_sleep_window',
  'Alcohol to Sleep Window',
  'Hours between last alcohol consumption and sleep session start',
  'time_difference',
  'sleep_start_time - alcohol_time',
  'hours',
  true,
  true,
  '{
    "parameters": {
      "sleep_start_time": "DEF_SLEEP_SESSION_START",
      "alcohol_time": "DEF_ALCOHOL_TIME"
    },
    "output_unit": "hours",
    "aggregation": "min",
    "window": "same_day",
    "alert_threshold": 3,
    "alert_message": "Alcohol within 3 hours of sleep may disrupt sleep architecture"
  }'::jsonb
)
ON CONFLICT (calc_id) DO NOTHING;

-- Mark old flexibility as inactive
UPDATE instance_calculations
SET is_active = false
WHERE calc_id = 'IC_003'
AND calc_name = 'flexibility_duration';

COMMIT;
