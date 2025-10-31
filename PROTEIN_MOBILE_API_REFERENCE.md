# Protein Mobile API Reference

Clean API reference for fetching protein screen data. All UI/presentation handled in Swift.

---

## Primary Screen Data

### Query:
```
GET /rest/v1/display_screens_primary?display_screen_id=eq.SCREEN_PROTEIN
```

### Response Fields:
```json
{
  "title": "Protein Intake",
  "subtitle": null,
  "description": "Track protein grams, servings, and variety",
  "about_content": "Protein is essential for building and repairing tissues...",
  "longevity_impact": "Higher protein intake, especially from plant sources...",
  "quick_tips": [
    "Aim for 20-40g protein per meal to maximize muscle protein synthesis",
    "Spread intake evenly across meals - don't load it all in one sitting",
    ...
  ]
}
```

### Featured Metric Data:
```
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<uuid>
  &agg_metric_id=eq.AGG_PROTEIN_GRAMS
  &period_type=eq.daily
  &calculation_type_id=eq.SUM
  &period_start=gte.<start_date>
  &select=period_start,value
  &order=period_start.desc
```

---

## Detail Screen Configuration

### Query:
```
GET /rest/v1/display_screens_detail?display_screen_id=eq.SCREEN_PROTEIN
```

### Response Fields:
```json
{
  "title": "Protein Tracking",
  "subtitle": "Optimize your protein intake",
  "layout_type": "tabs",
  "tab_config": [
    {
      "tab_id": "by_meal",
      "tab_title": "By Meal",
      "tab_icon": "clock",
      "display_order": 1
    },
    {
      "tab_id": "by_type",
      "tab_title": "By Type",
      "tab_icon": "list.bullet",
      "display_order": 2
    },
    {
      "tab_id": "ratio",
      "tab_title": "Ratio",
      "tab_icon": "chart.line.uptrend.xyaxis",
      "display_order": 3,
      "optimal_range_gkg": {"min": 1.2, "max": 1.6},
      "optimal_range_glb": {"min": 0.54, "max": 0.73}
    }
  ]
}
```

### Get Metrics for Each Tab:
```
GET /rest/v1/display_screens_detail_display_metrics
  ?detail_screen_id=eq.SCREEN_PROTEIN_DETAIL
  &select=metric_id,section_id,display_order
```

Returns:
```json
[
  {"metric_id": "DISP_PROTEIN_MEAL_TIMING", "section_id": "by_meal", "display_order": 1},
  {"metric_id": "DISP_PROTEIN_TYPE", "section_id": "by_type", "display_order": 1},
  {"metric_id": "DISP_PROTEIN_PER_KG", "section_id": "ratio", "display_order": 1}
]
```

---

## Tab 1: By Meal

### Tab Education Content:
```
GET /rest/v1/display_metrics?metric_id=eq.DISP_PROTEIN_MEAL_TIMING
  &select=metric_name,about_content,longevity_impact,quick_tips
```

Returns tab-specific accordion content about protein timing.

### Chart Data:
```
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<uuid>
  &agg_metric_id=in.(AGG_PROTEIN_BREAKFAST_GRAMS,AGG_PROTEIN_LUNCH_GRAMS,AGG_PROTEIN_DINNER_GRAMS)
  &period_type=eq.daily
  &calculation_type_id=eq.SUM
  &period_start=gte.<start_date>
  &select=period_start,agg_metric_id,value
  &order=period_start.desc
```

**Chart Type (Swift):** 3 grouped bars per x-axis point
- Breakfast, Lunch, Dinner
- Use pillar color gradient (#FFA726, #FF8A50, #FF6D3A)

---

## Tab 2: By Type

### Tab Education Content:
```
GET /rest/v1/display_metrics?metric_id=eq.DISP_PROTEIN_TYPE
  &select=metric_name,about_content,longevity_impact,quick_tips
```

Returns tab-specific accordion content about protein sources.

### Chart Data:
```
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<uuid>
  &agg_metric_id=in.(AGG_PROTEIN_TYPE_FATTY_FISH,AGG_PROTEIN_TYPE_LEAN_PROTEIN,AGG_PROTEIN_TYPE_PLANT_BASED,AGG_PROTEIN_TYPE_PROCESSED_MEAT,AGG_PROTEIN_TYPE_RED_MEAT,AGG_PROTEIN_TYPE_SUPPLEMENT)
  &period_type=eq.daily
  &calculation_type_id=eq.SUM
  &period_start=gte.<start_date>
  &select=period_start,agg_metric_id,value
  &order=period_start.desc
```

**Chart Type (Swift):** Stacked bars with legend
- Hide segments with value = 0
- Legend: Fatty Fish, Lean Protein, Plant-Based, Red Meat, Processed Meat, Supplement

---

## Tab 3: Ratio

### Tab Education Content:
```
GET /rest/v1/display_metrics?metric_id=eq.DISP_PROTEIN_PER_KG
  &select=metric_name,about_content,longevity_impact,quick_tips
```

Returns tab-specific accordion content about protein-to-bodyweight ratios.

### Chart Data:
```
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<uuid>
  &agg_metric_id=eq.AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT
  &period_type=eq.daily
  &calculation_type_id=eq.AVG
  &period_start=gte.<start_date>
  &select=period_start,value
  &order=period_start.asc
```

**Chart Type (Swift):** Line chart with optimal range overlay
- g/kg toggle to g/lb (conversion: g/lb = g/kg × 0.453592)
- Optimal ranges from `tab_config`:
  - g/kg: 1.2 - 1.6 (dotted lines, semi-transparent fill)
  - g/lb: 0.54 - 0.73

**Note:** Test user shows 0 (no weight data). Expected behavior.

---

## Complete Example Flow

```swift
// 1. Fetch primary screen config
let primary = await supabase
  .from("display_screens_primary")
  .select()
  .eq("display_screen_id", "SCREEN_PROTEIN")
  .single()

// 2. Show accordion with:
//    - About: primary.about_content
//    - Impact: primary.longevity_impact
//    - Tips: primary.quick_tips (array)

// 3. Fetch detail screen config
let detail = await supabase
  .from("display_screens_detail")
  .select()
  .eq("display_screen_id", "SCREEN_PROTEIN")
  .single()

// 4. Create tabs from detail.tab_config (3 tabs)

// 5. For each tab, fetch metric ID
let tabMetrics = await supabase
  .from("display_screens_detail_display_metrics")
  .select("metric_id, section_id")
  .eq("detail_screen_id", "SCREEN_PROTEIN_DETAIL")

// 6. For active tab, fetch education content
let metric = await supabase
  .from("display_metrics")
  .select("about_content, longevity_impact, quick_tips")
  .eq("metric_id", tabMetrics.metric_id)
  .single()

// 7. Show tab accordion with metric.about_content, etc.

// 8. Fetch aggregation data for chart
let data = await supabase
  .from("aggregation_results_cache")
  .select("period_start, agg_metric_id, value")
  .eq("patient_id", userId)
  .in("agg_metric_id", [/* based on tab */])
  ...

// 9. Render chart in Swift
```

---

## Test User

**Email:** test.patient.21@wellpath.com
**ID:** `8b79ce33-02b8-4f49-8268-3204130efa82`
**Data:** 46 days, 155 protein logs, fully calculated aggregations

---

## Summary

**Backend provides:**
- Screen configurations (titles, tabs)
- Education content (about, longevity impact, quick tips)
- Aggregated data (calculated values by period)
- Optimal ranges (for ratio chart)

**Swift handles:**
- All UI/UX (buttons, navigation, transitions)
- Chart rendering (grouping, stacking, legends, colors)
- Unit conversions (g/kg ↔ g/lb)
- Accordion interactions

Clean separation of concerns. Backend = data, Swift = presentation.
