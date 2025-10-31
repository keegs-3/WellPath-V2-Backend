-- =====================================================
-- Finalize Universal Reference Table
-- =====================================================
-- Adds constraints, indexes, and updates system to use data_entry_fields_reference
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Add Helpful Columns
-- =====================================================

-- Add sort_order for UI ordering
ALTER TABLE data_entry_fields_reference
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- Add is_active to hide/show items
ALTER TABLE data_entry_fields_reference
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Add description (can extract from metadata or add manually)
ALTER TABLE data_entry_fields_reference
ADD COLUMN IF NOT EXISTS description TEXT;

-- Add icon_name for UI icons
ALTER TABLE data_entry_fields_reference
ADD COLUMN IF NOT EXISTS icon_name TEXT;

-- Add color_hex for UI color coding
ALTER TABLE data_entry_fields_reference
ADD COLUMN IF NOT EXISTS color_hex TEXT;

-- =====================================================
-- 2. Add Missing Constraints and Indexes
-- =====================================================

-- Add unique constraint on category + key
ALTER TABLE data_entry_fields_reference
ADD CONSTRAINT data_entry_fields_reference_category_key_unique
UNIQUE (reference_category, reference_key);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_defref_category
ON data_entry_fields_reference(reference_category);

CREATE INDEX IF NOT EXISTS idx_defref_category_key
ON data_entry_fields_reference(reference_category, reference_key);

-- Add check constraints
ALTER TABLE data_entry_fields_reference
ADD CONSTRAINT check_reference_category_not_empty
CHECK (reference_category IS NOT NULL AND reference_category != '');

ALTER TABLE data_entry_fields_reference
ADD CONSTRAINT check_reference_key_not_empty
CHECK (reference_key IS NOT NULL AND reference_key != '');

ALTER TABLE data_entry_fields_reference
ADD CONSTRAINT check_display_name_not_empty
CHECK (display_name IS NOT NULL AND display_name != '');

-- Add comments
COMMENT ON TABLE data_entry_fields_reference IS 'Universal reference table for all categorical data (protein types, meal timing, vegetables, etc.)';
COMMENT ON COLUMN data_entry_fields_reference.reference_category IS 'Category of reference (protein_type, meal_timing, vegetable_type, etc.)';
COMMENT ON COLUMN data_entry_fields_reference.reference_key IS 'Unique key within category (fatty_fish, breakfast, broccoli, etc.)';
COMMENT ON COLUMN data_entry_fields_reference.metadata IS 'Category-specific attributes stored as JSON';
COMMENT ON COLUMN data_entry_fields_reference.sort_order IS 'UI display order within category (lower = first)';
COMMENT ON COLUMN data_entry_fields_reference.is_active IS 'Whether this reference value is active and should be shown';
COMMENT ON COLUMN data_entry_fields_reference.description IS 'Extended description or help text for UI';
COMMENT ON COLUMN data_entry_fields_reference.icon_name IS 'Icon identifier for UI (e.g., MaterialIcons name)';
COMMENT ON COLUMN data_entry_fields_reference.color_hex IS 'Hex color code for UI (e.g., #FF5733)';

-- Populate sort_order based on current ordering (alphabetical within category)
WITH numbered AS (
  SELECT
    id,
    ROW_NUMBER() OVER (PARTITION BY reference_category ORDER BY display_name) AS rn
  FROM data_entry_fields_reference
)
UPDATE data_entry_fields_reference
SET sort_order = numbered.rn
FROM numbered
WHERE data_entry_fields_reference.id = numbered.id;

-- =====================================================
-- 3. Create Helper Function for Category Filtering
-- =====================================================
CREATE OR REPLACE FUNCTION get_reference_id(
  p_category TEXT,
  p_key TEXT
) RETURNS UUID
LANGUAGE sql STABLE
AS $$
  SELECT id
  FROM data_entry_fields_reference
  WHERE reference_category = p_category
    AND reference_key = p_key
  LIMIT 1;
$$;

COMMENT ON FUNCTION get_reference_id IS 'Get UUID for a reference value by category and key';

-- =====================================================
-- 4. Update Data Entry Fields to Use Universal Table
-- =====================================================

-- Update all reference fields to point to the universal table
UPDATE data_entry_fields
SET reference_table = 'data_entry_fields_reference',
    updated_at = NOW()
WHERE field_type = 'reference'
  AND (reference_table LIKE 'def_ref_%' OR reference_table IS NULL);

-- =====================================================
-- 5. Update Aggregation Filter Logic
-- =====================================================

-- Update calculate_field_aggregation to work with the universal table
CREATE OR REPLACE FUNCTION public.calculate_field_aggregation(
  p_patient_id uuid,
  p_field_id text,
  p_period_start timestamp with time zone,
  p_period_end timestamp with time zone,
  p_calculation_type text,
  p_filter_conditions jsonb DEFAULT NULL
)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_result NUMERIC;
  v_ref_field TEXT;
  v_ref_value TEXT;
  v_ref_category TEXT;
BEGIN
  -- Extract filter conditions if present
  IF p_filter_conditions IS NOT NULL THEN
    v_ref_field := p_filter_conditions->>'reference_field';
    v_ref_value := p_filter_conditions->>'reference_value';

    -- Get the reference category from the reference field
    -- For DEF_PROTEIN_TIMING → protein_timing
    -- For DEF_PROTEIN_TYPE → protein_types
    v_ref_category := LOWER(REPLACE(REPLACE(v_ref_field, 'DEF_', ''), '_', '_'));
  END IF;

  CASE p_calculation_type
    WHEN 'AVG' THEN
      IF p_filter_conditions IS NOT NULL THEN
        -- Filtered aggregation: JOIN to universal reference table
        EXECUTE format('
          SELECT COALESCE(AVG(pde.value_quantity), 0)
          FROM patient_data_entries pde
          INNER JOIN patient_data_entries pde_ref
            ON pde.patient_id = pde_ref.patient_id
            AND pde.entry_timestamp = pde_ref.entry_timestamp
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
      ELSE
        -- No filtering
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
        EXECUTE format('
          SELECT COALESCE(SUM(pde.value_quantity), 0)
          FROM patient_data_entries pde
          INNER JOIN patient_data_entries pde_ref
            ON pde.patient_id = pde_ref.patient_id
            AND pde.entry_timestamp = pde_ref.entry_timestamp
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

    WHEN 'MAX', 'MIN', 'COUNT', 'COUNT_DISTINCT' THEN
      -- For now, these don't support filtering
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

    ELSE
      v_result := 0;
  END CASE;

  RETURN COALESCE(v_result, 0);
END;
$function$;

-- =====================================================
-- 6. Create Compatibility Views for Old Table Names
-- =====================================================

-- Drop old tables if they exist (replace with views)
DROP TABLE IF EXISTS def_ref_protein_timing CASCADE;
DROP TABLE IF EXISTS def_ref_protein_types CASCADE;
DROP TABLE IF EXISTS def_ref_food_timing CASCADE;

-- Protein Timing View
CREATE OR REPLACE VIEW def_ref_protein_timing AS
SELECT
  id,
  reference_key AS timing_key,
  display_name,
  COALESCE(description, metadata->>'description') AS description,
  (metadata->>'typical_hour_start')::INTEGER AS typical_hour_start,
  (metadata->>'typical_hour_end')::INTEGER AS typical_hour_end,
  sort_order,
  is_active,
  created_at
FROM data_entry_fields_reference
WHERE reference_category = 'protein_timing';

-- Protein Types View
CREATE OR REPLACE VIEW def_ref_protein_types AS
SELECT
  id,
  reference_key AS protein_type_key,
  display_name,
  COALESCE(description, metadata->>'description') AS description,
  (metadata->>'is_plant_based')::BOOLEAN AS is_plant_based,
  (metadata->>'typical_grams_per_serving')::INTEGER AS typical_grams_per_serving,
  sort_order,
  is_active,
  created_at
FROM data_entry_fields_reference
WHERE reference_category = 'protein_types';

-- Food Timing View
CREATE OR REPLACE VIEW def_ref_food_timing AS
SELECT
  id,
  reference_key AS timing_key,
  display_name,
  COALESCE(description, metadata->>'description') AS description,
  (metadata->>'typical_hour_start')::INTEGER AS typical_hour_start,
  (metadata->>'typical_hour_end')::INTEGER AS typical_hour_end,
  sort_order,
  is_active,
  created_at
FROM data_entry_fields_reference
WHERE reference_category = 'food_timing';

-- =====================================================
-- Summary
-- =====================================================
DO $$
DECLARE
  v_total_refs INTEGER;
  v_categories INTEGER;
  v_updated_fields INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total_refs FROM data_entry_fields_reference;
  SELECT COUNT(DISTINCT reference_category) INTO v_categories FROM data_entry_fields_reference;
  SELECT COUNT(*) INTO v_updated_fields FROM data_entry_fields WHERE reference_table = 'data_entry_fields_reference';

  RAISE NOTICE '';
  RAISE NOTICE '✅ Finalized Universal Reference Table!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Total reference values: %', v_total_refs;
  RAISE NOTICE '  Reference categories: %', v_categories;
  RAISE NOTICE '  Data entry fields updated: %', v_updated_fields;
  RAISE NOTICE '';
  RAISE NOTICE 'Categories:';
  RAISE NOTICE '  • added_sugar_types, beverage_types, caffeine_types';
  RAISE NOTICE '  • cardio_types, fat_types, fiber_sources';
  RAISE NOTICE '  • food_timing, food_types, hiit_types';
  RAISE NOTICE '  • meal_qualifiers, meal_types, mobility_types';
  RAISE NOTICE '  • muscle_groups, processed_meat_types';
  RAISE NOTICE '  • protein_timing, protein_types';
  RAISE NOTICE '  • screen_time_types, skincare_steps';
  RAISE NOTICE '  • sleep_period_types, social_event_types';
  RAISE NOTICE '  • strength_types, substance_types';
  RAISE NOTICE '  • sunlight_types, sunscreen_types';
  RAISE NOTICE '  • ultra_processed_types, unhealthy_beverage_types';
  RAISE NOTICE '  • water_units';
  RAISE NOTICE '';
  RAISE NOTICE 'Features:';
  RAISE NOTICE '  ✅ Unique constraint on (reference_category, reference_key)';
  RAISE NOTICE '  ✅ Indexes for performance';
  RAISE NOTICE '  ✅ Helper function: get_reference_id(category, key)';
  RAISE NOTICE '  ✅ All reference fields updated to use universal table';
  RAISE NOTICE '  ✅ Aggregation filtering updated';
  RAISE NOTICE '  ✅ Backward compatibility views created';
  RAISE NOTICE '';
  RAISE NOTICE 'New Columns:';
  RAISE NOTICE '  • sort_order - UI ordering (populated alphabetically by default)';
  RAISE NOTICE '  • is_active - Hide/show items (all true by default)';
  RAISE NOTICE '  • description - Extended description for UI';
  RAISE NOTICE '  • icon_name - Icon identifier (null by default)';
  RAISE NOTICE '  • color_hex - Color code for UI (null by default)';
  RAISE NOTICE '';
END $$;

COMMIT;
