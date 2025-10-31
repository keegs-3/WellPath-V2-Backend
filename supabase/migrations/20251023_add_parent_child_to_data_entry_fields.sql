-- =====================================================================================
-- Add Parent-Child Relationship to data_entry_fields
-- =====================================================================================
-- Enables consolidation of def_ref_* tables into data_entry_fields
-- Creates self-referential parent-child hierarchy within fields
--
-- Example: protein_servings (parent) → protein_chicken, protein_beef, etc. (children)
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Add Parent-Child Columns
-- =====================================================================================

ALTER TABLE data_entry_fields
ADD COLUMN IF NOT EXISTS is_parent boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS parent_field_id text,
ADD COLUMN IF NOT EXISTS sort_order integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_deprecated boolean DEFAULT false;

-- Add foreign key constraint for parent_field_id (self-referential)
ALTER TABLE data_entry_fields
ADD CONSTRAINT fk_parent_field
  FOREIGN KEY (parent_field_id)
  REFERENCES data_entry_fields(field_id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

-- Create index for parent-child queries
CREATE INDEX IF NOT EXISTS idx_data_entry_fields_parent ON data_entry_fields(parent_field_id);
CREATE INDEX IF NOT EXISTS idx_data_entry_fields_is_parent ON data_entry_fields(is_parent) WHERE is_parent = true;

-- =====================================================================================
-- STEP 2: Add Comments
-- =====================================================================================

COMMENT ON COLUMN data_entry_fields.is_parent IS
'True if this field has child fields (e.g., protein_servings is parent of protein_chicken, protein_beef).
Parent fields typically represent aggregated/total values, children represent breakdowns/sources.';

COMMENT ON COLUMN data_entry_fields.parent_field_id IS
'References the parent field if this is a child field.
Example: protein_chicken.parent_field_id → protein_servings
Creates hierarchical relationship within data_entry_fields without needing separate def_ref_* tables.';

COMMENT ON COLUMN data_entry_fields.sort_order IS
'Display order for child fields under their parent. Used for consistent ordering in UI.
Example: Protein sources might be ordered alphabetically or by commonality.';

COMMENT ON COLUMN data_entry_fields.is_deprecated IS
'True if this field is being phased out (e.g., old reference-type fields after migrating to child fields).
Deprecated fields remain for backward compatibility but are hidden in UI.';

-- =====================================================================================
-- STEP 3: Mark Existing Parent Fields
-- =====================================================================================

-- Protein: Mark parent
UPDATE data_entry_fields
SET is_parent = true
WHERE field_id IN ('DEF_PROTEIN_SERVINGS', 'DEF_PROTEIN_GRAMS');

-- Fiber: Mark parent
UPDATE data_entry_fields
SET is_parent = true
WHERE field_id IN ('DEF_FIBER_SERVINGS', 'DEF_FIBER_GRAMS');

-- Check if these exist before updating (may need to create if they don't exist)
UPDATE data_entry_fields
SET is_parent = true
WHERE field_name IN (
  'total_protein_servings',
  'total_protein_grams',
  'total_fiber_servings',
  'total_fiber_grams'
);

-- =====================================================================================
-- STEP 4: Mark Reference Fields as Deprecated (will be replaced by child fields)
-- =====================================================================================

-- These reference-type fields will be replaced by direct child fields
UPDATE data_entry_fields
SET is_deprecated = true
WHERE field_type = 'reference'
  AND reference_table LIKE 'def_ref_%';

COMMENT ON COLUMN data_entry_fields.reference_table IS
'[DEPRECATED for new fields] References a def_ref_* table for enum-like values.
New pattern: Create child fields instead of using reference tables.
Example: Instead of protein_type → def_ref_protein_types, create protein_chicken, protein_beef as child fields of protein_servings.
Kept for backward compatibility during migration.';

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show parent fields
SELECT
  field_id,
  field_name,
  display_name,
  is_parent,
  COUNT(c.field_id) as child_count
FROM data_entry_fields p
LEFT JOIN data_entry_fields c ON c.parent_field_id = p.field_id
WHERE p.is_parent = true
GROUP BY p.field_id, p.field_name, p.display_name, p.is_parent
ORDER BY p.field_name;

-- Show reference fields that will be deprecated
SELECT
  field_id,
  field_name,
  display_name,
  reference_table,
  is_deprecated
FROM data_entry_fields
WHERE field_type = 'reference'
  AND reference_table LIKE 'def_ref_%'
ORDER BY reference_table;
