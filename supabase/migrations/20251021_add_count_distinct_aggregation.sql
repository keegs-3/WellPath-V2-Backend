-- =====================================================
-- Add COUNT_DISTINCT Aggregation Type
-- =====================================================
-- Counts unique types/sources within a period
-- Example: "Ate 7 different vegetable types this week"
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

INSERT INTO calculation_types (type_id, type_name, description, sql_function)
VALUES
('COUNT_DISTINCT', 'Count Distinct Types', 'Count number of unique types/sources within the time window (measures variety/diversity)', 'COUNT(DISTINCT value_reference)')

ON CONFLICT (type_id) DO UPDATE SET
  type_name = EXCLUDED.type_name,
  description = EXCLUDED.description,
  sql_function = EXCLUDED.sql_function;

DO $$
BEGIN
  RAISE NOTICE '✅ COUNT_DISTINCT Aggregation Type Added';
  RAISE NOTICE '';
  RAISE NOTICE 'Use cases:';
  RAISE NOTICE '  • COUNT_DISTINCT → unique types (e.g., 7 different vegetable types)';
  RAISE NOTICE '  • COUNT_UNIQUE_DAYS → frequency (e.g., exercised on 4 days)';
  RAISE NOTICE '';
  RAISE NOTICE 'Perfect for diversity recommendations:';
  RAISE NOTICE '  "Eat 5 different types of vegetables per day"';
  RAISE NOTICE '  "Try 7 different fruits this week"';
  RAISE NOTICE '  "Consume 3 different protein sources weekly"';
END $$;

COMMIT;
