-- =====================================================================================
-- Update All Section Chart Types to bar_stacked
-- =====================================================================================
-- All modal sections should display as stacked bar charts where:
-- - Each bar = one time period (day/week/month based on scroll_granularity)
-- - Children = stacked segments within each bar
--
-- Example: Protein Timing section
-- - Period: Weekly (7 bars, each bar = 1 day)
-- - Children: Breakfast, Lunch, Dinner (stacked in each bar)
-- - Bar 1 (Monday): Breakfast segment + Lunch segment + Dinner segment
-- - Bar 2 (Tuesday): Breakfast segment + Lunch segment + Dinner segment
-- - etc.
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Update All Sections to bar_stacked
-- =====================================================================================

UPDATE parent_detail_sections
SET section_chart_type_id = 'bar_stacked'
WHERE section_chart_type_id IS NOT NULL;

-- =====================================================================================
-- STEP 2: Add Comments to Clarify Stacked Bar Pattern
-- =====================================================================================

COMMENT ON COLUMN parent_detail_sections.section_chart_type_id IS
'Chart type for this section. All sections use bar_stacked where:
- Each bar represents one time period (hour/day/week/month based on aggregation_periods.x_axis_granularity)
- Children are stacked segments within each bar
- Total bar height = sum of all child values for that period

Examples:
- Protein Timing (Weekly, 7 bars): Each bar = 1 day with Breakfast/Lunch/Dinner stacked
- Sleep Stages (Weekly, 7 bars): Each bar = 1 day with Deep/Core/REM/Awake stacked
- Protein Timing (Daily, 24 bars): Each bar = 1 hour with meal protein stacked';

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show all sections with their chart types
SELECT
  pds.parent_metric_id,
  pdm.parent_name,
  pds.section_name,
  pds.section_chart_type_id,
  pds.display_order,
  COUNT(cdm.child_metric_id) as child_count
FROM parent_detail_sections pds
JOIN parent_display_metrics pdm ON pds.parent_metric_id = pdm.parent_metric_id
LEFT JOIN child_display_metrics cdm ON cdm.section_id = pds.section_id
GROUP BY pds.parent_metric_id, pdm.parent_name, pds.section_id, pds.section_name, pds.section_chart_type_id, pds.display_order
ORDER BY pds.parent_metric_id, pds.display_order;
