-- =====================================================
-- Clean Up Instance Calculations
-- =====================================================
-- 1. Deprecate redundant session_duration calculations (now handled by generic event duration)
-- 2. Keep essential calculations (BMI, compliance, age, sleep metrics)
-- 3. Add missing body composition calculations
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Deprecate Redundant Session Duration Calculations
-- =====================================================
-- These are now redundant because we have generic start_time/end_time fields
-- Duration = end_time - start_time for any event

UPDATE instance_calculations
SET
  is_active = false,
  updated_at = now()
WHERE calc_name LIKE 'session_%_duration_time_difference'
AND is_active = true;

-- Log what was deprecated
DO $$
DECLARE
  deprecated_count INT;
BEGIN
  SELECT COUNT(*) INTO deprecated_count
  FROM instance_calculations
  WHERE calc_name LIKE 'session_%_duration_time_difference'
  AND is_active = false;

  RAISE NOTICE 'Deprecated % session duration calculations', deprecated_count;
END $$;


-- =====================================================
-- 2. Deprecate Individual Screening Time Calculations
-- =====================================================
-- These can be generic: measurement_time - now() for any screening

UPDATE instance_calculations
SET
  is_active = false,
  updated_at = now()
WHERE (
  calc_name LIKE 'current_months_since_%_time_difference'
  OR calc_name LIKE 'current_years_since_%_time_difference'
)
AND calc_name NOT LIKE '%sleep%'  -- Keep sleep period calculations
AND is_active = true;


-- =====================================================
-- 3. Keep Essential Calculations (Mark as Active)
-- =====================================================
-- These are truly custom and cannot be generic

-- Body composition calculations
UPDATE instance_calculations
SET is_active = true
WHERE calc_id IN (
  'IC_045',  -- current_bmi_calculated
  'IC_046'   -- current_hip_to_waist_ratio
);

-- Age calculation
UPDATE instance_calculations
SET is_active = true
WHERE calc_name LIKE '%user_age%';

-- Sleep period durations (REM, deep, core, awake)
UPDATE instance_calculations
SET is_active = true
WHERE calc_name LIKE 'period_%_duration_time_difference';

-- Sleep consistency metrics (std_dev)
UPDATE instance_calculations
SET is_active = true
WHERE calc_name LIKE '%sleep%consistency%std_dev';

-- Screening compliance calculations (custom logic with age/gender rules)
UPDATE instance_calculations
SET is_active = true
WHERE calc_name LIKE 'current_compliance_%_custom_calc';


-- =====================================================
-- 4. Add Missing Body Composition Calculations
-- =====================================================

-- Skeletal Muscle Mass (from lean mass and body fat)
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(),
  'IC_100',
  'current_skeletal_muscle_mass_calculated',
  'Skeletal Muscle Mass',
  'Calculated skeletal muscle mass from lean mass',
  'custom_calc',
  'lean_mass * 0.5',  -- Approximation: ~50% of lean mass is skeletal muscle
  ARRAY['lean_mass'],
  'kilogram',
  true,
  true
) ON CONFLICT (calc_id) DO UPDATE SET
  calc_name = EXCLUDED.calc_name,
  display_name = EXCLUDED.display_name,
  formula_definition = EXCLUDED.formula_definition,
  is_active = true,
  updated_at = now();

-- Fat-Free Mass (lean mass + bone mass approximation)
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(),
  'IC_101',
  'current_fat_free_mass_calculated',
  'Fat-Free Mass',
  'Total fat-free mass (lean mass)',
  'custom_calc',
  'lean_mass',  -- Lean mass IS fat-free mass in HealthKit
  ARRAY['lean_mass'],
  'kilogram',
  true,
  true
) ON CONFLICT (calc_id) DO UPDATE SET
  calc_name = EXCLUDED.calc_name,
  display_name = EXCLUDED.display_name,
  is_active = true,
  updated_at = now();

-- Skeletal Muscle Mass to Fat-Free Mass Ratio
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(),
  'IC_102',
  'current_skeletal_muscle_to_ffm_ratio',
  'Skeletal Muscle / FFM Ratio',
  'Ratio of skeletal muscle mass to fat-free mass',
  'divide',
  'skeletal_muscle_mass / fat_free_mass',
  ARRAY['skeletal_muscle_mass', 'fat_free_mass'],
  'percentage',
  true,
  true
) ON CONFLICT (calc_id) DO UPDATE SET
  calc_name = EXCLUDED.calc_name,
  display_name = EXCLUDED.display_name,
  is_active = true,
  updated_at = now();

-- Waist-to-Height Ratio (better than BMI for health risk)
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(),
  'IC_103',
  'current_waist_to_height_ratio',
  'Waist-to-Height Ratio',
  'Waist circumference divided by height (health risk indicator)',
  'divide',
  'waist / height',
  ARRAY['waist', 'height'],
  'ratio',
  true,
  true
) ON CONFLICT (calc_id) DO UPDATE SET
  calc_name = EXCLUDED.calc_name,
  display_name = EXCLUDED.display_name,
  is_active = true,
  updated_at = now();

-- Body Fat Mass (calculated from weight and body fat %)
INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(),
  'IC_104',
  'current_body_fat_mass_calculated',
  'Body Fat Mass',
  'Total body fat mass in kg',
  'custom_calc',
  'weight * (body_fat / 100)',
  ARRAY['weight', 'body_fat'],
  'kilogram',
  true,
  true
) ON CONFLICT (calc_id) DO UPDATE SET
  calc_name = EXCLUDED.calc_name,
  display_name = EXCLUDED.display_name,
  is_active = true,
  updated_at = now();


-- =====================================================
-- 5. Create Generic Event Duration Calculation Template
-- =====================================================
-- Single generic calculation that works for ALL event types

INSERT INTO instance_calculations (
  id, calc_id, calc_name, display_name, description,
  calculation_method, formula_definition, depends_on_fields,
  unit_id, is_displayed_to_user, is_active
) VALUES (
  gen_random_uuid(),
  'IC_999',
  'generic_event_duration',
  'Event Duration',
  'Generic duration calculation for any event with start/end time',
  'time_difference',
  'end_time - start_time',
  ARRAY['start_time', 'end_time'],
  'minute',
  true,
  true
) ON CONFLICT (calc_id) DO UPDATE SET
  calc_name = EXCLUDED.calc_name,
  display_name = EXCLUDED.display_name,
  is_active = true,
  updated_at = now();


-- =====================================================
-- 6. Summary Report
-- =====================================================

DO $$
DECLARE
  total_active INT;
  total_inactive INT;
  rec RECORD;
BEGIN
  SELECT COUNT(*) INTO total_active
  FROM instance_calculations
  WHERE is_active = true;

  SELECT COUNT(*) INTO total_inactive
  FROM instance_calculations
  WHERE is_active = false;

  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Instance Calculations Cleanup Summary:';
  RAISE NOTICE '===========================================';
  RAISE NOTICE 'Active calculations: %', total_active;
  RAISE NOTICE 'Deprecated calculations: %', total_inactive;
  RAISE NOTICE '';
  RAISE NOTICE 'Active calculations by type:';

  FOR rec IN
    SELECT calculation_method, COUNT(*) as count
    FROM instance_calculations
    WHERE is_active = true
    GROUP BY calculation_method
    ORDER BY count DESC
  LOOP
    RAISE NOTICE '  %: %', rec.calculation_method, rec.count;
  END LOOP;
END $$;

COMMIT;
