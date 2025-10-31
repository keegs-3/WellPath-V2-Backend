# Survey Response Options to Aggregation Metrics Mappings

## Overview

This document describes the comprehensive mappings created between WellPath survey response options and aggregation metrics to enable dynamic score updating based on patient tracking data.

## Migration File

**Location:** `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251022_complete_survey_aggregation_mappings.sql`

## Summary Statistics

- **Total Mappings Created:** 116
- **Unique Questions Mapped:** 24
- **Unique Metrics Used:** 27
- **Unique Response Options Mapped:** 107

## Mappings by Category

### Section 2: Nutrition (52 mappings)

#### Key Questions Mapped:

1. **Q2.13: Processed Meat Consumption**
   - Metric: `AGG_PROCESSED_MEAT_SERVING`
   - Calculation: SUM (weekly frequency)
   - 5 response options mapped (Rarely to 5+ times/week)

2. **Q2.15: Fatty Fish Consumption**
   - Metric: `AGG_FATTY_FISH_SERVINGS`
   - Calculation: SUM (weekly frequency)
   - 5 response options mapped

3. **Q2.17: Plant-Based Protein Percentage**
   - Metric: `AGG_PLANTBASED_PROTEIN_PERCENTAGE`
   - Calculation: AVG (monthly percentage)
   - 5 response options mapped (0-10% to 90-100%)

4. **Q2.19: Daily Fruit Servings (VALIDATION EXAMPLE)**
   - Metrics: `AGG_FRUIT_SERVINGS` + `AGG_FRUIT_VARIETY`
   - Calculation: AVG (servings) + COUNT_DISTINCT (variety)
   - 4 response options mapped, 7 total mappings (dual metric tracking)
   - Example thresholds:
     - "0" → 0-0.9 servings
     - "1-2" → 1.0-2.9 servings
     - "3-4" → 3.0-4.9 servings
     - "5 or more" → 5.0-999 servings

5. **Q2.21: Whole Grain Consumption**
   - Metrics: `AGG_WHOLE_GRAIN_SERVINGS` + `AGG_WHOLE_GRAIN_VARIETY`
   - Calculation: SUM (weekly) + COUNT_DISTINCT (variety)
   - 7 total mappings

6. **Q2.23: Legume Consumption**
   - Metrics: `AGG_LEGUME_SERVINGS` + `AGG_LEGUME_VARIETY`
   - Calculation: SUM (weekly) + COUNT_DISTINCT (variety)
   - 7 total mappings

7. **Q2.25: Seed Consumption**
   - Metric: `AGG_SEED_SERVINGS`
   - Calculation: SUM (weekly frequency)
   - 4 response options mapped

8. **Q2.27: Healthy Fat Consumption**
   - Metric: `AGG_FAT_SERVINGS`
   - Calculation: SUM (weekly frequency)
   - 4 response options mapped

9. **Q2.29: Daily Water Intake**
   - Metric: `AGG_WATER_CONSUMPTION`
   - Calculation: AVG (liters per day)
   - 3 response options mapped
   - Example thresholds:
     - "Less than 1 liter" → 0-0.9 L
     - "1-2 liters" → 1.0-2.9 L
     - "More than 2 liters" → 2.0-999 L

10. **Q2.31: Daily Caffeine Consumption**
    - Metric: `AGG_CAFFEINE_CONSUMED`
    - Calculation: AVG (mg per day)
    - 5 response options mapped
    - Example thresholds:
      - "None" → 0 mg
      - "<100 mg" → 1-99 mg
      - "100-200 mg" → 100-200 mg
      - "201-400 mg" → 201-400 mg
      - ">400 mg" → 400-999 mg

### Section 3: Exercise (38 mappings)

#### Key Questions Mapped:

1. **Q3.04: Cardio Frequency**
   - Metric: `AGG_CARDIO_SESSION_COUNT`
   - Calculation: SUM (sessions per week)
   - 4 response options mapped

2. **Q3.05: Strength Training Frequency**
   - Metric: `AGG_STRENGTH_SESSION_COUNT`
   - Calculation: SUM (sessions per week)
   - 4 response options mapped

3. **Q3.06: Flexibility/Mobility Frequency**
   - Metric: `AGG_MOBILITY_SESSION_COUNT`
   - Calculation: SUM (sessions per week)
   - 4 response options mapped

4. **Q3.07: HIIT Frequency**
   - Metric: `AGG_HIIT_SESSION_COUNT`
   - Calculation: SUM (sessions per week)
   - 4 response options mapped

5. **Q3.08: Daily Cardio Duration**
   - Metric: `AGG_CARDIO_DURATION`
   - Calculation: AVG (minutes per session day)
   - 4 response options mapped
   - Example thresholds:
     - "Less than 30 minutes" → 0-29 min
     - "30-45 minutes" → 30-45 min
     - "45-60 minutes" → 45-60 min
     - "More than 60 minutes" → 60-999 min

6. **Q3.09: Strength Training Duration**
   - Metric: `AGG_CALCULATED_EXERCISE_TIME`
   - Calculation: AVG (minutes per session day)
   - 4 response options mapped

7. **Q3.10: Mobility Duration**
   - Metric: `AGG_MOBILITY_DURATION`
   - Calculation: AVG (minutes per session day)
   - 4 response options mapped

8. **Q3.11: HIIT Duration**
   - Metric: `AGG_HIIT_DURATION`
   - Calculation: AVG (minutes per session day)
   - 4 response options mapped

9. **Q3.21: Daily Step Count**
   - Metric: `AGG_STEPS`
   - Calculation: AVG (steps per day)
   - 6 response options mapped (excluding "I'm not sure")
   - Example thresholds:
     - "Less than 2,500" → 0-2499 steps
     - "2,500-5,000" → 2500-4999 steps
     - "5,000-7,500" → 5000-7499 steps
     - "7,500-10,000" → 7500-9999 steps
     - "10,000-15,000" → 10000-14999 steps
     - "More than 15,000" → 15000-99999 steps

### Section 4: Sleep (12 mappings)

#### Key Questions Mapped:

1. **Q4.01: Sleep Quality Rating**
   - Metric: `AGG_SLEEP_QUALITY`
   - Calculation: AVG (1-5 rating scale)
   - 5 response options mapped
   - Example thresholds:
     - "Poor" → 1-2 rating
     - "Fair" → 2-3 rating
     - "Good" → 3-4 rating
     - "Very Good" → 4-5 rating
     - "Excellent" → 4.5-5 rating

2. **Q4.02: Nightly Sleep Duration**
   - Metric: `AGG_SLEEP_DURATION`
   - Calculation: AVG (minutes)
   - 7 response options mapped
   - Example thresholds:
     - "4 hours or less" → 0-240 min
     - "5 hours" → 270-330 min (300 ±30)
     - "6 hours" → 330-390 min (360 ±30)
     - "7 hours" → 390-450 min (420 ±30)
     - "8 hours" → 450-510 min (480 ±30)
     - "9 hours" → 510-570 min (540 ±30)
     - "More than 9 hours" → 540-999 min

### Section 5: Cognitive Health (4 mappings)

#### Key Questions Mapped:

1. **Q5.06: Brain Training Frequency**
   - Metric: `AGG_BRAIN_TRAINING_SESSION_COUNT`
   - Calculation: SUM (sessions per week)
   - 4 response options mapped

### Section 8: Substance Use (10 mappings)

#### Key Questions Mapped:

1. **Q8.02: Tobacco/Cigarette Use**
   - Metric: `AGG_CIGARETTES`
   - Calculation: AVG (cigarette equivalents per day)
   - 5 response options mapped
   - Example thresholds:
     - "Heavy: 2+ packs/day" → 40-999 cigarettes
     - "Moderate: 1 pack/day" → 20-40 cigarettes
     - "Light: <1 pack/day" → 5-19 cigarettes
     - "Minimal: Few/month" → 1-4 cigarettes/day avg
     - "Occasional: Rarely" → 0-0.5 cigarettes/day avg

2. **Q8.05: Alcohol Consumption**
   - Metric: `AGG_ALCOHOLIC_DRINKS`
   - Calculation: AVG (drinks per day)
   - 5 response options mapped
   - Example thresholds:
     - "Heavy: 5+ drinks/day" → 5-999 drinks
     - "Moderate: 2-4 drinks/day" → 2-4.9 drinks
     - "Light: 1 drink/day" → 1-1.9 drinks
     - "Minimal: Few/month" → 0-0.5 drinks
     - "Occasional: Rarely" → 0-0.1 drinks

## Parsing Logic Examples

### Frequency Text to Numeric Ranges

| Response Text | Threshold Low | Threshold High | Context |
|--------------|---------------|----------------|---------|
| "Rarely or never" | 0 | 0 | No activity |
| "Once a week" | 1.0 | 1.9 | Weekly context |
| "Several times a week" | 3.0 | 4.9 | Weekly context (3-4x) |
| "Daily" | 7.0 | 999 | Weekly context (7x) |
| "Occasionally (1-2 times per week)" | 1.0 | 2.9 | Weekly sessions |
| "Regularly (3-4 times per week)" | 3.0 | 4.9 | Weekly sessions |
| "Frequently (5+ times per week)" | 5.0 | 999 | Weekly sessions |

### Quantity Text to Numeric Ranges

| Response Text | Threshold Low | Threshold High | Unit |
|--------------|---------------|----------------|------|
| "0" | 0 | 0.9 | servings |
| "1-2" | 1.0 | 2.9 | servings |
| "3-4" | 3.0 | 4.9 | servings |
| "5 or more" | 5.0 | 999 | servings |
| "Less than 1 liter" | 0 | 0.9 | liters |
| "1-2 liters" | 1.0 | 2.9 | liters |
| "More than 2 liters" | 2.0 | 999 | liters |

### Duration Text to Numeric Ranges

| Response Text | Threshold Low | Threshold High | Unit |
|--------------|---------------|----------------|------|
| "Less than 30 minutes" | 0 | 29 | minutes |
| "30-45 minutes" | 30 | 45 | minutes |
| "45-60 minutes" | 45 | 60 | minutes |
| "More than 60 minutes" | 60 | 999 | minutes |

### Quality Ratings to Numeric Ranges

| Response Text | Threshold Low | Threshold High | Scale |
|--------------|---------------|----------------|-------|
| "Poor" | 1 | 2 | 1-5 rating |
| "Fair" | 2 | 3 | 1-5 rating |
| "Good" | 3 | 4 | 1-5 rating |
| "Very Good" | 4 | 5 | 1-5 rating |
| "Excellent" | 4.5 | 5 | 1-5 rating |

## Calculation Type Guidelines

### When to Use SUM

Use for counting discrete events over a time period:
- Session counts (cardio sessions, strength sessions per week)
- Frequency-based metrics (times per week/month)
- Total consumption counts (servings per week)

**Examples:**
- Q3.04 Cardio frequency: SUM of weekly sessions
- Q2.21 Whole grain frequency: SUM of weekly servings

### When to Use AVG

Use for continuous measurements or ratings:
- Daily quantities averaged over time (servings per day)
- Durations (average sleep duration, average exercise time)
- Ratings (average stress level, average sleep quality)
- Continuous tracking (daily water intake, daily steps)

**Examples:**
- Q2.19 Fruit servings: AVG servings per day over month
- Q4.02 Sleep duration: AVG minutes per night over month
- Q4.01 Sleep quality: AVG rating over month

### When to Use COUNT_DISTINCT

Use for measuring variety/diversity:
- Unique types consumed (fruit variety, vegetable variety)
- Dietary diversity tracking

**Examples:**
- Q2.19 Fruit servings: COUNT_DISTINCT fruit types
- Q2.23 Legume consumption: COUNT_DISTINCT legume types

## Period Type Guidelines

### Weekly Period

Use for activities tracked by sessions per week:
- Exercise session counts
- Weekly frequency questions
- Substance use patterns

**Data Collection:** Sum activities over rolling 7-day window

### Monthly Period

Use for daily averages calculated over longer periods:
- Daily serving averages (fruit servings per day)
- Daily quantity averages (protein grams per day)
- Quality ratings averaged over time
- Continuous daily tracking

**Data Collection:** Average daily values over rolling 30-day window

### Daily Period

Use for metrics naturally measured daily:
- Step counts
- Screen time

**Data Collection:** Direct daily values over rolling window

## Data Quality Requirements

### Conservative (High Quality Needed)

**Parameters:** min_data_points: 20, lookback_days: 30

**Use For:**
- Nutrition servings (fruit, vegetables, etc.)
- Sleep duration and quality
- Key behavioral metrics impacting longevity scores

**Rationale:** These metrics directly impact major health scores and require high confidence

### Moderate

**Parameters:** min_data_points: 15, lookback_days: 30

**Use For:**
- Quality ratings
- Less critical behavioral metrics
- Substance use tracking

**Rationale:** Important but can tolerate slightly lower data density

### Relaxed

**Parameters:** min_data_points: 10, lookback_days: 30

**Use For:**
- Exercise session counts (intermittent activity)
- Variety metrics (diversity tracking)
- HIIT, meditation, brain training (less frequent activities)

**Rationale:** These activities may occur less frequently but are still meaningful

## Advanced Features: Dual-Metric Tracking

Some questions are mapped to **two different metrics** to capture both quantity AND quality:

### Example: Q2.19 Fruit Servings

**Mapping 1: Quantity**
- Metric: `AGG_FRUIT_SERVINGS`
- Calculation: AVG (servings per day)
- Purpose: Track daily consumption amount

**Mapping 2: Variety**
- Metric: `AGG_FRUIT_VARIETY`
- Calculation: COUNT_DISTINCT (unique types)
- Purpose: Track dietary diversity

**Why Both?**
- A patient eating "5 or more" servings suggests they're consuming diverse fruit types
- Higher servings correlate with higher variety
- Variety is independently important for nutritional diversity

**Similar Dual Mappings:**
- Q2.21: Whole grains (servings + variety)
- Q2.23: Legumes (servings + variety)

## Usage Examples

### Example 1: Updating Fruit Servings Score

**Scenario:** Patient originally answered "1-2 servings" on survey but now tracks 3.5 servings/day average over 30 days.

**Query to Check:**
```sql
SELECT
    sroa.response_option_id,
    sroa.threshold_low,
    sroa.threshold_high,
    sroa.agg_metric_id,
    3.5 BETWEEN sroa.threshold_low AND sroa.threshold_high as matches
FROM survey_response_options_aggregations sroa
WHERE sroa.question_number = 2.19
  AND sroa.agg_metric_id = 'AGG_FRUIT_SERVINGS';
```

**Result:**
- Original answer: RO_2.19-2 (1-2 servings, threshold 1.0-2.9)
- Actual tracking: 3.5 servings
- New match: RO_2.19-3 (3-4 servings, threshold 3.0-4.9)
- **Action:** Update survey response to RO_2.19-3, recalculate nutrition score

### Example 2: Checking Cardio Frequency Alignment

**Scenario:** Patient answered "Regularly (3-4x/week)" but HealthKit shows only 2.1 sessions/week average.

**Query:**
```sql
SELECT
    sro.option_text,
    sroa.threshold_low,
    sroa.threshold_high,
    2.1 BETWEEN sroa.threshold_low AND sroa.threshold_high as matches
FROM survey_response_options_aggregations sroa
JOIN survey_response_options sro ON sro.option_id = sroa.response_option_id
WHERE sroa.question_number = 3.04;
```

**Result:**
- Original answer: "Regularly (3-4 times per week)" (threshold 3.0-4.9)
- Actual tracking: 2.1 sessions/week
- New match: "Occasionally (1-2 times per week)" (threshold 1.0-2.9)
- **Action:** Flag discrepancy, suggest survey update

### Example 3: Sleep Duration Quality Check

**Scenario:** Verify patient's sleep tracking meets minimum data requirements.

**Query:**
```sql
SELECT
    COUNT(DISTINCT DATE(sleep_start)) as days_with_data,
    sroa.min_data_points,
    COUNT(DISTINCT DATE(sleep_start)) >= sroa.min_data_points as sufficient_data
FROM patient_healthkit_events phe
JOIN survey_response_options_aggregations sroa
    ON sroa.agg_metric_id = 'AGG_SLEEP_DURATION'
WHERE phe.patient_id = 'PATIENT_123'
  AND phe.event_date >= CURRENT_DATE - INTERVAL '30 days'
  AND phe.event_type_id = 'sleep'
GROUP BY sroa.min_data_points;
```

## Questions Not Mapped (Future Enhancements)

The following questions could not be mapped due to missing aggregation metrics:

### Section 4: Sleep
- **Q4.03:** "How often do you feel rested upon waking?"
  - Missing metric: AGG_SLEEP_RESTEDNESS or AGG_SLEEP_REFRESHED
- **Q4.04:** "How consistent is your sleep schedule?"
  - Missing metric: AGG_SLEEP_CONSISTENCY or AGG_SLEEP_SCHEDULE_VARIANCE

### Section 5: Cognitive Health
- **Q5.01:** "How would you rate your current cognitive function?"
  - Missing metric: AGG_COGNITIVE_FUNCTION_RATING

### Section 6: Stress
- **Q6.01:** "How would you rate your current level of stress?"
  - Response options need verification
- **Q6.02:** "How often do you feel stressed?"
  - Response options need verification

### Section 2: Nutrition
- **Q2.11:** "How many grams of protein do you typically consume per day?"
  - Free response question - needs special handling
  - Could map to AGG_PROTEIN_GRAMS once structured

### Meditation/Breathwork
Available metrics but no matching survey questions identified:
- AGG_MEDITATION_SESSIONS
- AGG_BREATHWORK_SESSIONS
- AGG_MEDITATION_DURATION
- AGG_BREATHWORK_DURATION

## Database Schema Reference

### Table: survey_response_options_aggregations

```sql
CREATE TABLE survey_response_options_aggregations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    response_option_id TEXT NOT NULL,
    question_number NUMERIC NOT NULL,
    agg_metric_id TEXT NOT NULL,
    threshold_low NUMERIC,
    threshold_high NUMERIC,
    calculation_type_id TEXT,
    period_type TEXT,
    min_data_points INTEGER DEFAULT 20,
    lookback_days INTEGER DEFAULT 30,
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(response_option_id, agg_metric_id)
);
```

## Validation and Testing

### Validation Example: Q2.19 Fruit Servings

The migration includes Q2.19 as a **validation example** with all 4 response options fully mapped:

```sql
SELECT
    sro.option_text,
    sroa.agg_metric_id,
    sroa.threshold_low,
    sroa.threshold_high,
    sroa.calculation_type_id,
    sroa.period_type
FROM survey_response_options_aggregations sroa
JOIN survey_response_options sro ON sro.option_id = sroa.response_option_id
WHERE sroa.question_number = 2.19
ORDER BY sroa.threshold_low;
```

**Expected Output:**
| option_text | agg_metric_id | threshold_low | threshold_high | calculation_type_id | period_type |
|-------------|---------------|---------------|----------------|---------------------|-------------|
| 0 | AGG_FRUIT_SERVINGS | 0 | 0.9 | AVG | monthly |
| 1-2 | AGG_FRUIT_SERVINGS | 1.0 | 2.9 | AVG | monthly |
| 1-2 | AGG_FRUIT_VARIETY | 1 | 3 | COUNT_DISTINCT | monthly |
| 3-4 | AGG_FRUIT_SERVINGS | 3.0 | 4.9 | AVG | monthly |
| 3-4 | AGG_FRUIT_VARIETY | 3 | 5 | COUNT_DISTINCT | monthly |
| 5 or more | AGG_FRUIT_SERVINGS | 5.0 | 999 | AVG | monthly |
| 5 or more | AGG_FRUIT_VARIETY | 5 | 999 | COUNT_DISTINCT | monthly |

## Performance Considerations

### Indexing

The table includes indexes on:
- `question_number` - for quick question lookup
- `agg_metric_id` - for metric-based queries
- `(response_option_id, agg_metric_id)` - unique constraint + lookup optimization

### Query Optimization

When checking if tracked data matches a survey response:

```sql
-- GOOD: Uses indexed columns
SELECT * FROM survey_response_options_aggregations
WHERE question_number = 2.19
  AND agg_metric_id = 'AGG_FRUIT_SERVINGS'
  AND 3.5 BETWEEN threshold_low AND threshold_high;

-- AVOID: No index on threshold_low/high, requires full scan
SELECT * FROM survey_response_options_aggregations
WHERE threshold_low <= 3.5 AND threshold_high >= 3.5;
```

## Maintenance and Updates

### Adding New Mappings

To add new mappings without running the full migration:

```sql
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high,
 calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_X.XX-X', X.XX, 'AGG_METRIC_NAME', low, high, 'AVG', 'monthly', 20, 30, 'Description');
```

### Updating Thresholds

If threshold ranges need adjustment:

```sql
UPDATE survey_response_options_aggregations
SET threshold_low = new_low,
    threshold_high = new_high,
    updated_at = now()
WHERE response_option_id = 'RO_X.XX-X'
  AND agg_metric_id = 'AGG_METRIC_NAME';
```

### Disabling Mappings

To disable a mapping without deleting:

```sql
UPDATE survey_response_options_aggregations
SET is_active = false,
    updated_at = now()
WHERE response_option_id = 'RO_X.XX-X';
```

## Success Metrics

### Coverage Achieved

- **24 distinct questions** mapped across all behavior categories
- **27 different aggregation metrics** utilized
- **116 total mappings** created (including dual-metric tracking)
- **107 unique response options** covered

### Categories Covered

- Nutrition: 10 questions, 52 mappings (45% of total)
- Exercise: 9 questions, 38 mappings (33% of total)
- Sleep: 2 questions, 12 mappings (10% of total)
- Cognitive: 1 question, 4 mappings (3% of total)
- Substances: 2 questions, 10 mappings (9% of total)

### Quality Achievements

- All major behavior categories represented
- Intelligent threshold parsing for text-based responses
- Appropriate calculation types and periods selected
- Conservative data quality requirements for critical metrics
- Dual-metric tracking for comprehensive nutrition assessment
- Variety metrics included for dietary diversity

## Next Steps

1. **Test with Real Patient Data:** Validate thresholds align with actual tracking data
2. **Build Score Update Logic:** Create functions to check aggregations against thresholds
3. **Add Missing Metrics:** Work with data team to create missing aggregation metrics
4. **Expand Coverage:** Map additional stress, meditation, and cognitive questions
5. **Implement Alerts:** Notify patients when tracking data suggests survey updates
6. **Create Dashboard:** Visualize alignment between survey responses and actual behavior

## Contact and Support

For questions about these mappings or to request additions:
- Review the migration file: `supabase/migrations/20251022_complete_survey_aggregation_mappings.sql`
- Check mapping details in database: `survey_response_options_aggregations` table
- Validate against source tables: `survey_questions_base`, `survey_response_options`, `aggregation_metrics`
