-- =====================================================
-- Auto-Assign Uncategorized Type When Type Field is Blank
-- =====================================================
-- Automatically sets type to "uncategorized" when optional
-- type field is left blank on data entry
-- =====================================================

BEGIN;

-- =====================================================
-- Function to Auto-Assign Uncategorized Type
-- =====================================================

CREATE OR REPLACE FUNCTION auto_assign_uncategorized_type()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_type_field_id TEXT;
  v_type_category TEXT;
  v_uncategorized_id UUID;
BEGIN
  -- Map field_id to corresponding type field and category
  v_type_field_id := CASE NEW.field_id
    WHEN 'DEF_VEGETABLES_SERVINGS' THEN 'DEF_VEGETABLES_TYPE'
    WHEN 'DEF_LEGUMES_SERVINGS' THEN 'DEF_LEGUMES_TYPE'
    WHEN 'DEF_FRUITS_SERVINGS' THEN 'DEF_FRUITS_TYPE'
    WHEN 'DEF_WHOLE_GRAINS_SERVINGS' THEN 'DEF_WHOLE_GRAINS_TYPE'
    WHEN 'DEF_HEALTHY_FATS_SERVINGS' THEN 'DEF_HEALTHY_FATS_TYPE'
    WHEN 'DEF_FIBER_GRAMS' THEN 'DEF_FIBER_TYPE'
    WHEN 'DEF_ADDED_SUGAR_GRAMS' THEN 'DEF_ADDED_SUGAR_TYPE'
    WHEN 'DEF_PROTEIN_GRAMS' THEN 'DEF_PROTEIN_TYPE'
    ELSE NULL
  END;

  -- If this field has a corresponding type field
  IF v_type_field_id IS NOT NULL THEN
    -- Get the category for this type field
    v_type_category := CASE v_type_field_id
      WHEN 'DEF_VEGETABLES_TYPE' THEN 'vegetables_types'
      WHEN 'DEF_LEGUMES_TYPE' THEN 'legumes_types'
      WHEN 'DEF_FRUITS_TYPE' THEN 'fruits_types'
      WHEN 'DEF_WHOLE_GRAINS_TYPE' THEN 'whole_grains_types'
      WHEN 'DEF_HEALTHY_FATS_TYPE' THEN 'healthy_fats_types'
      WHEN 'DEF_FIBER_TYPE' THEN 'fiber_types'
      WHEN 'DEF_ADDED_SUGAR_TYPE' THEN 'added_sugar_types'
      WHEN 'DEF_PROTEIN_TYPE' THEN 'protein_types'
      ELSE NULL
    END;

    -- Check if there's already a type entry for this event_instance_id
    IF NEW.event_instance_id IS NOT NULL THEN
      -- Check if type field already exists for this event
      IF NOT EXISTS (
        SELECT 1 FROM patient_data_entries
        WHERE event_instance_id = NEW.event_instance_id
          AND field_id = v_type_field_id
      ) THEN
        -- Get the uncategorized reference ID for this category
        SELECT id INTO v_uncategorized_id
        FROM data_entry_fields_reference
        WHERE reference_category = v_type_category
          AND reference_key = 'uncategorized'
        LIMIT 1;

        -- Insert uncategorized type entry if ID was found
        IF v_uncategorized_id IS NOT NULL THEN
          INSERT INTO patient_data_entries (
            patient_id,
            field_id,
            value_reference,
            entry_date,
            entry_timestamp,
            source,
            event_instance_id
          ) VALUES (
            NEW.patient_id,
            v_type_field_id,
            v_uncategorized_id::text,
            NEW.entry_date,
            NEW.entry_timestamp,
            NEW.source,
            NEW.event_instance_id
          );

          RAISE LOG 'Auto-assigned uncategorized type for % (event: %)',
            NEW.field_id, NEW.event_instance_id;
        END IF;
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- =====================================================
-- Create Trigger
-- =====================================================

DROP TRIGGER IF EXISTS auto_assign_uncategorized_type_trigger ON patient_data_entries;

CREATE TRIGGER auto_assign_uncategorized_type_trigger
  AFTER INSERT ON patient_data_entries
  FOR EACH ROW
  WHEN (NEW.field_id IN (
    'DEF_VEGETABLES_SERVINGS',
    'DEF_LEGUMES_SERVINGS',
    'DEF_FRUITS_SERVINGS',
    'DEF_WHOLE_GRAINS_SERVINGS',
    'DEF_HEALTHY_FATS_SERVINGS',
    'DEF_FIBER_GRAMS',
    'DEF_ADDED_SUGAR_GRAMS',
    'DEF_PROTEIN_GRAMS'
  ))
  EXECUTE FUNCTION auto_assign_uncategorized_type();

-- =====================================================
-- Summary
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Auto-Assign Uncategorized Type Trigger Created!';
  RAISE NOTICE '';
  RAISE NOTICE 'How it works:';
  RAISE NOTICE '  • Triggers AFTER INSERT on patient_data_entries';
  RAISE NOTICE '  • When quantity field is entered (e.g., DEF_VEGETABLES_SERVINGS)';
  RAISE NOTICE '  • Checks if corresponding type field exists for that event';
  RAISE NOTICE '  • If type field is missing, auto-creates it with "uncategorized"';
  RAISE NOTICE '';
  RAISE NOTICE 'Applies to:';
  RAISE NOTICE '  • Vegetables (DEF_VEGETABLES_SERVINGS → DEF_VEGETABLES_TYPE)';
  RAISE NOTICE '  • Legumes (DEF_LEGUMES_SERVINGS → DEF_LEGUMES_TYPE)';
  RAISE NOTICE '  • Fruits (DEF_FRUITS_SERVINGS → DEF_FRUITS_TYPE)';
  RAISE NOTICE '  • Whole Grains (DEF_WHOLE_GRAINS_SERVINGS → DEF_WHOLE_GRAINS_TYPE)';
  RAISE NOTICE '  • Healthy Fats (DEF_HEALTHY_FATS_SERVINGS → DEF_HEALTHY_FATS_TYPE)';
  RAISE NOTICE '  • Fiber (DEF_FIBER_GRAMS → DEF_FIBER_TYPE)';
  RAISE NOTICE '  • Added Sugar (DEF_ADDED_SUGAR_GRAMS → DEF_ADDED_SUGAR_TYPE)';
  RAISE NOTICE '  • Protein (DEF_PROTEIN_GRAMS → DEF_PROTEIN_TYPE)';
  RAISE NOTICE '';
  RAISE NOTICE 'Result: Type percentages will always add up to 100%';
  RAISE NOTICE '';
END $$;

COMMIT;
