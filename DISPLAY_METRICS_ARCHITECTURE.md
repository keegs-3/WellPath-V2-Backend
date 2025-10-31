# Display Metrics Architecture

## ✅ CORRECT 3-TIER STRUCTURE

```
┌─────────────────────────────────────────┐
│ PARENT METRIC (Main list item)         │  ← What user sees on tracked metrics list
│ e.g., "Protein"                         │
└──────────────┬──────────────────────────┘
               │
               ├──> 📑 SECTION 1: "By Meal Timing"      ← Drill-down tab 1
               │    └─> ◆ Breakfast (data series)
               │    └─> ◆ Lunch (data series)
               │    └─> ◆ Dinner (data series)
               │    ONE CHART with 3 stacked bars
               │
               ├──> 📑 SECTION 2: "By Type"             ← Drill-down tab 2
               │    └─> ◆ Lean Protein (data series)
               │    └─> ◆ Plant-Based (data series)
               │    └─> ◆ Fatty Fish (data series)
               │    ONE CHART with 3 stacked layers
               │
               └──> 📑 SECTION 3: "Quality Score"       ← Drill-down tab 3
                    └─> ◆ Protein Quality (data series)
                    └─> ◆ Amino Acid Score (data series)
                    ONE CHART with 2 lines
```

## 🎯 ARCHITECTURE RULES

### Rule 1: Parent Metric
- **ONE parent** per metric category (e.g., "Protein", "Sleep", "Water")
- Shows on main tracked metrics list
- Has aggregated value (total/average)
- Defined in: `parent_display_metrics`

### Rule 2: Sections (Max 3)
- **Maximum 3 sections** per parent (ideally 2-3, not 4+)
- Each section = ONE tab in the drill-down modal
- Each section = ONE chart visualization
- Defined in: `parent_detail_sections`

### Rule 3: Child Metrics (Data Series)
- **Multiple children** per section
- Each child = ONE data series on the chart (one bar, one line, one layer)
- Defined in: `child_display_metrics`

## 📊 DATABASE TABLES

### 1. `parent_display_metrics`
```sql
parent_metric_id      | parent_name | chart_type_id | supported_units
----------------------|-------------|---------------|----------------
DISP_PROTEIN_GRAMS    | Protein     | bar_vertical  | ["grams"]
DISP_SLEEP_ANALYSIS   | Sleep       | bar_vertical  | ["hours"]
DISP_WATER            | Water       | bar_vertical  | ["ml", "oz"]
```

### 2. `parent_detail_sections`
```sql
section_id                    | parent_metric_id   | section_name | section_chart_type_id | display_order
------------------------------|-------------------|--------------|----------------------|---------------
SECTION_PROTEIN_TIMING        | DISP_PROTEIN_GRAMS | By Meal      | bar_stacked          | 1
SECTION_PROTEIN_TYPE          | DISP_PROTEIN_GRAMS | By Type      | bar_stacked          | 2
SECTION_PROTEIN_QUALITY       | DISP_PROTEIN_GRAMS | Quality      | trend_line           | 3
```

### 3. `child_display_metrics`
```sql
child_metric_id                | parent_metric_id   | section_id            | child_name      | data_series_order
-------------------------------|-------------------|-----------------------|-----------------|-------------------
DISP_PROTEIN_BREAKFAST_GRAMS   | DISP_PROTEIN_GRAMS | SECTION_PROTEIN_TIMING | Breakfast       | 1
DISP_PROTEIN_LUNCH_GRAMS       | DISP_PROTEIN_GRAMS | SECTION_PROTEIN_TIMING | Lunch           | 2
DISP_PROTEIN_DINNER_GRAMS      | DISP_PROTEIN_GRAMS | SECTION_PROTEIN_TIMING | Dinner          | 3
```

## ❌ CURRENT PROBLEMS

### Problem 1: Too Many Sections
**Current Protein Sections:**
1. SECTION_PROTEIN_TIMING
2. SECTION_PROTEIN_TYPE
3. SECTION_PROTEIN_VARIETY
4. SECTION_PROTEIN_SOURCES ← **TOO MANY!**

**Solution:** Merge Type + Sources into ONE section, remove Variety

### Problem 2: Servings References
All protein metrics still reference `SERVINGS` instead of `GRAMS`:
- `DISP_PROTEIN_SERVINGS` → should be `DISP_PROTEIN_GRAMS`
- `SECTION_PROTEIN_*_SERVINGS` → should be `SECTION_PROTEIN_*_GRAMS`

### Problem 3: Sleep Parent Wrong
Sleep stages are individual parents instead of sections under "Sleep Analysis":

**Current (WRONG):**
```
DISP_DEEP_SLEEP_DURATION (parent)
DISP_CORE_SLEEP_DURATION (parent)
DISP_REM_SLEEP_DURATION (parent)
```

**Should Be:**
```
DISP_SLEEP_ANALYSIS (parent)
  └─> SECTION_SLEEP_STAGES
      ├─> Deep Sleep (child)
      ├─> Core Sleep (child)
      ├─> REM Sleep (child)
      └─> Awake Periods (child)
```

### Problem 4: "Source Type" Fields Confusion
Fields like `DEF_PROTEIN_TYPE` (lean/plant/fish) should aggregate into:
- ONE section: "By Type"
- ONE chart: Stacked bars
- Multiple data series: one per type

Not individual display metrics for each type.

## 🔧 PROPOSED FIXES

### Fix 1: Restructure Protein (GRAMS ONLY)

**Parent:**
- `DISP_PROTEIN_GRAMS` (rename from SERVINGS)

**Sections (limit to 3):**
1. **By Meal Timing** (`SECTION_PROTEIN_TIMING_GRAMS`)
   - Chart: Stacked bar (breakfast/lunch/dinner)
   - Children: DISP_PROTEIN_BREAKFAST_GRAMS, DISP_PROTEIN_LUNCH_GRAMS, DISP_PROTEIN_DINNER_GRAMS

2. **By Type** (`SECTION_PROTEIN_TYPE_GRAMS`)
   - Chart: Stacked bar (lean/plant/fish/red meat)
   - Children: DISP_PROTEIN_TYPE_LEAN, DISP_PROTEIN_TYPE_PLANT, etc.

3. **Quality Metrics** (`SECTION_PROTEIN_QUALITY`) [OPTIONAL]
   - Chart: Trend line
   - Children: Variety score, distribution score

### Fix 2: Restructure Sleep

**Parent:**
- `DISP_SLEEP_ANALYSIS` (total sleep duration)

**Sections (limit to 2):**
1. **Sleep Stages** (`SECTION_SLEEP_STAGES`)
   - Chart: Horizontal stacked bar (deep → core → REM → awake)
   - Children: DISP_DEEP_SLEEP, DISP_CORE_SLEEP, DISP_REM_SLEEP, DISP_AWAKE_PERIODS

2. **Sleep Quality** (`SECTION_SLEEP_QUALITY`) [OPTIONAL]
   - Chart: Trend line
   - Children: Sleep efficiency, sleep latency

## 📱 MOBILE APP MAPPING

### MetricDetailView.swift
```swift
// 1. Shows parent metric chart (main view)
ParentMetricBarChart(metric: parentMetric)

// 2. "Show More Data" button → opens modal

// 3. Modal shows sections as TABS
HorizontalTabBar(sections: sections)  // Max 3 tabs

// 4. Each tab shows ONE chart with multiple data series
SectionChartView(section: section, children: children)
```

### Query Flow
```
User taps "Protein"
  → Queries parent_display_metrics for DISP_PROTEIN_GRAMS
  → Shows main chart with AGG_PROTEIN_GRAMS aggregation

User taps "Show More"
  → Queries parent_detail_sections WHERE parent_metric_id = 'DISP_PROTEIN_GRAMS'
  → Gets 3 sections (Timing, Type, Quality)

User swipes to "By Type" tab
  → Queries child_display_metrics WHERE section_id = 'SECTION_PROTEIN_TYPE_GRAMS'
  → Gets children: Lean, Plant, Fish, Red Meat
  → Queries aggregations for each child
  → Shows ONE stacked bar chart with 4 layers
```

## 🎯 KEY INSIGHT

**The confusion happened because:**
1. We had separate `def_ref` tables (like `def_ref_protein_types`) that got migrated to data entry fields
2. Each protein type became its own field (`DEF_PROTEIN_TYPE_LEAN`, etc.)
3. Each field got its own aggregation (`AGG_PROTEIN_TYPE_LEAN_PROTEIN`, etc.)
4. We mistakenly created individual display metrics for each

**The fix:**
- Keep the individual aggregations (`AGG_PROTEIN_TYPE_LEAN_PROTEIN`, etc.)
- But group them under ONE section ("By Type")
- Each aggregation becomes a data series (child metric) in that ONE chart
- Not separate display metrics

## ✅ FINAL STRUCTURE EXAMPLE

```
📊 PARENT: Protein (84.2g total today)
   │
   ├─> 📑 SECTION: By Meal Timing
   │   │   Chart: Stacked Bar (3 segments per day)
   │   ├─> ◆ Breakfast: 28.4g
   │   ├─> ◆ Lunch: 32.6g
   │   └─> ◆ Dinner: 23.2g
   │
   ├─> 📑 SECTION: By Type
   │   │   Chart: Stacked Bar (4 segments per day)
   │   ├─> ◆ Lean Protein: 40.2g
   │   ├─> ◆ Plant-Based: 22.8g
   │   ├─> ◆ Fatty Fish: 15.6g
   │   └─> ◆ Red Meat: 5.6g
   │
   └─> 📑 SECTION: Quality
       │   Chart: Line Graph (trend over time)
       ├─> ◆ Variety Score: 8.2/10
       └─> ◆ Distribution: 7.8/10
```

---

**Next Steps:**
1. Create migration to rename PROTEIN_SERVINGS → PROTEIN_GRAMS
2. Consolidate protein sections from 4 → 3
3. Restructure sleep to use DISP_SLEEP_ANALYSIS as parent
4. Update mobile app to query correct structure
