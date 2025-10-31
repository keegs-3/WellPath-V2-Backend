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
  field_description,
  category_id,
  event_type_id,
  value_type,
  is_active
) VALUES
  (
    'DEF_DEEP_SLEEP_START',
    'Deep Sleep Start',
    'Start time of deep sleep period',
    'CAT_SLEEP',
    'EVENT_SLEEP',
    'timestamp',
    true
  ),
  (
    'DEF_DEEP_SLEEP_END',
    'Deep Sleep End',
    'End time of deep sleep period',
    'CAT_SLEEP',
    'EVENT_SLEEP',
    'timestamp',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  field_description = EXCLUDED.field_description;

-- =====================================================
-- CORE SLEEP
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  field_description,
  category_id,
  event_type_id,
  value_type,
  is_active
) VALUES
  (
    'DEF_CORE_SLEEP_START',
    'Core Sleep Start',
    'Start time of core sleep period',
    'CAT_SLEEP',
    'EVENT_SLEEP',
    'timestamp',
    true
  ),
  (
    'DEF_CORE_SLEEP_END',
    'Core Sleep End',
    'End time of core sleep period',
    'CAT_SLEEP',
    'EVENT_SLEEP',
    'timestamp',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  field_description = EXCLUDED.field_description;

-- =====================================================
-- REM SLEEP
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  field_description,
  category_id,
  event_type_id,
  value_type,
  is_active
) VALUES
  (
    'DEF_REM_SLEEP_START',
    'REM Sleep Start',
    'Start time of REM sleep period',
    'CAT_SLEEP',
    'EVENT_SLEEP',
    'timestamp',
    true
  ),
  (
    'DEF_REM_SLEEP_END',
    'REM Sleep End',
    'End time of REM sleep period',
    'CAT_SLEEP',
    'EVENT_SLEEP',
    'timestamp',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  field_description = EXCLUDED.field_description;

-- =====================================================
-- AWAKE PERIODS (during sleep)
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  field_description,
  category_id,
  event_type_id,
  value_type,
  is_active
) VALUES
  (
    'DEF_AWAKE_PERIODS_START',
    'Awake Period Start',
    'Start time of awake period during sleep session',
    'CAT_SLEEP',
    'EVENT_SLEEP',
    'timestamp',
    true
  ),
  (
    'DEF_AWAKE_PERIODS_END',
    'Awake Period End',
    'End time of awake period during sleep session',
    'CAT_SLEEP',
    'EVENT_SLEEP',
    'timestamp',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  field_description = EXCLUDED.field_description;

-- =====================================================
-- INSTANCE CALCULATIONS (Duration from start/end)
-- =====================================================

INSERT INTO instance_calculations (
  instance_calculation_id,
  calculation_name,
  calculation_description,
  calculation_type_id,
  output_field_id,
  is_active
) VALUES
  (
    'CALC_DEEP_SLEEP_DURATION',
    'Deep Sleep Duration',
    'Calculate deep sleep duration from start/end times',
    'duration',
    'OUTPUT_DEEP_SLEEP_DURATION',
    true
  ),
  (
    'CALC_CORE_SLEEP_DURATION',
    'Core Sleep Duration',
    'Calculate core sleep duration from start/end times',
    'duration',
    'OUTPUT_CORE_SLEEP_DURATION',
    true
  ),
  (
    'CALC_REM_SLEEP_DURATION',
    'REM Sleep Duration',
    'Calculate REM sleep duration from start/end times',
    'duration',
    'OUTPUT_REM_SLEEP_DURATION',
    true
  ),
  (
    'CALC_AWAKE_PERIODS_DURATION',
    'Awake Periods Duration',
    'Calculate awake periods duration from start/end times',
    'duration',
    'OUTPUT_AWAKE_PERIODS_DURATION',
    true
  )
ON CONFLICT (instance_calculation_id) DO UPDATE SET
  calculation_name = EXCLUDED.calculation_name,
  output_field_id = EXCLUDED.output_field_id;

-- =====================================================
-- INSTANCE CALCULATION DEPENDENCIES
-- =====================================================

INSERT INTO instance_calculations_dependencies (
  instance_calculation_id,
  depends_on_field_id,
  dependency_role
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
ON CONFLICT (instance_calculation_id, depends_on_field_id) DO UPDATE SET
  dependency_role = EXCLUDED.dependency_role;

-- =====================================================
-- OUTPUT FIELDS (for duration results)
-- =====================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  field_description,
  category_id,
  event_type_id,
  value_type,
  default_unit,
  is_active
) VALUES
  (
    'OUTPUT_DEEP_SLEEP_DURATION',
    'Deep Sleep Duration',
    'Calculated deep sleep duration in minutes',
    'CAT_SLEEP',
    'EVENT_SLEEP',
    'quantity',
    'minutes',
    true
  ),
  (
    'OUTPUT_CORE_SLEEP_DURATION',
    'Core Sleep Duration',
    'Calculated core sleep duration in minutes',
    'CAT_SLEEP',
    'EVENT_SLEEP',
    'quantity',
    'minutes',
    true
  ),
  (
    'OUTPUT_REM_SLEEP_DURATION',
    'REM Sleep Duration',
    'Calculated REM sleep duration in minutes',
    'CAT_SLEEP',
    'EVENT_SLEEP',
    'quantity',
    'minutes',
    true
  ),
  (
    'OUTPUT_AWAKE_PERIODS_DURATION',
    'Awake Periods Duration',
    'Calculated awake periods duration in minutes',
    'CAT_SLEEP',
    'EVENT_SLEEP',
    'quantity',
    'minutes',
    true
  )
ON CONFLICT (field_id) DO UPDATE SET
  field_name = EXCLUDED.field_name,
  default_unit = EXCLUDED.default_unit;

-- =====================================================
-- AGGREGATION METRICS
-- =====================================================

INSERT INTO aggregation_metrics (
  agg_metric_id,
  agg_metric_name,
  agg_metric_description,
  category_id,
  unit,
  is_active
) VALUES
  (
    'AGG_DEEP_SLEEP_DURATION',
    'Deep Sleep Duration',
    'Total deep sleep duration',
    'CAT_SLEEP',
    'minutes',
    true
  ),
  (
    'AGG_CORE_SLEEP_DURATION',
    'Core Sleep Duration',
    'Total core sleep duration',
    'CAT_SLEEP',
    'minutes',
    true
  ),
  (
    'AGG_REM_SLEEP_DURATION',
    'REM Sleep Duration',
    'Total REM sleep duration',
    'CAT_SLEEP',
    'minutes',
    true
  ),
  (
    'AGG_AWAKE_PERIODS_DURATION',
    'Awake Periods Duration',
    'Total awake periods duration',
    'CAT_SLEEP',
    'minutes',
    true
  )
ON CONFLICT (agg_metric_id) DO UPDATE SET
  agg_metric_name = EXCLUDED.agg_metric_name;

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
ON CONFLICT (agg_metric_id, dependency_type, instance_calculation_id)
DO NOTHING;

-- =====================================================
-- AGGREGATION PERIODS (daily for sleep stages)
-- =====================================================

INSERT INTO aggregation_metrics_periods (
  agg_metric_id,
  period_id,
  chart_bars,
  chart_days,
  x_axis_label,
  y_axis_unit
) VALUES
  -- Deep Sleep
  ('AGG_DEEP_SLEEP_DURATION', 'daily', 7, 7, 'Last 7 Days', 'hours'),
  ('AGG_DEEP_SLEEP_DURATION', 'weekly', 12, 84, 'Last 12 Weeks', 'hours'),
  ('AGG_DEEP_SLEEP_DURATION', 'monthly', 6, 180, 'Last 6 Months', 'hours'),

  -- Core Sleep
  ('AGG_CORE_SLEEP_DURATION', 'daily', 7, 7, 'Last 7 Days', 'hours'),
  ('AGG_CORE_SLEEP_DURATION', 'weekly', 12, 84, 'Last 12 Weeks', 'hours'),
  ('AGG_CORE_SLEEP_DURATION', 'monthly', 6, 180, 'Last 6 Months', 'hours'),

  -- REM Sleep
  ('AGG_REM_SLEEP_DURATION', 'daily', 7, 7, 'Last 7 Days', 'hours'),
  ('AGG_REM_SLEEP_DURATION', 'weekly', 12, 84, 'Last 12 Weeks', 'hours'),
  ('AGG_REM_SLEEP_DURATION', 'monthly', 6, 180, 'Last 6 Months', 'hours'),

  -- Awake Periods
  ('AGG_AWAKE_PERIODS_DURATION', 'daily', 7, 7, 'Last 7 Days', 'hours'),
  ('AGG_AWAKE_PERIODS_DURATION', 'weekly', 12, 84, 'Last 12 Weeks', 'hours'),
  ('AGG_AWAKE_PERIODS_DURATION', 'monthly', 6, 180, 'Last 6 Months', 'hours')
ON CONFLICT (agg_metric_id, period_id) DO UPDATE SET
  chart_bars = EXCLUDED.chart_bars,
  y_axis_unit = EXCLUDED.y_axis_unit;

-- =====================================================
-- CALCULATION TYPES (SUM for all sleep stage durations)
-- =====================================================

INSERT INTO aggregation_metrics_calculation_types (
  agg_metric_id,
  calculation_type_id
) VALUES
  ('AGG_DEEP_SLEEP_DURATION', 'SUM'),
  ('AGG_CORE_SLEEP_DURATION', 'SUM'),
  ('AGG_REM_SLEEP_DURATION', 'SUM'),
  ('AGG_AWAKE_PERIODS_DURATION', 'SUM')
ON CONFLICT (agg_metric_id, calculation_type_id) DO NOTHING;

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
