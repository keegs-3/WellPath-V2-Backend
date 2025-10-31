# Mobile Quick Start: Protein Intake

**Status**: ✅ Ready for Implementation
**Test User**: `02cc8441-5f01-4634-acfc-59e6f6a5705a`

---

## 1. Parent Card (Hourly View)

### Query
```sql
SELECT
  pdm.parent_name,
  amp.chart_type,
  amp.bars,
  amp.y_axis_label,
  arc.period_start,
  arc.value

FROM parent_display_metrics pdm
JOIN parent_child_display_metrics_aggregations pcdma
  ON pcdma.parent_metric_id = pdm.parent_metric_id
  AND pcdma.period_type = 'hourly'
JOIN aggregation_metrics_periods amp
  ON amp.agg_metric_id = pcdma.agg_metric_id
  AND amp.period_id = pcdma.period_type
JOIN aggregation_results_cache arc
  ON arc.agg_metric_id = pcdma.agg_metric_id
  AND arc.period_type = pcdma.period_type
  AND arc.calculation_type_id = pcdma.calculation_type_id
  AND arc.user_id = :user_id

WHERE pdm.parent_metric_id = 'DISP_PROTEIN_SERVINGS'
  AND pcdma.child_metric_id IS NULL

ORDER BY arc.period_start;
```

### Result
```
parent_name    | chart_type   | bars | y_axis_label | period_start        | value
---------------+--------------+------+--------------+---------------------+------
Protein Intake | bar_vertical | 24   | Grams        | 2025-10-22 08:00:00 | 20.1
Protein Intake | bar_vertical | 24   | Grams        | 2025-10-22 12:00:00 | 23.4
Protein Intake | bar_vertical | 24   | Grams        | 2025-10-22 18:00:00 | 34.9
```

**Render**: Sparse bar chart (24 possible hours, only 3 have data)

---

## 2. Modal Tab 1: Timing

### Query
```sql
SELECT
  cdm.child_name,
  cdm.data_series_order,
  arc.value,
  arc.period_start

FROM child_display_metrics cdm
JOIN parent_child_display_metrics_aggregations pcdma
  ON pcdma.child_metric_id = cdm.child_metric_id
  AND pcdma.period_type = 'weekly'
JOIN aggregation_results_cache arc
  ON arc.agg_metric_id = pcdma.agg_metric_id
  AND arc.period_type = pcdma.period_type
  AND arc.calculation_type_id = pcdma.calculation_type_id
  AND arc.user_id = :user_id

WHERE cdm.section_id = 'SECTION_PROTEIN_TIMING'
  AND cdm.is_active = true

ORDER BY cdm.data_series_order NULLS LAST, arc.period_start;
```

### Result (Weekly AVG)
```
child_name         | data_series_order | value
-------------------+-------------------+-------
Protein: Breakfast | (null)            | 20.2
Protein: Lunch     | (null)            | 29.9
Protein: Dinner    | (null)            | 35.2
```

**Render**: Stacked bar chart
- 7 bars (one per day of week)
- 3 segments per bar (breakfast, lunch, dinner)
- Stack order: breakfast (bottom), lunch (middle), dinner (top)

---

## 3. Modal Tab 2: Type

### Query
```sql
SELECT
  cdm.child_name,
  cdm.data_series_order,
  arc.value,
  arc.period_start

FROM child_display_metrics cdm
JOIN parent_child_display_metrics_aggregations pcdma
  ON pcdma.child_metric_id = cdm.child_metric_id
  AND pcdma.period_type = 'weekly'
JOIN aggregation_results_cache arc
  ON arc.agg_metric_id = pcdma.agg_metric_id
  AND arc.period_type = pcdma.period_type
  AND arc.calculation_type_id = pcdma.calculation_type_id
  AND arc.user_id = :user_id

WHERE cdm.section_id = 'SECTION_PROTEIN_TYPE'
  AND cdm.is_active = true

ORDER BY cdm.data_series_order, arc.period_start;
```

### Result (Weekly AVG)
```
child_name     | data_series_order | value
---------------+-------------------+-------
Processed Meat | 1                 | 33.9
Red Meat       | 2                 | 31.6
Fatty Fish     | 3                 | 23.4
Lean Protein   | 4                 | 22.7
Plant-based    | 5                 | 27.5
```

**Render**: Stacked bar chart
- 7 bars (one per day of week)
- Up to 6 segments per bar (one per protein type)
- Stack order preserved by `data_series_order`
- Supplement type has no data (omit from chart)

---

## 4. Color Recommendations

### Timing Section
- Breakfast: 🟡 Yellow (#FDB813)
- Lunch: 🟠 Orange (#FF8C00)
- Dinner: 🔴 Red (#DC143C)

### Type Section
- Processed Meat: 🔴 Red (#DC143C)
- Red Meat: 🟠 Orange (#FF6347)
- Fatty Fish: 🔵 Blue (#4169E1)
- Lean Protein: 🟢 Green (#32CD32)
- Plant-based: 🟡 Yellow (#FFD700)
- Supplement: ⚪ Gray (#9E9E9E)

---

## 5. Period Switching

Change the `:user_id` and `pcdma.period_type` parameter:
- `'hourly'` - Parent card daily view only
- `'daily'` - Not typically used for protein
- `'weekly'` - Most common (7 days)
- `'monthly'` - 30 days
- `'6month'` - 26 weeks
- `'yearly'` - 52 weeks

**Note**: Calculation type changes automatically:
- hourly/daily → SUM (total grams that day/hour)
- weekly/monthly/6month/yearly → AVG (daily average)

---

## 6. Swift Example (Simplified)

```swift
// Fetch parent card data
func fetchProteinParent(userId: UUID, period: String) async -> [DataPoint] {
    let rows = await supabase
        .rpc("get_protein_parent_data", params: [
            "p_user_id": userId,
            "p_period": period
        ])
        .execute()

    return rows.map { row in
        DataPoint(
            value: row["value"],
            timestamp: row["period_start"]
        )
    }
}

// Fetch timing section
func fetchProteinTiming(userId: UUID, period: String) async -> [SeriesData] {
    let rows = await supabase
        .from("child_display_metrics")
        .select("""
            child_name,
            data_series_order,
            parent_child_display_metrics_aggregations!inner(
                aggregation_results_cache!inner(value, period_start)
            )
        """)
        .eq("section_id", "SECTION_PROTEIN_TIMING")
        .eq("parent_child_display_metrics_aggregations.period_type", period)
        .eq("aggregation_results_cache.user_id", userId)
        .order("data_series_order")
        .execute()

    // Group by child_name to create series
    return groupIntoSeries(rows)
}
```

---

## 7. Empty States

### Parent Card (Hourly)
- If no data: Show empty chart with "No protein logged today"
- If sparse data: Show only hours with entries (e.g., 3 bars out of 24)

### Modal Sections
- If no child data: "No protein data for this period"
- If partial data: Show only types/meals with data (e.g., 5 types instead of 6)

---

## 8. Testing Checklist

- [ ] Parent card hourly view shows 3 bars (8am, 12pm, 6pm)
- [ ] Parent card weekly view shows 7 bars
- [ ] Timing tab shows 3 segments (breakfast, lunch, dinner)
- [ ] Type tab shows 5 segments (no supplement data)
- [ ] Colors are consistent across periods
- [ ] Period switcher updates data correctly
- [ ] Empty states display gracefully

---

## 9. Need Help?

Contact backend with:
- User ID: `02cc8441-5f01-4634-acfc-59e6f6a5705a`
- Section ID: `SECTION_PROTEIN_TIMING` or `SECTION_PROTEIN_TYPE`
- Period: `hourly`, `weekly`, etc.
- SQL query attempted
- Expected vs actual results

---

**Full Documentation**: See `MOBILE_IMPLEMENTATION_ACTUAL_QUERIES.md` for complete details

**Last Updated**: 2025-10-23 23:50 UTC
