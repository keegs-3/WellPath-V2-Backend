# Complete Metric Pipeline Playbook

## What We Built: Protein (Template for All Future Metrics)

This document outlines **every step** required to build a complete, mobile-ready health metric from database to mobile app. Use this as a checklist when building Steps, Sleep, Cardio, etc.

---

## Phase 1: Data Model Setup

### 1.1 Create Reference Data (if needed)
**What:** Categorical values users can select (e.g., protein types, meal timing)

**Files:** `data_entry_fields_reference` table

**For Protein:**
- Created `protein_types` category: 8 types (fatty_fish, lean_protein, plant_based, processed_meat, red_meat, eggs, dairy, supplement)
- Created `protein_timing` category: 7 options (breakfast, lunch, dinner, morning_snack, afternoon_snack, evening_snack, other)

**SQL Pattern:**
```sql
INSERT INTO data_entry_fields_reference (
  reference_category, reference_key, display_name, sort_order, is_active
) VALUES
  ('protein_types', 'fatty_fish', 'Fatty Fish', 1, true),
  ('protein_types', 'lean_protein', 'Lean Protein', 2, true),
  ...
```

**Key Decision:** Keep categories MECE (Mutually Exclusive, Collectively Exhaustive)

---

### 1.2 Create Data Entry Fields
**What:** The actual fields users log data into

**Table:** `data_entry_fields`

**For Protein (4 fields):**
1. `DEF_PROTEIN_GRAMS` - quantity (numeric) - how much protein
2. `DEF_PROTEIN_TYPE` - reference (uuid) - what type of protein
3. `DEF_PROTEIN_TIMING` - reference (uuid) - when consumed
4. `DEF_PROTEIN_TIME` - timestamp (datetime) - exact time

**SQL Pattern:**
```sql
INSERT INTO data_entry_fields (
  field_id, field_name, field_type, data_type, reference_table, unit_id, is_active
) VALUES
  ('DEF_PROTEIN_GRAMS', 'protein_grams', 'quantity', 'numeric', NULL, 'gram', true),
  ('DEF_PROTEIN_TYPE', 'protein_type', 'reference', 'uuid', 'data_entry_fields_reference', NULL, true),
  ...
```

---

### 1.3 Register Fields in Field Registry
**What:** Make fields available for patient_data_entries

**Table:** `field_registry`

**For Protein:**
```sql
INSERT INTO field_registry (
  field_id, field_name, display_name, description, field_source, data_entry_field_id, is_active
) VALUES
  ('DEF_PROTEIN_GRAMS', 'protein_grams', 'Protein Grams', 'Amount of protein consumed', 'user_input', 'DEF_PROTEIN_GRAMS', true),
  ('DEF_PROTEIN_TYPE', 'protein_type', 'Protein Type', 'Type of protein source', 'user_input', 'DEF_PROTEIN_TYPE', true),
  ('DEF_PROTEIN_TIMING', 'protein_timing', 'Protein Timing', 'When protein was consumed', 'user_input', 'DEF_PROTEIN_TIMING', true),
  ...
```

---

## Phase 2: Aggregations Setup

### 2.1 Create Aggregation Metrics
**What:** Define what calculations you want (total protein, protein by meal, protein by type, etc.)

**Table:** `aggregation_metrics`

**For Protein (18 total aggregations):**
- 1 total: `AGG_PROTEIN_GRAMS`
- 7 by timing: `AGG_PROTEIN_BREAKFAST_GRAMS`, `AGG_PROTEIN_LUNCH_GRAMS`, etc.
- 8 by type: `AGG_PROTEIN_TYPE_FATTY_FISH`, `AGG_PROTEIN_TYPE_EGGS`, etc.
- 1 ratio: `AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT`
- 1 variety: `AGG_PROTEIN_VARIETY`

**SQL Pattern:**
```sql
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description, output_unit, is_active
) VALUES
  ('AGG_PROTEIN_GRAMS', 'protein_grams', 'Total Protein', 'Total daily protein intake', 'gram', true),
  ('AGG_PROTEIN_BREAKFAST_GRAMS', 'protein_breakfast_grams', 'Breakfast Protein', 'Protein at breakfast', 'gram', true),
  ...
```

---

### 2.2 Add Periods to Each Aggregation
**What:** Define time periods for each aggregation (hourly, daily, weekly, etc.)

**Table:** `aggregation_metrics_periods`

**For Protein:**
- Most aggregations: hourly, daily, weekly, monthly, 6month, yearly (6 periods)
- Ratio/per-kg: daily, weekly, monthly only (3 periods)

**SQL Pattern:**
```sql
INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
SELECT agg_id, period
FROM (VALUES ('AGG_PROTEIN_GRAMS'), ('AGG_PROTEIN_BREAKFAST_GRAMS'), ...) AS aggs(agg_id)
CROSS JOIN (VALUES ('hourly'), ('daily'), ('weekly'), ('monthly'), ('6month'), ('yearly')) AS periods(period)
ON CONFLICT DO NOTHING;
```

---

### 2.3 Add Calculation Types
**What:** Define how to calculate (SUM, AVG, COUNT, etc.)

**Table:** `aggregation_metrics_calculation_types`

**For Protein:**
- Quantity aggregations: SUM, AVG
- Count/variety aggregations: COUNT, COUNT_DISTINCT
- Ratio aggregations: AVG, SUM, MIN, MAX

**SQL Pattern:**
```sql
INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
SELECT agg_id, calc_type
FROM (VALUES ('AGG_PROTEIN_GRAMS'), ...) AS aggs(agg_id)
CROSS JOIN (VALUES ('SUM'), ('AVG')) AS calc_types(calc_type)
ON CONFLICT DO NOTHING;
```

---

### 2.4 Add Dependencies (THE CRITICAL STEP!)
**What:** Connect aggregations to data entry fields, with optional filters

**Table:** `aggregation_metrics_dependencies`

**For Protein:**
- `AGG_PROTEIN_GRAMS` → depends on `DEF_PROTEIN_GRAMS` (no filter)
- `AGG_PROTEIN_BREAKFAST_GRAMS` → depends on `DEF_PROTEIN_GRAMS` (filter: timing=breakfast)
- `AGG_PROTEIN_TYPE_EGGS` → depends on `DEF_PROTEIN_GRAMS` (filter: type=eggs)

**SQL Pattern (with filter):**
```sql
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES
  ('AGG_PROTEIN_BREAKFAST_GRAMS', 'DEF_PROTEIN_GRAMS', 'data_field',
   '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "breakfast"}'::jsonb),
  ...
```

**SQL Pattern (without filter):**
```sql
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES
  ('AGG_PROTEIN_GRAMS', 'DEF_PROTEIN_GRAMS', 'data_field'),
  ...
```

---

## Phase 3: Display Configuration

### 3.1 Create Display Metrics
**What:** UI-ready metrics that mobile will actually display

**Table:** `display_metrics`

**For Protein (6 display metrics):**
1. `DISP_PROTEIN_GRAMS` - Total protein
2. `DISP_PROTEIN_MEAL_TIMING` - By meal (stacked bars)
3. `DISP_PROTEIN_TYPE` - By type (stacked bars)
4. `DISP_PROTEIN_PER_KG` - Ratio (line chart with range)
5. `DISP_PLANT_PROTEIN_GRAMS` - Plant-based only
6. `DISP_PLANT_PROTEIN_PCT` - % plant-based

**SQL Pattern:**
```sql
INSERT INTO display_metrics (
  metric_id, metric_name, chart_type_id, pillar, is_active
) VALUES
  ('DISP_PROTEIN_GRAMS', 'Protein', 'bar_vertical', 'Healthful Nutrition', true),
  ('DISP_PROTEIN_MEAL_TIMING', 'Protein by Meal', 'bar_stacked', 'Healthful Nutrition', true),
  ...
```

---

### 3.2 Add Education Content to Display Metrics
**What:** Tab-specific about/tips content

**Columns:** `about_content`, `longevity_impact`, `quick_tips`

**For Protein:**
- Tab 1 (Meal Timing): Content about protein timing science
- Tab 2 (Protein Type): Content about protein sources
- Tab 3 (Ratio): Content about g/kg requirements

**SQL Pattern:**
```sql
UPDATE display_metrics
SET
  about_content = 'Protein timing and distribution throughout the day...',
  longevity_impact = 'Even protein distribution across meals is associated with...',
  quick_tips = jsonb_build_array(
    'Eat 20-40g protein at breakfast...',
    'Space protein meals 3-5 hours apart...',
    ...
  )
WHERE metric_id = 'DISP_PROTEIN_MEAL_TIMING';
```

---

### 3.3 Map Display Metrics to Aggregations
**What:** Connect display metrics to their underlying aggregations

**Table:** `display_metrics_aggregations`

**For Protein:**
- `DISP_PROTEIN_GRAMS` → `AGG_PROTEIN_GRAMS` (daily/SUM, weekly/AVG, hourly/SUM)
- `DISP_PROTEIN_MEAL_TIMING` → 7 breakfast/lunch/dinner/snack aggregations
- `DISP_PROTEIN_TYPE` → 8 protein type aggregations

**SQL Pattern:**
```sql
INSERT INTO display_metrics_aggregations (
  metric_id, agg_metric_id, period_type, calculation_type_id, display_order
) VALUES
  ('DISP_PROTEIN_GRAMS', 'AGG_PROTEIN_GRAMS', 'daily', 'SUM', 1),
  ('DISP_PROTEIN_GRAMS', 'AGG_PROTEIN_GRAMS', 'weekly', 'AVG', 2),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_BREAKFAST_GRAMS', 'daily', 'SUM', 1),
  ('DISP_PROTEIN_MEAL_TIMING', 'AGG_PROTEIN_LUNCH_GRAMS', 'daily', 'SUM', 2),
  ...
```

---

## Phase 4: Screen Configuration

### 4.1 Create Primary Screen
**What:** The summary screen with featured metric + accordion

**Table:** `display_screens_primary`

**For Protein:**
```sql
INSERT INTO display_screens_primary (
  primary_screen_id, display_screen_id, title, description,
  about_content, longevity_impact, quick_tips, has_detail_screen, is_active
) VALUES (
  'SCREEN_PROTEIN_PRIMARY', 'SCREEN_PROTEIN',
  'Protein Intake', 'Track protein grams, servings, and variety',
  'Protein is essential for building and repairing tissues...',
  'Higher protein intake, especially from plant sources...',
  jsonb_build_array(
    'Aim for 20-40g protein per meal...',
    ...
  ),
  true, true
);
```

---

### 4.2 Map Primary Screen Metric
**What:** Choose which metric to feature on primary screen

**Table:** `display_screens_primary_display_metrics`

**For Protein:**
```sql
INSERT INTO display_screens_primary_display_metrics (
  primary_screen_id, metric_id, display_order, is_featured
) VALUES
  ('SCREEN_PROTEIN_PRIMARY', 'DISP_PROTEIN_GRAMS', 1, true);
```

---

### 4.3 Create Detail Screen with Tabs
**What:** Detailed view with multiple tabs

**Table:** `display_screens_detail`

**For Protein (3 tabs):**
1. By Meal - stacked bars
2. By Type - stacked bars with legend
3. Ratio - line chart with optimal range

**SQL Pattern:**
```sql
INSERT INTO display_screens_detail (
  detail_screen_id, display_screen_id, title, subtitle, layout_type, tab_config
) VALUES (
  'SCREEN_PROTEIN_DETAIL', 'SCREEN_PROTEIN',
  'Protein Tracking', 'Optimize your protein intake',
  'tabs',
  jsonb_build_array(
    jsonb_build_object(
      'tab_id', 'by_meal',
      'tab_title', 'By Meal',
      'tab_icon', 'clock',
      'display_order', 1
    ),
    jsonb_build_object(
      'tab_id', 'by_type',
      'tab_title', 'By Type',
      'tab_icon', 'list.bullet',
      'display_order', 2
    ),
    jsonb_build_object(
      'tab_id', 'ratio',
      'tab_title', 'Ratio',
      'tab_icon', 'chart.line.uptrend.xyaxis',
      'display_order', 3,
      'optimal_range_gkg', jsonb_build_object('min', 1.2, 'max', 1.6),
      'optimal_range_glb', jsonb_build_object('min', 0.54, 'max', 0.73)
    )
  )
);
```

---

### 4.4 Map Detail Screen Metrics to Tabs
**What:** Assign metrics to each tab

**Table:** `display_screens_detail_display_metrics`

**For Protein:**
```sql
INSERT INTO display_screens_detail_display_metrics (
  detail_screen_id, metric_id, section_id, display_order
) VALUES
  ('SCREEN_PROTEIN_DETAIL', 'DISP_PROTEIN_MEAL_TIMING', 'by_meal', 1),
  ('SCREEN_PROTEIN_DETAIL', 'DISP_PROTEIN_TYPE', 'by_type', 1),
  ('SCREEN_PROTEIN_DETAIL', 'DISP_PROTEIN_PER_KG', 'ratio', 1);
```

---

## Phase 5: Test Data & Processing

### 5.1 Generate Test Data
**What:** Create realistic test data for development/testing

**For Protein:** `scripts/generate_protein_test_data.py`
- 46 days of data
- 155 protein logs
- 5 timing types (breakfast, lunch, dinner, snacks)
- 8 protein types

**Pattern:**
```python
# For each day/meal:
# 1. Insert quantity
cur.execute("""
  INSERT INTO patient_data_entries (patient_id, field_id, value_quantity, entry_date, entry_timestamp, source)
  VALUES (%s, 'DEF_PROTEIN_GRAMS', %s, %s, %s, 'manual')
""", (patient_id, grams, date, timestamp))

# 2. Insert type (separate row!)
cur.execute("""
  INSERT INTO patient_data_entries (patient_id, field_id, value_reference, entry_date, entry_timestamp, source)
  VALUES (%s, 'DEF_PROTEIN_TYPE', %s, %s, %s, 'manual')
""", (patient_id, type_uuid, date, timestamp))

# 3. Insert timing (separate row!)
cur.execute("""
  INSERT INTO patient_data_entries (patient_id, field_id, value_reference, entry_date, entry_timestamp, source)
  VALUES (%s, 'DEF_PROTEIN_TIMING', %s, %s, %s, 'manual')
""", (patient_id, timing_uuid, date, timestamp))
```

**Key:** Each protein log = 3 separate entries in patient_data_entries!

---

### 5.2 Process Aggregations
**What:** Calculate aggregations from raw data

**For Protein:** `scripts/process_protein_aggregations_only.py`

**Pattern:**
```python
# For each date with data:
cur.execute("""
  SELECT process_field_aggregations(%s, %s, %s)
""", (patient_id, 'DEF_PROTEIN_GRAMS', date))
```

**Result:** 13,676 aggregations calculated across 46 days

---

## Phase 6: Mobile Implementation

### 6.1 Primary Screen API
```
GET /rest/v1/display_screens_primary?display_screen_id=eq.SCREEN_PROTEIN
  &select=title,description,about_content,longevity_impact,quick_tips

GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<uuid>
  &agg_metric_id=eq.AGG_PROTEIN_GRAMS
  &period_type=eq.daily
  &calculation_type_id=eq.SUM
  &period_start=gte.<date>
```

### 6.2 Detail Screen API
```
GET /rest/v1/display_screens_detail?display_screen_id=eq.SCREEN_PROTEIN
  &select=title,subtitle,tab_config

GET /rest/v1/display_metrics?metric_id=eq.DISP_PROTEIN_MEAL_TIMING
  &select=about_content,longevity_impact,quick_tips

GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<uuid>
  &agg_metric_id=in.(AGG_PROTEIN_BREAKFAST_GRAMS,AGG_PROTEIN_LUNCH_GRAMS,...)
  &period_type=eq.daily
  &calculation_type_id=eq.SUM
  &period_start=gte.<date>
```

---

## Complete Checklist for New Metrics

Use this checklist for Steps, Sleep, Cardio, etc.:

### Database Setup:
- [ ] Create reference data (if needed) - `data_entry_fields_reference`
- [ ] Create data entry fields - `data_entry_fields`
- [ ] Register fields - `field_registry`

### Aggregations:
- [ ] Create aggregation metrics - `aggregation_metrics`
- [ ] Add periods to each - `aggregation_metrics_periods`
- [ ] Add calculation types - `aggregation_metrics_calculation_types`
- [ ] Add dependencies with filters - `aggregation_metrics_dependencies`

### Display:
- [ ] Create display metrics - `display_metrics`
- [ ] Add education content - about_content, longevity_impact, quick_tips
- [ ] Map to aggregations - `display_metrics_aggregations`

### Screens:
- [ ] Create primary screen - `display_screens_primary`
- [ ] Map featured metric - `display_screens_primary_display_metrics`
- [ ] Create detail screen with tabs - `display_screens_detail`
- [ ] Map metrics to tabs - `display_screens_detail_display_metrics`

### Testing:
- [ ] Generate test data script
- [ ] Process aggregations
- [ ] Verify data in cache
- [ ] Test mobile API queries

---

## Key Lessons from Protein

1. **MECE is Critical** - Keep reference categories mutually exclusive and collectively exhaustive
2. **Dependencies are Everything** - Aggregations without dependencies can't calculate anything
3. **Filter Conditions are Powerful** - One field (protein_grams) can create many filtered aggregations (breakfast, lunch, dinner, etc.)
4. **Separate Entries** - Quantity, type, and timing are 3 separate rows in patient_data_entries
5. **Education Content Matters** - Populate about/tips for both primary screen AND each tab
6. **Hourly is Important** - Day views need hourly aggregations
7. **Test Data is Essential** - Mobile can't build without realistic data

---

## File Organization

**Migrations:** `/supabase/migrations/`
- `20251025_create_protein_reference_data.sql`
- `20251025_create_protein_data_entry_fields.sql`
- `20251025_create_protein_aggregations.sql`
- `20251025_create_protein_display_metrics.sql`
- `20251025_create_protein_screens.sql`
- `20251025_add_protein_education_content.sql`

**Scripts:** `/scripts/`
- `generate_protein_test_data.py`
- `process_protein_aggregations_only.py`

**Documentation:** `/`
- `PROTEIN_MOBILE_API_REFERENCE.md` - Mobile API guide
- `PROTEIN_MOBILE_FINAL_SPEC.md` - Complete specification
- `PROTEIN_COMPLETE_STATUS.md` - Technical status

---

## Time Estimate for New Metrics

Based on protein experience:
- **Database setup**: 1-2 hours
- **Aggregations**: 2-3 hours (complex filtering adds time)
- **Display/Screens**: 1-2 hours
- **Test data**: 1 hour
- **Education content**: 1 hour
- **Testing**: 1 hour

**Total: ~8-10 hours per complete metric category**

---

## Next Metrics to Build

1. **Steps** - Simpler (no reference data needed, just quantity)
2. **Sleep** - Complex (multiple stages, calculations)
3. **Cardio** - Medium (types, duration, intensity)
4. **Water** - Simple (quantity, unit conversion)
5. **Weight** - Calculations (BMI, BMR, lean mass)

Use this playbook as your template! 🚀
