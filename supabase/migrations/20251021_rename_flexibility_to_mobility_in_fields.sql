-- =====================================================
-- Rename Flexibility to Mobility in data_entry_fields
-- =====================================================
-- Updates old flexibility fields to use mobility terminology
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Mark old flexibility fields as inactive
UPDATE data_entry_fields SET is_active = false
WHERE field_id IN (
  'DEF_FLEXIBILITY_TYPE',
  'DEF_FLEXIBILITY_START',
  'DEF_FLEXIBILITY_END',
  'DEF_FLEXIBILITY_INTENSITY'
);

-- The new mobility fields were already created in the previous migration
-- Just ensure they're active
UPDATE data_entry_fields SET is_active = true
WHERE field_id IN (
  'DEF_MOBILITY_TYPE',
  'DEF_MOBILITY_START',
  'DEF_MOBILITY_END',
  'DEF_MOBILITY_INTENSITY'
);

DO $$
DECLARE
  old_count INTEGER;
  new_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO old_count
  FROM data_entry_fields
  WHERE field_id LIKE 'DEF_FLEXIBILITY%' AND is_active = false;

  SELECT COUNT(*) INTO new_count
  FROM data_entry_fields
  WHERE field_id LIKE 'DEF_MOBILITY%' AND is_active = true;

  RAISE NOTICE '=========================================';
  RAISE NOTICE 'Renamed Flexibility to Mobility';
  RAISE NOTICE '=========================================';
  RAISE NOTICE 'Old flexibility fields marked inactive: %', old_count;
  RAISE NOTICE 'New mobility fields active: %', new_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Mobility fields:';
  RAISE NOTICE '  - DEF_MOBILITY_TYPE';
  RAISE NOTICE '  - DEF_MOBILITY_START';
  RAISE NOTICE '  - DEF_MOBILITY_END';
  RAISE NOTICE '  - DEF_MOBILITY_INTENSITY';
END $$;

COMMIT;
