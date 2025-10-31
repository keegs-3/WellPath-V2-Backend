-- =====================================================================================
-- Add Period Behavior Configuration to aggregation_metrics_periods
-- =====================================================================================
-- Stores chart behavior rules for D/W/M/6M/Y periods:
-- - calculation_type: SUM (for daily total) or AVG (for daily average)
-- - scroll_granularity: How user scrolls through time (day/week/month)
-- - bars: Number of bars to display in chart
-- - days_covered: Total days in the window
-- - label_format: Template for chart label
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Add Period Behavior Columns
-- =====================================================================================

ALTER TABLE aggregation_metrics_periods
ADD COLUMN calculation_type text CHECK (calculation_type IN ('SUM', 'AVG')),
ADD COLUMN scroll_granularity text CHECK (scroll_granularity IN ('day', 'week', 'month')),
ADD COLUMN bars integer,
ADD COLUMN days_covered integer,
ADD COLUMN label_format text;

COMMENT ON COLUMN aggregation_metrics_periods.calculation_type IS
'How to calculate values for this period:
- SUM: Show total for the period (used for daily)
- AVG: Show daily average across the period (used for weekly/monthly/etc.)';

COMMENT ON COLUMN aggregation_metrics_periods.scroll_granularity IS
'Time unit for scrolling through data:
- day: Scroll by day
- week: Scroll by week (each bar = one week)
- month: Scroll by month (each bar = one month)';

COMMENT ON COLUMN aggregation_metrics_periods.bars IS
'Number of bars to display in the chart.
Examples: 1 for daily, 7 for weekly, 30 for monthly, 26 for 6-month, 12 for yearly';

COMMENT ON COLUMN aggregation_metrics_periods.days_covered IS
'Total number of days covered by this period window.
Examples: 1 for daily, 7 for weekly, 30 for monthly, 182 for 6-month, 365 for yearly';

COMMENT ON COLUMN aggregation_metrics_periods.label_format IS
'Template for chart label. Placeholders:
- {start_date}: Start date
- {end_date}: End date
- {period_name}: Named period (e.g., "Yesterday", "This Week")
Examples: "{period_name}" or "{start_date} - {end_date}"';

-- =====================================================================================
-- STEP 2: Populate Period Behavior Configuration
-- =====================================================================================

-- Daily: Shows TOTAL for selected 24hr period, scrolls by day
UPDATE aggregation_metrics_periods
SET
  calculation_type = 'SUM',
  scroll_granularity = 'day',
  bars = 1,
  days_covered = 1,
  label_format = '{period_name}'  -- 'Yesterday' or 'Oct 21, 12 PM - Oct 22, 12 PM'
WHERE period_type = 'daily';

-- Weekly: Shows DAILY AVERAGE across 7-day window, scrolls by day
UPDATE aggregation_metrics_periods
SET
  calculation_type = 'AVG',
  scroll_granularity = 'day',
  bars = 7,
  days_covered = 7,
  label_format = '{start_date} - {end_date}'  -- 'Oct 16 - Oct 22, 2025'
WHERE period_type = 'weekly';

-- Monthly: Shows DAILY AVERAGE across 30-day window, scrolls by day
UPDATE aggregation_metrics_periods
SET
  calculation_type = 'AVG',
  scroll_granularity = 'day',
  bars = 30,
  days_covered = 30,
  label_format = '{start_date} - {end_date}'  -- 'Sep 22 - Oct 22, 2025'
WHERE period_type = 'monthly';

-- 6-Month: Shows DAILY AVERAGE across 26-week window, scrolls by week
UPDATE aggregation_metrics_periods
SET
  calculation_type = 'AVG',
  scroll_granularity = 'week',
  bars = 26,
  days_covered = 182,
  label_format = '{start_date} - {end_date}'  -- 'Jun 25 - Dec 23, 2025'
WHERE period_type = '6_month';

-- Yearly: Shows DAILY AVERAGE across 12-month window, scrolls by month
UPDATE aggregation_metrics_periods
SET
  calculation_type = 'AVG',
  scroll_granularity = 'month',
  bars = 12,
  days_covered = 365,
  label_format = '{start_date} - {end_date}'  -- 'Nov 2023 - Nov 2024'
WHERE period_type = 'yearly';

-- =====================================================================================
-- STEP 3: Add X-Axis Configuration
-- =====================================================================================

ALTER TABLE aggregation_metrics_periods
ADD COLUMN x_axis_labels text[];

COMMENT ON COLUMN aggregation_metrics_periods.x_axis_labels IS
'X-axis label configuration for this period.
For daily: Time labels like ["12 AM", "6", "12 PM", "6"]
For weekly/monthly: Day labels like ["Mon", "Tue", "Wed", ...]
For 6-month: Week numbers or dates
For yearly: Month abbreviations like ["Jan", "Feb", "Mar", ...]';

-- Daily: Time labels (12 AM, 6, 12 PM, 6)
UPDATE aggregation_metrics_periods
SET x_axis_labels = ARRAY['12 AM', '6', '12 PM', '6']
WHERE period_type = 'daily';

-- Weekly: Day abbreviations (for 7 bars)
UPDATE aggregation_metrics_periods
SET x_axis_labels = ARRAY['S', 'M', 'T', 'W', 'T', 'F', 'S']
WHERE period_type = 'weekly';

-- Monthly: Dynamic day numbers (will be generated in app based on actual days)
UPDATE aggregation_metrics_periods
SET x_axis_labels = ARRAY[]::text[]  -- Empty, generated dynamically
WHERE period_type = 'monthly';

-- 6-Month: Dynamic week labels (will be generated in app)
UPDATE aggregation_metrics_periods
SET x_axis_labels = ARRAY[]::text[]  -- Empty, generated dynamically
WHERE period_type = '6_month';

-- Yearly: Month abbreviations
UPDATE aggregation_metrics_periods
SET x_axis_labels = ARRAY['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
WHERE period_type = 'yearly';

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

SELECT
  period_type,
  calculation_type,
  scroll_granularity,
  bars,
  days_covered,
  label_format,
  x_axis_labels
FROM aggregation_metrics_periods
ORDER BY
  CASE period_type
    WHEN 'daily' THEN 1
    WHEN 'weekly' THEN 2
    WHEN 'monthly' THEN 3
    WHEN '6_month' THEN 4
    WHEN 'yearly' THEN 5
  END;
