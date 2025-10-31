-- =====================================================
-- Create Junction Tables for Primary/Detail Metrics
-- =====================================================
-- Allows many-to-many relationships:
--   - One metric can appear on multiple primary screens
--   - One metric can appear on multiple detail screens
--   - Use case: Show alcohol on Substances AND Sleep screens
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Create Junction Tables
-- =====================================================

-- Primary Screen → Metrics (many-to-many)
CREATE TABLE display_screens_primary_display_metrics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  primary_screen_id text NOT NULL REFERENCES display_screens_primary(primary_screen_id) ON DELETE CASCADE,
  metric_id text NOT NULL REFERENCES display_metrics(metric_id) ON DELETE CASCADE,

  -- Display order on this screen
  display_order integer DEFAULT 1,

  -- Role on this screen
  is_featured boolean DEFAULT false, -- Is this the "hero" metric?
  is_comparison boolean DEFAULT false, -- Is this a comparison/correlation metric?

  -- Override configuration for this screen
  override_title text, -- Custom title for this context
  override_description text,
  override_chart_type text REFERENCES chart_types(chart_type_id),

  -- Context for this metric on this screen
  context_label text, -- e.g., "Your Sleep vs Alcohol"
  context_description text, -- Explain why this metric is relevant here

  -- Metadata
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW(),

  UNIQUE(primary_screen_id, metric_id)
);

CREATE INDEX idx_primary_metrics_primary_screen ON display_screens_primary_display_metrics(primary_screen_id);
CREATE INDEX idx_primary_metrics_metric ON display_screens_primary_display_metrics(metric_id);
CREATE INDEX idx_primary_metrics_featured ON display_screens_primary_display_metrics(is_featured) WHERE is_featured = true;

COMMENT ON TABLE display_screens_primary_display_metrics IS
'Junction table: Primary screens → Metrics (many-to-many). One metric can appear on multiple primary screens for comparisons/correlations.';

COMMENT ON COLUMN display_screens_primary_display_metrics.is_featured IS
'True if this is the main "hero" metric for this screen (typically only 1 per screen)';

COMMENT ON COLUMN display_screens_primary_display_metrics.is_comparison IS
'True if this metric is shown for comparison purposes (e.g., alcohol on sleep screen)';

COMMENT ON COLUMN display_screens_primary_display_metrics.context_label IS
'Label explaining why this metric is on this screen. E.g., "Impact on Sleep Quality"';

-- Detail Screen → Metrics (many-to-many)
CREATE TABLE display_screens_detail_display_metrics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  detail_screen_id text NOT NULL REFERENCES display_screens_detail(detail_screen_id) ON DELETE CASCADE,
  metric_id text NOT NULL REFERENCES display_metrics(metric_id) ON DELETE CASCADE,

  -- Organization on detail screen
  section_id text, -- Which section/tab does this belong to?
  display_order integer DEFAULT 1,

  -- Role on this screen
  is_comparison boolean DEFAULT false,

  -- Override configuration for this screen
  override_title text,
  override_description text,
  override_chart_type text REFERENCES chart_types(chart_type_id),

  -- Context
  context_label text,
  context_description text,

  -- Metadata
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW(),

  UNIQUE(detail_screen_id, metric_id, section_id)
);

CREATE INDEX idx_detail_metrics_detail_screen ON display_screens_detail_display_metrics(detail_screen_id);
CREATE INDEX idx_detail_metrics_metric ON display_screens_detail_display_metrics(metric_id);
CREATE INDEX idx_detail_metrics_section ON display_screens_detail_display_metrics(section_id);

COMMENT ON TABLE display_screens_detail_display_metrics IS
'Junction table: Detail screens → Metrics (many-to-many). Metrics can appear on multiple detail screens and be organized into sections/tabs.';

COMMENT ON COLUMN display_screens_detail_display_metrics.section_id IS
'Organizes metrics into sections/tabs on detail screen. E.g., "timing", "sources", "quality"';

-- =====================================================
-- STEP 2: Migrate Existing FK Relationships
-- =====================================================

-- Migrate primary_screen_id relationships
INSERT INTO display_screens_primary_display_metrics (
  primary_screen_id,
  metric_id,
  display_order,
  is_featured
)
SELECT
  primary_screen_id,
  metric_id,
  ROW_NUMBER() OVER (PARTITION BY primary_screen_id ORDER BY metric_id) as display_order,
  ROW_NUMBER() OVER (PARTITION BY primary_screen_id ORDER BY metric_id) = 1 as is_featured
FROM display_metrics
WHERE primary_screen_id IS NOT NULL;

-- Migrate detail_screen_id relationships
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  display_order
)
SELECT
  detail_screen_id,
  metric_id,
  ROW_NUMBER() OVER (PARTITION BY detail_screen_id ORDER BY metric_id) as display_order
FROM display_metrics
WHERE detail_screen_id IS NOT NULL;

-- =====================================================
-- STEP 3: Drop Old FK Columns and Constraints
-- =====================================================

-- Drop check constraint
ALTER TABLE display_metrics
DROP CONSTRAINT IF EXISTS display_metrics_screen_assignment_check;

-- Drop FK columns
ALTER TABLE display_metrics
DROP COLUMN IF EXISTS primary_screen_id,
DROP COLUMN IF EXISTS detail_screen_id;

-- Drop indexes
DROP INDEX IF EXISTS idx_display_metrics_primary_screen;
DROP INDEX IF EXISTS idx_display_metrics_detail_screen;

-- =====================================================
-- STEP 4: Add Example Cross-Screen Metrics
-- =====================================================

-- Example: Show alcohol on sleep timing screen (correlation)
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  is_comparison,
  context_label,
  context_description
)
SELECT
  'SCREEN_SLEEP_TIMING' || '_DETAIL',
  'DISP_ALCOHOL_DRINKS',
  'sleep_factors',
  99,
  true,
  'Alcohol & Sleep Impact',
  'Alcohol consumption can affect sleep quality and timing. See how your drinking patterns correlate with sleep metrics.'
WHERE EXISTS (SELECT 1 FROM display_metrics WHERE metric_id = 'DISP_ALCOHOL_DRINKS')
  AND EXISTS (SELECT 1 FROM display_screens_detail WHERE detail_screen_id = 'SCREEN_SLEEP_TIMING' || '_DETAIL')
ON CONFLICT (detail_screen_id, metric_id, section_id) DO NOTHING;

-- Example: Show steps on sleep screen (activity correlation)
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id,
  metric_id,
  section_id,
  display_order,
  is_comparison,
  context_label,
  context_description
)
SELECT
  'SCREEN_SLEEP_QUALITY' || '_DETAIL',
  'DISP_STEPS',
  'activity_correlation',
  98,
  true,
  'Activity & Sleep Quality',
  'Physical activity can improve sleep quality. See how your daily steps correlate with sleep metrics.'
WHERE EXISTS (SELECT 1 FROM display_metrics WHERE metric_id = 'DISP_STEPS')
  AND EXISTS (SELECT 1 FROM display_screens_detail WHERE detail_screen_id = 'SCREEN_SLEEP_QUALITY' || '_DETAIL')
ON CONFLICT (detail_screen_id, metric_id, section_id) DO NOTHING;

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  primary_links INT;
  detail_links INT;
  multi_screen_metrics INT;
BEGIN
  SELECT COUNT(*) INTO primary_links FROM display_screens_primary_display_metrics;
  SELECT COUNT(*) INTO detail_links FROM display_screens_detail_display_metrics;

  -- Count metrics that appear on multiple screens
  SELECT COUNT(DISTINCT metric_id) INTO multi_screen_metrics
  FROM (
    SELECT metric_id, COUNT(DISTINCT primary_screen_id) as screen_count
    FROM display_screens_primary_display_metrics
    GROUP BY metric_id
    HAVING COUNT(DISTINCT primary_screen_id) > 1

    UNION ALL

    SELECT metric_id, COUNT(DISTINCT detail_screen_id) as screen_count
    FROM display_screens_detail_display_metrics
    GROUP BY metric_id
    HAVING COUNT(DISTINCT detail_screen_id) > 1
  ) multi;

  RAISE NOTICE '✅ Junction Tables Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Relationships:';
  RAISE NOTICE '  Primary Screen → Metrics: % links', primary_links;
  RAISE NOTICE '  Detail Screen → Metrics: % links', detail_links;
  RAISE NOTICE '  Metrics on multiple screens: %', multi_screen_metrics;
  RAISE NOTICE '';
  RAISE NOTICE 'Many-to-Many:';
  RAISE NOTICE '  ✓ Metrics can appear on multiple screens';
  RAISE NOTICE '  ✓ Screens can have multiple metrics';
  RAISE NOTICE '  ✓ Use case: Show alcohol on Substances AND Sleep screens';
END $$;

-- Show example cross-screen metrics
SELECT
  dm.metric_name,
  COUNT(DISTINCT pdm.primary_screen_id) as on_primary_screens,
  COUNT(DISTINCT ddm.detail_screen_id) as on_detail_screens,
  string_agg(DISTINCT dsp.title, ', ') as primary_screens,
  string_agg(DISTINCT dsd.title, ', ') as detail_screens
FROM display_metrics dm
LEFT JOIN display_screens_primary_display_metrics pdm ON pdm.metric_id = dm.metric_id
LEFT JOIN display_screens_detail_display_metrics ddm ON ddm.metric_id = dm.metric_id
LEFT JOIN display_screens_primary dsp ON dsp.primary_screen_id = pdm.primary_screen_id
LEFT JOIN display_screens_detail dsd ON dsd.detail_screen_id = ddm.detail_screen_id
GROUP BY dm.metric_id, dm.metric_name
HAVING COUNT(DISTINCT pdm.primary_screen_id) + COUNT(DISTINCT ddm.detail_screen_id) > 1
ORDER BY (COUNT(DISTINCT pdm.primary_screen_id) + COUNT(DISTINCT ddm.detail_screen_id)) DESC
LIMIT 10;

COMMIT;
