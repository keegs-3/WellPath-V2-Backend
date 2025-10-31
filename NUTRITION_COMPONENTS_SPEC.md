# Nutrition Components Database Specification

## Overview
Build out database structure for all nutrition components following the protein pattern.

## Components to Build

### 1. **Vegetables** (servings-based)
- **Main Chart**: Total servings
- **Detail View**: Types breakdown
- **Types**:
  - Leafy Greens
  - Cruciferous
  - Root Vegetables
  - Nightshades
  - Alliums
  - Other
  - Uncategorized (for entries without type specified)

### 2. **Legumes** (servings-based)
- **Main Chart**: Total servings
- **Detail View**: Types breakdown
- **Types**:
  - Beans
  - Lentils
  - Chickpeas
  - Peas
  - Soy Products
  - Other
  - Uncategorized (for entries without type specified)

### 3. **Fruits** (servings-based)
- **Main Chart**: Total servings
- **Detail View**: Types breakdown
- **Types**:
  - Berries
  - Citrus
  - Tropical
  - Stone Fruits
  - Apples/Pears
  - Other
  - Uncategorized (for entries without type specified)

### 4. **Whole Grains** (servings-based)
- **Main Chart**: Total servings
- **Detail View**: Types breakdown
- **Types**:
  - Oats
  - Brown Rice
  - Quinoa
  - Whole Wheat
  - Barley
  - Other Ancient Grains
  - Uncategorized (for entries without type specified)

### 5. **Healthy Fats** (servings-based)
- **Main Chart**: Total servings
- **Detail View**: Types breakdown
- **Types**:
  - Avocado
  - Nuts
  - Seeds
  - Olive Oil
  - Fatty Fish
  - Other
  - Uncategorized (for entries without type specified)

### 6. **Fiber** (grams-based)
- **Main Chart**: Total grams
- **Detail View**: Types breakdown
- **Types**:
  - Soluble Fiber
  - Insoluble Fiber
  - Uncategorized (for entries without type specified)

### 7. **Hydration** (simple)
- **Main Chart**: Total fluid ounces or liters
- **No detail view** - simple tracking

### 8. **Added Sugar** (grams-based)
- **Main Chart**: Total grams
- **Detail View**: Sources breakdown
- **Types**:
  - Beverages
  - Desserts
  - Sauces/Condiments
  - Snacks
  - Other
  - Uncategorized (for entries without type specified)

### 9. **Meal Quality** (stacked bar chart)
- **Main Chart**: Meal quality breakdown
- **Types**:
  - Whole Foods
  - Minimally Processed
  - Ultra-Processed

### 10. **Meal Timing** (special visualization)
- **Primary View**: Floating bar (first meal → last meal) with user-adjustable targets
- **Backup View**: Eating window bar chart
- **Data Needed**: First meal time, last meal time, eating window duration

---

## Database Pattern for Each Component

For each component (except hydration and meal timing), create:

### 1. Data Entry Fields

```sql
-- Main quantity field
DEF_[COMPONENT]_[UNIT]  -- e.g., DEF_VEGETABLES_SERVINGS, DEF_FIBER_GRAMS

-- Timing field (shared across all)
DEF_FOOD_TIMING  -- References: breakfast, lunch, dinner, morning_snack, afternoon_snack, evening_snack

-- Type field
DEF_[COMPONENT]_TYPE  -- e.g., DEF_VEGETABLES_TYPE
```

### 2. Reference Tables

```sql
-- In data_entry_fields_reference table
reference_category = '[component]_types'  -- e.g., 'vegetables_types'
reference_key = '[type_key]'              -- e.g., 'leafy_greens'
display_name = '[Type Display]'           -- e.g., 'Leafy Greens'
```

### 3. Aggregation Metrics

```sql
-- Main total
AGG_[COMPONENT]_[UNIT]  -- e.g., AGG_VEGETABLES_SERVINGS

-- Timing breakdowns (6 metrics per component)
AGG_[COMPONENT]_BREAKFAST_[UNIT]
AGG_[COMPONENT]_MORNING_SNACK_[UNIT]
AGG_[COMPONENT]_LUNCH_[UNIT]
AGG_[COMPONENT]_AFTERNOON_SNACK_[UNIT]
AGG_[COMPONENT]_DINNER_[UNIT]
AGG_[COMPONENT]_EVENING_SNACK_[UNIT]

-- Type breakdowns (varies by component)
AGG_[COMPONENT]_TYPE_[TYPE_KEY]  -- e.g., AGG_VEGETABLES_TYPE_LEAFY_GREENS
```

### 4. Display Metrics & Screens

```sql
-- Primary screen (main chart)
SCREEN_[COMPONENT]_PRIMARY

-- Detail screen (types breakdown)
SCREEN_[COMPONENT]_DETAIL
```

---

## Special Cases

### Hydration
- Only needs main quantity field (DEF_HYDRATION_OUNCES or DEF_HYDRATION_LITERS)
- Main aggregation (AGG_HYDRATION_TOTAL)
- Single display screen with simple bar chart
- No timing breakdown, no type breakdown

### Meal Timing
- Needs first_meal_time and last_meal_time timestamp fields
- Calculate eating_window_hours as instance calculation
- Special visualization (floating bar with adjustable targets)
- Backup bar chart for eating window

### Meal Quality
- Needs meal quality category field
- References: whole_foods, minimally_processed, ultra_processed
- Stacked bar chart showing proportions

---

## SQL Migration Template

Each component needs a migration file:

```sql
-- Example: 20251025_create_vegetables_nutrition_component.sql

BEGIN;

-- 1. Create data entry fields
INSERT INTO field_registry (...) VALUES
  ('DEF_VEGETABLES_SERVINGS', ...),
  ('DEF_VEGETABLES_TYPE', ...);

-- 2. Create reference data
INSERT INTO data_entry_fields_reference (...) VALUES
  ('vegetables_types', 'leafy_greens', 'Leafy Greens', ...),
  ('vegetables_types', 'cruciferous', 'Cruciferous', ...),
  ...;

-- 3. Create aggregation metrics
INSERT INTO aggregation_metrics (...) VALUES
  ('AGG_VEGETABLES_SERVINGS', ...),
  ('AGG_VEGETABLES_BREAKFAST_SERVINGS', ...),
  ...;

-- 4. Create aggregation dependencies
INSERT INTO aggregation_metrics_dependencies (...) VALUES
  ('AGG_VEGETABLES_SERVINGS', 'DEF_VEGETABLES_SERVINGS', 'data_field', ...),
  ...;

-- 5. Create aggregation calculation types
INSERT INTO aggregation_metrics_calculation_types (...) VALUES
  ('AGG_VEGETABLES_SERVINGS', 'SUM', ...),
  ('AGG_VEGETABLES_SERVINGS', 'AVG', ...);

-- 6. Create aggregation periods
INSERT INTO aggregation_metrics_periods (...) VALUES
  ('AGG_VEGETABLES_SERVINGS', 'daily'),
  ('AGG_VEGETABLES_SERVINGS', 'weekly'),
  ...;

COMMIT;
```

---

## Testing Requirements

For each component:
1. Generate test data (similar to protein script)
2. Run aggregations
3. Verify cache entries created
4. Verify values are realistic

---

## Agent Task Breakdown

Each agent should:
1. Read this spec
2. Review the protein implementation as reference
3. Create migration SQL file for their component
4. Create test data generation script
5. Apply migration and generate test data
6. Verify aggregations work correctly
7. Document any issues or deviations from spec
