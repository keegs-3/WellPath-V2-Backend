-- Add hourly period to AGG_PROTEIN_SERVINGS so mobile "day" view works
-- Mobile day view expects hourly granularity data

INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SERVINGS', 'hourly')
ON CONFLICT (agg_metric_id, period_id) DO NOTHING;

-- Verify configuration
SELECT
  'AGG_PROTEIN_SERVINGS now supports periods:' as info,
  string_agg(period_id, ', ' ORDER BY
    CASE period_id
      WHEN 'hourly' THEN 1
      WHEN 'daily' THEN 2
      WHEN 'weekly' THEN 3
      WHEN 'monthly' THEN 4
    END
  ) as periods
FROM aggregation_metrics_periods
WHERE agg_metric_id = 'AGG_PROTEIN_SERVINGS';
