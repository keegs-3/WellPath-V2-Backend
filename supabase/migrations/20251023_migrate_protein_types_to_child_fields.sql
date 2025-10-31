-- =====================================================================================
-- Migrate def_ref_protein_types to Child Fields
-- =====================================================================================
-- Converts 15 protein types from def_ref_protein_types into child data_entry_fields
-- Each type becomes a trackable field (protein_chicken, protein_beef, protein_tofu, etc.)
-- Phase 1 of consolidating def_ref_* tables into data_entry_fields
-- =====================================================================================

-- =====================================================================================
-- STEP 1: Create Child Fields for Each Protein Type (Servings)
-- =====================================================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  event_type_id,
  is_parent,
  parent_field_id,
  sort_order,
  is_active,
  validation_type,
  validation_config
)
SELECT
  'FIELD_PROTEIN_' || UPPER(REPLACE(protein_type_key, '_', '')) || '_SERVINGS' as field_id,
  'protein_' || protein_type_key || '_servings' as field_name,
  display_name || ' (servings)' as display_name,
  'Servings of ' || LOWER(display_name) || ' protein consumed' as description,
  'numeric' as field_type,
  'decimal' as data_type,
  'serving' as unit,
  'EVT_PROTEIN' as event_type_id,
  false as is_parent,
  'DEF_PROTEIN_SERVINGS' as parent_field_id,
  ROW_NUMBER() OVER (ORDER BY display_name) as sort_order,
  is_active,
  'numeric' as validation_type,
  jsonb_build_object(
    'min', 0,
    'max', 20,
    'step', 0.1,
    'category', category,
    'is_lean', is_lean,
    'is_processed', is_processed,
    'is_fish', is_fish,
    'is_red_meat', is_red_meat,
    'typical_serving_size', typical_serving_size,
    'typical_protein_grams', typical_protein_grams
  ) as validation_config
FROM def_ref_protein_types
WHERE is_active = true
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  parent_field_id = EXCLUDED.parent_field_id,
  sort_order = EXCLUDED.sort_order,
  validation_config = EXCLUDED.validation_config;

-- =====================================================================================
-- STEP 2: Create Child Fields for Each Protein Type (Grams)
-- =====================================================================================

INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  unit,
  event_type_id,
  is_parent,
  parent_field_id,
  sort_order,
  is_active,
  validation_type,
  validation_config
)
SELECT
  'FIELD_PROTEIN_' || UPPER(REPLACE(protein_type_key, '_', '')) || '_GRAMS' as field_id,
  'protein_' || protein_type_key || '_grams' as field_name,
  display_name || ' (grams)' as display_name,
  'Grams of ' || LOWER(display_name) || ' protein consumed' as description,
  'numeric' as field_type,
  'decimal' as data_type,
  'gram' as unit,
  'EVT_PROTEIN' as event_type_id,
  false as is_parent,
  'DEF_PROTEIN_GRAMS' as parent_field_id,
  ROW_NUMBER() OVER (ORDER BY display_name) as sort_order,
  is_active,
  'numeric' as validation_type,
  jsonb_build_object(
    'min', 0,
    'max', 200,
    'step', 1,
    'category', category,
    'is_lean', is_lean,
    'is_processed', is_processed,
    'is_fish', is_fish,
    'is_red_meat', is_red_meat,
    'typical_serving_size', typical_serving_size,
    'typical_protein_grams', typical_protein_grams
  ) as validation_config
FROM def_ref_protein_types
WHERE is_active = true
ON CONFLICT (field_id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  parent_field_id = EXCLUDED.parent_field_id,
  sort_order = EXCLUDED.sort_order,
  validation_config = EXCLUDED.validation_config;

-- =====================================================================================
-- STEP 3: Link to Pillars
-- =====================================================================================

UPDATE data_entry_fields
SET pillar_name = 'Nutrition'
WHERE parent_field_id IN ('DEF_PROTEIN_SERVINGS', 'DEF_PROTEIN_GRAMS')
  AND pillar_name IS NULL;

-- =====================================================================================
-- VERIFICATION
-- =====================================================================================

-- Show all protein child fields (servings)
SELECT
  field_id,
  field_name,
  display_name,
  parent_field_id,
  sort_order,
  unit,
  is_active
FROM data_entry_fields
WHERE parent_field_id = 'DEF_PROTEIN_SERVINGS'
ORDER BY sort_order;

-- Count by parent
SELECT
  p.field_id as parent_field_id,
  p.field_name,
  p.display_name as parent_name,
  COUNT(c.field_id) as child_count
FROM data_entry_fields p
LEFT JOIN data_entry_fields c ON c.parent_field_id = p.field_id
WHERE p.is_parent = true
  AND p.field_name LIKE '%protein%'
GROUP BY p.field_id, p.field_name, p.display_name
ORDER BY p.field_name;
