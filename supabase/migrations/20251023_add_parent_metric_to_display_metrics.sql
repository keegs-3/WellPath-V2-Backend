-- =====================================================================================
-- Add Parent/Child Relationship to Display Metrics
-- =====================================================================================
-- Implements Apple Health pattern: Parent metric with expandable child metrics
-- Example: Protein Servings (parent) → Breakfast/Lunch/Dinner, Variety, g/kg (children)
-- =====================================================================================

-- Add parent_metric_id column
ALTER TABLE display_metrics
ADD COLUMN parent_metric_id TEXT REFERENCES display_metrics(display_metric_id) ON DELETE CASCADE;

-- Add index for performance
CREATE INDEX idx_display_metrics_parent ON display_metrics(parent_metric_id);

-- Add comment explaining the pattern
COMMENT ON COLUMN display_metrics.parent_metric_id IS
'References parent metric for child metrics. Null for parent metrics.
Mobile UI shows parent metric with main chart, "View Details" reveals children.
Example: DISP_PROTEIN_SERVINGS (parent) has children like DISP_PROTEIN_SERVINGS_BREAKFAST';
