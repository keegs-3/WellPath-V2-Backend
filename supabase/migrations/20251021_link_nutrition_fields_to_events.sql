-- =====================================================
-- Link Nutrition Fields to Event Types
-- =====================================================
-- Assigns data_entry_fields to their corresponding event_type_id
-- for proper event creation and instance calculation triggering
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Link Fiber Fields to fiber_intake Event
-- =====================================================

UPDATE data_entry_fields
SET event_type_id = 'fiber_intake'
WHERE field_id IN (
  'DEF_FIBER_SOURCE',
  'DEF_FIBER_SERVINGS',
  'DEF_FIBER_GRAMS',
  'DEF_FIBER_TIME'
);


-- =====================================================
-- PART 2: Link Vegetable Fields to vegetable_intake Event
-- =====================================================

UPDATE data_entry_fields
SET event_type_id = 'vegetable_intake'
WHERE field_id IN (
  'DEF_VEGETABLE_TYPE',
  'DEF_VEGETABLE_SERVINGS',
  'DEF_VEGETABLE_TIME',
  'DEF_VEGETABLE_QUANTITY'  -- Legacy field, keeping for compatibility
);


-- =====================================================
-- PART 3: Link Fruit Fields to fruit_intake Event
-- =====================================================

UPDATE data_entry_fields
SET event_type_id = 'fruit_intake'
WHERE field_id IN (
  'DEF_FRUIT_TYPE',
  'DEF_FRUIT_SERVINGS',
  'DEF_FRUIT_TIME'
);


-- =====================================================
-- PART 4: Link Whole Grain Fields to whole_grain_intake Event
-- =====================================================

UPDATE data_entry_fields
SET event_type_id = 'whole_grain_intake'
WHERE field_id IN (
  'DEF_WHOLE_GRAIN_TYPE',
  'DEF_WHOLE_GRAIN_SERVINGS',
  'DEF_WHOLE_GRAIN_TIME'
);


-- =====================================================
-- PART 5: Link Legume Fields to legume_intake Event
-- =====================================================

UPDATE data_entry_fields
SET event_type_id = 'legume_intake'
WHERE field_id IN (
  'DEF_LEGUME_TYPE',
  'DEF_LEGUME_SERVINGS',
  'DEF_LEGUME_TIME'
);


-- =====================================================
-- PART 6: Link Nut/Seed Fields to nut_seed_intake Event
-- =====================================================

UPDATE data_entry_fields
SET event_type_id = 'nut_seed_intake'
WHERE field_id IN (
  'DEF_NUT_SEED_TYPE',
  'DEF_NUT_SEED_SERVINGS',
  'DEF_NUT_SEED_TIME'
);


-- =====================================================
-- PART 7: Link Protein Fields to protein_intake Event
-- =====================================================

UPDATE data_entry_fields
SET event_type_id = 'protein_intake'
WHERE field_id IN (
  'DEF_PROTEIN_TYPE',
  'DEF_PROTEIN_SERVINGS',
  'DEF_PROTEIN_GRAMS',
  'DEF_PROTEIN_TIME'
);


-- =====================================================
-- PART 8: Link Fat Fields to fat_intake Event
-- =====================================================

UPDATE data_entry_fields
SET event_type_id = 'fat_intake'
WHERE field_id IN (
  'DEF_FAT_TYPE',
  'DEF_FAT_SERVINGS',
  'DEF_FAT_GRAMS',
  'DEF_FAT_TIME'
);


-- =====================================================
-- PART 9: Verify Linkages
-- =====================================================

-- Count fields per nutrition event
DO $$
DECLARE
  fiber_count INT;
  veg_count INT;
  fruit_count INT;
  grain_count INT;
  legume_count INT;
  nut_count INT;
  protein_count INT;
  fat_count INT;
BEGIN
  SELECT COUNT(*) INTO fiber_count FROM data_entry_fields WHERE event_type_id = 'fiber_intake';
  SELECT COUNT(*) INTO veg_count FROM data_entry_fields WHERE event_type_id = 'vegetable_intake';
  SELECT COUNT(*) INTO fruit_count FROM data_entry_fields WHERE event_type_id = 'fruit_intake';
  SELECT COUNT(*) INTO grain_count FROM data_entry_fields WHERE event_type_id = 'whole_grain_intake';
  SELECT COUNT(*) INTO legume_count FROM data_entry_fields WHERE event_type_id = 'legume_intake';
  SELECT COUNT(*) INTO nut_count FROM data_entry_fields WHERE event_type_id = 'nut_seed_intake';
  SELECT COUNT(*) INTO protein_count FROM data_entry_fields WHERE event_type_id = 'protein_intake';
  SELECT COUNT(*) INTO fat_count FROM data_entry_fields WHERE event_type_id = 'fat_intake';

  RAISE NOTICE 'Nutrition Event Field Counts:';
  RAISE NOTICE '  fiber_intake: % fields', fiber_count;
  RAISE NOTICE '  vegetable_intake: % fields', veg_count;
  RAISE NOTICE '  fruit_intake: % fields', fruit_count;
  RAISE NOTICE '  whole_grain_intake: % fields', grain_count;
  RAISE NOTICE '  legume_intake: % fields', legume_count;
  RAISE NOTICE '  nut_seed_intake: % fields', nut_count;
  RAISE NOTICE '  protein_intake: % fields', protein_count;
  RAISE NOTICE '  fat_intake: % fields', fat_count;
END $$;


COMMIT;
