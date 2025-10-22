-- =====================================================
-- Add X-Axis Label Configuration
-- =====================================================
-- Define specific x-axis label positions and formats
-- for each period type
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- Add column for x-axis label positions
ALTER TABLE aggregation_periods
ADD COLUMN IF NOT EXISTS x_axis_label_positions TEXT[],
ADD COLUMN IF NOT EXISTS x_axis_label_values TEXT[];

-- Daily: 12 AM, 6 AM, 12 PM, 6 PM (positions 0, 6, 12, 18)
UPDATE aggregation_periods
SET
  x_axis_label_positions = ARRAY['0', '6', '12', '18'],
  x_axis_label_values = ARRAY['12 AM', '6', '12 PM', '6']
WHERE period_id = 'daily';

-- Weekly: Mon, Tue, Wed, Thu, Fri, Sat, Sun
UPDATE aggregation_periods
SET
  x_axis_label_positions = ARRAY['0', '1', '2', '3', '4', '5', '6'],
  x_axis_label_values = ARRAY['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
WHERE period_id = 'weekly';

-- Monthly: Show every 7th day (approximately weekly markers)
-- For 33 days: 6, 13, 20, 27
UPDATE aggregation_periods
SET
  x_axis_label_positions = ARRAY['6', '13', '20', '27'],
  x_axis_label_values = ARRAY['6', '13', '20', '27']
WHERE period_id = 'monthly';

-- 6-month: Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec (every other week for 26 weeks)
UPDATE aggregation_periods
SET
  x_axis_label_positions = ARRAY['0', '4', '8', '12', '16', '20', '24'],
  x_axis_label_values = ARRAY['Jan', 'Feb', 'Apr', 'Jun', 'Aug', 'Oct', 'Dec']
WHERE period_id = '6month';

-- Yearly: J F M A M J J A S O N D (12 months)
UPDATE aggregation_periods
SET
  x_axis_label_positions = ARRAY['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'],
  x_axis_label_values = ARRAY['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D']
WHERE period_id = 'yearly';

-- Summary
DO $$
BEGIN
  RAISE NOTICE '✅ X-Axis Label Configuration Added';
  RAISE NOTICE '';
  RAISE NOTICE 'Label Formats:';
  RAISE NOTICE '  Daily (24 hours): 12 AM, 6, 12 PM, 6';
  RAISE NOTICE '  Weekly (7 days): Mon, Tue, Wed, Thu, Fri, Sat, Sun';
  RAISE NOTICE '  Monthly (33 days): 6, 13, 20, 27 (weekly markers)';
  RAISE NOTICE '  6-Month (26 weeks): Jan, Feb, Apr, Jun, Aug, Oct, Dec';
  RAISE NOTICE '  Yearly (12 months): J, F, M, A, M, J, J, A, S, O, N, D';
END $$;

COMMIT;
