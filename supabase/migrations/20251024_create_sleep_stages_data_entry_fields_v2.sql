-- =====================================================
-- Create Sleep Stages Data Entry Fields
-- =====================================================
-- Individual fields for each sleep stage (no def/ref pattern)
-- Each stage has start/end times for duration calculation
--
-- Created: 2025-10-24
-- =====================================================

-- =====================================================
-- DEEP SLEEP
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  category_id,
  event_type_id,
  is_active
) VALUES
  (
    'DEF_DEEP_SLEEP_START',
    'deep_sleep_start',
    'Deep Sleep Start',
    'Start time of deep sleep period',
    'timestamp',
    'timestamp',
    'sleep_tracking',
    'EVT_SLEEP',
    true
  ),
  (
    'DEF_DEEP_SLEEP_END',
    'deep_sleep_end',
    'Deep Sleep End',
    'End time of deep sleep period',
    'timestamp',
    'timestamp',
    'sleep_tracking',
    'EVT_SLEEP',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  display_name = EXCLUDED.display_name;

-- =====================================================
-- CORE SLEEP
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  category_id,
  event_type_id,
  is_active
) VALUES
  (
    'DEF_CORE_SLEEP_START',
    'core_sleep_start',
    'Core Sleep Start',
    'Start time of core sleep period',
    'timestamp',
    'timestamp',
    'sleep_tracking',
    'EVT_SLEEP',
    true
  ),
  (
    'DEF_CORE_SLEEP_END',
    'core_sleep_end',
    'Core Sleep End',
    'End time of core sleep period',
    'timestamp',
    'timestamp',
    'sleep_tracking',
    'EVT_SLEEP',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  display_name = EXCLUDED.display_name;

-- =====================================================
-- REM SLEEP
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  category_id,
  event_type_id,
  is_active
) VALUES
  (
    'DEF_REM_SLEEP_START',
    'rem_sleep_start',
    'REM Sleep Start',
    'Start time of REM sleep period',
    'timestamp',
    'timestamp',
    'sleep_tracking',
    'EVT_SLEEP',
    true
  ),
  (
    'DEF_REM_SLEEP_END',
    'rem_sleep_end',
    'REM Sleep End',
    'End time of REM sleep period',
    'timestamp',
    'timestamp',
    'sleep_tracking',
    'EVT_SLEEP',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  display_name = EXCLUDED.display_name;

-- =====================================================
-- AWAKE PERIODS (during sleep)
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  category_id,
  event_type_id,
  is_active
) VALUES
  (
    'DEF_AWAKE_PERIODS_START',
    'awake_periods_start',
    'Awake Period Start',
    'Start time of awake period during sleep session',
    'timestamp',
    'timestamp',
    'sleep_tracking',
    'EVT_SLEEP',
    true
  ),
  (
    'DEF_AWAKE_PERIODS_END',
    'awake_periods_end',
    'Awake Period End',
    'End time of awake period during sleep session',
    'timestamp',
    'timestamp',
    'sleep_tracking',
    'EVT_SLEEP',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  display_name = EXCLUDED.display_name;

-- =====================================================
-- OUTPUT FIELDS (for duration results)
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  category_id,
  event_type_id,
  is_active
) VALUES
  (
    'OUTPUT_DEEP_SLEEP_DURATION',
    'deep_sleep_duration',
    'Deep Sleep Duration',
    'Calculated deep sleep duration in minutes',
    'output',
    'quantity',
    'minutes',
    'sleep_tracking',
    'EVT_SLEEP',
    true
  ),
  (
    'OUTPUT_CORE_SLEEP_DURATION',
    'core_sleep_duration',
    'Core Sleep Duration',
    'Calculated core sleep duration in minutes',
    'output',
    'quantity',
    'minutes',
    'sleep_tracking',
    'EVT_SLEEP',
    true
  ),
  (
    'OUTPUT_REM_SLEEP_DURATION',
    'rem_sleep_duration',
    'REM Sleep Duration',
    'Calculated REM sleep duration in minutes',
    'output',
    'quantity',
    'minutes',
    'sleep_tracking',
    'EVT_SLEEP',
    true
  ),
  (
    'OUTPUT_AWAKE_PERIODS_DURATION',
    'awake_periods_duration',
    'Awake Periods Duration',
    'Calculated awake periods duration in minutes',
    'output',
    'quantity',
    'minutes',
    'sleep_tracking',
    'EVT_SLEEP',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  display_name = EXCLUDED.display_name,
  unit = EXCLUDED.unit;

-- =====================================================
-- INSTANCE CALCULATIONS (Duration from start/end)
-- =====================================================

INSERT INTO instance_calculations (
  calc_id,
  calc_name,
  display_name,
  description,
  calculation_method,
  unit_id,
  is_active
) VALUES
  (
    'CALC_DEEP_SLEEP_DURATION',
    'deep_sleep_duration',
    'Deep Sleep Duration',
    'Calculate deep sleep duration from start/end times',
    'duration',
    'minutes',
    true
  ),
  (
    'CALC_CORE_SLEEP_DURATION',
    'core_sleep_duration',
    'Core Sleep Duration',
    'Calculate core sleep duration from start/end times',
    'duration',
    'minutes',
    true
  ),
  (
    'CALC_REM_SLEEP_DURATION',
    'rem_sleep_duration',
    'REM Sleep Duration',
    'Calculate REM sleep duration from start/end times',
    'duration',
    'minutes',
    true
  ),
  (
    'CALC_AWAKE_PERIODS_DURATION',
    'awake_periods_duration',
    'Awake Periods Duration',
    'Calculate awake periods duration from start/end times',
    'duration',
    'minutes',
    true
  )
ON CONFLICT (calc_id) DO UPDATE SET
  calc_name = EXCLUDED.calc_name,
  display_name = EXCLUDED.display_name;

-- =====================================================
-- INSTANCE CALCULATION DEPENDENCIES
-- =====================================================

INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  data_entry_field_id,
  parameter_role
) VALUES
  -- Deep Sleep
  ('CALC_DEEP_SLEEP_DURATION', 'DEF_DEEP_SLEEP_START', 'start_time'),
  ('CALC_DEEP_SLEEP_DURATION', 'DEF_DEEP_SLEEP_END', 'end_time'),

  -- Core Sleep
  ('CALC_CORE_SLEEP_DURATION', 'DEF_CORE_SLEEP_START', 'start_time'),
  ('CALC_CORE_SLEEP_DURATION', 'DEF_CORE_SLEEP_END', 'end_time'),

  -- REM Sleep
  ('CALC_REM_SLEEP_DURATION', 'DEF_REM_SLEEP_START', 'start_time'),
  ('CALC_REM_SLEEP_DURATION', 'DEF_REM_SLEEP_END', 'end_time'),

  -- Awake Periods
  ('CALC_AWAKE_PERIODS_DURATION', 'DEF_AWAKE_PERIODS_START', 'start_time'),
  ('CALC_AWAKE_PERIODS_DURATION', 'DEF_AWAKE_PERIODS_END', 'end_time')
ON CONFLICT ON CONSTRAINT unique_ic_def_param DO UPDATE SET
  parameter_role = EXCLUDED.parameter_role;

-- =====================================================
-- AGGREGATION METRICS
-- =====================================================

INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  description,
  output_unit,
  is_active
) VALUES
  (
    'AGG_DEEP_SLEEP_DURATION',
    'deep_sleep_duration',
    'Deep Sleep Duration',
    'Total deep sleep duration',
    'minutes',
    true
  ),
  (
    'AGG_CORE_SLEEP_DURATION',
    'core_sleep_duration',
    'Core Sleep Duration',
    'Total core sleep duration',
    'minutes',
    true
  ),
  (
    'AGG_REM_SLEEP_DURATION',
    'rem_sleep_duration',
    'REM Sleep Duration',
    'Total REM sleep duration',
    'minutes',
    true
  ),
  (
    'AGG_AWAKE_PERIODS_DURATION',
    'awake_periods_duration',
    'Awake Periods Duration',
    'Total awake periods duration',
    'minutes',
    true
  )
ON CONFLICT (agg_id) DO UPDATE SET
  metric_name = EXCLUDED.metric_name,
  display_name = EXCLUDED.display_name;

-- =====================================================
-- AGGREGATION DEPENDENCIES (link to instance calcs)
-- =====================================================

INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  dependency_type,
  instance_calculation_id
) VALUES
  ('AGG_DEEP_SLEEP_DURATION', 'instance_calc', 'CALC_DEEP_SLEEP_DURATION'),
  ('AGG_CORE_SLEEP_DURATION', 'instance_calc', 'CALC_CORE_SLEEP_DURATION'),
  ('AGG_REM_SLEEP_DURATION', 'instance_calc', 'CALC_REM_SLEEP_DURATION'),
  ('AGG_AWAKE_PERIODS_DURATION', 'instance_calc', 'CALC_AWAKE_PERIODS_DURATION')
ON CONFLICT ON CONSTRAINT unique_dependency DO NOTHING;

-- =====================================================
-- AGGREGATION PERIODS (daily for sleep stages)
-- =====================================================

INSERT INTO aggregation_metrics_periods (
  agg_metric_id,
  period_id,
  bars,
  days,
  y_axis_label
) VALUES
  -- Deep Sleep
  ('AGG_DEEP_SLEEP_DURATION', 'daily', 7, 7, 'hours'),
  ('AGG_DEEP_SLEEP_DURATION', 'weekly', 12, 84, 'hours'),
  ('AGG_DEEP_SLEEP_DURATION', 'monthly', 6, 180, 'hours'),

  -- Core Sleep
  ('AGG_CORE_SLEEP_DURATION', 'daily', 7, 7, 'hours'),
  ('AGG_CORE_SLEEP_DURATION', 'weekly', 12, 84, 'hours'),
  ('AGG_CORE_SLEEP_DURATION', 'monthly', 6, 180, 'hours'),

  -- REM Sleep
  ('AGG_REM_SLEEP_DURATION', 'daily', 7, 7, 'hours'),
  ('AGG_REM_SLEEP_DURATION', 'weekly', 12, 84, 'hours'),
  ('AGG_REM_SLEEP_DURATION', 'monthly', 6, 180, 'hours'),

  -- Awake Periods
  ('AGG_AWAKE_PERIODS_DURATION', 'daily', 7, 7, 'hours'),
  ('AGG_AWAKE_PERIODS_DURATION', 'weekly', 12, 84, 'hours'),
  ('AGG_AWAKE_PERIODS_DURATION', 'monthly', 6, 180, 'hours');

-- =====================================================
-- CALCULATION TYPES (SUM for all sleep stage durations)
-- =====================================================

INSERT INTO aggregation_metrics_calculation_types (
  aggregation_metric_id,
  calculation_type_id
) VALUES
  ('AGG_DEEP_SLEEP_DURATION', 'SUM'),
  ('AGG_CORE_SLEEP_DURATION', 'SUM'),
  ('AGG_REM_SLEEP_DURATION', 'SUM'),
  ('AGG_AWAKE_PERIODS_DURATION', 'SUM')
ON CONFLICT ON CONSTRAINT unique_agg_calc_type DO NOTHING;

-- Summary
SELECT '
========================================
✅ Sleep Stages Data Entry Fields Created
========================================

Data Entry Fields (Start/End):
  - DEF_DEEP_SLEEP_START / DEF_DEEP_SLEEP_END
  - DEF_CORE_SLEEP_START / DEF_CORE_SLEEP_END
  - DEF_REM_SLEEP_START / DEF_REM_SLEEP_END
  - DEF_AWAKE_PERIODS_START / DEF_AWAKE_PERIODS_END

Instance Calculations (Duration):
  - CALC_DEEP_SLEEP_DURATION
  - CALC_CORE_SLEEP_DURATION
  - CALC_REM_SLEEP_DURATION
  - CALC_AWAKE_PERIODS_DURATION

Aggregation Metrics:
  - AGG_DEEP_SLEEP_DURATION
  - AGG_CORE_SLEEP_DURATION
  - AGG_REM_SLEEP_DURATION
  - AGG_AWAKE_PERIODS_DURATION

Periods: daily, weekly, monthly
Calculation Type: SUM

Ready for display metric linking!
========================================
' as summary;
