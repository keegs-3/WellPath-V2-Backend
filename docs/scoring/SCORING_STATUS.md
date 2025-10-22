# WellPath V2 Scoring Status - Root Cause Identified

## Summary

The scoring discrepancy is NOT due to missing custom functions or incorrect scoring logic. All custom functions are defined and being called correctly. The issue is **missing survey responses in the database**.

## Root Cause

**Ground Truth (CSV)**: 357.30/385.0 for Core Care survey
**API (Database)**: 273.20/304.0 for Core Care survey

### What's Happening

1. **CSV has all 45 Core Care questions with responses** for patient 1a8a56a1
2. **Database only has 35 of those 45 questions** for the same patient
3. The 10 missing questions are:
   - 8.60, 9.10, 9.40, 9.50, 9.60, 10.04, 10.05, 10.06, 10.07, 10.10

4. **Expected max scores**:
   - All 45 questions + substances = 334 + 49 = **383.0** (matches GT 385.0 ± 2)
   - Only 35 questions + substances = 255 + 49 = **304.0** (matches API exactly!)

### Verification

```bash
# CSV columns exist and have values
8.60: "Reduced mental health|Impaired work performance|Other, but maybe in the future"
10.10: "No"
9.10: "No"
9.40: "" (empty)
9.50: "" (empty)
9.60: "" (empty)
10.04: "Grandparent"
10.05: "" (empty)
10.06: "No"
10.07: "" (empty)
10.10: "Not at all"
```

Many have empty values, but the CSV scorer still processes them and includes their max scores.

## The Real Problem

The data import script (`scripts/dev_only/import_all_test_data.py`) is:
1. **Skipping empty/NULL responses** when importing to database
2. **Not importing all question responses** for some reason

This causes the API to have fewer questions than the ground truth, leading to lower max scores.

## Solution

The import script needs to import ALL responses from the CSV, including empty ones, OR the scorer needs to count max scores for all QUESTION_CONFIG questions, not just answered ones.

**Recommendation**: Import all responses, using NULL/empty string for unanswered questions, so the database matches the CSV exactly.

## Scoring Logic Status

✅ All custom scoring functions are defined and working:
- `protein_intake_score` - Working
- `calorie_intake_score` - Working
- `score_movement_pillar` - Working
- `score_sleep_issues` - Working
- `score_sleep_protocols` - Working
- `calc_sleep_apnea_score` - Working
- `score_cognitive_activities` - Working
- `stress_score` - Working
- `coping_score` - Working
- `get_substance_score` - Working (43/49 points = 87.8%)

✅ QUESTION_CONFIG is correct:
- Has all 45 Core Care questions
- Weights match CSV config
- Total max = 383.0 (matches GT 385.0)

✅ Survey scorer logic is correct:
- Properly scales scores (0-1)
- Properly applies weights
- Properly sums pillar totals

## Next Step

Fix `scripts/dev_only/import_all_test_data.py` to import ALL survey responses, including empty ones, so database matches CSV exactly.
