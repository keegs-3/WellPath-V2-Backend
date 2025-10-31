-- =====================================================
-- Cleanup: Remove Unused Event Tables
-- =====================================================
-- Removes empty patient_events tables that are not being used
-- Keeps patient_sleep_periods for HealthKit sleep import
--
-- Created: 2025-10-24
-- Reason: Architecture simplified to use patient_data_entries only
-- =====================================================

-- Drop tables in dependency order (foreign keys first)
-- These tables are completely empty and not part of the current architecture

DROP TABLE IF EXISTS patient_correlation_events CASCADE;
DROP TABLE IF EXISTS patient_workout_events CASCADE;
DROP TABLE IF EXISTS patient_category_events CASCADE;
DROP TABLE IF EXISTS patient_quantity_events CASCADE;
DROP TABLE IF EXISTS patient_events CASCADE;

-- Note: patient_sleep_periods is KEPT for HealthKit sleep import

SELECT '
========================================
✅ Unused Event Tables Removed
========================================

Deleted:
  - patient_events
  - patient_quantity_events
  - patient_category_events
  - patient_workout_events
  - patient_correlation_events

Kept:
  - patient_sleep_periods (for HealthKit sleep)

Current Architecture:
  patient_data_entries (single source of truth)
    ↓
  field_registry
    ↓
  instance_calculations
    ↓
  aggregation_results_cache
    ↓
  display_metrics

event_instance_id groups related fields together
========================================
' as summary;
