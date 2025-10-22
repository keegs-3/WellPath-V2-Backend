-- =====================================================
-- Add Category and Cross-Pillar Relationships to Data Entry Fields
-- =====================================================
-- Adds category_id FK and related_pillars JSONB to data_entry_fields
-- Enables structured hierarchy and cross-pillar relationship tracking
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Add Columns
-- =====================================================

-- Add category_id column with FK constraint
ALTER TABLE data_entry_fields
ADD COLUMN IF NOT EXISTS category_id TEXT;

-- Add related_pillars JSONB column for cross-pillar relationships
ALTER TABLE data_entry_fields
ADD COLUMN IF NOT EXISTS related_pillars JSONB DEFAULT '[]'::jsonb;


-- =====================================================
-- PART 2: Create Foreign Key Constraint
-- =====================================================

-- Add FK constraint to data_entry_categories
ALTER TABLE data_entry_fields
ADD CONSTRAINT fk_field_category
  FOREIGN KEY (category_id)
  REFERENCES data_entry_categories(category_id)
  ON UPDATE CASCADE ON DELETE SET NULL;


-- =====================================================
-- PART 3: Create Indexes
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_data_entry_fields_category
  ON data_entry_fields(category_id);

CREATE INDEX IF NOT EXISTS idx_data_entry_fields_related_pillars
  ON data_entry_fields USING GIN(related_pillars);


-- =====================================================
-- PART 4: Add Comments
-- =====================================================

COMMENT ON COLUMN data_entry_fields.category_id IS
'Foreign key to data_entry_categories. Defines the primary display category for this field in the UI navigation hierarchy.';

COMMENT ON COLUMN data_entry_fields.related_pillars IS
'JSONB array of pillar names that this field also impacts. Example: ["Movement + Exercise", "Restorative Sleep"] for caffeine tracking. Used for cross-pillar insights and recommendations.';


COMMIT;
