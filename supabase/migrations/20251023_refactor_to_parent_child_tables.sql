-- =====================================================================================
-- Refactor Display Metrics to Separate Parent/Child Tables
-- =====================================================================================
-- Creates parent_display_metrics and child_display_metrics tables
-- Migrates data from existing display_metrics table
-- Provides cleaner separation of concerns and better categorization
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Create parent_display_metrics table
-- =====================================================================================

CREATE TABLE parent_display_metrics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_metric_id text UNIQUE NOT NULL,
  parent_name text NOT NULL,
  parent_description text,
  pillar text REFERENCES pillars_base(pillar_name) ON UPDATE CASCADE ON DELETE CASCADE,

  -- Unit toggle support
  supported_units jsonb DEFAULT '["default"]'::jsonb NOT NULL,
  default_unit text,

  -- Chart configuration
  chart_type_id text REFERENCES chart_types(chart_type_id),
  supported_periods text[] DEFAULT ARRAY['daily', 'weekly', 'monthly']::text[],
  default_period text DEFAULT 'weekly',
  chart_config jsonb DEFAULT '{}'::jsonb,

  -- Display preferences
  expand_by_default boolean DEFAULT false,
  summary_display_mode text DEFAULT 'latest' CHECK (summary_display_mode IN ('total', 'average', 'latest', 'none')),
  view_details_label text DEFAULT 'View Details',

  -- Display configuration
  display_format text,
  display_transformation text,
  display_unit text,
  null_handling text DEFAULT 'ignore' CHECK (null_handling IN ('ignore', 'show_as_zero', 'show_as_null', 'hide', 'interpolate')),
  null_display_value text,
  filter_config jsonb DEFAULT '{}'::jsonb,

  -- Widget/UI
  widget_type text,
  display_order integer,
  is_featured boolean DEFAULT false,
  is_active boolean DEFAULT true,

  -- Timestamps
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW(),

  -- Constraints
  CONSTRAINT parent_default_period_check CHECK (default_period = ANY (supported_periods))
);

-- Indexes
CREATE INDEX idx_parent_display_metrics_pillar ON parent_display_metrics(pillar);
CREATE INDEX idx_parent_display_metrics_active ON parent_display_metrics(is_active) WHERE is_active = true;

-- Comments
COMMENT ON TABLE parent_display_metrics IS
'Parent metrics that have expandable children. Shown in main metric list with "View Details" to reveal children.
Example: Protein Intake (parent) → Breakfast, Lunch, Dinner (children)';

COMMENT ON COLUMN parent_display_metrics.supported_units IS
'Array of units this metric can display in. Examples: ["servings", "grams"], ["minutes", "hours"]';

COMMENT ON COLUMN parent_display_metrics.expand_by_default IS
'If true, children are shown expanded by default in UI';

COMMENT ON COLUMN parent_display_metrics.summary_display_mode IS
'How to display parent value: total (sum of children), average, latest entry, or none';

-- =====================================================================================
-- STEP 2: Create child_display_metrics table
-- =====================================================================================

CREATE TABLE child_display_metrics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  child_metric_id text UNIQUE NOT NULL,
  parent_metric_id text NOT NULL REFERENCES parent_display_metrics(parent_metric_id) ON DELETE CASCADE,

  child_name text NOT NULL,
  child_description text,

  -- Categorization within parent
  child_category text,
  display_order_in_parent integer,
  display_order_in_category integer,

  -- Unit toggle (can inherit or override parent)
  supported_units jsonb DEFAULT '["default"]'::jsonb NOT NULL,
  default_unit text,
  inherit_parent_unit boolean DEFAULT true,

  -- Chart configuration (can differ from parent)
  chart_type_id text REFERENCES chart_types(chart_type_id),
  supported_periods text[] DEFAULT ARRAY['daily', 'weekly', 'monthly']::text[],
  default_period text DEFAULT 'weekly',
  chart_config jsonb DEFAULT '{}'::jsonb,

  -- Child-specific display
  show_in_summary boolean DEFAULT true,
  summary_format text,
  icon_override text,
  color_override text,

  -- Display configuration
  display_format text,
  display_transformation text,
  display_unit text,
  null_handling text DEFAULT 'ignore' CHECK (null_handling IN ('ignore', 'show_as_zero', 'show_as_null', 'hide', 'interpolate')),
  null_display_value text,
  filter_config jsonb DEFAULT '{}'::jsonb,

  -- Widget/UI
  widget_type text,
  is_active boolean DEFAULT true,

  -- Timestamps
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW(),

  -- Constraints
  CONSTRAINT child_default_period_check CHECK (default_period = ANY (supported_periods))
);

-- Indexes
CREATE INDEX idx_child_display_metrics_parent ON child_display_metrics(parent_metric_id);
CREATE INDEX idx_child_display_metrics_category ON child_display_metrics(parent_metric_id, child_category);
CREATE INDEX idx_child_display_metrics_active ON child_display_metrics(is_active) WHERE is_active = true;

-- Comments
COMMENT ON TABLE child_display_metrics IS
'Child metrics that belong to a parent. Shown when "View Details" is expanded.
Children can be categorized (e.g., Meals, Variety, Alternative Units)';

COMMENT ON COLUMN child_display_metrics.child_category IS
'Category within parent for UI grouping. Examples: "Meals", "Variety", "Plant-Based", "Alternative Units"';

COMMENT ON COLUMN child_display_metrics.inherit_parent_unit IS
'If true, uses parent''s unit toggle. If false, has independent unit preference';

COMMENT ON COLUMN child_display_metrics.show_in_summary IS
'If true, shows in parent metric summary card';

-- =====================================================================================
-- STEP 3: Create triggers for updated_at
-- =====================================================================================

CREATE TRIGGER update_parent_display_metrics_updated_at
  BEFORE UPDATE ON parent_display_metrics
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_child_display_metrics_updated_at
  BEFORE UPDATE ON child_display_metrics
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================================
-- STEP 4: Migrate data from display_metrics
-- =====================================================================================

-- Migrate parent metrics
INSERT INTO parent_display_metrics (
  parent_metric_id,
  parent_name,
  parent_description,
  pillar,
  supported_units,
  default_unit,
  chart_type_id,
  supported_periods,
  default_period,
  chart_config,
  display_format,
  display_transformation,
  display_unit,
  null_handling,
  null_display_value,
  filter_config,
  widget_type,
  display_order,
  is_featured,
  is_active,
  created_at,
  updated_at
)
SELECT
  display_metric_id,
  display_name,
  description,
  pillar,
  supported_units,
  default_unit,
  chart_type_id,
  supported_periods,
  default_period,
  chart_config,
  display_format,
  display_transformation,
  display_unit,
  null_handling,
  null_display_value,
  filter_config,
  widget_type,
  display_order,
  is_featured,
  is_active,
  created_at,
  updated_at
FROM display_metrics
WHERE is_parent = true;

-- Migrate child metrics with categorization
INSERT INTO child_display_metrics (
  child_metric_id,
  parent_metric_id,
  child_name,
  child_description,
  child_category,
  display_order_in_parent,
  supported_units,
  default_unit,
  inherit_parent_unit,
  chart_type_id,
  supported_periods,
  default_period,
  chart_config,
  display_format,
  display_transformation,
  display_unit,
  null_handling,
  null_display_value,
  filter_config,
  widget_type,
  is_active,
  created_at,
  updated_at
)
SELECT
  display_metric_id,
  parent_metric_id,
  display_name,
  description,
  -- Categorize children based on naming patterns
  CASE
    -- Meal categories
    WHEN display_name ILIKE '%breakfast%' THEN 'Meals'
    WHEN display_name ILIKE '%lunch%' THEN 'Meals'
    WHEN display_name ILIKE '%dinner%' THEN 'Meals'
    -- Variety categories
    WHEN display_name ILIKE '%variety%' THEN 'Variety'
    WHEN display_name ILIKE '%source%' THEN 'Variety'
    -- Plant-based category
    WHEN display_name ILIKE '%plant%based%' THEN 'Plant-Based'
    -- Alternative units
    WHEN display_name ILIKE '%g/kg%' OR display_name ILIKE '%per kilogram%' THEN 'Alternative Units'
    WHEN display_name ILIKE '%grams%' AND parent_metric_id IS NOT NULL THEN 'Alternative Units'
    -- Quality/metrics
    WHEN display_name ILIKE '%efficiency%' OR display_name ILIKE '%latency%' THEN 'Quality'
    WHEN display_name ILIKE '%consistency%' THEN 'Quality'
    -- Stages (for sleep)
    WHEN display_name ILIKE '%deep%' OR display_name ILIKE '%rem%' OR display_name ILIKE '%core%' THEN 'Stages'
    WHEN display_name ILIKE '%awake%' THEN 'Stages'
    -- Percentages
    WHEN display_name ILIKE '%percentage%' OR display_name ILIKE '% %' THEN 'Percentages'
    -- Sessions
    WHEN display_name ILIKE '%session%' THEN 'Sessions'
    -- Default
    ELSE 'Other'
  END as child_category,
  display_order,
  supported_units,
  default_unit,
  -- Inherit parent unit if both support same units
  CASE
    WHEN supported_units = (SELECT supported_units FROM display_metrics p WHERE p.display_metric_id = display_metrics.parent_metric_id)
    THEN true
    ELSE false
  END as inherit_parent_unit,
  chart_type_id,
  supported_periods,
  default_period,
  chart_config,
  display_format,
  display_transformation,
  display_unit,
  null_handling,
  null_display_value,
  filter_config,
  widget_type,
  is_active,
  created_at,
  updated_at
FROM display_metrics
WHERE parent_metric_id IS NOT NULL
  AND is_active = true;

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show migrated parent metrics
SELECT
  '🏆 PARENT' as type,
  parent_metric_id,
  parent_name,
  pillar,
  (SELECT COUNT(*) FROM child_display_metrics c WHERE c.parent_metric_id = p.parent_metric_id) as child_count
FROM parent_display_metrics p
ORDER BY pillar, parent_name
LIMIT 20;
