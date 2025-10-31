# Added Sugar Nutrition Component - Complete Implementation

## Overview
Complete database structure for tracking added sugar intake following the established protein pattern.

## Migration File
`supabase/migrations/20251025_create_added_sugar_nutrition_component.sql`

---

## Components Created

### 1. Data Entry Fields (2)

| Field ID | Type | Unit | Description |
|----------|------|------|-------------|
| `DEF_ADDED_SUGAR_GRAMS` | quantity | gram | Main quantity field for added sugar |
| `DEF_ADDED_SUGAR_TYPE` | reference | uuid | Reference to sugar source category |

**Shared Field:**
- `DEF_FOOD_TIMING` - Used for meal timing (breakfast, lunch, dinner, snacks)

---

### 2. Reference Data - Sugar Sources (6)

| Reference Key | Display Name | Description |
|---------------|--------------|-------------|
| `beverages` | Beverages | Soda, juice, sweetened coffee/tea, energy drinks |
| `desserts` | Desserts | Candy, cookies, cake, ice cream, pastries |
| `sauces_condiments` | Sauces/Condiments | Ketchup, BBQ sauce, salad dressing, marinades |
| `snacks` | Snacks | Granola bars, protein bars, sweetened yogurt, flavored nuts |
| `other` | Other | Other sources of added sugar |
| `uncategorized` | Uncategorized | Entries without a specified source |

**Reference Category:** `added_sugar_types`

---

### 3. Aggregation Metrics (13 total)

#### Main Total (1)
- `AGG_ADDED_SUGAR_GRAMS` - Total grams of added sugar consumed

#### Timing Breakdown (6)
1. `AGG_ADDED_SUGAR_BREAKFAST_GRAMS` - Breakfast added sugar
2. `AGG_ADDED_SUGAR_MORNING_SNACK_GRAMS` - Morning snack added sugar
3. `AGG_ADDED_SUGAR_LUNCH_GRAMS` - Lunch added sugar
4. `AGG_ADDED_SUGAR_AFTERNOON_SNACK_GRAMS` - Afternoon snack added sugar
5. `AGG_ADDED_SUGAR_DINNER_GRAMS` - Dinner added sugar
6. `AGG_ADDED_SUGAR_EVENING_SNACK_GRAMS` - Evening snack added sugar

#### Source Breakdown (6)
1. `AGG_ADDED_SUGAR_TYPE_BEVERAGES` - Sugar from beverages
2. `AGG_ADDED_SUGAR_TYPE_DESSERTS` - Sugar from desserts
3. `AGG_ADDED_SUGAR_TYPE_SAUCES_CONDIMENTS` - Sugar from sauces/condiments
4. `AGG_ADDED_SUGAR_TYPE_SNACKS` - Sugar from snacks
5. `AGG_ADDED_SUGAR_TYPE_OTHER` - Sugar from other sources
6. `AGG_ADDED_SUGAR_TYPE_UNCATEGORIZED` - Sugar from uncategorized sources

---

### 4. Dependencies & Filters

#### Main Total
- Source: `DEF_ADDED_SUGAR_GRAMS`
- Filter: None (sums all)

#### Timing Dependencies
- Source: `DEF_ADDED_SUGAR_GRAMS`
- Filter: `{"reference_field": "DEF_FOOD_TIMING", "reference_value": "<timing>"}`
- Timing values: breakfast, morning_snack, lunch, afternoon_snack, dinner, evening_snack

#### Source Dependencies
- Source: `DEF_ADDED_SUGAR_GRAMS`
- Filter: `{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "<source>"}`
- Source values: beverages, desserts, sauces_condiments, snacks, other, uncategorized

---

### 5. Calculation Types

All 13 aggregation metrics support:
- **SUM** - For daily totals
- **AVG** - For weekly/monthly averages

---

### 6. Periods

All 13 aggregation metrics support:
- `hourly` - Hourly aggregation
- `daily` - Daily totals
- `weekly` - Weekly summaries
- `monthly` - Monthly summaries
- `6month` - 6-month summaries
- `yearly` - Yearly summaries

---

### 7. Display Metrics (3)

| Metric ID | Type | Description |
|-----------|------|-------------|
| `DISP_ADDED_SUGAR_GRAMS` | bar (primary) | Total added sugar grams |
| `DISP_ADDED_SUGAR_MEAL_TIMING` | bar_stacked | Breakdown by meal timing |
| `DISP_ADDED_SUGAR_SOURCE` | bar_stacked | Breakdown by sugar source |

#### Display Metric Aggregations

**DISP_ADDED_SUGAR_GRAMS:**
- Daily SUM, Weekly AVG, Monthly AVG, Yearly AVG

**DISP_ADDED_SUGAR_MEAL_TIMING:**
- Daily SUM for all 6 timings
- Weekly AVG for all 6 timings

**DISP_ADDED_SUGAR_SOURCE:**
- Daily SUM for all 6 sources
- Weekly AVG for all 6 sources

---

### 8. Display Screens

#### Primary Screen
- **Screen ID:** `SCREEN_ADDED_SUGAR`
- **Name:** Added Sugar
- **Overview:** Track your added sugar intake by grams, timing, and source
- **Pillar:** Healthful Nutrition
- **Icon:** sugar
- **Default Period:** Daily (D)
- **Layout:** detailed

#### Detail Screen
- **Screen ID:** `SCREEN_ADDED_SUGAR_DETAIL`
- **Title:** Added Sugar Tracking
- **Subtitle:** Monitor and reduce added sugar consumption
- **Description:** Track total added sugar intake, meal timing distribution, and sugar sources to make healthier choices and support better health outcomes.

**Sections:**
1. `added_sugar_overview` - Total grams overview
2. `added_sugar_details` - Timing + source breakdown

---

## Database Counts

When migration completes, you should see:
- ✅ 2 Data Entry Fields
- ✅ 6 Reference Values (sugar sources)
- ✅ 13 Aggregation Metrics (1 + 6 + 6)
- ✅ 13 Dependencies (with filter conditions)
- ✅ 26 Calculation Types (SUM + AVG for each metric)
- ✅ 78 Periods (6 periods × 13 metrics)
- ✅ 3 Display Metrics
- ✅ 28 Display Aggregations
- ✅ 1 Primary Screen
- ✅ 1 Detail Screen

---

## Naming Conventions

### Fields
- Pattern: `DEF_ADDED_SUGAR_<DESCRIPTOR>`
- Unit: GRAMS (not servings)
- Examples: DEF_ADDED_SUGAR_GRAMS, DEF_ADDED_SUGAR_TYPE

### Aggregations
- Main: `AGG_ADDED_SUGAR_GRAMS`
- Timing: `AGG_ADDED_SUGAR_<TIMING>_GRAMS`
- Source: `AGG_ADDED_SUGAR_TYPE_<SOURCE>`

### Display Metrics
- Main: `DISP_ADDED_SUGAR_GRAMS`
- Timing: `DISP_ADDED_SUGAR_MEAL_TIMING`
- Source: `DISP_ADDED_SUGAR_SOURCE`

### Screens
- Primary: `SCREEN_ADDED_SUGAR`
- Detail: `SCREEN_ADDED_SUGAR_DETAIL`

---

## Filter Logic

### Timing Aggregations
```json
{
  "reference_field": "DEF_FOOD_TIMING",
  "reference_value": "breakfast|morning_snack|lunch|afternoon_snack|dinner|evening_snack"
}
```

### Source Aggregations
```json
{
  "reference_field": "DEF_ADDED_SUGAR_TYPE",
  "reference_value": "beverages|desserts|sauces_condiments|snacks|other|uncategorized"
}
```

---

## Next Steps

1. **Apply Migration**
   ```bash
   supabase db reset
   # or
   supabase migration up
   ```

2. **Generate Test Data**
   - Create script: `scripts/generate_added_sugar_test_data.py`
   - Generate entries with various timings and sources
   - Include "uncategorized" entries for testing

3. **Run Aggregations**
   ```bash
   python scripts/process_aggregations.py
   ```

4. **Verify Data**
   - Check aggregation_cache for all 13 metrics
   - Verify filter conditions work correctly
   - Confirm display metrics show data

5. **Test Mobile UI**
   - Test data entry with source selection
   - Verify timing filtering works
   - Check stacked bar charts render correctly
   - Confirm "uncategorized" option appears

---

## Key Features

✅ **Grams-based tracking** (not servings)
✅ **6 sugar sources** with Uncategorized fallback
✅ **Full timing breakdown** (6 meal timings)
✅ **Filter-based dependencies** for conditional aggregation
✅ **Stacked bar visualizations** for breakdown views
✅ **Complete period support** (hourly to yearly)
✅ **SUM and AVG calculations** for all metrics
✅ **Primary and detail screens** with sections

---

## Architecture Alignment

This component follows the exact pattern established by:
- ✅ Protein (grams-based with types and timing)
- ✅ Fruits (servings-based reference implementation)
- ✅ Vegetables, Legumes, etc. (servings-based)

**Consistency Points:**
- Same timing field (DEF_FOOD_TIMING)
- Same filter structure (reference_field + reference_value)
- Same period/calculation setup
- Same display metric patterns
- Same screen architecture

---

## File Location
`/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251025_create_added_sugar_nutrition_component.sql`

**Total Lines:** 859
**Sections:** 10 (Fields → Reference Data → Aggregations → Dependencies → Calc Types → Periods → Display Metrics → Aggregation Mappings → Screens → Summary)

---

**Status:** ✅ Complete and ready for deployment
**Created:** 2025-10-25
**Pattern:** Protein-based (grams + types + timing)
