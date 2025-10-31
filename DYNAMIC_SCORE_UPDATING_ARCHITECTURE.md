# Dynamic WellPath Score Updating Architecture

## Problem Statement

WellPath scores are currently static based on one-time survey responses. However, patient behaviors change over time through daily tracking. Scores should automatically update to reflect current behavior patterns, not just initial survey responses.

## Scoring Components

### 1. **Biomarkers** (Static)
- Tested every 3-4 months
- Input source: Clinician web application only
- Stored in: `patient_biomarker_readings`
- Scoring: Based on `biomarkers_detail` ranges
- **No dynamic updating needed**

### 2. **Biometrics** (Dynamic)
- Initial values: From clinician web application
- Ongoing tracking: From `patient_data_entries` (weight, blood pressure, etc.)
- Aggregated via: `aggregation_metrics` → `aggregation_results_cache`
- Scoring: Map to `biometrics_detail` ranges
- **Needs dynamic updating**

### 3. **Behaviors** (Dynamic)
- Initial values: From survey questionnaire responses
- Ongoing tracking: From `patient_data_entries` (fruit servings, exercise, sleep, etc.)
- Aggregated via: `aggregation_metrics` → `aggregation_results_cache`
- Scoring: Map tracked values back to survey response option ranges
- **Needs dynamic updating**

### 4. **Education** (Dynamic)
- Starts at 0
- Increases based on engagement with educational content
- 2.5 points per article (stay 30+ seconds)
- Max 10 points per pillar
- **Already dynamic via `education_patient_engagement`**

## Example: Fruit Servings (Question 2.19)

### Current Static Flow
1. Patient answers Q2.19: "0 servings" → RO_2.19-1
2. Score assigned: 0.2
3. Score remains 0.2 forever

### Desired Dynamic Flow
1. Patient answers Q2.19: "0 servings" → RO_2.19-1 → score: 0.2
2. Patient tracks daily fruit intake via app
3. AGG_FRUIT_SERVINGS calculates rolling 30-day average: 3.5 servings/day
4. System maps 3.5 servings → RO_2.19-3 (range: 3-4 servings) → score: 0.7
5. **Effective response updates** from RO_2.19-1 to RO_2.19-3
6. **WellPath score recalculates** with new 0.7 score
7. Patient sees improved score!

### Response Options for Q2.19
| Option ID  | Range      | Score |
|------------|------------|-------|
| RO_2.19-1  | 0          | 0.2   |
| RO_2.19-2  | 1-2        | 0.4   |
| RO_2.19-3  | 3-4        | 0.7   |
| RO_2.19-4  | 5 or more  | 1.0   |

## Architecture Design

### New Tables Needed

#### 1. `survey_response_options_aggregations`
Maps survey response options to aggregation metrics with threshold ranges.

```sql
CREATE TABLE survey_response_options_aggregations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Survey response option
    response_option_id TEXT NOT NULL REFERENCES survey_response_options(option_id),
    question_number NUMERIC NOT NULL,

    -- Aggregation metric
    agg_metric_id TEXT NOT NULL REFERENCES aggregation_metrics(agg_id),

    -- Threshold criteria
    threshold_low NUMERIC,        -- Minimum value for this response option
    threshold_high NUMERIC,       -- Maximum value for this response option
    calculation_type_id TEXT,     -- Which calculation: 'AVG', 'SUM', 'COUNT'
    period_type TEXT,             -- 'daily', 'weekly', 'monthly'

    -- Data quality requirements
    min_data_points INT,          -- Minimum entries required (e.g., 20 days)
    lookback_days INT,            -- Rolling window (e.g., 30 days)

    -- Metadata
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Example: Fruit Servings
INSERT INTO survey_response_options_aggregations VALUES
('...', 'RO_2.19-1', 2.19, 'AGG_FRUIT_SERVINGS', 0.0, 0.9, 'AVG', 'monthly', 20, 30, 'Less than 1 serving per day'),
('...', 'RO_2.19-2', 2.19, 'AGG_FRUIT_SERVINGS', 1.0, 2.9, 'AVG', 'monthly', 20, 30, '1-2 servings per day'),
('...', 'RO_2.19-3', 2.19, 'AGG_FRUIT_SERVINGS', 3.0, 4.9, 'AVG', 'monthly', 20, 30, '3-4 servings per day'),
('...', 'RO_2.19-4', 2.19, 'AGG_FRUIT_SERVINGS', 5.0, 999, 'AVG', 'monthly', 20, 30, '5+ servings per day');
```

#### 2. `biometric_aggregations_scoring`
Maps biometric aggregations to biomarker-style scoring ranges.

```sql
CREATE TABLE biometric_aggregations_scoring (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Biometric aggregation
    agg_metric_id TEXT NOT NULL REFERENCES aggregation_metrics(agg_id),

    -- Scoring range (similar to biomarkers_detail)
    range_name TEXT NOT NULL,
    range_bucket TEXT CHECK (range_bucket IN ('Optimal', 'In-Range', 'Out-of-Range')),
    range_low NUMERIC,
    range_high NUMERIC,
    range_score NUMERIC,  -- Score for this range (0-1)

    -- Demographic filters
    gender TEXT,
    age_low NUMERIC,
    age_high NUMERIC,

    -- Calculation settings
    calculation_type_id TEXT,  -- 'AVG', 'MIN', 'MAX'
    period_type TEXT,          -- 'monthly', 'weekly'
    min_data_points INT,
    lookback_days INT,

    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Example: Weight/BMI
INSERT INTO biometric_aggregations_scoring VALUES
('...', 'AGG_WEIGHT', 'Optimal', 'Optimal', 18.5, 24.9, 1.0, 'all', 18, 120, 'AVG', 'monthly', 10, 30),
('...', 'AGG_WEIGHT', 'Overweight', 'Out-of-Range', 25.0, 29.9, 0.6, 'all', 18, 120, 'AVG', 'monthly', 10, 30),
('...', 'AGG_WEIGHT', 'Obese', 'Out-of-Range', 30.0, 999, 0.2, 'all', 18, 120, 'AVG', 'monthly', 10, 30);
```

#### 3. `patient_effective_responses`
Stores the current "effective" response for each patient-question pair (either survey response OR tracking-based response).

```sql
CREATE TABLE patient_effective_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Patient and question
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    question_number NUMERIC NOT NULL,

    -- Original survey response
    original_response_option_id TEXT REFERENCES survey_response_options(option_id),
    original_score NUMERIC,
    original_response_date TIMESTAMPTZ,

    -- Current effective response (could be tracking-based)
    effective_response_option_id TEXT REFERENCES survey_response_options(option_id),
    effective_score NUMERIC,

    -- How was effective response determined?
    response_source TEXT CHECK (response_source IN ('survey', 'tracking', 'hybrid')),

    -- Tracking metadata (if response_source = 'tracking')
    tracking_agg_metric_id TEXT,
    tracking_avg_value NUMERIC,
    tracking_data_points INT,
    tracking_period_start DATE,
    tracking_period_end DATE,

    -- Timestamps
    last_updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, question_number)
);

-- Example: Patient tracking overrides survey
-- Original survey: 0 fruit servings (score 0.2)
-- Current tracking: 3.5 avg servings over 30 days (score 0.7)
INSERT INTO patient_effective_responses VALUES
('...', '1758fa60-a306-440e-8ae6-9e68fd502bc2', 2.19,
 'RO_2.19-1', 0.2, '2025-09-01',  -- Original survey response
 'RO_2.19-3', 0.7,                -- Effective response from tracking
 'tracking',                      -- Source
 'AGG_FRUIT_SERVINGS', 3.5, 28, '2025-09-23', '2025-10-22',  -- Tracking details
 NOW(), NOW());
```

### New Functions/Triggers

#### 1. Function: `calculate_effective_response(user_id, question_number)`
Determines the effective response for a patient based on their tracking data.

```sql
CREATE OR REPLACE FUNCTION calculate_effective_response(
    p_user_id UUID,
    p_question_number NUMERIC
) RETURNS TABLE (
    effective_response_option_id TEXT,
    effective_score NUMERIC,
    response_source TEXT,
    tracking_value NUMERIC
) AS $$
DECLARE
    v_agg_metric_id TEXT;
    v_calc_type TEXT;
    v_period_type TEXT;
    v_lookback_days INT;
    v_min_data_points INT;
    v_tracking_avg NUMERIC;
    v_data_point_count INT;
BEGIN
    -- Get aggregation metric for this question
    SELECT DISTINCT agg_metric_id, calculation_type_id, period_type, lookback_days, min_data_points
    INTO v_agg_metric_id, v_calc_type, v_period_type, v_lookback_days, v_min_data_points
    FROM survey_response_options_aggregations
    WHERE question_number = p_question_number
    LIMIT 1;

    IF v_agg_metric_id IS NULL THEN
        -- No tracking mapping exists, use survey response
        RETURN QUERY
        SELECT
            psr.response_option_id,
            sro.score,
            'survey'::TEXT,
            NULL::NUMERIC
        FROM patient_survey_responses psr
        JOIN survey_response_options sro ON psr.response_option_id = sro.option_id
        WHERE psr.user_id = p_user_id
            AND sro.question_number = p_question_number;
        RETURN;
    END IF;

    -- Calculate tracking average
    SELECT
        AVG(value) as avg_value,
        COUNT(*) as data_points
    INTO v_tracking_avg, v_data_point_count
    FROM aggregation_results_cache
    WHERE user_id = p_user_id
        AND agg_metric_id = v_agg_metric_id
        AND calculation_type_id = v_calc_type
        AND period_type = v_period_type
        AND period_start >= (NOW() - (v_lookback_days || ' days')::INTERVAL);

    -- Check if we have enough data
    IF v_data_point_count < v_min_data_points THEN
        -- Not enough tracking data, use survey response
        RETURN QUERY
        SELECT
            psr.response_option_id,
            sro.score,
            'survey'::TEXT,
            v_tracking_avg
        FROM patient_survey_responses psr
        JOIN survey_response_options sro ON psr.response_option_id = sro.option_id
        WHERE psr.user_id = p_user_id
            AND sro.question_number = p_question_number;
        RETURN;
    END IF;

    -- Find matching response option based on tracking average
    RETURN QUERY
    SELECT
        sroa.response_option_id,
        sro.score,
        'tracking'::TEXT,
        v_tracking_avg
    FROM survey_response_options_aggregations sroa
    JOIN survey_response_options sro ON sroa.response_option_id = sro.option_id
    WHERE sroa.question_number = p_question_number
        AND v_tracking_avg >= sroa.threshold_low
        AND v_tracking_avg <= sroa.threshold_high
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
```

#### 2. Trigger: Update `patient_effective_responses` when cache updates

```sql
CREATE OR REPLACE FUNCTION update_effective_responses_on_cache_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Find all questions mapped to this aggregation metric
    INSERT INTO patient_effective_responses (
        user_id,
        question_number,
        effective_response_option_id,
        effective_score,
        response_source,
        tracking_agg_metric_id,
        tracking_avg_value,
        last_updated_at
    )
    SELECT
        NEW.user_id,
        sroa.question_number,
        eff.effective_response_option_id,
        eff.effective_score,
        eff.response_source,
        NEW.agg_metric_id,
        eff.tracking_value,
        NOW()
    FROM survey_response_options_aggregations sroa
    CROSS JOIN LATERAL calculate_effective_response(NEW.user_id, sroa.question_number) eff
    WHERE sroa.agg_metric_id = NEW.agg_metric_id
    ON CONFLICT (user_id, question_number)
    DO UPDATE SET
        effective_response_option_id = EXCLUDED.effective_response_option_id,
        effective_score = EXCLUDED.effective_score,
        response_source = EXCLUDED.response_source,
        tracking_avg_value = EXCLUDED.tracking_avg_value,
        last_updated_at = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_effective_responses
AFTER INSERT OR UPDATE ON aggregation_results_cache
FOR EACH ROW
EXECUTE FUNCTION update_effective_responses_on_cache_update();
```

#### 3. View: `patient_current_scores`
Shows current effective scores for all patients for score calculation.

```sql
CREATE OR REPLACE VIEW patient_current_scores AS
SELECT
    per.user_id,
    sq.pillar,
    sq.section_id,
    sq.category_id,
    per.question_number,
    per.effective_score,
    per.response_source,
    sq.question_text
FROM patient_effective_responses per
JOIN survey_questions_base sq ON per.question_number = sq.question_number;
```

## Implementation Plan

### Phase 1: Data Model
1. ✅ Create `survey_response_options_aggregations` table
2. ✅ Create `biometric_aggregations_scoring` table
3. ✅ Create `patient_effective_responses` table

### Phase 2: Mappings
1. Map all behavior survey questions to aggregation metrics
   - Fruit servings (Q2.19) → AGG_FRUIT_SERVINGS
   - Vegetable servings → AGG_VEGETABLE_SERVINGS
   - Protein intake → AGG_PROTEIN_GRAMS
   - Exercise frequency → AGG_CARDIO_SESSION_COUNT, AGG_STRENGTH_SESSION_COUNT
   - Sleep duration → AGG_SLEEP_DURATION
   - Water consumption → AGG_WATER_CONSUMPTION
   - And ~50+ more behavioral questions

2. Define thresholds for each response option range
3. Set data quality requirements (min_data_points, lookback_days)

### Phase 3: Functions & Triggers
1. Create `calculate_effective_response()` function
2. Create trigger on `aggregation_results_cache`
3. Create `patient_current_scores` view
4. Update score calculation to use effective responses

### Phase 4: Testing
1. Populate test patient's survey responses
2. Populate tracking data that differs from survey
3. Verify effective responses update correctly
4. Verify WellPath score recalculates

### Phase 5: Mobile Integration
1. API endpoint: GET `/api/scores/{user_id}/effective-responses`
2. Show comparison: survey response vs tracked behavior
3. Show progress: "You answered 0 servings, but you're now averaging 3.5!"
4. Motivational messaging when scores improve

## Benefits

1. **Dynamic Scoring**: Scores reflect current behavior, not past survey
2. **Motivation**: Patients see score improve as they track consistently
3. **Accurate Assessment**: Real-world data > one-time survey responses
4. **Reduced Survey Burden**: Don't need to retake survey monthly if tracking
5. **Gamification**: Unlock better scores by consistent tracking
6. **Transparency**: Patient sees exactly how tracking impacts their score

## Edge Cases

### 1. Patient stops tracking
- After X days without data, revert to survey response
- Or: Use last known good average (hybrid approach)

### 2. Patient's behavior worsens
- Effective score could go DOWN if tracking shows worse behavior than survey
- This is actually good - encourages honesty and awareness

### 3. Insufficient data points
- Require minimum 20 entries over 30 days to avoid gaming
- One good day shouldn't unlock a high score

### 4. Multiple aggregation metrics for one question
- Example: "How often do you exercise?" could map to cardio + strength + HIIT
- Solution: Create composite score from multiple metrics

## Future Enhancements

1. **Confidence intervals**: Show uncertainty based on data consistency
2. **Trend analysis**: "Your score is improving over time"
3. **Predictions**: "At this rate, you'll reach Optimal in 2 weeks"
4. **Smart suggestions**: "Track 2 more fruit servings to improve your score"
5. **Hybrid scoring**: Weight survey + tracking based on recency and data quality
