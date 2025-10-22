# Edge Function Deployment Status

## Date: 2025-10-17

## Summary

The `calculate-wellpath-score` Edge Function (Version 3.0) has been **successfully deployed** to Supabase, but testing is **blocked by JWT authentication issue**.

---

## Deployment Status

✅ **Edge Function Deployed**
- URL: `https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/calculate-wellpath-score`
- Version: 3.0
- Deployment completed successfully

✅ **Database Migrations Applied**
- `patient_wellpath_score_items` table created
- `wellpath_scoring_*_normalized` views created
- All indexes and RLS policies applied

✅ **Test Data Available**
- Male patient: `1758fa60-a306-440e-8ae6-9e68fd502bc2` (age 56)
- Female patient: `d9581a86-0f30-4be4-ba9e-6ae269700d4d` (age 54)

---

## Blocking Issue: JWT Authentication

### Problem

All attempts to call the Edge Function result in **401 Unauthorized** with message:
```json
{"code":401,"message":"Invalid JWT"}
```

### Attempted Solutions

1. ❌ Using service_role key in Authorization header
2. ❌ Using anon key in Authorization header
3. ❌ Using both apikey and Authorization headers
4. ❌ Using curl vs Node.js Supabase client

### Root Cause

The JWT tokens being used may be expired, incorrect, or the Supabase project JWT settings have changed. The Edge Function code itself doesn't verify JWTs - it uses the service role key internally via env vars (`SUPABASE_SERVICE_ROLE_KEY`). The auth issue is at the Supabase platform level before the function even executes.

### Next Steps to Resolve

1. **Check Supabase Dashboard**
   - Go to Project Settings → API
   - Verify the anon key and service_role key match what we're using
   - Check if JWT Secret has changed

2. **Test from Supabase Dashboard**
   - Go to Edge Functions → calculate-wellpath-score
   - Use the built-in test functionality in the dashboard
   - This bypasses JWT validation

3. **Update API Keys**
   - If keys have changed, update them in test scripts:
     - `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/scripts/dev_only/test_edge_function.js`
     - Any other scripts using Supabase client

---

## Alternative Testing Path: Direct Database Simulation

Since the Edge Function can't be invoked due to JWT issues, we can test the logic by simulating it directly in the database.

### What the Edge Function Does

1. Queries `wellpath_scoring_marker_pillar_weights_normalized` view
2. Gets patient biomarker/biometric readings
3. Looks up scores from `biomarkers_detail`/`biometrics_detail`
4. Calculates normalized scores
5. Inserts into `patient_wellpath_score_items` table
6. Returns summary

### Manual Test Query (Biomarkers for Male Patient)

```sql
-- Simulate Edge Function logic for biomarkers
WITH patient_info AS (
  SELECT
    user_id,
    biological_sex as gender,
    date_part('year', age(date_of_birth)) as age,
    weight_kg * 2.20462 as weight_lb
  FROM patient_details
  WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
),
applicable_weights AS (
  SELECT
    w.*,
    p.gender,
    p.age
  FROM wellpath_scoring_marker_pillar_weights_normalized w
  CROSS JOIN patient_info p
  WHERE w.is_active = true
    AND w.biomarker_name IS NOT NULL
    AND (w.gender IS NULL OR w.gender = 'male_female' OR w.gender = 'M')
    AND (w.age_min IS NULL OR p.age >= w.age_min)
    AND (w.age_max IS NULL OR p.age <= w.age_max)
),
patient_readings AS (
  SELECT DISTINCT ON (biomarker_name)
    biomarker_name,
    value,
    test_date
  FROM patient_biomarker_readings
  WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
  ORDER BY biomarker_name, test_date DESC
)
SELECT
  w.biomarker_name,
  w.pillar_name,
  r.value as patient_value,
  w.max_normalized_score_male,
  w.max_normalized_score_female,
  COUNT(*) OVER (PARTITION BY w.pillar_name) as items_per_pillar
FROM applicable_weights w
LEFT JOIN patient_readings r ON r.biomarker_name = w.biomarker_name
ORDER BY w.pillar_name, w.biomarker_name
LIMIT 20;
```

This query will show:
- Which biomarkers apply to the male patient
- Their pillar assignments
- Patient values (if available)
- Normalized weights (male/female)
- How many items contribute to each pillar

---

## Files Modified/Created

### Edge Function Code
1. `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/functions/calculate-wellpath-score/index.ts`
   - Version 3.0
   - Complete rewrite using normalized weight views
   - Writes to `patient_wellpath_score_items` table

### Database Migrations
1. `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251017_wellpath_scoring_normalization.sql`
   - Creates normalized weight views
   - Handles gender-specific calculations
   - Implements max_grouping logic

2. `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251017_patient_wellpath_score_items.sql`
   - Creates output table
   - Adds indexes and RLS policies
   - Implements gender-specific constraints

### Test Scripts
1. `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/scripts/dev_only/test_edge_function.js`
   - Node.js test script
   - Currently blocked by JWT issue

---

## Database Objects Status

### Tables
```sql
-- Check if table exists and has correct structure
\d patient_wellpath_score_items
```

### Views
```sql
-- Check if views exist
\dv wellpath_scoring_*_normalized

-- Test view queries
SELECT pillar_name, COUNT(*)
FROM wellpath_scoring_marker_pillar_weights_normalized
WHERE is_active = true
GROUP BY pillar_name;

SELECT pillar_name, COUNT(*)
FROM wellpath_scoring_question_pillar_weights_normalized
WHERE is_active = true
GROUP BY pillar_name;
```

### Sample Data
```sql
-- Check test patients exist
SELECT user_id, biological_sex, date_part('year', age(date_of_birth)) as age
FROM patient_details
WHERE user_id IN ('1758fa60-a306-440e-8ae6-9e68fd502bc2', 'd9581a86-0f30-4be4-ba9e-6ae269700d4d');

-- Check they have data
SELECT
  '1758fa60-a306-440e-8ae6-9e68fd502bc2' as patient_id,
  (SELECT COUNT(*) FROM patient_biomarker_readings WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2') as biomarkers,
  (SELECT COUNT(*) FROM patient_biometric_readings WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2') as biometrics,
  (SELECT COUNT(*) FROM patient_survey_responses WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2') as survey_responses

UNION ALL

SELECT
  'd9581a86-0f30-4be4-ba9e-6ae269700d4d',
  (SELECT COUNT(*) FROM patient_biomarker_readings WHERE user_id = 'd9581a86-0f30-4be4-ba9e-6ae269700d4d'),
  (SELECT COUNT(*) FROM patient_biometric_readings WHERE user_id = 'd9581a86-0f30-4be4-ba9e-6ae269700d4d'),
  (SELECT COUNT(*) FROM patient_survey_responses WHERE user_id = 'd9581a86-0f30-4be4-ba9e-6ae269700d4d');
```

---

## Recommendations

### Immediate Actions

1. **Resolve JWT Issue**
   - Check Supabase Dashboard for correct API keys
   - Verify project settings haven't changed
   - Test Edge Function from Supabase Dashboard UI

2. **Test Database Logic**
   - Run the manual test queries above
   - Verify normalized weights are calculated correctly
   - Confirm patient data is accessible

### Once JWT is Fixed

1. Call Edge Function with male patient
2. Verify items inserted into `patient_wellpath_score_items`
3. Call Edge Function with female patient
4. Compare male vs female normalized scores
5. Verify max_grouping logic (PAP/HPV)
6. Create aggregation views for UI

---

## Status: ⏸️ Paused - Waiting for JWT Resolution

**Next Task**: Resolve JWT authentication issue to enable Edge Function testing

**Priority**: HIGH - Blocking all Edge Function testing

**Version**: 3.0
**Last Updated**: 2025-10-17 23:30 UTC
