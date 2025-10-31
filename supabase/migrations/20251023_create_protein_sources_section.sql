-- =====================================================================================
-- Create Protein Sources Section and Child Display Metrics
-- =====================================================================================
-- Creates "Sources" tab in Protein modal showing distribution by protein type
-- Each protein source (chicken, beef, tofu, etc.) becomes a data series in stacked bar
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Create "Sources" Section for Protein (Servings)
-- =====================================================================================

INSERT INTO parent_detail_sections (
  section_id,
  parent_metric_id,
  section_name,
  section_description,
  section_icon,
  display_order,
  section_layout,
  section_chart_type_id,
  is_default_tab,
  is_active
) VALUES (
  'SECTION_PROTEIN_SOURCES_SERVINGS',
  'DISP_PROTEIN_SERVINGS',
  'Sources',
  'Protein intake by source type',
  'leaf.fill',  -- Icon representing variety/sources
  4,  -- After Timing (1), Type (2), Variety (3)
  'vertical_stack',
  'bar_stacked',
  false,
  true
)
ON CONFLICT (section_id) DO UPDATE SET
  section_name = EXCLUDED.section_name,
  section_description = EXCLUDED.section_description,
  display_order = EXCLUDED.display_order,
  section_chart_type_id = EXCLUDED.section_chart_type_id;

-- =====================================================================================
-- STEP 2: Create Child Display Metrics for Protein Sources (Servings)
-- =====================================================================================

INSERT INTO child_display_metrics (
  child_metric_id,
  parent_metric_id,
  section_id,
  child_name,
  child_description,
  data_series_order,
  supported_units,
  default_unit,
  inherit_parent_unit,
  is_active
)
SELECT
  'DISP_' || UPPER(REPLACE(REPLACE(def.field_name, 'protein_', ''), '_servings', '')) || '_SERVINGS',
  'DISP_PROTEIN_SERVINGS',
  'SECTION_PROTEIN_SOURCES_SERVINGS',
  REPLACE(def.display_name, ' (servings)', ''),
  'Protein from ' || LOWER(REPLACE(def.display_name, ' (servings)', '')),
  def.sort_order,
  '["servings", "grams"]'::jsonb,
  'serving',
  true,
  true
FROM data_entry_fields def
WHERE def.parent_field_id = 'DEF_PROTEIN_SERVINGS'
  AND def.is_active = true
ORDER BY def.sort_order
ON CONFLICT (child_metric_id) DO UPDATE SET
  child_name = EXCLUDED.child_name,
  section_id = EXCLUDED.section_id,
  data_series_order = EXCLUDED.data_series_order;

-- =====================================================================================
-- STEP 3: Link Display Metrics to Aggregations
-- =====================================================================================

INSERT INTO parent_child_display_metrics_aggregations (
  parent_metric_id,
  child_metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id
)
SELECT
  NULL,  -- child-only aggregation
  cdm.child_metric_id,
  'AGG_' || UPPER(REPLACE(REPLACE(REPLACE(cdm.child_name, ' (servings)', ''), 'protein ', ''), ' ', '')) || '_SERVINGS',
  ap.period_id,
  'AVG'
FROM child_display_metrics cdm
CROSS JOIN aggregation_periods ap
WHERE cdm.section_id = 'SECTION_PROTEIN_SOURCES_SERVINGS'
  AND cdm.is_active = true
ON CONFLICT DO NOTHING;

-- Also add SUM for daily views
INSERT INTO parent_child_display_metrics_aggregations (
  parent_metric_id,
  child_metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id
)
SELECT
  NULL,
  cdm.child_metric_id,
  'AGG_' || UPPER(REPLACE(REPLACE(REPLACE(cdm.child_name, ' (servings)', ''), 'protein ', ''), ' ', '')) || '_SERVINGS',
  'daily',
  'SUM'
FROM child_display_metrics cdm
WHERE cdm.section_id = 'SECTION_PROTEIN_SOURCES_SERVINGS'
  AND cdm.is_active = true
ON CONFLICT DO NOTHING;

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show the Sources section structure
SELECT
  pds.section_id,
  pds.section_name,
  pds.display_order,
  pds.section_chart_type_id,
  COUNT(cdm.child_metric_id) as child_count
FROM parent_detail_sections pds
LEFT JOIN child_display_metrics cdm ON cdm.section_id = pds.section_id
WHERE pds.section_id = 'SECTION_PROTEIN_SOURCES_SERVINGS'
GROUP BY pds.section_id, pds.section_name, pds.display_order, pds.section_chart_type_id;

-- Show all child metrics in Sources section
SELECT
  cdm.child_metric_id,
  cdm.child_name,
  cdm.data_series_order,
  COUNT(DISTINCT pca.agg_metric_id) as linked_aggs,
  COUNT(DISTINCT pca.period_type) as periods
FROM child_display_metrics cdm
LEFT JOIN parent_child_display_metrics_aggregations pca ON pca.child_metric_id = cdm.child_metric_id
WHERE cdm.section_id = 'SECTION_PROTEIN_SOURCES_SERVINGS'
GROUP BY cdm.child_metric_id, cdm.child_name, cdm.data_series_order
ORDER BY cdm.data_series_order;

-- Show complete protein modal structure
SELECT
  '📊 PARENT' as type,
  0 as sort1,
  0 as sort2,
  pdm.parent_metric_id as id,
  pdm.parent_name as name
FROM parent_display_metrics pdm
WHERE pdm.parent_metric_id = 'DISP_PROTEIN_SERVINGS'

UNION ALL

SELECT
  '  📑 SECTION' as type,
  1 as sort1,
  pds.display_order as sort2,
  pds.section_id as id,
  pds.section_name || ' (' || pds.section_chart_type_id || ')' as name
FROM parent_detail_sections pds
WHERE pds.parent_metric_id = 'DISP_PROTEIN_SERVINGS'

UNION ALL

SELECT
  '    ◆ data series' as type,
  2 as sort1,
  pds.display_order * 100 + cdm.data_series_order as sort2,
  cdm.child_metric_id as id,
  '    ' || cdm.child_name as name
FROM child_display_metrics cdm
LEFT JOIN parent_detail_sections pds ON cdm.section_id = pds.section_id
WHERE cdm.parent_metric_id = 'DISP_PROTEIN_SERVINGS'

ORDER BY sort1, sort2;
