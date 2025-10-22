-- =====================================================
-- Cross-Population Strategy Documentation
-- =====================================================
-- Defines how nutrition tracking auto-populates across categories
-- Instance calculations to be implemented in application layer
--
-- Created: 2025-10-21
-- =====================================================

/*

CROSS-POPULATION ARCHITECTURE
==============================

User enters data via ONE category → System auto-populates related categories


FIBER TRACKING FLOWS
====================

Flow 1: User logs Fiber directly
---------------------------------
Entry: Fiber > Vegetables > 2 servings
Stores:
  - DEF_FIBER_SOURCE = 'vegetables'
  - DEF_FIBER_SERVINGS = 2 (user entered)
  - DEF_FIBER_GRAMS = 8 (calculated: 2 × 4g)

Auto-populates:
  - DEF_VEGETABLE_SERVINGS = 2


Flow 2: User logs Vegetables
-----------------------------
Entry: Vegetables > Broccoli > 2 servings
Stores:
  - DEF_VEGETABLE_TYPE = 'broccoli'
  - DEF_VEGETABLE_SERVINGS = 2 (user entered)

Auto-populates:
  - DEF_FIBER_SOURCE = 'vegetables'
  - DEF_FIBER_SERVINGS = 2
  - DEF_FIBER_GRAMS = 8 (2 × 4g from def_ref_fiber_sources)
  - DEF_PROTEIN_GRAMS = 5 (2 × 2.5g from def_ref_food_types.protein_grams_per_serving)


CONVERSION LOOKUPS
==================

Fiber: Uses def_ref_fiber_sources for category averages
----------------------------------------
vegetables → 4g fiber per serving
fruits → 4g fiber per serving
whole_grains → 5g fiber per serving
legumes → 12g fiber per serving
nuts_seeds → 4g fiber per serving
supplements → 5g fiber per serving


Detailed Foods: Uses def_ref_food_types for specific values
------------------------------------------------------------
broccoli → 4g fiber, 2.5g protein, 0g fat per serving
chickpeas → 12.5g fiber, 14.5g protein, 1g fat per serving
almonds → 3.5g fiber, 6g protein, 14g fat per serving


INSTANCE CALCULATION PATTERNS
==============================

Pattern 1: Grams ↔ Servings Conversion
---------------------------------------
Calculation: CALC_FIBER_GRAMS_TO_SERVINGS
Depends on: DEF_FIBER_SOURCE, DEF_FIBER_GRAMS
Formula: grams ÷ def_ref_fiber_sources.fiber_grams_per_serving
Populates: DEF_FIBER_SERVINGS

Calculation: CALC_FIBER_SERVINGS_TO_GRAMS
Depends on: DEF_FIBER_SOURCE, DEF_FIBER_SERVINGS
Formula: servings × def_ref_fiber_sources.fiber_grams_per_serving
Populates: DEF_FIBER_GRAMS


Pattern 2: Category → Fiber Auto-Population
--------------------------------------------
Calculation: CALC_VEGETABLES_TO_FIBER
Depends on: DEF_VEGETABLE_SERVINGS
Lookup: def_ref_fiber_sources WHERE source_key = 'vegetables'
Populates:
  - DEF_FIBER_SOURCE = 'vegetables'
  - DEF_FIBER_SERVINGS = DEF_VEGETABLE_SERVINGS
  - DEF_FIBER_GRAMS = servings × 4g


Pattern 3: Detailed Food → Nutrition Auto-Population
-----------------------------------------------------
Calculation: CALC_VEGETABLE_TYPE_TO_NUTRITION
Depends on: DEF_VEGETABLE_TYPE, DEF_VEGETABLE_SERVINGS
Lookup: def_ref_food_types WHERE food_name = [type]
Populates:
  - DEF_FIBER_GRAMS = servings × fiber_grams_per_serving
  - DEF_PROTEIN_GRAMS = servings × protein_grams_per_serving
  - DEF_FAT_GRAMS = servings × fat_grams_per_serving


IMPLEMENTATION NOTES
====================

1. Instance calculations run AFTER user entry
2. Exactly ONE of GRAMS or SERVINGS is user-entered, other is calculated
3. Auto-populated entries marked with source metadata
4. Cross-population creates separate data entries linked by timestamp
5. UI can toggle between grams/servings view (both stored)


CALCULATION TRIGGERS
====================

When user enters:              Run calculation:
-----------------------------------------------------------------
DEF_FIBER_GRAMS               → CALC_FIBER_GRAMS_TO_SERVINGS
DEF_FIBER_SERVINGS            → CALC_FIBER_SERVINGS_TO_GRAMS
DEF_VEGETABLE_SERVINGS        → CALC_VEGETABLES_TO_FIBER
                              → CALC_VEGETABLE_TYPE_TO_NUTRITION
DEF_FRUIT_SERVINGS            → CALC_FRUITS_TO_FIBER
DEF_WHOLE_GRAIN_SERVINGS      → CALC_WHOLE_GRAINS_TO_FIBER
DEF_LEGUME_SERVINGS           → CALC_LEGUMES_TO_FIBER_PROTEIN
DEF_NUT_SEED_SERVINGS         → CALC_NUTS_SEEDS_TO_NUTRITION
DEF_PROTEIN_GRAMS             → CALC_PROTEIN_GRAMS_TO_SERVINGS
DEF_PROTEIN_SERVINGS          → CALC_PROTEIN_SERVINGS_TO_GRAMS
DEF_FAT_GRAMS                 → CALC_FAT_GRAMS_TO_SERVINGS
DEF_FAT_SERVINGS              → CALC_FAT_SERVINGS_TO_GRAMS


EXAMPLE DATA FLOW
=================

User Action:
  Nutrition > Healthy Additions > Vegetables > Broccoli > 2 servings

System Stores (patient_data_entries):
  1. user_id, DEF_VEGETABLE_TYPE, value_reference='broccoli', timestamp
  2. user_id, DEF_VEGETABLE_SERVINGS, value_quantity=2, timestamp

Instance Calculations Run:
  CALC_VEGETABLE_TYPE_TO_NUTRITION looks up broccoli in def_ref_food_types
  Finds: fiber=4g, protein=2.5g, fat=0g per serving

Auto-Populates (patient_data_entries):
  3. user_id, DEF_FIBER_SOURCE, value_reference='vegetables', timestamp, source='auto_calculated'
  4. user_id, DEF_FIBER_SERVINGS, value_quantity=2, timestamp, source='auto_calculated'
  5. user_id, DEF_FIBER_GRAMS, value_quantity=8, timestamp, source='auto_calculated'
  6. user_id, DEF_PROTEIN_GRAMS, value_quantity=5, timestamp, source='auto_calculated'

Result:
  - User sees: "2 servings broccoli" in Vegetables tracking
  - Auto-shows: "8g fiber" in Fiber tracking
  - Auto-shows: "5g protein" in Protein tracking
  - Charts and recommendations update across all categories

*/

-- This is a documentation-only migration
-- No schema changes needed
SELECT 1;
