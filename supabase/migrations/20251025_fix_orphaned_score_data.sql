-- =====================================================
-- Fix Orphaned Score Data for Patient 3
-- =====================================================
-- Issue: patient_wellpath_score_items has old UUID for patient 3
-- Old: d9581a86-0f30-4be4-ba9e-6ae269700d4d
-- New: e21d19f7-4f80-4b76-b047-a74a4e87956e
-- =====================================================

BEGIN;

DO $$
DECLARE
  v_old_uuid UUID := 'd9581a86-0f30-4be4-ba9e-6ae269700d4d'::UUID;
  v_new_uuid UUID := 'e21d19f7-4f80-4b76-b047-a74a4e87956e'::UUID;
  v_updated_count INTEGER;
BEGIN
  -- Update patient_wellpath_score_items
  UPDATE patient_wellpath_score_items
  SET user_id = v_new_uuid
  WHERE user_id = v_old_uuid;

  GET DIAGNOSTICS v_updated_count = ROW_COUNT;

  RAISE NOTICE '✅ Fixed % score items with old patient 3 UUID', v_updated_count;
  RAISE NOTICE '  Old UUID: %', v_old_uuid;
  RAISE NOTICE '  New UUID: %', v_new_uuid;
END $$;

-- Verify: Check for any remaining orphaned data in score tables
DO $$
DECLARE
  v_orphaned_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_orphaned_count
  FROM patient_wellpath_score_items pwsi
  WHERE NOT EXISTS (
    SELECT 1 FROM patients p WHERE p.patient_id = pwsi.user_id
  );

  IF v_orphaned_count > 0 THEN
    RAISE WARNING '⚠️  Found % orphaned score items (user_id not in patients)', v_orphaned_count;
  ELSE
    RAISE NOTICE '✅ All score items now have valid patient references';
  END IF;
END $$;

COMMIT;
