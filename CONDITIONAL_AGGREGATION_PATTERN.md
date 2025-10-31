# Conditional Aggregation Pattern

## Universal Architecture for Nutrition Tracking

Instead of creating separate data entry fields for every variation, we use a **single quantity field + reference field** pattern with conditional filtering.

## The Pattern

### ❌ OLD WAY (Field Explosion)
```
DEF_PROTEIN_BREAKFAST → AGG_PROTEIN_BREAKFAST
DEF_PROTEIN_LUNCH → AGG_PROTEIN_LUNCH
DEF_PROTEIN_DINNER → AGG_PROTEIN_DINNER
DEF_PROTEIN_FATTY_FISH → AGG_PROTEIN_FATTY_FISH
DEF_PROTEIN_LEAN_PROTEIN → AGG_PROTEIN_LEAN_PROTEIN
... (100+ fields for every combination!)
```

### ✅ NEW WAY (Conditional Filtering)
```
DEF_PROTEIN_GRAMS (quantity)
  + DEF_PROTEIN_TIMING (reference → def_ref_protein_timing)
  + DEF_PROTEIN_TYPE (reference → def_ref_protein_types)

→ AGG_PROTEIN_BREAKFAST filters WHERE timing='breakfast'
→ AGG_PROTEIN_LUNCH filters WHERE timing='lunch'
→ AGG_PROTEIN_TYPE_FATTY_FISH filters WHERE type='fatty_fish'
→ AGG_PROTEIN_TYPE_LEAN_PROTEIN filters WHERE type='lean_protein'
```

## Implementation

### 1. Data Entry Fields (3 fields per nutrition item)
```sql
-- Quantity field
DEF_PROTEIN_GRAMS (quantity, numeric, gram)

-- Reference fields
DEF_PROTEIN_TIMING (reference, uuid, def_ref_protein_timing)
DEF_PROTEIN_TYPE (reference, uuid, def_ref_protein_types)
```

### 2. Reference Tables
```sql
CREATE TABLE def_ref_protein_timing (
  id UUID PRIMARY KEY,
  timing_key TEXT UNIQUE,  -- breakfast, lunch, dinner
  display_name TEXT,
  ...
);

CREATE TABLE def_ref_protein_types (
  id UUID PRIMARY KEY,
  protein_type_key TEXT UNIQUE,  -- fatty_fish, lean_protein
  display_name TEXT,
  ...
);
```

### 3. Aggregation Dependencies with Filters
```sql
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  data_entry_field_id,
  dependency_type,
  filter_conditions
) VALUES (
  'AGG_PROTEIN_BREAKFAST_GRAMS',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "breakfast"}'::jsonb
);
```

### 4. Dynamic Filtering Function
The `calculate_field_aggregation()` function automatically:
- Detects the reference table
- Finds the key column dynamically (`timing_key`, `protein_type_key`, etc.)
- JOINs to filter by the reference value

## Mobile App Data Entry

User enters **one entry** with multiple attributes:
```json
{
  "DEF_PROTEIN_GRAMS": 25,
  "DEF_PROTEIN_TIMING": "breakfast",
  "DEF_PROTEIN_TYPE": "lean_protein",
  "entry_timestamp": "2025-10-24T08:00:00Z"
}
```

System creates aggregations:
- `AGG_PROTEIN_GRAMS` → 25g total
- `AGG_PROTEIN_BREAKFAST_GRAMS` → 25g (filtered by timing)
- `AGG_PROTEIN_TYPE_LEAN_PROTEIN` → 25g (filtered by type)

## Applying to Other Nutrition

### Vegetables
```
DEF_VEGETABLE_GRAMS (quantity)
  + DEF_VEGETABLE_TYPE (reference → def_ref_vegetable_types)
  + DEF_FOOD_TIMING (reference → def_ref_food_timing)

→ AGG_VEGETABLE_BROCCOLI filters WHERE type='broccoli'
→ AGG_VEGETABLE_CARROTS filters WHERE type='carrots'
→ AGG_VEGETABLE_LUNCH filters WHERE timing='lunch'
```

### Fiber
```
DEF_FIBER_GRAMS (quantity)
  + DEF_FIBER_SOURCE (reference → def_ref_fiber_sources)
  + DEF_FOOD_TIMING (reference → def_ref_food_timing)

→ AGG_FIBER_SOURCE_BEANS filters WHERE source='beans'
→ AGG_FIBER_SOURCE_WHOLE_GRAINS filters WHERE source='whole_grains'
```

### Water
```
DEF_WATER_QUANTITY (quantity)
  + DEF_WATER_SOURCE (reference → def_ref_water_sources)

→ AGG_WATER_PLAIN filters WHERE source='plain'
→ AGG_WATER_HERBAL_TEA filters WHERE source='herbal_tea'
```

## Benefits

✅ **Scalability**: Add new aggregations without new fields
✅ **Flexibility**: Same pattern works for all nutrition types
✅ **Maintainability**: Single source of truth (e.g., one DEF_PROTEIN_GRAMS)
✅ **User Experience**: Enter data once, get multiple aggregations
✅ **Database Efficiency**: Fewer fields, cleaner schema
✅ **Reusability**: DEF_FOOD_TIMING works for protein, fiber, vegetables, etc.

## Key Files

- **Migrations**:
  - `20251025_implement_conditional_aggregation_filtering.sql`
  - `20251025_enhance_aggregation_with_filtering.sql`

- **Functions**:
  - `calculate_field_aggregation()` - Handles dynamic filtering
  - `process_single_aggregation()` - Passes filter conditions

- **Tables**:
  - `aggregation_metrics_dependencies.filter_conditions` - Stores filter JSON
  - `def_ref_protein_timing` - Meal timing reference
  - `def_ref_protein_types` - Protein source reference
  - `def_ref_food_timing` - Universal food timing (can be used by all nutrition)
