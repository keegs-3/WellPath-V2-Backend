-- =====================================================
-- Cleanup Old Flexibility Table
-- =====================================================
-- Drops the old z_old_def_ref_flexibility_types table
-- since we've replaced it with def_ref_mobility_types
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Drop the old flexibility types table
DROP TABLE IF EXISTS z_old_def_ref_flexibility_types CASCADE;

DO $$
BEGIN
  RAISE NOTICE 'Dropped z_old_def_ref_flexibility_types - replaced by def_ref_mobility_types';
END $$;

COMMIT;
