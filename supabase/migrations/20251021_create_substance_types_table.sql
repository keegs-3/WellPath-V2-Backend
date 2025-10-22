-- =====================================================
-- Create Substance Types Reference Table
-- =====================================================
-- Tracks substances from patient survey: alcohol, tobacco,
-- nicotine products, OTC meds, recreational drugs, other
--
-- Each type has a defined unit for consistent tracking
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Substance Types Table
-- =====================================================

CREATE TABLE IF NOT EXISTS def_ref_substance_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  substance_type_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  category TEXT NOT NULL, -- 'alcohol', 'tobacco', 'nicotine', 'otc_medication', 'recreational', 'other'
  description TEXT,
  default_unit TEXT NOT NULL, -- 'drinks', 'cigarettes', 'mg', 'uses', etc.
  unit_descriptor TEXT, -- User-friendly description: "drinks per day", "cigarettes per day", etc.
  typical_frequency TEXT, -- 'daily', 'weekly', 'occasional'
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_substance_types_category ON def_ref_substance_types(category);
CREATE INDEX IF NOT EXISTS idx_substance_types_active ON def_ref_substance_types(is_active);
CREATE INDEX IF NOT EXISTS idx_substance_types_display_order ON def_ref_substance_types(display_order);

-- Add update trigger
CREATE TRIGGER update_substance_types_updated_at
  BEFORE UPDATE ON def_ref_substance_types
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();


-- =====================================================
-- PART 2: Seed Substance Types
-- =====================================================

INSERT INTO def_ref_substance_types (
  substance_type_key,
  display_name,
  category,
  description,
  default_unit,
  unit_descriptor,
  typical_frequency,
  display_order
) VALUES

-- Alcohol
(
  'alcohol',
  'Alcohol',
  'alcohol',
  'Alcoholic beverages (beer, wine, spirits). 1 drink = 12 oz beer, 5 oz wine, or 1.5 oz spirits.',
  'drinks',
  'drinks',
  'weekly',
  1
),

-- Tobacco
(
  'cigarettes',
  'Cigarettes',
  'tobacco',
  'Cigarettes or hand-rolled tobacco',
  'cigarettes',
  'cigarettes per day',
  'daily',
  2
),
(
  'cigars',
  'Cigars',
  'tobacco',
  'Cigars or cigarillos',
  'cigars',
  'cigars per day',
  'daily',
  3
),
(
  'pipe_tobacco',
  'Pipe Tobacco',
  'tobacco',
  'Pipe smoking tobacco',
  'bowls',
  'bowls per day',
  'daily',
  4
),
(
  'chewing_tobacco',
  'Chewing Tobacco/Dip',
  'tobacco',
  'Smokeless tobacco, dip, or snus',
  'uses',
  'uses per day',
  'daily',
  5
),

-- Nicotine Products
(
  'vaping',
  'Vaping/E-cigarettes',
  'nicotine',
  'Electronic cigarettes, vapes, JUULs',
  'puffs',
  'sessions per day',
  'daily',
  6
),
(
  'nicotine_gum',
  'Nicotine Gum',
  'nicotine',
  'Nicotine replacement gum',
  'pieces',
  'pieces per day',
  'daily',
  7
),
(
  'nicotine_patch',
  'Nicotine Patch',
  'nicotine',
  'Transdermal nicotine patches',
  'patches',
  'patches per day',
  'daily',
  8
),
(
  'nicotine_lozenge',
  'Nicotine Lozenge',
  'nicotine',
  'Nicotine replacement lozenges',
  'lozenges',
  'lozenges per day',
  'daily',
  9
),

-- OTC Medications
(
  'otc_pain_reliever',
  'OTC Pain Reliever',
  'otc_medication',
  'Over-the-counter pain medications (ibuprofen, acetaminophen, aspirin, etc.)',
  'doses',
  'doses per day',
  'occasional',
  10
),
(
  'otc_antihistamine',
  'OTC Antihistamine',
  'otc_medication',
  'Allergy medications (diphenhydramine, loratadine, etc.)',
  'doses',
  'doses per day',
  'occasional',
  11
),
(
  'otc_sleep_aid',
  'OTC Sleep Aid',
  'otc_medication',
  'Over-the-counter sleep medications',
  'doses',
  'doses per day',
  'occasional',
  12
),
(
  'otc_other',
  'Other OTC Medication',
  'otc_medication',
  'Other over-the-counter medications',
  'doses',
  'doses per day',
  'occasional',
  13
),

-- Recreational Drugs
(
  'cannabis_smoking',
  'Cannabis (Smoking)',
  'recreational',
  'Marijuana, cannabis flower',
  'uses',
  'uses per day',
  'occasional',
  14
),
(
  'cannabis_edibles',
  'Cannabis (Edibles)',
  'recreational',
  'Marijuana edibles, gummies, etc.',
  'mg',
  'mg THC',
  'occasional',
  15
),
(
  'cannabis_vaping',
  'Cannabis (Vaping)',
  'recreational',
  'Cannabis vaping, THC vapes',
  'uses',
  'uses per day',
  'occasional',
  16
),

-- Other
(
  'other_substance',
  'Other Substance',
  'other',
  'Other substances not listed',
  'uses',
  'uses',
  'occasional',
  17
)

ON CONFLICT (substance_type_key) DO NOTHING;


-- =====================================================
-- PART 3: Update DEF_SUBSTANCE_TYPE Field
-- =====================================================

UPDATE data_entry_fields
SET
  reference_table = 'def_ref_substance_types',
  data_type = 'text',
  description = 'Type of substance used. Each type has a defined unit for consistent tracking.'
WHERE field_id = 'DEF_SUBSTANCE_TYPE';


-- =====================================================
-- PART 4: Add Comments
-- =====================================================

COMMENT ON TABLE def_ref_substance_types IS
'Reference table for substance use tracking. Includes alcohol, tobacco, nicotine products, OTC medications, and recreational drugs. Each type defines a standard unit for consistent tracking across recommendations.';

COMMENT ON COLUMN def_ref_substance_types.default_unit IS
'Standard unit for this substance type. Examples: drinks (alcohol), cigarettes (tobacco), mg (cannabis edibles), doses (OTC meds). Used to ensure consistent data entry and reporting.';

COMMENT ON COLUMN def_ref_substance_types.unit_descriptor IS
'User-friendly description of the unit for display in UI. Examples: "drinks per day", "cigarettes per day", "mg THC".';

COMMENT ON COLUMN def_ref_substance_types.category IS
'High-level category for grouping substances. Values: alcohol, tobacco, nicotine, otc_medication, recreational, other.';


COMMIT;
