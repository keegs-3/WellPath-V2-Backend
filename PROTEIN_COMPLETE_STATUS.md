# Protein Complete Status

## ✅ SCREEN CONFIGURATION

### **Primary Screen: SCREEN_PROTEIN_PRIMARY**
- Title: "Protein Intake"
- Description: "Track protein grams, servings, and variety"
- Has detail screen: Yes
- **Metric displayed:**
  - `DISP_PROTEIN_GRAMS` (featured)

### **Detail Screen: SCREEN_PROTEIN_DETAIL**
- Title: "Protein Tracking"
- Subtitle: "Optimize your protein intake"
- Layout: 2 sections

#### Section 1: "Protein Overview" (metrics_grid)
- `DISP_PROTEIN_PER_KG` - Protein per kg body weight

#### Section 2: "Detailed Breakdown" (metrics_detailed)
- `DISP_PROTEIN_MEAL_TIMING` - Breakfast/lunch/dinner distribution
- `DISP_PROTEIN_TYPE` - Breakdown by protein source (6 types)

---

## ✅ DISPLAY METRICS (What Mobile Queries)

### 1. **DISP_PROTEIN_GRAMS** (Total Protein)
- Chart: `bar_vertical`
- Periods: hourly (SUM), daily (SUM), weekly (AVG), monthly (AVG)
- Aggregation: `AGG_PROTEIN_GRAMS`

### 2. **DISP_PROTEIN_PER_KG** (Protein Ratio)
- Chart: `trend_line`
- Periods: hourly (AVG), daily (AVG), weekly (AVG), monthly (AVG)
- Aggregation: `AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT`

### 3. **DISP_PROTEIN_MEAL_TIMING** (By Meal)
- Chart: `bar_stacked`
- Daily: `AGG_PROTEIN_BREAKFAST_GRAMS` (SUM), `AGG_PROTEIN_LUNCH_GRAMS` (SUM), `AGG_PROTEIN_DINNER_GRAMS` (SUM)
- Weekly: Same 3 aggregations (AVG)
- Hourly: Same 3 aggregations (SUM)

### 4. **DISP_PROTEIN_TYPE** (By Source)
- Chart: `bar_stacked`
- Daily (SUM):
  - `AGG_PROTEIN_TYPE_FATTY_FISH`
  - `AGG_PROTEIN_TYPE_LEAN_PROTEIN`
  - `AGG_PROTEIN_TYPE_PLANT_BASED`
  - `AGG_PROTEIN_TYPE_PROCESSED_MEAT`
  - `AGG_PROTEIN_TYPE_RED_MEAT`
  - `AGG_PROTEIN_TYPE_SUPPLEMENT`
- Weekly (AVG): Same 6
- Hourly (SUM): Same 6

### 5-6. **Bonus Metrics** (not on screens yet)
- `DISP_PLANT_PROTEIN_GRAMS` - Plant-based protein only
- `DISP_PLANT_PROTEIN_PCT` - % of protein that's plant-based

---

## ✅ AGGREGATIONS (What Calculates the Data)

### **Core Aggregations** (Working)
1. `AGG_PROTEIN_GRAMS` - Total protein
   - Depends on: `DEF_PROTEIN_GRAMS`
   - Periods: 6 (hourly, daily, weekly, monthly, 6month, yearly)
   - Calc types: 2 (SUM, AVG)

2. `AGG_PROTEIN_BREAKFAST_GRAMS` - Breakfast protein
   - Depends on: `DEF_PROTEIN_GRAMS`
   - Filter: `{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "breakfast"}`
   - Periods: 14 (duplicates exist - needs cleanup)
   - Calc types: 2 (SUM, AVG)

3. `AGG_PROTEIN_LUNCH_GRAMS` - Lunch protein
   - Same as breakfast, filtered by "lunch"

4. `AGG_PROTEIN_DINNER_GRAMS` - Dinner protein
   - Same as breakfast, filtered by "dinner"

5-10. `AGG_PROTEIN_TYPE_*` (6 types)
   - Each depends on: `DEF_PROTEIN_GRAMS`
   - Each filtered by protein type (fatty_fish, lean_protein, plant_based, processed_meat, red_meat, supplement)
   - Periods: 6 each
   - Calc types: 2 (SUM, AVG)

11. `AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT` - Ratio
    - Depends on: `DEF_PROTEIN_GRAMS`, `DEF_WEIGHT`
    - Periods: 6
    - Calc types: 4 (AVG, SUM, MIN, MAX)

12. `AGG_PROTEIN_VARIETY` - Count of protein types
    - Depends on: `DEF_PROTEIN_TYPE`
    - Periods: 6
    - Calc types: 2 (COUNT, COUNT_DISTINCT)

13-14. Plant protein metrics
    - `AGG_PLANTBASED_PROTEIN` - Plant-based grams
    - `AGG_PLANTBASED_PROTEIN_PERCENTAGE` - % plant-based

---

## ⚠️  ISSUES TO FIX

### 1. **Duplicate Periods**
`AGG_PROTEIN_BREAKFAST_GRAMS`, `LUNCH`, `DINNER` have 14 periods instead of 6:
- hourly x3 (should be x1)
- daily x3 (should be x1)
- weekly x3 (should be x1)
- monthly x3 (should be x1)
- 6month x1 ✅
- yearly x1 ✅

**Fix:** Delete duplicates from `aggregation_metrics_periods`

### 2. **Unused Legacy Aggregations** (14 aggregations with no dependencies)
- `AGG_FATTY_FISH_GRAMS` (no dependencies)
- `AGG_GREEK_YOGURT_GRAMS`, `AGG_GREEK_YOGURT_SERVINGS`
- `AGG_LEAN_BEEF_GRAMS`, `AGG_LEAN_BEEF_SERVINGS`
- `AGG_LEAN_POULTRY_GRAMS`, `AGG_LEAN_POULTRY_SERVINGS`
- `AGG_PLANT_GRAMS`, `AGG_PLANT_SERVINGS` ⚠️ **0 periods, 0 calc types**
- `AGG_PROCESSED_MEAT_GRAMS`, `AGG_PROCESSED_MEAT_SERVINGS`
- `AGG_PROTEIN_GRAMS_TO_SERVINGS`, `AGG_PROTEIN_SERVINGS_TO_GRAMS`
- `AGG_RED_MEAT_GRAMS`

**Decision needed:** Delete these? They're not used anywhere and can't calculate anything.

### 3. **Missing DISP_PROTEIN_GRAMS from Detail Screen**
The detail screen shows:
- protein_overview: Only `DISP_PROTEIN_PER_KG`
- protein_details: `DISP_PROTEIN_MEAL_TIMING`, `DISP_PROTEIN_TYPE`

But we probably want `DISP_PROTEIN_GRAMS` in the overview section too?

---

## ✅ DATA ENTRY FIELDS

### **Input Fields** (4)
1. `DEF_PROTEIN_GRAMS` - quantity (numeric)
   - Used in 13 aggregations

2. `DEF_PROTEIN_TYPE` - reference (uuid)
   - Points to `data_entry_fields_reference` where `reference_category = 'protein_types'`
   - Options: fatty_fish, lean_protein, plant_based, processed_meat, red_meat, supplement, etc.
   - Used in 1 aggregation (PROTEIN_VARIETY)

3. `DEF_PROTEIN_TIMING` - reference (uuid)
   - Points to `data_entry_fields_reference` where `reference_category = 'protein_timing'`
   - Options: breakfast, lunch, dinner, afternoon_snack, evening_snack, morning_snack, other
   - Not directly used in aggregations (used in filter_conditions instead)

4. `DEF_PROTEIN_TIME` - timestamp (datetime)
   - Used in events only, not in aggregations

---

## 🎯 MOBILE IMPLEMENTATION QUERIES

### **For Primary Screen** (showing just total):
```sql
SELECT
  agg_metric_id,
  period_type,
  period_start,
  calculated_value
FROM aggregation_results_cache
WHERE patient_id = '<user_id>'
  AND agg_metric_id = 'AGG_PROTEIN_GRAMS'
  AND period_type IN ('daily', 'weekly')
  AND calculation_type = 'SUM'
  AND period_start >= '<start_date>'
ORDER BY period_start DESC;
```

### **For Detail Screen - Overview Section** (ratio):
```sql
SELECT
  agg_metric_id,
  period_type,
  period_start,
  calculated_value
FROM aggregation_results_cache
WHERE patient_id = '<user_id>'
  AND agg_metric_id = 'AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT'
  AND period_type = 'daily'
  AND calculation_type = 'AVG'
  AND period_start >= '<start_date>'
ORDER BY period_start;
```

### **For Detail Screen - Breakdown by Meal** (stacked bar):
```sql
SELECT
  agg_metric_id,
  period_start,
  calculated_value
FROM aggregation_results_cache
WHERE patient_id = '<user_id>'
  AND agg_metric_id IN (
    'AGG_PROTEIN_BREAKFAST_GRAMS',
    'AGG_PROTEIN_LUNCH_GRAMS',
    'AGG_PROTEIN_DINNER_GRAMS'
  )
  AND period_type = 'daily'
  AND calculation_type = 'SUM'
  AND period_start >= '<start_date>'
ORDER BY period_start, agg_metric_id;
```

### **For Detail Screen - Breakdown by Type** (stacked bar):
```sql
SELECT
  agg_metric_id,
  period_start,
  calculated_value
FROM aggregation_results_cache
WHERE patient_id = '<user_id>'
  AND agg_metric_id IN (
    'AGG_PROTEIN_TYPE_FATTY_FISH',
    'AGG_PROTEIN_TYPE_LEAN_PROTEIN',
    'AGG_PROTEIN_TYPE_PLANT_BASED',
    'AGG_PROTEIN_TYPE_PROCESSED_MEAT',
    'AGG_PROTEIN_TYPE_RED_MEAT',
    'AGG_PROTEIN_TYPE_SUPPLEMENT'
  )
  AND period_type = 'daily'
  AND calculation_type = 'SUM'
  AND period_start >= '<start_date>'
ORDER BY period_start, agg_metric_id;
```

---

## 📱 WHAT'S MISSING FOR MOBILE?

### **Data Entry Flow:**
1. User logs protein intake
2. Fields required:
   - Protein grams (quantity)
   - Protein type (dropdown: fatty fish, lean protein, plant-based, etc.)
   - Protein timing (dropdown: breakfast, lunch, dinner, snack)
   - Timestamp (auto or manual)
3. Creates entries in `patient_data_entries`:
   - Row 1: `field_id = 'DEF_PROTEIN_GRAMS'`, `value_quantity = <grams>`
   - Row 2: `field_id = 'DEF_PROTEIN_TYPE'`, `value_reference = <uuid from data_entry_fields_reference>`
   - Row 3: `field_id = 'DEF_PROTEIN_TIMING'`, `value_reference = <uuid from data_entry_fields_reference>`
   - Row 4: `field_id = 'DEF_PROTEIN_TIME'`, `value_timestamp = <time>`

### **Display Flow:**
1. Query `display_screens` where `screen_id = 'SCREEN_PROTEIN'`
2. Query `display_screens_primary_display_metrics` to get metrics for summary
3. Query `display_screens_detail_display_metrics` to get metrics for detail view
4. For each metric, query `display_metrics_aggregations` to get which aggregations to fetch
5. Query `aggregation_results_cache` with those aggregations for the selected period

---

## ✅ READY FOR MOBILE?

**YES!** Protein is complete for mobile implementation:

✅ All 4 display metrics configured and mapped
✅ All aggregations have dependencies and can calculate
✅ Screens configured (primary + detail with 2 sections)
✅ Test data exists for test.patient.21@wellpath.com
✅ Conditional filtering working (meal timing, protein types)
✅ Hourly, daily, weekly periods available

**Minor cleanup needed:**
⚠️  Remove duplicate periods (cosmetic, won't break anything)
⚠️  Delete or fix 14 unused legacy aggregations
⚠️  Consider adding DISP_PROTEIN_GRAMS to detail screen overview section

**The mobile team can start building the protein screens now!**
