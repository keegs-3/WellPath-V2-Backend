-- =====================================================================================
-- Add Parent Detail Sections for Modal Tabs
-- =====================================================================================
-- Creates parent_detail_sections table for organizing "Show More" modal
-- Updates child_display_metrics to reference sections instead of categories
-- Implements Apple Health style modal with tabbed sections
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Create parent_detail_sections table
-- =====================================================================================

CREATE TABLE parent_detail_sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id text UNIQUE NOT NULL,
  parent_metric_id text NOT NULL REFERENCES parent_display_metrics(parent_metric_id) ON DELETE CASCADE,

  -- Section details
  section_name text NOT NULL,
  section_description text,
  section_icon text,

  -- Display configuration
  display_order integer NOT NULL,
  section_layout text DEFAULT 'vertical_stack' CHECK (section_layout IN ('vertical_stack', 'grid_2col', 'grid_3col', 'comparison', 'timeline')),

  -- UI behavior
  is_default_tab boolean DEFAULT false,
  is_active boolean DEFAULT true,

  -- Timestamps
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_parent_sections_parent ON parent_detail_sections(parent_metric_id);
CREATE INDEX idx_parent_sections_order ON parent_detail_sections(parent_metric_id, display_order);

-- Trigger
CREATE TRIGGER update_parent_detail_sections_updated_at
  BEFORE UPDATE ON parent_detail_sections
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Comments
COMMENT ON TABLE parent_detail_sections IS
'Defines sections/tabs in the "Show More" modal for parent metrics.
Example: Protein parent → Sections: "Timing", "Type", "Variety"
Each section contains related child metrics organized by the section layout.';

COMMENT ON COLUMN parent_detail_sections.section_layout IS
'How children are displayed in this section:
- vertical_stack: Charts stacked vertically (default)
- grid_2col: 2 column grid layout
- grid_3col: 3 column grid layout
- comparison: Side-by-side comparison view
- timeline: Timeline/chronological view';

COMMENT ON COLUMN parent_detail_sections.is_default_tab IS
'If true, this section is shown by default when modal opens';

-- =====================================================================================
-- STEP 2: Update child_display_metrics to reference sections
-- =====================================================================================

-- Add section_id column to children
ALTER TABLE child_display_metrics
ADD COLUMN section_id text REFERENCES parent_detail_sections(section_id) ON DELETE CASCADE;

-- Create index
CREATE INDEX idx_child_metrics_section ON child_display_metrics(section_id);

-- Update comment
COMMENT ON COLUMN child_display_metrics.section_id IS
'References the modal section/tab this child belongs to.
If null, child appears directly under parent (legacy behavior).';

-- Rename child_category to legacy_category for clarity
ALTER TABLE child_display_metrics
RENAME COLUMN child_category TO legacy_category;

COMMENT ON COLUMN child_display_metrics.legacy_category IS
'Legacy auto-categorization (Meals, Variety, etc.).
Use section_id for new modal structure instead.';

-- =====================================================================================
-- STEP 3: Create sections for Protein
-- =====================================================================================

-- Protein Timing section
INSERT INTO parent_detail_sections (
  section_id,
  parent_metric_id,
  section_name,
  section_description,
  section_icon,
  display_order,
  section_layout,
  is_default_tab
) VALUES (
  'SECTION_PROTEIN_TIMING',
  'DISP_PROTEIN_SERVINGS',
  'Timing',
  'Protein intake by meal',
  'clock',
  1,
  'vertical_stack',
  true
);

-- Protein Type section
INSERT INTO parent_detail_sections (
  section_id,
  parent_metric_id,
  section_name,
  section_description,
  section_icon,
  display_order,
  section_layout,
  is_default_tab
) VALUES (
  'SECTION_PROTEIN_TYPE',
  'DISP_PROTEIN_SERVINGS',
  'Type',
  'Plant-based vs animal protein',
  'leaf',
  2,
  'vertical_stack',
  false
);

-- Protein Variety section
INSERT INTO parent_detail_sections (
  section_id,
  parent_metric_id,
  section_name,
  section_description,
  section_icon,
  display_order,
  section_layout,
  is_default_tab
) VALUES (
  'SECTION_PROTEIN_VARIETY',
  'DISP_PROTEIN_SERVINGS',
  'Variety',
  'Distribution of protein sources',
  'chart.pie',
  3,
  'vertical_stack',
  false
);

-- =====================================================================================
-- STEP 4: Link protein children to sections
-- =====================================================================================

-- Timing section: Breakfast, Lunch, Dinner
UPDATE child_display_metrics
SET section_id = 'SECTION_PROTEIN_TIMING'
WHERE parent_metric_id = 'DISP_PROTEIN_SERVINGS'
  AND legacy_category = 'Meals';

-- Type section: Plant-based metrics
UPDATE child_display_metrics
SET section_id = 'SECTION_PROTEIN_TYPE'
WHERE parent_metric_id = 'DISP_PROTEIN_SERVINGS'
  AND legacy_category = 'Plant-Based';

-- Variety section: Variety and source metrics
UPDATE child_display_metrics
SET section_id = 'SECTION_PROTEIN_VARIETY'
WHERE parent_metric_id = 'DISP_PROTEIN_SERVINGS'
  AND legacy_category = 'Variety';

-- Alternative Units: Keep as direct children (no section, shown always)
-- These don't go in modal, they're alternative views of the parent
-- (g/kg stays as a child but not in any section)

-- =====================================================================================
-- STEP 5: Create sections for other key parents
-- =====================================================================================

-- Fiber Timing, Type, Variety
INSERT INTO parent_detail_sections (section_id, parent_metric_id, section_name, section_description, section_icon, display_order, section_layout, is_default_tab)
VALUES
  ('SECTION_FIBER_TIMING', 'DISP_FIBER_SERVINGS', 'Timing', 'Fiber intake by meal', 'clock', 1, 'vertical_stack', true),
  ('SECTION_FIBER_TYPE', 'DISP_FIBER_SERVINGS', 'Sources', 'Fiber source types', 'list.bullet', 2, 'vertical_stack', false),
  ('SECTION_FIBER_VARIETY', 'DISP_FIBER_SERVINGS', 'Variety', 'Variety of fiber sources', 'chart.pie', 3, 'vertical_stack', false);

-- Link fiber children
UPDATE child_display_metrics SET section_id = 'SECTION_FIBER_TIMING'
WHERE parent_metric_id = 'DISP_FIBER_SERVINGS' AND legacy_category = 'Meals';

UPDATE child_display_metrics SET section_id = 'SECTION_FIBER_TYPE'
WHERE parent_metric_id = 'DISP_FIBER_SERVINGS' AND legacy_category = 'Variety';

-- Sleep Stages, Quality
INSERT INTO parent_detail_sections (section_id, parent_metric_id, section_name, section_description, section_icon, display_order, section_layout, is_default_tab)
VALUES
  ('SECTION_SLEEP_STAGES', 'DISP_TOTAL_SLEEP_DURATION', 'Stages', 'Sleep stage breakdown', 'moon.stars', 1, 'vertical_stack', true),
  ('SECTION_SLEEP_QUALITY', 'DISP_TOTAL_SLEEP_DURATION', 'Quality', 'Sleep quality metrics', 'chart.line.uptrend.xyaxis', 2, 'vertical_stack', false);

-- Link sleep children
UPDATE child_display_metrics SET section_id = 'SECTION_SLEEP_STAGES'
WHERE parent_metric_id = 'DISP_TOTAL_SLEEP_DURATION' AND legacy_category IN ('Stages', 'Percentages');

UPDATE child_display_metrics SET section_id = 'SECTION_SLEEP_QUALITY'
WHERE parent_metric_id = 'DISP_TOTAL_SLEEP_DURATION' AND legacy_category = 'Quality';

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show protein structure with sections
SELECT
  '🏆 PARENT' as type,
  pdm.parent_metric_id as id,
  pdm.parent_name as name,
  NULL as section,
  NULL as legacy_cat
FROM parent_display_metrics pdm
WHERE pdm.parent_metric_id = 'DISP_PROTEIN_SERVINGS'

UNION ALL

SELECT
  '  📂 SECTION' as type,
  pds.section_id as id,
  pds.section_name as name,
  NULL as section,
  NULL as legacy_cat
FROM parent_detail_sections pds
WHERE pds.parent_metric_id = 'DISP_PROTEIN_SERVINGS'
ORDER BY pds.display_order

UNION ALL

SELECT
  '    ↳ child' as type,
  cdm.child_metric_id as id,
  cdm.child_name as name,
  pds.section_name as section,
  cdm.legacy_category as legacy_cat
FROM child_display_metrics cdm
LEFT JOIN parent_detail_sections pds ON cdm.section_id = pds.section_id
WHERE cdm.parent_metric_id = 'DISP_PROTEIN_SERVINGS'
ORDER BY pds.display_order NULLS LAST, cdm.display_order_in_parent;
