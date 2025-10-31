-- =====================================================
-- Add Period Helper Functions for Aggregations
-- =====================================================

BEGIN;

CREATE OR REPLACE FUNCTION get_period_start(p_date DATE, p_period_type TEXT)
RETURNS DATE
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  CASE p_period_type
    WHEN 'daily' THEN
      RETURN p_date;
    WHEN 'weekly' THEN
      -- Start of week (Monday)
      RETURN DATE_TRUNC('week', p_date)::DATE;
    WHEN 'monthly' THEN
      -- Start of month
      RETURN DATE_TRUNC('month', p_date)::DATE;
    WHEN 'quarterly' THEN
      -- Start of quarter
      RETURN DATE_TRUNC('quarter', p_date)::DATE;
    WHEN 'yearly' THEN
      -- Start of year
      RETURN DATE_TRUNC('year', p_date)::DATE;
    WHEN 'hourly' THEN
      -- For hourly, just return the date (we'll handle hours in the entry_timestamp)
      RETURN p_date;
    ELSE
      -- Default to daily
      RETURN p_date;
  END CASE;
END;
$$;

CREATE OR REPLACE FUNCTION get_period_end(p_date DATE, p_period_type TEXT)
RETURNS DATE
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  CASE p_period_type
    WHEN 'daily' THEN
      RETURN p_date + INTERVAL '1 day';
    WHEN 'weekly' THEN
      -- End of week (next Monday)
      RETURN (DATE_TRUNC('week', p_date) + INTERVAL '1 week')::DATE;
    WHEN 'monthly' THEN
      -- Start of next month
      RETURN (DATE_TRUNC('month', p_date) + INTERVAL '1 month')::DATE;
    WHEN 'quarterly' THEN
      -- Start of next quarter
      RETURN (DATE_TRUNC('quarter', p_date) + INTERVAL '3 months')::DATE;
    WHEN 'yearly' THEN
      -- Start of next year
      RETURN (DATE_TRUNC('year', p_date) + INTERVAL '1 year')::DATE;
    WHEN 'hourly' THEN
      -- For hourly, return next day
      RETURN p_date + INTERVAL '1 day';
    ELSE
      -- Default to next day
      RETURN p_date + INTERVAL '1 day';
  END CASE;
END;
$$;

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Created Period Helper Functions!';
  RAISE NOTICE '';
  RAISE NOTICE 'Functions:';
  RAISE NOTICE '  - get_period_start(date, period_type) → DATE';
  RAISE NOTICE '  - get_period_end(date, period_type) → DATE';
  RAISE NOTICE '';
  RAISE NOTICE 'Supported period types: daily, weekly, monthly, quarterly, yearly, hourly';
  RAISE NOTICE '';
END $$;

COMMIT;
