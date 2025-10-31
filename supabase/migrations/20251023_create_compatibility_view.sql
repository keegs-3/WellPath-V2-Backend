-- =====================================================================================
-- Create Backward Compatibility View for display_metrics
-- =====================================================================================
-- Provides a unified view of parents and children for backward compatibility
-- Existing queries against display_metrics will continue to work
-- =====================================================================================

-- Rename old table to archive
ALTER TABLE display_metrics RENAME TO z_old_display_metrics_20251023;

-- Create view that unions parents and children
CREATE OR REPLACE VIEW display_metrics AS
-- Parent metrics
SELECT
  pdm.id,
  pdm.parent_metric_id as display_metric_id,
  pdm.parent_name as display_name,
  pdm.parent_description as description,
  pdm.pillar,
  pdm.supported_units,
  pdm.default_unit,
  pdm.chart_type_id,
  pdm.supported_periods,
  pdm.default_period,
  pdm.chart_config,
  pdm.display_format,
  pdm.display_transformation,
  pdm.display_unit,
  pdm.null_handling,
  pdm.null_display_value,
  pdm.filter_config,
  pdm.widget_type,
  pdm.display_order,
  pdm.is_featured,
  pdm.is_active,
  pdm.created_at,
  pdm.updated_at,
  NULL::text as parent_metric_id,  -- Parents have no parent
  true as is_parent,
  NULL::text as child_category,
  pdm.expand_by_default,
  pdm.summary_display_mode,
  NULL::boolean as inherit_parent_unit,
  NULL::integer as display_order_in_category
FROM parent_display_metrics pdm

UNION ALL

-- Child metrics
SELECT
  cdm.id,
  cdm.child_metric_id as display_metric_id,
  cdm.child_name as display_name,
  cdm.child_description as description,
  pdm.pillar,  -- Inherit pillar from parent
  cdm.supported_units,
  cdm.default_unit,
  cdm.chart_type_id,
  cdm.supported_periods,
  cdm.default_period,
  cdm.chart_config,
  cdm.display_format,
  cdm.display_transformation,
  cdm.display_unit,
  cdm.null_handling,
  cdm.null_display_value,
  cdm.filter_config,
  cdm.widget_type,
  cdm.display_order_in_parent as display_order,
  false as is_featured,  -- Children inherit parent featured status
  cdm.is_active,
  cdm.created_at,
  cdm.updated_at,
  cdm.parent_metric_id,
  false as is_parent,
  cdm.child_category,
  NULL::boolean as expand_by_default,
  NULL::text as summary_display_mode,
  cdm.inherit_parent_unit,
  cdm.display_order_in_category
FROM child_display_metrics cdm
JOIN parent_display_metrics pdm ON cdm.parent_metric_id = pdm.parent_metric_id;

-- Add comment
COMMENT ON VIEW display_metrics IS
'Backward compatibility view that unions parent_display_metrics and child_display_metrics.
For new code, query parent_display_metrics and child_display_metrics directly.
This view maintains compatibility with existing queries.';

-- Grant permissions
GRANT SELECT ON display_metrics TO anon, authenticated, service_role;

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show counts
SELECT
  'Parents' as type,
  COUNT(*) as count
FROM display_metrics
WHERE is_parent = true

UNION ALL

SELECT
  'Children' as type,
  COUNT(*) as count
FROM display_metrics
WHERE parent_metric_id IS NOT NULL

UNION ALL

SELECT
  'Total' as type,
  COUNT(*) as count
FROM display_metrics;

-- Show sample protein structure
SELECT
  CASE WHEN is_parent THEN '🏆 PARENT' ELSE '   ↳ child' END as type,
  display_metric_id,
  display_name,
  child_category,
  supported_units,
  is_active
FROM display_metrics
WHERE display_metric_id = 'DISP_PROTEIN_SERVINGS'
   OR parent_metric_id = 'DISP_PROTEIN_SERVINGS'
ORDER BY is_parent DESC, child_category, display_name;
