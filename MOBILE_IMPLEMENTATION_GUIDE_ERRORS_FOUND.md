# Mobile Implementation Guide - Errors Found and Fixes

**Date**: 2025-10-23
**Status**: Critical Errors Identified ⚠️

---

## Summary

The original `MOBILE_TRACKED_METRICS_IMPLEMENTATION_GUIDE.md` contains **3 critical errors** that cause mobile app failures.

---

## Error #1: Wrong Table Name ❌

**Location**: Line 119, Query 1 (Step 1)

**What the docs say:**
```sql
FROM parent_display_metrics pdm
JOIN display_screens_metrics dsm ON dsm.metric_id = pdm.parent_metric_id
WHERE dsm.screen_id = 'SCREEN_NUTRITION'
```

**Problems:**
1. ❌ Table `display_screens_metrics` **does not exist**
2. ❌ Column should be `dsm.parent_metric_id`, not `dsm.metric_id`
3. ❌ Need table alias on `parent_metric_id` (ambiguous column reference)

**Correct version:**
```sql
FROM parent_display_metrics pdm
JOIN display_screens_parent_metrics dspm ON dspm.parent_metric_id = pdm.parent_metric_id
WHERE dspm.screen_id = 'SCREEN_PROTEIN'  -- see Error #2
```

**Why it matters:** This is the **first query** mobile team runs to load screens. It fails immediately with "relation does not exist" error.

---

## Error #2: Wrong Screen ID ❌

**Location**: Multiple locations (lines 119, 122, example queries)

**What the docs say:**
```sql
WHERE dsm.screen_id = 'SCREEN_NUTRITION'
```

**Problem:**
❌ `SCREEN_NUTRITION` **does not exist** in the database

**Available screens:**
- `SCREEN_PROTEIN`
- `SCREEN_FIBER`
- `SCREEN_FRUITS`
- `SCREEN_VEGETABLES`
- `SCREEN_NUTRITION_QUALITY`
- `SCREEN_CARDIO`
- `SCREEN_STRENGTH`
- `SCREEN_HIIT`
- `SCREEN_MOBILITY`
- `SCREEN_SLEEP`
- `SCREEN_BIOMETRICS`
- `SCREEN_ACTIVITY`
- `SCREEN_WELLNESS`
- `SCREEN_COGNITIVE`
- `SCREEN_SUBSTANCES`
- `SCREEN_SKINCARE`
- `SCREEN_LIGHT_EXPOSURE`
- `SCREEN_HYDRATION`
- `SCREEN_COMPLIANCE`
- `SCREEN_MINDFULNESS`
- `SCREEN_STEPS`
- `SCREEN_MEAL_TIMING`

**Correct examples:**
```sql
WHERE dspm.screen_id = 'SCREEN_PROTEIN'
WHERE dspm.screen_id = 'SCREEN_FIBER'
WHERE dspm.screen_id = 'SCREEN_FRUITS'
```

**Why it matters:** Query returns 0 rows, mobile app shows no content.

---

## Error #3: Missing Table Alias ❌

**Location**: Lines 288-323 (Query 1 with CTEs), Line 106-123 (Query 1 simple)

**What the docs say:**
```sql
SELECT
  parent_metric_id,    -- ❌ Ambiguous!
  parent_name,
  ...
FROM parent_display_metrics pdm
JOIN display_screens_parent_metrics dspm
  ON dspm.parent_metric_id = pdm.parent_metric_id
```

**Problem:**
❌ Both tables have `parent_metric_id`, causes "column reference ambiguous" error

**Correct version:**
```sql
SELECT
  pdm.parent_metric_id,    -- ✅ Explicit table alias
  pdm.parent_name,
  pdm.parent_description,
  pdm.chart_type_id,
  pdm.supported_units,
  pdm.default_unit,
  pdm.about_what,
  pdm.about_why,
  pdm.about_optimal_target,
  pdm.about_quick_tips
FROM parent_display_metrics pdm
JOIN display_screens_parent_metrics dspm
  ON dspm.parent_metric_id = pdm.parent_metric_id
WHERE dspm.screen_id = :screen_id
  AND pdm.is_active = true
ORDER BY dspm.display_order;
```

**Why it matters:** PostgreSQL rejects the query with ambiguous column error.

---

## Error #4: CROSS JOIN Returns Empty on Missing Data ⚠️

**Location**: Lines 288-323 (Query 1 with CTEs)

**What the docs say:**
```sql
WITH parent_meta AS (...),
current_value AS (...)
SELECT
  pm.*,
  cv.value as current_value,
  cv.period_end as current_date
FROM parent_meta pm
CROSS JOIN current_value cv;  -- ❌ Returns 0 rows if cv is empty!
```

**Problem:**
If `current_value` CTE returns 0 rows (no aggregation data yet), the **entire query returns 0 rows** due to CROSS JOIN behavior.

**Correct version:**
```sql
SELECT
  pm.*,
  cv.value as current_value,
  cv.period_end as current_date
FROM parent_meta pm
LEFT JOIN current_value cv ON true;  -- ✅ Returns parent even if no current value
```

**Why it matters:** New users with no data see blank screen instead of parent card with "No data" message.

---

## Queries Status

| Query | Location | Status | Issues |
|-------|----------|--------|--------|
| **Query 1** (Simple) | Lines 106-123 | ❌ BROKEN | Wrong table name, wrong screen_id, missing alias |
| **Query 1** (CTE) | Lines 288-323 | ❌ BROKEN | Same issues + CROSS JOIN problem |
| **Query 2** | Lines 329-345 | ✅ WORKS | Syntax correct (returns 0 rows but that's expected with no data) |
| **Query 3** | Lines 356-367 | ✅ WORKS | Syntax correct, tested successfully |
| **Query 4** | Lines 371-381 | ✅ WORKS | Syntax correct, tested successfully |
| **Query 5** | Lines 386-406 | ✅ WORKS | Syntax correct (returns 0 rows but that's expected with no data) |

---

## Impact on Mobile Team

### Failure Sequence

1. **Mobile app starts** → Runs Query 1 to get parent cards
2. **Query 1 fails** with `relation "display_screens_metrics" does not exist`
3. **Mobile dev fixes table name** → Runs again
4. **Query fails again** with `column reference "parent_metric_id" is ambiguous`
5. **Mobile dev adds alias** → Runs again
6. **Query returns 0 rows** because `SCREEN_NUTRITION` doesn't exist
7. **Mobile dev frustrated** → Reports "documentation is shit, broken all over the place"

---

## Corrected Query 1 (Complete)

### Simple Version

```sql
-- Get all parent cards for a specific screen
SELECT
  pdm.parent_metric_id,
  pdm.parent_name,
  pdm.parent_description,
  pdm.chart_type_id,
  pdm.supported_units,
  pdm.default_unit,
  pdm.about_what,
  pdm.about_why,
  pdm.about_optimal_target,
  pdm.about_quick_tips
FROM parent_display_metrics pdm
JOIN display_screens_parent_metrics dspm
  ON dspm.parent_metric_id = pdm.parent_metric_id
WHERE dspm.screen_id = $1  -- e.g., 'SCREEN_PROTEIN'
  AND pdm.is_active = true
ORDER BY dspm.display_order;
```

**Parameters:**
- `$1`: screen_id (must be one of the 22 valid screen IDs listed above)

### CTE Version with Current Value

```sql
-- Get parent card metadata and current value
WITH parent_meta AS (
  SELECT
    pdm.parent_metric_id,
    pdm.parent_name,
    pdm.chart_type_id,
    pdm.supported_units,
    pdm.default_unit,
    pdm.about_what,
    pdm.about_why,
    pdm.about_optimal_target,
    pdm.about_quick_tips
  FROM parent_display_metrics pdm
  WHERE pdm.parent_metric_id = $1
),
current_value AS (
  SELECT
    arc.value,
    arc.period_end
  FROM aggregation_results_cache arc
  JOIN parent_child_display_metrics_aggregations pca
    ON pca.agg_metric_id = arc.agg_metric_id
  WHERE pca.parent_metric_id = $1
    AND arc.user_id = $2
    AND arc.period_type = 'daily'
    AND arc.calculation_type_id = 'SUM'
  ORDER BY arc.period_end DESC
  LIMIT 1
)
SELECT
  pm.*,
  cv.value as current_value,
  cv.period_end as current_date
FROM parent_meta pm
LEFT JOIN current_value cv ON true;  -- Changed from CROSS JOIN
```

**Parameters:**
- `$1`: parent_metric_id (e.g., 'DISP_PROTEIN_SERVINGS')
- `$2`: user_id (UUID)

---

## All Corrected Queries

### Query 2: Get Parent Chart Data ✅

**Status**: Already correct, no changes needed

```sql
SELECT
  arc.value,
  arc.period_start,
  arc.period_end
FROM aggregation_results_cache arc
JOIN parent_child_display_metrics_aggregations pca
  ON pca.agg_metric_id = arc.agg_metric_id
WHERE pca.parent_metric_id = $1
  AND arc.user_id = $2
  AND arc.period_type = $3  -- 'weekly'
  AND arc.calculation_type_id = $4  -- 'AVG'
  AND arc.period_end >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY arc.period_start;
```

### Query 3: Get Modal Sections ✅

**Status**: Already correct, no changes needed

```sql
SELECT
  section_id,
  section_name,
  section_icon,
  section_chart_type_id,
  display_order,
  is_default_tab
FROM parent_detail_sections
WHERE parent_metric_id = $1
  AND is_active = true
ORDER BY display_order;
```

### Query 4: Get Children for Section ✅

**Status**: Already correct, no changes needed

```sql
SELECT
  child_metric_id,
  child_name,
  child_description,
  data_series_order
FROM child_display_metrics
WHERE section_id = $1
  AND is_active = true
ORDER BY data_series_order;
```

### Query 5: Get Section Chart Data ✅

**Status**: Already correct, no changes needed

```sql
SELECT
  cdm.child_metric_id,
  cdm.child_name,
  cdm.data_series_order,
  arc.value,
  arc.period_start,
  arc.period_end
FROM child_display_metrics cdm
JOIN parent_child_display_metrics_aggregations pca
  ON pca.child_metric_id = cdm.child_metric_id
JOIN aggregation_results_cache arc
  ON arc.agg_metric_id = pca.agg_metric_id
  AND arc.period_type = pca.period_type
  AND arc.calculation_type_id = pca.calculation_type_id
WHERE cdm.section_id = $1
  AND arc.user_id = $2
  AND arc.period_type = $3
  AND arc.calculation_type_id = $4
  AND arc.period_end >= $5  -- Filter by date range
ORDER BY cdm.data_series_order, arc.period_start;
```

---

## Testing Results

All queries were tested against production database:

```bash
# Test environment
Host: aws-1-us-west-1.pooler.supabase.com
Port: 5432
Database: postgres
User: postgres.csotzmardnvrpdhlogjm
```

**Query 1 (Corrected)**: ✅ Syntax valid
**Query 2**: ✅ Syntax valid
**Query 3**: ✅ Returns 4 sections for DISP_PROTEIN_SERVINGS
**Query 4**: ✅ Returns 3 children for SECTION_PROTEIN_TIMING
**Query 5**: ✅ Syntax valid

---

## Recommendations

1. **Immediately** update `MOBILE_TRACKED_METRICS_IMPLEMENTATION_GUIDE.md` with corrected queries
2. **Test** all queries against actual database before documenting
3. **Use** actual screen IDs from the database, don't invent example names
4. **Always** use table aliases when joining tables with overlapping column names
5. **Prefer** LEFT JOIN over CROSS JOIN when dealing with optional data
6. **Validate** table and column names exist before documenting

---

## Next Steps

1. Create corrected version: `MOBILE_TRACKED_METRICS_IMPLEMENTATION_GUIDE_V2.md`
2. Archive broken version: `MOBILE_TRACKED_METRICS_IMPLEMENTATION_GUIDE_V1_BROKEN.md`
3. Notify mobile team of corrections
4. Add integration tests for all documented queries

---

**Status**: Ready for correction ✅
