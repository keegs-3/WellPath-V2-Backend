# Added Sugar Component - Complete Database Structure

## Migration File
`supabase/migrations/20251025_create_added_sugar_nutrition_component.sql`

---

## 1. Data Entry Fields (field_registry)

| field_id | field_name | unit | field_type | reference_category |
|----------|------------|------|------------|--------------------|
| DEF_ADDED_SUGAR_GRAMS | added_sugar_grams | gram | quantity | - |
| DEF_ADDED_SUGAR_TYPE | added_sugar_type | - | reference | added_sugar_types |

---

## 2. Reference Data (data_entry_fields_reference)

| reference_key | display_name | description | color_hex |
|---------------|--------------|-------------|-----------|
| beverages | Beverages | Soda, juice, sweetened coffee/tea, energy drinks | #FF6B6B |
| desserts | Desserts | Candy, cookies, cake, ice cream, pastries | #FFB84D |
| sauces_condiments | Sauces/Condiments | Ketchup, BBQ sauce, salad dressing, marinades | #F9CA24 |
| snacks | Snacks | Granola bars, protein bars, sweetened yogurt, flavored nuts | #A29BFE |
| other | Other | Other sources of added sugar | #95A5A6 |
| uncategorized | Uncategorized | Entries without a specified source | #BDC3C7 |

---

## 3. Aggregation Metrics (aggregation_metrics)

### Main Total (1)
| agg_id | metric_name | output_unit |
|--------|-------------|-------------|
| AGG_ADDED_SUGAR_GRAMS | added_sugar_grams | gram |

### Timing Breakdown (6)
| agg_id | metric_name | output_unit |
|--------|-------------|-------------|
| AGG_ADDED_SUGAR_BREAKFAST_GRAMS | added_sugar_breakfast_grams | gram |
| AGG_ADDED_SUGAR_MORNING_SNACK_GRAMS | added_sugar_morning_snack_grams | gram |
| AGG_ADDED_SUGAR_LUNCH_GRAMS | added_sugar_lunch_grams | gram |
| AGG_ADDED_SUGAR_AFTERNOON_SNACK_GRAMS | added_sugar_afternoon_snack_grams | gram |
| AGG_ADDED_SUGAR_DINNER_GRAMS | added_sugar_dinner_grams | gram |
| AGG_ADDED_SUGAR_EVENING_SNACK_GRAMS | added_sugar_evening_snack_grams | gram |

### Source Breakdown (6)
| agg_id | metric_name | output_unit |
|--------|-------------|-------------|
| AGG_ADDED_SUGAR_TYPE_BEVERAGES | added_sugar_type_beverages | gram |
| AGG_ADDED_SUGAR_TYPE_DESSERTS | added_sugar_type_desserts | gram |
| AGG_ADDED_SUGAR_TYPE_SAUCES_CONDIMENTS | added_sugar_type_sauces_condiments | gram |
| AGG_ADDED_SUGAR_TYPE_SNACKS | added_sugar_type_snacks | gram |
| AGG_ADDED_SUGAR_TYPE_OTHER | added_sugar_type_other | gram |
| AGG_ADDED_SUGAR_TYPE_UNCATEGORIZED | added_sugar_type_uncategorized | gram |

---

## 4. Dependencies (aggregation_metrics_dependencies)

### Main Total
| agg_metric_id | data_entry_field_id | filter_conditions |
|---------------|---------------------|-------------------|
| AGG_ADDED_SUGAR_GRAMS | DEF_ADDED_SUGAR_GRAMS | NULL |

### Timing Dependencies (6)
All use `DEF_ADDED_SUGAR_GRAMS` with filter:
```json
{"reference_field": "DEF_FOOD_TIMING", "reference_value": "<timing>"}
```

| agg_metric_id | reference_value |
|---------------|-----------------|
| AGG_ADDED_SUGAR_BREAKFAST_GRAMS | breakfast |
| AGG_ADDED_SUGAR_MORNING_SNACK_GRAMS | morning_snack |
| AGG_ADDED_SUGAR_LUNCH_GRAMS | lunch |
| AGG_ADDED_SUGAR_AFTERNOON_SNACK_GRAMS | afternoon_snack |
| AGG_ADDED_SUGAR_DINNER_GRAMS | dinner |
| AGG_ADDED_SUGAR_EVENING_SNACK_GRAMS | evening_snack |

### Source Dependencies (6)
All use `DEF_ADDED_SUGAR_GRAMS` with filter:
```json
{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "<source>"}
```

| agg_metric_id | reference_value |
|---------------|-----------------|
| AGG_ADDED_SUGAR_TYPE_BEVERAGES | beverages |
| AGG_ADDED_SUGAR_TYPE_DESSERTS | desserts |
| AGG_ADDED_SUGAR_TYPE_SAUCES_CONDIMENTS | sauces_condiments |
| AGG_ADDED_SUGAR_TYPE_SNACKS | snacks |
| AGG_ADDED_SUGAR_TYPE_OTHER | other |
| AGG_ADDED_SUGAR_TYPE_UNCATEGORIZED | uncategorized |

---

## 5. Calculation Types (aggregation_metrics_calculation_types)

All 13 metrics have:
- **SUM** (for daily totals)
- **AVG** (for weekly/monthly averages)

**Total:** 26 calculation type mappings

---

## 6. Periods (aggregation_metrics_periods)

All 13 metrics support:
- hourly
- daily
- weekly
- monthly
- 6month
- yearly

**Total:** 78 period mappings (13 × 6)

---

## 7. Display Metrics (display_metrics)

| metric_id | metric_name | chart_type | is_primary |
|-----------|-------------|------------|------------|
| DISP_ADDED_SUGAR_GRAMS | Added Sugar | bar | true |
| DISP_ADDED_SUGAR_MEAL_TIMING | Added Sugar by Meal | bar_stacked | false |
| DISP_ADDED_SUGAR_SOURCE | Added Sugar by Source | bar_stacked | false |

---

## 8. Display Metric Aggregations (display_metrics_aggregations)

### DISP_ADDED_SUGAR_GRAMS (4)
| period_type | calculation_type | agg_metric_id |
|-------------|------------------|---------------|
| daily | SUM | AGG_ADDED_SUGAR_GRAMS |
| weekly | AVG | AGG_ADDED_SUGAR_GRAMS |
| monthly | AVG | AGG_ADDED_SUGAR_GRAMS |
| yearly | AVG | AGG_ADDED_SUGAR_GRAMS |

### DISP_ADDED_SUGAR_MEAL_TIMING (12)
- daily SUM for all 6 timing metrics
- weekly AVG for all 6 timing metrics

### DISP_ADDED_SUGAR_SOURCE (12)
- daily SUM for all 6 source metrics
- weekly AVG for all 6 source metrics

**Total:** 28 display aggregation mappings

---

## 9. Display Screens (display_screens)

| screen_id | name | pillar | icon | screen_type |
|-----------|------|--------|------|-------------|
| SCREEN_ADDED_SUGAR | Added Sugar | Healthful Nutrition | sugar | detailed |

---

## 10. Display Screen Detail (display_screens_detail)

| display_screen_id | title | subtitle | layout_type |
|-------------------|-------|----------|-------------|
| SCREEN_ADDED_SUGAR | Added Sugar Tracking | Monitor and reduce added sugar consumption | sections |

**Sections:**
1. `added_sugar_overview` - Total grams overview (metrics_grid)
2. `added_sugar_details` - Timing + source breakdown (metrics_detailed)

---

## 11. Display Screen Detail Metrics (display_screens_detail_display_metrics)

| section_id | metric_id | context_label | display_order |
|------------|-----------|---------------|---------------|
| added_sugar_overview | DISP_ADDED_SUGAR_GRAMS | Total Added Sugar | 1 |
| added_sugar_details | DISP_ADDED_SUGAR_MEAL_TIMING | Added Sugar by Meal | 1 |
| added_sugar_details | DISP_ADDED_SUGAR_SOURCE | Added Sugar by Source | 2 |

---

## Database Object Counts

| Object Type | Count |
|-------------|-------|
| Data Entry Fields | 2 |
| Reference Values | 6 |
| Aggregation Metrics | 13 |
| Dependencies | 13 |
| Calculation Types | 26 |
| Periods | 78 |
| Display Metrics | 3 |
| Display Aggregations | 28 |
| Display Screens | 1 |
| Display Screen Details | 1 |
| Screen Detail Metrics | 3 |
| **TOTAL OBJECTS** | **174** |

---

## SQL File Stats

- **File Size:** 26 KB
- **Total Lines:** 859
- **INSERT Statements:** 21
- **ON CONFLICT Handlers:** 21
- **Transaction Blocks:** 1 (BEGIN/COMMIT)
- **Sections:** 10
- **RAISE NOTICE Statements:** 40+

---

## Verification Queries

### Check Data Entry Fields
```sql
SELECT field_id, field_name, unit, field_type, reference_category
FROM field_registry
WHERE field_id LIKE 'DEF_ADDED_SUGAR%';
```

### Check Reference Data
```sql
SELECT reference_key, display_name, color_hex
FROM data_entry_fields_reference
WHERE reference_category = 'added_sugar_types'
ORDER BY sort_order;
```

### Check Aggregation Metrics
```sql
SELECT agg_id, metric_name, output_unit
FROM aggregation_metrics
WHERE agg_id LIKE 'AGG_ADDED_SUGAR%'
ORDER BY agg_id;
```

### Check Dependencies with Filters
```sql
SELECT agg_metric_id, data_entry_field_id, filter_conditions
FROM aggregation_metrics_dependencies
WHERE agg_metric_id LIKE 'AGG_ADDED_SUGAR%'
ORDER BY agg_metric_id;
```

### Check Display Metrics
```sql
SELECT metric_id, metric_name, chart_type_id, is_primary
FROM display_metrics
WHERE metric_id LIKE 'DISP_ADDED_SUGAR%';
```

### Check Display Aggregations
```sql
SELECT metric_id, agg_metric_id, period_type, calculation_type_id, display_order
FROM display_metrics_aggregations
WHERE metric_id LIKE 'DISP_ADDED_SUGAR%'
ORDER BY metric_id, period_type, display_order;
```

---

## Complete Implementation Checklist

- ✅ Data entry fields created (2)
- ✅ Reference data populated (6 sources)
- ✅ Main aggregation metric (1)
- ✅ Timing aggregations with filters (6)
- ✅ Source aggregations with filters (6)
- ✅ Dependencies configured with filter_conditions (13)
- ✅ Calculation types (SUM + AVG) (26)
- ✅ Periods (hourly to yearly) (78)
- ✅ Display metrics (primary + 2 breakdowns) (3)
- ✅ Display aggregation mappings (28)
- ✅ Primary screen created (1)
- ✅ Detail screen configured (1)
- ✅ Screen detail metrics linked (3)
- ✅ ON CONFLICT handlers for idempotency (21)
- ✅ Transaction wrapped (BEGIN/COMMIT)
- ✅ Summary output with RAISE NOTICE
- ✅ Follows protein pattern exactly
- ✅ Includes "Uncategorized" option
- ✅ Uses GRAMS as unit
- ✅ Compatible with existing aggregation system

---

**Status:** Production Ready ✅  
**Pattern:** Protein-based (grams + types + timing)  
**Date Created:** 2025-10-25
