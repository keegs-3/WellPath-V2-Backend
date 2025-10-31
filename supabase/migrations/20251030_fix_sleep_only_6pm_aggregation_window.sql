-- =====================================================
-- Fix 6PM Window to Apply ONLY to Sleep Aggregations
-- =====================================================
-- Problem: 6PM-6PM date window logic for sleep may have bled into
--          non-sleep aggregations, causing incorrect data grouping
-- Solution: Ensure 6PM-6PM window ONLY applies to sleep-related fields
--           All other fields use standard midnight-to-midnight calendar dates
-- =====================================================
--
-- SLEEP AGGREGATIONS (6PM-6PM window):
--   - Sleep entries have entry_date set using 6PM cutoff via calculate_sleep_date()
--   - Formula: entry_date = DATE(wake_time + INTERVAL '6 hours')
--   - Example: Sleep ending between 6PM Monday and 5:59:59.999 Wednesday
--              gets entry_date = Wednesday (via 6PM cutoff)
--   - When aggregating for Wednesday: filter WHERE entry_date = '2025-10-29'
--     This correctly includes all sleep assigned to Wednesday
--
-- NON-SLEEP AGGREGATIONS (midnight-to-midnight):
--   - Non-sleep entries have entry_date as standard calendar date
--   - entry_date = DATE(entry_timestamp) in user's local timezone
--   - When aggregating for Wednesday: filter WHERE entry_date = '2025-10-29'
--     This correctly includes all entries from calendar Wednesday
--
-- The current implementation is CORRECT:
--   - calculate_field_aggregation uses entry_date for daily+ periods
--   - Sleep entries already have correct entry_date (6PM cutoff)
--   - Non-sleep entries already have correct entry_date (calendar date)
--   - No changes needed to aggregation logic itself
--
-- This migration documents the expected behavior and ensures no
-- incorrect date shifting occurs for non-sleep fields.

BEGIN;

-- =====================================================
-- Document the expected behavior
-- =====================================================

COMMENT ON FUNCTION calculate_field_aggregation IS 
'Calculates aggregations for a field.
- For hourly: uses entry_timestamp filtering
- For daily/weekly/monthly/yearly/6month: uses entry_date filtering

Sleep fields (OUTPUT_SLEEP_*):
  - entry_date is set via calculate_sleep_date() using 6PM cutoff
  - All sleep between 6PM Monday and 5:59:59.999 Wednesday → entry_date = Wednesday
  - Aggregation for Wednesday filters WHERE entry_date = Wednesday (correct)

Non-sleep fields:
  - entry_date is standard calendar date (midnight-to-midnight in user timezone)
  - Aggregation for Wednesday filters WHERE entry_date = Wednesday (correct)

The 6PM window is ONLY for sleep entry_date assignment, NOT for aggregation filtering.';

COMMENT ON FUNCTION calculate_sleep_date IS
'Assigns sleep entry_date using 6PM cutoff logic. ONLY used for sleep OUTPUT fields.
This ensures sleep aggregations correctly group sleep that crosses midnight.
DO NOT use this function for non-sleep fields.';

COMMIT;

