-- =====================================================
-- Fix Sleep Duration OUTPUT Field Generation
-- =====================================================
-- Updates instance calculations to properly generate
-- type-specific OUTPUT fields from generic sleep periods
--
-- Created: 2025-10-29
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Update CALC_SLEEP_PERIOD_DURATION config to create BOTH outputs
-- =====================================================

-- Update config to include type-specific output mapping
UPDATE instance_calculations
SET calculation_config = jsonb_build_object(
    'output_field', 'DEF_SLEEP_PERIOD_DURATION',
    'output_source', 'auto_calculated',
    'output_unit', 'minute',
    'type_field', 'DEF_SLEEP_PERIOD_TYPE',
    'type_output_mapping', jsonb_build_object(
        'in_bed', 'OUTPUT_IN_BED_DURATION',
        'awake', 'OUTPUT_AWAKE_PERIODS_DURATION',
        'core', 'OUTPUT_CORE_SLEEP_DURATION',
        'deep', 'OUTPUT_DEEP_SLEEP_DURATION',
        'rem', 'OUTPUT_REM_SLEEP_DURATION',
        'unspecified', 'OUTPUT_UNSPECIFIED_SLEEP_DURATION'
    )
)
WHERE calc_id = 'CALC_SLEEP_PERIOD_DURATION';

-- =====================================================
-- 2. Remove standalone type-specific calculations
-- =====================================================
-- These are now handled by CALC_SLEEP_PERIOD_DURATION

-- Remove from event type dependencies first
DELETE FROM event_types_dependencies
WHERE instance_calculation_id IN (
    'CALC_CORE_SLEEP_DURATION',
    'CALC_DEEP_SLEEP_DURATION',
    'CALC_REM_SLEEP_DURATION',
    'CALC_IN_BED_DURATION',
    'CALC_UNSPECIFIED_SLEEP_DURATION'
);

-- Mark as inactive (don't delete in case referenced elsewhere)
UPDATE instance_calculations
SET is_active = false
WHERE calc_id IN (
    'CALC_CORE_SLEEP_DURATION',
    'CALC_DEEP_SLEEP_DURATION',
    'CALC_REM_SLEEP_DURATION',
    'CALC_IN_BED_DURATION',
    'CALC_UNSPECIFIED_SLEEP_DURATION'
);

COMMIT;

-- =====================================================
-- Verification
-- =====================================================

-- Check updated config
SELECT
    calc_id,
    calc_name,
    calculation_config
FROM instance_calculations
WHERE calc_id = 'CALC_SLEEP_PERIOD_DURATION';

-- Check inactive calculations
SELECT
    calc_id,
    calc_name,
    is_active
FROM instance_calculations
WHERE calc_id IN (
    'CALC_CORE_SLEEP_DURATION',
    'CALC_DEEP_SLEEP_DURATION',
    'CALC_REM_SLEEP_DURATION',
    'CALC_IN_BED_DURATION',
    'CALC_UNSPECIFIED_SLEEP_DURATION'
);
