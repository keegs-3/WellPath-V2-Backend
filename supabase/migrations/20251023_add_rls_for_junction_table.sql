-- =====================================================================================
-- Enable RLS for parent_child_display_metrics_aggregations Junction Table
-- =====================================================================================
-- This table maps display metrics to their underlying aggregation metrics.
-- All authenticated users need read access to query which aggregations to use.
-- =====================================================================================

-- Enable RLS
ALTER TABLE parent_child_display_metrics_aggregations ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read from the junction table
-- This is a configuration/lookup table, so all users can see all mappings
CREATE POLICY "Allow authenticated users to read junction table"
ON parent_child_display_metrics_aggregations
FOR SELECT
TO authenticated
USING (true);

COMMENT ON POLICY "Allow authenticated users to read junction table"
ON parent_child_display_metrics_aggregations IS
'All authenticated users can read the junction table to determine which aggregation metrics to query for display metrics.';
