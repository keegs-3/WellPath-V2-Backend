-- =====================================================
-- Create Primary/Detail Screen Architecture
-- =====================================================
-- Navigation flow:
--   Pillar → Display Screen → Primary Screen → Detail Screen
--
-- Primary Screen: Summary view (1+ key metrics)
-- Detail Screen: "View More [Screen] Data" modal with breakdowns
-- =====================================================

BEGIN;

-- =====================================================
-- STEP 1: Create display_screens_primary
-- =====================================================

CREATE TABLE display_screens_primary (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  primary_screen_id text UNIQUE NOT NULL,
  display_screen_id text NOT NULL REFERENCES display_screens(screen_id) ON DELETE CASCADE,

  -- Display
  title text NOT NULL,
  subtitle text,
  description text,
  display_order integer DEFAULT 1,

  -- Layout configuration for Swift
  layout_type text DEFAULT 'single_metric', -- 'single_metric', 'multi_metric', 'grid', 'featured'
  primary_metric_id text, -- The main "hero" metric to feature

  -- Navigation
  has_detail_screen boolean DEFAULT true,
  detail_button_text text DEFAULT 'View More Data',
  detail_button_icon text DEFAULT 'chevron.right',

  -- Education & help content
  education_content_id text, -- FK to future education_content table
  quick_tips jsonb DEFAULT '[]'::jsonb, -- [{"tip": "...", "icon": "..."}]
  info_sections jsonb DEFAULT '[]'::jsonb, -- [{"title": "...", "content": "..."}]

  -- Goals and targets (optional)
  has_goal boolean DEFAULT false,
  goal_config jsonb, -- {"type": "daily_target", "value": 100, "unit": "grams"}

  -- Metadata
  metadata jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW(),

  UNIQUE(display_screen_id) -- Each screen has exactly one primary
);

CREATE INDEX idx_primary_screens_display ON display_screens_primary(display_screen_id);
CREATE INDEX idx_primary_screens_active ON display_screens_primary(is_active) WHERE is_active = true;

COMMENT ON TABLE display_screens_primary IS
'Primary/summary view for each display screen. Shows 1-3 key metrics. User can tap "View More" to see detail screen.';

COMMENT ON COLUMN display_screens_primary.layout_type IS
'Layout hint for Swift: single_metric (one big chart), multi_metric (2-3 small charts), grid (metric tiles), featured (hero metric + stats)';

COMMENT ON COLUMN display_screens_primary.quick_tips IS
'Array of quick tips shown on primary screen: [{"tip": "Aim for 25-30g per meal", "icon": "lightbulb"}]';

COMMENT ON COLUMN display_screens_primary.metadata IS
'Flexible metadata for future features: colors, icons, custom config, etc.';

-- =====================================================
-- STEP 2: Create display_screens_detail
-- =====================================================

CREATE TABLE display_screens_detail (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  detail_screen_id text UNIQUE NOT NULL,
  display_screen_id text NOT NULL REFERENCES display_screens(screen_id) ON DELETE CASCADE,

  -- Display
  title text NOT NULL,
  subtitle text,
  description text,

  -- Layout configuration for Swift
  layout_type text DEFAULT 'sections', -- 'tabs', 'sections', 'list', 'grid'
  section_config jsonb DEFAULT '[]'::jsonb, -- [{"section_id": "by_meal", "title": "By Meal", "type": "stacked_chart"}]

  -- Tab configuration (if layout_type = 'tabs')
  tab_config jsonb DEFAULT '[]'::jsonb, -- [{"tab_id": "timing", "title": "Timing", "icon": "clock"}]

  -- Education & detailed content
  education_content_id text,
  detailed_info jsonb DEFAULT '[]'::jsonb, -- [{"section": "Benefits", "content": "..."}]
  faq jsonb DEFAULT '[]'::jsonb, -- [{"question": "...", "answer": "..."}]
  related_articles jsonb DEFAULT '[]'::jsonb, -- [{"title": "...", "url": "..."}]

  -- Insights and analysis
  show_insights boolean DEFAULT false,
  insights_config jsonb, -- {"type": "ai_generated", "refresh_interval": "daily"}

  -- Metadata
  metadata jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW(),

  UNIQUE(display_screen_id) -- Each screen has exactly one detail
);

CREATE INDEX idx_detail_screens_display ON display_screens_detail(display_screen_id);
CREATE INDEX idx_detail_screens_active ON display_screens_detail(is_active) WHERE is_active = true;

COMMENT ON TABLE display_screens_detail IS
'Detail/drill-down view for each display screen. Accessed via "View More" button on primary screen. Shows comprehensive breakdowns, trends, and education.';

COMMENT ON COLUMN display_screens_detail.layout_type IS
'Layout hint for Swift: tabs (tabbed interface), sections (scrollable sections), list (metric list), grid (metric grid)';

COMMENT ON COLUMN display_screens_detail.section_config IS
'Defines sections in detail view: [{"section_id": "meal_timing", "title": "By Meal", "metrics": ["DISP_PROTEIN_MEAL_TIMING"]}]';

COMMENT ON COLUMN display_screens_detail.detailed_info IS
'Rich educational content: [{"section": "Why It Matters", "content": "Protein is essential for...", "image_url": "..."}]';

-- =====================================================
-- STEP 3: Update display_metrics to FK to primary/detail
-- =====================================================

-- Add new FK columns
ALTER TABLE display_metrics
ADD COLUMN primary_screen_id text REFERENCES display_screens_primary(primary_screen_id) ON DELETE CASCADE,
ADD COLUMN detail_screen_id text REFERENCES display_screens_detail(detail_screen_id) ON DELETE CASCADE;

-- Create indexes
CREATE INDEX idx_display_metrics_primary_screen ON display_metrics(primary_screen_id);
CREATE INDEX idx_display_metrics_detail_screen ON display_metrics(detail_screen_id);

COMMENT ON COLUMN display_metrics.primary_screen_id IS
'FK to primary screen. Metrics on primary screen are featured/summary metrics (1-3 per screen).';

COMMENT ON COLUMN display_metrics.detail_screen_id IS
'FK to detail screen. Metrics on detail screen provide comprehensive breakdowns and drill-downs.';

-- =====================================================
-- STEP 4: Create primary/detail screens for existing screens
-- =====================================================

-- Create primary and detail screens for all active display_screens
INSERT INTO display_screens_primary (
  primary_screen_id,
  display_screen_id,
  title,
  description,
  layout_type,
  has_detail_screen
)
SELECT
  screen_id || '_PRIMARY',
  screen_id,
  name,
  overview,
  CASE
    WHEN name ILIKE '%protein%' THEN 'single_metric'
    WHEN name ILIKE '%sleep%' THEN 'single_metric'
    WHEN name ILIKE '%biometric%' THEN 'grid'
    ELSE 'single_metric'
  END,
  true
FROM display_screens
WHERE is_active = true
ON CONFLICT (primary_screen_id) DO NOTHING;

INSERT INTO display_screens_detail (
  detail_screen_id,
  display_screen_id,
  title,
  description,
  layout_type
)
SELECT
  screen_id || '_DETAIL',
  screen_id,
  name || ' Details',
  'Detailed breakdown and analysis for ' || name,
  CASE
    WHEN name ILIKE '%protein%' THEN 'tabs'
    WHEN name ILIKE '%sleep%' THEN 'sections'
    WHEN name ILIKE '%biometric%' THEN 'list'
    ELSE 'sections'
  END
FROM display_screens
WHERE is_active = true
ON CONFLICT (detail_screen_id) DO NOTHING;

-- =====================================================
-- STEP 5: Migrate existing metrics to primary/detail
-- =====================================================

-- Default strategy:
-- - Main aggregation metrics (grams, duration, etc.) → PRIMARY
-- - Breakdowns (meal timing, by type, etc.) → DETAIL

-- PRIMARY METRICS (featured/summary)
UPDATE display_metrics SET primary_screen_id = screen_id || '_PRIMARY'
WHERE screen_id IS NOT NULL
  AND (
    metric_id LIKE '%_GRAMS' OR
    metric_id LIKE '%_DURATION' OR
    metric_id LIKE '%_SESSIONS' OR
    metric_id LIKE '%_COUNT' OR
    metric_id = 'DISP_SLEEP_ANALYSIS' OR
    metric_id LIKE '%_CONSISTENCY' OR
    metric_id LIKE '%_EFFICIENCY'
  );

-- DETAIL METRICS (breakdowns and drill-downs)
UPDATE display_metrics SET detail_screen_id = screen_id || '_DETAIL'
WHERE screen_id IS NOT NULL
  AND primary_screen_id IS NULL
  AND (
    metric_id LIKE '%_TIMING' OR
    metric_id LIKE '%_MEAL_%' OR
    metric_id LIKE '%_BY_%' OR
    metric_id LIKE '%_SOURCE_%' OR
    metric_id LIKE '%_TYPE_%' OR
    metric_id LIKE '%_PCT' OR
    metric_id LIKE '%_CYCLES' OR
    metric_id LIKE '%_EPISODES'
  );

-- Remaining metrics without assignment → PRIMARY (default)
UPDATE display_metrics SET primary_screen_id = screen_id || '_PRIMARY'
WHERE screen_id IS NOT NULL
  AND primary_screen_id IS NULL
  AND detail_screen_id IS NULL;

-- Handle metrics with no screen_id (orphaned metrics) → Delete them
DELETE FROM display_metrics
WHERE screen_id IS NULL;

-- Remove old screen_id column
ALTER TABLE display_metrics
DROP COLUMN screen_id;

-- Validation: Check for metrics with invalid assignments
DO $$
DECLARE
  both_assigned INT;
  neither_assigned INT;
BEGIN
  SELECT COUNT(*) INTO both_assigned
  FROM display_metrics
  WHERE primary_screen_id IS NOT NULL AND detail_screen_id IS NOT NULL;

  SELECT COUNT(*) INTO neither_assigned
  FROM display_metrics
  WHERE primary_screen_id IS NULL AND detail_screen_id IS NULL;

  IF both_assigned > 0 THEN
    RAISE EXCEPTION '% metrics have BOTH primary and detail assigned', both_assigned;
  END IF;

  IF neither_assigned > 0 THEN
    RAISE EXCEPTION '% metrics have NEITHER primary nor detail assigned', neither_assigned;
  END IF;

  RAISE NOTICE '✓ All metrics properly assigned';
END $$;

-- Add check constraint NOW (after all metrics are assigned)
ALTER TABLE display_metrics
ADD CONSTRAINT display_metrics_screen_assignment_check
CHECK (
  (primary_screen_id IS NOT NULL AND detail_screen_id IS NULL) OR
  (primary_screen_id IS NULL AND detail_screen_id IS NOT NULL)
);

-- =====================================================
-- VERIFICATION
-- =====================================================

DO $$
DECLARE
  screens_count INT;
  primary_count INT;
  detail_count INT;
  metrics_primary INT;
  metrics_detail INT;
  unassigned INT;
BEGIN
  SELECT COUNT(*) INTO screens_count FROM display_screens WHERE is_active = true;
  SELECT COUNT(*) INTO primary_count FROM display_screens_primary WHERE is_active = true;
  SELECT COUNT(*) INTO detail_count FROM display_screens_detail WHERE is_active = true;
  SELECT COUNT(*) INTO metrics_primary FROM display_metrics WHERE primary_screen_id IS NOT NULL;
  SELECT COUNT(*) INTO metrics_detail FROM display_metrics WHERE detail_screen_id IS NOT NULL;
  SELECT COUNT(*) INTO unassigned FROM display_metrics WHERE primary_screen_id IS NULL AND detail_screen_id IS NULL;

  RAISE NOTICE '✅ Primary/Detail Screen Architecture Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Structure:';
  RAISE NOTICE '  display_screens: % screens', screens_count;
  RAISE NOTICE '  display_screens_primary: % primary screens', primary_count;
  RAISE NOTICE '  display_screens_detail: % detail screens', detail_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Metrics Assignment:';
  RAISE NOTICE '  Primary screens: % metrics', metrics_primary;
  RAISE NOTICE '  Detail screens: % metrics', metrics_detail;
  RAISE NOTICE '  Unassigned: % metrics', unassigned;
  RAISE NOTICE '';
  RAISE NOTICE 'Navigation Flow:';
  RAISE NOTICE '  Pillar → Display Screen → Primary Screen (summary) → Detail Screen (breakdowns)';
END $$;

-- Show example breakdown for a few screens
SELECT
  ds.name as screen,
  COUNT(DISTINCT dm_p.metric_id) as primary_metrics,
  COUNT(DISTINCT dm_d.metric_id) as detail_metrics
FROM display_screens ds
LEFT JOIN display_screens_primary dsp ON dsp.display_screen_id = ds.screen_id
LEFT JOIN display_screens_detail dsd ON dsd.display_screen_id = ds.screen_id
LEFT JOIN display_metrics dm_p ON dm_p.primary_screen_id = dsp.primary_screen_id
LEFT JOIN display_metrics dm_d ON dm_d.detail_screen_id = dsd.detail_screen_id
WHERE ds.is_active = true
GROUP BY ds.screen_id, ds.name
ORDER BY primary_metrics DESC, detail_metrics DESC
LIMIT 10;

COMMIT;
