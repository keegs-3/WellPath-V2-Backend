# Dynamic Scoring Deployment Checklist

## Database Migrations ✅ COMPLETE

All migrations have been applied. Current state:

```sql
-- Verify mappings
SELECT COUNT(*) FROM survey_response_options_aggregations;
-- Should return: 159

SELECT COUNT(*) FROM biometric_aggregations_scoring;
-- Should return: 146 (after running 20251022_add_remaining_biometric_scoring_ranges.sql)

SELECT COUNT(*) FROM patient_effective_responses;
-- Should return: 0 (will populate when edge function runs)
```

## Edge Functions 📝 TO DEPLOY

### 1. Update Survey Scores
**File**: `supabase/functions/update-survey-scores/index.ts`
**Status**: Created, needs deployment

```bash
supabase functions deploy update-survey-scores
```

**Test**:
```bash
curl -X POST 'https://your-project.supabase.co/functions/v1/update-survey-scores' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"userId": "1758fa60-a306-440e-8ae6-9e68fd502bc2"}'
```

### 2. Update Biometric Scores
**File**: `supabase/functions/update-biometric-scores/index.ts`
**Status**: Created, needs deployment

```bash
supabase functions deploy update-biometric-scores
```

**Test**:
```bash
curl -X POST 'https://your-project.supabase.co/functions/v1/update-biometric-scores' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"userId": "1758fa60-a306-440e-8ae6-9e68fd502bc2"}'
```

### 3. Modify Existing Calculate Scores (if needed)
**File**: `supabase/functions/calculate-scores/index.ts`
**Change Needed**: Read from `patient_effective_responses` instead of `patient_survey_responses`

**Before**:
```typescript
const { data: responses } = await supabase
  .from('patient_survey_responses')
  .select('response_option_id, survey_response_options(score)')
  .eq('user_id', userId)
```

**After**:
```typescript
const { data: responses } = await supabase
  .from('patient_effective_responses')
  .select('question_number, effective_score, response_source')
  .eq('user_id', userId)
```

## Testing with Test Patient

**Patient ID**: `1758fa60-a306-440e-8ae6-9e68fd502bc2`

### 1. Check Current Survey Responses
```sql
SELECT
    sq.question_number,
    sq.question_text,
    sro.option_text,
    sro.score
FROM patient_survey_responses psr
JOIN survey_response_options sro ON psr.response_option_id = sro.option_id
JOIN survey_questions_base sq ON sro.question_number = sq.question_number
WHERE psr.user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
    AND sq.question_number IN (2.19, 3.04, 3.08, 8.05)
ORDER BY sq.question_number;
```

### 2. Check Tracking Data
```sql
SELECT
    agg_metric_id,
    calculation_type_id,
    period_type,
    value,
    data_point_count,
    period_start,
    period_end
FROM aggregation_results_cache
WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
    AND agg_metric_id IN (
        'AGG_FRUIT_SERVINGS',
        'AGG_CARDIO_SESSION_COUNT',
        'AGG_CARDIO_DURATION',
        'AGG_ALCOHOLIC_DRINKS'
    )
ORDER BY agg_metric_id, period_end DESC;
```

### 3. Run Edge Functions
```bash
# Update survey scores
curl -X POST 'https://your-project.supabase.co/functions/v1/update-survey-scores' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -d '{"userId": "1758fa60-a306-440e-8ae6-9e68fd502bc2"}'

# Update biometric scores
curl -X POST 'https://your-project.supabase.co/functions/v1/update-biometric-scores' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -d '{"userId": "1758fa60-a306-440e-8ae6-9e68fd502bc2"}'
```

### 4. Verify Effective Responses Created
```sql
SELECT
    question_number,
    original_score,
    effective_score,
    response_source,
    tracking_agg_metric_id,
    tracking_avg_value,
    tracking_data_points
FROM patient_effective_responses
WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
ORDER BY question_number;
```

### 5. Check Score Improvements
```sql
SELECT
    question_number,
    original_score,
    effective_score,
    effective_score - original_score as improvement,
    ROUND((effective_score - original_score) / NULLIF(original_score, 0) * 100, 1) as percent_improvement,
    response_source
FROM patient_effective_responses
WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
    AND effective_score > original_score
ORDER BY improvement DESC;
```

## Scheduled Job Setup (Optional)

**Deno Cron** (if using Deno Deploy):
```typescript
// In supabase/functions/scheduled-score-updates/index.ts
Deno.cron("Update all patient scores", "0 2 * * *", async () => {
  const { data: activePatients } = await supabase
    .from('patient_details')
    .select('user_id')
    .eq('is_active', true)

  for (const patient of activePatients) {
    await updateSurveyScores(patient.user_id)
    await updateBiometricScores(patient.user_id)
  }
})
```

**Supabase pg_cron** (if using database scheduling):
```sql
-- Schedule daily at 2 AM
SELECT cron.schedule(
  'update-dynamic-scores',
  '0 2 * * *',
  $$
  -- Call edge function for each active patient
  -- (Implementation depends on how you trigger edge functions from SQL)
  $$
);
```

## Documentation

- ✅ `DYNAMIC_SCORE_UPDATING_ARCHITECTURE.md` - Original design
- ✅ `DYNAMIC_SCORING_CORRECTED_ARCHITECTURE.md` - Simplified approach
- ✅ `EDGE_FUNCTION_DYNAMIC_SCORING.md` - Edge function guide
- ✅ `BIOMETRIC_DYNAMIC_SCORING_MAPPINGS.md` - Biometric mappings
- ✅ `DYNAMIC_SCORING_FINAL_SUMMARY.md` - Complete summary
- ✅ This checklist

## Next Steps

1. [ ] Deploy edge functions to Supabase
2. [ ] Test with patient `1758fa60-a306-440e-8ae6-9e68fd502bc2`
3. [ ] Verify effective responses populate correctly
4. [ ] Verify score improvements show up
5. [ ] Integrate with mobile app API
6. [ ] Set up scheduled job for automatic updates
7. [ ] Monitor performance and data quality

## Support

If issues arise:
1. Check function logs in Supabase dashboard
2. Verify aggregation_results_cache has data
3. Verify mappings exist in survey_response_options_aggregations
4. Check patient has survey responses to compare against
5. Review edge function logic for errors

---

**Status**: Ready for deployment! 🚀
