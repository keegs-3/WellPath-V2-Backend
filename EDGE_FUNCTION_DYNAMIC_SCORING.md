# Edge Function: Dynamic Score Updating

**Purpose**: Update patient effective responses based on tracked data and recalculate WellPath scores

---

## Core Concept

**ALL questions** (standalone or within functions) work the same way:
1. Question has response options
2. Response options map to aggregation metric thresholds
3. Edge function checks tracked data against thresholds
4. Updates `patient_effective_responses` with matching response option
5. Existing scoring logic recalculates automatically

---

## Database Tables

### Input Tables

#### 1. `survey_response_options_aggregations`
Maps response options to aggregation metrics with thresholds.

```sql
-- Example: Fruit servings (standalone question)
response_option_id: 'RO_2.19-3'
question_number: 2.19
agg_metric_id: 'AGG_FRUIT_SERVINGS'
threshold_low: 3.0
threshold_high: 4.9
calculation_type_id: 'AVG'
period_type: 'monthly'
min_data_points: 20
lookback_days: 30

-- Example: Cardio frequency (function-based question)
response_option_id: 'RO_3.04-3'
question_number: 3.04  -- Part of movement_cardio_score function
agg_metric_id: 'AGG_CARDIO_SESSION_COUNT'
threshold_low: 3
threshold_high: 4
calculation_type_id: 'AVG'
period_type: 'weekly'
min_data_points: 3
lookback_days: 30
```

#### 2. `aggregation_results_cache`
Stores pre-calculated aggregation values from patient tracking data.

```sql
user_id: patient-uuid
agg_metric_id: 'AGG_FRUIT_SERVINGS'
calculation_type_id: 'AVG'
period_type: 'monthly'
period_start: '2025-09-22'
period_end: '2025-10-22'
value: 3.5
data_point_count: 28
```

#### 3. `patient_survey_responses`
Original survey responses.

```sql
user_id: patient-uuid
response_option_id: 'RO_2.19-1'  -- Original: "0 servings"
question_number: 2.19
response_timestamp: '2025-09-01'
```

### Output Table

#### `patient_effective_responses`
Stores the current "effective" response for each patient-question pair.

```sql
user_id: patient-uuid
question_number: 2.19

-- Original survey data
original_response_option_id: 'RO_2.19-1'
original_score: 0.2
original_response_date: '2025-09-01'

-- Current effective data (from tracking!)
effective_response_option_id: 'RO_2.19-3'
effective_score: 0.7
response_source: 'tracking'

-- Tracking metadata
tracking_agg_metric_id: 'AGG_FRUIT_SERVINGS'
tracking_avg_value: 3.5
tracking_data_points: 28

last_updated_at: '2025-10-22'
```

---

## Edge Function Logic

### Main Function Flow

```javascript
export async function updateDynamicScores(userId) {
  // 1. Get all mappings for this user's questions
  const mappings = await getMappingsForUser(userId);

  // 2. For each mapping, check if tracked data matches
  for (const mapping of mappings) {
    const trackedValue = await getTrackedValue(
      userId,
      mapping.agg_metric_id,
      mapping.calculation_type_id,
      mapping.period_type,
      mapping.lookback_days
    );

    // 3. Check data quality
    if (!trackedValue || trackedValue.dataPoints < mapping.min_data_points) {
      continue; // Not enough data, keep survey response
    }

    // 4. Find matching response option
    const matchingOption = await findMatchingResponseOption(
      mapping.question_number,
      trackedValue.value
    );

    if (!matchingOption) {
      continue; // No matching threshold
    }

    // 5. Update effective response
    await updateEffectiveResponse(
      userId,
      mapping.question_number,
      matchingOption.option_id,
      matchingOption.score,
      trackedValue
    );
  }

  // 6. Recalculate WellPath scores
  await recalculateScores(userId);
}
```

### Helper Functions

#### `getTrackedValue()`
```javascript
async function getTrackedValue(userId, aggMetricId, calcType, periodType, lookbackDays) {
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - lookbackDays);

  const { data, error } = await supabase
    .from('aggregation_results_cache')
    .select('value, data_point_count')
    .eq('user_id', userId)
    .eq('agg_metric_id', aggMetricId)
    .eq('calculation_type_id', calcType)
    .eq('period_type', periodType)
    .gte('period_start', startDate.toISOString());

  if (error || !data || data.length === 0) {
    return null;
  }

  // Calculate overall average (if needed)
  const avgValue = calcType === 'AVG'
    ? data.reduce((sum, row) => sum + row.value, 0) / data.length
    : data.reduce((sum, row) => sum + row.value, 0);

  const totalDataPoints = data.reduce((sum, row) => sum + row.data_point_count, 0);

  return {
    value: avgValue,
    dataPoints: totalDataPoints
  };
}
```

#### `findMatchingResponseOption()`
```javascript
async function findMatchingResponseOption(questionNumber, trackedValue) {
  const { data, error } = await supabase
    .from('survey_response_options_aggregations')
    .select(`
      response_option_id,
      threshold_low,
      threshold_high,
      survey_response_options (
        option_id,
        option_text,
        score
      )
    `)
    .eq('question_number', questionNumber)
    .gte('threshold_high', trackedValue)
    .lte('threshold_low', trackedValue)
    .eq('is_active', true)
    .order('threshold_low', { ascending: false })
    .limit(1);

  if (error || !data || data.length === 0) {
    return null;
  }

  return {
    option_id: data[0].response_option_id,
    option_text: data[0].survey_response_options.option_text,
    score: data[0].survey_response_options.score
  };
}
```

#### `updateEffectiveResponse()`
```javascript
async function updateEffectiveResponse(userId, questionNumber, optionId, score, trackedValue) {
  // Get original survey response
  const { data: originalResponse } = await supabase
    .from('patient_survey_responses')
    .select('response_option_id, response_timestamp')
    .eq('user_id', userId)
    .eq('question_number', questionNumber)  // Note: need to join through response_options
    .single();

  const { data: originalOption } = await supabase
    .from('survey_response_options')
    .select('score')
    .eq('option_id', originalResponse?.response_option_id)
    .single();

  // Upsert effective response
  const { error } = await supabase
    .from('patient_effective_responses')
    .upsert({
      user_id: userId,
      question_number: questionNumber,
      original_response_option_id: originalResponse?.response_option_id,
      original_score: originalOption?.score,
      original_response_date: originalResponse?.response_timestamp,
      effective_response_option_id: optionId,
      effective_score: score,
      response_source: 'tracking',
      tracking_agg_metric_id: trackedValue.aggMetricId,
      tracking_avg_value: trackedValue.value,
      tracking_data_points: trackedValue.dataPoints,
      last_updated_at: new Date().toISOString()
    }, {
      onConflict: 'user_id,question_number'
    });
}
```

#### `recalculateScores()`
```javascript
async function recalculateScores(userId) {
  // Call existing scoring functions
  // These already know how to:
  // 1. Use effective_response_option_id from patient_effective_responses
  // 2. Calculate standalone question scores
  // 3. Combine question scores into function scores
  // 4. Weight and aggregate into pillar scores

  const { data, error } = await supabase.rpc('calculate_wellpath_scores', {
    p_user_id: userId
  });

  return data;
}
```

---

## Example Flows

### Example 1: Standalone Question (Fruit Servings)

**Initial State:**
```
Survey (2025-09-01):
  Q2.19: "How many fruit servings per day?"
  Answer: "0" → RO_2.19-1 → Score: 0.2

patient_effective_responses:
  question_number: 2.19
  original_score: 0.2
  effective_score: 0.2
  response_source: 'survey'
```

**After 30 Days of Tracking:**
```
aggregation_results_cache populated:
  AGG_FRUIT_SERVINGS (AVG, monthly): 3.5 servings/day (28 data points)

Edge function executes:
  1. Gets mapping: Q2.19 → AGG_FRUIT_SERVINGS
  2. Checks tracked value: 3.5
  3. Checks data quality: 28 >= 20 ✅
  4. Finds matching threshold: 3.5 falls in [3.0, 4.9] → RO_2.19-3
  5. Updates effective response:
       effective_response_option_id: RO_2.19-3
       effective_score: 0.7
       response_source: 'tracking'
  6. Recalculates scores → Nutrition pillar improves!

patient_effective_responses:
  question_number: 2.19
  original_score: 0.2 (unchanged)
  effective_score: 0.7 (improved!)
  response_source: 'tracking'
  tracking_avg_value: 3.5
```

### Example 2: Function-Based Question (Cardio)

**Initial State:**
```
Survey (2025-09-01):
  Q3.04: "How often do you do cardio?"
  Answer: "1-2 times per week" → RO_3.04-2 → Score: 0.4

  Q3.08: "How long per session?"
  Answer: "0-60 minutes" → RO_3.08-1 → Score: 0.2

movement_cardio_score function combines:
  (0.4 + 0.2) / 2 = 0.3
```

**After Tracking:**
```
aggregation_results_cache:
  AGG_CARDIO_SESSION_COUNT (AVG, weekly): 3.5 sessions/week (24 points)
  AGG_CARDIO_DURATION (SUM, weekly): 130 min/week (24 points)

Edge function executes:

  For Q3.04:
    1. Gets mapping: Q3.04 → AGG_CARDIO_SESSION_COUNT
    2. Tracked value: 3.5 sessions/week
    3. Data quality: 24 >= 3 ✅
    4. Matches threshold: [3, 4] → RO_3.04-3
    5. Updates effective response: score 0.7

  For Q3.08:
    1. Gets mapping: Q3.08 → AGG_CARDIO_DURATION
    2. Tracked value: 130 min/week
    3. Data quality: 24 >= 3 ✅
    4. Matches threshold: [121, 150] → RO_3.08-3
    5. Updates effective response: score 0.8

  Existing movement_cardio_score function recalculates:
    Now uses effective responses for Q3.04 (0.7) and Q3.08 (0.8)
    New function score: (0.7 + 0.8) / 2 = 0.75
    Improvement: 0.75 - 0.3 = +0.45 (150% better!)
```

**Key Point**: The edge function doesn't know about `movement_cardio_score`. It just updates Q3.04 and Q3.08 effective responses. The existing scoring function automatically recalculates because those question scores changed!

### Example 3: Substance (Alcohol) - Complex Flow

**Initial State (Current User):**
```
Survey (2025-09-01):
  Q8.01: "Currently using?" → Selected: "Alcohol"
  Q8.05: "How would you describe current use?"
  Answer: "Moderate (2-4 drinks per day)" → RO_8.05-2 → Score: 0.5
```

**After Tracking:**
```
aggregation_results_cache:
  AGG_ALCOHOLIC_DRINKS (SUM, weekly): 3 drinks/week (26 points)

Edge function executes:
  1. Gets mapping: Q8.05 → AGG_ALCOHOLIC_DRINKS
  2. Tracked value: 3 drinks/week
  3. Data quality: 26 >= 3 ✅
  4. Matches threshold: [1, 4] → RO_8.05-4 ("Minimal")
  5. Updates effective response: score 0.8

  substance_alcohol_score function recalculates automatically
  Patient score improves from 0.5 → 0.8!
```

**Former User (Time-Based Update):**
```
Survey (2025-09-01):
  Q8.01: "Currently using?" → NOT selected
  Q8.20: "Used in past?" → Selected: "Alcohol"
  Q8.24: "How long since you quit?"
  Answer: "6 months ago" → RO_8.24-3

Edge function calculates:
  time_since_cessation = DATEDIFF(today, survey_date) + 6 months
  = 6 months (elapsed) + 6 months (from survey) = 12 months

  Finds new threshold for 12 months
  Updates effective response to better score
  (No tracking data needed!)
```

---

## Trigger Integration

The edge function can be called:

### 1. On Aggregation Cache Update (Trigger)
```sql
CREATE TRIGGER aggregation_cache_updates_effective_responses
AFTER INSERT OR UPDATE ON aggregation_results_cache
FOR EACH ROW
EXECUTE FUNCTION trigger_update_effective_responses();
```

### 2. On Demand (API Endpoint)
```javascript
// POST /api/scores/refresh
export async function POST(request) {
  const { userId } = await request.json();

  // Call edge function
  const result = await updateDynamicScores(userId);

  return Response.json({ success: true, result });
}
```

### 3. Scheduled Job (Daily)
```javascript
// Deno.cron or similar
Deno.cron("Update all patient scores", "0 2 * * *", async () => {
  const { data: activeUsers } = await supabase
    .from('patient_details')
    .select('user_id')
    .eq('is_active', true);

  for (const user of activeUsers) {
    await updateDynamicScores(user.user_id);
  }
});
```

---

## Data Quality Considerations

### Minimum Data Points
Different metrics have different requirements:
- **Nutrition**: 20 data points over 30 days
- **Exercise**: 3-15 data points over 30 days (depends on frequency)
- **Substances**: 3 data points (lower threshold for critical metrics)

### Confidence Levels
```javascript
function getConfidenceLevel(dataPoints, minRequired) {
  if (dataPoints >= minRequired * 2) return 'high';
  if (dataPoints >= minRequired * 1.5) return 'medium';
  if (dataPoints >= minRequired) return 'low';
  return 'insufficient';
}
```

### Fallback to Survey
```javascript
// If tracked data insufficient, keep survey response
if (!trackedValue || trackedValue.dataPoints < mapping.min_data_points) {
  // Don't update effective response
  // Existing survey-based score remains
  continue;
}
```

---

## Testing Checklist

- [ ] Standalone question updates correctly
- [ ] Function-based question updates and function recalculates
- [ ] Insufficient data keeps survey response
- [ ] Data quality thresholds enforced
- [ ] Multiple metrics for one question handled
- [ ] Time-based updates (former substance users)
- [ ] Edge cases: no survey response, no tracking data
- [ ] Performance: bulk updates for 100+ patients

---

## Key Takeaways

1. **Unified Approach**: ALL questions work the same way (response options → agg metrics)
2. **Edge Function Simplicity**: Just update `patient_effective_responses`
3. **Existing Logic Reuse**: Scoring functions don't need changes
4. **Automatic Recalculation**: Functions recalculate when question scores change
5. **Data Quality First**: Require sufficient tracking before overriding survey

This architecture is clean, maintainable, and leverages existing WellPath scoring logic!
