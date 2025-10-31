-- =====================================================================================
-- Add is_parent Boolean Column to Display Metrics
-- =====================================================================================
-- Makes it easier to query for parent metrics without complex EXISTS checks
-- =====================================================================================

-- Add is_parent column
ALTER TABLE display_metrics
ADD COLUMN is_parent BOOLEAN DEFAULT false NOT NULL;

-- Update existing parent metrics (metrics that have children)
UPDATE display_metrics
SET is_parent = true
WHERE display_metric_id IN (
  SELECT DISTINCT parent_metric_id
  FROM display_metrics
  WHERE parent_metric_id IS NOT NULL
);

-- Add index for performance
CREATE INDEX idx_display_metrics_is_parent ON display_metrics(is_parent) WHERE is_parent = true;

-- Add comment
COMMENT ON COLUMN display_metrics.is_parent IS
'True for parent metrics that have children. Makes it easy to query parent metrics without EXISTS checks.
Example: SELECT * FROM display_metrics WHERE is_parent = true AND pillar = ''Movement + Exercise''';

-- Verify the update
SELECT
  is_parent,
  COUNT(*) as count
FROM display_metrics
GROUP BY is_parent
ORDER BY is_parent DESC;

-- Show the 19 parent metrics
SELECT
  display_metric_id,
  display_name,
  pillar,
  (SELECT COUNT(*) FROM display_metrics c WHERE c.parent_metric_id = p.display_metric_id) as child_count
FROM display_metrics p
WHERE is_parent = true
ORDER BY pillar, display_name;
