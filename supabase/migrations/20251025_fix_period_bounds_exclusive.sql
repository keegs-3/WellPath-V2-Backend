-- =====================================================
-- Fix Period Bounds to Use Exclusive Upper Bound
-- =====================================================
-- Change from: BETWEEN start AND end (inclusive both sides)
-- Change to:   >= start AND < end (exclusive upper bound)
--
-- This is cleaner and more standard:
-- - period_end is first day of NEXT period
-- - Query uses: WHERE date >= start AND date < end
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Update get_period_bounds Function
-- =====================================================

DROP FUNCTION IF EXISTS get_period_bounds(TEXT, DATE);

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
BEGIN
  CASE p_period_id
    WHEN 'hourly' THEN
      -- Hourly: Same day, end = next day (exclusive)
      RETURN QUERY SELECT
        p_reference_date,
        p_reference_date + 1;

    WHEN 'daily' THEN
      -- Daily: Same day, end = next day (exclusive)
      RETURN QUERY SELECT
        p_reference_date,
        p_reference_date + 1;

    WHEN 'weekly' THEN
      -- Weekly: Monday to Monday (exclusive upper bound)
      v_week_start := p_reference_date - (EXTRACT(DOW FROM p_reference_date)::int + 6) % 7;
      RETURN QUERY SELECT
        v_week_start,
        v_week_start + 7;  -- Next Monday (exclusive)

    WHEN 'monthly' THEN
      -- Monthly: First of month to first of next month (exclusive)
      v_month_start := DATE_TRUNC('month', p_reference_date)::DATE;
      v_month_end := (DATE_TRUNC('month', p_reference_date) + INTERVAL '1 month')::DATE;
      RETURN QUERY SELECT v_month_start, v_month_end;

    WHEN '6month' THEN
      -- 6 months: 5 months before reference to day after reference (exclusive)
      RETURN QUERY SELECT
        (p_reference_date - INTERVAL '5 months')::DATE,
        p_reference_date + 1;

    WHEN 'yearly' THEN
      -- Yearly: Jan 1 to Jan 1 of next year (exclusive)
      v_year_start := DATE_TRUNC('year', p_reference_date)::DATE;
      RETURN QUERY SELECT
        v_year_start,
        (DATE_TRUNC('year', p_reference_date) + INTERVAL '1 year')::DATE;

    ELSE
      -- Fallback: same as daily
      RETURN QUERY SELECT p_reference_date, p_reference_date + 1;
  END CASE;
END;
$$;

COMMENT ON FUNCTION get_period_bounds(TEXT, DATE) IS
'Returns period bounds with EXCLUSIVE upper bound (use >= start AND < end).
- daily: 2025-09-23 to 2025-09-24 (includes Sept 23, excludes Sept 24)
- weekly: 2025-09-22 to 2025-09-29 (Mon Sept 22 to Sun Sept 28, excludes next Mon)
- monthly: 2025-09-01 to 2025-10-01 (all of Sept, excludes Oct 1)
- 6month: 2025-04-23 to 2025-09-24 (5 months before ref to ref inclusive)
- yearly: 2025-01-01 to 2026-01-01 (all of 2025, excludes Jan 1 2026)';

-- =====================================================
-- STEP 2: Update calculate_field_aggregation Function
-- =====================================================

DROP FUNCTION IF EXISTS calculate_field_aggregation(UUID, TEXT, DATE, DATE, TEXT);

CREATE OR REPLACE FUNCTION calculate_field_aggregation(
  p_user_id UUID,
  p_field_id TEXT,
  p_period_start DATE,
  p_period_end DATE,
  p_calc_type TEXT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
  v_result NUMERIC;
BEGIN
  CASE p_calc_type
    WHEN 'SUM' THEN
      SELECT COALESCE(SUM(value_quantity), 0) INTO v_result
      FROM patient_data_entries
      WHERE user_id = p_user_id
        AND field_id = p_field_id
        AND entry_date >= p_period_start
        AND entry_date < p_period_end  -- ✅ Exclusive upper bound
        AND source != 'deleted';

    WHEN 'AVG' THEN
      SELECT COALESCE(AVG(value_quantity), 0) INTO v_result
      FROM patient_data_entries
      WHERE user_id = p_user_id
        AND field_id = p_field_id
        AND entry_date >= p_period_start
        AND entry_date < p_period_end  -- ✅ Exclusive upper bound
        AND source != 'deleted';

    WHEN 'COUNT' THEN
      SELECT COUNT(*) INTO v_result
      FROM patient_data_entries
      WHERE user_id = p_user_id
        AND field_id = p_field_id
        AND entry_date >= p_period_start
        AND entry_date < p_period_end  -- ✅ Exclusive upper bound
        AND source != 'deleted';

    WHEN 'COUNT_DISTINCT' THEN
      SELECT COUNT(DISTINCT value_reference) INTO v_result
      FROM patient_data_entries
      WHERE user_id = p_user_id
        AND field_id = p_field_id
        AND entry_date >= p_period_start
        AND entry_date < p_period_end  -- ✅ Exclusive upper bound
        AND source != 'deleted'
        AND value_reference IS NOT NULL;

    ELSE
      v_result := NULL;
  END CASE;

  RETURN v_result;
END;
$$;

COMMENT ON FUNCTION calculate_field_aggregation(UUID, TEXT, DATE, DATE, TEXT) IS
'Calculates field aggregation using EXCLUSIVE upper bound (entry_date >= start AND < end)';

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
  RAISE NOTICE '✅ Period Bounds Updated to Exclusive Upper Bound';
  RAISE NOTICE '';
  RAISE NOTICE 'Testing with reference date: % (Tuesday)', v_ref_date;
  RAISE NOTICE 'Pattern: date >= period_start AND date < period_end';
  RAISE NOTICE '';

  -- Test daily
  SELECT * INTO v_start, v_end FROM get_period_bounds('daily', v_ref_date);
  v_days := v_end - v_start;
  RAISE NOTICE 'daily:   % to % (< end, so includes % only) %',
    v_start, v_end, v_start,
    CASE WHEN v_days = 1 THEN '✅' ELSE '❌' END;

  -- Test weekly
  SELECT * INTO v_start, v_end FROM get_period_bounds('weekly', v_ref_date);
  v_days := v_end - v_start;
  RAISE NOTICE 'weekly:  % (Mon) to % (< Mon, so includes Mon-Sun) %',
    v_start, v_end,
    CASE WHEN v_days = 7 THEN '✅' ELSE '❌' END;

  -- Test monthly
  SELECT * INTO v_start, v_end FROM get_period_bounds('monthly', v_ref_date);
  v_days := v_end - v_start;
  RAISE NOTICE 'monthly: % to % (< Oct 1, so includes all of Sept) %',
    v_start, v_end,
    CASE WHEN v_days = 30 THEN '✅' ELSE '❌' END;

  -- Test 6month
  SELECT * INTO v_start, v_end FROM get_period_bounds('6month', v_ref_date);
  v_days := v_end - v_start;
  RAISE NOTICE '6month:  % to % (< Sept 24, so includes to Sept 23) %',
    v_start, v_end,
    CASE WHEN v_days >= 153 THEN '✅' ELSE '❌' END;

  -- Test yearly
  SELECT * INTO v_start, v_end FROM get_period_bounds('yearly', v_ref_date);
  v_days := v_end - v_start;
  RAISE NOTICE 'yearly:  % to % (< 2026, so includes all of 2025) %',
    v_start, v_end,
    CASE WHEN v_days = 365 THEN '✅' ELSE '❌' END;

  RAISE NOTICE '';
  RAISE NOTICE '✅ All periods now use exclusive upper bound (cleaner pattern)';
END $$;

COMMIT;
