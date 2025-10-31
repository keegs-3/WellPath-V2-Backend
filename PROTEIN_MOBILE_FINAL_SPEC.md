# Protein Screen - Final Mobile Specification

## ✅ Complete Configuration

**Test User:** test.patient.21@wellpath.com
**Patient ID:** `8b79ce33-02b8-4f49-8268-3204130efa82`
**Data:** 46 days, 155 protein logs, 11,788 aggregations calculated

---

## Primary Screen

### Query:
```sql
GET /rest/v1/display_screens_primary?display_screen_id=eq.SCREEN_PROTEIN
  &select=title,subtitle,description,detail_button_text,about_content,longevity_impact,quick_tips
```

### Layout:
```
┌─────────────────────────────────────┐
│  🥩 Protein Intake                  │
│  Track protein grams, servings...   │
├─────────────────────────────────────┤
│  Featured Metric Chart              │
│  (DISP_PROTEIN_GRAMS - daily total) │
│  ▮▮▮▮▮▮▮▮▮▮▮ 145g                  │
│  ▮▮▮▮▮▮▮▮▮   132g                  │
│  ▮▮▮▮▮▮▮▮▮▮▮▮ 156g                 │
│  Oct 24  Oct 23  Oct 22             │
│                                     │
│  [View More Protein Data →]         │ ← Almost touching bottom of chart
├─────────────────────────────────────┤
│  ▼ About Protein                    │ ← Accordion (expandable)
└─────────────────────────────────────┘
```

### About Protein Accordion (3 sections):

#### 1. About
**Field:** `about_content`
```
Protein is essential for building and repairing tissues, making enzymes and hormones,
and supporting immune function. It provides the amino acids your body needs to maintain
muscle mass, produce neurotransmitters, and create antibodies. Adequate protein intake
is crucial for healthy aging, wound healing, and maintaining metabolic health.
```

#### 2. Impact on Longevity
**Field:** `longevity_impact`
```
Higher protein intake, especially from plant sources, is associated with increased
longevity and reduced mortality risk. Adequate protein helps preserve muscle mass
as you age (sarcopenia prevention), supports bone density, maintains cognitive function,
and promotes metabolic health. Studies show that consuming 1.2-1.6 g/kg body weight
daily is optimal for healthy aging, with emphasis on leucine-rich sources for muscle
protein synthesis.
```

#### 3. Quick Tips
**Field:** `quick_tips` (array of 7 tips)
```
• Aim for 20-40g protein per meal to maximize muscle protein synthesis
• Spread intake evenly across meals - don't load it all in one sitting
• Include protein within 2 hours post-workout for optimal recovery
• Prioritize lean sources: fish, poultry, legumes, low-fat dairy
• Plant proteins are highly effective when varied (beans + grains)
• Fatty fish provide bonus omega-3s for brain and heart health
• Morning protein improves satiety and helps maintain stable blood sugar
```

---

## Detail Screen (3 Tabs)

### Query Tab Configuration:
```sql
GET /rest/v1/display_screens_detail?display_screen_id=eq.SCREEN_PROTEIN
  &select=title,subtitle,layout_type,tab_config
```

**Response:**
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

---

### Tab 1: By Meal

**Chart Type:** Grouped bars (3 bars per x-axis point)
**Metric:** `DISP_PROTEIN_MEAL_TIMING`

#### Data Query:
```sql
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.8b79ce33-02b8-4f49-8268-3204130efa82
  &agg_metric_id=in.(AGG_PROTEIN_BREAKFAST_GRAMS,AGG_PROTEIN_LUNCH_GRAMS,AGG_PROTEIN_DINNER_GRAMS)
  &period_type=eq.daily
  &calculation_type_id=eq.SUM
  &period_start=gte.2025-10-18
  &select=period_start,agg_metric_id,value
  &order=period_start.desc
```

#### Chart Rendering (Swift):
```
For each date:
  - 3 bars side by side (grouped, not stacked)
  - Same x-axis, different colors
  - Bottom bar: Breakfast (#FFA726)
  - Middle bar: Lunch (#FF8A50)
  - Top bar: Dinner (#FF6D3A)
```

**Colors:** Use 3 shades of your pillar color (healthful nutrition)

---

### Tab 2: By Type

**Chart Type:** Stacked bars with legend at bottom
**Metric:** `DISP_PROTEIN_TYPE`

#### Data Query:
```sql
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.8b79ce33-02b8-4f49-8268-3204130efa82
  &agg_metric_id=in.(AGG_PROTEIN_TYPE_FATTY_FISH,AGG_PROTEIN_TYPE_LEAN_PROTEIN,AGG_PROTEIN_TYPE_PLANT_BASED,AGG_PROTEIN_TYPE_PROCESSED_MEAT,AGG_PROTEIN_TYPE_RED_MEAT,AGG_PROTEIN_TYPE_SUPPLEMENT)
  &period_type=eq.daily
  &calculation_type_id=eq.SUM
  &period_start=gte.2025-10-18
  &select=period_start,agg_metric_id,value
  &order=period_start.desc
```

#### Chart Rendering (Swift):
```
For each date:
  - One stacked bar showing all 6 types
  - Hide types with 0 value
  - Legend at bottom showing:
    □ Fatty Fish (#0288D1)
    □ Lean Protein (#66BB6A)
    □ Plant-Based (#8BC34A)
    □ Red Meat (#E53935)
    □ Processed Meat (#FF7043) - if > 0
    □ Supplement (#AB47BC) - if > 0
```

---

### Tab 3: Ratio

**Chart Type:** Line chart with optimal range overlay
**Metric:** `DISP_PROTEIN_PER_KG`
**Toggle:** g/kg ↔ g/lb

#### Data Query (g/kg):
```sql
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.8b79ce33-02b8-4f49-8268-3204130efa82
  &agg_metric_id=eq.AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT
  &period_type=eq.daily
  &calculation_type_id=eq.AVG
  &period_start=gte.2025-10-01
  &select=period_start,value
  &order=period_start.asc
```

#### Chart Rendering (Swift):

**For g/kg view:**
```
Line chart with:
  - Y-axis: 0.8 to 2.0 g/kg
  - Optimal range: 1.2 - 1.6 g/kg
    - Dotted horizontal lines at 1.2 and 1.6 (pillar color #FF8A50)
    - Semi-transparent blue fill between (#4FC3F7 at 20% opacity)
  - User's data: Line connecting daily values
```

**For g/lb view (when toggled):**
```
Same chart but:
  - Y-axis: 0.4 to 1.0 g/lb
  - Optimal range: 0.54 - 0.73 g/lb
  - Same styling
```

**Formula for conversion:**
```
g/lb = g/kg × 0.453592
```

**⚠️ Note:** Test user currently shows 0 because no weight data exists. This is expected. Chart will show proper data once weight is logged.

---

## Color Palette Summary

### By Meal (Pillar gradient):
- Breakfast: `#FFA726` (lighter orange)
- Lunch: `#FF8A50` (medium orange)
- Dinner: `#FF6D3A` (darker orange)

### By Type:
- Fatty Fish: `#0288D1` (deep blue - omega-3s)
- Lean Protein: `#66BB6A` (green - healthy)
- Plant-Based: `#8BC34A` (light green - plants)
- Red Meat: `#E53935` (red - caution)
- Processed Meat: `#FF7043` (orange-red - warning)
- Supplement: `#AB47BC` (purple - supplemental)

### Ratio Chart:
- Optimal range lines: `#FF8A50` (pillar color, dashed)
- Optimal range fill: `#4FC3F7` (blue, 20% opacity)
- User data line: Your primary accent color

---

## API Quick Reference

```bash
# Primary screen with accordion content
GET /rest/v1/display_screens_primary
  ?display_screen_id=eq.SCREEN_PROTEIN
  &select=title,subtitle,description,detail_button_text,about_content,longevity_impact,quick_tips

# Detail screen tab configuration
GET /rest/v1/display_screens_detail
  ?display_screen_id=eq.SCREEN_PROTEIN
  &select=title,subtitle,tab_config

# Tab metrics mapping
GET /rest/v1/display_screens_detail_display_metrics
  ?detail_screen_id=eq.SCREEN_PROTEIN_DETAIL
  &select=metric_id,section_id,display_order

# Display metric aggregation mappings
GET /rest/v1/display_metrics_aggregations
  ?metric_id=in.(DISP_PROTEIN_MEAL_TIMING,DISP_PROTEIN_TYPE,DISP_PROTEIN_PER_KG)
  &select=metric_id,agg_metric_id,period_type,calculation_type_id

# Actual data (by meal)
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<uuid>
  &agg_metric_id=in.(AGG_PROTEIN_BREAKFAST_GRAMS,AGG_PROTEIN_LUNCH_GRAMS,AGG_PROTEIN_DINNER_GRAMS)
  &period_type=eq.daily
  &calculation_type_id=eq.SUM
  &period_start=gte.<date>

# Actual data (by type)
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<uuid>
  &agg_metric_id=in.(AGG_PROTEIN_TYPE_FATTY_FISH,AGG_PROTEIN_TYPE_LEAN_PROTEIN,AGG_PROTEIN_TYPE_PLANT_BASED,AGG_PROTEIN_TYPE_PROCESSED_MEAT,AGG_PROTEIN_TYPE_RED_MEAT,AGG_PROTEIN_TYPE_SUPPLEMENT)
  &period_type=eq.daily
  &calculation_type_id=eq.SUM
  &period_start=gte.<date>

# Actual data (ratio)
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<uuid>
  &agg_metric_id=eq.AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT
  &period_type=eq.daily
  &calculation_type_id=eq.AVG
  &period_start=gte.<date>
```

---

## ✅ Ready for Swift Implementation

Everything is configured and ready:
- ✅ 46 days of test data
- ✅ Primary screen with accordion content
- ✅ Detail screen with 3 tabs
- ✅ All aggregations calculated
- ✅ Education content populated
- ✅ Chart specifications provided

Mobile team has full autonomy over chart rendering in Swift. Backend provides the data structure and content, you handle the visual presentation.
