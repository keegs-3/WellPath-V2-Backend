-- Update calculate_field_aggregation to handle "unassigned" cases
-- When filter_conditions contains {"no_match": true}, it finds entries WITHOUT a matching reference

CREATE OR REPLACE FUNCTION public.calculate_field_aggregation(
  p_patient_id uuid,
  p_field_id text,
  p_period_start timestamp with time zone,
  p_period_end timestamp with time zone,
  p_calculation_type text,
  p_filter_conditions jsonb DEFAULT NULL::jsonb
)
RETURNS numeric
LANGUAGE plpgsql
AS $function$
DECLARE
  v_result NUMERIC;
  v_ref_field TEXT;
  v_ref_value TEXT;
  v_no_match BOOLEAN;
  v_ref_category TEXT;
  v_sql TEXT;
BEGIN
  -- Extract filter conditions if present
  IF p_filter_conditions IS NOT NULL THEN
    v_ref_field := p_filter_conditions->>'reference_field';
    v_ref_value := p_filter_conditions->>'reference_value';
    v_no_match := COALESCE((p_filter_conditions->>'no_match')::boolean, false);
    v_ref_category := LOWER(REPLACE(REPLACE(v_ref_field, 'DEF_', ''), '_', '_'));
  END IF;

  CASE p_calculation_type
    WHEN 'AVG' THEN
      IF p_filter_conditions IS NOT NULL THEN
        IF v_no_match THEN
          -- Find entries WITHOUT a matching reference entry
          EXECUTE format('
            SELECT COALESCE(AVG(pde.value_quantity), 0)
            FROM patient_data_entries pde
            LEFT JOIN patient_data_entries pde_ref
              ON pde.patient_id = pde_ref.patient_id
              AND pde.event_instance_id = pde_ref.event_instance_id
              AND pde_ref.field_id = $5
            WHERE pde.patient_id = $1
              AND pde.field_id = $2
              AND pde.entry_timestamp >= $3
              AND pde.entry_timestamp < $4
              AND pde.source != ''deleted''
              AND pde_ref.id IS NULL  -- No matching reference entry
          ')
          INTO v_result
          USING p_patient_id, p_field_id, p_period_start, p_period_end, v_ref_field;
        ELSE
          -- Original logic: find entries WITH matching reference
          EXECUTE format('
            SELECT COALESCE(AVG(pde.value_quantity), 0)
            FROM patient_data_entries pde
            INNER JOIN patient_data_entries pde_ref
              ON pde.patient_id = pde_ref.patient_id
              AND pde.event_instance_id = pde_ref.event_instance_id
            INNER JOIN data_entry_fields_reference ref
              ON pde_ref.value_reference::uuid = ref.id
            WHERE pde.patient_id = $1
              AND pde.field_id = $2
              AND pde.entry_timestamp >= $3
              AND pde.entry_timestamp < $4
              AND pde.source != ''deleted''
              AND pde_ref.field_id = $5
              AND ref.reference_key = $6
          ')
          INTO v_result
          USING p_patient_id, p_field_id, p_period_start, p_period_end, v_ref_field, v_ref_value;
        END IF;
      ELSE
        SELECT COALESCE(AVG(value_quantity), 0)
        INTO v_result
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = p_field_id
          AND entry_timestamp >= p_period_start
          AND entry_timestamp < p_period_end
          AND source != 'deleted';
      END IF;

    WHEN 'SUM' THEN
      IF p_filter_conditions IS NOT NULL THEN
        IF v_no_match THEN
          -- Find entries WITHOUT a matching reference entry
          EXECUTE format('
            SELECT COALESCE(SUM(pde.value_quantity), 0)
            FROM patient_data_entries pde
            LEFT JOIN patient_data_entries pde_ref
              ON pde.patient_id = pde_ref.patient_id
              AND pde.event_instance_id = pde_ref.event_instance_id
              AND pde_ref.field_id = $5
            WHERE pde.patient_id = $1
              AND pde.field_id = $2
              AND pde.entry_timestamp >= $3
              AND pde.entry_timestamp < $4
              AND pde.source != ''deleted''
              AND pde_ref.id IS NULL  -- No matching reference entry
          ')
          INTO v_result
          USING p_patient_id, p_field_id, p_period_start, p_period_end, v_ref_field;
        ELSE
          -- Original logic: find entries WITH matching reference
          EXECUTE format('
            SELECT COALESCE(SUM(pde.value_quantity), 0)
            FROM patient_data_entries pde
            INNER JOIN patient_data_entries pde_ref
              ON pde.patient_id = pde_ref.patient_id
              AND pde.event_instance_id = pde_ref.event_instance_id
            INNER JOIN data_entry_fields_reference ref
              ON pde_ref.value_reference::uuid = ref.id
            WHERE pde.patient_id = $1
              AND pde.field_id = $2
              AND pde.entry_timestamp >= $3
              AND pde.entry_timestamp < $4
              AND pde.source != ''deleted''
              AND pde_ref.field_id = $5
              AND ref.reference_key = $6
          ')
          INTO v_result
          USING p_patient_id, p_field_id, p_period_start, p_period_end, v_ref_field, v_ref_value;
        END IF;
      ELSE
        SELECT COALESCE(SUM(value_quantity), 0)
        INTO v_result
        FROM patient_data_entries
        WHERE patient_id = p_patient_id
          AND field_id = p_field_id
          AND entry_timestamp >= p_period_start
          AND entry_timestamp < p_period_end
          AND source != 'deleted';
      END IF;

    WHEN 'MAX', 'MIN', 'COUNT' THEN
      EXECUTE format('
        SELECT COALESCE(%s(value_quantity), 0)
        FROM patient_data_entries
        WHERE patient_id = $1
          AND field_id = $2
          AND entry_timestamp >= $3
          AND entry_timestamp < $4
          AND source != ''deleted''
      ', p_calculation_type)
      INTO v_result
      USING p_patient_id, p_field_id, p_period_start, p_period_end;

    WHEN 'COUNT_DISTINCT' THEN
      -- Special case: COUNT_DISTINCT needs COUNT(DISTINCT ...) syntax
      SELECT COUNT(DISTINCT value_reference)
      INTO v_result
      FROM patient_data_entries
      WHERE patient_id = p_patient_id
        AND field_id = p_field_id
        AND entry_timestamp >= p_period_start
        AND entry_timestamp < p_period_end
        AND source != 'deleted';

    ELSE
      v_result := 0;
  END CASE;

  RETURN COALESCE(v_result, 0);
END;
$function$;

SELECT '✅ Updated calculate_field_aggregation to handle unassigned (no_match) cases' as status;
