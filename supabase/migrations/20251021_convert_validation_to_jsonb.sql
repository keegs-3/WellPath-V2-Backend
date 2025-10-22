-- =====================================================
-- Convert Validation Fields to JSONB
-- =====================================================
-- Replaces numeric validation columns with JSONB structure
-- Supports complex validation scenarios:
-- - Absolute validation (min/max values)
-- - Relative validation (comparison to other fields)
-- - Context-aware prompts (duration thresholds)
-- - Custom validation messages
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Drop Old Numeric Validation Columns
-- =====================================================

ALTER TABLE data_entry_fields
DROP COLUMN IF EXISTS validation_min,
DROP COLUMN IF EXISTS validation_max,
DROP COLUMN IF EXISTS validation_prompt_threshold,
DROP COLUMN IF EXISTS validation_max_threshold;


-- =====================================================
-- 2. Add New JSONB Validation Column
-- =====================================================

ALTER TABLE data_entry_fields
ADD COLUMN IF NOT EXISTS validation_rules JSONB;

COMMENT ON COLUMN data_entry_fields.validation_rules IS
'JSONB validation rules supporting:
- absolute: {min, max, unit}
- relative: {comparison_field, max_duration_hours, prompt_message}
- enum: {allowed_values}
- custom: {validator_function, error_message}';


-- =====================================================
-- 3. Set Validation Rules for Common Field Types
-- =====================================================

-- Rating fields (1-10 scale)
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'absolute',
  'min', 1,
  'max', 10,
  'error_message', 'Rating must be between 1 and 10'
)
WHERE field_type = 'rating'
AND is_active = true;

-- Meal size (enum)
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'enum',
  'allowed_values', jsonb_build_array('small', 'regular', 'large'),
  'error_message', 'Meal size must be small, regular, or large'
)
WHERE field_name = 'meal_size'
AND is_active = true;

-- Screening result (enum)
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'enum',
  'allowed_values', jsonb_build_array('normal', 'abnormal', 'pending', 'inconclusive'),
  'error_message', 'Result must be normal, abnormal, pending, or inconclusive'
)
WHERE field_name = 'screening_result'
AND is_active = true;


-- =====================================================
-- 4. Set Relative Validation Rules (Time Pairs)
-- =====================================================

-- Cardio end time (relative to start time)
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'relative',
  'comparison_field', 'cardio_start_time',
  'must_be_after', true,
  'max_duration_hours', 8,
  'prompt_duration_hours', 3,
  'typical_duration_hours', jsonb_build_object('min', 0.5, 'max', 2),
  'prompt_message', 'This workout duration seems unusually long (>3 hours). Is this correct?',
  'error_message', 'End time must be after start time and within 8 hours'
)
WHERE field_name = 'cardio_end_time'
AND is_active = true;

-- Strength end time
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'relative',
  'comparison_field', 'strength_start_time',
  'must_be_after', true,
  'max_duration_hours', 4,
  'prompt_duration_hours', 2,
  'typical_duration_hours', jsonb_build_object('min', 0.5, 'max', 1.5),
  'prompt_message', 'This strength session seems unusually long (>2 hours). Is this correct?',
  'error_message', 'End time must be after start time and within 4 hours'
)
WHERE field_name = 'strength_end_time'
AND is_active = true;

-- Flexibility end time
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'relative',
  'comparison_field', 'flexibility_start_time',
  'must_be_after', true,
  'max_duration_hours', 2,
  'prompt_duration_hours', 1.5,
  'typical_duration_hours', jsonb_build_object('min', 0.25, 'max', 1),
  'prompt_message', 'This flexibility session seems unusually long (>1.5 hours). Is this correct?',
  'error_message', 'End time must be after start time and within 2 hours'
)
WHERE field_name = 'flexibility_end_time'
AND is_active = true;

-- Mindfulness end time
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'relative',
  'comparison_field', 'mindfulness_start_time',
  'must_be_after', true,
  'max_duration_hours', 2,
  'prompt_duration_hours', 1,
  'typical_duration_hours', jsonb_build_object('min', 0.08, 'max', 0.5),
  'prompt_message', 'This mindfulness session seems unusually long (>1 hour). Is this correct?',
  'error_message', 'End time must be after start time and within 2 hours'
)
WHERE field_name = 'mindfulness_end_time'
AND is_active = true;

-- Sleep wake time (relative to bedtime)
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'relative',
  'comparison_field', 'sleep_session_start',
  'must_be_after', true,
  'max_duration_hours', 16,
  'prompt_duration_hours', 12,
  'typical_duration_hours', jsonb_build_object('min', 6, 'max', 9),
  'prompt_message', 'This sleep duration seems unusually long (>12 hours). Is this correct?',
  'error_message', 'Wake time must be after bedtime and within 16 hours'
)
WHERE field_name = 'sleep_session_end'
AND is_active = true;

-- Sleep period end time
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'relative',
  'comparison_field', 'sleep_period_start',
  'must_be_after', true,
  'max_duration_hours', 4,
  'error_message', 'Period end must be after period start and within 4 hours'
)
WHERE field_name = 'sleep_period_end'
AND is_active = true;


-- =====================================================
-- 5. Set Quantity Validation Rules
-- =====================================================

-- Food quantity (positive numbers, typical serving sizes)
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'absolute',
  'min', 1,
  'max', 10000,
  'unit', 'grams',
  'typical_range', jsonb_build_object('min', 50, 'max', 500),
  'prompt_threshold', 1000,
  'prompt_message', 'This serving size seems very large (>1kg). Is this correct?',
  'error_message', 'Quantity must be between 1g and 10kg'
)
WHERE field_name = 'food_quantity'
AND is_active = true;

-- Beverage quantity
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'absolute',
  'min', 1,
  'max', 5000,
  'unit', 'ml',
  'typical_range', jsonb_build_object('min', 100, 'max', 500),
  'prompt_threshold', 2000,
  'prompt_message', 'This beverage amount seems very large (>2L). Is this correct?',
  'error_message', 'Quantity must be between 1ml and 5L'
)
WHERE field_name = 'beverage_quantity'
AND is_active = true;

-- Cardio distance
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'absolute',
  'min', 0.1,
  'max', 200,
  'unit', 'km',
  'typical_range', jsonb_build_object('min', 1, 'max', 20),
  'prompt_threshold', 50,
  'prompt_message', 'This distance seems very long (>50km). Is this correct?',
  'error_message', 'Distance must be between 0.1km and 200km'
)
WHERE field_name = 'cardio_distance'
AND is_active = true;

-- Substance quantity (for alcohol, caffeine, etc.)
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'absolute',
  'min', 1,
  'max', 1000,
  'unit', 'ml',
  'typical_range', jsonb_build_object('min', 30, 'max', 500),
  'prompt_threshold', 500,
  'prompt_message', 'This amount seems very high. Is this correct?',
  'error_message', 'Quantity must be between 1ml and 1L'
)
WHERE field_name = 'substance_quantity'
AND is_active = true;

-- Measurement value (context-dependent via measurement_types table)
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'context_dependent',
  'validation_source', 'measurement_types',
  'validation_fields', jsonb_build_array('healthy_range_min', 'healthy_range_max', 'critical_low', 'critical_high'),
  'error_message', 'Value must be within valid range for this measurement type'
)
WHERE field_name = 'measurement_value'
AND is_active = true;


-- =====================================================
-- 6. Set Timestamp Validation Rules (No Future Dates)
-- =====================================================

UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'timestamp',
  'max_date', 'now',
  'max_past_days', 365,
  'error_message', 'Date cannot be in the future or more than 1 year in the past'
)
WHERE field_type = 'timestamp'
AND is_active = true
AND validation_rules IS NULL;


-- =====================================================
-- 7. Set Reference Field Validation (Foreign Key Check)
-- =====================================================

-- All reference fields should validate against their reference table
UPDATE data_entry_fields
SET validation_rules = jsonb_build_object(
  'type', 'reference',
  'error_message', 'Must be a valid reference ID'
)
WHERE field_type = 'reference'
AND is_active = true
AND validation_rules IS NULL;


-- =====================================================
-- 8. Create Validation Helper Function
-- =====================================================

CREATE OR REPLACE FUNCTION validate_field_value(
  p_field_id TEXT,
  p_value JSONB,
  p_context JSONB DEFAULT NULL
) RETURNS JSONB AS $$
DECLARE
  v_field RECORD;
  v_rules JSONB;
  v_result JSONB;
  v_errors TEXT[];
  v_warnings TEXT[];
BEGIN
  -- Get field and its validation rules
  SELECT * INTO v_field
  FROM data_entry_fields
  WHERE field_id = p_field_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('valid', false, 'errors', jsonb_build_array('Field not found'));
  END IF;

  v_rules := v_field.validation_rules;

  IF v_rules IS NULL THEN
    RETURN jsonb_build_object('valid', true);
  END IF;

  -- Validate based on rule type
  CASE v_rules->>'type'
    WHEN 'absolute' THEN
      -- Check min/max
      IF (p_value->>'value')::numeric < (v_rules->>'min')::numeric THEN
        v_errors := array_append(v_errors, v_rules->>'error_message');
      ELSIF (p_value->>'value')::numeric > (v_rules->>'max')::numeric THEN
        v_errors := array_append(v_errors, v_rules->>'error_message');
      ELSIF v_rules ? 'prompt_threshold'
        AND (p_value->>'value')::numeric > (v_rules->>'prompt_threshold')::numeric THEN
        v_warnings := array_append(v_warnings, v_rules->>'prompt_message');
      END IF;

    WHEN 'relative' THEN
      -- Check relative to another field (requires context)
      IF p_context IS NOT NULL AND p_context ? (v_rules->>'comparison_field') THEN
        DECLARE
          v_start_time TIMESTAMPTZ;
          v_end_time TIMESTAMPTZ;
          v_duration_hours NUMERIC;
        BEGIN
          v_start_time := (p_context->(v_rules->>'comparison_field')->>'value')::timestamptz;
          v_end_time := (p_value->>'value')::timestamptz;
          v_duration_hours := EXTRACT(EPOCH FROM (v_end_time - v_start_time)) / 3600;

          IF v_end_time <= v_start_time THEN
            v_errors := array_append(v_errors, v_rules->>'error_message');
          ELSIF v_duration_hours > (v_rules->>'max_duration_hours')::numeric THEN
            v_errors := array_append(v_errors, v_rules->>'error_message');
          ELSIF v_rules ? 'prompt_duration_hours'
            AND v_duration_hours > (v_rules->>'prompt_duration_hours')::numeric THEN
            v_warnings := array_append(v_warnings, v_rules->>'prompt_message');
          END IF;
        END;
      END IF;

    WHEN 'enum' THEN
      -- Check if value is in allowed_values
      IF NOT (v_rules->'allowed_values' @> to_jsonb(p_value->>'value')) THEN
        v_errors := array_append(v_errors, v_rules->>'error_message');
      END IF;

    ELSE
      -- Unknown validation type
      NULL;
  END CASE;

  -- Build result
  v_result := jsonb_build_object(
    'valid', COALESCE(array_length(v_errors, 1), 0) = 0,
    'errors', to_jsonb(COALESCE(v_errors, ARRAY[]::TEXT[])),
    'warnings', to_jsonb(COALESCE(v_warnings, ARRAY[]::TEXT[]))
  );

  RETURN v_result;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validate_field_value IS
'Validates a field value against its validation_rules.
Parameters:
- p_field_id: The field_id from data_entry_fields
- p_value: JSONB object with {value: ...}
- p_context: JSONB object with other field values for relative validation
Returns: {valid: boolean, errors: [], warnings: []}';


-- =====================================================
-- 9. Create Summary View
-- =====================================================

CREATE OR REPLACE VIEW data_entry_fields_validation_summary AS
SELECT
  field_name,
  field_type,
  validation_rules->>'type' as validation_type,
  CASE
    WHEN validation_rules IS NULL THEN 'No validation'
    WHEN validation_rules->>'type' = 'absolute' THEN
      'Min: ' || (validation_rules->>'min') || ', Max: ' || (validation_rules->>'max')
    WHEN validation_rules->>'type' = 'relative' THEN
      'Compared to: ' || (validation_rules->>'comparison_field')
    WHEN validation_rules->>'type' = 'enum' THEN
      'Allowed: ' || (validation_rules->'allowed_values')::text
    ELSE validation_rules->>'type'
  END as validation_summary,
  validation_rules
FROM data_entry_fields
WHERE is_active = true
ORDER BY event_type_id, field_name;

COMMENT ON VIEW data_entry_fields_validation_summary IS
'Human-readable summary of validation rules for all active fields';

COMMIT;
