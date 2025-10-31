-- =====================================================================================
-- Update Foreign Key References for New Parent/Child Structure
-- =====================================================================================
-- Creates new junction tables that can reference both parents and children
-- Migrates data from old tables
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Create new aggregations table (supports both parents and children)
-- =====================================================================================

CREATE TABLE parent_child_display_metrics_aggregations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Either parent_id or child_id (not both)
  parent_metric_id text REFERENCES parent_display_metrics(parent_metric_id) ON DELETE CASCADE,
  child_metric_id text REFERENCES child_display_metrics(child_metric_id) ON DELETE CASCADE,

  -- Aggregation configuration
  agg_metric_id text NOT NULL REFERENCES aggregation_metrics(agg_id) ON DELETE CASCADE,
  period_type text NOT NULL REFERENCES aggregation_periods(period_id) ON UPDATE CASCADE ON DELETE CASCADE,
  calculation_type_id text NOT NULL REFERENCES calculation_types(type_id),

  -- Display configuration
  display_order integer,
  is_primary boolean DEFAULT false,

  created_at timestamptz DEFAULT NOW(),

  -- Constraint: must have exactly one of parent or child
  CONSTRAINT check_exactly_one_metric CHECK (
    (parent_metric_id IS NOT NULL AND child_metric_id IS NULL) OR
    (parent_metric_id IS NULL AND child_metric_id IS NOT NULL)
  ),

  -- Unique constraint
  CONSTRAINT unique_parent_child_agg UNIQUE (parent_metric_id, child_metric_id, agg_metric_id, period_type, calculation_type_id)
);

-- Indexes
CREATE INDEX idx_pc_agg_parent ON parent_child_display_metrics_aggregations(parent_metric_id);
CREATE INDEX idx_pc_agg_child ON parent_child_display_metrics_aggregations(child_metric_id);
CREATE INDEX idx_pc_agg_metric ON parent_child_display_metrics_aggregations(agg_metric_id);

COMMENT ON TABLE parent_child_display_metrics_aggregations IS
'Links parent or child metrics to their aggregations. Each row references either a parent OR a child (not both).';

-- =====================================================================================
-- STEP 2: Create new preferences table (supports both parents and children)
-- =====================================================================================

CREATE TABLE parent_child_user_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,

  -- Either parent_id or child_id (not both)
  parent_metric_id text REFERENCES parent_display_metrics(parent_metric_id) ON DELETE CASCADE,
  child_metric_id text REFERENCES child_display_metrics(child_metric_id) ON DELETE CASCADE,

  -- User preferences
  preferred_unit text,
  is_visible boolean DEFAULT true,
  display_order integer,
  widget_size text,

  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW(),

  -- Constraint: must have exactly one of parent or child
  CONSTRAINT check_exactly_one_metric_pref CHECK (
    (parent_metric_id IS NOT NULL AND child_metric_id IS NULL) OR
    (parent_metric_id IS NULL AND child_metric_id IS NOT NULL)
  ),

  -- Unique constraint
  CONSTRAINT unique_user_metric_pref UNIQUE (user_id, parent_metric_id, child_metric_id)
);

-- Indexes
CREATE INDEX idx_pc_pref_user ON parent_child_user_preferences(user_id);
CREATE INDEX idx_pc_pref_parent ON parent_child_user_preferences(parent_metric_id);
CREATE INDEX idx_pc_pref_child ON parent_child_user_preferences(child_metric_id);

-- Trigger
CREATE TRIGGER update_parent_child_user_preferences_updated_at
  BEFORE UPDATE ON parent_child_user_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE parent_child_user_preferences IS
'User preferences for parent or child metrics. Unit preferences for parents cascade to children unless child overrides.';

-- =====================================================================================
-- STEP 3: Create new display_screens junction table
-- =====================================================================================

CREATE TABLE display_screens_parent_metrics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  screen_id text NOT NULL REFERENCES display_screens(screen_id) ON DELETE CASCADE,
  parent_metric_id text NOT NULL REFERENCES parent_display_metrics(parent_metric_id) ON DELETE CASCADE,
  display_order integer,
  created_at timestamptz DEFAULT NOW(),

  CONSTRAINT unique_screen_parent UNIQUE (screen_id, parent_metric_id)
);

CREATE INDEX idx_screen_parent_screen ON display_screens_parent_metrics(screen_id);
CREATE INDEX idx_screen_parent_metric ON display_screens_parent_metrics(parent_metric_id);

COMMENT ON TABLE display_screens_parent_metrics IS
'Links display screens to parent metrics. Only parents appear in screens; children are accessed via parent expansion.';

-- =====================================================================================
-- STEP 4: Migrate aggregation data
-- =====================================================================================

-- Migrate parent aggregations
INSERT INTO parent_child_display_metrics_aggregations (
  parent_metric_id,
  child_metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order,
  is_primary
)
SELECT
  dma.display_metric_id,
  NULL,
  dma.agg_metric_id,
  dma.period_type,
  dma.calculation_type_id,
  dma.display_order,
  dma.is_primary
FROM display_metrics_aggregations dma
JOIN parent_display_metrics pdm ON dma.display_metric_id = pdm.parent_metric_id
ON CONFLICT DO NOTHING;

-- Migrate child aggregations
INSERT INTO parent_child_display_metrics_aggregations (
  parent_metric_id,
  child_metric_id,
  agg_metric_id,
  period_type,
  calculation_type_id,
  display_order,
  is_primary
)
SELECT
  NULL,
  dma.display_metric_id,
  dma.agg_metric_id,
  dma.period_type,
  dma.calculation_type_id,
  dma.display_order,
  dma.is_primary
FROM display_metrics_aggregations dma
JOIN child_display_metrics cdm ON dma.display_metric_id = cdm.child_metric_id
ON CONFLICT DO NOTHING;

-- =====================================================================================
-- STEP 5: Migrate user preferences
-- =====================================================================================

-- Migrate parent preferences
INSERT INTO parent_child_user_preferences (
  user_id,
  parent_metric_id,
  child_metric_id,
  preferred_unit,
  is_visible,
  display_order,
  widget_size
)
SELECT
  pdmp.user_id,
  dm.display_metric_id,
  NULL,
  pdmp.preferred_unit,
  pdmp.is_visible,
  pdmp.display_order,
  pdmp.widget_size
FROM patient_display_metrics_preferences pdmp
JOIN display_metrics dm ON pdmp.display_metric_id = dm.id
JOIN parent_display_metrics pdm ON dm.display_metric_id = pdm.parent_metric_id
ON CONFLICT DO NOTHING;

-- Migrate child preferences
INSERT INTO parent_child_user_preferences (
  user_id,
  parent_metric_id,
  child_metric_id,
  preferred_unit,
  is_visible,
  display_order,
  widget_size
)
SELECT
  pdmp.user_id,
  NULL,
  dm.display_metric_id,
  pdmp.preferred_unit,
  pdmp.is_visible,
  pdmp.display_order,
  pdmp.widget_size
FROM patient_display_metrics_preferences pdmp
JOIN display_metrics dm ON pdmp.display_metric_id = dm.id
JOIN child_display_metrics cdm ON dm.display_metric_id = cdm.child_metric_id
ON CONFLICT DO NOTHING;

-- =====================================================================================
-- STEP 6: Migrate display screens (only parents appear in screens)
-- =====================================================================================

INSERT INTO display_screens_parent_metrics (
  screen_id,
  parent_metric_id,
  display_order
)
SELECT DISTINCT
  dsdm.display_screen,
  pdm.parent_metric_id,
  MIN(dsdm.display_order)
FROM display_screens_display_metrics dsdm
JOIN display_metrics dm ON dsdm.display_metric = dm.display_metric_id
JOIN parent_display_metrics pdm ON dm.display_metric_id = pdm.parent_metric_id
GROUP BY dsdm.display_screen, pdm.parent_metric_id
ON CONFLICT DO NOTHING;

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show aggregations migrated
SELECT
  'Aggregations' as table_name,
  COUNT(*) FILTER (WHERE parent_metric_id IS NOT NULL) as parent_count,
  COUNT(*) FILTER (WHERE child_metric_id IS NOT NULL) as child_count,
  COUNT(*) as total
FROM parent_child_display_metrics_aggregations

UNION ALL

-- Show preferences migrated
SELECT
  'Preferences' as table_name,
  COUNT(*) FILTER (WHERE parent_metric_id IS NOT NULL) as parent_count,
  COUNT(*) FILTER (WHERE child_metric_id IS NOT NULL) as child_count,
  COUNT(*) as total
FROM parent_child_user_preferences

UNION ALL

-- Show screens migrated
SELECT
  'Screens' as table_name,
  COUNT(DISTINCT parent_metric_id) as parent_count,
  0 as child_count,
  COUNT(*) as total
FROM display_screens_parent_metrics;
