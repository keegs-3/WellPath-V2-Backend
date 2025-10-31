# Tracked Metrics - Mobile Navigation Guide

**For**: Mobile Developer
**Date**: 2025-10-22
**Status**: Ready for Implementation

---

## Navigation Flow

```
Home/Dashboard
    ↓
Pillars Screen (7 WellPath Pillars)
    ↓
Display Screens (by Pillar)
    ↓
Parent Metric Screen (Main chart + "View Details")
    ↓
Child Metrics (Expanded under parent)
```

**Parent/Child Pattern**: Like Apple Health Sleep screen, parent metrics show the main chart with a "View Details" section that reveals related child metrics (breakdowns by meal, variety, alternative units, etc.).

---

## Screen 1: Pillars

**Route**: `/pillars` or `/tracking`

**Data Source**:
```swift
// Get all 7 pillars
SELECT DISTINCT pillar_name
FROM pillars_base
WHERE is_active = true
ORDER BY display_order
```

**UI Layout**:
- Grid or List of pillar cards
- Each card shows:
  - Pillar icon/color
  - Pillar name
  - Current score/percentage
  - Number of trackable metrics in that pillar

**The 7 Pillars**:
1. Healthful Nutrition
2. Movement + Exercise
3. Restorative Sleep
4. Cognitive Health
5. Stress Management
6. Connection + Purpose
7. Core Care

**Example Card**:
```
┌─────────────────────────┐
│  🥗 Healthful Nutrition │
│  Score: 97.8%           │
│  12 trackable metrics   │
│  Last entry: 2 hrs ago  │
└─────────────────────────┘
```

---

## Screen 2: Display Screens (within a Pillar)

**Route**: `/pillars/:pillar_name/screens`

**Data Source**:
```swift
// Get all display screens for a pillar
SELECT
  ds.screen_id,
  ds.screen_name,
  ds.screen_description,
  ds.display_order
FROM display_screens ds
WHERE ds.pillar_name = :pillar_name
  AND ds.is_active = true
ORDER BY ds.display_order
```

**UI Layout**:
- List of screen cards for that pillar
- Each screen represents a group of related metrics
- Show aggregated data or latest entry for each screen

**Example for "Healthful Nutrition" Pillar**:
```
┌─────────────────────────────────────┐
│  Fruits & Vegetables                │
│  Last entry: Today                  │
│  3.5 servings fruit, 4 veg       [>]│
├─────────────────────────────────────┤
│  Hydration                          │
│  Last entry: 2 hrs ago              │
│  64 fl oz water today            [>]│
├─────────────────────────────────────┤
│  Protein Intake                     │
│  Last entry: Yesterday              │
│  2 servings                      [>]│
└─────────────────────────────────────┘
```

**Alternative**: Show metrics directly instead of screens
```swift
// Skip screens, get metrics directly for a pillar
SELECT DISTINCT
  def.field_id,
  def.field_name,
  dm.pillar_name
FROM data_entry_fields def
JOIN display_metrics dm ON def.field_id = dm.field_id
WHERE dm.pillar_name = :pillar_name
  AND def.is_active = true
ORDER BY def.field_name
```

**Actions**:
- Tap screen → Navigate to metric detail (if screen has one metric)
- Tap screen → Show metric list (if screen has multiple metrics)

---

## Screen 3: Parent Metric Detail Screen

**Route**: `/tracked-metrics/:pillar/:parent_metric_id`

**This is the main screen with parent chart, "View Details", and expandable children!**

### Parent/Child Pattern (Apple Health Style)

**Query for Parent Metrics**:
```swift
// Get parent metrics for a pillar
SELECT
  parent_metric_id,
  parent_name,
  parent_description,
  pillar,
  supported_units,
  default_unit,
  expand_by_default,
  summary_display_mode,
  (SELECT COUNT(*) FROM child_display_metrics c
   WHERE c.parent_metric_id = p.parent_metric_id) as child_count
FROM parent_display_metrics p
WHERE pillar = :pillar_name
  AND is_active = true
ORDER BY display_order;
```

**Query for Child Metrics with Categories** (after tapping "View Details"):
```swift
// Get children grouped by category
SELECT
  child_metric_id,
  child_name,
  child_description,
  child_category,
  supported_units,
  default_unit,
  inherit_parent_unit,
  show_in_summary,
  display_order_in_category
FROM child_display_metrics
WHERE parent_metric_id = :parent_metric_id
  AND is_active = true
ORDER BY
  CASE child_category
    WHEN 'Meals' THEN 1
    WHEN 'Variety' THEN 2
    WHEN 'Plant-Based' THEN 3
    WHEN 'Alternative Units' THEN 4
    WHEN 'Quality' THEN 5
    WHEN 'Stages' THEN 6
    WHEN 'Percentages' THEN 7
    WHEN 'Sessions' THEN 8
    ELSE 9
  END,
  display_order_in_category;
```

### Top Section: Parent Metric with Current Value

**UI** (Parent Metric - e.g., Protein Servings):
```
┌─────────────────────────────────────┐
│  Protein Servings                   │
│  ════════════════════                │
│                                     │
│  Current: 3.5 servings              │
│  Last entry: Today, 2:30 PM         │
│                                     │
│  [Log New Entry]                    │
└─────────────────────────────────────┘
```

### Chart Section: Visualizations

**Data Source**:
```swift
// Get aggregations for this metric
SELECT
  agg_metric_id,
  period_type,
  calculation_type_id,
  value,
  period_start,
  period_end
FROM aggregation_results_cache arc
JOIN aggregation_metrics_dependencies amd
  ON arc.agg_metric_id = amd.agg_metric_id
WHERE arc.user_id = :user_id
  AND amd.data_entry_field_id = :field_id
ORDER BY period_end DESC
```

**Chart Configuration**:
```swift
// Get chart settings
SELECT
  chart_type,           -- 'bar', 'line', 'area'
  period_id,            -- 'daily', 'weekly', 'monthly'
  bars,                 -- number of bars to show
  days,                 -- days covered
  x_axis_granularity,   -- 'day', 'week', 'month'
  x_axis_label_values,  -- ['Mon', 'Tue', 'Wed', ...]
  y_axis_min,
  y_axis_max,
  y_axis_label
FROM aggregation_metrics_periods amp
JOIN aggregation_metrics_dependencies amd
  ON amp.agg_metric_id = amd.agg_metric_id
WHERE amd.data_entry_field_id = :field_id
```

**Chart Types**:

1. **Bar Chart** (default for most metrics)
   - X-axis: Time periods (last 7 days, 4 weeks, 6 months)
   - Y-axis: Metric value
   - Shows aggregated values (AVG, SUM, COUNT)

2. **Line Chart** (for continuous metrics like weight, sleep)
   - Trend over time
   - Optional: Show target range as shaded area

3. **Area Chart** (for cumulative metrics)
   - Same as line but filled below

**UI**:
```
┌─────────────────────────────────────┐
│  Last 7 Days                     [v]│ ← Period selector
│  ╔═══════════════════════════════╗  │
│  ║     ▄                         ║  │
│  ║   ▄ █ ▄                       ║  │
│  ║ ▄ █ █ █   ▄   ▄               ║  │
│  ║ █ █ █ █ ▄ █ ▄ █               ║  │
│  ╚═══════════════════════════════╝  │
│    M  T  W  T  F  S  S              │
│                                     │
│  Average: 3.5 servings              │
│  Goal: 5 servings                   │
└─────────────────────────────────────┘
```

**Period Selector** (dropdown):
- Last 7 Days (daily granularity)
- Last 4 Weeks (weekly granularity)
- Last 6 Months (monthly granularity)

### View Details Section: Child Metrics

**UI** (Between chart and about section):
```
┌─────────────────────────────────────┐
│  [▼ View Details]                   │ ← Expandable
└─────────────────────────────────────┘
```

**When expanded, shows child metrics grouped by category**:
```
┌─────────────────────────────────────┐
│  [▲ View Details]                   │
│  ────────────────────────────────   │
│  Meals                              │ ← child_category
│  • Breakfast: 1.5 servings       [>]│
│  • Lunch: 1.0 servings           [>]│
│  • Dinner: 2.0 servings          [>]│
│                                     │
│  Variety                            │ ← child_category
│  • Protein Variety: 4 sources    [>]│
│                                     │
│  Plant-Based                        │ ← child_category
│  • Plant-Based %: 40%            [>]│
│  • Plant-Based (g): 45g          [>]│
│                                     │
│  Alternative Units                  │ ← child_category
│  • g/kg body weight: 1.5 g/kg    [>]│
└─────────────────────────────────────┘
```

**Child Categories** (from `child_category` column):
- **Meals**: Breakfast, Lunch, Dinner breakdowns
- **Variety**: Source counts, variety metrics
- **Plant-Based**: Plant-based specific metrics
- **Alternative Units**: g/kg, grams when parent is servings
- **Quality**: Efficiency, latency metrics (sleep)
- **Stages**: Sleep stages (Deep, REM, Core, Awake)
- **Percentages**: Percentage breakdowns
- **Sessions**: Session counts

Each child metric is tappable and leads to its own detail view with chart and data entry.

### Stats Section: Parent Summary Statistics

**Data Source**: Same as chart (aggregation_results_cache)

**UI**:
```
┌─────────────────────────────────────┐
│  Statistics (Last 30 Days)          │
│  ────────────────────────────────   │
│  Average:      3.5 servings         │
│  Highest:      5 servings (Oct 15)  │
│  Lowest:       2 servings (Oct 3)   │
│  Total Days:   28/30 tracked        │
└─────────────────────────────────────┘
```

### History Section: All Entries

**Data Source**:
```swift
// Get all entries for this metric
SELECT
  entry_date,
  value_quantity,
  value_unit,
  value_reference,  -- optional: type/source info
  notes
FROM patient_data_entries
WHERE user_id = :user_id
  AND field_id = :field_id
ORDER BY entry_date DESC
LIMIT 30
```

**UI**:
```
┌─────────────────────────────────────┐
│  History                         [+]│
│  ────────────────────────────────   │
│  Today, 2:30 PM                     │
│  3.5 servings                       │
│  Notes: Apple, banana, berries      │
│                                     │
│  Yesterday, 1:00 PM                 │
│  4 servings                         │
│                                     │
│  Oct 20, 8:00 AM                    │
│  2 servings                    [Edit]│
└─────────────────────────────────────┘
```

**Actions**:
- Tap [+] → Add new entry
- Tap entry → Edit/delete
- Swipe left → Quick delete

---

## Data Entry Modal/Screen

**Triggered from**:
- Metric list screen (quick entry)
- Detail screen (main entry)

**Input Types** (from `data_entry_fields.input_type`):

1. **Numeric** (`value_quantity`)
   - Number picker or text field
   - Shows unit (servings, hours, kg, etc.)

2. **Single Select** (`value_reference`)
   - Picker/dropdown from reference table
   - Example: Food Type → ['Apple', 'Banana', 'Berries']

3. **Multi Select** (`value_reference` - comma separated)
   - Multiple checkboxes
   - Example: Sleep Factors → ['Caffeine', 'Screen Time', 'Stress']

4. **Duration** (`value_duration`)
   - Time picker (hours/minutes)
   - Example: Cardio Duration → 45 minutes

5. **Date/Time**
   - Default: Current date/time
   - Allow editing

6. **Notes** (optional)
   - Text field for additional context

**UI Example** (Fruit entry):
```
┌─────────────────────────────────────┐
│  Log Fruit Servings                 │
│  ════════════════════                │
│                                     │
│  Servings:     [  3.5  ] servings   │
│                                     │
│  Type (optional):                   │
│  [ ] Apple                          │
│  [ ] Banana                         │
│  [x] Berries                        │
│  [ ] Other                          │
│                                     │
│  Date: Today, 2:30 PM          [Edit]│
│                                     │
│  Notes:                             │
│  [                              ]   │
│                                     │
│  [Cancel]              [Save Entry] │
└─────────────────────────────────────┘
```

---

## Key Database Tables for Mobile

### `data_entry_fields`
- `field_id` - Unique identifier
- `field_name` - Display name
- `category` - For grouping metrics
- `input_type` - How user enters data
- `default_unit` - Unit to display
- `field_type` - numeric, reference, duration, etc.

### `patient_data_entries`
- User's tracked data
- Links to `field_id`
- Contains `value_quantity`, `value_reference`, `value_duration`, etc.

### `aggregation_results_cache`
- Pre-calculated aggregations (AVG, SUM, MAX, MIN, COUNT)
- Different periods (daily, weekly, monthly)
- Powers the charts

### `aggregation_metrics_periods`
- Chart configuration (type, period, axis settings)
- Use this to know what kind of chart to show

### Reference Tables (for dropdowns)
- `cardio_types`, `food_types`, `protein_types`, etc.
- Linked via `data_entry_fields.reference_table`

---

## Apple Pattern: Three-Screen Approach

Following Apple Health/Fitness app patterns:

1. **Browse** → Pillars (7 WellPath pillars with scores)
2. **Select** → Display Screens within pillar (grouped metrics)
3. **Detail** → Charts, history, entry for specific metric

**Pro tip**: Support pull-to-refresh on all list screens to sync latest data!

**Hierarchy**:
```
Pillars (7)
  └─ Display Screens (multiple per pillar)
      └─ Metrics (trackable data points)
          └─ Detail View (chart + entry)
```

---

---

## Parent/Child Metric Examples

We've configured 19 parent metrics across pillars. Here are the key examples:

### Healthful Nutrition (10 parents)

**Protein Servings** (8 children):
- Meals: Breakfast, Lunch, Dinner
- Variety: Protein Variety
- Plant-Based: Percentage, Grams
- Alternative Units: Grams, g/kg body weight

**Fruit Servings** (6 children):
- Meals: Breakfast, Lunch, Dinner
- Variety: Fruit Variety, Source Count, Sources

**Fiber Servings** (7 children):
- Meals: Breakfast, Lunch, Dinner
- Alternative Unit: Grams
- Variety: Source Count, Source Variety, Sources

**Other Nutrition Parents**:
- Legume Servings (6 children)
- Added Sugar Servings (4 children)
- Healthy Fat Usage (9 children)
- Processed Meat Serving (3 children)
- Plant-Based Meal (3 children)
- Mindful Eating Episodes (3 children)
- Large Meals (3 children)

### Movement + Exercise (8 parents)

**Cardio Duration** (2 children):
- Cardio Sessions
- Calories

**Post Meal Activity Duration** (8 children):
- Sessions total and by meal (Breakfast, Lunch, Dinner)
- Exercise Snacks total and by meal (Breakfast, Lunch, Dinner)

**Other Exercise Parents**:
- HIIT Duration → Sessions
- Mobility Duration → Sessions
- Strength Training Duration → Sessions
- Zone 2 Cardio Duration → Sessions
- Exercise Snacks → Exercise Snack
- Sedentary Time → Sessions, Period

### Restorative Sleep (1 parent)

**Total Sleep Duration** (15 children):
- Stages: Deep, Core, REM, Awake (duration)
- Percentages: Deep %, Core %, REM %, Awake %
- Quality: Sleep Efficiency, Sleep Latency, Awake Episode Count
- Consistency: Sleep Time Consistency, Wake Time Consistency
- Other: Time In Bed, Sleep Sessions

---

## Implementation Guidelines

### Query Pattern
```swift
// 1. Get parent metrics for a pillar
SELECT * FROM display_metrics
WHERE pillar = :pillar AND parent_metric_id IS NULL

// 2. Show parent with main chart
// ... display parent metric detail screen ...

// 3. On "View Details" tap, get children
SELECT * FROM display_metrics
WHERE parent_metric_id = :parent_metric_id
ORDER BY display_order

// 4. Each child is tappable → shows child's detail screen
```

### UI Hierarchy
- **Display Screen** (e.g., "Protein & Nutrition") lists only parent metrics
- **Parent Detail** shows main chart + "View Details" button
- **View Details** expands to show child metrics (organized by type)
- **Child Detail** full chart view for specific breakdown

### Benefits
- Reduces navigation depth (7 pillars → ~3 screens → ~50 parents vs 216+ metrics)
- Matches Apple Health pattern (familiar to users)
- Allows detailed exploration without overwhelming main views
- Easy to track both totals and breakdowns

---

## Next Steps for Mobile Dev

1. ✅ Build navigation structure (4 levels with parent/child)
2. ✅ Query parent metrics only for display screens
3. ✅ Build parent detail screen with "View Details" section
4. ✅ Implement expandable child metrics list
5. ✅ Build child detail screens with charts
6. ✅ Implement data entry modal with dynamic inputs
7. ✅ Connect to aggregation API for chart data
8. ✅ Add pull-to-refresh and real-time updates

**Questions?** Check the database schema or ask! All the chart configs, aggregations, and parent/child relationships are set up. 🎉
