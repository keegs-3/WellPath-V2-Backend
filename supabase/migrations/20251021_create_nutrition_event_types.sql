-- =====================================================
-- Create Nutrition Event Types
-- =====================================================
-- Defines event types for nutrition tracking that support
-- cross-population architecture (one entry can auto-populate related fields)
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Nutrition Event Types
-- =====================================================

INSERT INTO event_types (
  event_type_id,
  name,
  description,
  category,
  is_active,
  requires_parent,
  supports_manual_entry,
  supports_api_ingestion,
  metadata
) VALUES
(
  'fiber_intake',
  'Fiber Intake',
  'Direct fiber tracking by source (vegetables, fruits, whole grains, etc.). Supports both grams and servings entry.',
  'nutrition',
  true,
  false,
  true,
  true,
  '{"supports_unit_conversion": true, "cross_populates": ["vegetable_intake", "fruit_intake", "whole_grain_intake", "legume_intake", "nut_seed_intake"]}'::jsonb
),
(
  'vegetable_intake',
  'Vegetable Intake',
  'Vegetable servings tracking. Auto-populates fiber and protein based on vegetable type.',
  'nutrition',
  true,
  false,
  true,
  true,
  '{"supports_unit_conversion": false, "cross_populates": ["fiber_intake", "protein_intake"]}'::jsonb
),
(
  'fruit_intake',
  'Fruit Intake',
  'Fruit servings tracking. Auto-populates fiber based on fruit type.',
  'nutrition',
  true,
  false,
  true,
  true,
  '{"supports_unit_conversion": false, "cross_populates": ["fiber_intake"]}'::jsonb
),
(
  'whole_grain_intake',
  'Whole Grain Intake',
  'Whole grain servings tracking. Auto-populates fiber and protein based on grain type.',
  'nutrition',
  true,
  false,
  true,
  true,
  '{"supports_unit_conversion": false, "cross_populates": ["fiber_intake", "protein_intake"]}'::jsonb
),
(
  'legume_intake',
  'Legume Intake',
  'Legume (beans, lentils, peas) servings tracking. Auto-populates fiber and protein.',
  'nutrition',
  true,
  false,
  true,
  true,
  '{"supports_unit_conversion": false, "cross_populates": ["fiber_intake", "protein_intake"]}'::jsonb
),
(
  'nut_seed_intake',
  'Nut & Seed Intake',
  'Nut and seed servings tracking. Auto-populates fiber, protein, and healthy fats.',
  'nutrition',
  true,
  false,
  true,
  true,
  '{"supports_unit_conversion": false, "cross_populates": ["fiber_intake", "protein_intake", "fat_intake"]}'::jsonb
),
(
  'protein_intake',
  'Protein Intake',
  'Direct protein tracking by source. Supports both grams and servings entry.',
  'nutrition',
  true,
  false,
  true,
  true,
  '{"supports_unit_conversion": true, "cross_populates": []}'::jsonb
),
(
  'fat_intake',
  'Healthy Fat Intake',
  'Healthy fat tracking by source. Supports both grams and servings entry.',
  'nutrition',
  true,
  false,
  true,
  true,
  '{"supports_unit_conversion": true, "cross_populates": []}'::jsonb
)
ON CONFLICT (event_type_id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  metadata = EXCLUDED.metadata,
  updated_at = now();


-- =====================================================
-- PART 2: Add Comments
-- =====================================================

COMMENT ON COLUMN event_types.metadata IS
'JSONB metadata for event configuration. Common fields:
- supports_unit_conversion: true/false - whether event allows grams ↔ servings conversion
- cross_populates: array of event_type_ids that get auto-populated when this event is entered

Example:
{
  "supports_unit_conversion": true,
  "cross_populates": ["fiber_intake", "protein_intake"]
}';


COMMIT;
