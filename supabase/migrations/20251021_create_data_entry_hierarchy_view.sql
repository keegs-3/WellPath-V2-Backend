-- =====================================================
-- Create Data Entry Hierarchy Helper Views
-- =====================================================
-- Views for querying the full Pillar → Category → Field hierarchy
-- Useful for UI navigation, field discovery, and data validation
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Main Hierarchy View
-- =====================================================

CREATE OR REPLACE VIEW data_entry_hierarchy AS
SELECT
  -- Pillar info
  p.pillar_id,
  p.pillar_name,
  p.display_order as pillar_order,
  p.description as pillar_description,
  p.color as pillar_color,
  p.icon as pillar_icon,

  -- Category info
  c.category_id,
  c.category_name,
  c.display_order as category_order,
  c.description as category_description,

  -- Field info
  f.field_id,
  f.field_name,
  f.display_name,
  f.description as field_description,
  f.field_type,
  f.data_type,
  f.unit,
  f.reference_table,
  f.healthkit_identifier,
  f.supports_healthkit_sync,
  f.event_type_id,

  -- Cross-pillar relationships
  f.related_pillars,

  -- Active status
  p.is_active as pillar_active,
  c.is_active as category_active,
  f.is_active as field_active

FROM pillars_base p
JOIN data_entry_categories c
  ON c.pillar_name = p.pillar_name
LEFT JOIN data_entry_fields f
  ON f.category_id = c.category_id

WHERE p.is_active = true
  AND c.is_active = true

ORDER BY
  p.display_order,
  c.display_order,
  f.display_name;


-- =====================================================
-- PART 2: Create Category Summary View
-- =====================================================

CREATE OR REPLACE VIEW category_field_summary AS
SELECT
  p.pillar_name,
  p.display_order as pillar_order,
  c.category_id,
  c.category_name,
  c.display_order as category_order,
  COUNT(f.field_id) as total_fields,
  COUNT(f.field_id) FILTER (WHERE f.is_active = true) as active_fields,
  COUNT(f.field_id) FILTER (WHERE f.supports_healthkit_sync = true) as healthkit_fields,
  ARRAY_AGG(f.field_id ORDER BY f.display_name) FILTER (WHERE f.is_active = true) as field_ids

FROM pillars_base p
JOIN data_entry_categories c
  ON c.pillar_name = p.pillar_name
LEFT JOIN data_entry_fields f
  ON f.category_id = c.category_id

WHERE p.is_active = true
  AND c.is_active = true

GROUP BY
  p.pillar_name,
  p.display_order,
  c.category_id,
  c.category_name,
  c.display_order

ORDER BY
  p.display_order,
  c.display_order;


-- =====================================================
-- PART 3: Create Cross-Pillar Impact View
-- =====================================================

CREATE OR REPLACE VIEW cross_pillar_relationships AS
SELECT
  f.field_id,
  f.display_name,
  p.pillar_name as primary_pillar,
  c.category_name as primary_category,
  f.related_pillars,
  JSONB_ARRAY_LENGTH(COALESCE(f.related_pillars, '[]'::jsonb)) as related_pillar_count

FROM data_entry_fields f
JOIN data_entry_categories c
  ON c.category_id = f.category_id
JOIN pillars_base p
  ON p.pillar_name = c.pillar_name

WHERE f.is_active = true
  AND JSONB_ARRAY_LENGTH(COALESCE(f.related_pillars, '[]'::jsonb)) > 0

ORDER BY
  related_pillar_count DESC,
  f.display_name;


-- =====================================================
-- PART 4: Create Helper Function
-- =====================================================

-- Function to get all fields in a category
CREATE OR REPLACE FUNCTION get_fields_by_category(cat_id TEXT)
RETURNS TABLE(
  field_id TEXT,
  display_name TEXT,
  field_type TEXT,
  data_type TEXT,
  healthkit_sync BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    f.field_id,
    f.display_name,
    f.field_type,
    f.data_type,
    f.supports_healthkit_sync
  FROM data_entry_fields f
  WHERE f.category_id = cat_id
    AND f.is_active = true
  ORDER BY f.display_name;
END;
$$ LANGUAGE plpgsql STABLE;


-- Function to get all categories in a pillar
CREATE OR REPLACE FUNCTION get_categories_by_pillar(p_name TEXT)
RETURNS TABLE(
  category_id TEXT,
  category_name TEXT,
  field_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.category_id,
    c.category_name,
    COUNT(f.field_id) as field_count
  FROM data_entry_categories c
  LEFT JOIN data_entry_fields f
    ON f.category_id = c.category_id
    AND f.is_active = true
  WHERE c.pillar_name = p_name
    AND c.is_active = true
  GROUP BY c.category_id, c.category_name, c.display_order
  ORDER BY c.display_order;
END;
$$ LANGUAGE plpgsql STABLE;


-- =====================================================
-- PART 5: Add Comments
-- =====================================================

COMMENT ON VIEW data_entry_hierarchy IS
'Complete hierarchy view showing Pillars → Categories → Fields with all metadata. Use for UI navigation, field discovery, and understanding the data structure.

Example usage:
SELECT * FROM data_entry_hierarchy WHERE pillar_name = ''Healthful Nutrition'';
';

COMMENT ON VIEW category_field_summary IS
'Summary of field counts by category. Useful for understanding category size and HealthKit coverage.

Example usage:
SELECT pillar_name, category_name, active_fields, healthkit_fields
FROM category_field_summary
ORDER BY active_fields DESC;
';

COMMENT ON VIEW cross_pillar_relationships IS
'Shows fields that impact multiple pillars through related_pillars. Useful for understanding cross-pillar dependencies and recommendation logic.

Example usage:
SELECT * FROM cross_pillar_relationships WHERE primary_pillar = ''Healthful Nutrition'';
';

COMMENT ON FUNCTION get_fields_by_category IS
'Returns all active fields in a given category. Useful for dynamic form generation.

Example usage:
SELECT * FROM get_fields_by_category(''nutrition_meals'');
';

COMMENT ON FUNCTION get_categories_by_pillar IS
'Returns all categories in a given pillar with field counts. Useful for navigation UI.

Example usage:
SELECT * FROM get_categories_by_pillar(''Movement + Exercise'');
';


COMMIT;
