# Added Sugar Component - Quick Reference Card

## File
`supabase/migrations/20251025_create_added_sugar_nutrition_component.sql`

## Data Entry
```
DEF_ADDED_SUGAR_GRAMS    - Main quantity field (grams)
DEF_ADDED_SUGAR_TYPE     - Sugar source (beverages, desserts, etc.)
DEF_FOOD_TIMING          - Meal timing (shared field)
```

## Sugar Sources (6)
1. **beverages** - Soda, juice, sweetened coffee/tea
2. **desserts** - Candy, cookies, cake, ice cream
3. **sauces_condiments** - Ketchup, BBQ sauce, dressing
4. **snacks** - Granola bars, sweetened yogurt
5. **other** - Other sources
6. **uncategorized** - No source specified ⚠️

## Aggregations (13)

### Main (1)
- `AGG_ADDED_SUGAR_GRAMS`

### By Timing (6)
- `AGG_ADDED_SUGAR_BREAKFAST_GRAMS`
- `AGG_ADDED_SUGAR_MORNING_SNACK_GRAMS`
- `AGG_ADDED_SUGAR_LUNCH_GRAMS`
- `AGG_ADDED_SUGAR_AFTERNOON_SNACK_GRAMS`
- `AGG_ADDED_SUGAR_DINNER_GRAMS`
- `AGG_ADDED_SUGAR_EVENING_SNACK_GRAMS`

### By Source (6)
- `AGG_ADDED_SUGAR_TYPE_BEVERAGES`
- `AGG_ADDED_SUGAR_TYPE_DESSERTS`
- `AGG_ADDED_SUGAR_TYPE_SAUCES_CONDIMENTS`
- `AGG_ADDED_SUGAR_TYPE_SNACKS`
- `AGG_ADDED_SUGAR_TYPE_OTHER`
- `AGG_ADDED_SUGAR_TYPE_UNCATEGORIZED`

## Display Metrics (3)
- `DISP_ADDED_SUGAR_GRAMS` - Primary (bar)
- `DISP_ADDED_SUGAR_MEAL_TIMING` - Stacked bar
- `DISP_ADDED_SUGAR_SOURCE` - Stacked bar

## Screens
- `SCREEN_ADDED_SUGAR` - Primary
- `SCREEN_ADDED_SUGAR_DETAIL` - Detail view

## Key Stats
- **Total Lines:** 859
- **Data Fields:** 2
- **Reference Values:** 6
- **Aggregations:** 13
- **Dependencies:** 13
- **Calc Types:** 26 (SUM + AVG)
- **Periods:** 78 (6 × 13)
- **Display Metrics:** 3
- **Display Aggs:** 28
- **Screens:** 2

## Unit
**GRAMS** (not servings)

## Filter Pattern
```json
// Timing
{"reference_field": "DEF_FOOD_TIMING", "reference_value": "breakfast"}

// Source
{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "beverages"}
```

## Migration Sections
1. Data Entry Fields
2. Reference Data
3. Aggregation Metrics
4. Dependencies
5. Calculation Types
6. Periods
7. Display Metrics
8. Display Metric Mappings
9. Display Screens
10. Detail Screen Links

## Status
✅ Complete
✅ Follows protein pattern
✅ Includes uncategorized option
✅ Ready for deployment
