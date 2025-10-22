-- =====================================================
-- Create Fiber Sources Reference Table
-- =====================================================
-- High-level fiber source categories with average grams per serving
-- Used for bidirectional conversion: servings ↔ grams
-- Enables cross-population: fiber tracking ↔ category tracking
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Fiber Sources Table
-- =====================================================

CREATE TABLE IF NOT EXISTS def_ref_fiber_sources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  description TEXT,
  fiber_grams_per_serving NUMERIC NOT NULL,
  typical_serving_size_grams NUMERIC, -- For reference (e.g., 200g vegetables)
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_fiber_sources_active ON def_ref_fiber_sources(is_active);
CREATE INDEX IF NOT EXISTS idx_fiber_sources_display_order ON def_ref_fiber_sources(display_order);

-- Add update trigger
CREATE TRIGGER update_fiber_sources_updated_at
  BEFORE UPDATE ON def_ref_fiber_sources
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();


-- =====================================================
-- PART 2: Seed Fiber Source Categories
-- =====================================================

INSERT INTO def_ref_fiber_sources (
  source_key,
  display_name,
  description,
  fiber_grams_per_serving,
  typical_serving_size_grams,
  display_order
) VALUES
(
  'whole_grains',
  'Whole Grains',
  'Intact or minimally processed grains containing the bran, germ, and endosperm. Examples: oats, brown rice, quinoa, whole wheat bread, barley.',
  5,
  200,
  1
),
(
  'legumes',
  'Legumes',
  'Beans, lentils, and peas (excluding fresh green beans/peas). Examples: black beans, chickpeas, lentils, kidney beans, split peas.',
  12,
  200,
  2
),
(
  'vegetables',
  'Vegetables',
  'Non-starchy and starchy vegetables. Examples: broccoli, carrots, Brussels sprouts, sweet potatoes, artichokes.',
  4,
  200,
  3
),
(
  'fruits',
  'Fruits',
  'Fresh, frozen, or dried whole fruits. Examples: raspberries, pears, apples with skin, avocados, dried figs.',
  4,
  150,
  4
),
(
  'nuts_seeds',
  'Nuts & Seeds',
  'Tree nuts, peanuts, and edible seeds. Examples: almonds, chia seeds, flaxseeds, walnuts, pumpkin seeds.',
  4,
  28,
  5
),
(
  'supplements',
  'Fiber Supplements',
  'Isolated or concentrated fiber products. Examples: psyllium husk, inulin powder, methylcellulose, wheat bran.',
  5,
  15,
  6
)
ON CONFLICT (source_key) DO NOTHING;


-- =====================================================
-- PART 3: Update DEF_FIBER_SOURCE Field
-- =====================================================

-- Link fiber source field to new table
UPDATE data_entry_fields
SET
  reference_table = 'def_ref_fiber_sources',
  data_type = 'text',
  description = 'High-level fiber source category. Used for cross-population with vegetables, fruits, whole grains, etc.'
WHERE field_id = 'DEF_FIBER_SOURCE';


-- =====================================================
-- PART 4: Add Comments
-- =====================================================

COMMENT ON TABLE def_ref_fiber_sources IS
'High-level fiber source categories with average fiber content per serving. Used for bidirectional conversion between servings and grams, and for cross-population between fiber tracking and category-specific tracking (vegetables, fruits, etc.).';

COMMENT ON COLUMN def_ref_fiber_sources.fiber_grams_per_serving IS
'Average fiber content in grams per serving for this category. Used by instance calculations to convert between servings and grams.

Examples:
- vegetables: 4g per serving
- legumes: 12g per serving
- whole_grains: 5g per serving

When user logs "2 servings vegetables", system calculates 2 × 4g = 8g fiber.
When user logs "10g fiber from vegetables", system calculates 10g ÷ 4g = 2.5 servings.';

COMMENT ON COLUMN def_ref_fiber_sources.typical_serving_size_grams IS
'Reference weight in grams for a typical serving (not used in calculations, just for user reference).';


COMMIT;
