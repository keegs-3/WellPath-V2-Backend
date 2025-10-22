-- =====================================================
-- Add COUNT_UNIQUE_DAYS Aggregation Calculation Type
-- =====================================================
-- Allows aggregations to count unique days with activity
-- Example: "Did cardio on 4 different days this week"
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

INSERT INTO calculation_types (type_id, type_name, description, sql_function)
VALUES
('COUNT_UNIQUE_DAYS', 'Count Unique Days', 'Count number of unique days with activity within the time window', 'COUNT(DISTINCT entry_date)')

ON CONFLICT (type_id) DO UPDATE SET
  type_name = EXCLUDED.type_name,
  description = EXCLUDED.description,
  sql_function = EXCLUDED.sql_function;

DO $$
BEGIN
  RAISE NOTICE '✅ COUNT_UNIQUE_DAYS Aggregation Type Added';
  RAISE NOTICE '';
  RAISE NOTICE 'Use this to count frequency of activity:';
  RAISE NOTICE '  • SUM → total sessions (e.g., 10 cardio workouts)';
  RAISE NOTICE '  • COUNT_UNIQUE_DAYS → activity frequency (e.g., cardio on 4 days)';
  RAISE NOTICE '';
  RAISE NOTICE 'Perfect for tracking "X times per week" recommendations!';
END $$;

COMMIT;
