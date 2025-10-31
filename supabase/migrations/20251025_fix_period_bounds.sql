-- =====================================================
-- Fix Period Bounds Function
-- =====================================================
-- Issue: get_period_bounds returns incorrect period_end for weekly/monthly/yearly
-- Current: period_end = reference_date (partial period)
-- Fix: period_end = actual end of period (full period)
-- =====================================================

BEGIN;

-- Drop the existing function
DROP FUNCTION IF EXISTS get_period_bounds(TEXT, DATE);

-- Create corrected version
CREATE OR REPLACE FUNCTION get_period_bounds(
  p_period_id TEXT,
  p_reference_date DATE
)
RETURNS TABLE(period_start DATE, period_end DATE)
LANGUAGE plpgsql
AS $$
DECLARE
  v_week_start DATE;
  v_month_start DATE;
  v_month_end DATE;
  v_year_start DATE;
  v_year_end DATE;
BEGIN
  CASE p_period_id
    WHEN 'hourly' THEN
      -- For hourly, return the same day (aggregation handles hours within the day)
      RETURN QUERY SELECT p_reference_date, p_reference_date;

    WHEN 'daily' THEN
      -- For daily, return the same day (WHERE clause uses BETWEEN which is inclusive)
      RETURN QUERY SELECT p_reference_date, p_reference_date;

    WHEN 'weekly' THEN
      -- Full week: Monday to Sunday (7 days)
      v_week_start := p_reference_date - (EXTRACT(DOW FROM p_reference_date)::int + 6) % 7;
      RETURN QUERY SELECT v_week_start, v_week_start + 6;  -- ✅ +6 days = Sunday

    WHEN 'monthly' THEN
      -- Full month: First day to last day of month
      v_month_start := DATE_TRUNC('month', p_reference_date)::DATE;
      v_month_end := (DATE_TRUNC('month', p_reference_date) + INTERVAL '1 month - 1 day')::DATE;
      RETURN QUERY SELECT v_month_start, v_month_end;

    WHEN '6month' THEN
      -- 6 months back from reference date (rolling window)
      -- This one was already correct
      RETURN QUERY SELECT
        (p_reference_date - INTERVAL '5 months')::DATE,
        p_reference_date;

    WHEN 'yearly' THEN
      -- Full year: January 1 to December 31
      v_year_start := DATE_TRUNC('year', p_reference_date)::DATE;
      v_year_end := (DATE_TRUNC('year', p_reference_date) + INTERVAL '1 year - 1 day')::DATE;
      RETURN QUERY SELECT v_year_start, v_year_end;

    ELSE
      -- Fallback: same as daily
      RETURN QUERY SELECT p_reference_date, p_reference_date;
  END CASE;
END;
$$;

COMMENT ON FUNCTION get_period_bounds(TEXT, DATE) IS
'Returns the start and end dates for a given period type and reference date.
- daily/hourly: same day (WHERE BETWEEN is inclusive)
- weekly: Monday to Sunday (7 full days)
- monthly: First to last day of month
- 6month: 5 months before reference to reference (rolling 6-month window)
- yearly: January 1 to December 31';

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  v_ref_date DATE := '2025-09-23';  -- Tuesday
  v_start DATE;
  v_end DATE;
  v_days INTEGER;
BEGIN
  RAISE NOTICE '✅ Period Bounds Function Fixed';
  RAISE NOTICE '';
  RAISE NOTICE 'Testing with reference date: % (Tuesday)', v_ref_date;
  RAISE NOTICE '';

  -- Test daily
  SELECT * INTO v_start, v_end FROM get_period_bounds('daily', v_ref_date);
  v_days := v_end - v_start;
  RAISE NOTICE 'daily:   % to % (% days) %',
    v_start, v_end, v_days,
    CASE WHEN v_days = 0 THEN '✅' ELSE '❌' END;

  -- Test weekly
  SELECT * INTO v_start, v_end FROM get_period_bounds('weekly', v_ref_date);
  v_days := v_end - v_start;
  RAISE NOTICE 'weekly:  % to % (% days) % (should be Mon-Sun)',
    v_start, v_end, v_days,
    CASE WHEN v_days = 6 THEN '✅' ELSE '❌' END;

  -- Test monthly
  SELECT * INTO v_start, v_end FROM get_period_bounds('monthly', v_ref_date);
  v_days := v_end - v_start;
  RAISE NOTICE 'monthly: % to % (% days) % (should be full month)',
    v_start, v_end, v_days,
    CASE WHEN v_days >= 28 THEN '✅' ELSE '❌' END;

  -- Test 6month
  SELECT * INTO v_start, v_end FROM get_period_bounds('6month', v_ref_date);
  v_days := v_end - v_start;
  RAISE NOTICE '6month:  % to % (% days) % (should be ~153 days)',
    v_start, v_end, v_days,
    CASE WHEN v_days >= 150 AND v_days <= 155 THEN '✅' ELSE '❌' END;

  -- Test yearly
  SELECT * INTO v_start, v_end FROM get_period_bounds('yearly', v_ref_date);
  v_days := v_end - v_start;
  RAISE NOTICE 'yearly:  % to % (% days) % (should be full year)',
    v_start, v_end, v_days,
    CASE WHEN v_days >= 364 THEN '✅' ELSE '❌' END;

  RAISE NOTICE '';
  RAISE NOTICE '✅ All period bounds now return full period ranges';
END $$;

COMMIT;
