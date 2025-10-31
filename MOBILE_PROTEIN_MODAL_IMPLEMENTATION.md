# Mobile: Protein Intake Modal Implementation

**Date**: 2025-10-23
**Status**: ✅ Backend Complete & Verified, Ready for Mobile

---

## Overview

Protein Intake has **3 tabs** in the modal. All are **stacked bar charts** with different data breakdowns.

---

## Parent Card (Protein Intake)

### Daily View
- **Chart**: 24 hourly bars (sparse - only hours with data)
- **Query**: Standard parent query with `period_type = 'hourly'` and `calculation_type_id = 'SUM'`
- **X-axis**: Hour (0-23)
- **Data**: ✅ Hourly data computed and verified

### Weekly/Monthly/Yearly View
- **Chart**: Standard aggregated view
- **Query**: Standard parent query (uses standard aggregation pipeline)

---

## Modal Section 1: **Timing Tab** (Default)

**Shows**: Protein grams breakdown by meal time

### Query

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
WHERE cdm.section_id = 'SECTION_PROTEIN_TIMING'
  AND arc.user_id = :user_id
  AND arc.period_type = :selected_period
  AND arc.calculation_type_id = :calc_type
ORDER BY cdm.data_series_order NULLS LAST, arc.period_start;
```

### Example Result (Weekly AVG)
```
child_name         | value
-------------------+------
Protein: Breakfast | 20.2g
Protein: Lunch     | 29.9g
Protein: Dinner    | 35.2g
```

### Chart
- **Type**: Stacked bar
- **Data series**: 3 (Breakfast, Lunch, Dinner)
- **Colors**: Assign consistent colors for each meal
- **Legend**: Show at bottom

### Interpretation
- **Daily**: Total grams at each meal today
- **Weekly**: Daily average grams at each meal this week
- Shows when user consumes most protein

---

## Modal Section 2: **Type Tab**

**Shows**: Protein grams breakdown by protein source type

### Query

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
WHERE cdm.section_id = 'SECTION_PROTEIN_TYPE'
  AND arc.user_id = :user_id
  AND arc.period_type = :selected_period
  AND arc.calculation_type_id = :calc_type
ORDER BY cdm.data_series_order, arc.period_start;
```

### Example Result (Weekly AVG)
```
child_name     | value
---------------+------
Processed Meat | 33.9g
Red Meat       | 31.6g
Fatty Fish     | 23.4g
Lean Protein   | 22.7g
Plant-based    | 27.5g
Supplement     | 0g (or missing)
```

### Chart
- **Type**: Stacked bar
- **Data series**: Up to 6 (only types with data show)
- **Colors**:
  - Processed Meat: 🔴 Red
  - Red Meat: 🟠 Orange
  - Fatty Fish: 🔵 Blue
  - Lean Protein: 🟢 Green
  - Plant-based: 🟡 Yellow
  - Supplement: ⚪ Gray

### Interpretation
- **Daily**: Total grams from each source today
- **Weekly**: Daily average grams from each source this week
- Shows protein diversity

---

## Modal Section 3: **Variety Tab**

**Shows**: Count of distinct protein types consumed

### Query

```sql
SELECT
  cdm.child_metric_id,
  cdm.child_name,
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
WHERE cdm.section_id = 'SECTION_PROTEIN_VARIETY'
  AND arc.user_id = :user_id
  AND arc.period_type = :selected_period
  AND arc.calculation_type_id = 'AVG'
ORDER BY arc.period_start;
```

### Example Result (Weekly)
```
child_name      | value
----------------+------
Protein Variety | 5
```

### Display
- **Type**: Single value card (not a chart)
- **Shows**: "5 types" or "5 different protein sources"
- **Interpretation**:
  - Higher is better (more variety)
  - Optimal: 4-6 types per week
  - Poor: 1-2 types (not diverse)

---

## Period Behavior

| Period | Calc Type | Meaning |
|--------|-----------|---------|
| Daily | SUM | Total grams that day |
| Weekly | AVG | Daily average over 7 days |
| Monthly | AVG | Daily average over 30 days |
| 6-Month | AVG | Daily average over 6 months |
| Yearly | AVG | Daily average over 12 months |

---

## Data Processing

### Standard Aggregations
- Run: `python3 scripts/process_aggregations.py`
- Handles: Parent totals (weekly/monthly/yearly)

### Custom Protein Aggregations
- Run: `python3 scripts/process_protein_aggregations.py`
- Handles:
  - Hourly data (for daily parent view)
  - Timing breakdown (breakfast/lunch/dinner)
  - Type breakdown (6 protein types)
- **Must run after data entry** to populate child aggregations

---

## Swift Implementation Example

### Load Timing Section

```swift
func loadTimingSection(userId: UUID, period: String) async -> [SeriesData] {
    let calcType = period == "daily" ? "SUM" : "AVG"

    let rows = await supabase
        .from("child_display_metrics")
        .select("""
            child_metric_id,
            child_name,
            data_series_order,
            parent_child_display_metrics_aggregations!inner(
                agg_metric_id,
                aggregation_results_cache!inner(
                    value,
                    period_start,
                    period_end
                )
            )
        """)
        .eq("section_id", "SECTION_PROTEIN_TIMING")
        .eq("parent_child_display_metrics_aggregations.period_type", period)
        .eq("parent_child_display_metrics_aggregations.calculation_type_id", calcType)
        .eq("aggregation_results_cache.user_id", userId)
        .order("data_series_order")
        .execute()

    // Transform into SeriesData for chart
    return transformToSeries(rows)
}
```

### Render Stacked Bar

```swift
Chart {
    ForEach(timingSeries) { series in
        ForEach(series.dataPoints) { point in
            BarMark(
                x: .value("Date", point.date),
                y: .value("Grams", point.value),
                stacking: .standard  // Stacked!
            )
            .foregroundStyle(by: .value("Meal", series.name))
        }
    }
}
.chartLegend(position: .bottom)
```

---

## Empty States

### No Data
- **Timing**: "No protein data for this period"
- **Type**: "No protein type data logged"
- **Variety**: "0 types" (show as 0, not empty)

### Partial Data
- If only 1-2 meals have data, show just those bars
- If only 2-3 types, show just those types
- Don't show empty series

---

## Testing Checklist

- [ ] Timing tab shows breakfast/lunch/dinner breakdown
- [ ] Type tab shows all 6 protein types (or fewer if no data)
- [ ] Variety tab shows count (0-6)
- [ ] Period selector changes data correctly
- [ ] Daily view on parent card shows hourly data (sparse)
- [ ] Empty sections display gracefully
- [ ] Colors are consistent across views
- [ ] Legend shows correct labels

---

## Backend Status

✅ **Complete**:
- ✅ Hourly period configured (24 bars, 1 day)
- ✅ Hourly data computed for daily parent view
- ✅ 3 modal sections created (Timing, Type, Variety)
- ✅ 9 child display metrics (3 timing + 6 types + 1 variety)
- ✅ Custom aggregation processor (`process_protein_aggregations.py`)
- ✅ Standard aggregation processor updated to skip hourly
- ✅ Test data with realistic values (60-120g/day)
- ✅ All mobile queries tested and verified

⚠️ **Note**:
- Supplement type has no test data (expected - not commonly used)

---

## Questions?

Contact backend team with:
- Section ID (e.g., `SECTION_PROTEIN_TIMING`)
- User ID
- Period type
- SQL query used
- Expected vs actual results

---

**Updated**: 2025-10-23
**Backend Engineer**: Claude
**Ready for Mobile**: ✅ Yes
