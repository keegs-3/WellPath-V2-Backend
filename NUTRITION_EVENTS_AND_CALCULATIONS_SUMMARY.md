# Nutrition Events & Instance Calculations Summary

## Overview
Implemented cross-population architecture for nutrition tracking where one user entry can auto-populate related nutrition categories.

Created: 2025-10-21

---

## Architecture Flow

### User Entry Flow
1. User navigates: Nutrition → Fiber → '+'
2. User enters data:
   - **Time** (when consumed)
   - **Type** (vegetables, fruits, whole grains, etc.)
   - **Unit** (servings or grams)
   - **Quantity** (e.g., 2)

### Backend Processing
3. Creates event in `patient_data_entries`:
   - `event_type_id` = 'fiber_intake'
   - User entries marked with `source='manual'`
   - Example entries:
     - `DEF_FIBER_SOURCE` → `value_reference='vegetables'`
     - `DEF_FIBER_SERVINGS` → `value_quantity=2`

4. **Instance Calculations Trigger:**
   - Looks up vegetables in `def_ref_fiber_sources` → 4g per serving
   - Calculates: 2 servings × 4g = 8g
   - Creates auto-calculated entry:
     - `DEF_FIBER_GRAMS` → `value_quantity=8`, `source='auto_calculated'`

### Cross-Population Example

**User enters:** Vegetables → Broccoli → 2 servings

**System stores (manual):**
- `DEF_VEGETABLE_TYPE` = 'broccoli'
- `DEF_VEGETABLE_QUANTITY` = 2

**Instance calculations run:**
- `CALC_VEGETABLE_TYPE_TO_NUTRITION` looks up broccoli in `def_ref_food_types`
- Finds: fiber=4g, protein=2.5g per serving

**Auto-populates (auto_calculated):**
- `DEF_FIBER_SOURCE` = 'vegetables'
- `DEF_FIBER_SERVINGS` = 2
- `DEF_FIBER_GRAMS` = 8 (2 × 4g)
- `DEF_PROTEIN_GRAMS` = 5 (2 × 2.5g)

**Result:**
- User sees "2 servings broccoli" in Vegetables tracking
- Charts auto-show "8g fiber" in Fiber tracking
- Charts auto-show "5g protein" in Protein tracking
- All recommendations update across categories

---

## Event Types Created

| Event Type ID | Name | Fields Count | Purpose |
|--------------|------|--------------|---------|
| `fiber_intake` | Fiber Intake | 4 | Direct fiber tracking with grams ↔ servings conversion |
| `vegetable_intake` | Vegetable Intake | 3 | Vegetable servings, auto-populates fiber + protein |
| `fruit_intake` | Fruit Intake | 2 | Fruit servings, auto-populates fiber |
| `whole_grain_intake` | Whole Grain Intake | 2 | Whole grain servings, auto-populates fiber + protein |
| `legume_intake` | Legume Intake | 2 | Legume servings, auto-populates fiber + protein |
| `nut_seed_intake` | Nut & Seed Intake | 2 | Nut/seed servings, auto-populates fiber + protein + fat |
| `protein_intake` | Protein Intake | 4 | Direct protein tracking with grams ↔ servings conversion |
| `fat_intake` | Healthy Fat Intake | 4 | Direct fat tracking with grams ↔ servings conversion |

---

## Instance Calculations Created

### Pattern 1: Unit Conversions (Grams ↔ Servings)

| Calc ID | Display Name | Triggers When | Output |
|---------|-------------|---------------|--------|
| `CALC_FIBER_SERVINGS_TO_GRAMS` | Fiber Servings → Grams | User enters servings | DEF_FIBER_GRAMS |
| `CALC_FIBER_GRAMS_TO_SERVINGS` | Fiber Grams → Servings | User enters grams | DEF_FIBER_SERVINGS |
| `CALC_PROTEIN_SERVINGS_TO_GRAMS` | Protein Servings → Grams | User enters servings | DEF_PROTEIN_GRAMS |
| `CALC_PROTEIN_GRAMS_TO_SERVINGS` | Protein Grams → Servings | User enters grams | DEF_PROTEIN_SERVINGS |
| `CALC_FAT_SERVINGS_TO_GRAMS` | Fat Servings → Grams | User enters servings | DEF_FAT_GRAMS |
| `CALC_FAT_GRAMS_TO_SERVINGS` | Fat Grams → Servings | User enters grams | DEF_FAT_SERVINGS |

### Pattern 2: Category → Fiber Auto-Population

| Calc ID | Display Name | Triggers When | Output |
|---------|-------------|---------------|--------|
| `CALC_VEGETABLES_TO_FIBER` | Vegetables → Fiber | User logs vegetable servings | Fiber entries (source=vegetables, 4g/serving) |
| `CALC_FRUITS_TO_FIBER` | Fruits → Fiber | User logs fruit servings | Fiber entries (source=fruits, 4g/serving) |
| `CALC_WHOLE_GRAINS_TO_FIBER` | Whole Grains → Fiber | User logs whole grain servings | Fiber entries (source=whole_grains, 5g/serving) |
| `CALC_LEGUMES_TO_FIBER_PROTEIN` | Legumes → Fiber/Protein | User logs legume servings | Fiber entries (12g) + Protein entries (14.5g) |
| `CALC_NUTS_SEEDS_TO_NUTRITION` | Nuts/Seeds → Fiber/Protein/Fat | User logs nut/seed servings | Fiber (4g) + Protein (6g) + Fat (14g) |

### Pattern 3: Specific Food → Nutrition

| Calc ID | Display Name | Triggers When | Output |
|---------|-------------|---------------|--------|
| `CALC_VEGETABLE_TYPE_TO_NUTRITION` | Vegetable Type → Nutrition | User selects specific vegetable | Exact fiber + protein + fat from food_types table |
| `CALC_FRUIT_TYPE_TO_NUTRITION` | Fruit Type → Nutrition | User selects specific fruit | Exact fiber + protein + fat from food_types table |
| `CALC_WHOLE_GRAIN_TYPE_TO_NUTRITION` | Whole Grain Type → Nutrition | User selects specific grain | Exact fiber + protein + fat from food_types table |
| `CALC_LEGUME_TYPE_TO_NUTRITION` | Legume Type → Nutrition | User selects specific legume | Exact fiber + protein + fat from food_types table |
| `CALC_NUT_SEED_TYPE_TO_NUTRITION` | Nut/Seed Type → Nutrition | User selects specific nut/seed | Exact fiber + protein + fat from food_types table |

---

## Calculation Dependencies

Total: **27 dependencies** linking calculations to fields

### Example Dependencies:

**CALC_FIBER_SERVINGS_TO_GRAMS** depends on:
1. `DEF_FIBER_SOURCE` (lookup key to find grams/serving)
2. `DEF_FIBER_SERVINGS` (quantity to multiply)

**CALC_VEGETABLE_TYPE_TO_NUTRITION** depends on:
1. `DEF_VEGETABLE_TYPE` (lookup key for specific food)
2. `DEF_VEGETABLE_QUANTITY` (servings to multiply nutrition values)

---

## Conversion Lookups

### Fiber Sources (def_ref_fiber_sources)
| Source | Grams per Serving |
|--------|------------------|
| vegetables | 4g |
| fruits | 4g |
| whole_grains | 5g |
| legumes | 12g |
| nuts_seeds | 4g |
| supplements | 5g |

### Food Types (def_ref_food_types)
Specific foods with exact nutrition per serving:
- **Broccoli**: 4g fiber, 2.5g protein, 0g fat
- **Chickpeas**: 12.5g fiber, 14.5g protein, 1g fat
- **Almonds**: 3.5g fiber, 6g protein, 14g fat
- *(Many more in database)*

---

## Implementation Status

✅ **Event Types**: 8 nutrition events created
✅ **Fields Linked**: All nutrition fields assigned to events
✅ **Instance Calculations**: 16 calculations created
✅ **Dependencies**: 27 dependencies linking calculations to fields
✅ **Cross-Population**: Full architecture implemented

---

## Next Steps

### Application Layer Implementation
1. **Event Creation Logic**: When user submits nutrition data, create event with all related fields
2. **Calculation Trigger System**: Run instance calculations based on dependencies after data entry
3. **Auto-Population**: Create additional `patient_data_entries` rows with `source='auto_calculated'`
4. **UI Display**: Show both manual and auto-calculated data in charts/tracking views

### Example Application Flow
```python
# User enters: Vegetables → Broccoli → 2 servings

# 1. Create manual entries
create_data_entry(user_id, 'DEF_VEGETABLE_TYPE', value_reference='broccoli', source='manual')
create_data_entry(user_id, 'DEF_VEGETABLE_QUANTITY', value_quantity=2, source='manual')

# 2. Trigger calculations
run_instance_calculations(user_id, event_type='vegetable_intake', timestamp)

# 3. System looks up dependencies for CALC_VEGETABLE_TYPE_TO_NUTRITION
# - DEF_VEGETABLE_TYPE = 'broccoli' → lookup in def_ref_food_types
# - DEF_VEGETABLE_QUANTITY = 2 → multiply nutrition values

# 4. System creates auto-calculated entries
create_data_entry(user_id, 'DEF_FIBER_GRAMS', value_quantity=8, source='auto_calculated')
create_data_entry(user_id, 'DEF_PROTEIN_GRAMS', value_quantity=5, source='auto_calculated')
```

---

## Files Created

1. `20251021_create_nutrition_event_types.sql` - Event type definitions
2. `20251021_link_nutrition_fields_to_events.sql` - Field → event linkages
3. `20251021_create_nutrition_instance_calculations.sql` - Calculation definitions
4. `20251021_create_nutrition_calculation_dependencies.sql` - Calculation dependencies
