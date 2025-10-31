# Hydration Component - Quick Reference Card

## At a Glance

**Component**: Hydration (Water & Fluid Intake)
**Complexity**: SIMPLE (1 field, 1 aggregation)
**Migration**: `20251025_create_hydration_nutrition_component.sql`
**Status**: Ready to apply ✅

---

## Key IDs (Copy/Paste Ready)

```
Field:       DEF_HYDRATION_OUNCES
Aggregation: AGG_HYDRATION_TOTAL
Display:     DISP_HYDRATION
Screen:      SCREEN_HYDRATION
```

---

## Database Tables Touched

```
✅ field_registry                           (1 record)
✅ aggregation_metrics                      (1 record)
✅ aggregation_metrics_dependencies         (1 record)
✅ aggregation_metrics_calculation_types    (2 records)
✅ aggregation_metrics_periods              (6 records)
✅ display_metrics                          (1 record)
✅ display_metrics_aggregations             (4 records)
✅ display_screens                          (1 record)
✅ display_screens_primary_display_metrics  (1 record)
```

**Total Records**: 18 database records

---

## Sample Data Entry

```sql
-- User drinks 16 oz of water
INSERT INTO patient_data_entries (
  app_user_id,
  field_id,
  value,
  entry_timestamp
) VALUES (
  'user123',
  'DEF_HYDRATION_OUNCES',
  16.0,
  NOW()
);
```

---

## Sample Aggregation Query

```sql
-- Get daily hydration totals
SELECT 
  period_start::date as day,
  value as total_ounces
FROM aggregation_results_cache
WHERE agg_metric_id = 'AGG_HYDRATION_TOTAL'
  AND period_type = 'daily'
  AND calculation_type = 'SUM'
  AND app_user_id = 'user123'
ORDER BY period_start DESC
LIMIT 7;
```

---

## Mobile API Query

```sql
-- Get screen data for mobile app
SELECT 
  ds.screen_id,
  ds.name,
  ds.icon,
  dm.metric_id,
  dm.chart_type_id,
  dma.period_type,
  dma.calculation_type_id,
  arc.value,
  arc.period_start,
  arc.period_end
FROM display_screens ds
JOIN display_screens_primary_display_metrics dspdm 
  ON ds.screen_id = dspdm.primary_screen_id
JOIN display_metrics dm 
  ON dspdm.metric_id = dm.metric_id
JOIN display_metrics_aggregations dma 
  ON dm.metric_id = dma.metric_id
LEFT JOIN aggregation_results_cache arc 
  ON dma.agg_metric_id = arc.agg_metric_id
  AND dma.period_type = arc.period_type
  AND dma.calculation_type_id = arc.calculation_type
WHERE ds.screen_id = 'SCREEN_HYDRATION'
  AND arc.app_user_id = 'user123'
  AND dma.period_type = 'daily'
ORDER BY arc.period_start DESC;
```

---

## Typical Daily Values

| Scenario | Fluid Ounces | Servings (8oz cups) |
|----------|--------------|---------------------|
| Low | 32-48 oz | 4-6 cups |
| Target | 64-80 oz | 8-10 cups |
| Active/Hot | 96-128 oz | 12-16 cups |

---

## Unit Conversions

```
1 fluid ounce = 0.0296 liters
1 cup = 8 fluid ounces
1 liter = 33.814 fluid ounces
Standard water bottle = 16-20 oz
```

---

## Educational Content (From Migration)

**Optimal Range**: 64-100 fluid ounces (8-12 cups) daily

**Quick Tips**:
- Start day with 16oz water
- Drink before/during/after exercise
- Keep reusable bottle handy
- Eat water-rich foods
- Monitor urine color (pale yellow ideal)
- Set reminders

---

## Chart Configuration

**Type**: Simple bar chart
**Primary Metric**: DISP_HYDRATION
**Periods Available**: hourly, daily, weekly, monthly
**Calculations**: SUM (total), AVG (average)

---

## Comparison with Protein (Complex Component)

| Feature | Hydration | Protein |
|---------|-----------|---------|
| Fields | 1 | 3 |
| Aggregations | 1 | 20+ |
| Type Breakdown | No | Yes (6 types) |
| Timing Breakdown | No | Yes (7 timings) |
| Chart Type | Simple bar | Stacked bar |
| Detail Screen | No | Yes (sections) |
| Complexity | ⭐ Simple | ⭐⭐⭐ Complex |

---

## Files Generated

1. `supabase/migrations/20251025_create_hydration_nutrition_component.sql` (309 lines)
2. `HYDRATION_COMPONENT_SUMMARY.md` (documentation)
3. `HYDRATION_STRUCTURE_DIAGRAM.txt` (visual diagram)
4. `HYDRATION_EXECUTION_SUMMARY.md` (execution guide)
5. `HYDRATION_QUICK_REFERENCE.md` (this file)

---

## Apply Commands (Quick Copy)

```bash
# Start Supabase
cd /Users/keegs/Documents/GitHub/WellPath-V2-Backend
supabase start

# Apply migration
supabase db reset

# Or direct apply
psql postgresql://postgres:postgres@127.0.0.1:54322/postgres \
  -f supabase/migrations/20251025_create_hydration_nutrition_component.sql
```

---

## Verify Commands (Quick Copy)

```sql
-- Quick verification
SELECT 
  (SELECT COUNT(*) FROM field_registry WHERE field_id = 'DEF_HYDRATION_OUNCES') as fields,
  (SELECT COUNT(*) FROM aggregation_metrics WHERE agg_id = 'AGG_HYDRATION_TOTAL') as aggs,
  (SELECT COUNT(*) FROM display_metrics WHERE metric_id = 'DISP_HYDRATION') as displays,
  (SELECT COUNT(*) FROM display_screens WHERE screen_id = 'SCREEN_HYDRATION') as screens;

-- Expected: fields=1, aggs=1, displays=1, screens=1
```

---

## Next Component Pattern

To build vegetables/fruits/legumes, add:
1. Type field (e.g., `DEF_VEGETABLES_TYPE`)
2. Type reference data (leafy_greens, cruciferous, etc.)
3. Type aggregations (one per type)
4. Timing field (`DEF_FOOD_TIMING`)
5. Timing aggregations (breakfast, lunch, dinner, etc.)
6. Detail screen with sections
7. Stacked bar chart

**But start with this hydration pattern first!**

---

## Troubleshooting

**Issue**: Migration fails
**Fix**: Check Docker is running, Supabase is started

**Issue**: No data showing in aggregations
**Fix**: Ensure patient_data_entries exist, run aggregation processor

**Issue**: Screen not appearing
**Fix**: Check display_screens.is_active = true

---

**Created**: 2025-10-25
**Pattern**: Simplest nutrition component
**Use Case**: Reference for building other components
