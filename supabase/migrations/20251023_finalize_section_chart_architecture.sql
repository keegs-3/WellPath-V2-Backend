-- =====================================================================================
-- Finalize Section Chart Architecture
-- =====================================================================================
-- Sections ARE the charts, children are data series/labels within each section chart
-- Adds about content to parents, chart types to sections, clarifies data series
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Add About Content to Parent Display Metrics
-- =====================================================================================

ALTER TABLE parent_display_metrics
ADD COLUMN about_what TEXT,
ADD COLUMN about_why TEXT,
ADD COLUMN about_optimal_target TEXT,
ADD COLUMN about_quick_tips TEXT;

COMMENT ON COLUMN parent_display_metrics.about_what IS
'Brief description of what this metric is. Shown in About section on parent card.';

COMMENT ON COLUMN parent_display_metrics.about_why IS
'Why this metric matters for health/longevity. Shown in About section on parent card.';

COMMENT ON COLUMN parent_display_metrics.about_optimal_target IS
'Optimal range or target for this metric. Shown in About section on parent card.';

COMMENT ON COLUMN parent_display_metrics.about_quick_tips IS
'Actionable tips for improving this metric. Shown in About section on parent card.';

-- =====================================================================================
-- STEP 2: Add Chart Type to Sections
-- =====================================================================================

ALTER TABLE parent_detail_sections
ADD COLUMN section_chart_type_id TEXT REFERENCES chart_types(chart_type_id);

COMMENT ON COLUMN parent_detail_sections.section_chart_type_id IS
'Chart type for this section. The section IS a single chart with children as data series/labels.
Example: "Timing" section = grouped_bar_chart with Breakfast/Lunch/Dinner as bars.
Example: "Stages" section = stacked_bar_chart with Deep/Core/REM/Awake as segments.';

-- =====================================================================================
-- STEP 3: Clarify Child Columns as Data Series
-- =====================================================================================

-- Rename display_order_in_parent to data_series_order for clarity
ALTER TABLE child_display_metrics
RENAME COLUMN display_order_in_parent TO data_series_order;

COMMENT ON COLUMN child_display_metrics.data_series_order IS
'Display order within the section chart. Determines order of bars/segments/labels in the visualization.';

-- Update display_order_in_category for consistency
ALTER TABLE child_display_metrics
RENAME COLUMN display_order_in_category TO chart_label_order;

COMMENT ON COLUMN child_display_metrics.chart_label_order IS
'Order of this data series within its category/grouping in the chart.';

-- Update comment on child_name
COMMENT ON COLUMN child_display_metrics.child_name IS
'Name of this data series. Becomes the label in the section chart.
Examples: "Breakfast", "Deep Sleep", "Plant-Based"';

-- =====================================================================================
-- STEP 4: Populate Protein About Content
-- =====================================================================================

UPDATE parent_display_metrics
SET
  about_what = 'Protein is a macronutrient essential for building and repairing tissues, making enzymes and hormones, and supporting immune function.',
  about_why = 'Adequate protein intake supports muscle maintenance, healthy aging, satiety, and metabolic health. It''s crucial for preserving muscle mass as you age and maintaining a healthy metabolism.',
  about_optimal_target = '0.8-1.2g per kg body weight daily for general health. Athletes and active individuals may need 1.6-2.2g/kg. Aim to distribute protein across meals for optimal absorption.',
  about_quick_tips = E'• Spread protein across meals for better absorption\n• Include variety: both animal and plant sources\n• Pair with strength training for muscle growth\n• Choose lean sources to minimize saturated fat'
WHERE parent_metric_id = 'DISP_PROTEIN_SERVINGS';

-- =====================================================================================
-- STEP 5: Set Section Chart Types
-- =====================================================================================

-- Protein Timing: Vertical bar chart (3 bars: B/L/D)
UPDATE parent_detail_sections
SET section_chart_type_id = 'bar_vertical'
WHERE section_id = 'SECTION_PROTEIN_TIMING';

-- Protein Type: Comparison view (plant vs animal) - will use custom chart in mobile
UPDATE parent_detail_sections
SET section_chart_type_id = 'comparison_view'
WHERE section_id = 'SECTION_PROTEIN_TYPE';

-- Protein Variety: Horizontal bar chart (distribution of sources)
UPDATE parent_detail_sections
SET section_chart_type_id = 'bar_horizontal'
WHERE section_id = 'SECTION_PROTEIN_VARIETY';

-- Fiber Timing: Vertical bar chart
UPDATE parent_detail_sections
SET section_chart_type_id = 'bar_vertical'
WHERE section_id = 'SECTION_FIBER_TIMING';

-- Fiber Sources: Comparison view
UPDATE parent_detail_sections
SET section_chart_type_id = 'comparison_view'
WHERE section_id = 'SECTION_FIBER_TYPE';

-- Fiber Variety: Horizontal bar
UPDATE parent_detail_sections
SET section_chart_type_id = 'bar_horizontal'
WHERE section_id = 'SECTION_FIBER_VARIETY';

-- Sleep Stages: Stacked bar chart (like Apple Health)
UPDATE parent_detail_sections
SET section_chart_type_id = 'bar_stacked'
WHERE section_id = 'SECTION_SLEEP_STAGES';

-- Sleep Quality: Trend line
UPDATE parent_detail_sections
SET section_chart_type_id = 'trend_line'
WHERE section_id = 'SECTION_SLEEP_QUALITY';

-- =====================================================================================
-- STEP 6: Set Parent Chart Types
-- =====================================================================================

-- Protein parent card: Vertical bar chart
UPDATE parent_display_metrics
SET chart_type_id = 'bar_vertical'
WHERE parent_metric_id = 'DISP_PROTEIN_SERVINGS';

-- Fiber parent card: Vertical bar chart
UPDATE parent_display_metrics
SET chart_type_id = 'bar_vertical'
WHERE parent_metric_id = 'DISP_FIBER_SERVINGS';

-- Sleep parent card: Sleep stages horizontal (timeline)
UPDATE parent_display_metrics
SET chart_type_id = 'sleep_stages_horizontal'
WHERE parent_metric_id = 'DISP_TOTAL_SLEEP_DURATION';

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show complete protein structure
WITH protein_structure AS (
  SELECT
    '🏆 PARENT' as type,
    0 as sort1,
    0 as sort2,
    pdm.parent_metric_id as id,
    pdm.parent_name as name,
    pdm.chart_type_id as chart,
    NULL::text as section_chart,
    COALESCE(LEFT(pdm.about_what, 50) || '...', 'No about content') as about_preview
  FROM parent_display_metrics pdm
  WHERE pdm.parent_metric_id = 'DISP_PROTEIN_SERVINGS'

  UNION ALL

  SELECT
    '  📂 SECTION' as type,
    1 as sort1,
    pds.display_order as sort2,
    pds.section_id as id,
    pds.section_name as name,
    NULL::text as chart,
    pds.section_chart_type_id as section_chart,
    NULL::text as about_preview
  FROM parent_detail_sections pds
  WHERE pds.parent_metric_id = 'DISP_PROTEIN_SERVINGS'

  UNION ALL

  SELECT
    '    ↳ data series' as type,
    2 as sort1,
    COALESCE(pds.display_order, 99) as sort2,
    cdm.child_metric_id as id,
    cdm.child_name as name,
    NULL::text as chart,
    COALESCE(pds.section_name || ' series', 'No section') as section_chart,
    NULL::text as about_preview
  FROM child_display_metrics cdm
  LEFT JOIN parent_detail_sections pds ON cdm.section_id = pds.section_id
  WHERE cdm.parent_metric_id = 'DISP_PROTEIN_SERVINGS'
)
SELECT type, id, name, chart, section_chart, about_preview
FROM protein_structure
ORDER BY sort1, sort2;
