# Real-Time WellPath Scoring Architecture

## Overview

This document describes the real-time WellPath scoring system that enables tracked behavioral and biometric data to dynamically update patient scores over time, replacing initial questionnaire responses when sufficient quality data is available.

## Problem Statement

Initial WellPath scores are based on:
- **Biomarkers** - Lab values entered by clinicians (static, clinician-controlled)
- **Biometrics** - Initial readings from clinicians, later updated via patient tracking
- **Behaviors** - Initial values from questionnaire responses
- **Education** - Course completion tracking

**The Challenge:**
- Survey responses are categorical and retrospective ("How often do you eat vegetables?")
- Tracked data is quantitative and prospective (actual daily vegetable servings logged)
- How do we transition from self-reported to tracked data without premature updates?
- When someone says "I eat vegetables 2 servings/day" but then tracks 3 servings once, we shouldn't update their score immediately

**The Solution:**
- Threshold-based replacement system
- Require 3-4 weeks of consistent tracking (15-20+ data points)
- Weekly score updates using behavioral averages
- Data source transparency (questionnaire vs tracked vs clinician)
- Preserve historical values for trend visualization

---

## Architecture Components

### 1. Data Source Tracking

**Modified Table:** `patient_wellpath_score_items`

**New Columns:**
```sql
data_source TEXT  -- 'questionnaire_initial', 'clinician_biomarker', 'clinician_biometric',
                  -- 'tracked_biometric', 'tracked_behavior', 'education_completion'
source_updated_at TIMESTAMP WITH TIME ZONE
data_points_count INTEGER  -- How many data points contributed to this score
```

**Purpose:** Full transparency about where each score item's data originated.

**Migration:** `20251027_01_add_data_source_tracking_to_score_items.sql`

---

### 2. Data Entry Field Mappings

**New Table:** `data_entry_fields_mappings`

**Schema:**
```sql
- field_id → What the user tracks
- biometric_name → Updates biometric readings (e.g., Weight)
- question_number → Updates behavioral scores (e.g., Q2.65 vegetable servings)
- agg_metric_id → The aggregation metric this feeds
- replacement_threshold_days → Days of tracking required (default: 21)
- min_data_points → Minimum data points needed (default: 15)
- min_data_points_per_week → Quality control (default: 3)
- mapping_type → 'biometric_tracking' or 'behavior_tracking'
```

**Purpose:** Maps what users track (data_entry_fields) to what gets updated (biometrics or survey behaviors).

**Examples:**
| Field ID | Biometric | Question | Agg Metric | Type |
|----------|-----------|----------|------------|------|
| `FIELD_WEIGHT` | Weight | NULL | `AGG_WEIGHT_AVG` | biometric_tracking |
| `FIELD_VEGETABLES` | NULL | Q2.65 | `AGG_VEGETABLE_SERVINGS` | behavior_tracking |
| `FIELD_STEPS` | Daily Steps | NULL | `AGG_STEPS_DAILY` | biometric_tracking |

**Migration:** `20251027_02_create_data_entry_fields_mappings.sql`

---

### 3. Patient Behavioral Values

**New Table:** `patient_behavioral_values`

**Schema:**
```sql
- patient_id
- question_number OR biometric_name (one required)
- agg_metric_id
- current_value (numeric) - Current value being used for scoring
- current_value_source - 'questionnaire', 'tracked', or 'clinician'
- original_questionnaire_value - Preserve initial survey response
- established_date - When this value was established
- data_points_count - How many data points contributed
- lookback_period_start/end - Time window for tracked data
- last_updated_at
```

**Purpose:** Stores the "current behavioral value" for each patient's tracked behaviors/biometrics. Acts as the source of truth for what value is currently used in scoring.

**Example Record:**
```json
{
  "patient_id": "8b79ce33-...",
  "question_number": 2.65,
  "agg_metric_id": "AGG_VEGETABLE_SERVINGS",
  "current_value": 3.2,
  "current_value_source": "tracked",
  "original_questionnaire_value": 2.0,
  "original_questionnaire_response_text": "1-2 servings daily",
  "established_date": "2025-01-15",
  "data_points_count": 28,
  "lookback_period_start": "2025-01-01",
  "lookback_period_end": "2025-01-28"
}
```

**Migration:** `20251027_03_create_patient_behavioral_values.sql`

---

### 4. Survey Response Numeric Conversions

**New Table:** `survey_response_options_numeric_values`

**Schema:**
```sql
- response_option_id
- question_number
- numeric_value - Numeric equivalent of categorical response
- numeric_value_unit - e.g., 'servings/day', 'days/month', 'hours/night'
- value_range_low/high - Optional range boundaries
- conversion_method - 'midpoint', 'conservative', 'optimistic', 'exact'
```

**Purpose:** Converts categorical survey responses to numeric values for behavioral tracking.

**Examples:**
| Question | Response | Numeric Value | Unit | Range |
|----------|----------|---------------|------|-------|
| Q2.65 Vegetables | "Rarely or never" | 0.5 | servings/day | 0-1 |
| Q2.65 Vegetables | "1-2 servings" | 1.5 | servings/day | 1-2 |
| Q2.65 Vegetables | "3-4 servings" | 3.5 | servings/day | 3-4 |
| Q2.65 Vegetables | "5+ servings" | 6.0 | servings/day | 5-10 |
| Q2.21 Whole grains | "Rarely or never" | 2 | days/month | 0-4 |
| Q2.21 Whole grains | "Daily" | 28 | days/month | 28-31 |

**Migration:** `20251027_04_create_survey_response_options_numeric_values.sql`

---

### 5. Behavioral Threshold Configuration

**New Table:** `behavioral_threshold_config`

**Schema:**
```sql
- agg_metric_id
- question_number (optional)
- biometric_name (optional)
- min_weeks_of_data (default: 3)
- min_data_points_per_week (default: 4)
- min_total_data_points (default: 15)
- min_tracking_days (default: 21)
- max_gap_days (default: 7)
- require_recent_data (default: true)
- stability_threshold (optional - coefficient of variation)
- min_unique_days (optional - for daily behaviors)
```

**Purpose:** Defines thresholds for when tracked data should replace initial questionnaire/clinician data.

**Default Configuration:**
```json
{
  "min_weeks_of_data": 3,
  "min_data_points_per_week": 4,
  "min_total_data_points": 15,
  "min_tracking_days": 21,
  "max_gap_days": 7,
  "require_recent_data": true
}
```

**Threshold Logic:**
- **3 weeks minimum** - Ensures data spans sufficient time
- **4 data points/week** - Ensures consistent tracking quality
- **15 total data points** - Absolute minimum for statistical relevance
- **21 calendar days** - Must span at least 3 weeks
- **7 day max gap** - No week-long tracking gaps
- **Recent data required** - Must have data within last 7 days

**Migration:** `20251027_05_create_behavioral_threshold_config.sql`

---

## Data Flow

### Initial Score (Questionnaire Completion)

```
1. Patient completes questionnaire
   └─> Q2.65: "How many servings of vegetables do you eat daily?"
       └─> Answer: "1-2 servings"

2. Conversion to numeric value
   └─> survey_response_options_numeric_values
       └─> "1-2 servings" → 1.5 servings/day

3. Create initial behavioral value
   └─> patient_behavioral_values
       └─> current_value: 1.5
       └─> current_value_source: 'questionnaire'
       └─> data_points_count: 0

4. Create initial score item
   └─> patient_wellpath_score_items
       └─> question_number: 2.65
       └─> patient_value: "1-2 servings"
       └─> patient_value_numeric: 1.5
       └─> data_source: 'questionnaire_initial'
       └─> data_points_count: 0
       └─> Scored using nutrition behavioral weight
```

---

### Tracked Data Accumulation

```
Week 1-3: Patient tracks vegetables
├─> Day 1: 2 servings (breakfast, lunch)
├─> Day 2: 3 servings (breakfast, lunch, dinner)
├─> Day 4: 1 serving (lunch)
├─> Day 5: 2 servings (breakfast, dinner)
└─> ... continues ...

Aggregation Processing:
└─> data_entry_field: FIELD_VEGETABLES
    └─> Maps to: AGG_VEGETABLE_SERVINGS
        └─> Stores in: aggregation_results_cache
            └─> period_type: 'weekly'
            └─> calculation_type: 'CALC_AVERAGE'
            └─> value: 2.1 servings/day (average)
            └─> data_points_count: 18 entries
            └─> period_start: 2025-01-01
            └─> period_end: 2025-01-21
```

---

### Threshold Evaluation (Weekly Scoring Process)

```
Weekly Scoring Job (runs every Sunday night):

1. Query aggregation_results_cache for each patient
   └─> Get weekly averages for all tracked metrics

2. Check thresholds (behavioral_threshold_config)
   └─> AGG_VEGETABLE_SERVINGS requires:
       ├─ min_weeks_of_data: 3 ✓ (have 3 weeks)
       ├─ min_data_points_per_week: 4 ✓ (have 6/week average)
       ├─ min_total_data_points: 15 ✓ (have 18 total)
       ├─ min_tracking_days: 21 ✓ (spans 21 days)
       ├─ max_gap_days: 7 ✓ (no gaps > 7 days)
       └─ require_recent_data: true ✓ (has data from last 7 days)

3. Threshold met! Replace questionnaire value with tracked data
   └─> Update patient_behavioral_values:
       ├─ current_value: 1.5 → 2.1 (tracked average)
       ├─ current_value_source: 'questionnaire' → 'tracked'
       ├─ data_points_count: 0 → 18
       ├─ lookback_period_start: 2025-01-01
       ├─ lookback_period_end: 2025-01-21
       └─ last_updated_at: 2025-01-21

4. Create new score item (preserve history)
   └─> patient_wellpath_score_items (new record):
       ├─ question_number: 2.65
       ├─ patient_value_numeric: 2.1
       ├─ data_source: 'tracked_behavior'
       ├─ source_updated_at: 2025-01-21
       ├─ data_points_count: 18
       └─ Rescored using updated value

5. Create new overall score record
   └─> patient_wellpath_scores:
       └─> New overall score with updated pillar scores
```

---

### Tracking Gaps (Insufficient Data)

```
Week 4: Patient stops tracking (only 2 entries all week)

Weekly Scoring Job:

1. Query aggregation_results_cache
   └─> Last week: only 2 data points

2. Check thresholds
   └─> min_data_points_per_week: 4 ✗ (only have 2)
   └─> Threshold NOT met

3. Keep previous value (don't revert to questionnaire)
   └─> patient_behavioral_values:
       ├─ current_value: 2.1 (unchanged)
       ├─ current_value_source: 'tracked' (unchanged)
       └─ NO new score item created

4. No score update this week
   └─> Previous score remains valid
```

---

## Weekly Scoring Process (Detailed)

### Trigger
- Cron job runs every **Sunday at 11:59 PM**
- OR manual trigger via edge function
- OR triggered by aggregation completion for a patient

### Process Flow

```typescript
async function weeklyScoring(patient_id: string) {
  // 1. Get all tracked metrics for this patient
  const trackedMetrics = await getTrackedMetrics(patient_id)

  for (const metric of trackedMetrics) {
    // 2. Get aggregation results for last 3-4 weeks
    const aggregationResults = await getAggregationResults(
      patient_id,
      metric.agg_metric_id,
      lookbackWeeks: 4
    )

    // 3. Get threshold config for this metric
    const threshold = await getThresholdConfig(metric.agg_metric_id)

    // 4. Evaluate if thresholds are met
    const meetsThreshold = evaluateThreshold(aggregationResults, threshold)

    if (meetsThreshold) {
      // 5. Calculate new average from tracked data
      const newValue = calculateWeeklyAverage(aggregationResults)

      // 6. Update patient_behavioral_values
      await updateBehavioralValue(patient_id, metric, newValue, aggregationResults)

      // 7. Create new score item
      await createScoreItem(patient_id, metric, newValue, 'tracked_behavior')
    } else {
      // 8. Insufficient data - keep existing value
      console.log(`Threshold not met for ${metric.agg_metric_id}, keeping previous value`)
    }
  }

  // 9. Recalculate overall WellPath score
  await calculateWellPathScore(patient_id)
}
```

### Threshold Evaluation Logic

```typescript
function evaluateThreshold(aggregationResults, threshold) {
  const totalDataPoints = aggregationResults.reduce((sum, r) => sum + r.data_points_count, 0)
  const uniqueDays = [...new Set(aggregationResults.map(r => r.date))].length
  const weeksSpanned = (latestDate - earliestDate) / 7
  const avgPointsPerWeek = totalDataPoints / weeksSpanned
  const maxGap = findMaxGapBetweenDataPoints(aggregationResults)
  const hasRecentData = aggregationResults.some(r => r.date > (today - 7 days))

  return (
    weeksSpanned >= threshold.min_weeks_of_data &&
    avgPointsPerWeek >= threshold.min_data_points_per_week &&
    totalDataPoints >= threshold.min_total_data_points &&
    uniqueDays >= threshold.min_tracking_days &&
    maxGap <= threshold.max_gap_days &&
    (threshold.require_recent_data ? hasRecentData : true)
  )
}
```

---

## Example: Whole Grains Tracking

### Initial State (Post-Questionnaire)

**Q2.21:** "How often do you consume whole grains?"
**Answer:** "Rarely or never"

```sql
-- survey_response_options_numeric_values
{
  "response_option_id": "uuid-...",
  "question_number": 2.21,
  "numeric_value": 2,  -- 2 days/month
  "numeric_value_unit": "days/month",
  "value_range_low": 0,
  "value_range_high": 4,
  "conversion_method": "midpoint"
}

-- patient_behavioral_values
{
  "patient_id": "8b79ce33-...",
  "question_number": 2.21,
  "agg_metric_id": "AGG_WHOLE_GRAINS_UNIQUE_DAYS",
  "current_value": 2,  -- 2 days/month
  "current_value_source": "questionnaire",
  "original_questionnaire_value": 2,
  "data_points_count": 0
}

-- patient_wellpath_score_items
{
  "question_number": 2.21,
  "patient_value": "Rarely or never",
  "patient_value_numeric": 2,
  "data_source": "questionnaire_initial",
  "data_points_count": 0,
  "raw_score": 20,  -- Low score
  "normalized_score": 0.2
}
```

### Tracking Begins (Weeks 1-4)

Patient logs whole grain consumption:
- Week 1: Mon, Wed, Fri, Sun (4 days)
- Week 2: Tue, Thu, Sat (3 days)
- Week 3: Mon, Tue, Fri, Sat, Sun (5 days)
- Week 4: Mon, Wed, Thu, Sat (4 days)

**Total: 16 unique days over 28 days**

```sql
-- aggregation_results_cache (simplified)
{
  "patient_id": "8b79ce33-...",
  "agg_metric_id": "AGG_WHOLE_GRAINS_UNIQUE_DAYS",
  "period_type": "monthly",
  "calculation_type_id": "CALC_COUNT_DISTINCT",
  "period_start": "2025-01-01",
  "period_end": "2025-01-28",
  "value": 16,  -- 16 unique days
  "data_points_count": 16
}
```

### Threshold Evaluation (End of Week 4)

```typescript
// behavioral_threshold_config for AGG_WHOLE_GRAINS_UNIQUE_DAYS
{
  "min_weeks_of_data": 3,               // ✓ Have 4 weeks
  "min_data_points_per_week": 3,       // ✓ Have 4/week average
  "min_total_data_points": 12,         // ✓ Have 16 total
  "min_tracking_days": 21,             // ✓ Spans 28 days
  "max_gap_days": 7,                   // ✓ No gaps > 7 days
  "require_recent_data": true          // ✓ Has data from last week
}

// THRESHOLD MET! ✅
```

### Update to Tracked Value

```sql
-- patient_behavioral_values (UPDATED)
{
  "patient_id": "8b79ce33-...",
  "question_number": 2.21,
  "agg_metric_id": "AGG_WHOLE_GRAINS_UNIQUE_DAYS",
  "current_value": 16,  -- UPDATED from 2 to 16 days/month
  "current_value_source": "tracked",  -- CHANGED from questionnaire
  "original_questionnaire_value": 2,  -- PRESERVED
  "established_date": "2025-01-28",  -- When tracked value was established
  "data_points_count": 16,
  "lookback_period_start": "2025-01-01",
  "lookback_period_end": "2025-01-28"
}

-- patient_wellpath_score_items (NEW RECORD - preserves history)
{
  "question_number": 2.21,
  "patient_value_numeric": 16,  -- NEW VALUE
  "data_source": "tracked_behavior",  -- NEW SOURCE
  "source_updated_at": "2025-01-28",
  "data_points_count": 16,
  "raw_score": 85,  -- IMPROVED SCORE
  "normalized_score": 0.85,
  "scored_at": "2025-01-28"
}

-- patient_wellpath_scores (NEW RECORD)
{
  "patient_id": "8b79ce33-...",
  "overall_score": 785,  -- IMPROVED from 732
  "overall_percentage": 89.2,  -- IMPROVED from 83.1
  "calculated_at": "2025-01-28",
  "pillar_scores": {
    "Healthful Nutrition": {
      "score": 118,  // IMPROVED
      "max": 130,
      "percentage": 90.8  // Up from 87.2
    }
  }
}
```

---

## Mobile App Integration

### Displaying Data Source

```swift
// SwiftUI View
struct BehaviorMetricCard: View {
    let metric: BehaviorMetric

    var body: some View {
        VStack(alignment: .leading) {
            Text(metric.name)
                .font(.headline)

            HStack {
                Text(metric.currentValue)
                    .font(.title)

                // Data source badge
                DataSourceBadge(source: metric.dataSource)
            }

            if metric.dataSource == "tracked_behavior" {
                Text("Based on \(metric.dataPointsCount) tracked entries")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct DataSourceBadge: View {
    let source: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(label)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .cornerRadius(8)
    }

    var icon: String {
        switch source {
        case "questionnaire_initial": return "doc.text"
        case "tracked_behavior": return "chart.line.uptrend.xyaxis"
        case "clinician_biometric": return "stethoscope"
        default: return "questionmark"
        }
    }

    var label: String {
        switch source {
        case "questionnaire_initial": return "Survey"
        case "tracked_behavior": return "Tracked"
        case "clinician_biometric": return "Clinician"
        default: return "Unknown"
        }
    }
}
```

### Fetching Current Behavioral Values

```swift
// API Query
func fetchBehavioralValues(for patientId: String) async throws -> [BehavioralValue] {
    let response = try await supabase
        .from("patient_behavioral_values")
        .select("""
            current_value,
            current_value_source,
            data_points_count,
            last_updated_at,
            question_number,
            biometric_name,
            aggregation_metrics(metric_name, display_name, output_unit)
        """)
        .eq("patient_id", patientId)
        .eq("is_active", true)
        .execute()

    return try response.decode([BehavioralValue].self)
}
```

---

## Next Steps

### Phase 1: Data Population (Current)
- [x] Create all 5 new tables
- [ ] Populate `biometrics_aggregation_metrics` with biometric→agg mappings
- [ ] Populate `data_entry_fields_mappings` with field→biometric/question mappings
- [ ] Populate `behavioral_threshold_config` with default thresholds
- [ ] Populate `survey_response_options_numeric_values` with categorical→numeric conversions

### Phase 2: Scoring Logic
- [ ] Update `calculate-wellpath-score` edge function with threshold logic
- [ ] Implement `evaluateThreshold()` function
- [ ] Implement `updateBehavioralValue()` function
- [ ] Add data source tracking to score item creation

### Phase 3: Weekly Automation
- [ ] Create `weekly-scoring` edge function
- [ ] Set up Supabase cron job (Sunday 11:59 PM)
- [ ] Add manual trigger endpoint
- [ ] Create monitoring/logging for weekly runs

### Phase 4: Mobile Integration
- [ ] Add data source badges to UI
- [ ] Show "tracked vs survey" comparisons
- [ ] Display threshold progress ("12/15 data points needed")
- [ ] Add "Start Tracking" CTAs for questionnaire-only values

---

## Success Metrics

### Data Quality
- **Threshold Coverage:** % of trackable behaviors with threshold configs
- **Conversion Coverage:** % of scored survey questions with numeric conversions
- **Mapping Coverage:** % of data_entry_fields mapped to biometrics/questions

### User Engagement
- **Tracking Adoption:** % of patients who start tracking after questionnaire
- **Threshold Achievement:** % of tracked behaviors that reach replacement threshold
- **Tracking Consistency:** Average data points per week for active trackers

### Scoring Accuracy
- **Data Source Distribution:** % of score items from each source type
- **Score Volatility:** Week-over-week score changes (should stabilize with tracked data)
- **Tracked vs Survey Gap:** Average difference between initial survey and tracked values

---

## Questions & Answers

**Q: What happens if someone stops tracking after threshold is met?**
A: The last tracked value is preserved. We don't revert to questionnaire unless they delete/reset their data.

**Q: Can users see their original questionnaire response?**
A: Yes, it's preserved in `patient_behavioral_values.original_questionnaire_value` for reference.

**Q: What if tracked data contradicts questionnaire response?**
A: Tracked data takes precedence once threshold is met. This is expected and valuable feedback.

**Q: How do we handle outliers in tracked data?**
A: Future enhancement: Add `stability_threshold` (coefficient of variation) to detect and flag unstable data.

**Q: Can clinicians override tracked values?**
A: Yes, clinician-entered values can have `data_source: 'clinician'` and take precedence over both questionnaire and tracked.

---

## File References

**Migrations:**
- `20251027_01_add_data_source_tracking_to_score_items.sql`
- `20251027_02_create_data_entry_fields_mappings.sql`
- `20251027_03_create_patient_behavioral_values.sql`
- `20251027_04_create_survey_response_options_numeric_values.sql`
- `20251027_05_create_behavioral_threshold_config.sql`

**Related Documentation:**
- `WELLPATH_SCORING_HISTORY_SYSTEM.md` - Overall score history tracking
- `COMPREHENSIVE_SURVEY_AGGREGATION_MAPPINGS_COMPLETE.md` - Survey→aggregation mappings
- `TRACKED_METRICS_E2E_PIPELINE.md` - Data entry → aggregation pipeline
