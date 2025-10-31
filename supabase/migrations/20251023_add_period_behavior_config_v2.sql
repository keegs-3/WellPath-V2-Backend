-- =====================================================================================
-- Add Period Behavior Configuration to aggregation_periods
-- =====================================================================================
-- Stores chart behavior rules for D/W/M/6M/Y periods:
-- - calculation_type: SUM (for daily total) or AVG (for daily average)
-- - label_format: Template for chart label
-- - Updates monthly to 30 days instead of 33
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Add Period Behavior Columns
-- =====================================================================================

ALTER TABLE aggregation_periods
ADD COLUMN IF NOT EXISTS calculation_type text CHECK (calculation_type IN ('SUM', 'AVG')),
ADD COLUMN IF NOT EXISTS label_format text;

COMMENT ON COLUMN aggregation_periods.calculation_type IS
'How to calculate values for this period:
- SUM: Show total for the period (used for daily)
- AVG: Show daily average across the period (used for weekly/monthly/etc.)';

COMMENT ON COLUMN aggregation_periods.label_format IS
'Template for chart label. Placeholders:
- {start_date}: Start date
- {end_date}: End date
- {period_name}: Named period (e.g., "Yesterday", "This Week")
Examples: "{period_name}" or "{start_date} - {end_date}"';

-- =====================================================================================
-- STEP 2: Populate Period Behavior Configuration
-- =====================================================================================

-- Daily: Shows TOTAL for selected 24hr period
-- X-axis granularity already set to 'hour' (24 bars showing hours)
UPDATE aggregation_periods
SET
  calculation_type = 'SUM',
  label_format = '{period_name}'  -- 'Yesterday' or 'Oct 21, 12 PM - Oct 22, 12 PM'
WHERE period_id = 'daily';

-- Weekly: Shows DAILY AVERAGE across 7-day window
-- X-axis granularity already set to 'day' (7 bars showing days)
UPDATE aggregation_periods
SET
  calculation_type = 'AVG',
  label_format = '{start_date} - {end_date}'  -- 'Oct 16 - Oct 22, 2025'
WHERE period_id = 'weekly';

-- Monthly: Shows DAILY AVERAGE across 30-day window
-- Update to 30 bars/days (was 33), x_axis_granularity already 'day'
UPDATE aggregation_periods
SET
  calculation_type = 'AVG',
  bars = 30,
  days = 30,
  label_format = '{start_date} - {end_date}'  -- 'Sep 22 - Oct 22, 2025'
WHERE period_id = 'monthly';

-- 6-Month: Shows DAILY AVERAGE across 26-week window
-- X-axis granularity already set to 'week' (26 bars showing weeks)
UPDATE aggregation_periods
SET
  calculation_type = 'AVG',
  label_format = '{start_date} - {end_date}'  -- 'Jun 25 - Dec 23, 2025'
WHERE period_id = '6month';

-- Yearly: Shows DAILY AVERAGE across 12-month window
-- X-axis granularity already set to 'month' (12 bars showing months)
UPDATE aggregation_periods
SET
  calculation_type = 'AVG',
  label_format = '{start_date} - {end_date}'  -- 'Nov 2023 - Nov 2024'
WHERE period_id = 'yearly';

-- =====================================================================================
-- STEP 3: Rename x_axis_granularity to scroll_granularity for clarity
-- =====================================================================================
-- Note: x_axis_granularity represents how the user scrolls AND what each bar represents

COMMENT ON COLUMN aggregation_periods.x_axis_granularity IS
'Time unit for scrolling AND what each bar represents:
- hour: Each bar = 1 hour (daily chart with 24 bars)
- day: Each bar = 1 day (weekly chart with 7 bars, monthly with 30 bars)
- week: Each bar = 1 week (6-month chart with 26 bars)
- month: Each bar = 1 month (yearly chart with 12 bars)

This also determines scroll granularity: user scrolls by this time unit.';

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

SELECT
  period_id,
  period_name,
  calculation_type,
  x_axis_granularity as scroll_granularity,
  bars,
  days,
  label_format
FROM aggregation_periods
ORDER BY
  CASE period_id
    WHEN 'daily' THEN 1
    WHEN 'weekly' THEN 2
    WHEN 'monthly' THEN 3
    WHEN '6month' THEN 4
    WHEN 'yearly' THEN 5
  END;
