# Survey Aggregation Mappings - README

## Migration: 20251022_comprehensive_survey_aggregation_mappings.sql

### Purpose

This migration creates comprehensive mappings between survey response options and aggregation metrics, enabling the WellPath scoring system to compare self-reported survey answers with actual tracked behavioral data.

### What It Does

Maps 27 out of 72 survey questions to their corresponding aggregation metrics:
- **122 total response option mappings** created
- **27 unique AGG metrics** referenced
- **14 questions** remapped (previously existed)
- **13 questions** newly mapped
- **45 questions** intentionally NOT mapped (not trackable behaviors)

### Coverage by Category

| Category | Questions Mapped | Total Questions | Coverage |
|----------|------------------|-----------------|----------|
| Nutrition (2.x) | 17 | 19 | 89.5% |
| Movement (3.x) | 1 | 1 | 100% |
| Sleep (4.x) | 3 | 3 | 100% |
| Cognitive (5.x) | 1 | 3 | 33.3% |
| Social (7.x) | 1 | 5 | 20% |
| Core Care (8.x) | 4 | 4 | 100% |
| Family/Personal History (9.x) | 0 | 30 | 0% (intentional) |
| Screening/Mental Health (10.x) | 0 | 7 | 0% (intentional) |

### High-Priority Questions

All critical questions identified in requirements are now mapped:

✅ **Q2.65** - Vegetable servings (was MISSING - now fixed!)
✅ **Q2.67** - Red meat consumption
✅ **Q2.07** - Eating out/takeout frequency
✅ **Q2.34** - Last caffeine time
✅ **Q4.03** - Feel rested upon waking
✅ **Q4.04** - Sleep schedule consistency
✅ **Q8.58** - Flossing frequency
✅ **Q8.60** - Brushing frequency
✅ **Q8.62** - Sunscreen application
✅ **Q7.02** - Social interaction frequency

### Why Only 27/72 Questions?

The remaining 45 questions are intentionally NOT mapped because they represent:

1. **Family/Personal History (30 questions)** - Static survey data about past diagnoses and family history
   - Q9.01-Q9.74: Family history and personal diagnosis questions
   - These are one-time survey responses, not trackable ongoing behaviors

2. **Subjective Ratings (7 questions)** - Quality/satisfaction ratings without trackable metrics
   - Q5.01: Rate cognitive function
   - Q7.01: Quality of relationships
   - Q7.04: Satisfaction with social interaction
   - Q7.07: Have support available
   - Q7.09: Comfort in social situations

3. **Meta Questions (2 questions)** - Questions about tracking behavior itself
   - Q2.09: Do you track protein intake?
   - Q2.59: Do you track calorie intake?

4. **Validated Screening Tools (4 questions)** - PHQ-2/GAD-2 standardized mental health screening
   - Q10.13-Q10.16: Depression and anxiety screening questions
   - These use validated scoring algorithms, not aggregated behavioral data

5. **Past Events (3 questions)** - Previous screenings/tests
   - Q10.09: Cardiac screening
   - Q10.10: Sleep study
   - Q10.11: Immunizations

### How the Mappings Work

Each response option is mapped to threshold ranges for the corresponding aggregation metric:

**Example: Q2.65 Vegetable Servings**
```sql
Response: "1-2 servings" → threshold_low: 1, threshold_high: 2
Tracked Data: AGG_VEGETABLE_SERVINGS
Scoring: If user tracks 3.5 servings/day but says "1-2", score uses tracked data (higher is better)
```

### Threshold Interpretation

- `threshold_low` = NULL: No lower bound (includes 0)
- `threshold_high` = NULL: No upper bound (unlimited)
- Both specified: Value should fall within range
- Period type: daily, weekly, or monthly aggregation

### Calculation Types Used

- **CALC_SUM**: Sum total amounts (servings, quantity, duration)
- **CALC_COUNT**: Count occurrences (sessions, meals, events)
- **CALC_COUNT_DISTINCT**: Count unique items (caffeine sources, food variety)
- **CALC_AVERAGE**: Average rating/score (sleep quality, subjective ratings)
- **CALC_PERCENTAGE**: Percentage calculations (plant-based protein %)
- **CALC_CONSISTENCY**: Consistency scores (sleep schedule variance)
- **CALC_ADHERENCE**: Adherence rates (skincare routine compliance)
- **CALC_LAST_TIME**: Time of last event (last caffeine consumption)

### Data Quality Parameters

Each mapping includes:
- `min_data_points`: 20 (default) - Minimum tracked data points needed
- `lookback_days`: 30 (default) - Days to look back for aggregated data

### Deployment

**Status:** ✅ Successfully deployed and tested

**Validation:**
- All 27 AGG metrics exist in `aggregation_metrics` table
- All response_option_ids exist in `survey_response_options` table
- All calculation_type_ids are valid
- Unique constraint enforced on (response_option_id, agg_metric_id)

### Impact

**Scoring System:**
- Can now compare survey responses to actual tracked behaviors
- More accurate personalized scores based on real data
- Identifies discrepancies between self-reported and tracked behaviors

**User Experience:**
- Users see scores that reflect actual behavior, not just survey responses
- Gamification: Improving tracked behaviors improves scores automatically
- Transparency: Can show when scores use tracked vs survey data

### Next Steps

1. **Verify Data Population**
   - Confirm AGG metrics are being populated with real user data
   - Monitor data quality and coverage

2. **Test Scoring Integration**
   - Verify scoring engine uses these mappings correctly
   - Test edge cases (missing data, conflicting survey vs tracked)

3. **Monitor Performance**
   - Track query performance with 122 mappings
   - Consider caching for frequently-accessed mappings

4. **Future Enhancements**
   - Add mappings for subjective ratings if we implement mood/quality tracking
   - Explore social connection quality tracking beyond frequency

### Database Schema

**Table:** `survey_response_options_aggregations`

**Columns:**
- `id`: UUID primary key
- `response_option_id`: References survey_response_options
- `question_number`: References survey_questions_base
- `agg_metric_id`: References aggregation_metrics
- `threshold_low`: Numeric (nullable)
- `threshold_high`: Numeric (nullable)
- `calculation_type_id`: Text (nullable)
- `period_type`: Text (nullable) - daily, weekly, monthly
- `min_data_points`: Integer (default 20)
- `lookback_days`: Integer (default 30)
- `notes`: Text (nullable)
- `is_active`: Boolean (default true)
- `created_at`: Timestamp
- `updated_at`: Timestamp

**Indexes:**
- Primary key on `id`
- Unique constraint on `(response_option_id, agg_metric_id)`
- Index on `question_number`
- Index on `agg_metric_id`

### Rollback

To remove all mappings:
```sql
DELETE FROM survey_response_options_aggregations;
```

To restore previous state (14 original mappings only):
- Run migration prior to 20251022

### Questions?

For questions or issues, see:
- Main documentation: `COMPREHENSIVE_SURVEY_AGGREGATION_MAPPINGS_COMPLETE.md`
- Scoring flow: `WELLPATH_SCORING_FLOW_STATUS.md`
- Aggregation metrics: `TRACKED_METRICS_E2E_PIPELINE.md`
