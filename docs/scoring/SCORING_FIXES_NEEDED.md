# WellPath V2 Scoring Fixes Needed

## Summary of Progress

Added individual component breakdowns to API and began integrating custom survey scoring functions. However, significant scoring discrepancies remain.

## Current Status (Patient 1a8a56a1-360f-456c-837f-34201b13d445)

### Overall Score
- **API**: 62.81%
- **Ground Truth**: 59.4%
- **Difference**: +3.41% (acceptably close)

### Pillar Comparisons

| Pillar | API Score | Ground Truth | Difference | Status |
|--------|-----------|--------------|------------|--------|
| Healthful Nutrition | 67.19% | 62.5% | +4.69% | ⚠️ Small discrepancy |
| Movement + Exercise | 56.67% | 54.9% | +1.77% | ✅ Close match |
| Restorative Sleep | 53.13% | 54.0% | -0.87% | ✅ Close match |
| Cognitive Health | 60.60% | 57.4% | +3.20% | ⚠️ Small discrepancy |
| Stress Management | 77.03% | 77.1% | -0.07% | ✅ Perfect match |
| Connection + Purpose | 39.81% | 31.1% | +8.71% | ⚠️ Biomarker issue |
| **Core Care** | **65.46%** | **79.1%** | **-13.64%** | ❌ **Major issue** |

## Root Causes Identified

### 1. Missing Custom Survey Scoring (PARTIALLY FIXED)

**Problem**: The original `wellpath_score_runner_survey_v2.py` script has special handling for several question types that bypass the normal QUESTION_CONFIG scoring loop:

```python
# From original script (lines 3002-3032)
move_scores = score_movement_pillar(row, movement_questions)
sleep_issues_scores = score_sleep_issues(row)
sleep_proto_score = score_sleep_protocols(row.get("4.07", ""))
sub_scores = get_substance_score(row)
```

**What Was Fixed**:
- ✅ Added `get_substance_score()` call to database-driven scorer
- ✅ Added `score_sleep_protocols()` call
- ✅ Added `score_movement_pillar()` call
- ✅ Added `score_sleep_issues()` call

**Result**: Core Care improved from 230.20/255.00 to 274.40/304.00 (+44.20 points)

**What's Still Missing**:
- Core Care GT: 357.30/385.00
- Core Care API: 274.40/304.00
- **Gap**: -82.90 raw points, -81.00 max points

### 2. Core Care Detailed Analysis

#### API (Current):
- 42 questions contributing
- Total weighted: 274.40
- Total max: 304.00
- Normalized: 90.26%

#### Ground Truth:
- Unknown number of questions (need to count from breakdown file)
- Total weighted: 357.30
- Total max: 385.00
- Normalized: 92.80%

#### Missing Components:
The 81-point max score gap suggests entire question categories are missing from the database-driven scorer. Possible candidates:
- Sleep apnea scoring (complex multi-question logic)
- Screening date compliance (10 screening questions with custom date scoring)
- Additional hygiene/preventive care questions
- Stress/coping mechanism scoring

### 3. Connection + Purpose Biomarker Discrepancy

**Problem**: Biomarker scoring differs significantly

**API**: 2.03/10.0 (20.26%)
**Ground Truth**: 1.06/10.0 (10.6%)

**Individual Markers**:
- hsCRP: 0.720 (API) vs unknown (GT)
- Cortisol: 0.000 (both)
- DHEA-S: 1.305 (API) vs unknown (GT)

**Likely Cause**: Different scoring ranges or weights in `marker_config.json` vs the ranges used in preliminary_data scripts.

### 4. Healthful Nutrition Survey Discrepancy

**API**: 72.50/83.0 (87.35%)
**Ground Truth**: 80.50/83.0 (97.0%)

**Gap**: -8.0 raw points

**Likely Cause**: Complex custom scoring functions (protein intake, calorie intake) may not be executing properly or have different calculation logic.

## Action Items

### High Priority (Core Care)

1. **Identify all missing Core Care questions**
   - Compare question lists from API vs ground truth breakdown
   - Check if screening date questions (10.01-10.08) are being scored
   - Verify sleep apnea multi-question scoring is working
   - Check stress/coping mechanism scoring

2. **Verify QUESTION_CONFIG completeness**
   - Ensure all Core Care questions from Survey_questions.csv are in QUESTION_CONFIG
   - Check that pillar_weights are set correctly for Core Care questions
   - Verify that conditional questions are being handled properly

3. **Debug custom scoring execution**
   - Add debug logging to show which questions use `score_fn`
   - Verify that all `score_fn` functions are being called
   - Check that the responses dictionary has all required data for custom functions

### Medium Priority (Biomarkers)

4. **Fix biomarker scoring ranges**
   - Compare `marker_config.json` with scoring ranges in preliminary_data
   - Specifically check Connection + Purpose markers (hsCRP, DHEA-S)
   - Verify that marker weights match between systems

### Low Priority (Fine-tuning)

5. **Fix Healthful Nutrition survey scoring**
   - Debug protein intake scoring (question 2.11)
   - Debug calorie intake scoring (question 2.62)
   - Verify BMR calculations match between systems

6. **Fix Cognitive Health discrepancy**
   - Check cognitive activities scoring function
   - Verify question weights

## Files Modified

- `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/scoring_engine/survey_scorer.py:701-825` - Added custom scoring calls
- `/Users/keegs/Documents/GitHub/WellPath-V2-Backend/scoring_engine/scoring_service.py:420-490` - Added detailed breakdown methods

## Next Steps

1. Run the `WellPath_score_runner_survey_v2.py` script on the same patient data to generate the CSV output
2. Compare the CSV output question-by-question with the API output
3. Identify which specific questions are missing or scored differently
4. Fix the remaining issues in `survey_scorer.py`

## Commands to Re-test

```bash
# Restart API
pkill -f uvicorn && sleep 2 && source venv/bin/activate && uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload 2>&1 &

# Test scoring
curl -s "http://localhost:8000/api/v1/scores/patient/1a8a56a1-360f-456c-837f-34201b13d445" | python3 -c "import sys, json; d=json.load(sys.stdin); print(f'Overall: {d[\"overall_score\"]:.2f}%'); print(f'Core Care: {d[\"breakdown\"][\"Core Care\"][\"total_score\"]:.2f}%')"

# Check Core Care details
curl -s "http://localhost:8000/api/v1/scores/patient/1a8a56a1-360f-456c-837f-34201b13d445?include_breakdown=true" | python3 -c "
import sys, json
d = json.load(sys.stdin)
cc = d['breakdown']['Core Care']['components']['survey']
print(f'Core Care Survey: {cc[\"raw_score\"]:.2f}/{cc[\"max_score\"]:.2f} = {cc[\"normalized\"]:.2f}%')
"
```
