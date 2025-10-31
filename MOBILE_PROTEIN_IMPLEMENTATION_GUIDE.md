# Mobile Protein Implementation Guide

## Overview
This guide provides step-by-step instructions for implementing the Protein tracking screens in the WellPath mobile app.

---

## Architecture Flow

```
User Input → patient_data_entries → Trigger → Edge Function →
Aggregation Calculation → aggregation_results_cache → Mobile Display
```

---

## Part 1: Data Entry (Logging Protein)

### API Endpoint
`POST /rest/v1/patient_data_entries`

### Required Fields
When a user logs protein intake, create **3 separate rows** in `patient_data_entries`:

#### Row 1: Protein Grams (Quantity)
```json
{
  "patient_id": "<uuid>",
  "field_id": "DEF_PROTEIN_GRAMS",
  "value_quantity": 25.0,
  "entry_date": "2025-10-24",
  "entry_timestamp": "2025-10-24T08:30:00Z",
  "source": "manual"
}
```

#### Row 2: Protein Type (Reference)
```json
{
  "patient_id": "<uuid>",
  "field_id": "DEF_PROTEIN_TYPE",
  "value_reference": "<uuid_from_reference_table>",
  "entry_date": "2025-10-24",
  "entry_timestamp": "2025-10-24T08:30:00Z",
  "source": "manual"
}
```

#### Row 3: Protein Timing (Reference)
```json
{
  "patient_id": "<uuid>",
  "field_id": "DEF_PROTEIN_TIMING",
  "value_reference": "<uuid_from_reference_table>",
  "entry_date": "2025-10-24",
  "entry_timestamp": "2025-10-24T08:30:00Z",
  "source": "manual"
}
```

### Getting Reference UUIDs

#### For Protein Types:
```sql
GET /rest/v1/data_entry_fields_reference
  ?reference_category=eq.protein_types
  &is_active=eq.true
  &select=id,reference_key,display_name,sort_order
  &order=sort_order
```

**Available protein types:**
- `cottage_cheese` - Cottage Cheese
- `eggs` - Eggs
- `fatty_fish` - Fatty Fish (salmon, mackerel)
- `fish` - Fish
- `greek_yogurt` - Greek Yogurt
- `lean_beef` - Lean Beef
- `lean_poultry` - Lean Poultry (chicken, turkey)
- `lean_protein` - Lean Protein (general)
- `plant_based` - Plant-Based Protein
- `plant_protein` - Plant Protein (legacy)
- `processed_meat` - Processed Meat
- `protein_powder_plant` - Plant-Based Protein Powder
- `protein_powder_whey` - Whey Protein Powder
- `red_meat` - Red Meat
- `seitan` - Seitan
- `supplement` - Protein Supplement
- `tempeh` - Tempeh
- `tofu` - Tofu

#### For Protein Timing:
```sql
GET /rest/v1/data_entry_fields_reference
  ?reference_category=eq.protein_timing
  &is_active=eq.true
  &select=id,reference_key,display_name,sort_order
  &order=sort_order
```

**Available timing options:**
- `breakfast` - Breakfast
- `lunch` - Lunch
- `dinner` - Dinner
- `morning_snack` - Morning Snack
- `afternoon_snack` - Afternoon Snack
- `evening_snack` - Evening Snack
- `other` - Other

### Example: Complete Protein Entry

User logs: "25g Greek Yogurt at Breakfast (8:30 AM)"

1. **First, get the reference UUIDs** (cache these in the app):
```
GET /rest/v1/data_entry_fields_reference?reference_category=eq.protein_types&reference_key=eq.greek_yogurt
→ Returns: { id: "uuid-1234", display_name: "Greek Yogurt", ... }

GET /rest/v1/data_entry_fields_reference?reference_category=eq.protein_timing&reference_key=eq.breakfast
→ Returns: { id: "uuid-5678", display_name: "Breakfast", ... }
```

2. **Then, create 3 entries**:
```json
POST /rest/v1/patient_data_entries
[
  {
    "patient_id": "8b79ce33-02b8-4f49-8268-3204130efa82",
    "field_id": "DEF_PROTEIN_GRAMS",
    "value_quantity": 25,
    "entry_date": "2025-10-24",
    "entry_timestamp": "2025-10-24T08:30:00Z",
    "source": "manual"
  },
  {
    "patient_id": "8b79ce33-02b8-4f49-8268-3204130efa82",
    "field_id": "DEF_PROTEIN_TYPE",
    "value_reference": "uuid-1234",
    "entry_date": "2025-10-24",
    "entry_timestamp": "2025-10-24T08:30:00Z",
    "source": "manual"
  },
  {
    "patient_id": "8b79ce33-02b8-4f49-8268-3204130efa82",
    "field_id": "DEF_PROTEIN_TIMING",
    "value_reference": "uuid-5678",
    "entry_date": "2025-10-24",
    "entry_timestamp": "2025-10-24T08:30:00Z",
    "source": "manual"
  }
]
```

3. **Backend automatically triggers**:
   - Edge function `run-instance-calculations` processes the entries
   - Aggregations are calculated
   - Results stored in `aggregation_results_cache`
   - Data becomes available immediately for display

---

## Part 2: Display Screens

### Step 1: Fetch Screen Configuration

#### Primary Screen:
```sql
GET /rest/v1/display_screens_primary
  ?display_screen_id=eq.SCREEN_PROTEIN
  &select=*,primary_metrics:display_screens_primary_display_metrics(metric_id,display_order,is_featured)
```

**Response:**
```json
{
  "primary_screen_id": "SCREEN_PROTEIN_PRIMARY",
  "display_screen_id": "SCREEN_PROTEIN",
  "title": "Protein Intake",
  "description": "Track protein grams, servings, and variety",
  "has_detail_screen": true,
  "detail_button_text": "View More Data",
  "primary_metrics": [
    {
      "metric_id": "DISP_PROTEIN_GRAMS",
      "display_order": 1,
      "is_featured": true
    }
  ]
}
```

#### Detail Screen:
```sql
GET /rest/v1/display_screens_detail
  ?display_screen_id=eq.SCREEN_PROTEIN
  &select=*,detail_metrics:display_screens_detail_display_metrics(metric_id,section_id,display_order)
```

**Response:**
```json
{
  "detail_screen_id": "SCREEN_PROTEIN_DETAIL",
  "display_screen_id": "SCREEN_PROTEIN",
  "title": "Protein Tracking",
  "subtitle": "Optimize your protein intake",
  "section_config": [
    {
      "section_id": "protein_overview",
      "section_type": "metrics_grid",
      "display_order": 1,
      "section_title": "Protein Overview"
    },
    {
      "section_id": "protein_details",
      "section_type": "metrics_detailed",
      "display_order": 2,
      "section_title": "Detailed Breakdown"
    }
  ],
  "detail_metrics": [
    {
      "metric_id": "DISP_PROTEIN_PER_KG",
      "section_id": "protein_overview",
      "display_order": 2
    },
    {
      "metric_id": "DISP_PROTEIN_MEAL_TIMING",
      "section_id": "protein_details",
      "display_order": 1
    },
    {
      "metric_id": "DISP_PROTEIN_TYPE",
      "section_id": "protein_details",
      "display_order": 2
    }
  ]
}
```

### Step 2: Fetch Display Metrics Configuration

For each metric, get its configuration:

```sql
GET /rest/v1/display_metrics
  ?metric_id=in.(DISP_PROTEIN_GRAMS,DISP_PROTEIN_PER_KG,DISP_PROTEIN_MEAL_TIMING,DISP_PROTEIN_TYPE)
  &select=*,aggregations:display_metrics_aggregations(agg_metric_id,period_type,calculation_type_id,display_order)
```

**Example Response for DISP_PROTEIN_GRAMS:**
```json
{
  "metric_id": "DISP_PROTEIN_GRAMS",
  "metric_name": "Protein",
  "chart_type_id": "bar_vertical",
  "target_value": null,
  "target_range_min": null,
  "target_range_max": null,
  "aggregations": [
    {
      "agg_metric_id": "AGG_PROTEIN_GRAMS",
      "period_type": "hourly",
      "calculation_type_id": "SUM",
      "display_order": 0
    },
    {
      "agg_metric_id": "AGG_PROTEIN_GRAMS",
      "period_type": "daily",
      "calculation_type_id": "SUM",
      "display_order": 1
    },
    {
      "agg_metric_id": "AGG_PROTEIN_GRAMS",
      "period_type": "weekly",
      "calculation_type_id": "AVG",
      "display_order": 2
    },
    {
      "agg_metric_id": "AGG_PROTEIN_GRAMS",
      "period_type": "monthly",
      "calculation_type_id": "AVG",
      "display_order": 3
    }
  ]
}
```

### Step 3: Fetch Cached Aggregation Data

Now fetch the actual data from the cache. Use the patient's selected period (daily/weekly/monthly).

#### For Primary Screen (Total Protein - Bar Chart):
```sql
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<user_uuid>
  &agg_metric_id=eq.AGG_PROTEIN_GRAMS
  &period_type=eq.daily
  &calculation_type=eq.SUM
  &period_start=gte.2025-10-01
  &period_start=lte.2025-10-31
  &select=period_start,calculated_value
  &order=period_start.desc
```

**Response:**
```json
[
  { "period_start": "2025-10-24T00:00:00Z", "calculated_value": 145.5 },
  { "period_start": "2025-10-23T00:00:00Z", "calculated_value": 132.0 },
  { "period_start": "2025-10-22T00:00:00Z", "calculated_value": 156.3 },
  ...
]
```

#### For Detail Screen - Overview Section (Protein per Kg - Line Chart):
```sql
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<user_uuid>
  &agg_metric_id=eq.AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT
  &period_type=eq.daily
  &calculation_type=eq.AVG
  &period_start=gte.2025-10-01
  &period_start=lte.2025-10-31
  &select=period_start,calculated_value
  &order=period_start.asc
```

**Response:**
```json
[
  { "period_start": "2025-10-01T00:00:00Z", "calculated_value": 1.85 },
  { "period_start": "2025-10-02T00:00:00Z", "calculated_value": 1.92 },
  { "period_start": "2025-10-03T00:00:00Z", "calculated_value": 1.78 },
  ...
]
```

#### For Detail Screen - Breakdown by Meal (Stacked Bar Chart):
```sql
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<user_uuid>
  &agg_metric_id=in.(AGG_PROTEIN_BREAKFAST_GRAMS,AGG_PROTEIN_LUNCH_GRAMS,AGG_PROTEIN_DINNER_GRAMS)
  &period_type=eq.daily
  &calculation_type=eq.SUM
  &period_start=gte.2025-10-01
  &period_start=lte.2025-10-31
  &select=period_start,agg_metric_id,calculated_value
  &order=period_start.desc,agg_metric_id.asc
```

**Response:**
```json
[
  { "period_start": "2025-10-24T00:00:00Z", "agg_metric_id": "AGG_PROTEIN_BREAKFAST_GRAMS", "calculated_value": 35.0 },
  { "period_start": "2025-10-24T00:00:00Z", "agg_metric_id": "AGG_PROTEIN_LUNCH_GRAMS", "calculated_value": 50.0 },
  { "period_start": "2025-10-24T00:00:00Z", "agg_metric_id": "AGG_PROTEIN_DINNER_GRAMS", "calculated_value": 60.5 },
  { "period_start": "2025-10-23T00:00:00Z", "agg_metric_id": "AGG_PROTEIN_BREAKFAST_GRAMS", "calculated_value": 30.0 },
  { "period_start": "2025-10-23T00:00:00Z", "agg_metric_id": "AGG_PROTEIN_LUNCH_GRAMS", "calculated_value": 45.0 },
  { "period_start": "2025-10-23T00:00:00Z", "agg_metric_id": "AGG_PROTEIN_DINNER_GRAMS", "calculated_value": 57.0 },
  ...
]
```

**Display Logic:**
For each date, stack the 3 values:
- Breakfast (bottom bar segment)
- Lunch (middle bar segment)
- Dinner (top bar segment)

#### For Detail Screen - Breakdown by Type (Stacked Bar Chart):
```sql
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<user_uuid>
  &agg_metric_id=in.(AGG_PROTEIN_TYPE_FATTY_FISH,AGG_PROTEIN_TYPE_LEAN_PROTEIN,AGG_PROTEIN_TYPE_PLANT_BASED,AGG_PROTEIN_TYPE_PROCESSED_MEAT,AGG_PROTEIN_TYPE_RED_MEAT,AGG_PROTEIN_TYPE_SUPPLEMENT)
  &period_type=eq.daily
  &calculation_type=eq.SUM
  &period_start=gte.2025-10-01
  &period_start=lte.2025-10-31
  &select=period_start,agg_metric_id,calculated_value
  &order=period_start.desc,agg_metric_id.asc
```

**Response:**
```json
[
  { "period_start": "2025-10-24T00:00:00Z", "agg_metric_id": "AGG_PROTEIN_TYPE_FATTY_FISH", "calculated_value": 25.0 },
  { "period_start": "2025-10-24T00:00:00Z", "agg_metric_id": "AGG_PROTEIN_TYPE_LEAN_PROTEIN", "calculated_value": 40.0 },
  { "period_start": "2025-10-24T00:00:00Z", "agg_metric_id": "AGG_PROTEIN_TYPE_PLANT_BASED", "calculated_value": 30.5 },
  { "period_start": "2025-10-24T00:00:00Z", "agg_metric_id": "AGG_PROTEIN_TYPE_PROCESSED_MEAT", "calculated_value": 0 },
  { "period_start": "2025-10-24T00:00:00Z", "agg_metric_id": "AGG_PROTEIN_TYPE_RED_MEAT", "calculated_value": 50.0 },
  { "period_start": "2025-10-24T00:00:00Z", "agg_metric_id": "AGG_PROTEIN_TYPE_SUPPLEMENT", "calculated_value": 0 },
  ...
]
```

**Display Logic:**
For each date, stack the 6 values (only show non-zero):
- Fatty Fish
- Lean Protein
- Plant-Based
- Processed Meat (if > 0)
- Red Meat
- Supplement (if > 0)

---

## Part 3: UI Implementation

### Primary Screen Layout

```
┌─────────────────────────────────────┐
│  🥩 Protein Intake                  │
│  Track protein grams, servings...   │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │  Protein (Daily)              │ │
│  │                               │ │
│  │  ▮▮▮▮▮▮▮▮▮▮▮ 145.5g          │ │
│  │  ▮▮▮▮▮▮▮▮▮   132.0g          │ │
│  │  ▮▮▮▮▮▮▮▮▮▮▮▮ 156.3g         │ │
│  │  Oct 24  Oct 23  Oct 22       │ │
│  └───────────────────────────────┘ │
│                                     │
│  [View More Data →]                 │
│                                     │
└─────────────────────────────────────┘
```

### Detail Screen Layout

```
┌─────────────────────────────────────┐
│  ← Protein Tracking                 │
│  Optimize your protein intake       │
├─────────────────────────────────────┤
│  📊 Protein Overview                │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │ Protein per Kg              │   │
│  │                             │   │
│  │    2.0 ┌──╮                 │   │
│  │    1.8 │  └─╮               │   │
│  │    1.6 └────└──             │   │
│  │   Oct 1  Oct 15  Oct 31     │   │
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  📋 Detailed Breakdown              │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │ Protein by Meal             │   │
│  │                             │   │
│  │ ▓▓▓ 60.5g Dinner            │   │
│  │ ░░░ 50.0g Lunch             │   │
│  │ ▒▒▒ 35.0g Breakfast         │   │
│  │                             │   │
│  │  Oct 24  Oct 23  Oct 22     │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Protein by Type             │   │
│  │                             │   │
│  │ ▓ 50g Red Meat              │   │
│  │ ░ 40g Lean Protein          │   │
│  │ ▒ 30.5g Plant-Based         │   │
│  │ ▓ 25g Fatty Fish            │   │
│  │                             │   │
│  │  Oct 24  Oct 23  Oct 22     │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

---

## Part 4: Period Switching

Users can toggle between daily/weekly/monthly views. When the period changes:

1. **Update the query `period_type` parameter**:
   - Daily: `period_type=eq.daily`
   - Weekly: `period_type=eq.weekly`
   - Monthly: `period_type=eq.monthly`

2. **Update the calculation type if needed**:
   - Daily: Usually `SUM` for quantities
   - Weekly: Usually `AVG` (average daily intake that week)
   - Monthly: Usually `AVG` (average daily intake that month)

3. **Adjust date range**:
   - Daily: Last 7 days, last 30 days, etc.
   - Weekly: Last 4 weeks, last 12 weeks
   - Monthly: Last 3 months, last 6 months

**Example - Switching to Weekly:**
```sql
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.<user_uuid>
  &agg_metric_id=eq.AGG_PROTEIN_GRAMS
  &period_type=eq.weekly
  &calculation_type=eq.AVG
  &period_start=gte.2025-09-01
  &select=period_start,calculated_value
  &order=period_start.desc
```

---

## Part 5: Error Handling

### No Data Available
If no aggregation data exists:
```json
[]  // Empty array
```

**Display:**
- Show empty state: "No protein data logged yet"
- Show "Log Protein" button

### Stale Cache
Aggregation cache updates happen automatically via triggers, but there's a small delay (usually < 1 second). If user logs data and immediately views screen:

1. **Option A**: Show loading spinner for 1-2 seconds
2. **Option B**: Optimistically update UI, then refresh from cache

### Missing Reference Data
If protein types/timing dropdown is empty:

```sql
GET /rest/v1/data_entry_fields_reference
  ?reference_category=eq.protein_types
  &is_active=eq.true
```

If returns empty, this is a backend configuration issue.

---

## Part 6: Caching Strategy (Mobile)

### Cache Locally:
1. **Reference data** (protein types, timing options)
   - Fetch once on app launch
   - Refresh daily or on app update

2. **Screen configurations** (display_screens, display_metrics)
   - Fetch once per session
   - Refresh when user pulls to refresh

### Always Fetch Fresh:
1. **Aggregation cache data** (`aggregation_results_cache`)
   - Always fetch latest
   - This is the dynamic data that changes with user input

---

## Part 7: Testing with Test User

**Test Patient ID:** `8b79ce33-02b8-4f49-8268-3204130efa82`
**Email:** test.patient.21@wellpath.com

This user has 30+ days of protein data across all meal times and protein types.

### Sample Queries:

```sql
-- Get last 7 days of total protein (daily)
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.8b79ce33-02b8-4f49-8268-3204130efa82
  &agg_metric_id=eq.AGG_PROTEIN_GRAMS
  &period_type=eq.daily
  &calculation_type=eq.SUM
  &period_start=gte.2025-10-18
  &select=period_start,calculated_value
  &order=period_start.desc

-- Get protein by meal for October
GET /rest/v1/aggregation_results_cache
  ?patient_id=eq.8b79ce33-02b8-4f49-8268-3204130efa82
  &agg_metric_id=in.(AGG_PROTEIN_BREAKFAST_GRAMS,AGG_PROTEIN_LUNCH_GRAMS,AGG_PROTEIN_DINNER_GRAMS)
  &period_type=eq.daily
  &calculation_type=eq.SUM
  &period_start=gte.2025-10-01
  &period_start=lt.2025-11-01
  &select=period_start,agg_metric_id,calculated_value
  &order=period_start.desc
```

---

## Part 8: Color Coding Recommendations

### Protein by Meal:
- Breakfast: `#FFA726` (Orange)
- Lunch: `#66BB6A` (Green)
- Dinner: `#42A5F5` (Blue)

### Protein by Type:
- Fatty Fish: `#0288D1` (Deep Blue)
- Lean Protein: `#66BB6A` (Green)
- Plant-Based: `#8BC34A` (Light Green)
- Processed Meat: `#FF7043` (Orange-Red) - warning color
- Red Meat: `#E53935` (Red)
- Supplement: `#AB47BC` (Purple)

---

## Part 9: Next Steps

Once protein screens are working:
1. Test with test.patient.21@wellpath.com
2. Verify all 4 metrics display correctly
3. Test period switching (daily/weekly/monthly)
4. Test data entry flow end-to-end
5. Report any issues or missing data

We'll replicate this pattern for other categories (Steps, Sleep, Cardio, etc.) once protein is validated.

---

## Quick Reference: All Protein Queries

```bash
# Get protein type options
GET /rest/v1/data_entry_fields_reference?reference_category=eq.protein_types&is_active=eq.true

# Get protein timing options
GET /rest/v1/data_entry_fields_reference?reference_category=eq.protein_timing&is_active=eq.true

# Get screen config
GET /rest/v1/display_screens_primary?display_screen_id=eq.SCREEN_PROTEIN
GET /rest/v1/display_screens_detail?display_screen_id=eq.SCREEN_PROTEIN

# Get metric configs
GET /rest/v1/display_metrics?metric_id=in.(DISP_PROTEIN_GRAMS,DISP_PROTEIN_PER_KG,DISP_PROTEIN_MEAL_TIMING,DISP_PROTEIN_TYPE)&select=*,aggregations:display_metrics_aggregations(*)

# Get total protein (daily)
GET /rest/v1/aggregation_results_cache?patient_id=eq.<uuid>&agg_metric_id=eq.AGG_PROTEIN_GRAMS&period_type=eq.daily&calculation_type=eq.SUM&period_start=gte.<date>

# Get protein by meal (daily)
GET /rest/v1/aggregation_results_cache?patient_id=eq.<uuid>&agg_metric_id=in.(AGG_PROTEIN_BREAKFAST_GRAMS,AGG_PROTEIN_LUNCH_GRAMS,AGG_PROTEIN_DINNER_GRAMS)&period_type=eq.daily&calculation_type=eq.SUM&period_start=gte.<date>

# Get protein by type (daily)
GET /rest/v1/aggregation_results_cache?patient_id=eq.<uuid>&agg_metric_id=in.(AGG_PROTEIN_TYPE_FATTY_FISH,AGG_PROTEIN_TYPE_LEAN_PROTEIN,AGG_PROTEIN_TYPE_PLANT_BASED,AGG_PROTEIN_TYPE_PROCESSED_MEAT,AGG_PROTEIN_TYPE_RED_MEAT,AGG_PROTEIN_TYPE_SUPPLEMENT)&period_type=eq.daily&calculation_type=eq.SUM&period_start=gte.<date>

# Get protein per kg ratio (daily)
GET /rest/v1/aggregation_results_cache?patient_id=eq.<uuid>&agg_metric_id=eq.AGG_PROTEIN_PER_KILOGRAM_BODY_WEIGHT&period_type=eq.daily&calculation_type=eq.AVG&period_start=gte.<date>
```
